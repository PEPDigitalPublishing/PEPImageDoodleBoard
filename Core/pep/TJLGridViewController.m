//
//  TJLGridViewController.m
//  PhotoManagement
//
//  Created by Oma-002 on 17/1/12.
//  Copyright © 2017年 com.oma.matec. All rights reserved.
//

#import "TJLGridViewController.h"
#import "TJLGridCollectionCell.h"
#import "TJLPreviewViewController.h"
#import "TJLBottomEditView.h"

#define WIDTH [[UIScreen mainScreen] bounds].size.width
#define HEIGHT [[UIScreen mainScreen] bounds].size.height

static NSInteger kGridItemNumberOfColumns = 4;
static CGFloat kGridSpace = 4;

static CGFloat kCollectionItemHeight;
static CGSize kCollectionItemSize;
static CGSize kCollectionPhotoItemSize;

@interface TJLGridViewController () <UICollectionViewDelegate, UICollectionViewDataSource, TJLGridCollectionCellDelegate>

@property (strong, nonatomic) UICollectionView *collectionView;

@property (strong, nonatomic) TJLBottomEditView *bottomEditView;

@property (strong, nonatomic) PHCachingImageManager *imageManager;

/**
 选中的图片下标数组
 */
@property (strong, nonatomic) NSMutableArray *selectIndexArray;

/**
 选中的图片资源asset
 */
@property (strong, nonatomic) NSMutableArray *selectImageArray;

@end

@implementation TJLGridViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        kCollectionItemHeight = (WIDTH - (kGridItemNumberOfColumns + 1) * kGridSpace) / kGridItemNumberOfColumns;
        kCollectionItemSize = CGSizeMake(kCollectionItemHeight, kCollectionItemHeight);
//        kCollectionPhotoItemSize = CGSizeMake(kCollectionItemHeight * 1.2, kCollectionItemHeight * 1.2);
        kCollectionPhotoItemSize = CGSizeMake(WIDTH * 0.7, WIDTH * 0.7);

        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //    [self setupTitle:@"相册"];
        self.title = @"相册";
    //    [self addRightBarButton];
        [self setCollectionViewDetail];
        [self addBottomView];
}

- (void)addRightBarButton {
    self.navigationItem.hidesBackButton = true;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(rightBarButtonClicked:)];
}

- (void)rightBarButtonClicked:(UIBarButtonItem *)sender {
    [self dismiss];
}

- (void)setCollectionViewDetail {
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.collectionView registerClass:[TJLGridCollectionCell class] forCellWithReuseIdentifier:[TJLGridCollectionCell cellIdentifier]];
    [self.view addSubview:self.collectionView];
}

- (void)addBottomView {
    UIEdgeInsets safeAreaInsets;
    if (@available(iOS 11.0, *)) {
        safeAreaInsets = UIApplication.sharedApplication.keyWindow.safeAreaInsets;
    } else {
        safeAreaInsets = UIEdgeInsetsZero;
    }
    if ([[UIDevice currentDevice].model containsString:@"iPad"]) {
        self.bottomEditView = [[TJLBottomEditView alloc] initWithFrame:CGRectMake(0, HEIGHT - 49 - 70, WIDTH, 49)];
    }else{
        self.bottomEditView = [[TJLBottomEditView alloc] initWithFrame:CGRectMake(0, HEIGHT - 49 - safeAreaInsets.bottom-safeAreaInsets.top-44, WIDTH, 49)];
    }
    [self.bottomEditView.chooseButton setTitle:[NSString stringWithFormat:@"确认：(0/%zd)",self.total] forState:UIControlStateNormal];
    [self.bottomEditView.chooseButton addTarget:self action:@selector(chooseButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.bottomEditView.backgroundColor = UIColor.whiteColor;
    [self.view addSubview:self.bottomEditView];
}

- (void)chooseButtonClicked:(UIButton *)sender {
    if (self.selectImageArray.count > 0) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"assetsArray" object:nil userInfo:@{@"assetsArray" : self.selectImageArray}];
        
        [self dismiss];
    }
}

#pragma mark --- Collection

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.assetsFetchResults.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    TJLGridCollectionCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:[TJLGridCollectionCell cellIdentifier] forIndexPath:indexPath];
    [cell initSubViews];
    cell.delegate = self;
    cell.tag = indexPath.item;
    
    PHAsset *asset = self.assetsFetchResults[indexPath.item];
