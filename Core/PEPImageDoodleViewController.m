//
//  PEPImageDoodleViewController.m
//  PEPClassroom
//
//  Created by 李沛倬 on 2019/8/13.
//  Copyright © 2019 PEP. All rights reserved.
//

#import "PEPImageDoodleViewController.h"
#import "PEPImageDoodleCollectionViewCell.h"
#import "PEPImageCaptureController.h"
#import "PEPCutImageManager.h"
//#import <Masonry/Masonry.h>

NSBundle *PEPImageDoodleAssetsBundle(void) {
    return [NSBundle.alloc initWithPath:[NSBundle.mainBundle pathForResource:@"PEPImageDoodleBoard" ofType:@"bundle"]];
}

NSString *PEPImageDoodleLocalizedString(NSString *key) {
    return [PEPImageDoodleAssetsBundle() localizedStringForKey:key value:@"" table:nil];
}

typedef NS_ENUM(NSUInteger, PEPImageDoodleToolBarItemType) {
    PEPImageDoodleToolBarItemTypeClose              = 10,
    PEPImageDoodleToolBarItemTypeBrush,
    PEPImageDoodleToolBarItemTypeEraser,
    PEPImageDoodleToolBarItemTypeClear,
    PEPImageDoodleToolBarItemTypeAdd,
    PEPImageDoodleToolBarItemTypeEnlarge,
    PEPImageDoodleToolBarItemTypeLessen,
    PEPImageDoodleToolBarItemTypeRotate,
};


@interface PEPImageDoodleViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, PEPImageCaptureControllerDelegate ,PEPImageDoodleCollectionViewCellDelegate>
{
    NSInteger _navigationBarHiddenStatus;
    NSIndexPath * _pageIndex;
}

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, weak) UICollectionViewFlowLayout *flowLayout;

@property (nonatomic, strong) UIStackView *toolBarStackView;

@property (nonatomic, weak) UIButton *brushButton;

@property (nonatomic, weak) UIButton *eraserButton;

@property (nonatomic, weak) UIButton *toolBarAddImageButtonItem;

@property (nonatomic, strong, readonly) PEPImageDoodleCollectionViewCell *currentCollectionViewCell;



@end

@implementation PEPImageDoodleViewController

// MARK: - Lifecycle

- (BOOL)willDealloc {
    return false;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.dataSource = [NSMutableArray array];
    }
    return self;
}

- (instancetype)initWithImages:(NSArray<UIImage *> *)dataSource {
    if (self = [super init]) {
        self.dataSource = [dataSource mutableCopy];
    }
    
    return self;
}

- (void)setLineArray:(NSMutableArray *)lineArray
{
    if (!_lineArray) {
        _lineArray = [[NSMutableArray alloc] init];
        [_lineArray addObjectsFromArray:lineArray[0][0][@"linePath"]];
    }
}

- (void)setImageInfoDictionary:(NSMutableDictionary *)imageInfoDictionary
{
    _imageInfoDictionary = imageInfoDictionary;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _pageIndex = [NSIndexPath indexPathForRow:0 inSection:0];
    //默认为两张
    _availableImageCountMax = _availableImageCountMax?_availableImageCountMax:2;
    _navigationBarHiddenStatus = -1;
    //加载试图
    [self initSubviews];
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
    
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.navigationController setNavigationBarHidden:_navigationBarHiddenStatus == 1 animated:true];
}


// MARK: - Public Method

- (void)addImage:(UIImage *)image {
    if (image == nil || self.dataSource.count >= self.availableImageCountMax) { return; }
    
    [self.dataSource addObject:image];
    _pageIndex = [NSIndexPath indexPathForRow:self.dataSource.count-1 inSection:0];
    [self.collectionView reloadData];
    
    if (self.dataSource.count >= self.availableImageCountMax) {
        self.toolBarAddImageButtonItem.enabled = false;
    }
}



// MARK: - Action

