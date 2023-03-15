//
//  PEPImageCaptureController.h
//  PEPClassroom
//
//  Created by 李沛倬 on 2019/8/12.
//  Copyright © 2019 PEP. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol PEPImageCaptureControllerDelegate;

@interface PEPImageCaptureController : UIViewController

/**可以选择图片的数量*/
@property (nonatomic , assign) NSInteger currentSelectPicCount;

@property (nonatomic, weak) id<PEPImageCaptureControllerDelegate> delegate;

@end


@protocol PEPImageCaptureControllerDelegate <NSObject>

- (void)imageCaptureController:(PEPImageCaptureController *)imageCaptureController captureImage:(UIImage *)image;

- (void)imageCaptureController:(PEPImageCaptureController *)imageCaptureController captureImages:(NSArray<UIImage *> *)imageArrays;

@end

NS_ASSUME_NONNULL_END
