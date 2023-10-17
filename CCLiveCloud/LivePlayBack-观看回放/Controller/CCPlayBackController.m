//
//  CCPlayBackController.m
//  CCLiveCloud
//
//  Created by MacBook Pro on 2018/11/20.
//  Copyright © 2018 MacBook Pro. All rights reserved.
//

#import "CCPlayBackController.h"
#import "CCPlayBackView.h"//视频视图
#import "CCSDK/RequestDataPlayBack.h"//sdk
#import "CCSDK/SaveLogUtil.h"//日志
#import "CCPlayBackInteractionView.h"//回放互动视图
#import <CoreTelephony/CTCallCenter.h>
#import <CoreTelephony/CTCall.h>
#import <AVFoundation/AVFoundation.h>
#import "HDSSupportView.h"
#import "Utility.h"
/// 4.5.1 new
#import "AppDelegate.h"
//#ifdef LockView
#import "CCLockView.h"//锁屏
//#endif

#import "HDSLoginErrorManager.h"
#import <HDBaseUtils/HDBaseUtils.h>
#import "UIColor+RCColor.h"
#import "NSString+CCSwitchTime.h"
#import "CCAlertView.h"
#import "HDSPublicTipsView.h"
#import "ObjectExtension.h"
#import <Masonry/Masonry.h>

#define kHDRecordHistory @"HDPlayBackRecordHistoryPlayTime"
/*
 *******************************************************
 *      去除锁屏界面功能步骤如下：                          *
 *  1。command+F搜索   #ifdef LockView                  *
 *                                                     *
 *  2.删除 #ifdef LockView 至 #endif之间的代码            *
 *******************************************************
 */

@interface CCPlayBackController ()<RequestDataPlayBackDelegate,UIScrollViewDelegate, CCPlayBackViewDelegate>

@property (nonatomic,strong)CCPlayBackInteractionView   * interactionView;//互动视图
@property (nonatomic,strong)CCPlayBackView              * playerView;//视频视图
@property (nonatomic,strong)RequestDataPlayBack         * requestDataPlayBack;//sdk
//#ifdef LockView
@property (nonatomic,strong)CCLockView                  * lockView;//锁屏视图
//#endif
@property (nonatomic,assign) BOOL                       pauseInBackGround;//后台是否暂停
@property (nonatomic,assign) BOOL                       enterBackGround;//是否进入后台
@property (nonatomic,copy)  NSString                    * groupId;//聊天分组
@property (nonatomic,copy)  NSString                    * roomName;//房间名

#pragma mark - 文档显示模式
@property (nonatomic,assign)BOOL                          isSmallDocView;//是否是文档小屏
@property (nonatomic,strong)HDMarqueeView               * marqueeView;//跑马灯
@property (nonatomic,strong)NSDictionary                * jsonDict;//跑马灯数据
   
@property (nonatomic, strong)PlayParameter              * parameter;
/** 是否播放完成 */
@property (nonatomic, assign)BOOL                       isPlayDone;
/** 历史播放记录 记录器(连续播放5s才进行记录) */
@property (nonatomic, assign)int                        recordHistoryCount;
/** 历史播放记录时间 */
@property (nonatomic, assign)int                        recordHistoryTime;
/** 是否显示过历史播放记录 */
@property (nonatomic, assign)BOOL                       isShowRecordHistory;
/** 视频总时长 */
@property (nonatomic, assign)double                     videoTotalDuration;
/** 是否是在卡顿 */
@property (nonatomic,assign)BOOL                        isPlayerLoadStateStalled;
/** 播放失败 */
@property (nonatomic,assign)BOOL                        isPlayFailed;
/** 提示窗 */
@property (nonatomic,strong)InformationShowView         *tipView;
/** 视音频模式 */
@property (nonatomic,assign)BOOL                        isAudioMode;
/** 来电处理*/
@property (nonatomic, strong)CTCallCenter               *callCenter;// 来电状态判断
/** 是否已加载总时长 */
@property (nonatomic, assign)BOOL                       isLoadedTotalTime;
/// 流媒体父视图
@property (nonatomic, strong)UIView                     *hds_contentView;
/// 流媒体视图
@property (nonatomic, strong)UIView                     *hds_playerView;
/// 流媒体辅助父视图
@property (nonatomic, strong)UIView                     *hds_headerView;
/// 流媒体辅助视图
@property (nonatomic, strong)HDSSupportView             *supportView;
/// 流媒体辅助视图类型
@property (nonatomic, assign)HDSSupportViewBaseType     supportBaseType;
/// 4.1.0 new 试看时长
@property (nonatomic, assign)NSTimeInterval             trialDuration;
/// 4.1.0 new 试看结束
@property (nonatomic, assign)BOOL                       isTrialEnd;
/// 上次播放时间
@property (nonatomic, assign) NSTimeInterval            lastPlayTime;
@property (nonatomic, assign) NSInteger                 docOrVideoFlag;

/// 单个按钮弹窗
@property (nonatomic, strong) CCAlertView           *singleBtnAlertView;

@property (nonatomic, strong) HDSPublicTipsView        *publicTipsView;

@end

@implementation CCPlayBackController

- (void)onEmojiLoadingResult:(BOOL)result message:(NSString *)message {
    
}

