//
//  CCPlayBackView.m
//  CCLiveCloud
//
//  Created by MacBook Pro on 2018/11/20.
//  Copyright © 2018 MacBook Pro. All rights reserved.
//

#import "CCPlayBackView.h"
#import "Utility.h"
#import "InformationShowView.h"
#import "CCAlertView.h"//提示框
#import "CCProxy.h"
#import "HDPlayerBaseToolView.h"
#import "HDPlayerBaseModel.h"
#import "CCSDK/PlayParameter.h"
#import "HDPlayerBaseView.h"
#import "VideoDotInfo.h"
#import "VideoDotEngine.h"
#import "HDPortraitToolManager.h"
#import "HDPortraitToolModel.h"
#import "UIColor+RCColor.h"
#import "CCcommonDefine.h"
#import "UIView+Extension.h"
#import <Masonry/Masonry.h>

#define TOP_SHADOW_IMAGE @"playerBar_against"
#define TOP_BACKBTN_IMAGE @"nav_ic_back_nor_white"
#define TOP_MOREBTN_IMAGE @"player_top_more"
#define BOTTOM_SHADOW_IMAGE @"playerBar"
#define BOTTOM_PLAYBTN_PLAY @"video_play"
#define BOTTOM_PLAYBTN_PAUSE @"video_pause"
#define SLIDER_IMAGE @"progressBar"
#define BOTTOM_FULLSCREEN_IMAGE @"player_bottom_switch"
#define SPEED_DEFAULT_TEXT @"倍速"
#define QUALITY_DEFAULT_TEXT @"清晰度"
#define LIVE_UNSTART_BGIMAGE @"live_streaming_unstart_bg"
#define LIVE_UNSTART_IMAGE @"live_streaming_unstart"
#define REPLAY_BTN_IMAGE @"video_replay"
#define REPLAY_BTN_TEXT @"重播"

@interface CCPlayBackView()<UITextFieldDelegate>

/** 隐藏导航定时器 */
@property (nonatomic, strong)NSTimer                    *playerTimer;
/** 提示视图 */
@property (nonatomic, strong)InformationShowView        *informationViewPop;
/** 是否是文档小窗 */
@property (nonatomic, assign)BOOL                       isSmallDocView;
/** 重新播放 */
@property (nonatomic, strong)UILabel                    *unStart;

/** 手势回调次数标识 */
@property (nonatomic, assign)NSInteger                  showShadowCountFlag;
/** 是否隐藏顶底部工具栏 */
@property (nonatomic, assign)BOOL                       isHiddenShadowView;
/** 顶底部工具栏是否接受用户事件 是 定时器不触发隐藏事件 否 定时器正常触发隐藏事件 */
@property (nonatomic, assign)BOOL                       isUserTouching;

/** 拖动时间 */
@property (nonatomic, assign)int                        dragTime;
/** 拖动时间显示 */
@property (nonatomic, strong)UILabel                    *dragTimeLabel;
/** 正在拖动 */
@property (nonatomic, assign)BOOL                       isDragging;
/** 添加滑动遮罩层 */
@property (nonatomic, strong)UIView                     *draggingShadowView;
/** 是否允许拖动 */
@property (nonatomic, assign)BOOL                       isAllowDragging;

/** 重播 */
@property (nonatomic, strong)UIButton                   * replayBtn;
/** 重播提示 */
@property (nonatomic, strong)UILabel                    * replayTipLabel;
/** 重播shadowView */
@property (nonatomic, strong)UIView                     * replayView;

/** 历史播放记录view */
@property (nonatomic, strong)UIView                     * recordHistoryPlayView;
/** 历史播放记录跳转按钮 */
@property (nonatomic, strong)UIButton                   * recordHistoryPlayJumpBtn;
/** 历史播放记录 */
@property (nonatomic, assign)int                          recordHistoryTime;
/** 时间显示区 */
@property (nonatomic, strong) UIView                    *timeView;
/** 更多按钮 */
@property (nonatomic, strong) UIButton                  *moreBtn;
/** 清晰度按钮 */
@property (nonatomic, strong) UIButton                  *qualityBtn;
/** 更多功能view */
@property (nonatomic, strong) HDPlayerBaseToolView      *baseToolView;
/** 正在显示工具view 默认 NO */
@property (nonatomic, assign) BOOL                      isShowToolView;
/** 线路数据锁 */
@property (nonatomic, assign) BOOL                      lineDataLock;
/** 清晰度数据锁 */
@property (nonatomic, assign) BOOL                      qualityDataLock;
/** 用户选择线路数组 */
@property (nonatomic, strong) NSMutableArray            *lineSelectedArray;
/** 用户选择清晰度数组 */
@property (nonatomic, strong) NSMutableArray            *qualitySelectedArray;
/** 用户选择倍速数组 */
@property (nonatomic, strong) NSMutableArray            *rateSelectedArray;
/** 倍速元数据 */
@property (nonatomic, strong) NSArray                   *rateMetaArray;
/** 用户选择线路下标 */
@property (nonatomic, assign) NSInteger                 userSelectedLineIndex;
/** 用户选择清晰度下标 */
@property (nonatomic, assign) NSInteger                 userSelectedQualityIndex;
/** 是否是横屏倍速 */
@property (nonatomic, assign) BOOL                      isShowLandRate;
/** 音视频线路元数据 */
@property (nonatomic, strong) NSMutableArray            *lineArray;
/** 清晰度元数据 */
@property (nonatomic, strong) NSArray                   *secRoadArr;
/** 是否是音频模式 */
@property (nonatomic, assign) BOOL                      isSound;
/** 是否开启音频模式 */
@property (nonatomic, assign) BOOL                      isAudioMode;
/** 只切换音视频模式 */
@property (nonatomic, assign) BOOL                      isOnlyChangePlayMode;
/** 辅助视图 */
@property (nonatomic, strong) HDPlayerBaseView          *baseView;
/** 打点引擎 */
@property (nonatomic, strong) VideoDotEngine            *dotEngine;
/** 是否显示打点按钮提示窗 */
@property (nonatomic, assign) BOOL                      isShowVideoDotTipView;
/** 顶部阴影 */
@property (nonatomic, strong) UIImageView               *topShadow;
/** 底部阴影 */
@property (nonatomic, strong) UIImageView               *bottomShadow;
/** 打点数据数组 */
@property (nonatomic, strong) NSMutableArray            *dotsInfoArray;

/** 竖屏辅助视图 */
@property (nonatomic, strong) HDPlayerBaseView          *portraitBaseView;
/** 竖屏工具视图 */
@property (nonatomic, strong) HDPortraitToolManager     *portraitToolManager;

@property (nonatomic, copy)   NSDictionary              *lineMetaData;

@property (nonatomic, copy)   NSDictionary              *qualityMetaData;

/// 录屏视图
@property (nonatomic, strong) UIView                    *screenCaptureView;

@end

@implementation CCPlayBackView

/**
 *    @brief    初始化视图
 */
- (instancetype)initWithFrame:(CGRect)frame docViewType:(BOOL)isSmallDocView{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        _sliderValue = 0;//初始化滑动条进度
        _playBackRate = 1.0;//初始化回放速率
        _isSmallDocView = isSmallDocView;//是否是文档小窗
        _isUserTouching = NO; //用户是否点击工具栏
        _isDragging = NO; //是否正在拖动
        _isShowToolView = NO; //默认不显示更多工具
        _isShowLandRate = NO; //默认不使用横屏倍速
        _isOnlyChangePlayMode = NO;
        _isHiddenShadowView = YES;
        _isTrialEnd = NO;
        if (@available(iOS 11.0, *)) {
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(screenCapture)
                                                         name:UIScreenCapturedDidChangeNotification
                                                       object:nil];
        }
        
        /** 倍速默认选择数据 */
        self.rateMetaArray = @[@"0.5x",@"1x",@"1.25x",@"1.5x"];
        [self.rateSelectedArray removeAllObjects];
        HDPlayerBaseModel *model = [[HDPlayerBaseModel alloc]init];
        model.value = @"1x";
        model.func = HDPlayerBaseVideoLine;
        [self.rateSelectedArray addObject:model];
        
        [self newSetupUI];
    }
    return self;
}

// 4.1.0 new
- (void)setIsTrialEnd:(BOOL)isTrialEnd {
    _isTrialEnd = isTrialEnd;
    
    if (_pauseButton.selected == NO && isTrialEnd) {
        _pauseButton.selected = YES;
        [_pauseButton setImage:[UIImage imageNamed:@"video_play"] forState:UIControlStateSelected];
    }
    
    _pauseButton.userInteractionEnabled = isTrialEnd == YES ? NO : YES;
    _moreBtn.userInteractionEnabled = isTrialEnd == YES ? NO : YES;
    _slider.userInteractionEnabled = isTrialEnd == YES ? NO : YES;
    _qualityBtn.userInteractionEnabled = isTrialEnd == YES ? NO : YES;
    _speedButton.userInteractionEnabled = isTrialEnd == YES ? NO : YES;
    _recordHistoryPlayJumpBtn.userInteractionEnabled = isTrialEnd == YES ? NO : YES;
}

- (void)setTrialEndDuration:(NSTimeInterval)trialEndDuration {
    _trialEndDuration = trialEndDuration;
}

- (void)setScreenCaptureSwitch:(BOOL)screenCaptureSwitch {
    _screenCaptureSwitch = screenCaptureSwitch;
    if (_smallVideoView) {
        _smallVideoView.screenCaptureSwitch = _screenCaptureSwitch;
    }
    /// 3.18.0 new 防录屏
    if ([self isCapture]) {
        [self screenCapture];
    }
}

/// 录屏通知
- (void)screenCapture {
    if (_screenCaptureSwitch == NO) {
        return;
    }
    BOOL isCap = [self isCapture];
    if (isCap) {
        if (self.screenCaptureView == nil) {
            self.screenCaptureView = [[UIView alloc]init];
            self.screenCaptureView.backgroundColor = [UIColor blackColor];
            [self addSubview:self.screenCaptureView];
        }
        [self bringSubviewToFront:self.screenCaptureView];
        WS(weakSelf)
        [self.screenCaptureView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(weakSelf);
        }];
        [self.screenCaptureView layoutIfNeeded];
    }else {
        if (_screenCaptureView) {
            [_screenCaptureView removeFromSuperview];
            _screenCaptureView = nil;
        }
    }
}

