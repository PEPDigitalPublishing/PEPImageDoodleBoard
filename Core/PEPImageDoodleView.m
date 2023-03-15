//
//  PEPImageDoodleView.m
//  PEPClassroom
//
//  Created by 李沛倬 on 2019/8/27.
//  Copyright © 2019 PEP. All rights reserved.
//

#import "PEPImageDoodleView.h"
#import "PEPCutImageManager.h"
#import <AVFoundation/AVFoundation.h>


// MARK: - Line
// MARK: -

@interface PEPLine : NSObject

@property (nonatomic, strong) UIColor *lineColor;

@property (nonatomic, assign) NSInteger lineWidth;

@property (nonatomic, strong) NSMutableArray<NSValue *> *points;

@property (nonatomic, strong) UIBezierPath *path;

@property (nonatomic, assign) NSInteger rotate;

@end


@implementation PEPLine

- (instancetype)init {
    if (self = [super init]) {
        self.points = [NSMutableArray array];
    }
    return self;
}



@end

// MARK: - PEPImageDoodleView
// MARK: -

@interface PEPImageDoodleView ()
/** 背景 */
@property (nonatomic, strong) UIImageView *imageView;


@property (nonatomic, weak) CAShapeLayer *doodleLayer;

@property (nonatomic, strong) NSMutableArray<PEPLine *> *goBackLines;

@property (nonatomic, strong) NSDictionary *linesDictionary;

@end

@implementation PEPImageDoodleView

// MARK: - Lifecycle

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self initSubviews];
}

- (instancetype)init {
    if (self = [super init]) {
        [self initSubviews];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initSubviews];
    }
    return self;
}


// MARK: - Public Method

- (void)setImage:(UIImage *)image {
    if (_image != image) {
        _image = image;
        //竖屏情况下，
        if (image.size.width>image.size.height) {
            self.imageView.frame = CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, UIScreen.mainScreen.bounds.size.width*image.size.height/image.size.width);
        }else{
            self.imageView.frame = CGRectMake(0, 0, image.size.width/image.size.height*UIScreen.mainScreen.bounds.size.height, UIScreen.mainScreen.bounds.size.height);
        }
        self.imageView.center = self.center;
        self.imageView.image = image;
    }
}

- (void)setAllLines:(NSMutableArray *)allLines{
    _allLines = allLines;
    //获取所有数组中的线
    PEPLine *resultLine = [self arrangementFormArray:_allLines];
    //绘制线
    [self drawBrushPath:resultLine];
}

//将数组中所有的线，整理到一个layer
- (PEPLine *)arrangementFormArray:(NSArray *)lineArray{
    //预加载
    PEPLine *resultLine = [[PEPLine alloc] init];
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    bezierPath.lineWidth = self.lineWidth;
    bezierPath.lineCapStyle = kCGLineCapRound;
    bezierPath.lineJoinStyle = kCGLineJoinRound;
    for (PEPLine *line in lineArray) {
        //根据每条线的旋转角度，进行绘制
        resultLine.lineColor = line.lineColor;
        resultLine.lineWidth = line.lineWidth;
        resultLine.rotate = line.rotate;
        for (int i = 0; i < line.points.count; i++) {
            if (i == 0) {
                [bezierPath moveToPoint:[line.points[i] CGPointValue]];
            }else{
                [bezierPath addLineToPoint:[line.points[i] CGPointValue]];
            }
            [resultLine.points addObject:line.points[i]];
        }
    }
    resultLine.path = bezierPath;
    return resultLine;
}

- (void)DoodleViewRotation
{
    //旋转画笔层
    self.doodleView.transform = CGAffineTransformMakeRotation(M_PI * self.rotation / 180.0);
     
    
//    [self doodleViewDoodleDidEnded];
}

- (BOOL)canGoBack {
    return self.allLines.count > 0;
}

- (BOOL)canGoNext {
    return self.goBackLines.count > 0;
}

- (BOOL)goBack {
    if (self.canGoBack == false) { return false; }
    
    PEPLine *line = self.allLines.lastObject;
    [self.goBackLines addObject:line];
    [self.allLines removeObject:line];
    
    return false;
}

