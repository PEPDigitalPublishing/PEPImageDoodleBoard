//
//  TJLPreviewViewController.m
//  PhotoManagement
//
//  Created by Oma-002 on 17/1/17.
//  Copyright © 2017年 com.oma.matec. All rights reserved.
//

#import "TJLPreviewViewController.h"
#define iPhoneX UIScreen.mainScreen.bounds.size.height/UIScreen.mainScreen.bounds.size.width >= 2.16
#define TJLNavBarHeight (iPhoneX ? 88.f : 64.f)
#define TJLTabBarBottomHeight (iPhoneX ? 34.f : 0.0)

@interface TJLPreviewViewController ()

@property (strong, nonatomic) UIImageView *imageView;

@end

@implementation TJLPreviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.imageView];
    [[PHCachingImageManager defaultManager] requestImageForAsset:self.asset targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeDefault options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        self.imageView.image = result;
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, UIScreen.mainScreen.bounds.size.height-TJLNavBarHeight-TJLTabBarBottomHeight)];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _imageView;
}

@end