- (void)moveImageWithImageInformationDictionary:(NSDictionary *)informationDic andCell:(PEPImageDoodleCollectionViewCell *)item
{
    if ([self.imageInfoDictionary.allKeys containsObject:@"scale"] && self.imageInfoDictionary[@"scale"]) {
        //缩放
//        NSLog(@"有缩放");
        float scale = [self.imageInfoDictionary[@"scale"] floatValue];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            item.scrollView.zoomScale = scale;
        });
    }
    //判断是否有位移和缩放
    if ([self.imageInfoDictionary.allKeys containsObject:@"offset_x"] && self.imageInfoDictionary[@"offset_x"]) {
//        //有位移
//        NSLog(@"有位移");
    }
    if ([self.imageInfoDictionary.allKeys containsObject:@"rotation"] && self.imageInfoDictionary[@"rotation"]){
        //旋转
//        NSLog(@"有旋转");
        float rotation = [self.imageInfoDictionary[@"rotation"] floatValue];
        
        item.imageView.rotation = rotation;
        UIImage *currentImage = item.image;
        UIImage *rotateImage;
        if ((rotation/180-0.5) == (int)(rotation/180-0.5) && (rotation/180-0.5)/2 == (int)(rotation/180-0.5)/2) {
            rotateImage = [self image:currentImage rotation:UIImageOrientationRight];
        }else if ((rotation/180-0.5) == (int)(rotation/180-0.5) && (rotation/180-0.5)/2 != (int)(rotation/180-0.5)/2){
            rotateImage = [self image:currentImage rotation:UIImageOrientationLeft];
        }else if ((int)rotation/180%2 == 0){
            rotateImage = [self image:currentImage rotation:UIImageOrientationUp];
        }else{
            rotateImage = [self image:currentImage rotation:UIImageOrientationDown];
        }
        //旋转照片
        item.image = rotateImage;
        //旋转画笔层
        [item.imageView DoodleViewRotation];
    }
}

- (void)closeButtonAction:(UIButton *)sender {
    if (self.navigationController) {
        [self.navigationController popViewControllerAnimated:true];
    } else if (self.presentingViewController) {
        [self dismissViewControllerAnimated:true completion:nil];
    }
}

