//
//  NewLotteryWinnersCell.m
//  CCLiveCloud
//
//  Created by Apple on 2020/11/13.
//  Copyright © 2020 MacBook Pro. All rights reserved.
//

#import "NewLotteryWinnersCell.h"
#import "NewLotteryWinnersCellModel.h"
#import "UIImageView+Extension.h"
#import "UIColor+RCColor.h"
#import "UIView+Extension.h"
#import <Masonry/Masonry.h>

@interface NewLotteryWinnersCell ()

/** 头像 */
@property (nonatomic, strong) UIImageView *imageView;
/** 昵称 */
@property (nonatomic, strong) UILabel     *name;

@end

@implementation NewLotteryWinnersCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI
{
    [self addSubview:self.imageView];
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self).offset(10);
        make.centerX.mas_equalTo(self);
        make.width.height.mas_equalTo(self.width * 3 / 5);
    }];

    [self addSubview:self.name];
    [self.name mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self).offset(5);
        make.bottom.mas_equalTo(self).offset(-10);
        make.right.mas_equalTo(self).offset(-5);
    }];
    
    [self layoutIfNeeded];
    self.imageView.layer.cornerRadius = self.imageView.width / 2;
    self.imageView.layer.masksToBounds = YES;
}

- (void)setModel:(NewLotteryWinnersCellModel *)model
{
    _model = model;
    [self.imageView setHeader:model.userAvatar];;
    self.name.text = model.userName;
}

#pragma mark - 懒加载
- (UIImageView *)imageView
{
    if (!_imageView) {
        _imageView = [[UIImageView alloc]init];
    }
    return _imageView;
}

- (UILabel *)name
{
    if (!_name) {
        _name = [[UILabel alloc]init];
        _name.font = [UIFont systemFontOfSize:12];
        _name.textColor = [UIColor colorWithHexString:@"#333333" alpha:1];
        _name.textAlignment = NSTextAlignmentCenter;
    }
    return _name;
}

@end
