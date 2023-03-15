//
//  TJLImagePickerController.h
//  PhotoManagement
//
//  Created by Oma-002 on 17/1/12.
//  Copyright © 2017年 com.oma.matec. All rights reserved.
//

#import <UIKit/UIKit.h>

#define IPHONE_X \
({BOOL isPhoneX = NO;\
if (@available(iOS 11.0, *)) {\
    isPhoneX = [[UIApplication sharedApplication] delegate].window.safeAreaInsets.bottom > 0.0;\
}\
(isPhoneX);})

typedef void(^TJLPicPickerSuccessedHanlder)(NSArray *imageArray);

typedef void(^TJLTakePhotoSuccessedHanlder)(UIImage *image);

@interface TJLImagePickerController : UINavigationController

+ (instancetype) sharedInstance;

- (void)showPickerInController:(UIViewController *)vc successBlock:(TJLPicPickerSuccessedHanlder)succeedHandler;

- (void)showCameraInController:(UIViewController *)vc successBlock:(TJLTakePhotoSuccessedHanlder)succeedHandler;

- (void)showPickerInController:(UIViewController *)vc total:(NSInteger)total successBlock:(TJLPicPickerSuccessedHanlder)succeedHandler;

@end