- (void)brushButtonAction:(UIButton *)sender {
    sender.selected = !sender.selected;
    self.eraserButton.selected = false;
    self.collectionView.scrollEnabled = !sender.selected;
    
    NSInteger index = (NSInteger)round(self.collectionView.contentOffset.x / self.flowLayout.itemSize.width);
    PEPImageDoodleCollectionViewCell *cell = (PEPImageDoodleCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    
    cell.eraser = false;
    cell.doodle = sender.selected;
}

- (void)eraserButtonAction:(UIButton *)sender {
    sender.selected = !sender.selected;
    self.brushButton.selected = false;
    self.collectionView.scrollEnabled = !sender.selected;
    
    NSInteger index = (NSInteger)round(self.collectionView.contentOffset.x / self.flowLayout.itemSize.width);
    PEPImageDoodleCollectionViewCell *cell = (PEPImageDoodleCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    
    cell.doodle = false;
    cell.eraser = sender.selected;
}

- (void)addImageButtonAction:(id)sender {
    
}

- (void)clearButtonAction:(id)sender {
    
    
}

- (void)toolBarItemAction:(UIButton *)sender {
    PEPImageDoodleToolBarItemType type = sender.tag;
    
    for (UIButton *item in self.toolBarStackView.arrangedSubviews) {
        if (item == sender &&
            (type == PEPImageDoodleToolBarItemTypeBrush || type == PEPImageDoodleToolBarItemTypeEraser)) {
            sender.selected = !sender.selected;
        } else {
            item.selected = false;
        }
    }
    
    switch (type) {
        case PEPImageDoodleToolBarItemTypeClose: {
            if ([self.delegate respondsToSelector:@selector(doodleViewClickBackButton)]) {
                [self.delegate doodleViewClickBackButton];
            }
            if (self.navigationController) {
                [self.navigationController popViewControllerAnimated:true];
            } else if (self.presentingViewController) {
                [self dismissViewControllerAnimated:true completion:nil];
            }
            break;
        }
        case PEPImageDoodleToolBarItemTypeBrush: {
            
            sender.selected = !sender.selected;
            
            self.collectionView.scrollEnabled = !sender.selected;
            
            PEPImageDoodleCollectionViewCell *cell = [self getCunrrentCollectionViewCell];

            cell.eraser = false;
            cell.doodle = sender.selected;

            break;
        }
        case PEPImageDoodleToolBarItemTypeEraser: {
            self.collectionView.scrollEnabled = !sender.selected;
            
            PEPImageDoodleCollectionViewCell *cell = [self getCunrrentCollectionViewCell];

            cell.doodle = false;
            cell.eraser = sender.selected;
            break;
        }
        case PEPImageDoodleToolBarItemTypeClear: {
            PEPImageDoodleCollectionViewCell *cell = [self getCunrrentCollectionViewCell];
            NSLog(@"是否有标注   %zd",cell.hasDoodle);
            
            if (cell.hasDoodle) {
                __weak typeof(self) weakself = self;
                [self showAlertForClearAllDoodleWithCancelBlock:nil confrimBlcok:^{
                    //返回截图
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [cell.imageView doodleViewDoodleDidEnded];
                    });
                    //通过socket通知pc端清理所有画笔
                    if ([self.delegate respondsToSelector:@selector(doodleViewClearAllDoodle:)]) {
                        [self.delegate doodleViewClearAllDoodle:cell.imageView.doodleView.image];
                    }
                    [cell clearAllDoodle];
                    
                    weakself.collectionView.scrollEnabled = true;
                }];
            } else {
                [self showAlertWithTitle:PEPImageDoodleLocalizedString(@"tips") message:PEPImageDoodleLocalizedString(@"no_need_to_clear")];
            }
            
            break;
        }
        case PEPImageDoodleToolBarItemTypeAdd: {
            
            if (self.dataSource.count < self.availableImageCountMax) {
                
                PEPImageCaptureController *imageCapture = [PEPImageCaptureController.alloc init];
                imageCapture.delegate = self;
                imageCapture.currentSelectPicCount = self.availableImageCountMax-self.dataSource.count;
                imageCapture.modalPresentationStyle = UIModalPresentationFullScreen;
                [self presentViewController:imageCapture animated:true completion:nil];
                
                PEPImageDoodleCollectionViewCell *cell = [self getCunrrentCollectionViewCell];
                cell.eraser = false;
                cell.doodle = false;
                self.collectionView.scrollEnabled = true;
                
            } else {
                NSString *message = [PEPImageDoodleLocalizedString(@"add_photo_limit") stringByReplacingOccurrencesOfString:@"#" withString:@(self.availableImageCountMax).stringValue];
                [self showAlertWithTitle:PEPImageDoodleLocalizedString(@"tips") message:message];
            }
            break;
        }
        case PEPImageDoodleToolBarItemTypeEnlarge:{
            //放大
            PEPImageDoodleCollectionViewCell * item = [self getCunrrentCollectionViewCell];
            if (item.scrollView.zoomScale<=2) {
                item.scrollView.zoomScale = item.scrollView.zoomScale+0.2;
            }
            NSIndexPath *indexPath = [self.collectionView indexPathForCell:item];
            CGRect rect = [item getScaleRectAndShowY:NO];
            //返回截图
            [item.imageView doodleViewDoodleDidEnded];
            //返回放大比率
            if ([self.delegate respondsToSelector:@selector(imageDoodleCollectionViewCellPositionX:andY:andScale:)]) {
                [self.delegate imageDoodleCollectionViewCellPositionX:item.offset_x-item.scrollView.contentOffset.x andY:item.offset_y-item.scrollView.contentOffset.y andScale:item.scrollView.zoomScale];
            }
            break;
        }
        case PEPImageDoodleToolBarItemTypeLessen:{
            //缩小
            PEPImageDoodleCollectionViewCell * item = [self getCunrrentCollectionViewCell];
            if (item.scrollView.zoomScale>=1){
                item.scrollView.zoomScale = item.scrollView.zoomScale-0.2;
            }
            NSIndexPath *indexPath = [self.collectionView indexPathForCell:item];
            CGRect rect = [item getScaleRectAndShowY:NO];

            //返回截图
            [item.imageView doodleViewDoodleDidEnded];
            
            if ([self.delegate respondsToSelector:@selector(imageDoodleCollectionViewCellPositionX:andY:andScale:)]) {
                [self.delegate imageDoodleCollectionViewCellPositionX:item.offset_x-item.scrollView.contentOffset.x andY:item.offset_y-item.scrollView.contentOffset.y andScale:item.scrollView.zoomScale];
            }
            break;
        }
        case PEPImageDoodleToolBarItemTypeRotate:{
            //旋转
            PEPImageDoodleCollectionViewCell * item = [self getCunrrentCollectionViewCell];
            
            item.imageView.rotation = item.imageView.rotation+90;
            UIImage *currentImage = item.image;
            UIImage *rotateImage = [self image:currentImage rotation:UIImageOrientationRight];
            //发送socket通知pc端旋转90度
            if ([self.delegate respondsToSelector:@selector(doodleViewRotate:andRotateImage:)]) {
                [self.delegate doodleViewRotate:item.imageView.rotation andRotateImage:item.imageView.doodleView.image];
            }
            //旋转照片
            item.image = rotateImage;
            //旋转画笔层
            [item.imageView DoodleViewRotation];
            //替换数据源中的图片
            [self.dataSource replaceObjectAtIndex:_pageIndex.row withObject:rotateImage];
            //返回截图
            [item.imageView doodleViewDoodleDidEnded];
            break;
        }
    }
}



