//
//  HDSPlayerErrorModeView.m
//  CCLiveCloud
//
//  Created by Richard Lee on 8/11/21.
//  Copyright © 2021 MacBook Pro. All rights reserved.
//

#import "HDSPlayerErrorModeView.h"
#import "Reachability.h"
#import "UIColor+RCColor.h"
#import "Masonry.h"
#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

#define PLAY_ERROR @"视频加载失败请稍后重试"
#define AUDIO_ERROR @"音频加载失败请稍后重试"
#define PLAY_RETRY @"正在尝试连接,请稍后..."
#define NETWORK_ERROR @"当前网络已断开,请检查网络"
#define BTN_TITLE @"刷新"

@interface HDSPlayerErrorModeView ()

/// 提示语
@property (nonatomic, strong) UILabel               *tipLabel;
/// 刷新按钮
@property (nonatomic, strong) UIButton              *refreshBtn;
/// 父视图宽度
@property (nonatomic, assign) CGFloat               width;
/// 提示语
@property (nonatomic, copy) NSString                *tipText;


@end

@implementation HDSPlayerErrorModeView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithHexString:@"#000000" alpha:0.8f];
        [self customUI];
    }
    return self;
}

- (void)customUI {
    
    _tipText = PLAY_ERROR;

    BOOL small = self.frame.size.width < kScreenWidth ? YES : NO;
    _tipLabel = [[UILabel alloc]init];
    _tipLabel.text = _tipText;
    _tipLabel.textColor = [UIColor whiteColor];
    _tipLabel.textAlignment = NSTextAlignmentCenter;
    _tipLabel.font = [UIFont systemFontOfSize:small == YES ? 11.f : 14.f];
    _tipLabel.numberOfLines = 0;
    [self addSubview:_tipLabel];
    
    /// 设置约束
    [_tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self).offset(10.f);
        make.right.mas_equalTo(self).offset(-10.f);
        make.centerY.mas_equalTo(self).offset(-10.f);
    }];
    
    _refreshBtn = [[UIButton alloc]init];
    [_refreshBtn setTitle:BTN_TITLE forState:UIControlStateNormal];
    [_refreshBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _refreshBtn.layer.borderColor = [UIColor whiteColor].CGColor;
    _refreshBtn.titleLabel.font = [UIFont systemFontOfSize:small == YES ? 12.f : 15.f];
    _refreshBtn.layer.cornerRadius = small == YES ? 7.5f : 15.f;
    _refreshBtn.layer.masksToBounds = YES;
    _refreshBtn.layer.borderWidth = .5f;
    _refreshBtn.tag = 1000;
    [_refreshBtn addTarget:self action:@selector(refreshBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_refreshBtn];

    [_refreshBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self);
        make.top.mas_equalTo(_tipLabel.mas_bottom).offset(small == YES ? 5.f : 10.f);
        make.width.mas_equalTo(small == YES ? 40.f : 80.f);
        make.height.mas_equalTo(small == YES ? 15.f : 30.f);
    }];
    
}

// MARK: - API
/// 是否是音频
/// @param isAudio 是否是音频
- (void)setIsAudio:(BOOL)isAudio {
    _isAudio = isAudio;
    _tipText = _isAudio == YES ? AUDIO_ERROR : PLAY_ERROR;
}

/// 更新布局
/// @param frame 布局
- (void)updateFrame:(CGRect)frame {
    
    BOOL small = frame.size.width < kScreenWidth ? YES : NO;
    self.frame = frame;
    /// 更新约束
    [_tipLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self).offset(10.f);
        make.right.mas_equalTo(self).offset(-10.f);
        make.centerY.mas_equalTo(self).offset(-10.f);
    }];
    
    [_refreshBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self);
        make.top.mas_equalTo(_tipLabel.mas_bottom).offset(small == YES ? 5.f : 10.f);
        make.width.mas_equalTo(small == YES ? 40.f : 80.f);
        make.height.mas_equalTo(small == YES ? 15.f : 30.f);
    }];

    /// 更新显示
    _tipLabel.font = [UIFont systemFontOfSize:small == YES ? 11.f : 14.f];
    _refreshBtn.titleLabel.font = [UIFont systemFontOfSize:small == YES ? 12.f : 15.f];
    _refreshBtn.layer.cornerRadius = small == YES ? 7.5f : 15.f;
    _refreshBtn.layer.masksToBounds = YES;
    
}

/// 重制
- (void)reset {
    _tipLabel.text = _tipText;
    _refreshBtn.hidden = NO;
}

// MARK: - Custom Method
/// 刷新按钮点击事件
/// @param sender sender
- (void)refreshBtnClick:(UIButton *)sender {
    /// 判断是否有网络
    
    if (![self isExistenceNetwork]) {
        _tipLabel.text = NETWORK_ERROR;
        return;
    }
    _tipLabel.text = PLAY_RETRY;
    _refreshBtn.hidden = YES;
    if (self.btnActionClosure) {
        self.btnActionClosure();
    }
}

/// 是否有网络
/// @return  是否有网络
- (BOOL)isExistenceNetwork {
    BOOL isExistenceNetwork = YES;
    Reachability *reach = [Reachability reachabilityForInternetConnection];
    switch ([reach currentReachabilityStatus]) {
        case NotReachable:{
            isExistenceNetwork = NO;
            break;
        }
        case ReachableViaWiFi:{
            isExistenceNetwork = YES;
            break;
        }
        case ReachableViaWWAN:{
            isExistenceNetwork = YES;
            break;
        }
    }
    return isExistenceNetwork;
}

@end
