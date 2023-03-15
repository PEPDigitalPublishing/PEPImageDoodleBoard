//
//  TJLGridViewController.h
//  PhotoManagement
//
//  Created by Oma-002 on 17/1/12.
//  Copyright © 2017年 com.oma.matec. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TJLBaseViewController.h"
#import <Photos/Photos.h>

#define IPHONE_X \
({BOOL isPhoneX = NO;\
if (@available(iOS 11.0, *)) {\
    isPhoneX = [[UIApplication sharedApplication] delegate].window.safeAreaInsets.bottom > 0.0;\
}\
(isPhoneX);})

@interface TJLGridViewController : UIViewController

@property (strong, nonatomic) NSString *navTitle;

@property (strong, nonatomic) PHFetchResult *assetsFetchResults;

@property (assign, nonatomic) NSInteger total;

@end
