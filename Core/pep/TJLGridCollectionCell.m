//
//  TJLGridCollectionCell.m
//  PhotoManagement
//
//  Created by Oma-002 on 17/1/13.
//  Copyright © 2017年 com.oma.matec. All rights reserved.
//

#import "TJLGridCollectionCell.h"


@interface TJLGridCollectionCell ()

@property (assign, nonatomic) BOOL imageSelected;

@end

@implementation TJLGridCollectionCell

+ (UINib *)cellNib {
    return [UINib nibWithNibName:[self cellIdentifier] bundle:nil];
}

+ (NSString *)cellIdentifier {
    return NSStringFromClass([self class]);
}

- (void)initSubViews{
    self.gridImageView = [[UIImageView alloc] initWithFrame:self.contentView.frame];
    self.gridImageView.image = [UIImage imageNamed:@"blank" inBundle:[NSBundle.alloc initWithPath:[NSBundle.mainBundle pathForResource:@"PEPImageDoodleBoard" ofType:@"bundle"]] compatibleWithTraitCollection:nil];
    [self.contentView addSubview:self.gridImageView];
    
    self.checkView  = [[UIView alloc] initWithFrame:CGRectMake(self.contentView.frame.size.width/2, 0, self.contentView.frame.size.width/2, self.contentView.frame.size.width/2)];
    [self.contentView addSubview:self.checkView];
    
    self.checkImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.contentView.frame.size.width/4, 0, self.contentView.frame.size.width/4, self.contentView.frame.size.width/4)];
    self.checkImageView.image = [UIImage imageNamed:@"grey" inBundle:[NSBundle.alloc initWithPath:[NSBundle.mainBundle pathForResource:@"PEPImageDoodleBoard" ofType:@"bundle"]] compatibleWithTraitCollection:nil];
    [self.checkView addSubview:self.checkImageView];
    
    [self.gridImageView setUserInteractionEnabled:YES];
    [self.checkView setUserInteractionEnabled:YES];
    
    UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selected:)];
    [self.gridImageView addGestureRecognizer:tap1];
    
    UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(checkSelected:)];
    [self.checkView addGestureRecognizer:tap2];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
}

- (void)selected:(UITapGestureRecognizer *)tap {
    if ([self.delegate respondsToSelector:@selector(didPreviewAssetsViewCell:)]) {
        [self.delegate didPreviewAssetsViewCell:self];
    }
}

- (void)checkSelected:(UITapGestureRecognizer *)tap {
    if (self.imageSelected) {
        self.imageSelected = NO;
        self.checkImageView.image = [UIImage imageNamed:@"grey" inBundle:[NSBundle.alloc initWithPath:[NSBundle.mainBundle pathForResource:@"PEPImageDoodleBoard" ofType:@"bundle"]] compatibleWithTraitCollection:nil];
        
        if ([self.delegate respondsToSelector:@selector(didDeselectItemAssetsViewCell:)]) {
            [self.delegate didDeselectItemAssetsViewCell:self];
        }
        
    } else {
        self.imageSelected = YES;
        self.checkImageView.image = [UIImage imageNamed:@"green" inBundle:[NSBundle.alloc initWithPath:[NSBundle.mainBundle pathForResource:@"PEPImageDoodleBoard" ofType:@"bundle"]] compatibleWithTraitCollection:nil];
        
        self.checkImageView.transform = CGAffineTransformMakeScale(0.6, 0.6);
        [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.3 initialSpringVelocity:5 options:UIViewAnimationOptionCurveLinear animations:^{
            self.checkImageView.transform = CGAffineTransformIdentity;
        } completion:nil];
        
        if ([self.delegate respondsToSelector:@selector(didSelectItemAssetsViewCell:)]) {
            [self.delegate didSelectItemAssetsViewCell:self];
        }
    
    }
}

- (void)reduceCheckImage {
    self.imageSelected = NO;
    
    self.checkImageView.image = [UIImage imageNamed:@"grey" inBundle:[NSBundle.alloc initWithPath:[NSBundle.mainBundle pathForResource:@"PEPImageDoodleBoard" ofType:@"bundle"]] compatibleWithTraitCollection:nil];
    
    if ([self.delegate respondsToSelector:@selector(didDeselectItemAssetsViewCell:)]) {
        [self.delegate didDeselectItemAssetsViewCell:self];
    }
}

@end
