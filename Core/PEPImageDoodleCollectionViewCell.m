//
//  PEPImageDoodleCollectionViewCell.m
//  PEPClassroom
//
//  Created by 李沛倬 on 2019/8/27.
//  Copyright © 2019 PEP. All rights reserved.
//

#import "PEPImageDoodleCollectionViewCell.h"
#import "PEPCutImageManager.h"

@interface PEPImageDoodleCollectionViewCell ()<UIScrollViewDelegate, PEPImageDoodleViewDelegate>
{
    float zoomScale;
    float move_to_x;
    float move_to_y;
    float ratio;
}


@end

@implementation PEPImageDoodleCollectionViewCell

// MARK: - Lifecycle

- (void)awakeFromNib {
    [super awakeFromNib];
    [self initData];
    [self initSubviews];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initSubviews];
    }
    
    return self;
}

// MARK: - Public Method

- (void)clearAllDoodle {
    self.eraser = false;
    self.doodle = false;

    [self.imageView clearAllDoodle];
}

- (BOOL)hasDoodle {
    return self.imageView.hasDoodle;
}

// MARK: - Action

- (void)setDoodle:(BOOL)doodle {
    _doodle = doodle;
    
    self.scrollView.scrollEnabled = !doodle;
    
    if (doodle) {
        self.imageView.lineWidth = 1;
    } else {
        self.imageView.lineWidth = 0;
    }
}

- (void)setEraser:(BOOL)eraser {
    _eraser = eraser;
    
    self.scrollView.scrollEnabled = !eraser;
    
    self.imageView.eraser = eraser;
}

- (void)setImage:(UIImage *)image {
    if (_image != image) {
        _image = image;
        
        self.doodle = false;
        self.eraser = false;
        
        self.scrollView.zoomScale = MIN(1, CGRectGetWidth(self.scrollView.bounds) / image.size.width);
//        self.scrollView.maximumZoomScale = image.size.width / CGRectGetWidth(self.scrollView.bounds) / 2.0;
        self.scrollView.maximumZoomScale = CGFLOAT_MAX;
        self.scrollView.minimumZoomScale = 1;
        
        self.imageView.image = image;
        
        ratio = self.imageView.imageView.frame.origin.x/UIScreen.mainScreen.bounds.size.width;

    }
}


// MARK: - PEPImageDoodleViewDelegate

- (void)doodleViewDoodleDidMoved:(PEPImageDoodleView *)doodleView pathArray:(NSArray *)pathArray touchPoint:(CGPoint)point andType:(NSInteger)type
{
    if ([self.delegate respondsToSelector:@selector(doodleViewDoodleDidMoved:pathArray:touchPoint:andType:)]) {
        [self.delegate doodleViewDoodleDidMoved:doodleView pathArray:pathArray touchPoint:point andType:type];
    }
}
- (void)doodleViewDoodleDidEnded:(PEPImageDoodleView *)doodleView doodleViewImage:(UIImage *)image
{
    if (self.imageDoodleViewDidEnd) {
        CGRect rect = [self getScaleRectAndShowY:NO];
        /*
         判断
         如果缩放的高度 < 屏幕的高度，采取直接截屏，也就是cut方法（cut方法会缩小图片分辨率）
         如果缩放的高度 > 屏幕的高度，采取直接截屏,也就是capture放大，该方法清晰度大于cut
         */
        if (rect.size.height < UIScreen.mainScreen.bounds.size.height) {
            UIImage *finishImg = [[PEPCutImageManager shareManager] cutImageWithRect:rect andTargetImage:image andViewSize:self.frame.size andOutputWidth:self.image.size.width];
            self.imageDoodleViewDidEnd(finishImg);
        }else{
            //判断如果缩放比率是1，直接返回原图
            self.imageDoodleViewDidEnd([self captureScreenForView:self.scrollView]);//直接返回全屏截图即可
        }
    }
}
- (void)doodleViewDoodleDidEnded:(PEPImageDoodleView *)doodleView doodleImage:(UIImage *)image {
    if (self.imageDoodleDidEnd) {
        //新版本返回scrollview截图
        CGRect rect = [self getScaleRectAndShowY:NO];
        /*
         判断
         如果缩放的高度 < 屏幕的高度，采取直接截屏，也就是cut方法（cut方法会缩小图片分辨率）
         如果缩放的高度 > 屏幕的高度，采取直接截屏,也就是capture放大，该方法清晰度大于cut
         */
        if (rect.size.height < UIScreen.mainScreen.bounds.size.height) {
            UIImage *targetImage = [self captureScreenForView:self.scrollView];//先进行截屏，将画笔层和图片层合并为统一图层/
            UIImage *finishImg = [[PEPCutImageManager shareManager] cutImageWithRect:rect andTargetImage:targetImage andViewSize:self.frame.size andOutputWidth:self.image.size.width];
            self.imageDoodleDidEnd(finishImg);
        }else{
            //判断如果缩放比率是1，直接返回原图
            self.imageDoodleDidEnd([self captureScreenForView:self.scrollView]);//直接返回全屏截图即可
        }
    }
}