/// 是否在录屏
- (BOOL)isCapture {
    if (@available(iOS 11.0, *)) {
        return [UIScreen mainScreen].isCaptured;
    }
    return NO;
}

/**
 *    @brief    滑动事件
 */
- (void)UIControlEventTouchDown:(UISlider *)sender {
    /// 4.1.0 new
    if (_isTrialEnd) {
         
        return;
    }
    _isUserTouching = YES;
    UIImage *image = [UIImage imageNamed:@"progressBar"];//图片模式，不设置的话会被压缩
    [_slider setThumbImage:image forState:UIControlStateNormal];//设置图片
}
/**
 *    @brief    滑动完成
 */
- (void)durationSliderDone:(UISlider *)sender
{
    /// 4.1.0 new
    if (_isTrialEnd) {
         
        return;
    }
    UIImage *image2 = [UIImage imageNamed:@"progressBar"];//图片模式，不设置的话会被压缩
    [_slider setThumbImage:image2 forState:UIControlStateNormal];//设置图片
    
    //更新当前播放时间
    int duration = (int)sender.value;
    /// 4.1.0 new
    if (duration > self.trialEndDuration && self.trialEndDuration > 0) {
        duration = self.trialEndDuration;
    }
    _leftTimeLabel.text = [NSString stringWithFormat:@"%@",[self timeFormatted:duration]];

    _slider.value = duration;
    if(duration == 0) {
        _sliderValue = 0;
    }
    
    //滑块完成回调
    self.sliderCallBack(duration);
    
    //更新播放按钮状态
    _pauseButton.selected = NO;
    [_pauseButton setImage:[UIImage imageNamed:@"video_pause"] forState:UIControlStateNormal];
    
    _isUserTouching = NO; //拖拽结束 用户移除点击事件
    [self resetReplayState];//重置重播状态
    [self showOrHiddenShadowView];
}
/**
 *    @brief    滑块正在移动时
 */
- (void)durationSliderMoving:(UISlider *)sender
{
    /// 4.1.0 new
    if (_isTrialEnd) {
         
        return;
    }
    
    //当前有用户触摸事件
    _isUserTouching = YES;
    //重置重播状态
    if (_playDone == NO) {
        [self resetReplayState];
    } else {
        return;
    }
    //更新当前时间
    int duration = (int)sender.value;
    /// 4.1.0 new
    if (duration > self.trialEndDuration && self.trialEndDuration > 0) {
        duration = self.trialEndDuration;
    }
    _leftTimeLabel.text = [NSString stringWithFormat:@"%@",[self timeFormatted:duration]];

    //更新播放按钮状态
    if (_pauseButton.selected == NO) {
        _pauseButton.selected = YES;

        [_pauseButton setImage:[UIImage imageNamed:@"video_play"] forState:UIControlStateSelected];
    }
    
    _slider.value = duration;
    //滑块移动回调
    self.sliderMoving();
}
/**
 *    @brief    开始倒计时
 */
- (void)beginTimer
{
    [self stopPlayerTimer];
    CCProxy *weakObject = [CCProxy proxyWithWeakObject:self];
    self.playerTimer = [NSTimer scheduledTimerWithTimeInterval:5.0f target:weakObject selector:@selector(LatencyHiding) userInfo:nil repeats:YES];
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    [runLoop addTimer:_playerTimer forMode:NSRunLoopCommonModes];
}

/**
 *    @brief    定时器回调
 */
- (void)LatencyHiding
{
    if (self.isShowVideoDotTipView == YES) return;
    if (_isDragging == YES) return; //拖动动 不回调
    if (_isUserTouching == YES) return;//用户点击顶底部工具栏 不回调
    [self stopPlayerTimer];
    self.controlView.hidden = YES;
    self.isHiddenShadowView = YES;
}
/**
 *    @brief    更新UI层级
 */
- (void)updateUITier {
    [self bringSubviewToFront:self.controlView];
    if (_isShowLandRate) {
        [self showDotList];
    }
}
/**
 *  @brief  显示/隐藏 顶底部工具栏
 */
- (void)showOrHiddenShadowView
{
    if (_isShowToolView == YES) {
        [self stopPlayerTimer];
        self.controlView.hidden = YES;
        self.isHiddenShadowView = YES;
        return;
    }
    //滑动时间中也需要一直显示
    if (_isHiddenShadowView == NO || _isDragging == YES) {
        if (_isUserTouching == NO && _isDragging == NO) {
            [self beginTimer];
        }
        self.controlView.hidden = NO;
        [self bringSubviewToFront:self.controlView];
        
    }else {
        [self stopPlayerTimer];
        self.controlView.hidden = YES;
        self.isHiddenShadowView = YES;
    }
}