-(UIImage *)image:(UIImage *)image rotation:(UIImageOrientation)orientation
{
    long double rotate = 0.0;
    CGRect rect;
    float translateX = 0;
    float translateY = 0;
    float scaleX = 1.0;
    float scaleY = 1.0;
    
    switch (orientation) {
      case UIImageOrientationLeft:
           rotate =M_PI_2;
           rect =CGRectMake(0,0,image.size.height, image.size.width);
           translateX=0;
           translateY= -rect.size.width;
           scaleY =rect.size.width/rect.size.height;
           scaleX =rect.size.height/rect.size.width;
          break;
      case UIImageOrientationRight:
           rotate =3 *M_PI_2;
           rect =CGRectMake(0,0,image.size.height, image.size.width);
                   translateX= -rect.size.height;
                   translateY=0;
                   scaleY =rect.size.width/rect.size.height;
                   scaleX =rect.size.height/rect.size.width;
          break;
      case UIImageOrientationDown:
           rotate =M_PI;
           rect =CGRectMake(0,0,image.size.width, image.size.height);
           translateX= -rect.size.width;
           translateY= -rect.size.height;
          break;
      default:
           rotate =0.0;
           rect =CGRectMake(0,0,image.size.width, image.size.height);
           translateX=0;
           translateY=0;
          break;
    }
    
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context =UIGraphicsGetCurrentContext();
   //做CTM变换
        CGContextTranslateCTM(context, 0.0, rect.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextRotateCTM(context, rotate);
    CGContextTranslateCTM(context, translateX,translateY);
    
    CGContextScaleCTM(context, scaleX,scaleY);
   //绘制图片
    CGContextDrawImage(context, CGRectMake(0,0,rect.size.width, rect.size.height), image.CGImage);
    
    UIImage *newPic =UIGraphicsGetImageFromCurrentImageContext();
    
    return newPic;
}

- (void)setDataSource:(NSMutableArray<UIImage *> *)dataSource {
    if (_dataSource != dataSource) {
        _dataSource = dataSource;
        
        if (dataSource.count >= self.availableImageCountMax) {
            self.toolBarAddImageButtonItem.enabled = false;
        }
        [self.collectionView reloadData];
    }
}



// MARK: - PEPImageCaptureControllerDelegate

- (void)imageCaptureController:(PEPImageCaptureController *)imageCaptureController captureImage:(UIImage *)image {
    if (image == nil) { return; }
    
    [self addImage:image];

    __weak typeof(self) weakself = self;
    [imageCaptureController dismissViewControllerAnimated:true completion:^{
        [weakself.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:weakself.dataSource.count-1 inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:true];
    }];
    
    [self.delegate imageDoodleViewController:self imageDoodleDidEnd:@[image] forIndex:self.dataSource.count-1];
    
}

- (void)imageCaptureController:(PEPImageCaptureController *)imageCaptureController captureImages:(NSArray<UIImage *> *)imageArrays
{
    if (imageArrays == nil) { return; }
    
    for (UIImage *image in imageArrays) {
        [self addImage:image];
    }
    __weak typeof(self) weakself = self;
    [imageCaptureController dismissViewControllerAnimated:true completion:^{
        [weakself.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:[self.dataSource lastObject] inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:true];
    }];
    [self.delegate imageDoodleViewController:self imageDoodleDidEnd:imageArrays forIndex:self.dataSource.count-1];
}

//MARK: -PEPImageDoodleCollectionViewCellDelegate
- (void)doodleViewDoodleDidMoved:(PEPImageDoodleView *)doodleView pathArray:(NSArray *)pathArray touchPoint:(CGPoint)point andType:(NSInteger)type{
    PEPImageDoodleCollectionViewCell * item = [self getCunrrentCollectionViewCell];
    //item.imageView.rotation
    if ([self.delegate respondsToSelector:@selector(doodleViewDoodleDidMoved:touchPoint:andType:andDooleImage:)]) {
        [self.delegate doodleViewDoodleDidMoved:pathArray touchPoint:point andType:type andDooleImage:doodleView.doodleView.image];
    }
}

- (void)imageDoodleCollectionViewCellPositionX:(CGFloat)offset_x andY:(CGFloat)offset_y andScale:(CGFloat)scale
{
    if ([self.delegate respondsToSelector:@selector(imageDoodleCollectionViewCellPositionX:andY:andScale:)]) {
        [self.delegate imageDoodleCollectionViewCellPositionX:offset_x andY:offset_y andScale:scale];
    }
}
// MARK: - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PEPImageDoodleCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass(PEPImageDoodleCollectionViewCell.class) forIndexPath:indexPath];
    __weak typeof(self) weakself = self;
    if (_lineArray && _lineArray.count > 0) {
        cell.imageView.allLines = _lineArray;
    }
    cell.delegate = self;
    cell.imageDoodleDidEnd = ^(UIImage * _Nonnull image) {
        [weakself.delegate imageDoodleViewController:weakself imageDoodleDidEnd:@[image] forIndex:indexPath.row];
    };
    
    cell.image = self.dataSource[indexPath.row];
    
    //如果有记录的图片信息，进行对应操作--缩放，位移，旋转
    [self moveImageWithImageInformationDictionary:self.imageInfoDictionary andCell:cell];
    
    return cell;
}

