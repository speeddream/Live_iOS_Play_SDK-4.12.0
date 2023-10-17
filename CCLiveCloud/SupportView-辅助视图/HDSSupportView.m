//
//  HDSSupportView.m
//  CCLiveCloud
//
//  Created by Richard Lee on 8/11/21.
//  Copyright © 2021 MacBook Pro. All rights reserved.
//

#import "HDSSupportView.h"
#import "HDSAudioModeView.h"
#import "HDSSpeedModeView.h"
#import "HDSPlayerErrorModeView.h"
#import "CCcommonDefine.h"
#import "UIView+Extension.h"

@interface HDSSupportView ()

@property (nonatomic, strong) UIView                    *contentView;

@property (nonatomic, strong) UIView                    *boardView;

@property (nonatomic, strong) HDSAudioModeView          *audioView;

@property (nonatomic, strong) HDSSpeedModeView          *speedView;

@property (nonatomic, strong) HDSPlayerErrorModeView    *playErrorView;

@property (nonatomic, assign) BOOL                      isAudio;

@property (nonatomic, copy)   ActionClosure             actionClosure;

@property (nonatomic, strong) UIView                    *trialView;

@property (nonatomic, strong) UILabel                   *trialTipLabel;

@end

@implementation HDSSupportView

// MARK: - API
/// 初始化
/// @param frame 布局
/// @param actionClosure 回调
- (instancetype)initWithFrame:(CGRect)frame actionClosure:(ActionClosure)actionClosure {
    if (self = [super initWithFrame:frame]) {
        [self customUI];
        self.userInteractionEnabled = YES;
        if (actionClosure) {
            _actionClosure = actionClosure;
        }
        
    }
    return self;
}

/// 设置类型
/// @param baseType     类型
/// @param boardView    父视图
- (void)setSupportBaseType:(HDSSupportViewBaseType)baseType boardView:(nonnull UIView *)boardView {
    
    _boardView = boardView;
    [self removeFromSuperview];
    self.frame = _boardView.bounds;
    self.contentView.frame = _boardView.bounds;
    if (_speedView.hidden == NO) {
        [_speedView updateFrame:self.bounds];
    }
    [_boardView addSubview:self];
    _isAudio = baseType == HDSSupportViewBaseTypeAudio ? YES : NO;
    [self updateSubView:baseType];
}

/// 缓存速度
/// @param speed 速度
- (void)setSpeed:(NSString *)speed {

    if (_trialView) {
        return;
    }
    
    if (_playErrorView) {
        [_playErrorView removeFromSuperview];
        _playErrorView = nil;
    }
    
    if (!_speedView) {
        _speedView = [[HDSSpeedModeView alloc]initWithFrame:self.bounds];
        [self addSubview:_speedView];
    }
    if (_speedView.hidden) {
        _speedView.hidden = NO;
    }
    if (self.width != _speedView.width) {
        [_speedView updateFrame:self.bounds];
    }
    [_speedView setSpeed:speed];
}

/// 隐藏速度
- (void)hiddenSpeed {

    if (!_speedView.hidden) {
        _speedView.hidden = YES;
    }
}

// MARK: - CustionMethod
/// 自定义UI
- (void)customUI {
    
    _contentView = [[UIView alloc]initWithFrame:self.bounds];
    [self addSubview:_contentView];
    
    _speedView = [[HDSSpeedModeView alloc]initWithFrame:self.bounds];
    [self addSubview:_speedView];
    _speedView.hidden = YES;
}

/// 更新子视图
/// @param baseType 类型
- (void)updateSubView:(HDSSupportViewBaseType)baseType {
    
    switch (baseType) {
        case HDSSupportViewBaseTypeAudio:
            [self updateAudioView];
            break;
        case HDSSupportViewBaseTypePlayError:
            [self updatePlayErrorView];
            break;
        case HDSSupportViewBaseTypeTrialEnd:
            [self updateTrialEndView];
            break;
        default:
            [self killAll];
            break;
    }
}

- (void)killAll {
    
    if (_playErrorView) {
        [_playErrorView removeFromSuperview];
        _playErrorView = nil;
    }
    if (_audioView) {
        [_audioView removeFromSuperview];
        _audioView = nil;
    }
    if (_trialView) {
        [_trialView removeFromSuperview];
        _trialView = nil;
    }
}

- (void)updateTrialEndView {
    [self hiddenSpeed];
    if (_audioView) {
        [_audioView removeFromSuperview];
        _audioView = nil;
    }
    if (_trialView) {
        [self.contentView addSubview:_trialView];
        [_trialView setFrame:self.bounds];
        [_trialTipLabel setFrame:self.bounds];
        return;
    }
    _trialView = [[UIView alloc]initWithFrame:self.bounds];
    _trialView.backgroundColor = [UIColor blackColor];
    _trialTipLabel = [[UILabel alloc]initWithFrame:self.bounds];
    _trialTipLabel.textAlignment = NSTextAlignmentCenter;
    _trialTipLabel.font = [UIFont systemFontOfSize:14];
    _trialTipLabel.textColor = [UIColor whiteColor];
    _trialTipLabel.text = @"试看已结束";
    [_trialView addSubview:_trialTipLabel];
    [_contentView addSubview:_trialView];
}

/// 更新音频模块
- (void)updateAudioView {
    
    if (_playErrorView) {
        [_playErrorView removeFromSuperview];
        _playErrorView = nil;
    }
    
    if (_trialView) {
        [_trialView removeFromSuperview];
        _trialView = nil;
    }
    
    [self hiddenSpeed];
    if (_audioView) {
        [self.contentView addSubview:_audioView];
        [_audioView updateFrame:self.bounds];
        return;
    }
    _audioView = [[HDSAudioModeView alloc]initWithFrame:self.bounds];
    [_contentView addSubview:_audioView];
}

/// 更新音频模块
- (void)updatePlayErrorView {
    
    WS(weakSelf)
    if (_audioView) {
        [_audioView removeFromSuperview];
        _audioView = nil;
    }
    
    if (_trialView) {
        [_trialView removeFromSuperview];
        _trialView = nil;
    }
    
    [self hiddenSpeed];
    if (_playErrorView) {
        _playErrorView.frame = self.bounds;
        _playErrorView.isAudio = _isAudio;
        [_playErrorView reset];
        [_playErrorView updateFrame:self.bounds];
        _playErrorView.btnActionClosure = ^{
            if (weakSelf.actionClosure) {
                weakSelf.actionClosure();
            }
        };
        return;
    }
    _playErrorView = [[HDSPlayerErrorModeView alloc]initWithFrame:self.bounds];
    _playErrorView.isAudio = _isAudio;
    [_playErrorView reset];
    [_playErrorView updateFrame:self.bounds];
    [_contentView addSubview:_playErrorView];
    _playErrorView.btnActionClosure = ^{
        if (weakSelf.actionClosure) {
            weakSelf.actionClosure();
        }
    };
}

- (void)kRelease {
    
    if (_audioView) {
        [_audioView removeFromSuperview];
        _audioView = nil;
    }
    
    if (_playErrorView) {
        [_playErrorView removeFromSuperview];
        _playErrorView = nil;
    }
    
    if (_speedView) {
        [_speedView removeFromSuperview];
        _speedView = nil;
    }
    
    if (_trialView) {
        [_trialView removeFromSuperview];
        _trialView = nil;
    }
}

- (void)dealloc {
    
}

@end