- (void)newSetupUI {
    
    WS(weakSelf)
    /// 需要传给SDK用的视图
    self.contentView = [[UIView alloc]init];
    self.contentView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.contentView];
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.mas_equalTo(weakSelf);
    }];
    [self.contentView layoutIfNeeded];
    
    /// 顶部视图（展示辅助视图）
    self.headerView = [[UIView alloc]init];
    [self addSubview:self.headerView];
    [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(weakSelf.contentView);
    }];
    [self.headerView layoutIfNeeded];
    
    /** 控制层 */
    self.controlView = [[UIView alloc]init];
    [self addSubview:self.controlView];
    [self.controlView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.mas_equalTo(weakSelf);
    }];
    [self.controlView layoutIfNeeded];
    /** 上阴影 */
    CGFloat ipadShadowH = 44;
    if ([[UIDevice currentDevice].model isEqualToString:@"iPad"]) {
        ipadShadowH = 64;
    }
    self.topShadow = [[UIImageView alloc]init];
    self.topShadow.image = [UIImage imageNamed:TOP_SHADOW_IMAGE];
    [self.controlView addSubview:self.topShadow];
    [self.topShadow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.mas_equalTo(weakSelf.controlView);
        make.height.mas_equalTo(ipadShadowH);
    }];
    [self.topShadow layoutIfNeeded];
    /** 返回按钮 */
    self.backButton = [[CCButton alloc]init];
    [self.backButton setImage:[UIImage imageNamed:TOP_BACKBTN_IMAGE] forState:UIControlStateNormal];
    self.backButton.tag = 1;
    [self.controlView addSubview:self.backButton];
    [self.backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.controlView);
        make.top.mas_equalTo(weakSelf.controlView);
        make.width.height.mas_equalTo(ipadShadowH);
    }];
    [self.backButton layoutIfNeeded];
    
    /** 更多按钮 */
    self.moreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.moreBtn setImage:[UIImage imageNamed:TOP_MOREBTN_IMAGE] forState:UIControlStateNormal];
    [self.controlView addSubview:self.moreBtn];
    [self.moreBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(weakSelf.controlView).offset(-10);
        make.centerY.mas_equalTo(weakSelf.backButton.mas_centerY);
        make.width.height.mas_equalTo(44);
    }];
    [self.moreBtn layoutIfNeeded];
    
    /** 房间标题 */
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.font = [UIFont systemFontOfSize:FontSize_30];
    [self.controlView addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.backButton.mas_right);
        make.centerY.mas_equalTo(weakSelf.backButton);
        make.right.mas_equalTo(weakSelf.moreBtn.mas_left);
    }];
    [self.titleLabel layoutIfNeeded];
    
    /** 下阴影 */
    self.bottomShadow = [[UIImageView alloc] init];
    self.bottomShadow.image = [UIImage imageNamed:BOTTOM_SHADOW_IMAGE];
    [self.controlView addSubview:self.bottomShadow];
    [self.bottomShadow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(weakSelf.controlView);
        make.height.mas_equalTo(54);
    }];
    [self.bottomShadow layoutIfNeeded];
    /** 暂停按钮 */
    self.pauseButton = [[CCButton alloc] init];
    self.pauseButton.backgroundColor = CCClearColor;
    [self.pauseButton setImage:[UIImage imageNamed:BOTTOM_PLAYBTN_PAUSE] forState:UIControlStateNormal];
    [self.pauseButton setImage:[UIImage imageNamed:BOTTOM_PLAYBTN_PLAY] forState:UIControlStateSelected];
    self.pauseButton.contentMode = UIViewContentModeScaleAspectFit;
    [self.controlView addSubview:self.pauseButton];
    [self.pauseButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.bottomShadow.mas_top).offset(15);
        make.left.mas_equalTo(weakSelf.bottomShadow.mas_left).offset(5);
        make.width.height.mas_equalTo(35);
    }];
    [self.pauseButton layoutIfNeeded];
    self.pauseButton.endTouchBlock = ^(NSString * _Nonnull sting) {
        weakSelf.isUserTouching = NO;
    };
    /** 时间显示区 */
    self.timeView = [[UIView alloc]init];
    [self.controlView addSubview:self.timeView];
    [self.timeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.pauseButton.mas_right).offset(-8);
        make.centerY.mas_equalTo(weakSelf.pauseButton);
        make.width.mas_equalTo(97);
        make.height.mas_equalTo(44);
    }];
    [self.timeView layoutIfNeeded];
    /** 时间中间的 '/' */
    UILabel * placeholder = [[UILabel alloc] init];
    placeholder.text = @"/";
    placeholder.textColor = [UIColor whiteColor];
    placeholder.font = [UIFont systemFontOfSize:FontSize_24];
    placeholder.textAlignment = NSTextAlignmentCenter;
    [self.timeView addSubview:placeholder];
    [placeholder mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(weakSelf.timeView);
        make.centerX.mas_equalTo(weakSelf.timeView);
    }];
    [placeholder layoutIfNeeded];
    /** 当前播放时间 */
    self.leftTimeLabel = [[UILabel alloc] init];
    self.leftTimeLabel.text = @"00:00";
    self.leftTimeLabel.userInteractionEnabled = NO;
    self.leftTimeLabel.textColor = [UIColor colorWithHexString:@"#FF9500" alpha:1];
    self.leftTimeLabel.font = [UIFont systemFontOfSize:FontSize_24];
    self.leftTimeLabel.textAlignment = NSTextAlignmentRight;
    [self.timeView addSubview:self.leftTimeLabel];
    [self.leftTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(weakSelf.timeView);
        make.left.mas_equalTo(weakSelf.timeView);
        make.right.mas_equalTo(placeholder.mas_left).offset(-1);
    }];
    [self.leftTimeLabel layoutIfNeeded];
    /** 总时长 */
    self.rightTimeLabel = [[UILabel alloc] init];
    self.rightTimeLabel.text = @"--:--";
    self.rightTimeLabel.userInteractionEnabled = NO;
    self.rightTimeLabel.textColor = [UIColor whiteColor];
    self.rightTimeLabel.font = [UIFont systemFontOfSize:FontSize_24];
    self.rightTimeLabel.alpha = 0.6f;
    self.rightTimeLabel.textAlignment = NSTextAlignmentCenter;
    [self.timeView addSubview:self.rightTimeLabel];
    [self.rightTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(placeholder);
        make.right.mas_equalTo(weakSelf.timeView.mas_right);
        make.centerY.mas_equalTo(weakSelf.timeView);
    }];
    [self.rightTimeLabel layoutIfNeeded];
    /** 滑动条 */
    self.slider = [[MySlider alloc] init];
    //设置滑动条最大值
    self.slider.maximumValue =0;
    //设置滑动条的最小值，可以为负值
    self.slider.minimumValue =0;
    //设置滑动条的滑块位置float值
    self.slider.value = 0.00;
    //左侧滑条背景颜色
    self.slider.minimumTrackTintColor = [UIColor colorWithHexString:@"#FF9500" alpha:1];
    //右侧滑条背景颜色
    self.slider.maximumTrackTintColor = [UIColor colorWithHexString:@"#999999" alpha:1];
    //设置滑块的颜色
    [self.slider setThumbImage:[UIImage imageNamed:SLIDER_IMAGE] forState:UIControlStateNormal];
    //对滑动条添加事件函数
    [self.slider addTarget:self action:@selector(durationSliderMoving:) forControlEvents:UIControlEventValueChanged];
    [self.slider addTarget:self action:@selector(durationSliderDone:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchCancel | UIControlEventTouchUpOutside];
    [self.slider addTarget:self action:@selector(UIControlEventTouchDown:) forControlEvents:UIControlEventTouchDown];
    [self.controlView addSubview:self.slider];
    /** 全屏按钮 */
    self.quanpingButton = [[CCButton alloc] init];
    [self.quanpingButton setImage:[UIImage imageNamed:BOTTOM_FULLSCREEN_IMAGE] forState:UIControlStateNormal];
    self.quanpingButton.tag = 1;
    [self.controlView addSubview:self.quanpingButton];
    [self.quanpingButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(weakSelf.pauseButton);
        make.right.mas_equalTo(weakSelf.bottomShadow.mas_right).offset(-10);
        make.width.height.mas_equalTo(35);
    }];
    [self.quanpingButton layoutIfNeeded];
    self.quanpingButton.endTouchBlock = ^(NSString * _Nonnull sting) {
        weakSelf.isUserTouching = NO;
    };
    /** 切换视频 */
    self.changeButton = [[CCButton alloc] init];
    self.changeButton.tag = 2;//默认以文档为主
    [self.changeButton setImage:PLAY_CHANGEVIDEO_IMAGE forState:UIControlStateNormal];
    self.changeButton.imageView.contentMode = UIViewContentModeCenter;
    [self.controlView addSubview:self.changeButton];
    [self.changeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(weakSelf.pauseButton);
        make.right.mas_equalTo(weakSelf.quanpingButton.mas_left).offset(-5);
        make.width.height.mas_equalTo(35);
    }];
    [self.changeButton layoutIfNeeded];
    self.changeButton.endTouchBlock = ^(NSString * _Nonnull sting) {
        weakSelf.isUserTouching = NO;
    };
    /** 倍速按钮 */
    self.speedButton = [[CCButton alloc] init];
    [self.speedButton setTitle:SPEED_DEFAULT_TEXT forState:UIControlStateNormal];
    self.speedButton.titleLabel.font = [UIFont systemFontOfSize:FontSize_28];
    self.speedButton.hidden = YES;
    [self.controlView addSubview:self.speedButton];
    [self.speedButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(weakSelf.pauseButton);
        make.right.mas_equalTo(weakSelf.quanpingButton.mas_left).offset(-5);
        make.width.height.mas_equalTo(35);
    }];
    [self.speedButton layoutIfNeeded];
    self.speedButton.endTouchBlock = ^(NSString * _Nonnull sting) {
        weakSelf.isUserTouching = NO;
    };
    /** 清晰度按钮 */
    self.qualityBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.qualityBtn setTitle:QUALITY_DEFAULT_TEXT forState:UIControlStateNormal];
    [self.qualityBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.qualityBtn.titleLabel.font = [UIFont systemFontOfSize:FontSize_30];
    [self.controlView addSubview:self.qualityBtn];
    [self.qualityBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(weakSelf.quanpingButton.mas_left).offset(-10);
        make.centerY.equalTo(weakSelf.pauseButton);
        make.height.mas_equalTo(30);
        make.width.mas_equalTo(60);
    }];
    [self.qualityBtn layoutIfNeeded];
    self.qualityBtn.hidden = YES;
    
    
    /** 进度条 */
    [self.slider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.bottomShadow.mas_top).offset(10);
        make.left.mas_equalTo(weakSelf.bottomShadow.mas_left).offset(15);
        make.right.mas_equalTo(weakSelf.bottomShadow.mas_right).offset(-15);
        make.height.mas_equalTo(17);
    }];
    [self.slider layoutIfNeeded];
    
    /** 重置进度条布局 */
//    CGFloat offset = 44 / 2 - 3;
//    [self.slider mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.mas_equalTo(weakSelf.bottomShadow.mas_top).offset(offset);
//        make.left.mas_equalTo(weakSelf.timeView.mas_right).offset(10);
//        make.right.mas_equalTo(weakSelf.speedButton.mas_left).offset(-10);
//        make.height.mas_equalTo(17);
//    }];
//    [self.slider layoutIfNeeded];
    /** 隐藏导航 */
    [self beginTimer];
    /** 按钮添加点击事件监听 */
    [self.backButton addTarget:self action:@selector(backButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.changeButton addTarget:self action:@selector(changeButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.quanpingButton addTarget:self action:@selector(quanpingButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.pauseButton addTarget:self action:@selector(pauseButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.speedButton addTarget:self action:@selector(playbackRateBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.moreBtn addTarget:self action:@selector(moreBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.qualityBtn addTarget:self action:@selector(qualityBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    /** 添加文档小窗 */
    _smallVideoView = [[CCDocView alloc] initWithType:_isSmallDocView];
    _smallVideoView.hiddenSmallVideoBlock = ^{
        [weakSelf hiddenSmallVideoview];
    };
    /** 直播未开始 */
    self.liveEnd = [[UIImageView alloc] init];
    self.liveEnd.image = [UIImage imageNamed:LIVE_UNSTART_BGIMAGE];
    [self addSubview:self.liveEnd];
    self.liveEnd.frame = CGRectMake(0, 0, SCREEN_WIDTH, HDGetRealHeight);
    self.liveEnd.hidden = YES;
    /** 直播未开始图片 */
    UIImageView * alarmClock = [[UIImageView alloc] init];
    alarmClock.image = [UIImage imageNamed:LIVE_UNSTART_IMAGE];
    [self.liveEnd addSubview:alarmClock];
    [alarmClock mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(weakSelf.liveEnd);
        make.height.width.mas_equalTo(32);
        make.centerY.mas_equalTo(weakSelf.liveEnd.mas_centerY).offset(-10);
    }];
    [alarmClock layoutIfNeeded];
    /** 未开始 */
    self.unStart = [[UILabel alloc] init];
    self.unStart.textColor = [UIColor whiteColor];
    self.unStart.alpha = 0.6f;
    self.unStart.textAlignment = NSTextAlignmentCenter;
    self.unStart.font = [UIFont systemFontOfSize:FontSize_30];
    self.unStart.text = PLAY_END;
    [self.liveEnd addSubview:self.unStart];
    self.unStart.frame = CGRectMake(SCREEN_WIDTH/2-50, 236, 100, 30);
    /** 拖动阴影 */
    self.draggingShadowView = [[UIView alloc]init];
    self.draggingShadowView.backgroundColor = CCRGBAColor(0, 0, 0, 0.7);
    self.draggingShadowView.hidden = YES;
    self.draggingShadowView.userInteractionEnabled = NO;
    [self addSubview:self.draggingShadowView];
    [self bringSubviewToFront:self.draggingShadowView];
    [self.draggingShadowView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.mas_equalTo(weakSelf);
    }];
    [self.draggingShadowView layoutIfNeeded];
    /** 推动时间进度 */
    self.dragTimeLabel = [[UILabel alloc]init];
    self.dragTimeLabel.textColor = [UIColor whiteColor];
    self.dragTimeLabel.font = [UIFont systemFontOfSize:FontSize_40];
    self.dragTimeLabel.hidden = YES;
    self.dragTimeLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.dragTimeLabel];
    [self.dragTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.centerY.mas_equalTo(weakSelf);
    }];
    [self.dragTimeLabel layoutIfNeeded];
    /** 添加拖动手势 */
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragAction:)];
    [self addGestureRecognizer:pan];
    /** 重播 */
    _replayView = [[UIView alloc]init];
    _replayView.backgroundColor = CCRGBAColor(0, 0, 0, 0.3);
    _replayView.hidden = YES;
    [self addSubview:_replayView];
    [_replayView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.mas_equalTo(weakSelf);
    }];
    [_replayView layoutIfNeeded];
    /** 重播按钮 */
    _replayBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_replayBtn setImage:[UIImage imageNamed:REPLAY_BTN_IMAGE] forState:UIControlStateNormal];
    [_replayBtn addTarget:self action:@selector(replayBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [_replayView addSubview:_replayBtn];
    [_replayBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(weakSelf.replayView);
        make.centerY.mas_equalTo(weakSelf.replayView).offset(-10);
        make.width.height.mas_equalTo(50);
    }];
    [_replayBtn layoutIfNeeded];
    /** 重播显示提示 */
    _replayTipLabel = [[UILabel alloc]init];
    _replayTipLabel.text = REPLAY_BTN_TEXT;
    _replayTipLabel.textColor = [UIColor whiteColor];
    _replayTipLabel.font = [UIFont systemFontOfSize:13];
    _replayTipLabel.textAlignment = NSTextAlignmentCenter;
    [_replayView addSubview:_replayTipLabel];
    [_replayTipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(weakSelf.replayBtn);
        make.top.mas_equalTo(weakSelf.replayBtn.mas_bottom).offset(-10);
    }];
    [_replayTipLabel layoutIfNeeded];
    
    [self.controlView bringSubviewToFront:self.pauseButton];
    /// 防录屏
    if ([self isCapture]) {
        [self screenCapture];
    }
}