- (PEPImageDoodleCollectionViewCell *)getCunrrentCollectionViewCell {
    NSInteger index = (NSInteger)round(self.collectionView.contentOffset.x / self.flowLayout.itemSize.width);
    PEPImageDoodleCollectionViewCell *cell = (PEPImageDoodleCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];

    return cell;
}



// MARK: - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:true];
    
}

// MARK: - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    //获取当前cell的indexPath
    NSInteger row = scrollView.contentOffset.x/[UIScreen mainScreen].bounds.size.width;
    _pageIndex = [NSIndexPath indexPathForRow:row inSection:0];
}


// MARK: - UI

- (void)initSubviews {
    self.view.backgroundColor = UIColor.clearColor;
    UIEdgeInsets safeAreaInsets = [self safeAreaInsets];
    CGFloat toolBarHeight = 49;

    UICollectionViewFlowLayout *flowLayout = [UICollectionViewFlowLayout.alloc init];
    flowLayout.minimumLineSpacing = 0;
    flowLayout.itemSize =UIScreen.mainScreen.bounds.size.height<UIScreen.mainScreen.bounds.size.width?CGSizeMake(UIScreen.mainScreen.bounds.size.width, UIScreen.mainScreen.bounds.size.height):CGSizeMake(UIScreen.mainScreen.bounds.size.height, UIScreen.mainScreen.bounds.size.width);
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    UICollectionView *collectionView = [UICollectionView.alloc initWithFrame:CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, UIScreen.mainScreen.bounds.size.height) collectionViewLayout:flowLayout];
    collectionView.showsHorizontalScrollIndicator = false;
    collectionView.showsVerticalScrollIndicator = false;
    collectionView.dataSource = self;
    collectionView.delegate = self;
    collectionView.pagingEnabled = true;
    [collectionView registerClass:PEPImageDoodleCollectionViewCell.class forCellWithReuseIdentifier:NSStringFromClass(PEPImageDoodleCollectionViewCell.class)];

    
    UIView *toolBarContainerView = [UIView.alloc init];
    toolBarContainerView.backgroundColor = UIColor.blackColor;
    toolBarContainerView.userInteractionEnabled = YES;
    UIView *toolBarStackView = [self makeToolBarStackView];
    
    
    [self.view addSubview:collectionView];
    [self.view addSubview:toolBarContainerView];
    [toolBarContainerView addSubview:toolBarStackView];
    
    
    collectionView.translatesAutoresizingMaskIntoConstraints = false;
    [[collectionView.leadingAnchor constraintEqualToAnchor:collectionView.superview.leadingAnchor] setActive:true];
    [[collectionView.trailingAnchor constraintEqualToAnchor:collectionView.superview.trailingAnchor] setActive:true];
    [[collectionView.topAnchor constraintEqualToAnchor:collectionView.superview.topAnchor] setActive:true];
    [[collectionView.bottomAnchor constraintEqualToAnchor:collectionView.superview.bottomAnchor] setActive:true];

    toolBarContainerView.translatesAutoresizingMaskIntoConstraints = false;
    [[toolBarContainerView.topAnchor constraintEqualToAnchor:toolBarContainerView.superview.topAnchor] setActive:true];
    [[toolBarContainerView.trailingAnchor constraintEqualToAnchor:toolBarContainerView.superview.trailingAnchor] setActive:true];
    [[toolBarContainerView.bottomAnchor constraintEqualToAnchor:toolBarContainerView.superview.bottomAnchor] setActive:true];
    [[toolBarContainerView.widthAnchor constraintEqualToConstant:(toolBarHeight+safeAreaInsets.bottom)] setActive:true];
    
