//
//  TJLGridCollectionCell.h
//  PhotoManagement
//
//  Created by Oma-002 on 17/1/13.
//  Copyright © 2017年 com.oma.matec. All rights reserved.
//

#import <UIKit/UIKit.h>


@class TJLGridCollectionCell;

@protocol TJLGridCollectionCellDelegate <NSObject>

- (void)didPreviewAssetsViewCell:(TJLGridCollectionCell *)assetsCell;

- (void)didSelectItemAssetsViewCell:(TJLGridCollectionCell *)assetsCell;

- (void)didDeselectItemAssetsViewCell:(TJLGridCollectionCell *)assetsCell;

@end

@interface TJLGridCollectionCell : UICollectionViewCell



@property (strong, nonatomic)  UIImageView *gridImageView;

@property (strong, nonatomic)  UIView *checkView;

@property (strong, nonatomic)  UIImageView *checkImageView;


@property (assign, nonatomic) id<TJLGridCollectionCellDelegate> delegate;

+ (UINib *)cellNib;

+ (NSString *)cellIdentifier;

- (void)reduceCheckImage;

- (void)initSubViews;

@end