- (void)emojiShowTips:(NSString *)message {
    WS(ws);
    [NSObject cancelPreviousPerformRequestsWithTarget:ws selector:@selector(hiddenTipView) object:nil];
    if (ws.tipView) {
        [ws.tipView removeFromSuperview];
    }
    ws.tipView = [[InformationShowView alloc] initWithLabel:message];
    [APPDelegate.window addSubview:ws.tipView];
    [ws.tipView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    [NSTimer scheduledTimerWithTimeInterval:2.0f target:ws selector:@selector(hiddenTipView) userInfo:nil repeats:NO];
}
- (void)emojiCustomClicked {
    BOOL emojiOK = [self.requestDataPlayBack isEmojiLoadComplete];
    if(!emojiOK) {
        [self emojiShowTips:@"加载中。。。！"];
    }
    NSDictionary *info = @{
        KK_EMOJI_LOAD_RES:@(emojiOK)
    };
    [[NSNotificationCenter defaultCenter]postNotificationName:KK_KB_EMOJI_CUSTOM_CLICKED_RESULT object:nil userInfo:info];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //初始化背景颜色，设置状态栏样式
    self.view.backgroundColor = [UIColor whiteColor];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    /*  设置后台是否暂停 ps:后台支持播放时将会开启锁屏播放器 */
    _pauseInBackGround = NO;
    _isSmallDocView = YES;//是否开启文档
    _supportBaseType = HDSSupportViewBaseTypeNone;//辅助视图类型
    
    _recordHistoryTime = 0;
    _lastPlayTime = 0;
    _recordHistoryCount = 0;
    _isShowRecordHistory = NO;
    _isLoadedTotalTime = NO;
    _isTrialEnd = NO;
    
    [self setupUI];//设置UI布局 
    [self addObserver];//添加通知
    [self integrationSDK];//集成SDK

    [self callCenterObserver];
}

/**
 切换回放,需要重新配置参数
 ps:切换频率不能过快
 */
- (void)changeVideo {
    [self deleteData];
    _pauseInBackGround = YES;
    _isSmallDocView = YES;
    [self setupUI];//设置UI布局
    [self addObserver];//添加通知
    
    UIView *docView = _isSmallDocView ? _playerView.contentView : _playerView.smallVideoView.hdContentView;
    self.hds_contentView = _isSmallDocView ? _playerView.smallVideoView.hdContentView : _playerView.contentView;
    
    PlayParameter *parameter = [[PlayParameter alloc] init];
    parameter.userId = @"";//userId
    parameter.roomId = @"";//roomId
    parameter.recordId = @"";//回放Id
    parameter.viewerName = @"";//用户名
    parameter.token = @"";//密码
    parameter.docParent = docView;//文档小窗
    parameter.docFrame = docView.bounds;//视频位置,ps:起始位置为视频视图坐标
    parameter.PPTScalingMode = 4;//ppt展示模式,建议值为4
    parameter.pauseInBackGround = _pauseInBackGround;//后台是否暂停
    parameter.defaultColor = @"#FFFFFF";//ppt默认底色，不写默认为白色
    parameter.scalingMode = 1;//屏幕适配方式
    parameter.pptInteractionEnabled = YES;
    _requestDataPlayBack = [[RequestDataPlayBack alloc] initSDKWithParameter:parameter succed:^(BOOL succed) {
        
    } player:^(UIView * _Nonnull playerView) {
        
    } failed:^(NSError * _Nullable error, NSString * _Nonnull reason) {
        
    }];
    _requestDataPlayBack.delegate = self;
    [self.playerView showLoadingView];//显示视频加载中提示
}

- (void)deleteData {
    [self.playerView.smallVideoView removeFromSuperview];
    if (_requestDataPlayBack) {
        [_requestDataPlayBack requestCancel];
        _requestDataPlayBack = nil;
    }
    [self removeObserver];
    [self.playerView removeFromSuperview];
    [self.interactionView removeData];
    [self.interactionView removeFromSuperview];
}

//集成SDK
- (void)integrationSDK {
    
    WS(weakSelf)
    UIView *docView = self.isSmallDocView ? self.playerView.contentView : self.playerView.smallVideoView.hdContentView;     //文档父视图
    self.hds_contentView = self.isSmallDocView ? self.playerView.smallVideoView.hdContentView : self.playerView.contentView;//视频父视图
    self.hds_headerView = self.isSmallDocView ? self.playerView.smallVideoView.headerView : self.playerView.headerView;     //辅助父视图
    _parameter = [[PlayParameter alloc] init];
    _parameter.userId = GetFromUserDefaults(PLAYBACK_USERID);//userId
    _parameter.roomId = GetFromUserDefaults(PLAYBACK_ROOMID);//roomId
    _parameter.recordId = GetFromUserDefaults(PLAYBACK_RECORDID);//回放Id
    _parameter.viewerName = GetFromUserDefaults(PLAYBACK_USERNAME);//用户名
    _parameter.token = GetFromUserDefaults(PLAYBACK_PASSWORD);//密码
    _parameter.docParent = docView;//文档视图
    _parameter.docFrame = docView.bounds;//文档视图布局
    _parameter.PPTScalingMode = 4;//ppt展示模式,建议值为4
    _parameter.pauseInBackGround = _pauseInBackGround;//后台是否暂停
    _parameter.defaultColor = @"#FFFFFF";//ppt默认底色，不写默认为白色
    _parameter.scalingMode = 1;//屏幕适配方式
    _parameter.pptInteractionEnabled = YES;
    _parameter.viewerCustomua = @"viewerCustomua"; // 用户自定义UA信息 可选。数据格式：字符串，限制40个字符
    _parameter.viewercustominfo = @"viewercustominfo"; // 用户自定义信息 可选。数据格式：字符串，最大长度200个字符
    _parameter.tpl = 20;
    _requestDataPlayBack = [[RequestDataPlayBack alloc] initSDKWithParameter:_parameter succed:^(BOOL succed) {
        
    } player:^(UIView * _Nonnull playerView) {
        playerView.frame = weakSelf.hds_contentView.bounds;
        [weakSelf.hds_contentView addSubview:playerView];
        if (weakSelf.hds_playerView) {
            [weakSelf.hds_playerView removeFromSuperview];
            weakSelf.hds_playerView = nil;
        }
        weakSelf.hds_playerView = playerView;
        
    } failed:^(NSError * _Nullable error, NSString * _Nonnull reason) {
        
    }];
    _requestDataPlayBack.delegate = self;
    [_playerView showLoadingView];//显示视频加载中提示
    [self setupSupportView];//设置辅助视图
}

// MARK: - 辅助视图
/// 设置辅助视图
- (void)setupSupportView {
    WS(weakSelf)
    if (_supportView) {
        [_supportView removeFromSuperview];
        _supportView = nil;
    }
    self.supportView = [[HDSSupportView alloc]initWithFrame:self.hds_headerView.bounds actionClosure:^{
        [weakSelf.requestDataPlayBack retryReplay];
    }];
    [self.supportView setSupportBaseType:_supportBaseType boardView:self.hds_headerView];
    self.supportView.hidden = YES;
}

/// 更新辅助视图
- (void)updateSupportView {
    if (_supportView.hidden) {
        _supportView.hidden = NO;
    }
    [_supportView setSupportBaseType:_supportBaseType boardView:self.hds_headerView];
}

- (void)onRequestLoginPlaybackSucced {
    
}

- (void)onRequstLoginPlaybackFailed:(NSUInteger)code message:(NSString *)message {
    
    NSString *errorTipString = [HDSLoginErrorManager loginErrorCode:code message:message];
    if (errorTipString.length == 0) {
        errorTipString = [NSString stringWithFormat:@"错误码:%zd",code];
    }
    
    __weak typeof(self) weakSelf = self;
    [self showSingleAlertView:errorTipString closure:^{
        [weakSelf exit];
    }];
}

/// 展示单个按钮的弹窗
/// - Parameters:
///   - titleStr: 展示信息
///   - closure: 后续操作
- (void)showSingleAlertView:(NSString *)titleStr closure:(void(^)(void))closure {
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (weakSelf.singleBtnAlertView) {
            [weakSelf.singleBtnAlertView removeFromSuperview];
            weakSelf.singleBtnAlertView = nil;
        }
        weakSelf.singleBtnAlertView = [[CCAlertView alloc] initWithAlertTitle:titleStr sureAction:SURE cancelAction:nil sureBlock:^{
            if (closure) {
                closure();
            }
        }];
        [APPDelegate.window addSubview:weakSelf.singleBtnAlertView];
    });
}

#pragma mark - 必须实现的代理方法
/// 媒体准备完成
- (void)mediaPrepared {
    
}
/**
 *    @brief    登录请求失败
 */
- (void)requestFailed:(NSError *)error reason:(NSString *)reason {
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *message = nil;
        if (reason == nil) {
            message = [error localizedDescription];
        } else {
            message = reason;
        }
        NSArray *subviews = [APPDelegate.window subviews];
        // 如果没有子视图就直接返回
        if ([subviews count] == 0) return;
        for (UIView *subview in subviews) {
            if ([[subview class] isEqual:[CCAlertView class]]) {
                [subview removeFromSuperview];
            }
        }
        if ([message isEqualToString:@"加载视频超时，请重试"] || [message isEqualToString:@"加载加密视频超时，请重试"]) {
            [weakSelf showTipInfomationWithTitle:message];
        } else {
            CCAlertView *alertView = [[CCAlertView alloc] initWithAlertTitle:message sureAction:ALERT_SURE cancelAction:nil sureBlock:nil];
            [APPDelegate.window addSubview:alertView];
        }
    });
}

