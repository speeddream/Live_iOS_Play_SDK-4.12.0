//
//  HDPlayerBaseInfoView.m
//  CCLiveCloud
//
//  Created by Apple on 2020/11/27.
//  Copyright © 2020 MacBook Pro. All rights reserved.
//

#import "HDPlayerBaseInfoView.h"
#import "Reachability.h"
#import "UIColor+RCColor.h"
#import "CCcommonDefine.h"
#import <Masonry/Masonry.h>

@interface HDPlayerBaseInfoView ()
/** 提示语label */
@property (nonatomic, strong) UILabel               *tipLabel;
/** 功能按钮 */
@property (nonatomic, strong) UIButton              *actionBtn;
/** 按钮文字 */
@property (nonatomic, copy)   NSString              *btnStr;
/** 是否展示按钮 */
@property (nonatomic, assign) BOOL                  showButton;

@property (nonatomic, assign) BOOL                  isNeedUpdata;

@property (nonatomic, assign) BOOL                  isNeedUpdataSmall;

@property (strong, nonatomic) NSTimer               *timeOutTimer;
@end

@implementation HDPlayerBaseInfoView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.showButton = NO;
        self.isNeedUpdata = YES;
        self.isNeedUpdataSmall = YES;
        self.btnStr = REFRESH_BTN;
        self.backgroundColor = [UIColor colorWithHexString:@"#000000" alpha:0.8f];
        [self setupUI];
    }
    return self;
}

- (void)setupUI
{
    /** 小窗 */
    BOOL small = self.frame.size.width < SCREEN_WIDTH ? YES : NO;
    _tipLabel = [[UILabel alloc]init];
    _tipLabel.text = @"";
    _tipLabel.textColor = [UIColor whiteColor];
    _tipLabel.textAlignment = NSTextAlignmentCenter;
    _tipLabel.font = [UIFont systemFontOfSize:small == YES ? 11.f : 14.f];
    _tipLabel.numberOfLines = 0;
    [self addSubview:_tipLabel];
    [_tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self).offset(10.f);
        make.right.mas_equalTo(self).offset(-10.f);
        make.centerY.mas_equalTo(self).offset(-10.f);
    }];
    
    _actionBtn = [[UIButton alloc]init];
    [_actionBtn setTitle:_btnStr forState:UIControlStateNormal];
    [_actionBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _actionBtn.titleLabel.font = [UIFont systemFontOfSize:small == YES ? 12.f : 15.f];
    _actionBtn.layer.cornerRadius = small == YES ? 7.5f : 15.f;
    _actionBtn.layer.masksToBounds = YES;
    _actionBtn.layer.borderColor = [UIColor whiteColor].CGColor;
    _actionBtn.layer.borderWidth = .5f;
    _actionBtn.hidden = _showButton == YES ? NO : YES;
    [_actionBtn addTarget:self action:@selector(actionBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_actionBtn];
    [_actionBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self);
        make.top.mas_equalTo(_tipLabel.mas_bottom).offset(small == YES ? 5.f : 10.f);
        make.width.mas_equalTo(small == YES ? 40.f : 80.f);
        make.height.mas_equalTo(small == YES ? 15.f : 30.f);
    }];
}

- (void)updatePlayerBaseInfoViewWithFrame:(CGRect)frame
{
    if (self.frame.size.width == frame.size.width) return;
    self.frame = frame;
    [self layoutIfNeeded];
    if (frame.size.width < SCREEN_WIDTH) {
        [self showSmallWindowView];
    }else {
        [self showMainWindowView];
    }
}

- (void)showMainWindowView
{
    _tipLabel.font = [UIFont systemFontOfSize:14.f];
    _actionBtn.titleLabel.font = [UIFont systemFontOfSize:14.f];
    _actionBtn.layer.cornerRadius = 15.f;
    _actionBtn.layer.masksToBounds = YES;
    WS(ws)
    [_actionBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(ws);
        make.top.mas_equalTo(ws.tipLabel.mas_bottom).offset(10.f);
        make.width.mas_equalTo(80.f);
        make.height.mas_equalTo(30.f);
    }];
}

- (void)showSmallWindowView
{
    _tipLabel.font = [UIFont systemFontOfSize:11.f];
    _actionBtn.titleLabel.font = [UIFont systemFontOfSize:12.f];
    _actionBtn.layer.cornerRadius = 7.5f;
    _actionBtn.layer.masksToBounds = YES;
    WS(ws)
    [_actionBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(ws);
        make.top.mas_equalTo(ws.tipLabel.mas_bottom).offset(5.f);
        make.width.mas_equalTo(40.f);
        make.height.mas_equalTo(15.f);
    }];
}

- (void)showTipStrWithType:(HDPlayerBaseInfoViewType)type withTipStr:(NSString *)tipStr
{
    [self updatePlayerBaseInfoViewWithFrame:self.frame];
    if (type == HDPlayerBaseInfoViewTypeWithError) {
        self.tipLabel.text = tipStr;
        self.actionBtn.hidden = NO;
    }else if (type == HDPlayerBaseInfoViewTypeWithhRetry) {
        self.tipLabel.text = tipStr;
        self.actionBtn.hidden = YES;
    }else if (type == HDPlayerBaseInfoViewTypeWithOther) {
        self.tipLabel.text = tipStr;
        self.actionBtn.hidden = YES;
    }
}

- (void)actionBtnClick:(UIButton *)sender
{
    /** 判断是否有网络 */
    if (![self isExistenceNetwork]) {
        self.tipLabel.text = NETWORK_ERROR;
        return;
    }
    _actionBtn.enabled = NO;
    [_actionBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    if (self.actionBtnClickBlock) {
        self.actionBtnClickBlock(@"");
    }
    [self startTimer];
}

- (void)startTimer {
    [self endTimer];
    _timeOutTimer = [NSTimer scheduledTimerWithTimeInterval:10.0f target:self selector:@selector(timeOut) userInfo:nil repeats:YES];
}

- (void)timeOut {
    [self endTimer];
    if (self.actionBtn.hidden != NO) {
        [self showTipStrWithType:HDPlayerBaseInfoViewTypeWithError withTipStr:AUTO_PLAY_ERROR];
        self.actionBtn.enabled = YES;
    }
}

- (void)endTimer {
    if([self.timeOutTimer isValid]) {
        [self.timeOutTimer invalidate];
        self.timeOutTimer = nil;
    }
}

#pragma mark - 判断是否有网络
/**
 *    @brief    判断当前是否有网络
 *    @return   是否有网
 */
- (BOOL)isExistenceNetwork
{
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

- (void)dealloc {
    [self endTimer];
}

@end