- (BOOL)goNext {
    if (self.canGoNext == false) { return false; }
    
    PEPLine *line = self.goBackLines.lastObject;
    [self.allLines addObject:line];
    [self.goBackLines removeObject:line];
    
    return false;
}

- (void)clearAllDoodle {
    self.doodleView.image = nil;
    self.doodleLayer.path = nil;
    
    BOOL clear = self.allLines.count > 0;
    
    [self.allLines removeAllObjects];
    [self.goBackLines removeAllObjects];
    
    if (clear) {
        // 清除所有涂鸦后也要回调代理方法
//        [self doodleViewDoodleDidEnded];
    }
}

- (BOOL)hasDoodle {
    return self.doodleView.image != nil || self.doodleLayer.path != nil;
}


// MARK: - Draw



- (void)drawBrushPath:(PEPLine *)line {
    CAShapeLayer *shapeLayer;
    shapeLayer = self.doodleLayer;
    shapeLayer.strokeColor = self.lineColor.CGColor;
    shapeLayer.fillColor = UIColor.clearColor.CGColor;
    shapeLayer.lineWidth = self.lineWidth==0 ? 1 : self.lineWidth;
    shapeLayer.path = line.path.CGPath;
    
    NSLog(@"绘制完毕");
}

//擦去line
- (void)drawErasePath:(PEPLine *)line {
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(UIScreen.mainScreen.bounds.size.height, UIScreen.mainScreen.bounds.size.height), false, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self.doodleView.layer renderInContext:context];

    [UIColor.clearColor set];

    line.path.lineWidth = 16;
    [line.path strokeWithBlendMode:kCGBlendModeCopy alpha:0];
    [line.path stroke];

    self.doodleView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
}

// MARK: - Touch Action
//划点
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (self.lineWidth == 0 && self.eraser == false) { return; }
    UITouch *touch = touches.anyObject;
    CGPoint touchPoint = [touch locationInView:self.doodleView];
    CGPoint resultPoint = [touch locationInView:self.imageView];
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    bezierPath.lineWidth = self.lineWidth;
    bezierPath.lineCapStyle = kCGLineCapRound;
    bezierPath.lineJoinStyle = kCGLineJoinRound;
    [bezierPath moveToPoint:touchPoint];
    
    PEPLine *line = [PEPLine.alloc init];
    line.lineColor = self.lineColor;
    line.lineWidth = self.lineWidth;
    line.path = bezierPath;
    line.rotate = self.rotation;
    [line.points addObject:[NSValue valueWithCGPoint:touchPoint]];
    
    [self.allLines addObject:line];
    [self.goBackLines removeAllObjects];
    
    if ([self.delegate respondsToSelector:@selector(doodleViewDoodleWillBegan:)]) {
        [self.delegate doodleViewDoodleWillBegan:self];
    }
    //整理到统一layer中
    PEPLine *resultLine = [self arrangementFormArray:self.allLines];
    //绘制
    [self drawBrushPath:resultLine];
    
    if ([self.delegate respondsToSelector:@selector(doodleViewDoodleDidBegan:)]) {
        [self.delegate doodleViewDoodleDidBegan:self];
    }
    if ([self.delegate respondsToSelector:@selector(doodleViewDoodleDidMoved:pathArray:touchPoint:andType:)]) {
        [self.delegate doodleViewDoodleDidMoved:self pathArray:self.allLines touchPoint:[self getImagePointWith:resultPoint] andType:0];
    }
}

//划线
- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (self.lineWidth == 0 && self.eraser == false) { return; }
    UITouch *touch = touches.anyObject;
    CGPoint touchPoint = [touch locationInView:self.doodleView];
    CGPoint resultPoint = [touch locationInView:self.imageView];
    
    PEPLine *lastLine = self.allLines.lastObject;

    [lastLine.path addLineToPoint:touchPoint];

    [lastLine.points addObject:[NSValue valueWithCGPoint:touchPoint]];
    if (self.eraser) {
        [self drawErasePath:lastLine];
    } else {
        //整理到统一layer中
        PEPLine *resultLine = [self arrangementFormArray:self.allLines];
        //绘制
        [self drawBrushPath:resultLine];
    }
    
    if ([self.delegate respondsToSelector:@selector(doodleViewDoodleDidMoved:pathArray:touchPoint:andType:)]) {
        [self.delegate doodleViewDoodleDidMoved:self pathArray:self.allLines touchPoint:[self getImagePointWith:resultPoint] andType:1];
    }
}