#pragma mark-----------------------功能代理方法 用哪个实现哪个-------------------------------
/// 试看时长
/// @param trialDuration 时长 trialDuration >= 1 代表有 试看时长 < 1 表示没有试看时长
- (void)onTrialDuration:(NSTimeInterval)trialDuration {
    if (trialDuration >= 1) {
        _trialDuration = trialDuration;
    }
}

/**
 *    @brief    播放器准备完成 (会多次回调)
 */
- (void)HDMediaPlaybackIsPreparedToPlayDidChange:(NSDictionary *)dict {
    
}
/**
 *    @brief    视频状态改变
 *    @param    state
 *              HDSMediaPlaybackStateStopped          播放停止
 *              HDSMediaPlaybackStatePlaying          开始播放
 *              HDSMediaPlaybackStatePaused           暂停播放
 *              HDSMediaPlaybackStateInterrupted      播放间断
 *              HDSMediaPlaybackStateSeekingForward   播放快进
 *              HDSMediaPlaybackStateSeekingBackward  播放后退
 */
- (void)HDSMediaPlayBackStateDidChange:(HDSMediaPlaybackState)state {
    WS(weakSelf)
    switch (state) {
        case HDSMediaPlaybackStateStopped: {
//            if (self.playerView.pauseButton.selected == NO) {
//                self.playerView.pauseButton.selected = YES;
//            }
        } break;
        case HDSMediaPlaybackStatePlaying: {
            //#ifdef LockView
            if (_pauseInBackGround == NO) {//后台支持播放
                [self setLockView];//设置锁屏界面
            }
            //#endif
            if (_isTrialEnd == YES) {
                _playerView.isTrialEnd = _isTrialEnd;
                return;
            }
            if (self.isPlayDone == YES) {
                self.playerView.playDone = NO;
                self.isPlayDone = NO;
            }
            
            if (self.playerView.pauseButton.selected == YES) {
                self.playerView.pauseButton.selected = NO;
            }
            /// 4.1.0 new
            if (_trialDuration > 0) {
                _playerView.trialEndDuration = _trialDuration;
            }
            self.lastPlayTime = 0;
            self.isPlayerLoadStateStalled = NO;
            self.isPlayFailed = NO;
            if (_supportView && _supportView.hidden == NO && !_isAudioMode) {
                _supportBaseType = HDSSupportViewBaseTypeNone;
                _supportView.hidden = YES;
            }
            if (_playerView.loadingView) {
                [_playerView.loadingView removeFromSuperview];
            }
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{            
                if (weakSelf.isShowRecordHistory == NO) {
                    int time = [weakSelf readRecordHistoryPlayTime];
                    if (time > 0) {
                        [weakSelf.playerView showRecordHistoryPlayViewWithRecordHistoryTime:time];
                        weakSelf.isShowRecordHistory = YES;
                    }
                }
            });
            break;
        }
        case HDSMediaPlaybackStatePaused: {
            if (self.playerView.pauseButton.selected == NO) {
                self.playerView.pauseButton.selected = YES;
            }
            if(self.playerView.pauseButton.selected == YES && [_requestDataPlayBack isPlaying]) {
                [_requestDataPlayBack pausePlayer];
            }
            if(self.playerView.loadingView && ![self.playerView.timer isValid]) {
                [self.playerView removeLoadingView];//移除加载视图
                /* 当视频被打断时，重新开启视频需要校对时间 */
                if (_playerView.slider.value != 0) {
                    /// 4.1.0 new 试看结束
                    if (_trialDuration > 0) {
                        _requestDataPlayBack.currentPlaybackTime = _trialDuration;
                        return;
                    }
                    _requestDataPlayBack.currentPlaybackTime = _playerView.slider.value;
                    return;
                }
            }
            break;
        }
        case HDSMediaPlaybackStateInterrupted:
            break;
        case HDSMediaPlaybackStateSeekingForward:
            break;
        case HDSMediaPlaybackStateSeekingBackward:
            break;
        default:
            break;
    }
}
/**
 *    @brief    视频加载状态
 *    @param    state   播放状态
 *              HDSMediaLoadStateUnknown         未知状态
 *              HDSMediaLoadStatePlayable        视频未完成全部缓存，但已缓存的数据可以进行播放
 *              HDSMediaLoadStatePlaythroughOK   缓冲已经完成
 *              HDSMediaLoadStateStalled         缓冲已经开始
 */
- (void)HDSMediaLoadStateDidChange:(HDSMediaLoadState)state {
    switch (state) {
        case HDSMediaLoadStateUnknown:
            break;
        case HDSMediaLoadStatePlayable:
            break;
        case HDSMediaLoadStatePlaythroughOK:
            break;
        case HDSMediaLoadStateStalled: {
            self.isPlayerLoadStateStalled = YES;
        } break;
        default:
            break;
    }
}
/**
 *    @brief    视频播放完成原因
 *    @param    reason  原因
 *              HDSMediaFinishReasonPlaybackEnded    自然播放结束
 *              HDSMediaFinishReasonUserExited       用户人为结束
 *              HDSMediaFinishReasonPlaybackError    发生错误崩溃结束
 */
- (void)HDSMediaPlayerPlaybackDidFinish:(HDSMediaFinishReason)reason {
    switch (reason) {
        case HDSMediaFinishReasonPlaybackEnded: {
            self.playerView.playDone = YES;
        } break;
        case HDSMediaFinishReasonUserExited:
            break;
        case HDSMediaFinishReasonPlaybackError: {
            self.isPlayFailed = YES;
            self.supportBaseType = HDSSupportViewBaseTypePlayError;
            [self updateSupportView];
        } break;
        default:
            break;
    }
}

/**
 *  @brief  加载视频失败
 */
- (void)playback_loadVideoFail {
    self.isPlayFailed = YES;
    self.supportBaseType = HDSSupportViewBaseTypePlayError;
    [self updateSupportView];
}

/**
 *    @brief   回放翻页数据列表
 *    @param   array [{ docName         //文档名
                        pageTitle       //页标题
                        time            //时间
                        url             //地址 }]
 */
- (void)pageChangeList:(NSMutableArray *)array {
    
}
/**
 *    @brief    翻页同步之前的文档展示模式
 */
- (void)onPageChange:(NSDictionary *)dictionary {
    
}

- (void)videoStateChangeWithString:(NSString *)result {

}

/**
 *    @brief    读取历史播放记录
 */
- (int)readRecordHistoryPlayTime {
    int time = 0;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *dict = [userDefaults objectForKey:kHDRecordHistory];
    // 1.本地有历史播放记录
    if (![dict isKindOfClass:[NSNull class]]) {
        // 2.是同一个回放
        if ([_parameter.recordId isEqualToString:dict[@"recordId"]]) {
            time = [dict[@"time"] intValue];
        }
    }
    
    return time;
}

/**
 *    @brief    存储历史播放记录
 */
- (void)saveRecordHistoryPlayTime {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *saveDict = [NSMutableDictionary dictionary];
    NSDictionary *dict = [userDefaults objectForKey:kHDRecordHistory];
    // 1.本地有历史播放记录
    if (![dict isKindOfClass:[NSNull class]]) {
        // 2.是同一个回放
        if ([_parameter.recordId isEqualToString:dict[@"recordId"]]) {
            saveDict[@"time"] = @(self.recordHistoryTime);
            saveDict[@"recordId"] = dict[@"recordId"];
            
        }else {
            //2.不是同一个回放
            saveDict[@"recordId"] = _parameter.recordId;
            saveDict[@"time"] = @(self.recordHistoryTime);
            
        }
    }else {
        //1.本地无历史播放记录数据
        saveDict[@"recordId"] = _parameter.recordId;
        saveDict[@"time"] = @(self.recordHistoryTime);
        
    }
    [userDefaults setObject:saveDict forKey:kHDRecordHistory];
    [userDefaults synchronize];
}