// MARK: - update
- (void)updateMoreBtnConstraints:(BOOL)isHidden {
    CGFloat offset = -10;
    if (IS_IPHONE_X) {
        offset = _isShowLandRate == YES ? -54 : -10;
    }
    if (isHidden) {
        __weak typeof(self) weakSelf = self;
        [_moreBtn mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(0);
            make.right.mas_equalTo(weakSelf.controlView).offset(offset);
        }];
    } else {
        __weak typeof(self) weakSelf = self;
        [_moreBtn mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(44);
            make.right.mas_equalTo(weakSelf.controlView).offset(offset);
        }];
    }
}

- (void)setIsOffline:(BOOL)isOffline {
    _isOffline = isOffline;
    if (_isOffline == YES && _isShowLandRate == YES) {
        self.moreBtn.hidden = YES;
        [self updateMoreBtnConstraints:YES];
    }
}

#pragma mark - 切换横竖屏
/**
 *    @brief    切换横竖屏
 *    @param    screenLandScape   横竖屏
 */
- (void)layoutUI:(BOOL)screenLandScape {
    
    WS(weakSelf)
    self.isShowLandRate = screenLandScape;
    self.quanpingButton.hidden = screenLandScape;
    if (_isOffline == YES && screenLandScape == YES) {
        self.moreBtn.hidden = YES;
        [self updateMoreBtnConstraints:YES];
    }else {
        self.moreBtn.hidden = NO;
        [self updateMoreBtnConstraints:NO];
    }
    if (screenLandScape == YES) { /// 横屏
        self.speedButton.hidden = NO;
        if (_isOffline == YES) {
            self.qualityBtn.hidden = _isOffline == YES ? YES : NO;
        }else {
            self.qualityBtn.hidden = self.isSound == YES ? YES : NO;
        }
        CGFloat offset = IS_IPHONE_X ? 44 : 0;
        /** 底部阴影 */
        [self.bottomShadow mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(64);
        }];
        /** 进度条 */
        [self.slider mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(weakSelf.bottomShadow.mas_left).offset(20+offset);
            make.right.mas_equalTo(weakSelf.bottomShadow.mas_right).offset(-(20+offset));
        }];
        /** 更新暂停按钮约束 */
        [self.pauseButton mas_updateConstraints:^(MASConstraintMaker *make) {;
            make.left.mas_equalTo(weakSelf.bottomShadow.mas_left).offset(5+offset);
            make.width.height.mas_equalTo(44);
        }];
        [self.controlView bringSubviewToFront:self.pauseButton];
        
        [self.changeButton mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.height.mas_equalTo(44);
        }];
        
        [self.quanpingButton mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.height.mas_equalTo(44);
        }];
        
        [self.backButton mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(weakSelf.controlView).offset(offset);
        }];
        [self.backButton layoutIfNeeded];
        
        self.liveEnd.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
        self.unStart.frame = CGRectMake(SCREEN_WIDTH/2-50, 200, 100, 30);
        
        /** 离线回放 */
        if (_isOffline == YES || self.qualityBtn.hidden == YES) {
            if (self.changeButton.hidden == YES) {
                /** 重置倍速按钮 */
                [self.speedButton mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.centerY.mas_equalTo(weakSelf.pauseButton);
                    make.right.mas_equalTo(weakSelf.bottomShadow.mas_right).offset(-(10+offset));
                    make.width.mas_equalTo(44);
                    make.height.mas_equalTo(44);
                }];
            }else {
                /** 重置倍速按钮 */
                [self.speedButton mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.centerY.mas_equalTo(weakSelf.pauseButton);
                    make.right.mas_equalTo(weakSelf.changeButton.mas_left).offset(-10);
                    make.width.mas_equalTo(44);
                    make.height.mas_equalTo(44);
                }];
            }
        }else {
            if (self.changeButton.hidden == YES) {
                /** 重置清晰度按钮约束 */
                [self.qualityBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.right.mas_equalTo(weakSelf.bottomShadow.mas_right).offset(-(5+offset));
                    make.centerY.mas_equalTo(weakSelf.pauseButton);
                    make.height.mas_equalTo(30);
                    make.width.mas_equalTo(70);
                }];
            }else {
                /** 重置清晰度按钮约束 */
                [self.qualityBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.right.mas_equalTo(weakSelf.changeButton.mas_left).offset(-5);
                    make.centerY.mas_equalTo(weakSelf.pauseButton);
                    make.height.mas_equalTo(30);
                    make.width.mas_equalTo(70);
                }];
            }
            [self.qualityBtn layoutIfNeeded];
            /** 重置倍速按钮 */
            [self.speedButton mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.centerY.mas_equalTo(weakSelf.pauseButton);
                make.right.mas_equalTo(weakSelf.qualityBtn.mas_left);
                make.width.mas_equalTo(44);
                make.height.mas_equalTo(44);
            }];
        }
        if (self.recordHistoryPlayView.hidden != YES) {
            CGFloat offset = IS_IPHONE_X ? 44 :0;
            [self.recordHistoryPlayView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(weakSelf.bottomShadow.mas_left).offset(offset);
            }];
        }
        
        /** 重置切换按钮 */
        [self.changeButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(weakSelf.bottomShadow.mas_right).offset(-(5+offset));
            make.centerY.mas_equalTo(weakSelf.pauseButton);
            make.width.height.mas_equalTo(44);
        }];
        [self.changeButton layoutIfNeeded];
        [self.controlView bringSubviewToFront:self.changeButton];
        
        if (self.dotsInfoArray.count > 0 && !_isOffline) {
            [self showDotList];
            [_dotEngine hideAll:NO];
        }
        
    }else { /// 竖屏
        self.moreBtn.hidden = NO;
        self.speedButton.hidden = YES;
        self.isShowToolView = NO;
        self.qualityBtn.hidden = YES;
        [self.dotEngine hideAll:YES];
        /** 下阴影更新布局 */
        [self.bottomShadow mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(54);
        }];
        /** 暂停按钮更新布局 */
        [self.pauseButton mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(weakSelf.bottomShadow.mas_left).offset(5);
            make.width.height.mas_equalTo(35);
        }];
        [self.pauseButton layoutIfNeeded];
        
        [self.quanpingButton mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.height.mas_equalTo(35);
        }];
        
        /** 倍速按钮 */
        [self.speedButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(weakSelf.pauseButton);
            make.right.mas_equalTo(weakSelf.quanpingButton.mas_left).offset(-5);
            make.width.height.mas_equalTo(35);
        }];
        [self.speedButton layoutIfNeeded];
        
        [self.slider mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(weakSelf.bottomShadow.mas_left).offset(15);
            make.right.mas_equalTo(weakSelf.bottomShadow.mas_right).offset(-15);
        }];
        
        [self.changeButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(weakSelf.pauseButton);
            make.right.mas_equalTo(weakSelf.quanpingButton.mas_left).offset(-5);
            make.width.height.mas_equalTo(35);
        }];
        [self.changeButton layoutIfNeeded];
        
        [self.backButton mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(weakSelf.controlView);
        }];
        [self.backButton layoutIfNeeded];
        
        if (self.recordHistoryPlayView.hidden != YES) {
            [self.recordHistoryPlayView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(weakSelf.bottomShadow.mas_left);
            }];
        }
        
        self.liveEnd.frame = CGRectMake(0, 0, SCREEN_WIDTH, HDGetRealHeight);
        self.unStart.frame = CGRectMake(SCREEN_WIDTH/2-50, 236, 100, 30);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            weakSelf.backButton.userInteractionEnabled = YES;
        });
    }
}
#pragma mark - 更多工具
/**
 *    @brief    更多按钮点击事件
 */
- (void)moreBtnClick:(UIButton *)sender {
    /// 4.1.0 new
    if (_isTrialEnd) {
         
        return;
    }
    if (_isShowToolView == NO ) {
        if (_isShowLandRate == YES) {
            [self showToolViewWithType:0];
        }else {
            [self showPortraintTool];
        }
    }
}
/**
 *    @brief    展示竖屏工具
 */
- (void)showPortraintTool {
    
    WS(ws)
    if (!self.portraitBaseView) {
        /// 背景视图
        self.portraitBaseView = [[HDPlayerBaseView alloc]init];
        self.portraitBaseView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
        [APPDelegate.window addSubview:self.portraitBaseView];
        [APPDelegate.window makeKeyAndVisible];
        self.portraitBaseView.touchBegin = ^(NSString * _Nonnull string) {
            [ws.portraitToolManager setToolViewHidden:YES];
        };
        /// 工具视图
        BOOL isAudioMode = self.isAudioMode;
        BOOL isQuality = self.secRoadArr.count > 0 ? YES : NO;
        BOOL isLine = self.lineArray.count > 0 ? YES : NO;
        BOOL isRate = YES;
        self.portraitToolManager = [[HDPortraitToolManager alloc]initWithBoardView:self.portraitBaseView
                                                                         audioMode:isAudioMode
                                                                           quality:isQuality
                                                                              line:isLine
                                                                              rate:isRate
                                                                        eventBlock:^(HDPortraitToolModel * _Nonnull model) {
            [ws updatePortraitToolDataWithModel:model];
            [ws.portraitToolManager setToolViewHidden:YES];
        }];
    }
    if (self.rateSelectedArray.count > 0) {
        HDPlayerBaseModel *baseModel = [self.rateSelectedArray firstObject];
        NSMutableDictionary *rateDict = [NSMutableDictionary dictionary];
        rateDict[@"rateList"] = self.rateMetaArray;
        rateDict[@"currentRate"] = baseModel.value;
        [self.portraitToolManager setRateMetaData:rateDict];
    }
    [self.portraitToolManager setAudioModeSelected:self.isSound];
    [self.portraitToolManager setLineMetaData:self.lineMetaData];
    [self.portraitToolManager setQualityMetaData:self.qualityMetaData];
    [self.portraitToolManager setToolViewHidden:NO];
}
/**
 *    @brief    更新竖屏用户选择数据
 *    @param    model   数据
 */
