//
//  HDSLiveAnnouncementView.m
//  CCLiveCloud
//
//  Created by richard lee on 1/29/23.
//  Copyright © 2023 MacBook Pro. All rights reserved.
//

#import "HDSLiveAnnouncementView.h"
#import "UIColor+RCColor.h"
#import <Masonry/Masonry.h>

@interface HDSLiveAnnouncementView ()

@property (nonatomic, strong) UIImageView *BGIMGView;

@property (nonatomic, strong) UIImageView *iconIMGView;

@property (nonatomic, strong) UILabel *mainTitle;

@property (nonatomic, strong) UIButton *closeBtn;

@property (nonatomic, strong) UILabel *contentLabel;

@property (nonatomic, strong) UIButton *mButton;

@property (nonatomic, copy)   buttonTap callBack;

@end

@implementation HDSLiveAnnouncementView

- (instancetype)initWithFrame:(CGRect)frame closure:(nonnull buttonTap)closure {
    if (self = [super initWithFrame:frame]) {
        if (closure) {
            _callBack = closure;
        }
        [self configureUI];
        [self configureCostriaint];
    }
    return self;
}

- (void)setHistoryAnnouncementString:(NSString *)historyAnnouncementString {
    _historyAnnouncementString = historyAnnouncementString;
    _contentLabel.text = _historyAnnouncementString;
}

// MARK: - Custom UI
- (void)configureUI {
    
    _BGIMGView = [[UIImageView alloc]init];
    _BGIMGView.image = [UIImage imageNamed:@"公告新背景"];
    [self addSubview:_BGIMGView];
    
    _iconIMGView = [[UIImageView alloc]init];
    _iconIMGView.image = [UIImage imageNamed:@"公告"];
    _iconIMGView.contentMode = UIViewContentModeCenter;
    [self addSubview:_iconIMGView];
    
    _mainTitle = [[UILabel alloc]init];
    _mainTitle.textColor = [UIColor colorWithHexString:@"#FF842F" alpha:1];
    _mainTitle.text = @"公告";
    _mainTitle.font = [UIFont systemFontOfSize:15];
    [self addSubview:_mainTitle];
    
    _closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_closeBtn setImage:[UIImage imageNamed:@"公告关闭"] forState:UIControlStateNormal];
    [_closeBtn setImage:[UIImage imageNamed:@"公告关闭"] forState:UIControlStateHighlighted];
    [self addSubview:_closeBtn];
    [_closeBtn addTarget:self action:@selector(closeBtnTap:) forControlEvents:UIControlEventTouchUpInside];
    
    _contentLabel = [[UILabel alloc]init];
    _contentLabel.textColor = [UIColor colorWithHexString:@"#000000" alpha:0.8];
    _contentLabel.font = [UIFont systemFontOfSize:14];
    _contentLabel.numberOfLines = 2;
    [self addSubview:_contentLabel];
    
    _mButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self addSubview:_mButton];
    [_mButton addTarget:self action:@selector(mButtonTap:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)configureCostriaint {
    
    __weak typeof(self) weakSelf = self;
    [_BGIMGView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(weakSelf);
        make.bottom.mas_equalTo(weakSelf).offset(-5);
    }];
    [_BGIMGView layoutIfNeeded];
    _BGIMGView.layer.masksToBounds = NO;
    _BGIMGView.layer.shadowOffset = CGSizeMake(5, 5);
    _BGIMGView.layer.shadowColor = [UIColor colorWithHexString:@"#000000" alpha:0.08].CGColor;
    _BGIMGView.layer.shadowOpacity = 0.3f;
    _BGIMGView.layer.shadowRadius = 2.0f;
    
    [_iconIMGView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf).offset(8);
        make.left.mas_equalTo(weakSelf).offset(15);
        make.width.mas_equalTo(19);
        make.height.mas_equalTo(19);
    }];
    
    [_mainTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(weakSelf.iconIMGView.mas_centerY);
        make.left.mas_equalTo(weakSelf.iconIMGView.mas_right).offset(4);
    }];
    
    [_closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.mas_equalTo(weakSelf);
        make.width.height.mas_equalTo(34);
    }];
    
    [_contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.iconIMGView.mas_bottom).offset(8);
        make.left.mas_equalTo(weakSelf).offset(15);
        make.bottom.mas_lessThanOrEqualTo(weakSelf).offset(-15);
        make.right.mas_equalTo(weakSelf).offset(-15);
    }];
    
    [_mButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.mas_equalTo(weakSelf);
        make.right.mas_equalTo(weakSelf).offset(-35);
    }];
}

- (void)closeBtnTap:(UIButton *)sender {
    if (_callBack) {
        _callBack(0);
    }
}

- (void)mButtonTap:(UIButton *)sender {
    if (_callBack) {
        _callBack(1);
    }
}

@end