#pragma mark - 播放器时间
/**
 *    @brief    播放器时间
 *    @param    currentTime   当前时间
 *    @param    totalTime     总时间
 */
- (void)HDPlayerCurrentTime:(NSTimeInterval)currentTime totalTime:(NSTimeInterval)totalTime {
    // 记录视频总时长
    self.videoTotalDuration = totalTime;
    if([_requestDataPlayBack isPlaying]) {
        [self.playerView removeLoadingView];
    }
    
    /// 4.1.0 new 试看时长
    if (currentTime >= _trialDuration && _trialDuration >= 1) {
        [_requestDataPlayBack pausePlayer];
        _isTrialEnd = YES;
        _playerView.isTrialEnd = _isTrialEnd;
        _playerView.slider.value = currentTime;
        [self parseChatOnTime:currentTime];
        //更新左侧label
        self.playerView.leftTimeLabel.text = [NSString stringWithFormat:@"%02d:%02d", (int)(currentTime / 60), (int)(currentTime) % 60];
        self.supportBaseType = HDSSupportViewBaseTypeTrialEnd;
        [self updateSupportView];
        return;
    }
    
    if (self.recordHistoryCount == 5) {
        self.recordHistoryTime = currentTime;
        
        [self saveRecordHistoryPlayTime];
        self.recordHistoryCount = 0;
    }else {
        
        if (currentTime != 0) {
            self.recordHistoryCount++;
        
        }
    }

    WS(ws)
    dispatch_async(dispatch_get_main_queue(), ^{
        //获取当前播放时间和视频总时长
        NSTimeInterval position = (int)round(currentTime);
        NSTimeInterval duration = (int)round(totalTime);
        if (position != 0 && duration > 0 && position >= duration) {
            //ws.playerView.playDone = YES;
        }
        /** 设置plaerView的滑块 */
        ws.playerView.slider.maximumValue = (int)duration;
        /** 更新播放总时长 */
        if (!ws.isLoadedTotalTime && duration > 0) {
            ws.playerView.rightTimeLabel.text = [NSString stringWithFormat:@"%02d:%02d", (int)(duration / 60), (int)(duration) % 60];
            ws.isLoadedTotalTime = YES;
            [ws.playerView updateUITier];
        }
        
        //校对SDK当前播放时间
        if(position == 0 && ws.playerView.sliderValue != 0) {
            /// 4.1.0 new 试看结束
            if (ws.trialDuration > 0) {
                ws.requestDataPlayBack.currentPlaybackTime = ws.trialDuration;
                return;
            }
            ws.requestDataPlayBack.currentPlaybackTime = ws.playerView.sliderValue;
            ws.playerView.slider.value = ws.playerView.sliderValue;
        } else {
            ws.playerView.slider.value = position;
            ws.playerView.sliderValue = ws.playerView.slider.value;
            if (ws.videoTotalDuration - position <= 2) {
                ws.playerView.slider.value = ceil(ws.videoTotalDuration);
                ws.playerView.sliderValue = ceil(ws.videoTotalDuration);
            }
        }
        
        //校对本地显示速率和播放器播放速率
        if ([ws.requestDataPlayBack getMediaRate] != ws.playerView.playBackRate) {
            [ws.requestDataPlayBack setMediaRate:ws.playerView.playBackRate];
            //#ifdef LockView
            //校对锁屏播放器播放速率
            [ws.lockView updatePlayBackRate:[ws.requestDataPlayBack getMediaRate]];
            //#endif
        }
        
        if (ws.playerView.pauseButton.selected == NO && [ws.requestDataPlayBack getMediaRate] == HDSMediaPlaybackStatePaused) {
            //开启播放视频
            [ws.requestDataPlayBack startPlayer];
        }
        
        /*  加载聊天数据 */
        [ws parseChatOnTime:(int)ws.playerView.sliderValue];
        ws.lastPlayTime = ws.playerView.sliderValue;
        //更新左侧label
        ws.playerView.leftTimeLabel.text = [NSString stringWithFormat:@"%02d:%02d", (int)(ws.playerView.sliderValue / 60), (int)(ws.playerView.sliderValue) % 60];
        //#ifdef LockView
        /*  校对锁屏播放器进度 */
        [ws.lockView updateCurrentDurtion:ws.requestDataPlayBack.currentPlaybackTime];
        //#endif
    });
}

#pragma mark - 服务端给自己设置的信息
/**
 *    @brief    服务器端给自己设置的信息(The new method)
 *    groupId 分组id
 *    name 用户名
 */
- (void)setMyViewerInfo:(NSDictionary *) infoDic {
    _groupId = @"";
    _interactionView.groupId = _groupId;
}
/**
 *    @brief     双击ppt
 */
- (void)doubleCllickPPTView {
    /// [修460Bug] 这里干什么的导致死循环了
    /// 38935 在线回放双击切换横竖屏时崩溃
    /// 两个方法m里都注了h里还留着
    if (_playerView.quanpingButton.selected) {//如果是横屏状态下
        /* 横屏转竖屏 */
        _playerView.quanpingButton.selected = NO;
//        [_playerView turnPortrait];
        _interactionView.hidden = NO;
        [_playerView backBtnClickWithTag:2];
    }else{
        /* 竖屏转横屏 */
        _playerView.quanpingButton.selected = YES;
//        [_playerView turnRight];
        _interactionView.hidden = YES;
        [_playerView quanpingBtnClick];
    }
}

- (void)onRoomConfigure:(HDSRoomConfigureModel *)configure {
    
}

#pragma mark- 房间信息
/**
 *    @brief  获取房间信息，主要是要获取直播间模版来类型，根据直播间模版类型来确定界面布局
 *    房间信息
 *
 *    3.16.0 新增
 *
 *    新增参数名称      类型              是否必须        示例
 *    recordInfo      NSDictionary    （非必须）       @{@"title":@"房间标题",@"description":@"简介信息"}
 *
 *    房间模版类型：[dic[@"templateType"] integerValue];
 *    模版类型为1: 聊天互动： 无 直播文档： 无 直播问答： 无
 *    模版类型为2: 聊天互动： 有 直播文档： 无 直播问答： 有
 *    模版类型为3: 聊天互动： 有 直播文档： 无 直播问答： 无
 *    模版类型为4: 聊天互动： 有 直播文档： 有 直播问答： 无
 *    模版类型为5: 聊天互动： 有 直播文档： 有 直播问答： 有
 *    模版类型为6: 聊天互动： 无 直播文档： 无 直播问答： 有
 */