- (void)updatePortraitToolDataWithModel:(HDPortraitToolModel *)model {
    if (model.type == HDPortraitToolTypeWithAudioMode) {
        self.isOnlyChangePlayMode = YES;
        self.isSound = model.isSelected;
        if (self.switchAudio) {
            self.switchAudio(model.isSelected);
        }
    }else if (model.type == HDPortraitToolTypeWithLine) {
        _userSelectedLineIndex = model.index;
        if (self.selectedRod) {
            self.selectedRod(model.index);
        }
    }else if (model.type == HDPortraitToolTypeWithQuality) {
        _userSelectedQualityIndex = model.index;
        if (self.selectedQuality) {
            self.selectedQuality(model.value);
        }
    }else if (model.type == HDPortraitToolTypeWithRate) {
        HDPlayerBaseModel *baseModel = [[HDPlayerBaseModel alloc]init];
        baseModel.func = HDPlayerBaseRate;
        baseModel.index = model.index;
        baseModel.desc = model.desc;
        baseModel.value = model.value;
        [self.rateSelectedArray replaceObjectAtIndex:0 withObject:baseModel];
        [self updateRateUIWithString:model.value];
    }
}

/**
 *    @brief    清晰度按钮点击事件
 */
- (void)qualityBtnClick:(UIButton *)sender {
    if (_isShowToolView == NO) {
        [self showToolViewWithType:2];
    }
}
/**
 *    @brief    点击切换倍速按钮
 */
- (void)playbackRateBtnClicked {
    /// 4.1.0 new
    if (_isTrialEnd) {
         
        return;
    }
    if (self.isShowLandRate == YES) {
        if (_isShowToolView == NO) {
            [self showToolViewWithType:1];
        }
    }else {
        HDPlayerBaseModel *newModel = [[HDPlayerBaseModel alloc]init];
        newModel.func = HDPlayerBaseRate;
        _isUserTouching = YES;
        NSString *title = self.speedButton.titleLabel.text;
        if([title isEqualToString:@"倍速"]) {
            [self.speedButton setTitle:@"1.25x" forState:UIControlStateNormal];
            _playBackRate = 1.25;
            newModel.value = @"1.25x";
            self.changeRate(_playBackRate);
        } else if([title isEqualToString:@"1.25x"]) {
            [self.speedButton setTitle:@"1.5x" forState:UIControlStateNormal];
            _playBackRate = 1.5;
            newModel.value = @"1.5x";
            self.changeRate(_playBackRate);
        } else if([title isEqualToString:@"1.5x"]) {
            [self.speedButton setTitle:@"0.5x" forState:UIControlStateNormal];
            _playBackRate = 0.5;
            newModel.value = @"0.5x";
            self.changeRate(_playBackRate);
            
        } else if([title isEqualToString:@"0.5x"]) {
            [self.speedButton setTitle:@"倍速" forState:UIControlStateNormal];
            _playBackRate = 1.0;
            /** 更新数据 */
            newModel.value = @"1x";
            self.changeRate(_playBackRate);
        }
        [self.rateSelectedArray replaceObjectAtIndex:0 withObject:newModel];
    }
}
/**
 *    @brief    更新用户选择输入
 *    @param    model   数据
 */
- (void)updateUserInfosWithModel:(HDPlayerBaseModel *)model {
    
    HDPlayerBaseModel *newModel = [[HDPlayerBaseModel alloc]init];
    newModel.value = model.value;
    if (model.func == HDPlayerBaseQuality) { //清晰度
        //NSLog(@"---切换----清晰度:%zd",model.index);
        /** 更新UI */
        [self updateQualityUIWithString:model.value];
        /** 当前用户选择的清晰度 */
        _userSelectedQualityIndex = model.index;
        if (self.selectedQuality) {
            self.selectedQuality(model.value);
        }
        /** 更新数据 */
        newModel.func = HDPlayerBaseQuality;
        [self.qualitySelectedArray replaceObjectAtIndex:0 withObject:newModel];
        
    }else if (model.func == HDPlayerBaseVideoLine) {
        
        self.isSound = NO;
        self.qualityBtn.hidden = NO;
        [self layoutUI:YES];
        
        //NSLog(@"---切换----视频线路:%zd",model.index);
        /** 当前用户选择线路 */
        _userSelectedLineIndex = model.index;
        if (self.isOnlyChangePlayMode != YES) {
            if (self.selectedRod) {
                self.selectedRod(_userSelectedLineIndex);
            }
        }
        self.isOnlyChangePlayMode = NO;
        /** 更新数据 */
        newModel.func = HDPlayerBaseVideoLine;
        [self.lineSelectedArray replaceObjectAtIndex:0 withObject:newModel];
        
    }else if (model.func == HDPlayerBaseAudioLine) {
        
        self.qualityBtn.hidden = YES;
        self.isSound = YES;
        [self layoutUI:YES];
        //NSLog(@"---切换----音频线路:%zd",model.index);
        /** 当前用户选择线路 */
        _userSelectedLineIndex = model.index;
        if (self.isOnlyChangePlayMode != YES) {
            if (self.selectedRod) {
                self.selectedRod(_userSelectedLineIndex);
            }
        }
        self.isOnlyChangePlayMode = NO;
        /** 更新数据 */
        newModel.func = HDPlayerBaseAudioLine;
        [self.lineSelectedArray replaceObjectAtIndex:0 withObject:newModel];
        
    }else if (model.func == HDPlayerBaseRate) {
        //NSLog(@"---切换----倍速:%zd",model.index);
        /** 更新UI */
        NSString *value = newModel.value;
        [self updateRateUIWithString:value];
        /** 更新数据 */
        newModel.func = HDPlayerBaseRate;
        [self.rateSelectedArray replaceObjectAtIndex:0 withObject:newModel];
    }
}
/**
 *    @brief    更新清晰度UI
 *    @param    quality   清晰度
 */
- (void)updateQualityUIWithString:(NSString *)quality {
    for (HDQualityModel *model in self.secRoadArr) {
        if ([model.quality isEqualToString:quality]) {
            NSString *qualityStr = model.desc;
            qualityStr = qualityStr.length == 0 ? @"原画" : qualityStr;
            [self.qualityBtn setTitle:qualityStr forState:UIControlStateNormal];
        }
    }
}
/**
 *    @brief    横屏更换倍速UI
 *    @param    rate   倍速
 */
- (void)updateRateUIWithString:(NSString *)rate {
    
    if([rate isEqualToString:@"1x"]) {
        [self.speedButton setTitle:@"倍速" forState:UIControlStateNormal];
        _playBackRate = 1.0;
        self.changeRate(_playBackRate);
    } else if([rate isEqualToString:@"1.25x"]) {
        [self.speedButton setTitle:@"1.25x" forState:UIControlStateNormal];
        _playBackRate = 1.25;
        self.changeRate(_playBackRate);
    } else if([rate isEqualToString:@"1.5x"]) {
           [self.speedButton setTitle:@"1.5x" forState:UIControlStateNormal];
           _playBackRate = 1.5;
           self.changeRate(_playBackRate);
       } else if([rate isEqualToString:@"0.5x"]) {
        [self.speedButton setTitle:@"0.5x" forState:UIControlStateNormal];
        _playBackRate = 0.5;
        self.changeRate(_playBackRate);
    }
}
/**
 *    @brief    初始化工具栏
 */
- (void)initBaseToolView {
    if (!self.baseToolView) {
        self.baseView = [[HDPlayerBaseView alloc]init];
        self.baseView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
        [APPDelegate.window addSubview:self.baseView];
        
        CGFloat w = 205;
        CGFloat h = SCREEN_HEIGHT;
        CGFloat x = SCREEN_WIDTH;
        CGFloat y = 0;
        self.baseToolView = [[HDPlayerBaseToolView alloc]initWithFrame:CGRectMake(x,y,w,h)];
        [APPDelegate.window addSubview:self.baseToolView];
    }else {
        self.baseView.hidden = NO;
        self.baseToolView.hidden = NO;
    }
}

/**
 *    @brief    展示工具view
 *    @param    type   对应展示类型
 */
- (void)showToolViewWithType:(NSInteger)type {
    WS(ws)
    [ws initBaseToolView];
    [UIView animateWithDuration:0.35 animations:^{
        CGFloat w = 205;
        CGFloat h = SCREEN_HEIGHT;
        CGFloat x = SCREEN_WIDTH - w;
        CGFloat y = 0;
        ws.baseToolView.frame = CGRectMake(x, y, w, h);
        if (type == 1) {
            HDPlayerBaseModel *model = [ws.rateSelectedArray firstObject];
            [ws.baseToolView showInformationWithType:HDPlayerBaseToolViewTypeRate infos:ws.rateMetaArray defaultData:model];
        }else if (type == 2) {
            HDPlayerBaseModel *model = [ws.qualitySelectedArray firstObject];
            [ws.baseToolView showInformationWithType:HDPlayerBaseToolViewTypeQuality infos:ws.secRoadArr defaultData:model];
        }else {
            HDPlayerBaseModel *model = [ws.lineSelectedArray firstObject];
            [ws.baseToolView showInformationWithType:HDPlayerBaseToolViewTypeLine infos:ws.lineArray defaultData:model];
        }
    } completion:^(BOOL finished) {
        ws.isShowToolView = YES;
        [ws showOrHiddenShadowView];
    }];
    
    self.baseView.touchBegin = ^(NSString * _Nonnull string) {
        [ws hiddenToolView];
    };
    self.baseToolView.switchAudio = ^(BOOL result) {
        ws.isOnlyChangePlayMode = YES;
        if (ws.switchAudio) {
            ws.switchAudio(result);
        }
    };
    self.baseToolView.baseToolBlock = ^(HDPlayerBaseModel * _Nonnull model) {
        [ws hiddenToolView];
        [ws updateUserInfosWithModel:model];
    };
}
/**
 *    @brief    隐藏工具view
 */
