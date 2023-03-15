//
//  PEPImageDoodleCollectionViewCell.h
//  PEPClassroom
//
//  Created by 李沛倬 on 2019/8/27.
//  Copyright © 2019 PEP. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PEPImageDoodleView.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger , PEPImageDoodleType){
    PEPImageDoodleTypeScale = 1,
    PEPImageDoodleTypeMove,
};

@protocol PEPImageDoodleCollectionViewCellDelegate <NSObject>

- (void)doodleViewDoodleDidMoved:(PEPImageDoodleView *)doodleView pathArray:(NSArray *)pathArray touchPoint:(CGPoint)point andType:(NSInteger)type;
/**
 *返回手势缩放比例
 *param x 横坐标位移
 *param y 纵坐标位移
 */
- (void)imageDoodleCollectionViewCellPositionX:(CGFloat)offset_x andY:(CGFloat)offset_y andScale:(CGFloat)scale;

@end

@interface PEPImageDoodleCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) PEPImageDoodleView *imageView;

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) UIImage *image;

@property (nonatomic, assign) BOOL doodle;

@property (nonatomic, assign) BOOL eraser;

@property (nonatomic, assign) float offset_x;//记录缩放后，x轴位置
@property (nonatomic, assign) float offset_y;//记录缩放后，y轴位置

/** 是否有涂鸦 */
@property (nonatomic, assign, readonly) BOOL hasDoodle;

/** 一次涂鸦结束以后将会回调此block，将涂鸦后的image传出 */
@property (nonatomic, copy) void(^imageDoodleDidEnd)(UIImage *image);
/** 一次涂鸦结束以后将会回调此block，将涂鸦后的image传出(不包含背景) */
@property (nonatomic, copy) void(^imageDoodleViewDidEnd)(UIImage *image);


/** 代理返回绘画路径*/
@property (nonatomic , weak)id <PEPImageDoodleCollectionViewCellDelegate> delegate;

/** 获取放大后的图片 */
- (UIImage *)captureScreenForView:(UIView *)currentView;

/** 获取区域的图片 */
- (UIImage *)cutImageWithRect:(CGRect)rect andTargetImage:(UIImage *)targetImage;

/** 获取截图需要的rect */
- (CGRect)getScaleRectAndShowY:(BOOL)hasY;

- (void)clearAllDoodle;

@end

NS_ASSUME_NONNULL_END