-(void)roomInfo:(NSDictionary *)dic {
    // 3.16.0 new
    if ([dic.allKeys containsObject:@"recordInfo"]) {
        NSDictionary *recordInfo = dic[@"recordInfo"];
        _roomName = @"";
        if ([recordInfo.allKeys containsObject:@"title"]) {
            _roomName = recordInfo[@"title"];
        }else {
            if ([dic.allKeys containsObject:@"baseRecordInfo"]) {
                NSDictionary *baseRecordInfo = dic[@"baseRecordInfo"];
                if ([baseRecordInfo.allKeys containsObject:@"title"]) {
                    _roomName = baseRecordInfo[@"title"];
                }
            }
        }
    }else {
        if ([dic.allKeys containsObject:@"baseRecordInfo"]) {
            NSDictionary *baseRecordInfo = dic[@"baseRecordInfo"];
            _roomName = @"";
            if ([baseRecordInfo.allKeys containsObject:@"title"]) {
                _roomName = baseRecordInfo[@"title"];
            }
        }
    }
    NSInteger type = -1;
    // 回放模板类型
    if ([dic.allKeys containsObject:@"templateType"]) {
        type = [dic[@"templateType"] integerValue];
    }
    // 房间模板类型
    if ([dic.allKeys containsObject:@"template"]) {
        NSDictionary *templateDic = dic[@"template"];
        if ([templateDic.allKeys containsObject:@"type"]) {
            type = [templateDic[@"type"] integerValue];
        }
    }
    if (type == 4 || type == 5) {
        [self.playerView addSmallView];
        self.playerView.isOnlyVideoMode = NO;
    }else {
        [self changeBtnClicked:1];
        self.playerView.isOnlyVideoMode = YES;
        [self docLoadCompleteWithIndex:0];
    }
    //设置房间标题
    self.playerView.titleLabel.text = _roomName;
    self.interactionView.roomName = _roomName;
    //配置互动视图的信息
    [self.interactionView roomInfo:dic playerView:self.playerView];
}
#pragma mark - 切换线路
/**
 *    The New Method (3.13.0)
 *    @brief    是否开启音频模式
 *    @param    hasAudio   HAVE_AUDIO_LINE_TURE 有音频 HAVE_AUDIO_LINE_FALSE 无音频
 *
 *    触发回调条件 1.初始化SDK登录成功后
 */
- (void)HDAudioMode:(HAVE_AUDIO_LINE)hasAudio {
    [self.playerView HDAudioMode:hasAudio];
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
    [self.playerView HDReceivedVideoQuality:dict];
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
    [self.playerView HDReceivedVideoAudioLines:dict];
}

- (void)changePlayMode:(BOOL)isAudio {
    _isAudioMode = isAudio == YES ? YES : NO;
    WS(ws)
    if (isAudio == YES) {
        [_requestDataPlayBack changePlayMode:PLAY_MODE_TYEP_AUDIO completion:^(NSDictionary *results) {
            NSInteger result = [results[@"success"] integerValue];
            [ws showTextWithIndex:result];
            [ws.playerView updateUITier];
            ws.supportBaseType = HDSSupportViewBaseTypeAudio;
        }];
    }else {
        [_requestDataPlayBack changePlayMode:PLAY_MODE_TYEP_VIDEO completion:^(NSDictionary *results) {
            NSInteger result = [results[@"success"] integerValue];
            [ws showTextWithIndex:result];
            [ws.playerView updateUITier];
            ws.supportBaseType = HDSSupportViewBaseTypeNone;
        }];
    }
    [self updateSupportView];
}

/**
 *    @brief    切换线路
 *    @param    rodIndex   线路
 */
- (void)selectedRodWidthIndex:(NSInteger)rodIndex {
    WS(ws)
    [_requestDataPlayBack changeLine:rodIndex completion:^(NSDictionary *results) {
        NSInteger result = [results[@"success"] integerValue];
        [ws showTextWithIndex:result];
        [ws.playerView updateUITier];
        if (ws.isAudioMode == YES) {
            ws.supportBaseType = HDSSupportViewBaseTypeAudio;
            [ws updateSupportView];
        }
    }];
}
/**
 *    @brief    切换清晰度
 *    @param    quality    清晰度
 */
- (void)selectedQuality:(NSString *)quality {
    WS(ws)
    [_requestDataPlayBack changeQuality:quality completion:^(NSDictionary *results) {
        NSInteger result = [results[@"success"] integerValue];
        [ws showTextWithIndex:result];
        [ws.playerView updateUITier];
    }];
}

/**
 *    @brief    展示切换线路结果
 *    @param    result   //0 切换成功 -1切换失败 -2 切换频繁
 */
- (void)showTextWithIndex:(NSInteger)result
{
    NSString *showTitle = @"";
    NSString *index = [NSString stringWithFormat:@"%zd",result];
    if ([index isEqualToString:@"0"]) {
        showTitle = PLAY_MODE_CHANGE_SUCCESS;
    }else if ([index isEqualToString:@"-1"]) {
        showTitle = PLAY_MODE_CHANGE_ERROR;
    }else if ([index isEqualToString:@"-2"]) {
        showTitle = PLAY_MODE_CHANGE_TIMEOUT;
    }
    [self showTipInfomationWithTitle:showTitle];
}

- (void)showPublicTipsView:(NSString *)tips {
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hiddenPublicTipsView) object:nil];
        if (weakSelf.publicTipsView) {
            [weakSelf.publicTipsView removeFromSuperview];
            weakSelf.publicTipsView = nil;
        }
        weakSelf.publicTipsView = [[HDSPublicTipsView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT) tips:tips];
        [APPDelegate.window addSubview:weakSelf.publicTipsView];
        [weakSelf performSelector:@selector(hiddenPublicTipsView) withObject:nil afterDelay:2];
    });
}

- (void)hiddenPublicTipsView {
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf.publicTipsView removeFromSuperview];
        weakSelf.publicTipsView = nil;
    });
}

- (void)showTipInfomationWithTitle:(NSString *)title {
    dispatch_async(dispatch_get_main_queue(), ^{    
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hiddenTipView) object:nil];
        if (self.tipView) {
            [self.tipView removeFromSuperview];
        }
        self.tipView = [[InformationShowView alloc] initWithLabel:title];
        [APPDelegate.window addSubview:self.tipView];
        [self.tipView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
        }];
        [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(hiddenTipView) userInfo:nil repeats:NO];
    });
}

- (void)hiddenTipView {
    if (_tipView) {
        [_tipView removeFromSuperview];
        _tipView = nil;
    }
}

#pragma mark - 回放打点信息
- (void)HDReplayDotList:(NSArray *)dotList {
    [self.playerView HDReplayDotList:dotList];
}

