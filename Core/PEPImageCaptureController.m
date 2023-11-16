//
//  PEPImageCaptureController.m
//  PEPClassroom
//
//  Created by 李沛倬 on 2019/8/12.
//  Copyright © 2019 PEP. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

#import "PEPImageCaptureController.h"
#import "PEPImageDoodleViewController.h"
#import "TJLImagePickerController.h"
//#import <Masonry/Masonry.h>


static CGFloat const HeightForToolBar = 44;

@interface PEPImageCaptureController ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate>
{
    NSInteger _navigationBarHiddenStatus;
    float cameraScale;//
}

// 捕获设备，通常是前置摄像头，后置摄像头，麦克风（音频输入）
@property (nonatomic, strong) AVCaptureDevice *device;

// 输入
@property (nonatomic, strong) AVCaptureDeviceInput *input;

// 输出
@property (nonatomic, strong) AVCaptureStillImageOutput *output;

// 把输入输出结合在一起，并开始启动捕获设备（摄像头）
@property (nonatomic, strong) AVCaptureSession *session;

// 图像预览层，实时显示捕获的图像
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;

@property (nonatomic, strong) UIView *capturePreview;

@property (nonatomic, strong) UIToolbar *toolBar;

@property (nonatomic, strong) UIImagePickerController *imagePicker;

@property (nonatomic, strong) PEPImageDoodleViewController *imageDoodleVC;


@end

@implementation PEPImageCaptureController

// MARK: - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.blackColor;
    
    _navigationBarHiddenStatus = -1;
    cameraScale = 1;
    [self initSubviews];
    
    __weak typeof(self) weakself = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakself initCapturer];
    });
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didChangeRotate:) name:UIApplicationDidChangeStatusBarFrameNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (_navigationBarHiddenStatus == -1) {
        _navigationBarHiddenStatus = self.navigationController.navigationBarHidden;
    }
    
    [self.navigationController setNavigationBarHidden:true animated:true];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.session startRunning];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    if (self.presentedViewController == nil) {
        [self.navigationController setNavigationBarHidden:_navigationBarHiddenStatus == 1 animated:true];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [self.session stopRunning];
}

// MARK: - Action

- (void)cancelBarButtonItemAction:(UIButton *)sender {
    
    if (self.navigationController) {
        [self.navigationController popViewControllerAnimated:true];
    } else {
        [self dismissViewControllerAnimated:true completion:nil];
    }
}

- (void)cameraBarButtonItemAction:(UIButton *)sender {
    
    AVCaptureConnection *conntion = [self.output connectionWithMediaType:AVMediaTypeVideo];
    if (!conntion) {
        NSLog(@"%@", PEPImageDoodleLocalizedString(@"capture_photo_failed"));
        return;
    }
    /* !!!: 改动处 */
    if (conntion.isVideoOrientationSupported && [[UIDevice currentDevice].model containsString:@"iPad"]) {
        UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
        if (orientation == UIInterfaceOrientationLandscapeLeft) {
            conntion.videoOrientation = AVCaptureVideoOrientationLandscapeLeft;
        }else{
            conntion.videoOrientation = AVCaptureVideoOrientationLandscapeRight;
        }
        
    }
    __weak typeof(self) weakself = self;
    [self.output captureStillImageAsynchronouslyFromConnection:conntion completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        if (imageDataSampleBuffer == nil) { return; }
        
        NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
        UIImage *image = [UIImage imageWithData:imageData];
        
        if (image == nil) { return; }
        
        [weakself.session stopRunning];
        //图片矫正(如果图片的方向不是up,那么矫正一下—)
        UIImage * resultImage = image;
        if (image.imageOrientation != UIImageOrientationUp) {
            resultImage = [self fixOrientation:image];
        }
        [weakself didCaptureImage:image];
    }];
}