//结束上传数据
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (self.lineWidth == 0 && self.eraser == false) { return; }
    UITouch *touch = touches.anyObject;
    CGPoint touchPoint = [touch locationInView:self.doodleView];
    CGPoint resultPoint = [touch locationInView:self.imageView];
    
    if ([self.delegate respondsToSelector:@selector(doodleViewDoodleDidMoved:pathArray:touchPoint:andType:)]) {
        [self.delegate doodleViewDoodleDidMoved:self pathArray:self.allLines touchPoint:[self getImagePointWith:resultPoint] andType:2];
    }
    if ([self.delegate respondsToSelector:@selector(doodleViewDoodleWillEnded:)]) {
        [self.delegate doodleViewDoodleWillEnded:self];
    }
    [self doodleViewDoodleDidEnded];
}

// MARK: - Action

- (void)doodleViewDoodleDidEnded {
    if ([self.delegate respondsToSelector:@selector(doodleViewDoodleDidEnded:doodleImage:)]) {
        [self.delegate doodleViewDoodleDidEnded:self doodleImage:self.doodleView.image];
    }
}



// MARK: - UI


- (void)initSubviews {
    self.userInteractionEnabled = true;
    
    self.lineColor = UIColor.redColor;
    self.allLines = [NSMutableArray array];
    self.goBackLines = [NSMutableArray array];
    
    UIImageView *imageView = [UIImageView.alloc initWithFrame:self.bounds];
    imageView.contentMode = UIViewContentModeScaleAspectFit;

    //设置正方形画布，这样画布旋转后，坐标系不会有偏移。
    UIImageView *doodleView = [UIImageView.alloc initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.width)];
    doodleView.center = self.center;
    doodleView.contentMode = UIViewContentModeScaleAspectFit;
    doodleView.backgroundColor = UIColor.clearColor;
    
    CAShapeLayer *doodleLayer = [CAShapeLayer.alloc init];
    doodleLayer.frame = doodleView.bounds;
    doodleLayer.lineJoin = kCALineJoinRound;
    doodleLayer.lineCap = kCALineCapRound;
    [doodleView.layer addSublayer:doodleLayer];
    
    [self addSubview:imageView];
    [self addSubview:doodleView];
    
    self.imageView = imageView;

    self.doodleView = doodleView;
    self.doodleLayer = doodleLayer;
    NSLog(@"加载完毕");
}

// MARK: - Private Method

- (CGPoint)getImagePointWith:(CGPoint)touchPoint
{
    float imageW =self.image.size.width;
    
    CGPoint point = CGPointMake(self.image.size.width/(UIScreen.mainScreen.bounds.size.width-self.imageView.frame.origin.x*2)*touchPoint.x, self.image.size.height/(UIScreen.mainScreen.bounds.size.height-self.imageView.frame.origin.y*2)*touchPoint.y);
    
    return point;//1729.51_883.01
}

- (UIImage *)screenshotDoodleView {
    return [self screenshotWithView:self.imageView];
}

- (UIImage *)screenshotWithView:(UIView *)view {
    UIGraphicsBeginImageContextWithOptions(view.frame.size, false, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [view.layer renderInContext:context];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (UIImage *)screenshotWithView:(UIView *)view rect:(CGRect)rect {
    UIImage *image = [self screenshotWithView:view];
    
    CGFloat scale = UIScreen.mainScreen.scale;
    CGRect scaleRect = CGRectMake(rect.origin.x * scale, rect.origin.y * scale, rect.size.width * scale, rect.size.height * scale);
    CGImageRef cgImage = CGImageCreateWithImageInRect(image.CGImage, scaleRect);
    
    UIImage *screenshotImage = [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);
    
    return screenshotImage;
}

@end