#pragma mark - 跑马灯
- (void)receivedMarqueeInfo:(NSDictionary *)dic {
    if (dic == nil) {
        return;
    }
    self.jsonDict = dic;
    {

        CGFloat width = 0.0;
        CGFloat height = 0.0;
        self.marqueeView = [[HDMarqueeView alloc]init];
        HDMarqueeViewStyle style = [[self.jsonDict objectForKey:@"type"] isEqualToString:@"text"] ? HDMarqueeViewStyleTitle : HDMarqueeViewStyleImage;
        self.marqueeView.style = style;
        self.marqueeView.repeatCount = [[self.jsonDict objectForKey:@"loop"] integerValue];
        if (style == HDMarqueeViewStyleTitle) {
            NSDictionary * textDict = [self.jsonDict objectForKey:@"text"];
            NSString * text = [textDict objectForKey:@"content"];
            UIColor * textColor = [UIColor colorWithHexString:[textDict objectForKey:@"color"] alpha:1.0f];
            UIFont * textFont = [UIFont systemFontOfSize:[[textDict objectForKey:@"font_size"] floatValue]];
            
            self.marqueeView.text = text;
            self.marqueeView.textAttributed = @{NSFontAttributeName:textFont,NSForegroundColorAttributeName:textColor};
            CGSize textSize = [self.marqueeView.text calculateRectWithSize:CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT) Font:textFont WithLineSpace:0];
            width = textSize.width;
            height = textSize.height;
            
        }else{
            NSDictionary * imageDict = [self.jsonDict objectForKey:@"image"];
            NSURL * imageURL = [NSURL URLWithString:[imageDict objectForKey:@"image_url"]];
            self.marqueeView.imageURL = imageURL;
            width = [[imageDict objectForKey:@"width"] floatValue];
            height = [[imageDict objectForKey:@"height"] floatValue];

        }
        self.marqueeView.frame = CGRectMake(0, 0, width, height);
        //处理action
        NSArray * setActionsArray = [self.jsonDict objectForKey:@"action"];
        //跑马灯数据不是数组类型
        if (![setActionsArray isKindOfClass:[NSArray class]]) return;
        NSMutableArray <HDMarqueeAction *> * actions = [NSMutableArray array];
        for (int i = 0; i < setActionsArray.count; i++) {
            NSDictionary * actionDict = [setActionsArray objectAtIndex:i];
            CGFloat duration = [[actionDict objectForKey:@"duration"] floatValue];
            NSDictionary * startDict = [actionDict objectForKey:@"start"];
            NSDictionary * endDict = [actionDict objectForKey:@"end"];

            HDMarqueeAction * marqueeAction = [[HDMarqueeAction alloc]init];
            marqueeAction.duration = duration;
            marqueeAction.startPostion.alpha = [[startDict objectForKey:@"alpha"] floatValue];
            marqueeAction.startPostion.pos = CGPointMake([[startDict objectForKey:@"xpos"] floatValue], [[startDict objectForKey:@"ypos"] floatValue]);
            marqueeAction.endPostion.alpha = [[endDict objectForKey:@"alpha"] floatValue];
            marqueeAction.endPostion.pos = CGPointMake([[endDict objectForKey:@"xpos"] floatValue], [[endDict objectForKey:@"ypos"] floatValue]);
            
            [actions addObject:marqueeAction];
        }
        
        self.marqueeView.actions = actions;
        self.marqueeView.fatherView = self.playerView;
        self.playerView.layer.masksToBounds = YES;
    }
}
#pragma  mark - 文档加载状态
/**
 *    @brief    文档加载状态
 *    index
 *      0 文档组件初始化完成
 *      1 动画文档加载完成
 *      2 非动画翻页加载成功
 *      3 文档组件加载失败
 *      4 非动画翻页加载失败
 *      5 文档动画加载失败
 *      6 画板加载失败
 *      7 极速动画翻页加载成功
 *      8 极速动画翻页加载失败
 */
- (void)docLoadCompleteWithIndex:(NSInteger)index {
    WS(weakSelf)
    if (index == 0) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf.playerView addSubview:weakSelf.marqueeView];
            [weakSelf.marqueeView startMarquee];
        });
    }
}
#pragma mark- 回放的开始时间和结束时间
/**
 *  @brief 回放的开始时间和结束时间
 *  @param dic {endTime     //结束时间
                startTime   //开始时间 }
 */
- (void)liveInfo:(NSDictionary *)dic {
    NSInteger startTime = [NSString timeSwitchTimestamp:dic[@"startTime"] andFormatter:@"yyyy-MM-dd HH:mm:ss"];
    NSString *liveStartTime = [NSString stringWithFormat:@"%zd",startTime];
    SaveToUserDefaults(LIVE_STARTTIME, liveStartTime);
}
#pragma mark - 缓存速度
- (void)onBufferSpeed:(NSString *)speed {
    if (self.isPlayerLoadStateStalled == YES && self.isPlayFailed != YES) {
        if (_supportView) {
            if (_supportView.hidden == YES) {
                _supportView.hidden = NO;
            }
            [_supportView setSpeed:[NSString stringWithFormat:@"%@%@",PLAY_LOADING,speed]];
        }
    }else {
        if (_supportView) {
            [_supportView hiddenSpeed];
        }
    }
}
#pragma mark- 聊天
/**
 *    @brief    解析本房间的历史聊天数据
 */
-(void)onParserChat:(NSArray *)chatArr {
    if ([chatArr count] == 0) {
        return;
    }
    //解析历史聊天
    [self.interactionView onParserChat:chatArr];
}

- (void)receivePracticeWithDic:(NSDictionary *)resultDic {

}

- (void)broadcastHistory_msg:(NSArray *)array {

}
#pragma mark- 问答
/**
 *    @brief  收到提问&回答
 */
- (void)onParserQuestionArr:(NSArray *)questionArr onParserAnswerArr:(NSArray *)answerArr {
    [self.interactionView onParserQuestionArr:questionArr onParserAnswerArr:answerArr];
}

//移除通知
- (void)dealloc {
    /* 自动登录情况下，会存在移除控制器但是SDK没有销毁的情况 */
    if (_requestDataPlayBack) {
        [_requestDataPlayBack requestCancel];
        _requestDataPlayBack = nil;
    }
    [self removeObserver];
}
#pragma mark - 设置UI
/**
 *    @brief    将时间字符串转成秒
 *    @param    timeStr    时间字符串  例:@"01:00:
 */