//矫正相册获取的照片资源位置倾斜
- (UIImage *)fixOrientation:(UIImage *)image {
    if (image.imageOrientation == UIImageOrientationUp)
        return image;
    CGAffineTransform transform = CGAffineTransformIdentity;

    switch (image.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, image.size.height);
            transform = CGAffineTransformRotate(transform,M_PI);
            break;

        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width,0);
            transform = CGAffineTransformRotate(transform,M_PI_2);
            break;

        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform,0, image.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }

    switch (image.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width,0);
            transform = CGAffineTransformScale(transform, -1,1);
            break;

        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.height,0);
            transform = CGAffineTransformScale(transform, -1,1);
            break;
        default:
            break;
    }

    CGContextRef ctx = CGBitmapContextCreate(NULL, image.size.width, image.size.height,
                                             CGImageGetBitsPerComponent(image.CGImage),0,
                                             CGImageGetColorSpace(image.CGImage),
                                             CGImageGetBitmapInfo(image.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (image.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx,CGRectMake(0,0,image.size.height,image.size.width), image.CGImage);
            break;

        default:
            CGContextDrawImage(ctx,CGRectMake(0,0,image.size.width,image.size.height), image.CGImage);
            break;
    }

    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

- (void)photoAlbumBarButtonItemAction:(UIButton *)sender {
    
    BOOL available = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
    if (!available) {
        NSLog(@"Photo Library is Unavailable!");
        return;
    }

    __weak typeof(self) weakSelf = self;
    
    
    [[TJLImagePickerController sharedInstance] showPickerInController:self total:self.currentSelectPicCount successBlock:^(NSArray *imageArray) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf dismissViewControllerAnimated:YES completion:^{
                [weakSelf.delegate imageCaptureController:weakSelf captureImages:imageArray];
            }];
        });
    }];
}

- (void)didCaptureImage:(UIImage *)image {
    [self.delegate imageCaptureController:self captureImage:image];
}


// MARK: - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    UIImage *selectImage = info[UIImagePickerControllerOriginalImage];
    
    __weak typeof(self) weakself = self;
    [picker dismissViewControllerAnimated:true completion:^{
        
        [weakself didCaptureImage:selectImage];
    }];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:true completion:nil];
    
}




// MARK: - Init Capturer

- (void)initCapturer {
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];  //读取设备授权状态
    if (authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied) {
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:PEPImageDoodleLocalizedString(@"tips") message:PEPImageDoodleLocalizedString(@"camera_authorization_limit") preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *settingAction = [UIAlertAction actionWithTitle:PEPImageDoodleLocalizedString(@"goto_setting") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            if ([[UIApplication sharedApplication] canOpenURL:url]) {
                [[UIApplication sharedApplication] openURL:url];
            }
        }];
        
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:PEPImageDoodleLocalizedString(@"cancel") style:UIAlertActionStyleDefault handler:nil];
        
        [alert addAction:settingAction];
        [alert addAction:cancel];
        
        [self presentViewController:alert animated:true completion:nil];
        return;
    }
    
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
//    AVCaptureDevice *device = [self cameraWithPosition:AVCaptureDevicePositionBack];
    if (device == nil) { return; }
    
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput.alloc initWithDevice:device error:nil];
    
    AVCaptureStillImageOutput *output = [AVCaptureStillImageOutput.alloc init];

    AVCaptureSession *session = [AVCaptureSession.alloc init];

    if ([session canSetSessionPreset:AVCaptureSessionPresetPhoto]) {
        session.sessionPreset = AVCaptureSessionPresetPhoto;
    }

    // 将输入输出设备添加到会话（session）
    if ([session canAddInput:input]) {
        [session addInput:input];
        
        if ([session canAddOutput:output]) {
            [session addOutput:output];
        }
    }

    // 预览层的生成
    AVCaptureVideoPreviewLayer *previewLayer = [AVCaptureVideoPreviewLayer.alloc initWithSession:session];
    previewLayer.frame = self.capturePreview.bounds;
    previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    /* !!!: 改动处 */
    if ([[UIDevice currentDevice].model containsString:@"iPad"]) {
        UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
        if (orientation == UIInterfaceOrientationLandscapeLeft) {
            previewLayer.connection.videoOrientation = AVCaptureVideoOrientationLandscapeLeft;
        }else{
            previewLayer.connection.videoOrientation = AVCaptureVideoOrientationLandscapeRight;
        }
    }
    
    [self.capturePreview.layer addSublayer:previewLayer];
    
    if (session.inputs.count > 0 && output.availableImageDataCodecTypes.count > 0) {
        // 设备取景开始
        [session startRunning];
        
        if ([device lockForConfiguration:nil]) {

            // 自动闪光灯
            if ([device isFlashModeSupported:AVCaptureFlashModeAuto]) {
                device.flashMode = AVCaptureFlashModeAuto;
            }
            
            // 自动白平衡
            if ([device isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance]) {
                device.whiteBalanceMode = AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance;
            }
            
            // 连续自动对焦
            if ([device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
                device.focusMode = AVCaptureFocusModeContinuousAutoFocus;
            }
            
            if (device.isSmoothAutoFocusSupported == true) {
                device.smoothAutoFocusEnabled = true;
            }
            
            [device unlockForConfiguration];
        }
        
        self.previewLayer = previewLayer;
    }
    
    
    self.device = device;
    self.input = input;
    self.output = output;
    self.session = session;
}

- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position {
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if (device.position == position) {
            return device;
        }
    }
    return nil;
}



// MARK: - UI

- (void)initSubviews {
    self.view.backgroundColor = UIColor.whiteColor;
    UIEdgeInsets safeAreaInsets = [self safeAreaInsets];
    
    UIView *capturePreview = [UIView.alloc initWithFrame:self.view.bounds];
    capturePreview.backgroundColor = UIColor.blackColor;
    //添加捏合手势
    UIPinchGestureRecognizer *pinGR = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
    [capturePreview addGestureRecognizer:pinGR];
    
    
    UIToolbar *toolBar = [UIToolbar.alloc initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.bounds)-HeightForToolBar-safeAreaInsets.bottom, CGRectGetWidth(self.view.bounds), HeightForToolBar)];
    toolBar.barStyle = UIBarStyleBlack;
    toolBar.translucent = true;
    toolBar.tintColor = UIColor.whiteColor;
    
    UIBarButtonItem *flexibleSpace = [UIBarButtonItem.alloc initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *cancelItem = [UIBarButtonItem.alloc initWithCustomView:[self standardButtonWithTitle:PEPImageDoodleLocalizedString(@"cancel") image:nil action:@selector(cancelBarButtonItemAction:)]];
    UIBarButtonItem *cameraItem = [UIBarButtonItem.alloc initWithCustomView:[self standardButtonWithTitle:nil image:[UIImage imageNamed:@"pb_toolbar_camera" inBundle:PEPImageDoodleAssetsBundle() compatibleWithTraitCollection:nil] action:@selector(cameraBarButtonItemAction:)]];
    UIBarButtonItem *photoAlbumItem = [UIBarButtonItem.alloc initWithCustomView:[self standardButtonWithTitle:PEPImageDoodleLocalizedString(@"album") image:nil action:@selector(photoAlbumBarButtonItemAction:)]];
    
    [toolBar setItems:@[cancelItem, flexibleSpace, cameraItem, flexibleSpace, photoAlbumItem] animated:true];
    
    [self.view addSubview:capturePreview];
    [self.view addSubview:toolBar];
    
    
    
//    capturePreview.translatesAutoresizingMaskIntoConstraints = false;
//    [[capturePreview.leadingAnchor constraintEqualToAnchor:capturePreview.superview.leadingAnchor] setActive:true];
//    [[capturePreview.trailingAnchor constraintEqualToAnchor:capturePreview.superview.trailingAnchor] setActive:true];
//    [[capturePreview.topAnchor constraintEqualToAnchor:capturePreview.superview.topAnchor] setActive:true];
//    [[capturePreview.bottomAnchor constraintEqualToAnchor:capturePreview.superview.bottomAnchor] setActive:true];
    
//    toolBar.translatesAutoresizingMaskIntoConstraints = false;
//    [[toolBar.leadingAnchor constraintEqualToAnchor:toolBar.superview.leadingAnchor] setActive:true];
//    [[toolBar.trailingAnchor constraintEqualToAnchor:toolBar.superview.trailingAnchor] setActive:true];
//    [[toolBar.heightAnchor constraintEqualToConstant:HeightForToolBar] setActive:true];
//    [[toolBar.bottomAnchor constraintEqualToAnchor:toolBar.superview.bottomAnchor] setActive:true];

//    [capturePreview mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.edges.equalTo(capturePreview.superview);
//    }];
//
//    [toolBar mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.right.equalTo(toolBar.superview);
//        make.height.equalTo(@(HeightForToolBar));
//        if (@available(iOS 11.0, *)) {
//            make.bottom.equalTo(toolBar.superview.mas_safeAreaLayoutGuideBottom);
//        } else {
//            make.bottom.equalTo(toolBar.superview);
//        }
//    }];
    
    
    self.capturePreview = capturePreview;
    self.toolBar = toolBar;
}

