//
//  TJLBottomEditView.m
//  PhotoManagement
//
//  Created by Oma-002 on 17/1/18.
//  Copyright © 2017年 com.oma.matec. All rights reserved.
//

#import "TJLBottomEditView.h"
#import "UIColor+Hex.h"

#define WIDTH [[UIScreen mainScreen] bounds].size.width
#define HEIGHT [[UIScreen mainScreen] bounds].size.height

@interface TJLBottomEditView ()

@property (strong, nonatomic) UIView *lineView;

@property (strong, nonatomic) UILabel *editLabel;

@property (strong, nonatomic) UILabel *previewLabel;


@end

@implementation TJLBottomEditView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.lineView];
        [self addSubview:self.chooseButton];
        [self addSubview:self.cancelButton];
    }
    return self;
}

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 0.5)];
        _lineView.backgroundColor = [UIColor hexString:@"bfbfbf"];
    }
    return _lineView;
}

- (UIButton *)chooseButton {
    if (!_chooseButton) {
        _chooseButton = [[UIButton alloc] initWithFrame:CGRectMake(WIDTH - 105, (CGRectGetHeight(self.frame)-30)/2, 95, 30)];
        [_chooseButton setBackgroundColor:[UIColor hexString:@"09bb07"]];
        _chooseButton.layer.masksToBounds = YES;
        _chooseButton.layer.cornerRadius = 5;
        [_chooseButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _chooseButton.titleLabel.font = [UIFont systemFontOfSize:15];
        [_chooseButton setTitle:@"确认" forState:UIControlStateNormal];
    }
    return _chooseButton;
}
- (UIButton *)cancelButton {
    if (!_cancelButton) {
        _cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(20, (CGRectGetHeight(self.frame)-30)/2, 95, 30)];
        [_cancelButton setBackgroundColor:[UIColor lightGrayColor]];
        _cancelButton.layer.masksToBounds = YES;
        _cancelButton.layer.cornerRadius = 5;
        [_cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _cancelButton.titleLabel.font = [UIFont systemFontOfSize:15];
        [_cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    }
    return _cancelButton;
}
- (void)setButtonTitleColorNormal:(NSInteger)count {
    if (count == 0) {
        [self.chooseButton setTitleColor:[UIColor hexString:@"b4e2b9"] forState:UIControlStateNormal];
    }else{
        [self.chooseButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
}



@end