- (int)secondWithTimeString:(NSString *)timeStr {
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

- (void)exit {
    __weak typeof(self) weakSelf = self;
    [self dismissViewControllerAnimated:YES completion:^{
        [weakSelf.requestDataPlayBack shutdownPlayer];
        [weakSelf.requestDataPlayBack requestCancel];
        weakSelf.requestDataPlayBack = nil;
        weakSelf.playerView.delegate = nil;
        weakSelf.requestDataPlayBack.delegate = nil;
        [weakSelf.interactionView removeFromSuperview];
        weakSelf.interactionView = nil;
        [weakSelf.playerView removeFromSuperview];
        weakSelf.playerView = nil;
    }];
}

/**
 创建UI
 */
- (void)setupUI {
    //添加视频播放视图
    /// 4.5.1 new
    _playerView = [[CCPlayBackView alloc] initWithFrame:CGRectZero docViewType:_isSmallDocView];
    _playerView.screenCaptureSwitch = self.screenCaptureSwitch;
    _playerView.delegate = self;
    WS(weakSelf)
    [weakSelf.requestDataPlayBack cancleTask];
    _playerView.exitCallBack = ^{ //退出直播间回调
        [weakSelf exit];
    };
    
    _playerView.replayBtnTapClosure = ^{
        [weakSelf.requestDataPlayBack replayPlayer];
    };
    
    //滑块滑动完成回调
    _playerView.sliderCallBack = ^(int duration) {
        /// 4.1.0 new 试看结束
        if (weakSelf.trialDuration > 0) {
            weakSelf.requestDataPlayBack.currentPlaybackTime = weakSelf.trialDuration;
            [weakSelf.requestDataPlayBack startPlayer];
            return;
        }
        if (weakSelf.isPlayFailed == YES) {
            weakSelf.playerView.slider.value = weakSelf.lastPlayTime;
            weakSelf.playerView.sliderValue = weakSelf.lastPlayTime;
            weakSelf.playerView.leftTimeLabel.text = [NSString stringWithFormat:@"%02d:%02d", (int)(weakSelf.playerView.sliderValue / 60), (int)(weakSelf.playerView.sliderValue) % 60];
            return;
        }
        // 拖动至视频结尾,视频播放完成
        weakSelf.recordHistoryCount = 0;
        if (duration >= self.videoTotalDuration) {
            weakSelf.requestDataPlayBack.currentPlaybackTime = duration-2;
            [weakSelf.requestDataPlayBack startPlayer];
            weakSelf.playerView.sliderValue = duration;
            return;
        }
        weakSelf.requestDataPlayBack.currentPlaybackTime = duration;
        //#ifdef LockView
        /*  校对锁屏播放器进度 */
        [weakSelf.lockView updateCurrentDurtion:weakSelf.requestDataPlayBack.currentPlaybackTime];
        //#endif
        if ([weakSelf.requestDataPlayBack getMediaPlayStatus] != HDSMediaPlaybackStatePlaying) {
            [weakSelf.requestDataPlayBack startPlayer];
        }
        //隐藏历史播放记录view
        [weakSelf.playerView hiddenRecordHistoryPlayView];
    };
    
    //滑块移动回调
    _playerView.sliderMoving = ^{
        if ([weakSelf.requestDataPlayBack getMediaPlayStatus] != HDSMediaPlaybackStatePaused) {
            [weakSelf.requestDataPlayBack pausePlayer];
        }
    };
    
    //更改播放器速率回调
    _playerView.changeRate = ^(float rate) {
        [weakSelf.requestDataPlayBack setMediaRate:rate];
    };
    
    //暂停/开始播放回调
    _playerView.pausePlayer = ^(BOOL pause) {
        if (pause) {
            [weakSelf.requestDataPlayBack pausePlayer];
        }else{
            [weakSelf.requestDataPlayBack startPlayer];
        }
    };
    
    //切换音视频线路
    _playerView.selectedRod = ^(NSInteger selectedRod) {
        [weakSelf selectedRodWidthIndex:selectedRod];
    };
    
    //切换音视频模式
    _playerView.switchAudio = ^(BOOL result) {
        [weakSelf changePlayMode:result];
    };
    
    //切换清晰度
    _playerView.selectedQuality = ^(NSString * _Nonnull quality) {
        [weakSelf selectedQuality:quality];
    };
    
    [self.view addSubview:self.playerView];
    [self.playerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(SCREEN_STATUS);
        make.left.right.equalTo(self.view);
        make.height.mas_equalTo(HDGetRealHeight);
    }];
    [_playerView layoutIfNeeded];
    
    //添加互动视图
    CGFloat y = HDGetRealHeight+SCREEN_STATUS;
    CGFloat h = SCREEN_HEIGHT - y;
    self.interactionView = [[CCPlayBackInteractionView alloc] initWithFrame:CGRectMake(0, y, SCREEN_WIDTH,h) docViewType:_isSmallDocView];
    [self.view addSubview:self.interactionView];
    [self.interactionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.playerView.mas_bottom);
        make.left.right.mas_equalTo(self.view);
        make.height.mas_equalTo(h);
    }];
    [_interactionView layoutIfNeeded];
}
//#ifdef LockView
/**
 设置锁屏播放器界面
 */
- (void)setLockView {
    if (_lockView) {//如果当前已经初始化，return;
        return;
    }
    _lockView = [[CCLockView alloc] initWithRoomName:_roomName duration:[_requestDataPlayBack playerDuration]];
    [self.view addSubview:_lockView];
    [_requestDataPlayBack setpauseInBackGround:self.pauseInBackGround];
}

//#endif
#pragma mark - playViewDelegate
/**
 全屏按钮点击代理
 
 @param tag 1视频为主，2文档为主
 */
- (void)quanpingBtnClicked:(NSInteger)tag {
    /// 4.5.1 new
    self.docOrVideoFlag = tag;
    [self interfaceOrientation:UIInterfaceOrientationLandscapeRight];
}
/**
 返回按钮点击代理
 
 @param tag 1.视频为主，2.文档为主
 */
- (void)backBtnClicked:(NSInteger)tag {
    /// 4.5.1 new
    self.docOrVideoFlag = tag;
    [self interfaceOrientation:UIInterfaceOrientationPortrait];
}
/**
 切换视频/文档按钮点击回调
 
 @param tag changeBtn的tag值
 */
- (void)changeBtnClicked:(NSInteger)tag {
    
    if (_hds_playerView) {
        [_hds_playerView removeFromSuperview];
    }
    if (tag == 2) {
        [_requestDataPlayBack changeDocParent:self.playerView.contentView];
         [_requestDataPlayBack changeDocFrame:self.playerView.contentView.bounds];
        
        self.hds_contentView = self.playerView.smallVideoView.hdContentView;
        self.hds_contentView.frame = self.playerView.smallVideoView.bounds;
        [self.hds_contentView addSubview:self.hds_playerView];
        self.hds_playerView.frame = self.hds_contentView.bounds;
        self.hds_headerView = self.playerView.smallVideoView.headerView;
        self.hds_headerView.frame = self.playerView.smallVideoView.headerView.bounds;
        self.playerView.headerView.hidden = YES; //修复文档适应宽度情况下文档无法滚动的问题
        
    }else{
        [_requestDataPlayBack changeDocParent:self.playerView.smallVideoView.hdContentView];
        [_requestDataPlayBack changeDocFrame:self.playerView.smallVideoView.hdContentView.bounds];
        
        self.hds_contentView = self.playerView.contentView;
        self.hds_contentView.frame = self.playerView.contentView.bounds;
        [self.hds_contentView addSubview:self.hds_playerView];
        self.hds_playerView.frame = self.hds_contentView.bounds;
        self.hds_headerView = self.playerView.headerView;
        self.hds_headerView.frame = self.playerView.headerView.bounds;
        self.playerView.headerView.hidden = NO; //修复文档适应宽度情况下文档无法滚动的问题
        
    }
    [self.playerView bringSubviewToFront:self.marqueeView];
    [self.playerView updateUITier];
    [self updateSupportView];
}

/**
 隐藏互动视图

 @param hidden 是否隐藏
 */
- (void)hiddenInteractionView:(BOOL)hidden {
    self.interactionView.hidden = hidden;
}

/**
 *    @brief    播放完成
 */
- (void)playDone
{
    self.isPlayDone = YES;
}
/**
 通过传入时间获取聊天信息

 @param time 传入的时间
 */
-(void)parseChatOnTime:(int)time{
    [self.interactionView parseChatOnTime:time];
}
#pragma mark - 添加通知
//通知监听
-(void)addObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appWillEnterBackgroundNotification)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appWillEnterForegroundNotification)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidBecomeActiveNotification)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(emojiCustomClicked)
                                                name:KK_KB_EMOJI_CUSTOM_CLICKED object:nil];

}

//移除通知
-(void) removeObserver {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidEnterBackgroundNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationWillEnterForegroundNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidBecomeActiveNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self];

}

/**
 APP将要进入前台
 */
- (void)appWillEnterForegroundNotification {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        _enterBackGround = NO;
    });
    if (_isTrialEnd) {
        _playerView.isTrialEnd = _isTrialEnd;
        return;
    }
//#ifdef LockView
    /*  当视频播放被打断时，重新加载视频  */
    if (self.isPlayDone == NO) {
        [self.lockView updateLockView];
    }
//#endif
    if (self.playerView.pauseButton.selected == NO && self.isPlayDone != YES) {

    }
}

/**
 APP将要进入后台
 */