- (void)hiddenToolView {
    WS(ws)
    [UIView animateWithDuration:0.35 animations:^{;
        ws.baseView.hidden = YES;
        CGFloat w = 205;
        CGFloat h = SCREEN_HEIGHT;
        CGFloat x = SCREEN_WIDTH;
        CGFloat y = 0;
        ws.baseToolView.frame = CGRectMake(x,y,w,h);
    } completion:^(BOOL finished) {
        ws.baseToolView.hidden = YES;
        ws.isShowToolView = NO;
        ws.isHiddenShadowView = NO;
        [ws showOrHiddenShadowView];
    }];
}
/**
 *    The New Method (3.13.0)
 *    @brief    是否开启音频模式
 *    @param    hasAudio   HAVE_AUDIO_LINE_TURE 有音频 HAVE_AUDIO_LINE_FALSE 无音频
 *
 *    触发回调条件 1.初始化SDK登录成功后
 */
- (void)HDAudioMode:(HAVE_AUDIO_LINE)hasAudio {
    if (hasAudio == HAVE_AUDIO_LINE_TURE) {
        self.isAudioMode = YES;
    }else if (hasAudio == HAVE_AUDIO_LINE_FALSE) {
        self.isAudioMode = NO;
    }
}
/**
 *    The New Method (3.13.0)
 *    @brief    房间所包含的清晰度 (会多次回调)
 *    @param    dict    清晰度数据
 *    清晰度数据  key(包含的键值)              type(数据类型)             description(描述)
 *              qualityList(清晰度列表)      array                     @[HDQualityModel(清晰度详情),HDQualityModel(清晰度详情)]
 *              currentQuality(当前清晰度)   object                    HDQualityModel(清晰度详情)
 *
 *    触发回调条件 1.初始化SDK登录成功后
 *               2.主动调用切换清晰度方法
 *               3.主动调用切换视频模式回调
 */
- (void)HDReceivedVideoQuality:(NSDictionary *)dict {
    self.qualityMetaData = [dict copy];
    /** 清晰度列表 */
    NSArray *qualityList = dict[@"qualityList"];
    self.secRoadArr = qualityList;
    /** 当前的清晰度 */
    HDQualityModel *qualityModel = dict[@"currentQuality"];
    if (self.qualitySelectedArray.count > 0) {
        HDPlayerBaseModel *model = [[HDPlayerBaseModel alloc]init];
        model.value = qualityModel.quality;
        model.desc = qualityModel.desc;
        model.func = HDPlayerBaseQuality;
        [self.qualitySelectedArray replaceObjectAtIndex:0 withObject:model];
    }else {
        [self.qualitySelectedArray removeAllObjects];
        HDPlayerBaseModel *model = [[HDPlayerBaseModel alloc]init];
        model.value = qualityModel.quality;
        model.desc = qualityModel.desc;
        model.func = HDPlayerBaseQuality;
        [self.qualitySelectedArray addObject:model];
    }
    [self.qualityBtn setTitle:qualityModel.desc forState:UIControlStateNormal];
}
/**
 *    The New Method (3.13.0)
 *    @brief    房间包含的音视频线路 (会多次回调)
 *    @param    dict   线路数据
 *    线路数据   key(包含的键值)             type(数据类型)             description(描述)
 *              lineList(线路列表)         array                     @[@"line1",@"line2"]
 *              indexNum(当前线路下标)      integer                   0
 *
 *    触发回调条件 1.初始化SDK登录成功后
 *               2.主动调用切换清晰度方法
 *               3.主动调用切换线路方法
 *               4.主动调用切换音视频模式回调
 */
- (void)HDReceivedVideoAudioLines:(NSDictionary *)dict {
    self.lineMetaData = [dict copy];
    /** 所有的线路数据 */
    NSArray *lineList = dict[@"lineList"];
    [self.lineArray removeAllObjects];
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    param[@"lines"] = [self getLineDespWithNum:lineList.count];
    param[@"hasAudio"] = @(self.isAudioMode == YES ? YES : NO);
    [self.lineArray addObject:param];
    /** 当前选择线路 */
    NSInteger index = [dict[@"indexNum"] integerValue];
    if (self.lineSelectedArray.count > 0) {
        HDPlayerBaseModel *model = [[HDPlayerBaseModel alloc]init];
        model.value = [[NSString alloc]initWithFormat:@"%zd",index];
        model.index = index;
        model.func = self.isSound == YES ? HDPlayerBaseAudioLine : HDPlayerBaseVideoLine;
        [self.lineSelectedArray replaceObjectAtIndex:0 withObject:model];
    }else {
        [self.lineSelectedArray removeAllObjects];
        HDPlayerBaseModel *model = [[HDPlayerBaseModel alloc]init];
        model.value = [[NSString alloc]initWithFormat:@"%zd",index];;
        model.index = index;
        model.func = self.isSound == YES ? HDPlayerBaseAudioLine : HDPlayerBaseVideoLine;
        [self.lineSelectedArray addObject:model];
    }
}
/**
 *    @brief    根据线路数初始化线路文字
 *    @param    num   线路数
 *
 *    @return   显示数
 */
- (NSArray *)getLineDespWithNum:(NSInteger)num
{
    NSArray *array = @[];
    switch (num) {
        case 1:
            array = @[@"线路1"];
            break;
        case 2:
            array = @[@"线路1",@"线路2"];
            break;
        case 3:
            array = @[@"线路1",@"线路2",@"线路3"];
            break;

        default:
            break;
    }
    return array;
}

- (NSMutableArray *)lineArray {
    if (!_lineArray) {
        _lineArray = [NSMutableArray array];
    }
    return _lineArray;
}

- (NSMutableArray *)lineSelectedArray {
    if (!_lineSelectedArray) {
        _lineSelectedArray = [NSMutableArray array];
    }
    return _lineSelectedArray;
}

- (NSMutableArray *)qualitySelectedArray {
    if (!_qualitySelectedArray) {
        _qualitySelectedArray = [NSMutableArray array];
    }
    return _qualitySelectedArray;
}

- (NSMutableArray *)rateSelectedArray {
    if (!_rateSelectedArray) {
        _rateSelectedArray = [NSMutableArray array];
    }
    return _rateSelectedArray;
}

#pragma mark - 回放打点

- (NSMutableArray *)dotsInfoArray {
    if (!_dotsInfoArray) {
        _dotsInfoArray = [NSMutableArray array];
    }
    return _dotsInfoArray;
}

- (void)HDReplayDotList:(NSArray *)dotList {
    if (dotList.count > 0) {
        [self.dotsInfoArray removeAllObjects];
        for (HDReplayDotModel *dotModel in dotList) {
            VideoDotInfo *dot = [[VideoDotInfo alloc]init];
            dot.desc = dotModel.desc;
            dot.time = (int)dotModel.time;
            [self.dotsInfoArray addObject:dot];
        }
    }
}
/**
 *    @brief    展示打点信息
 */
- (void)showDotList {
    UIImage *image = [UIImage imageNamed:@"replay_dot_play"];
    int totalTime = [self secondWithTimeString:self.rightTimeLabel.text];
    if (totalTime == 0) return;
    CGFloat margin = IS_IPHONE_X ? 44 : 0;
    CGFloat x = margin + 20;
    CGFloat barHeight = 64;
    CGFloat y = SCREEN_HEIGHT - barHeight + 11.5;
    CGFloat endX = SCREEN_WIDTH - margin - 20;
    WS(ws)
    _dotEngine = [[VideoDotEngine alloc]initWithDots:self.dotsInfoArray seekBTNImg:image boardView:self.controlView startX:x endX:endX axisY:y totalTime:totalTime seekClosure:^(int time) {
        //NSLog(@"🟣 seek to time %i", time);
        [ws dotTapSeekToTime:time];
    } isShowClosure:^(BOOL isShow) {
        //NSLog(@"🟣 is Show %ld", (long)isShow);
        ws.isShowVideoDotTipView = isShow;
    }];
    [_dotEngine configureDots];
}

- (void)dotTapSeekToTime:(int)time {
    if (time == 0) {
        [self replayBtnClick];
    }else {
        self.slider.value = time;
        NSString *seekTimeStr = [self timeFormatted:time];
        _leftTimeLabel.text = [NSString stringWithFormat:@"%@",seekTimeStr];
        self.sliderCallBack(time);
        [self resetReplayState];
    }
}

/**
 *    @brief    仅有视频模式
 *    @param    isOnlyVideoMode   YES 仅有视频 NO 视频和文档
 */
- (void)setIsOnlyVideoMode:(BOOL)isOnlyVideoMode
{
    _isOnlyVideoMode = isOnlyVideoMode;
    self.changeButton.tag = _isOnlyVideoMode == YES ? 1 : 2;
}
/**
 *    @brief    视频播放失败
 */
- (void)playback_loadVideoFail
{
    
}

#pragma mark - 重播
/**
 *    @brief    播放完成
 *    @param    playDone   playDone 播放完成
 */
- (void)setPlayDone:(BOOL)playDone
{
    _playDone = playDone;
    _slider.userInteractionEnabled = playDone == YES ? NO : YES;
    if (_replayView.hidden == YES && playDone == YES) {
        // 播放完成回调控制器 已播放完成
        if ([self.delegate respondsToSelector:@selector(playDone)]) {
            [self.delegate playDone];
        }
        [_pauseButton setImage:[UIImage imageNamed:@"video_replay1"] forState:UIControlStateNormal];
        _replayView.hidden = NO;
        [self bringSubviewToFront:_replayView];
        [self bringSubviewToFront:_controlView];
    }else {
        _replayView.hidden = playDone == YES ? NO : YES;
        _pauseButton.selected = NO;
        
        [_pauseButton setImage:[UIImage imageNamed:@"video_pause"] forState:UIControlStateNormal];
    }
}
/**
 *    @brief    重播按钮点击事件
 */