// MARK: - UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    self.imageView.center = [self centerOfScrollViewContent:scrollView];
}
//结束拖拽
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if ( !decelerate ) {
        CGRect rect = [self getScaleRectAndShowY:NO];
        //计算偏移量
        float offsetX =  - scrollView.contentOffset.x;
        float offsetY =  - scrollView.contentOffset.y;
        
        NSLog(@"图片的  x = %.2f y = %.2f width = %.2f  height = %.2f",self.imageView.imageView.frame.origin.x,self.imageView.imageView.frame.origin.y,self.imageView.imageView.frame.size.width,self.imageView.imageView.frame.size.height);
        NSLog(@"contentSize的  x = %.2f  y = %.2f",self.scrollView.contentSize.width,self.scrollView.contentSize.height);
//        NSLog(@"offsetX = %.2f,offsetY = %.2f",offsetX,offsetY);
        NSLog(@"offsetX = %.2f",offsetX+ratio*self.scrollView.contentSize.width);
        float newSetX = offsetX+ratio*self.scrollView.contentSize.width;
        //返回截图
        [self.imageView doodleViewDoodleDidEnded];
        if ([self.delegate respondsToSelector:@selector(imageDoodleCollectionViewCellPositionX:andY:andScale:)]) {
            [self.delegate imageDoodleCollectionViewCellPositionX:offsetX andY:offsetY andScale:scrollView.zoomScale];
        }
    }
}
//自动滑动完毕
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGRect rect = [self getScaleRectAndShowY:NO];
    //计算偏移量
    float offsetX =  - scrollView.contentOffset.x;
    float offsetY =  - scrollView.contentOffset.y;
    NSLog(@"图片的  x = %.2f y = %.2f width = %.2f  height = %.2f",self.imageView.imageView.frame.origin.x,self.imageView.imageView.frame.origin.y,self.imageView.imageView.frame.size.width,self.imageView.imageView.frame.size.height);
    NSLog(@"contentSize的  x = %.2f  y = %.2f",self.scrollView.contentSize.width,self.scrollView.contentSize.height);
//    NSLog(@"offsetX = %.2f,offsetY = %.2f",offsetX,offsetY);
    NSLog(@"offsetX = %.2f",offsetX+ratio*self.scrollView.contentSize.width);
    float newSetX = offsetX+ratio*self.scrollView.contentSize.width;

    //返回截图
    [self.imageView doodleViewDoodleDidEnded];
    if ([self.delegate respondsToSelector:@selector(imageDoodleCollectionViewCellPositionX:andY:andScale:)]) {
        [self.delegate imageDoodleCollectionViewCellPositionX:newSetX andY:offsetY andScale:scrollView.zoomScale];
    }
}
//结束缩放
- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(nullable UIView *)view atScale:(CGFloat)scale {
    scrollView.contentSize = CGSizeMake(CGRectGetWidth(scrollView.bounds)*scale, CGRectGetHeight(scrollView.bounds)*scale);
    
    if (scale >= 2) {
        zoomScale = 2;
        scrollView.zoomScale = 2;
    }else{
        zoomScale = scale;
        scrollView.zoomScale = scale;
    }
    CGRect rect = [self getScaleRectAndShowY:YES];
    //计算偏移量
    float offsetX =  - scrollView.contentOffset.x;
    float offsetY =  - scrollView.contentOffset.y;
    NSLog(@"图片的  x = %.2f y = %.2f width = %.2f  height = %.2f",self.imageView.imageView.frame.origin.x,self.imageView.imageView.frame.origin.y,self.imageView.imageView.frame.size.width,self.imageView.imageView.frame.size.height);
    NSLog(@"contentSize的  x = %.2f  y = %.2f",self.scrollView.contentSize.width,self.scrollView.contentSize.height);
//    NSLog(@"offsetX = %.2f,offsetY = %.2f",offsetX,offsetY);
    NSLog(@"offsetX = %.2f",offsetX+ratio*self.scrollView.contentSize.width);
    float newSetX = offsetX+ratio*self.scrollView.contentSize.width;

    //返回截图
    [self.imageView doodleViewDoodleDidEnded];
    if ([self.delegate respondsToSelector:@selector(imageDoodleCollectionViewCellPositionX:andY:andScale:)]) {
        [self.delegate imageDoodleCollectionViewCellPositionX:newSetX andY:offsetY andScale:scrollView.zoomScale];
    }
}
- (UIImage *)captureScreenForView:(UIView *)currentView andRect:(CGRect)rect{
    // 开启一个绘图的上下文
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(rect.size.width, rect.size.height), NO, 0.0);
    // 作用于CALayer层的方法。将view的layer渲染到当前的绘制的上下文中。
    [currentView drawViewHierarchyInRect:rect afterScreenUpdates:NO];
    // 获取图片
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    // 结束绘图上下文
    UIGraphicsEndImageContext();
    
    return  viewImage;
}
- (void)textRectWithTargetView:(UIView *)target andRect:(CGRect)rect
{
    UIView *view = [[UIView alloc] initWithFrame:rect];
    view.layer.borderWidth = 1;
    view.layer.borderColor = [UIColor blueColor].CGColor;
    [target addSubview:view];
}

