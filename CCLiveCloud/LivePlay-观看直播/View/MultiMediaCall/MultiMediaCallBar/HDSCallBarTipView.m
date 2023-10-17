//
//  HDSCallBarTipView.m
//  CCLiveCloud
//
//  Created by Richard Lee on 2021/8/29.
//  Copyright © 2021 MacBook Pro. All rights reserved.
//

#import "HDSCallBarTipView.h"
#import "UIView+Extension.h"

@interface HDSCallBarTipView ()

@property (nonatomic, copy) tipViewHangupBtnClosure hangupClosure;

@property (nonatomic, assign) HDSMultiMediaCallBarType  callType;

@property (nonatomic, strong) UILabel                   *tipLabel;

@property (nonatomic, strong) UIButton                  *hangupBtn;

@property (nonatomic, assign) BOOL                      isInvitation;

@end

@implementation HDSCallBarTipView

// MARK: - API
/// 初始化
/// @param frame 布局
/// @param closure 挂断按钮回掉（邀请连麦情况下）
- (instancetype)initWithFrame:(CGRect)frame
                         type:(HDSMultiMediaCallBarType)type
                      closure:(nonnull tipViewHangupBtnClosure)closure {
    if (self = [super initWithFrame:frame]) {
        //NSLog(@"🔴⚪️🟡 %s",__func__);
        _callType = type;
        if (_callType == HDSMultiMediaCallBarTypeAudioInvitation || _callType == HDSMultiMediaCallBarTypeVideoInvitation) {
            _isInvitation = YES;
        }else {
            _isInvitation = NO;
        }
        [self customUI];
        if (closure) {
            _hangupClosure = closure;
        }
    }
    return self;
}
/// 更新视图
/// @param type 类型
- (void)updateCallBarTipViewWithType:(HDSMultiMediaCallBarType)type {
    //NSLog(@"🔴⚪️🟡 %s",__func__);
    CGFloat tipLabelW = 90;
    _isInvitation = NO;
    if (type == HDSMultiMediaCallBarTypeAudioInvitation || type == HDSMultiMediaCallBarTypeVideoInvitation) {
        _isInvitation = YES;
        tipLabelW = 73;
    }
    if (_tipLabel) {
        _tipLabel.text = [self getTipStringWithType:type];
        _tipLabel.textAlignment = _isInvitation == YES ? NSTextAlignmentCenter : NSTextAlignmentLeft;
        [_tipLabel setFrame:CGRectMake(5, 0, tipLabelW, self.height)];
    }
    if (_hangupBtn) {
        _hangupBtn.hidden = _isInvitation == YES ? NO : YES;
    }
    _callType = type;
}

// MARK: - Custom Method

- (void)customUI {
    //NSLog(@"🔴⚪️🟡 %s",__func__);
    CGFloat tipLabelX = 5;
    CGFloat tipLabelY = 0;
    CGFloat tipLabelW = _isInvitation == YES ? 73 : 90;
    _tipLabel = [[UILabel alloc]initWithFrame:CGRectMake(tipLabelX, tipLabelY, tipLabelW, self.height)];
    _tipLabel.textColor = [UIColor whiteColor];
    _tipLabel.textAlignment = _isInvitation == YES ? NSTextAlignmentCenter : NSTextAlignmentLeft;
    _tipLabel.font = [UIFont systemFontOfSize:14];
    _tipLabel.numberOfLines = 2;
    _tipLabel.text = [self getTipStringWithType:_callType];
    [self addSubview:_tipLabel];
    
    CGFloat hangupX = 83;
    _hangupBtn = [[UIButton alloc]initWithFrame:CGRectMake(hangupX, 5, 35, 35)];
    [_hangupBtn setImage:[UIImage imageNamed:@"callBar_hangup"] forState:UIControlStateNormal];
    _hangupBtn.hidden = _isInvitation == YES ? NO : YES;
    [self addSubview:_hangupBtn];
    [_hangupBtn addTarget:self action:@selector(hangupBtnClick:) forControlEvents:UIControlEventTouchUpInside];
}

- (NSString *)getTipStringWithType:(HDSMultiMediaCallBarType)type {
    NSString *tipString = @"";
    switch (type) {
        case HDSMultiMediaCallBarTypeVideoApply:
            tipString = @"申请视频连麦";
            break;
        case HDSMultiMediaCallBarTypeAudioApply:
            tipString = @"申请语音连麦";
            break;
        case HDSMultiMediaCallBarTypeVideoCalling:
            tipString = @"申请中...";
            break;
        case HDSMultiMediaCallBarTypeAudioCalling:
            tipString = @"申请中...";
            break;
        case HDSMultiMediaCallBarTypeVideoInvitation:
            tipString = @"讲师邀请你\n视频连麦";
            break;
        case HDSMultiMediaCallBarTypeAudioInvitation:
            tipString = @"讲师邀请你\n音频连麦";
            break;
        case HDSMultiMediaCallBarTypeVideoConnecting:
            tipString = @"连接中...";
            break;
        case HDSMultiMediaCallBarTypeAudioConnecting:
            tipString = @"连接中...";
            break;
        default:
            break;
    }
    //NSLog(@"🔴⚪️🟡 %s tipString:%@",__func__,tipString);
    return tipString;
}

- (void)hangupBtnClick:(UIButton *)sender {
    //NSLog(@"🔴⚪️🟡 %s ",__func__);
    if (_hangupClosure) {
        _hangupClosure();
    }
}

@end
