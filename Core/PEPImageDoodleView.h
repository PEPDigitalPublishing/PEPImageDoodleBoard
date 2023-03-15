//
//  PEPImageDoodleView.h
//  PEPClassroom
//
//  Created by 李沛倬 on 2019/8/27.
//  Copyright © 2019 PEP. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PEPImageDoodleViewDelegate;

typedef NS_ENUM(NSInteger , PEPLineType){
    PEPLineTypeHorizontal = 1,
    PEPLineTypeVertical,
};

@interface PEPImageDoodleView : UIView

@property (nonatomic, strong, readonly) UIImageView *imageView;

@property (nonatomic, strong) UIImage *image;

@property (nonatomic, strong) UIColor *lineColor;

@property (nonatomic, assign) NSInteger lineWidth;
/**旋转的角度*/
@property (nonatomic, assign) int rotation;
/**放大的比例*/
@property (nonatomic, assign) float imageScale;

@property (nonatomic, assign) BOOL eraser;

@property (nonatomic, assign) PEPLineType lineType;
/** 画笔的路径 */
@property (nonatomic, strong) NSMutableArray *allLines;
/** 画板 */
@property (nonatomic, strong) UIImageView *doodleView;
/** 是否有涂鸦 */
@property (nonatomic, assign, readonly) BOOL hasDoodle;


/** 图片缩放比例 */
@property (nonatomic, assign) float zoomScale;

@property (nonatomic, weak) id<PEPImageDoodleViewDelegate> delegate;


@property (nonatomic, assign, readonly) BOOL canGoBack      DEPRECATED_ATTRIBUTE;

@property (nonatomic, assign, readonly) BOOL canGoNext      DEPRECATED_ATTRIBUTE;


- (BOOL)goBack      DEPRECATED_ATTRIBUTE;

- (BOOL)goNext      DEPRECATED_ATTRIBUTE;

/** 清除所有涂鸦 */
- (void)clearAllDoodle;

/** 旋转画笔层 */
- (void)DoodleViewRotation;
/** 返回截图*/
- (void)doodleViewDoodleDidEnded;
@end


@protocol PEPImageDoodleViewDelegate <NSObject>

@optional

- (void)doodleViewDoodleWillBegan:(PEPImageDoodleView *)doodleView;

- (void)doodleViewDoodleDidBegan:(PEPImageDoodleView *)doodleView;

- (void)doodleViewDoodleDidMoved:(PEPImageDoodleView *)doodleView pathArray:(NSArray *)pathArray touchPoint:(CGPoint)point andType:(NSInteger)type;

- (void)doodleViewDoodleWillEnded:(PEPImageDoodleView *)doodleView;

- (void)doodleViewDoodleDidEnded:(PEPImageDoodleView *)doodleView doodleImage:(UIImage *)image;
/**
 * @param doodleView 整个绘画层
 * @param image 画笔层
 */
- (void)doodleViewDoodleDidEnded:(PEPImageDoodleView *)doodleView doodleViewImage:(UIImage *)image;


@end

