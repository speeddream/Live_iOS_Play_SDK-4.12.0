//
//  HDPlayerBaseBarrageView.m
//  CCLiveCloud
//
//  Created by Apple on 2021/4/6.
//  Copyright © 2021 MacBook Pro. All rights reserved.
//

#import "HDPlayerBaseBarrageView.h"
#import "HDPlayerBaseModel.h"
#import "UIColor+RCColor.h"
#import "CCcommonDefine.h"
#import <Masonry/Masonry.h>

#define kTipText @"显示区域"
#define kFullScreenImageName @"barrage_fullscreen"
#define kFullScreenSelectedImageName @"barrage_fullScreen_selected"
#define kFullScreenText @"全屏"
#define kHalfScreenImageName @"barrage_halfScreen"
#define kHalfScreenSelectedImageName @"barrage_halfScreen_selected"
#define kHalfScreenText @"半屏"
#define kDefaultColor @"#FFFFFF"
#define kSelectedColor @"#F89E0F"

@interface HDPlayerBaseBarrageView ()

@property (nonatomic, assign) HDPlayerBaseBarrageViewStyle barrageStyle;

@property (nonatomic, strong) UILabel                      *tipLabel;

@property (nonatomic, strong) UIButton                     *fullScreenBtn;

@property (nonatomic, strong) UIImageView                  *fullScreenImageView;

@property (nonatomic, strong) UILabel                      *fullScreenLabel;

@property (nonatomic, strong) UIButton                     *halfScreenBtn;

@property (nonatomic, strong) UIImageView                  *halfScreenImageView;

@property (nonatomic, strong) UILabel                      *halfScreenLabel;

@end

@implementation HDPlayerBaseBarrageView

// MARK: - API
- (instancetype)initWithFrame:(CGRect)frame barrageStyle:(HDPlayerBaseBarrageViewStyle)barrageStyle {
    self = [super initWithFrame:frame];
    if (self) {
        _barrageStyle = barrageStyle;
        [self customView];
    }
    return self;
}

- (void)setBarrageStyle:(HDPlayerBaseBarrageViewStyle)style {
    _barrageStyle = style;
    [self updateCustomView];
}

// MARK: - CustomMethod
- (void)customView {
    WS(weakSelf)
    _tipLabel = [[UILabel alloc]init];
    _tipLabel.font = [UIFont systemFontOfSize:15];
    _tipLabel.textColor = [UIColor colorWithHexString:@"#FFFFFF" alpha:1];
    _tipLabel.text = kTipText;
    [self addSubview:_tipLabel];
    [_tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf).offset(30);
        make.top.mas_equalTo(weakSelf).offset(54);
    }];
    [_tipLabel layoutIfNeeded];
    
    UIView *firstView = [[UIView alloc]init];
    [self addSubview:firstView];
    [firstView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.tipLabel.mas_bottom).offset(15);
        make.left.mas_equalTo(weakSelf).offset(20);
        make.width.mas_equalTo(50);
        make.height.mas_equalTo(80);
    }];
    [firstView layoutIfNeeded];

    _fullScreenImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:kFullScreenImageName]];
    [firstView addSubview:_fullScreenImageView];
    [_fullScreenImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(firstView).offset(10);
        make.centerX.mas_equalTo(firstView);
        make.width.height.mas_equalTo(30);
    }];
    [_fullScreenImageView layoutIfNeeded];
    
    _fullScreenLabel = [[UILabel alloc]init];
    _fullScreenLabel.font = [UIFont systemFontOfSize:13];
    _fullScreenLabel.textColor = [UIColor colorWithHexString:kDefaultColor alpha:1];
    _fullScreenLabel.text = kFullScreenText;
    [firstView addSubview:_fullScreenLabel];
    [_fullScreenLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(firstView);
        make.top.mas_equalTo(weakSelf.fullScreenImageView.mas_bottom).offset(2);
    }];
    [_fullScreenLabel layoutIfNeeded];
    
    _fullScreenBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _fullScreenBtn.tag = 1;
    [_fullScreenBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_fullScreenBtn];
    [_fullScreenBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.centerY.width.height.mas_equalTo(firstView);
    }];
    [_fullScreenBtn layoutIfNeeded];
    
    UIView *lastView = [[UIView alloc]init];
    [self addSubview:lastView];
    [lastView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(firstView.mas_right).offset(10);
        make.centerY.mas_equalTo(firstView);
        make.width.mas_equalTo(50);
        make.height.mas_equalTo(80);
    }];
    [lastView layoutIfNeeded];

    _halfScreenImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:kHalfScreenImageName]];
    [lastView addSubview:_halfScreenImageView];
    [_halfScreenImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(lastView).offset(10);
        make.centerX.mas_equalTo(lastView);
        make.width.height.mas_equalTo(30);
    }];
    [_halfScreenImageView layoutIfNeeded];
    
    _halfScreenLabel = [[UILabel alloc]init];
    _halfScreenLabel.font = [UIFont systemFontOfSize:13];
    _halfScreenLabel.textColor = [UIColor colorWithHexString:kDefaultColor alpha:1];
    _halfScreenLabel.text = kHalfScreenText;
    [lastView addSubview:_halfScreenLabel];
    [_halfScreenLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(lastView);
        make.top.mas_equalTo(weakSelf.halfScreenImageView.mas_bottom).offset(2);
    }];
    [_halfScreenLabel layoutIfNeeded];
    
    _halfScreenBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _halfScreenBtn.tag = 2;
    [_halfScreenBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_halfScreenBtn];
    [_halfScreenBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.centerY.width.height.mas_equalTo(lastView);
    }];
    [_halfScreenBtn layoutIfNeeded];
    [self updateCustomView];
}

- (void)updateCustomView {
    if (_barrageStyle == HDPlayerBaseBarrageViewStyleHalfScreen) {
        _halfScreenImageView.image = [UIImage imageNamed:kHalfScreenSelectedImageName];
        _fullScreenImageView.image = [UIImage imageNamed:kFullScreenImageName];
        _halfScreenLabel.textColor = [UIColor colorWithHexString:kSelectedColor alpha:1];
        _fullScreenLabel.textColor = [UIColor colorWithHexString:kDefaultColor alpha:1];
    }else {
        _halfScreenImageView.image = [UIImage imageNamed:kHalfScreenImageName];
        _fullScreenImageView.image = [UIImage imageNamed:kFullScreenSelectedImageName];
        _halfScreenLabel.textColor = [UIColor colorWithHexString:kDefaultColor alpha:1];
        _fullScreenLabel.textColor = [UIColor colorWithHexString:kSelectedColor alpha:1];
    }
}

- (void)btnClick:(UIButton *)sender {
    NSInteger index = 0;
    NSString  *desc = @"全屏";
    if (sender.tag == 1) {
        _barrageStyle = HDPlayerBaseBarrageViewStyleFullScreen;
    }else if (sender.tag == 2) {
        index = 2;
        desc = @"半屏";
        _barrageStyle = HDPlayerBaseBarrageViewStyleHalfScreen;
    }
    
    HDPlayerBaseModel *model = [[HDPlayerBaseModel alloc]init];
    model.func = HDPlayerBaseBarrage;
    model.index = index;
    model.desc = desc;
    model.value = desc;
    if (self.barrageViewBlock) {
        self.barrageViewBlock(model);
    }
    [self updateCustomView];
}

@end