- (void)appWillEnterBackgroundNotification {
    _enterBackGround = YES;
    UIApplication *app = [UIApplication sharedApplication];
    UIBackgroundTaskIdentifier taskID = 0;
    taskID = [app beginBackgroundTaskWithExpirationHandler:^{
        [app endBackgroundTask:taskID];
    }];
    if (taskID == UIBackgroundTaskInvalid) {
        return;
    }
    //#ifdef LockView
    if (_pauseInBackGround == NO) {//后台支持播放
        [self.lockView updateLockView];
        WS(weakSelf)
        /*     播放/暂停回调     */
        self.lockView.pauseCallBack = ^(BOOL pause) {
            weakSelf.playerView.pauseButton.selected = pause;
            if (pause) {
                [weakSelf.requestDataPlayBack pausePlayer];
            }else{
                [weakSelf.requestDataPlayBack startPlayer];
            }
        };
        /*     快进/快退回调     */
        self.lockView.progressBlock = ^(int time) {
            [weakSelf.requestDataPlayBack setCurrentPlaybackTime:time];
            weakSelf.playerView.slider.value = time;
            weakSelf.playerView.sliderValue = weakSelf.playerView.slider.value;
        };
    }
    //#endif
}

/**
 程序从后台激活
 */
- (void)applicationDidBecomeActiveNotification {
    if (_isTrialEnd) {
        _playerView.isTrialEnd = _isTrialEnd;
        return;
    }
    
    if (_enterBackGround == NO) {
        /*  如果当前视频不处于播放状态，重新进行播放,初始化播放状态 */
//#ifdef LockView
        [_lockView updateLockView];
//#endif
    }
}

#pragma mark - 横竖屏旋转设置
/// 4.5.1 new
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    BOOL isLaunchScreen = NO;
    NSLog(@"view 发生改变:%@", NSStringFromCGSize(size));
    if (@available(iOS 16.0, *)) {
        NSArray *array = [[[UIApplication sharedApplication] connectedScenes] allObjects];
        UIWindowScene *scene = [array firstObject];
        isLaunchScreen = scene.interfaceOrientation == UIInterfaceOrientationLandscapeRight;
    } else {
        isLaunchScreen = [UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeLeft;
    }
    NSLog(@"将要%@", isLaunchScreen ? @"横屏" : @"竖屏");
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(beginChange:) object:nil];
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    param[@"isLaunchScreen"] = @(isLaunchScreen);
    [self performSelector:@selector(beginChange:) withObject:param afterDelay:0.25];
}

/// 4.5.1 new
/**
 *    @brief    强制转屏
 *    @param    orientation   旋转方向
 */
- (void)interfaceOrientation:(UIInterfaceOrientation)orientation {
    BOOL isLaunchScreen = orientation != UIInterfaceOrientationPortrait ? YES : NO;
    AppDelegate *appdelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    if (isLaunchScreen) {
        // 全屏操作
        appdelegate.launchScreen = YES;
    } else {
        // 退出全屏操作
        appdelegate.launchScreen = NO;
    }
       
    if (@available(iOS 16.0, *)) {
        
        void (^errorHandler)(NSError *error) = ^(NSError *error) {
            NSLog(@"强制%@错误:%@", isLaunchScreen ? @"横屏" : @"竖屏", error);
        };
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        SEL supportedInterfaceSelector = NSSelectorFromString(@"setNeedsUpdateOfSupportedInterfaceOrientations");
        [self performSelector:supportedInterfaceSelector];
        NSArray *array = [[UIApplication sharedApplication].connectedScenes allObjects];
        UIWindowScene *scene = (UIWindowScene *)[array firstObject];
        Class UIWindowSceneGeometryPreferencesIOS = NSClassFromString(@"UIWindowSceneGeometryPreferencesIOS");
        if (UIWindowSceneGeometryPreferencesIOS) {
            SEL initWithInterfaceOrientationsSelector = NSSelectorFromString(@"initWithInterfaceOrientations:");
            UIInterfaceOrientationMask orientation = isLaunchScreen ? UIInterfaceOrientationMaskLandscapeRight : UIInterfaceOrientationMaskPortrait;
            id geometryPreferences = [[UIWindowSceneGeometryPreferencesIOS alloc] performSelector:initWithInterfaceOrientationsSelector withObject:@(orientation)];
            if (geometryPreferences) {
                SEL requestGeometryUpdateWithPreferencesSelector = NSSelectorFromString(@"requestGeometryUpdateWithPreferences:errorHandler:");
                if ([scene respondsToSelector:requestGeometryUpdateWithPreferencesSelector]) {
                    [scene performSelector:requestGeometryUpdateWithPreferencesSelector withObject:geometryPreferences withObject:errorHandler];
                }
            }
        }
        #pragma clang diagnostic pop
    } else {
        if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
            SEL selector  = NSSelectorFromString(@"setOrientation:");
            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
            [invocation setSelector:selector];
            [invocation setTarget:[UIDevice currentDevice]];
            int val = orientation;
            // 从2开始是因为0 1 两个参数已经被selector和target占用
            [invocation setArgument:&val atIndex:2];
            [invocation invoke];
        }
    }
}
/// 4.5.1 new
- (void)beginChange:(NSDictionary *)param {
    BOOL isLaunchScreen = [[param objectForKey:@"isLaunchScreen"] boolValue];
    [self updateSubViewConstraints:isLaunchScreen];
}
/// 4.5.1 new
- (void)updateSubViewConstraints:(BOOL)isLaunchScreen {
    if (isLaunchScreen == YES) {
        
        [self.playerView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self.view);
        }];
        [_playerView layoutIfNeeded];
        
        if (self.docOrVideoFlag == 1) {
            self.hds_contentView.frame = self.view.bounds;
            self.hds_playerView.frame = self.view.bounds;
            self.hds_headerView.frame = self.view.bounds;
        } else {
            [_requestDataPlayBack changeDocFrame:self.view.bounds];
        }
        //隐藏互动视图
        [self hiddenInteractionView:YES];
        [self updateSupportView];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.marqueeView startMarquee];
        });
    } else {
        
        [self.playerView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view).offset(SCREEN_STATUS);
            make.left.right.equalTo(self.view);
            make.height.mas_equalTo(HDGetRealHeight);
        }];
        [_playerView layoutIfNeeded];
        
        if (self.docOrVideoFlag == 1) {
            self.hds_contentView.frame = CGRectMake(0, 0, SCREEN_WIDTH, HDGetRealHeight);
            self.hds_playerView.frame = CGRectMake(0, 0, SCREEN_WIDTH, HDGetRealHeight);
            self.hds_headerView.frame = CGRectMake(0, 0, SCREEN_WIDTH, HDGetRealHeight);
        } else {
            [_requestDataPlayBack changeDocFrame:CGRectMake(0, 0, SCREEN_WIDTH, HDGetRealHeight)];
        }
        //显示互动视图
        [self hiddenInteractionView:NO];
        [self updateSupportView];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.marqueeView startMarquee];
        });
    }
}

- (BOOL)prefersHomeIndicatorAutoHidden {

    return  YES;
}

/**
 *    @brief    来电监听
 */
- (void)callCenterObserver {
    __weak __typeof(self)weakSelf = self;
    _callCenter = [[CTCallCenter alloc] init];
    _callCenter.callEventHandler = ^(CTCall* call) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([call.callState isEqualToString:CTCallStateIncoming]) {
                [weakSelf.playerView.pauseButton setSelected:YES];
                [weakSelf.requestDataPlayBack pausePlayer];
            }
            
            if ([call.callState isEqualToString:CTCallStateDisconnected]) {
                [weakSelf.playerView.pauseButton setSelected:NO];
                [weakSelf.requestDataPlayBack retryReplay];
            }
        });
    };
}
@end