//    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
//    options.synchronous = NO;
//    options.deliveryMode = PHImageRequestOptionsResizeModeFast;
    [self.imageManager requestImageForAsset:asset targetSize:kCollectionPhotoItemSize contentMode:PHImageContentModeAspectFit options:0 resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            cell.gridImageView.image = result;
        });
    }];
    
    [self.selectIndexArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSNumber *index = (NSNumber *)obj;
        if ([index isEqual:@(indexPath.item)]) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                cell.checkImageView.image = [UIImage imageNamed:@"green" inBundle:[NSBundle.alloc initWithPath:[NSBundle.mainBundle pathForResource:@"PEPImageDoodleBoard" ofType:@"bundle"]] compatibleWithTraitCollection:nil];
            });
            stop = YES;
        } else {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                cell.checkImageView.image = [UIImage imageNamed:@"grey" inBundle:[NSBundle.alloc initWithPath:[NSBundle.mainBundle pathForResource:@"PEPImageDoodleBoard" ofType:@"bundle"]] compatibleWithTraitCollection:nil];
            });
        }
    }];
    
    return cell;
}

#pragma mark --- TJLGridCollectionCellDelegate

- (void)didPreviewAssetsViewCell:(TJLGridCollectionCell *)assetsCell {
    PHAsset *asset = self.assetsFetchResults[assetsCell.tag];
    TJLPreviewViewController *vc = [[TJLPreviewViewController alloc] init];
    vc.asset = asset;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)didSelectItemAssetsViewCell:(TJLGridCollectionCell *)assetsCell {
    
    if (self.selectIndexArray.count == self.total) {
        NSString *alertString = [NSString stringWithFormat:@"你最多只能选择%ld张照片",(long)(self.total)];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:alertString message:nil delegate:self cancelButtonTitle:@"我知道了" otherButtonTitles:nil, nil];
        
        [alert show];
        [assetsCell reduceCheckImage];
    } else {
        
        [_bottomEditView.chooseButton setTitle:[NSString stringWithFormat:@"确认(%zd/%zd)",self.selectImageArray.count+1,self.total] forState:UIControlStateNormal];
        
        PHAsset *asset = self.assetsFetchResults[assetsCell.tag];
        
        [self.selectImageArray addObject:asset];
        
        [self.selectIndexArray addObject:@(assetsCell.tag)];
        
        [self.bottomEditView setButtonTitleColorNormal:self.selectIndexArray.count];
    }
}

- (void)didDeselectItemAssetsViewCell:(TJLGridCollectionCell *)assetsCell {
    
    for (int i = 0; i < self.selectIndexArray.count; i++) {
        if ([self.selectIndexArray[i] isEqual:@(assetsCell.tag)]) {
            [self.selectIndexArray removeObjectAtIndex:i];
            [self.selectImageArray removeObjectAtIndex:i];
        }
    }
    [_bottomEditView.chooseButton setTitle:[NSString stringWithFormat:@"确认(%zd/%zd)",self.selectImageArray.count,self.total] forState:UIControlStateNormal];
    [self.bottomEditView setButtonTitleColorNormal:self.selectIndexArray.count];
}

#pragma mark --- dismiss

- (void)dismiss {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark --- get

- (NSString *)navTitle {
    if (!_navTitle) {
        _navTitle = @"相机胶卷";
    }
    return _navTitle;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UIEdgeInsets safeAreaInsets;
        if (@available(iOS 11.0, *)) {
            safeAreaInsets = UIApplication.sharedApplication.keyWindow.safeAreaInsets;
        } else {
            safeAreaInsets = UIEdgeInsetsZero;
        }
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        layout.itemSize = kCollectionItemSize;
        layout.minimumLineSpacing = kGridSpace;
        layout.minimumInteritemSpacing = kGridSpace;
        layout.sectionInset = UIEdgeInsetsMake(kGridSpace, kGridSpace, kGridSpace, kGridSpace);
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, HEIGHT - 49 -safeAreaInsets.bottom-safeAreaInsets.top-44) collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.showsVerticalScrollIndicator = NO;
        [_collectionView setContentOffset:CGPointMake(0, (kCollectionItemHeight + kGridSpace) * (self.assetsFetchResults.count / 4)) animated:YES];
    }
    return _collectionView;
}

- (PHFetchResult *)assetsFetchResults {
    if (!_assetsFetchResults) {
        PHFetchOptions *options = [[PHFetchOptions alloc] init];
        options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
        _assetsFetchResults = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:nil];
    }
    return _assetsFetchResults;
}

- (PHCachingImageManager *)imageManager {
    if (!_imageManager) {
        _imageManager = [[PHCachingImageManager alloc] init];
    }
    return _imageManager;
}

- (NSMutableArray *)selectIndexArray {
    if (!_selectIndexArray) {
        _selectIndexArray = [[NSMutableArray alloc] init];
    }
    return _selectIndexArray;
}

- (NSMutableArray *)selectImageArray {
    if (!_selectImageArray) {
        _selectImageArray = [[NSMutableArray alloc] init];
    }
    return _selectImageArray;
}

@end