- (void)handlePinch:(UIPinchGestureRecognizer *)recognizer
{
    CGFloat scale = recognizer.scale;
    if ([self.device lockForConfiguration:nil]) {
        if (scale>1) {
            //放大
            self.device.videoZoomFactor = cameraScale>1?cameraScale-1+scale:scale;
        }else{
            //缩小
            float scaleSize = 1-scale;
            self.device.videoZoomFactor = cameraScale-scaleSize<1?1:cameraScale-scaleSize;
        }
        if (recognizer.state == UIGestureRecognizerStateEnded) {
            cameraScale = self.device.videoZoomFactor;
        }
//            NSLog(@"cameraScale = %.2f   scale = %.2f",cameraScale,scale);
    }
}

- (UIImagePickerController *)imagePicker {
    if (_imagePicker) {
        return _imagePicker;
    }
    
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.allowsEditing = false;
    _imagePicker = imagePicker;
    
    return imagePicker;
}

- (PEPImageDoodleViewController *)imageDoodleVC {
    if (_imageDoodleVC) {
        return _imageDoodleVC;
    }
    
    PEPImageDoodleViewController *imageDoodleVC = [PEPImageDoodleViewController.alloc init];
    
    _imageDoodleVC = imageDoodleVC;
    return _imageDoodleVC;
}



- (UIButton *)standardButtonWithTitle:(NSString *)title image:(UIImage *)image action:(SEL)sel {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:title forState:UIControlStateNormal];
    [button setImage:image forState:UIControlStateNormal];
    [button addTarget:self action:sel forControlEvents:UIControlEventTouchUpInside];
    button.titleLabel.font = [UIFont systemFontOfSize:18];
    
    button.frame = CGRectMake(0, 0, HeightForToolBar, HeightForToolBar);
    
    return button;
}


- (UIEdgeInsets)safeAreaInsets {
    if (@available(iOS 11.0, *)) {
        return UIApplication.sharedApplication.keyWindow.safeAreaInsets;
    } else {
        return UIEdgeInsetsZero;
    }
}


// MARK: - Interface Orientation

//- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
//    if([[UIDevice currentDevice].model containsString:@"iPad"]) {
//        return UIInterfaceOrientationLandscapeRight;
//    }else{
//        return UIInterfaceOrientationPortrait;
//    }
//
//}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    if([[UIDevice currentDevice].model containsString:@"iPad"]) {
        return UIInterfaceOrientationMaskLandscape;
    }else{
        return UIInterfaceOrientationMaskPortrait;
    }
    
}
-(BOOL)shouldAutorotate{
    if([[UIDevice currentDevice].model containsString:@"iPad"]) {
        return YES;

    }else{
        return NO;
    }

}
/* !!!: 改动处 */
- (void)didChangeRotate:(NSNotification*)notice {
    if(![[UIDevice currentDevice].model containsString:@"iPad"]) {
//        //旋转手机
        UIEdgeInsets safeAreaInsets = [self safeAreaInsets];
//        //旋转图像预览层
        self.capturePreview.frame = CGRectMake(0, 0, CGRectGetHeight(self.view.frame), CGRectGetWidth(self.view.frame)-safeAreaInsets.top-safeAreaInsets.bottom);
//        self.previewLayer.connection.videoOrientation = AVCaptureVideoOrientationPortrait;
        
//        NSLog(@"capturePreview = %@",self.capturePreview.frame);
//        NSLog(@"previewLayer = %@",self.previewLayer.frame);
        //旋转工具条
        self.toolBar.frame = CGRectMake(0, CGRectGetWidth(self.view.frame)-HeightForToolBar-safeAreaInsets.bottom, CGRectGetHeight(self.view.frame), HeightForToolBar);
        
        return;
    }
    if ([[UIDevice currentDevice] orientation] == UIInterfaceOrientationLandscapeRight) {
        
        self.previewLayer.connection.videoOrientation = AVCaptureVideoOrientationLandscapeRight;
        
    } else if([[UIDevice currentDevice] orientation] == UIInterfaceOrientationLandscapeLeft) {
        
        self.previewLayer.connection.videoOrientation = AVCaptureVideoOrientationLandscapeLeft;
        
    }
}


@end