//    toolBarStackView.translatesAutoresizingMaskIntoConstraints = false;
//    [[toolBarStackView.leadingAnchor constraintEqualToAnchor:toolBarStackView.superview.leadingAnchor] setActive:true];
//    [[toolBarStackView.trailingAnchor constraintEqualToAnchor:toolBarStackView.superview.trailingAnchor] setActive:true];
//    [[toolBarStackView.topAnchor constraintEqualToAnchor:toolBarStackView.superview.topAnchor constant:20] setActive:true];
//    [[toolBarStackView.widthAnchor constraintEqualToConstant:toolBarHeight] setActive:true];
    
    self.collectionView = collectionView;
    self.flowLayout = flowLayout;
//    self.toolBarStackView = toolBarStackView;
    
}


- (UIView *)makeToolBarStackView {
//    UIStackView *stackView = [UIStackView.alloc init];
//    stackView.axis = UILayoutConstraintAxisVertical;
//    stackView.spacing = 10;
//    stackView.distribution = UIStackViewDistributionFill;
//    stackView.alignment = UIStackViewAlignmentFill;
//    stackView.tintColor = UIColor.whiteColor;
    UIView * backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 40, UIScreen.mainScreen.bounds.size.height)];
    backView.backgroundColor= UIColor.blackColor;
    backView.userInteractionEnabled = YES;
    
    UIButton *closeButton = [self standardButtonWithTitle:nil image:[UIImage imageNamed:@"pb_toolbar_close" inBundle:PEPImageDoodleAssetsBundle() compatibleWithTraitCollection:nil] action:@selector(toolBarItemAction:)];
    closeButton.frame = CGRectMake(10, 20, 40, 40);
    UIButton *brushButton = [self standardButtonWithTitle:nil image:[UIImage imageNamed:@"pb_toolbar_brush" inBundle:PEPImageDoodleAssetsBundle() compatibleWithTraitCollection:nil] action:@selector(toolBarItemAction:)];
    brushButton.frame = CGRectMake(10,10+40+20, 40, 40);
//    UIButton *eraserButton = [self standardButtonWithTitle:nil image:[UIImage imageNamed:@"pb_toolbar_eraser" inBundle:PEPImageDoodleAssetsBundle() compatibleWithTraitCollection:nil] action:@selector(toolBarItemAction:)];
    UIButton *clearButton = [self standardButtonWithTitle:nil image:[UIImage imageNamed:@"pb_toolbar_clear" inBundle:PEPImageDoodleAssetsBundle() compatibleWithTraitCollection:nil] action:@selector(toolBarItemAction:)];
    clearButton.frame = CGRectMake(10, 20+(40+10)*2, 40, 40);