- (void)textWithImage1:(UIImage *)img1 andImage2:(UIImage *)img2
{
    UIImageView * imageView1 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width/2, UIScreen.mainScreen.bounds.size.width/3*2)];
    imageView1.backgroundColor = UIColor.orangeColor;
    imageView1.image = img1;
    [self.contentView addSubview:imageView1];
    UIImageView * imageView2 = [[UIImageView alloc] initWithFrame:CGRectMake(UIScreen.mainScreen.bounds.size.width/2, 0, UIScreen.mainScreen.bounds.size.width/2, UIScreen.mainScreen.bounds.size.width/3*2)];
    imageView2.image = img2;
    imageView2.backgroundColor = UIColor.orangeColor;
    [self.contentView addSubview:imageView2];
}

//获取缩放的截图区域
- (CGRect)getScaleRectAndShowY:(BOOL)hasY{
    float scaleHeight = UIScreen.mainScreen.bounds.size.width*self.image.size.height/self.image.size.width*(zoomScale==0?1:zoomScale);
    float y = (UIScreen.mainScreen.bounds.size.height-scaleHeight)/2;
    return CGRectMake(0, hasY ? y : 0, UIScreen.mainScreen.bounds.size.width, scaleHeight);
}

- (UIImage *)captureScreenForView:(UIView *)currentView {
    // 开启一个绘图的上下文
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(currentView.frame.size.width, currentView.frame.size.height), NO, 0.0);
    // 作用于CALayer层的方法。将view的layer渲染到当前的绘制的上下文中。
    [currentView drawViewHierarchyInRect:CGRectMake(0, 0, currentView.frame.size.width, currentView.frame.size.height) afterScreenUpdates:YES];
    // 获取图片
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    // 结束绘图上下文
    UIGraphicsEndImageContext();
    
    return  viewImage;
}

- (CGPoint)centerOfScrollViewContent:(UIScrollView *)scrollView {
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width) ? (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0;
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height) ? (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0;
    CGPoint actualCenter = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX, scrollView.contentSize.height * 0.5 + offsetY);
    return actualCenter;
}


// MARK: - UI

- (void)initSubviews {
    UIScrollView *scrollView = [UIScrollView.alloc initWithFrame:CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, UIScreen.mainScreen.bounds.size.height)];
    scrollView.showsVerticalScrollIndicator = false;
    scrollView.showsHorizontalScrollIndicator = false;
    scrollView.backgroundColor = [UIColor blackColor];
    scrollView.delegate = self;
    
    PEPImageDoodleView *imageView = [PEPImageDoodleView.alloc initWithFrame:CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, UIScreen.mainScreen.bounds.size.height)];
    imageView.delegate = self;
    [scrollView addSubview:imageView];
    [self.contentView addSubview:scrollView];
    self.scrollView = scrollView;
    self.imageView = imageView;
}

- (void)initData{
    zoomScale = 1;
    _offset_x = 0;
    _offset_y = 0;
    move_to_x = 0;
    move_to_y = 0;
    ratio = 0;
}

@end
