//
//  PEPImageDoodleViewController.h
//  PEPClassroom
//
//  Created by 李沛倬 on 2019/8/13.
//  Copyright © 2019 PEP. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


FOUNDATION_EXPORT NSBundle *PEPImageDoodleAssetsBundle(void);

FOUNDATION_EXPORT NSString *PEPImageDoodleLocalizedString(NSString *key);



@protocol PEPImageDoodleViewControllerDelegate;

@interface PEPImageDoodleViewController : UIViewController

@property (nonatomic, strong) NSMutableArray<UIImage *> *dataSource;
/**存储图片所有的线*/
@property (nonatomic, strong) NSMutableArray * lineArray;
/**存储图片信息*/
@property (nonatomic, strong)  NSDictionary * imageInfoDictionary;

/** 图片浏览器允许的最大数量，默认为2 */
@property (nonatomic, assign) NSUInteger availableImageCountMax;

@property (nonatomic, weak) id<PEPImageDoodleViewControllerDelegate> delegate;


- (instancetype)initWithImages:(NSArray<UIImage *> *)dataSource;

- (void)addImage:(UIImage *)image;

@end


@protocol PEPImageDoodleViewControllerDelegate <NSObject>

/** 一次涂鸦结束以后将会回调此代理方法，将涂鸦后的image传出 */
- (void)imageDoodleViewController:(PEPImageDoodleViewController *)imageDoodle imageDoodleDidEnd:(NSMutableArray *)imageArray forIndex:(NSUInteger)index;
/** 实时返回绘画的路径以及point点*/
- (void)doodleViewDoodleDidMoved:(NSArray *)pathArray touchPoint:(CGPoint)point andType:(NSInteger)type andDooleImage:(UIImage *)image;
/** 顺时针旋转90度*/
- (void)doodleViewRotate:(CGFloat)rotate andRotateImage:(UIImage *)image;
/** 清除所有画笔层*/
- (void)doodleViewClearAllDoodle:(UIImage *)image;
/** 返回上一页*/
- (void)doodleViewClickBackButton;
/**
 *返回手势缩放比例
 *param x 横坐标位移
 *param y 纵坐标位移
 */
- (void)imageDoodleCollectionViewCellPositionX:(CGFloat)offset_x andY:(CGFloat)offset_y andScale:(CGFloat)scale;
@end

NS_ASSUME_NONNULL_END