//    UIButton *addButton = [self standardButtonWithTitle:nil image:[UIImage imageNamed:@"pb_toolbar_add" inBundle:PEPImageDoodleAssetsBundle() compatibleWithTraitCollection:nil] action:@selector(toolBarItemAction:)];
    UIButton *enlargeButton = [self standardButtonWithTitle:nil image:[UIImage imageNamed:@"pb_toolbar_enlarge" inBundle:PEPImageDoodleAssetsBundle() compatibleWithTraitCollection:nil] action:@selector(toolBarItemAction:)];
    enlargeButton.frame = CGRectMake(10,20+(40+10)*3, 40, 40);
    UIButton *lessenButton = [self standardButtonWithTitle:nil image:[UIImage imageNamed:@"pb_toolbar_lessen" inBundle:PEPImageDoodleAssetsBundle() compatibleWithTraitCollection:nil] action:@selector(toolBarItemAction:)];
    lessenButton.frame = CGRectMake(10,20+(40+10)*4, 40, 40);
    UIButton *rotateButton = [self standardButtonWithTitle:nil image:[UIImage imageNamed:@"pb_toolbar_rotation" inBundle:PEPImageDoodleAssetsBundle() compatibleWithTraitCollection:nil] action:@selector(toolBarItemAction:)];
    rotateButton.frame = CGRectMake(10,20+(40+10)*5, 40, 40);
    
    closeButton.tag = PEPImageDoodleToolBarItemTypeClose;
    brushButton.tag = PEPImageDoodleToolBarItemTypeBrush;
//    eraserButton.tag = PEPImageDoodleToolBarItemTypeEraser;
    clearButton.tag = PEPImageDoodleToolBarItemTypeClear;
//    addButton.tag = PEPImageDoodleToolBarItemTypeAdd;
    enlargeButton.tag = PEPImageDoodleToolBarItemTypeEnlarge;
    lessenButton.tag = PEPImageDoodleToolBarItemTypeLessen;
    rotateButton.tag = PEPImageDoodleToolBarItemTypeRotate;
    
    [backView addSubview:closeButton];
    [backView addSubview:brushButton];
//    [stackView addArrangedSubview:eraserButton];
    [backView addSubview:clearButton];
//    [stackView addArrangedSubview:addButton];
    [backView addSubview:enlargeButton];
    [backView addSubview:lessenButton];
    [backView addSubview:rotateButton];
    
//    self.toolBarAddImageButtonItem = addButton;
    return backView;
}


- (void)showAlertForClearAllDoodleWithCancelBlock:(void(^)(void))cancelBlock confrimBlcok:(void(^)(void))confrimBlock {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:PEPImageDoodleLocalizedString(@"tips") message:PEPImageDoodleLocalizedString(@"all_clear_tips_message") preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:PEPImageDoodleLocalizedString(@"cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        if (cancelBlock) {
            cancelBlock();
        }
    }];
    
    UIAlertAction *clearAction = [UIAlertAction actionWithTitle:PEPImageDoodleLocalizedString(@"all_clear") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        if (confrimBlock) {
            confrimBlock();
        }
    }];
    
    [alert addAction:cancel];
    [alert addAction:clearAction];
    
    [self presentViewController:alert animated:true completion:nil];
}

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *confrimAction = [UIAlertAction actionWithTitle:PEPImageDoodleLocalizedString(@"ok") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    [alert addAction:confrimAction];
    
    [self presentViewController:alert animated:true completion:nil];
}


- (UIButton *)standardButtonWithTitle:(NSString *)title image:(UIImage *)image action:(SEL)sel {
    UIButton *button = [[UIButton alloc]  init];
    [button setTitle:title forState:UIControlStateNormal];
    [button setImage:image forState:UIControlStateNormal];
    [button addTarget:self action:sel forControlEvents:UIControlEventTouchUpInside];
    button.titleLabel.font = [UIFont systemFontOfSize:18];
    
    return button;
}

- (UIEdgeInsets)safeAreaInsets {
    if (@available(iOS 11.0, *)) {
        return UIApplication.sharedApplication.keyWindow.safeAreaInsets;
    } else {
        return UIEdgeInsetsZero;
    }
}

//- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
//    if([[UIDevice currentDevice].model containsString:@"iPad"]) {
//        return UIInterfaceOrientationLandscapeRight;
//    }else{
//        return UIInterfaceOrientationPortrait;
//    }
//}

//- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
//
//    if([[UIDevice currentDevice].model containsString:@"iPad"]) {
//        return UIInterfaceOrientationMaskLandscape;
//    }else{
//        return UIInterfaceOrientationMaskPortrait;
//    }
//}
//MARK: 屏幕方向
- (BOOL)shouldAutorotate
{
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationLandscapeRight;
}

// MARK: - ModalPresentationStyle

- (UIModalPresentationStyle)modalPresentationStyle {
    return UIModalPresentationFullScreen;
}

@end