- (void)replayBtnClick
{
    _dragTime = 0;
    _slider.value = _dragTime;
    if(_dragTime == 0) {
        _sliderValue = _dragTime;
    }
    NSString *seekTimeStr = [self timeFormatted:_dragTime];
    _leftTimeLabel.text = [NSString stringWithFormat:@"%@",seekTimeStr];
    //滑块完成回调
    //    self.sliderCallBack(_dragTime);
    if (self.replayBtnTapClosure) {
        self.replayBtnTapClosure();
    }
    //[_pauseButton setImage:[UIImage imageNamed:@"video_pause"] forState:UIControlStateNormal];
    //重置重播状态
    [self resetReplayState];
}
/**
 *    @brief    重置重播状态
 */
- (void)resetReplayState
{
    if (_replayView.hidden != YES) {    
        _replayView.hidden = YES;
        [_pauseButton setImage:[UIImage imageNamed:@"video_pause"] forState:UIControlStateNormal];
        _playDone = NO;
    }
}

#pragma mark - 拖动手势操作
- (void)dragAction:(UIPanGestureRecognizer *)pan
{
    /// 4.1.0 new
    if (_isTrialEnd) {
        
        return;
    }
    if (self.isShowToolView == YES) return;
    //播放完成 视频总时长回调完成前 禁止拖动
    int totalTime = [self secondWithTimeString:self.rightTimeLabel.text];
    if (_playDone == YES || totalTime == 0) {
        _draggingShadowView.hidden = _draggingShadowView.hidden == NO ? YES : YES;
        return;
    }
    //是否允许拖动
    if (_isAllowDragging == NO) return;
    
    CGPoint velocity = [pan velocityInView:pan.view];
    //滑动滚动开始
    if (pan.state == UIGestureRecognizerStateBegan) {
        _isDragging = YES;
        [self showOrHiddenShadowView];
        if (_draggingShadowView) {
            _draggingShadowView.hidden = YES;
        }
        
        //当前播放时间(秒)
        self.dragTime = [self secondWithTimeString:self.leftTimeLabel.text];
        self.draggingShadowView.alpha = 1;
        self.draggingShadowView.hidden = NO;
        [self bringSubviewToFront:self.draggingShadowView];
        self.dragTimeLabel.hidden = NO;
        [self bringSubviewToFront:self.dragTimeLabel];
        
    //滑动滚动中
    }else if (pan.state == UIGestureRecognizerStateChanged) {
        
        //跳转时间 根据滑动 水平方向滑动速度 / 40 计算
        _dragTime += velocity.x / 40;
        if (_dragTime < 0) {
            _dragTime = 0;
        }
        //获取总时间(秒)
        int totalTime = [self secondWithTimeString:self.rightTimeLabel.text];
        if (totalTime == 0) {
            _draggingShadowView.alpha = 0;
            _draggingShadowView.hidden = YES;
            _leftTimeLabel.text = @"00:00";
            return;
        }
            
        if (self.dragTime > totalTime) self.dragTime = totalTime;
        //根据移动速度的方向判断是否是 横向滑动
        CGFloat x = fabs(velocity.x);
        CGFloat y = fabs(velocity.y);
        if (x < y) return;
        //拖动中 shadowView(阴影)时间显示
        /// 4.1.0 new
        if (_dragTime > self.trialEndDuration && self.trialEndDuration > 0) {
            _dragTime = self.trialEndDuration;
        }
        NSString *seekTimeStr = [self timeFormatted:_dragTime];
        NSString *totalTimeStr = self.rightTimeLabel.text;
        NSString *showSeekString = [NSString stringWithFormat:@"%@/%@",seekTimeStr,totalTimeStr];
        NSRange range = [showSeekString rangeOfString:@"/"];
        //获取"/"之前的 当前时间 范围
        NSRange range1 = NSMakeRange(0, range.location);
        NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc]initWithString:showSeekString];
        [attributedText addAttribute:NSForegroundColorAttributeName value:CCRGBColor(255,102,51) range:range1];
        _dragTimeLabel.attributedText = attributedText;
        
        //更新底部工具栏当前显示时间
        _leftTimeLabel.text = [NSString stringWithFormat:@"%@",seekTimeStr];
        if (_pauseButton.selected == NO) {
            _pauseButton.selected = YES;
            [_pauseButton setImage:[UIImage imageNamed:@"video_play"] forState:UIControlStateSelected];
        }
        
        _slider.value = _dragTime;
        //滑块移动回调
        self.sliderMoving();
    
    //滑动滚动结束
    }else if (pan.state == UIGestureRecognizerStateEnded) {
        
        //隐藏拖动蒙版view
        if (_draggingShadowView) {
            self.dragTimeLabel.hidden = YES;
            [UIView animateWithDuration:0.5 animations:^{
                self.draggingShadowView.alpha = 0;
                self.draggingShadowView.hidden = YES;
            }];
        }
        //更新当前播放时间
        NSString *seekTimeStr = [self timeFormatted:_dragTime];
        _leftTimeLabel.text = [NSString stringWithFormat:@"%@",seekTimeStr];

        /// 4.1.0 new
        if (_dragTime > self.trialEndDuration && self.trialEndDuration > 0) {
            _dragTime = self.trialEndDuration;
        }
        _slider.value = _dragTime;
        if(_dragTime == 0) {
            _sliderValue = 0;
        }
        //滑块完成回调
        self.sliderCallBack(_dragTime);
        _dragTime = 0;
        
        _isDragging = NO;
        
        [self showOrHiddenShadowView];
    }
}

/**
 *    @brief    将时间字符串转成秒
 *    @param    timeStr    时间字符串  例:@"01:00:
 */
- (int)secondWithTimeString:(NSString *)timeStr
{
    if ([timeStr rangeOfString:@":"].length == 0) {
        return 0;
    }
    int second = 0;
    NSRange range = [timeStr rangeOfString:@":"];
    int minute = [[timeStr substringToIndex:range.location] intValue];
    int sec = [[timeStr substringFromIndex:range.location + 1] intValue];
    second = minute * 60 + sec;
    return second;
}

/**
 *    @brief    秒转分秒字符串
 *    @param    totalSeconds   秒数
 */
- (NSString *)timeFormatted:(int)totalSeconds
{
    int seconds = totalSeconds % 60;
    int minutes = totalSeconds / 60;
    return [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
}

- (void)addSmallView {
    [APPDelegate.window addSubview:_smallVideoView];
}
#pragma mark - btn点击事件
/**
 *    @brief    点击暂停和继续
 */
- (void)pauseButtonClick {
    /// 4.1.0 new
    if (_isTrialEnd) {
         
        return;
    }
    
    _isUserTouching = YES;
    if (_playDone == YES) {
        [self replayBtnClick];
    }else {
        if (self.pauseButton.selected == NO) {
            self.pauseButton.selected = YES;
            self.pausePlayer(YES);
        } else if (self.pauseButton.selected == YES){
            self.pauseButton.selected = NO;
            self.pausePlayer(NO);
        }
    }
}


- (void)showTipInfosWithTitle:(NSString *)title {
    if (_informationViewPop) {
        [_informationViewPop removeFromSuperview];
    }
    _informationViewPop = [[InformationShowView alloc] initWithLabel:title];
    [APPDelegate.window addSubview:_informationViewPop];
    [_informationViewPop mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(removeInformationViewPop) userInfo:nil repeats:NO];
}

/**
 *    @brief    点击全屏按钮
 */
- (void)quanpingButtonClick:(UIButton *)sender {

    
    if (!sender.selected) {
        sender.selected = YES;
        sender.tag = 2;

        [self quanpingBtnClick];
    } else {
        sender.selected = NO;
        [self backButtonClick:sender];
        sender.tag = 1;
    }
}

/**
 *    @brief    双击文档模拟点击返回按钮
 *    @param    tag   按钮的标签==2 是退出全屏操作
 */
- (void)backBtnClickWithTag:(NSInteger)tag
{
    UIButton *sender = [UIButton buttonWithType:UIButtonTypeCustom];
    sender.tag = tag;
    [self backButtonClick:sender];
    self.backButton.tag = 1;
}

/**
 *    @brief    双击文档模拟点击全屏按钮
 */
- (void)quanpingBtnClick
{
    _isUserTouching = YES;
    //全屏按钮代理
    if (self.delegate) {
        [self.delegate quanpingBtnClicked:_changeButton.tag];
    }
//    CGRect frame = [UIScreen mainScreen].bounds;
    self.backButton.tag = 2;
    [UIApplication sharedApplication].statusBarHidden = YES;
    UIView *view = [self superview];
    [self mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.mas_equalTo(view);
        make.height.mas_equalTo(SCREEN_HEIGHT);
    }];
    [self layoutIfNeeded];
    //隐藏其他视图
    [self layoutUI:YES];
    //smallVideoView
    if (_isSmallDocView) {
        // 1.更换小窗横屏位置
        CGFloat y = CGRectGetMaxY(self.topShadow.frame);
        [self.smallVideoView setFrame:CGRectMake((IS_IPHONE_X ? 44:0), y, 100, 75)];
    }
}

/**
 *    @brief    切换视频和文档
 */
- (void)changeButtonClick:(UIButton *)sender {
    if (_smallVideoView.hidden) {
        UIImage *image = _changeButton.tag == 1 ? PLAY_CHANGEDOC_IMAGE : PLAY_CHANGEVIDEO_IMAGE;
        [_changeButton setImage:image forState:UIControlStateNormal];
        _smallVideoView.hidden = NO;
        return;
    }
    _isUserTouching = YES;
    if (sender.tag == 1) {//切换文档大屏
//        self.isSmallVideoView = YES;
        sender.tag = 2;
        [sender setImage:PLAY_CHANGEVIDEO_IMAGE forState:UIControlStateNormal];
    } else {//切换文档小屏
//        self.isSmallVideoView = NO;
        sender.tag = 1;
        [sender setImage:PLAY_CHANGEDOC_IMAGE forState:UIControlStateNormal];
    }
    if (self.delegate) {
        [self.delegate changeBtnClicked:sender.tag];
    }
    if (self.playDone == YES) {
        [self bringSubviewToFront:_replayView];
    }
    [self bringSubviewToFront:self.controlView];
    if (self.recordHistoryPlayView.hidden != YES) {
        [self bringSubviewToFront:self.recordHistoryPlayView];
    }
}
/**
 *    @brief    结束直播和退出全屏
 */
- (void)backButtonClick:(UIButton *)sender {
    self.backButton.userInteractionEnabled = NO;
    UIView *view = [self superview];
    _isUserTouching = YES;
    if (sender.tag == 2) {//横屏返回竖屏
        sender.tag = 1;
        [self endEditing:NO];
        /// 4.5.1 new
//        [self turnPortrait];
        self.quanpingButton.selected = NO;
        if (self.delegate) {
            [self.delegate backBtnClicked:_changeButton.tag];
        }
        [self mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.right.mas_equalTo(view);
            make.height.mas_equalTo(HDGetRealHeight);
            make.top.mas_equalTo(view).offset(SCREEN_STATUS);
        }];
        [self layoutIfNeeded];
        /// 4.5.1 new
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.35 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.smallVideoView setFrame:CGRectMake(self.frame.size.width - 110, HDGetRealHeight + 41 + (IS_IPHONE_X ? 44 : 20), 100, 75)];
        });
        [self layoutUI:NO];
    }else if( sender.tag == 1){//结束直播
        [self creatAlertController_alert];
    }
}

/**
 *    @brief    playerView 触摸事件 （直播文档模式，文档手势冲突）
 *    @param    point   触碰当前区域的点
 */
- (nullable UIView *)hitTest:(CGPoint)point withEvent:(nullable UIEvent *)event
{
    // 每次触摸事件 此方法会进行两次回调，_showShadowCountFlag 标记第二次回调处理事件
    _showShadowCountFlag++;
    CGFloat selfH = self.frame.size.height;
    if (point.y > 0 && point.y <= self.topShadow.size.height) { //过滤掉顶部shadowView
        if (_showShadowCountFlag == 2) {
            _isAllowDragging = NO;//禁止拖动
            _showShadowCountFlag = 0;
        }
        return [super hitTest:point withEvent:event];
    }else if (point.y >= selfH - self.bottomShadow.size.height && point.y <= selfH) { //过滤掉底部shadowView
        if (_showShadowCountFlag == 2) {
            _isAllowDragging = NO;//禁止拖动
            _showShadowCountFlag = 0;
        }
        return [super  hitTest:point withEvent:event];
    }else {
        if (self.isShowVideoDotTipView == YES) {
            if (_showShadowCountFlag == 2) {
                _isAllowDragging = NO;//禁止拖动
                _showShadowCountFlag = 0;
            }
            return [super hitTest:point withEvent:event];
        }
        if (_showShadowCountFlag == 2) {
            _isAllowDragging = YES;//允许拖动
            if (_isDragging == YES) {
                _isHiddenShadowView = NO;
            }else {
                _isHiddenShadowView = _isHiddenShadowView == NO ? YES : NO;
            }
            [self showOrHiddenShadowView];
            _showShadowCountFlag = 0;
        }
        return [super hitTest:point withEvent:event];
    }
}


/**
 *    @brief    创建提示窗
 */
- (void)creatAlertController_alert {
    //设置提示弹窗
    WS(weakSelf)
    CCAlertView *alertView = [[CCAlertView alloc] initWithAlertTitle:ALERT_EXITPLAYBACK sureAction:SURE cancelAction:CANCEL sureBlock:^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf exitPlayBack];
            weakSelf.backButton.enabled = NO;
            [weakSelf.recordHistoryPlayView removeFromSuperview];
        });
    }];
    [APPDelegate.window addSubview:alertView];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        weakSelf.backButton.userInteractionEnabled = YES;
    });
}
/**
 *    @brief    退出直播回放
 */
- (void)exitPlayBack {
    if (self.smallVideoView) {
        [self.smallVideoView removeFromSuperview];
    }
    [self stopPlayerTimer];

    if (self.exitCallBack) {
        self.exitCallBack();//退出回放回调
        self.backButton.enabled = YES;
    }
}
/**
 *    @brief    显示视频加载中样式
 */
- (void)showLoadingView {
    if (_loadingView) {
        return;
    }
    _loadingView = [[LoadingView alloc] initWithLabel:PLAY_LOADING centerY:YES];
    [self addSubview:_loadingView];
    [_loadingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(50, 0, 0, 0));
    }];
    [_loadingView layoutIfNeeded];
}

/**
 *    @brief    移除视频加载中样式
 */
- (void)removeLoadingView {
    if(_loadingView) {
        [_loadingView removeFromSuperview];
        _loadingView = nil;
    }
}
/**
 *    @brief    移除提示信息
 */
-(void)removeInformationViewPop {
    [_informationViewPop removeFromSuperview];
    _informationViewPop = nil;
}
/**
 *    @brief    移除定时器
 */
-(void)stopPlayerTimer {
    if([self.playerTimer isValid]) {
        [self.playerTimer invalidate];
        self.playerTimer = nil;
    }
}

- (UIView *)recordHistoryPlayView
{
    if (!_recordHistoryPlayView) {
        _recordHistoryPlayView = [[UIView alloc]init];
        _recordHistoryPlayView.backgroundColor = CCRGBAColor(51, 51, 51, 1);
        _recordHistoryPlayView.alpha = 0.7;
        _recordHistoryPlayView.layer.cornerRadius = 17.5;
        _recordHistoryPlayView.layer.masksToBounds = YES;
        _recordHistoryPlayView.hidden = YES;
    }
    return _recordHistoryPlayView;
}

- (UIButton *)recordHistoryPlayJumpBtn
{
    if (!_recordHistoryPlayJumpBtn) {
        _recordHistoryPlayJumpBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_recordHistoryPlayJumpBtn setTitle:@"跳转" forState:UIControlStateNormal];
        [_recordHistoryPlayJumpBtn setTitleColor:CCRGBAColor(255,102,51,1) forState:UIControlStateNormal];
        [_recordHistoryPlayJumpBtn.titleLabel setFont:[UIFont systemFontOfSize:13]];
        [_recordHistoryPlayJumpBtn addTarget:self action:@selector(jumpHistory:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _recordHistoryPlayJumpBtn;
}

- (void)jumpHistory:(UIButton *)sender {
    self.slider.value = _recordHistoryTime;
    NSString *seekTimeStr = [self timeFormatted:_recordHistoryTime];
    _leftTimeLabel.text = [NSString stringWithFormat:@"%@",seekTimeStr];
    self.sliderCallBack(_recordHistoryTime);
}

- (void)showRecordHistoryPlayViewWithRecordHistoryTime:(int)time
{
    WS(weakSelf)
    _recordHistoryTime = time;
    NSString *timeStr = [self timeFormatted:time];
    [self addSubview:self.recordHistoryPlayView];
    _recordHistoryPlayView.hidden = NO;
    CGFloat offset = _isShowLandRate == YES ? (IS_IPHONE_X ? 44 : 0) : 0;
    [self.recordHistoryPlayView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.bottomShadow.mas_left).offset(offset);
        make.bottom.mas_equalTo(weakSelf.bottomShadow.mas_top);
        make.height.mas_equalTo(35);
    }];

    UILabel *recordLabel = [[UILabel alloc]init];
    recordLabel.text = [[NSString alloc]initWithFormat:@"%@%@",@"您上次看到",timeStr];
    recordLabel.textColor = [UIColor whiteColor];
    recordLabel.alpha = 0.9;
    recordLabel.font = [UIFont systemFontOfSize:12];
    [self.recordHistoryPlayView addSubview:recordLabel];
    [recordLabel mas_makeConstraints:^(MASConstraintMaker *make) {
       make.left.mas_equalTo(self.recordHistoryPlayView).offset(20);
       make.centerY.mas_equalTo(self.recordHistoryPlayView);
    }];

    [self.recordHistoryPlayView addSubview:self.recordHistoryPlayJumpBtn];
    [self.recordHistoryPlayJumpBtn mas_makeConstraints:^(MASConstraintMaker *make) {
       make.top.mas_equalTo(self.recordHistoryPlayView).offset(5);
       make.left.mas_equalTo(recordLabel.mas_right).offset(20);
       make.bottom.mas_equalTo(self.recordHistoryPlayView).offset(-5);
       make.right.mas_equalTo(self.recordHistoryPlayView).offset(-20);
    }];
    
    // 5秒无任何操作自动隐藏历史播放记录
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.recordHistoryPlayView.hidden == NO) {
            [self hiddenRecordHistoryPlayView];
        }
    });
}

- (void)hiddenRecordHistoryPlayView
{
    self.recordHistoryPlayView.hidden = YES;
}

#pragma mark - 隐藏视频小窗
/**
 *    @brief    隐藏小窗视图
 */
- (void)hiddenSmallVideoview {
    _smallVideoView.hidden = YES;
    UIImage *image = _changeButton.tag == 1 ? PLAY_SHOWDOC_IMAGE : PLAY_SHOWVIDEO_IMAGE;
    [_changeButton setImage:image forState:UIControlStateNormal];
//    NSString *title = self.changeButton.tag == 1 ? PLAY_SHOWDOC : PLAY_SHOWVIDEO;
//    [self.changeButton setTitle:title forState:UIControlStateNormal];
}
#pragma mark - 横竖屏旋转
/// 4.5.1 new
///**
// *    @brief    转为横屏
// */
//- (void)turnRight {
//    self.isScreenLandScape = YES;
//    [self interfaceOrientation:UIInterfaceOrientationLandscapeRight];
//    self.isScreenLandScape = NO;
//    [UIApplication sharedApplication].statusBarHidden = YES;
//}
///**
// *    @brief    转为竖屏
// */
//- (void)turnPortrait {
//    self.isScreenLandScape = YES;
//    [self interfaceOrientation:UIInterfaceOrientationPortrait];
//    [UIApplication sharedApplication].statusBarHidden = NO;
//    self.isScreenLandScape = NO;
//}
@end
