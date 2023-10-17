//
//  OfflinePlayBackViewController.m
//  CCOffline
//
//  Created by 何龙 on 2019/5/14.
//  Copyright © 2019 MacBook Pro. All rights reserved.
//

#import "OfflinePlayBackViewController.h"
#import "CCPlayBackView.h"//视频视图
#import "CCSDK/SaveLogUtil.h"//日志
#import "CCPlayBackInteractionView.h"//回放互动视图
#import "CCSDK/OfflinePlayBack.h"//离线下载
#import <CoreTelephony/CTCallCenter.h>
#import <CoreTelephony/CTCall.h>
//#ifdef LockView
#import "CCLockView.h"//锁屏
//#endif
#import <AVFoundation/AVFoundation.h>
/// 4.5.1 new
#import "AppDelegate.h"
#import "CCAlertView.h"
#import <Masonry/Masonry.h>

#define kHDOfflineRecordHistory @"HDOfflinePlayBackRecordHistoryPlayTime"

/*
 *******************************************************
 *      去除锁屏界面功能步骤如下：                          *
 *  1。command+F搜索   #ifdef LockView                  *
 *                                                     *
 *  2.删除 #ifdef LockView 至 #endif之间的代码            *
 *******************************************************
 */

@interface OfflinePlayBackViewController ()<OfflinePlayBackDelegate,UIScrollViewDelegate, CCPlayBackViewDelegate>

@property (nonatomic,strong)CCPlayBackInteractionView  * interactionView;//互动视图
@property (nonatomic,strong)CCPlayBackView              * playerView;//视频视图
@property (nonatomic,strong)OfflinePlayBack             * offlinePlayBack;
//#ifdef LockView
@property (nonatomic,strong)CCLockView                  * lockView;//锁屏视图
//#endif
@property (nonatomic,assign) BOOL                       pauseInBackGround;//后台是否暂停
@property (nonatomic,assign) BOOL                       enterBackGround;//是否进入后台
@property (nonatomic,copy)  NSString                    * groupId;//聊天分组
@property (nonatomic,copy)  NSString                    * roomName;//房间名
@property(nonatomic,  copy)NSString                 *destination;

#pragma mark - 文档显示模式
@property (nonatomic,assign)BOOL                        isSmallDocView;//是否是文档小屏
@property (nonatomic,strong)UIView                      * onceDocView;//临时DocView(双击ppt进入横屏调用)
@property (nonatomic,strong)UIView                      * oncePlayerView;//临时playerView(双击ppt进入横屏调用)
@property (nonatomic,strong)UILabel                     * label;

/** 记录切换ppt缩放模式 */
@property (nonatomic, assign)NSInteger                    pptScaleMode;
/** 是否播放完成 */
@property (nonatomic, assign)BOOL                         isPlayDone;

/** 历史播放记录 记录器(连续播放5s才进行记录) */
@property (nonatomic, assign)int                        recordHistoryCount;
/** 历史播放记录时间 */
@property (nonatomic, assign)int                        recordHistoryTime;
/** 是否显示过历史播放记录 */
@property (nonatomic, assign)BOOL                       isShowRecordHistory;
/** 视频总时长 */
@property (nonatomic, assign)double                     videoTotalDuration;
/** 来电处理*/
@property (nonatomic, strong)CTCallCenter               *callCenter;// 来电状态判断

/// 流媒体父视图
@property (nonatomic, strong)UIView                     *hds_contentView;
/// 流媒体视图
@property (nonatomic, strong)UIView                     *hds_playerView;
/// 4.5.1 new
@property (nonatomic, assign) NSInteger                 docOrVideoFlag;

@end

@implementation OfflinePlayBackViewController

-(instancetype)initWithDestination:(NSString *)destination {
    self = [super init];
    if (self) {
        self.destination = destination;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    //初始化背景颜色，设置状态栏样式
    self.view.backgroundColor = [UIColor whiteColor];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    /*  设置后台是否暂停 ps:后台支持播放时将会开启锁屏播放器 */
    _pauseInBackGround = NO;
    _isSmallDocView = YES;
    [self setupUI];//设置UI布局
    [self addObserver];//添加通知
    [self integrationSDK];//集成SDK
    
    _recordHistoryTime = 0;
    _recordHistoryCount = 0;
    _isShowRecordHistory = NO;
    [self callCenterObserver];
}

//集成SDK
- (void)integrationSDK {
    
    UIView *docView = self.isSmallDocView ? self.playerView.contentView : self.playerView.smallVideoView.hdContentView;     //文档父视图
    self.hds_contentView = self.isSmallDocView ? self.playerView.smallVideoView.hdContentView : self.playerView.contentView;//视频父视图
    PlayParameter *parameter = [[PlayParameter alloc] init];
    parameter.docParent = docView;//文档小窗
    parameter.docFrame = docView.bounds;//视频位置,ps:起始位置为视频视图坐标
    parameter.PPTScalingMode = 2;//ppt展示模式,建议值为2
    parameter.pauseInBackGround = _pauseInBackGround;//后台是否暂停
    parameter.defaultColor = @"#FFFFFF";//ppt默认底色，不写默认为白色
    parameter.scalingMode = 1;//屏幕适配方式
    parameter.pptInteractionEnabled = YES;
    parameter.destination = self.destination;
    _pptScaleMode = parameter.PPTScalingMode;
    WS(weakSelf)
    _offlinePlayBack = [[OfflinePlayBack alloc] initSDKWithParameter:parameter succed:^(BOOL succed) {
        
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
    _offlinePlayBack.delegate = self;
    [_offlinePlayBack startPlayAndDecompress];
    self.playerView.headerView.hidden = YES;
    [self.playerView showLoadingView];//显示视频加载中提示
}
#pragma mark- 必须实现的代理方法
/**
 *    @brief    请求成功
 */
-(void)requestSucceed {
    
}

/**
 *    @brief    登录请求失败
 */
-(void)requestFailed:(NSError *)error reason:(NSString *)reason {
    NSString *message = nil;
    if (reason == nil) {
        message = [error localizedDescription];
    } else {
        message = reason;
    }
    
    CCAlertView *alertView = [[CCAlertView alloc] initWithAlertTitle:message sureAction:ALERT_SURE cancelAction:nil sureBlock:nil];
    [APPDelegate.window addSubview:alertView];
}

#pragma mark-----------------------功能代理方法 用哪个实现哪个-------------------------------
/**
 *    @brief    播放器初始化完成 (会多次回调)
 */
- (void)HDMediaPlaybackIsPreparedToPlayDidChange:(NSDictionary *)dict
{

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
- (void)HDSMediaPlayBackStateDidChange:(HDSMediaPlaybackState)state
{
    switch (state)
    {
        case HDSMediaPlaybackStateStopped: {
            break;
        }
        case HDSMediaPlaybackStatePlaying:{            
            //#ifdef LockView
            if (_pauseInBackGround == NO && _roomName) {//后台支持播放
                [self setLockView];//设置锁屏界面
            }
            //#endif
            if (self.isPlayDone == YES) {
                self.playerView.playDone = NO;
                self.isPlayDone = NO;
            }
            if (self.playerView.pauseButton.selected == YES) {
                self.playerView.pauseButton.selected = NO;
            }
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (_isShowRecordHistory == NO) {
                    int time = [self readRecordHistoryPlayTime];
                    if (time > 0) {
                        [self.playerView showRecordHistoryPlayViewWithRecordHistoryTime:time];
                        _isShowRecordHistory = YES;
                    }
                }
            });
        }
        case HDSMediaPlaybackStatePaused: {
            if(self.playerView.pauseButton.selected == YES && [_offlinePlayBack isPlaying]) {
                [_offlinePlayBack pausePlayer];
            }
            if(self.playerView.loadingView && ![self.playerView.timer isValid]) {
                [self.playerView removeLoadingView];//移除加载视图
                /*      保存日志     */
                [[SaveLogUtil sharedInstance] saveLog:@"" action:SAVELOG_ALERT];
                
                
                /* 当视频被打断时，重新开启视频需要校对时间 */
                if (_playerView.slider.value != 0) {
                    _offlinePlayBack.currentPlaybackTime = _playerView.slider.value;
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
- (void)HDSMediaLoadStateDidChange:(HDSMediaLoadState)state
{
    switch (state)
    {
        case HDSMediaLoadStateUnknown:
            break;
        case HDSMediaLoadStatePlayable:
            break;
        case HDSMediaLoadStatePlaythroughOK:
            break;
        case HDSMediaLoadStateStalled:
            break;
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
- (void)HDSMediaPlayerPlaybackDidFinish:(HDSMediaFinishReason)reason
{
    switch (reason) {
        case HDSMediaFinishReasonPlaybackEnded:
        {
            [self playDone];
            self.playerView.playDone = YES;
        }
            break;
        case HDSMediaFinishReasonUserExited:
            break;
        case HDSMediaFinishReasonPlaybackError:
            break;
        default:
            break;
    }
}

- (void)HDPlayerCurrentTime:(NSTimeInterval)currentTime totalTime:(NSTimeInterval)totalTime
{
    // 记录视频总时长
    self.videoTotalDuration = totalTime;
    if([_offlinePlayBack isPlaying]) {
        [self.playerView removeLoadingView];
    }
    //持续播放5s进行记录并存储
    if (self.recordHistoryCount == 5) {
        self.recordHistoryTime = currentTime;
        [self saveRecordHistoryPlayTime];
        self.recordHistoryCount = 0;
    }else {
        if (currentTime != 0) {
            self.recordHistoryCount++;
        }
    }
    
    WS(weakSelf)
    dispatch_async(dispatch_get_main_queue(), ^{
        //获取当前播放时间和视频总时长
        NSTimeInterval position = (int)round(currentTime);
        NSTimeInterval duration = (int)round(totalTime);
        if (position != 0 && duration > 0 && position >= duration) {
            [weakSelf playDone];
           // weakSelf.playerView.playDone = YES;
        }
 
        //设置plaerView的滑块和右侧时间Label
        weakSelf.playerView.slider.maximumValue = (int)duration;
        weakSelf.playerView.rightTimeLabel.text = [NSString stringWithFormat:@"%02d:%02d", (int)(duration / 60), (int)(duration) % 60];
        
        //校对SDK当前播放时间
        if(position == 0 && weakSelf.playerView.sliderValue != 0) {
            weakSelf.offlinePlayBack.currentPlaybackTime = weakSelf.playerView.sliderValue;
            weakSelf.playerView.slider.value = weakSelf.playerView.sliderValue;
        } else {
            weakSelf.playerView.slider.value = position;
            weakSelf.playerView.sliderValue = weakSelf.playerView.slider.value;
            if (weakSelf.videoTotalDuration - position <= 2) {
                weakSelf.playerView.slider.value = ceil(weakSelf.videoTotalDuration);
                weakSelf.playerView.sliderValue = ceil(weakSelf.videoTotalDuration);
            }
        }
        
        //校对本地显示速率和播放器播放速率
        if([weakSelf.offlinePlayBack getMediaRate] != weakSelf.playerView.playBackRate) {

            [weakSelf.offlinePlayBack setMediaRate:weakSelf.playerView.playBackRate];
            //#ifdef LockView
            //校对锁屏播放器播放速率
            [weakSelf.lockView updatePlayBackRate:[weakSelf.offlinePlayBack getMediaRate]];
            //#endif
        }
                
        if(weakSelf.playerView.pauseButton.selected == NO && [weakSelf.offlinePlayBack getMediaRate] == HDSMediaPlaybackStatePaused) {
            //开启播放视频
            [weakSelf.offlinePlayBack startPlayer];
        }
        
        /*  加载聊天数据 */
        [weakSelf parseChatOnTime:(int)weakSelf.playerView.sliderValue];
        //更新左侧label
        weakSelf.playerView.leftTimeLabel.text = [NSString stringWithFormat:@"%02d:%02d", (int)(weakSelf.playerView.sliderValue / 60), (int)(weakSelf.playerView.sliderValue) % 60];
        //#ifdef LockView
        /*  校对锁屏播放器进度 */
        [weakSelf.lockView updateCurrentDurtion:_offlinePlayBack.currentPlaybackTime];
        //#endif
    });
}

#pragma mark - 服务端给自己设置的信息
/**
 *    @brief    服务器端给自己设置的信息(The new method)
 *    groupId 分组id
 *    name 用户名
 */
-(void)setMyViewerInfo:(NSDictionary *) infoDic{
    _groupId = @"";
    _interactionView.groupId = _groupId;
}
#pragma mark- 房间信息
/**
 *    @brief    读取历史播放记录
 */
- (int)readRecordHistoryPlayTime
{
    int time = 0;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *dict = [userDefaults objectForKey:kHDOfflineRecordHistory];
    // 1.本地有历史播放记录
    if (![dict isKindOfClass:[NSNull class]]) {
        // 2.是同一个回放
        if ([_fileName isEqualToString:dict[@"recordId"]]) {
            time = [dict[@"time"] intValue];
        }
    }
    return time;
}

/**
 *    @brief    存储历史播放记录
 */
- (void)saveRecordHistoryPlayTime
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *saveDict = [NSMutableDictionary dictionary];
    NSDictionary *dict = [userDefaults objectForKey:kHDOfflineRecordHistory];
    // 1.本地有历史播放记录
    if (![dict isKindOfClass:[NSNull class]]) {
        // 2.是同一个回放
        if ([_fileName isEqualToString:dict[@"recordId"]]) {
            saveDict[@"time"] = @(self.recordHistoryTime);
            saveDict[@"recordId"] = dict[@"recordId"];
        }else {
            //2.不是同一个回放
            saveDict[@"recordId"] = _fileName;
            saveDict[@"time"] = @(self.recordHistoryTime);
        }
    }else {
        //1.本地无历史播放记录数据
        saveDict[@"recordId"] = _fileName;
        saveDict[@"time"] = @(self.recordHistoryTime);
    }
    [userDefaults setObject:saveDict forKey:kHDOfflineRecordHistory];
    [userDefaults synchronize];
}

/**
 *    @brief  房间信息
 */
-(void)offline_roomInfo:(NSDictionary *)dic{
    // 3.17.0 new
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
    
    WS(weakSelf)
    dispatch_async(dispatch_get_main_queue(), ^{
        //设置房间标题
        weakSelf.playerView.titleLabel.text = weakSelf.roomName;
        //配置互动视图的信息
        [weakSelf.interactionView roomInfo:dic playerView:weakSelf.playerView];
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
        if (type == 4 || type == 5) { ///离线回放添加小窗
            //读取本地数据 无网络延时 会被先添加到控制器 被遮盖
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakSelf.playerView addSmallView];
            });
        }else {
            // 1.仅有视频模式
            [weakSelf changeBtnClicked:1];
            weakSelf.playerView.isOnlyVideoMode = YES;
        }
        //#ifdef LockView
        //_roomName有值得时候才初始化锁屏view
        if (weakSelf.pauseInBackGround == NO && weakSelf.roomName) {//后台支持播放
           [weakSelf setLockView];//设置锁屏界面
        }
        //#endif
    });
}
#pragma mark- 回放的开始时间和结束时间
/**
 *  @brief 回放的开始时间和结束时间
 */
-(void)liveInfo:(NSDictionary *)dic {
    SaveToUserDefaults(LIVE_STARTTIME, dic[@"startTime"]);
}
#pragma mark- 聊天
/**
 *    @brief    解析本房间的历史聊天数据
 */
-(void)offline_onParserChat:(NSArray *)arr {
    if ([arr count] == 0) {
        return;
    }
    //解析历史聊天
    [self.interactionView onParserChat:arr];
}

- (void)offline_loadVideoFail {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"视频品文件损坏播放错误,请重新下载" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDestructive handler:nil];
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}
- (void)pageChangeList:(NSMutableArray *)array {
    
}

-(void)onPageChange:(NSDictionary *)dictionary {
    
}

-(void)broadcastHistory_msg:(NSArray *)array {
    
}
#pragma mark- 问答
/**
 *    @brief    收到本房间的历史提问&回答
 */
- (void)offline_onParserQuestionArr:(NSArray *)questionArr onParserAnswerArr:(NSArray *)answerArr
{
    [self.interactionView onParserQuestionArr:questionArr onParserAnswerArr:answerArr];
}

//移除通知
- (void)dealloc {
    /*      自动登录情况下，会存在移除控制器但是SDK没有销毁的情况 */
    if (_offlinePlayBack) {
        [_offlinePlayBack requestCancel];
        _offlinePlayBack = nil;
    }
    [self removeObserver];
    [self.interactionView removeData];
}
#pragma mark - 设置UI

/**
 创建UI
 */
- (void)setupUI {
    
    //添加视频播放视图
    _playerView = [[CCPlayBackView alloc] initWithFrame:CGRectZero docViewType:_isSmallDocView];
    _playerView.isOffline = YES;
    _playerView.delegate = self;
    _playerView.screenCaptureSwitch = self.screenCaptureSwitch;
    
    //退出直播间回调
    WS(weakSelf)
    _playerView.exitCallBack = ^{
        [weakSelf.offlinePlayBack requestCancel];
        weakSelf.offlinePlayBack = nil;
        [weakSelf dismissViewControllerAnimated:YES completion:^{
            [weakSelf.interactionView removeFromSuperview];
            weakSelf.interactionView = nil;
            [weakSelf.playerView removeFromSuperview];
            weakSelf.playerView = nil;
        }];
    };
    
    _playerView.replayBtnTapClosure = ^{
        [weakSelf.offlinePlayBack replayPlayer];
    };
    
    //滑块滑动完成回调
    _playerView.sliderCallBack = ^(int duration) {
        // 拖动至视频结尾,视频播放完成
        weakSelf.recordHistoryCount = 0;
        if (duration >= self.videoTotalDuration) {
            weakSelf.offlinePlayBack.currentPlaybackTime = duration-2;
            [weakSelf.offlinePlayBack startPlayer];
            weakSelf.playerView.sliderValue = duration;
            return;
        }
        weakSelf.offlinePlayBack.currentPlaybackTime = duration;
        //#ifdef LockView
        /*  校对锁屏播放器进度 */
        [weakSelf.lockView updateCurrentDurtion:weakSelf.offlinePlayBack.currentPlaybackTime];
        //#endif
        if ([weakSelf.offlinePlayBack getMediaPlayStatus] != HDSMediaPlaybackStatePlaying) {
            [weakSelf.offlinePlayBack startPlayer];
        }
        //隐藏历史播放记录view
        [weakSelf.playerView hiddenRecordHistoryPlayView];
    };
    //滑块移动回调
    _playerView.sliderMoving = ^{
        if ([weakSelf.offlinePlayBack getMediaPlayStatus] != HDSMediaPlaybackStatePaused) {
            [weakSelf.offlinePlayBack pausePlayer];
        }
    };
    //更改播放器速率回调
    _playerView.changeRate = ^(float rate) {
        [weakSelf.offlinePlayBack setMediaRate:rate];
    };
    //暂停/开始播放回调
    _playerView.pausePlayer = ^(BOOL pause) {
        if (pause) {
            [weakSelf.offlinePlayBack pausePlayer];
        }else{
            [weakSelf.offlinePlayBack startPlayer];
        }
    };
    [self.view addSubview:self.playerView];
    [self.playerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(SCREEN_STATUS);
        make.left.right.equalTo(self.view);
        make.height.mas_equalTo(HDGetRealHeight);
    }];
    [_playerView layoutIfNeeded];
    
    /// 4.5.1 new
    //添加互动视图
    self.interactionView = [[CCPlayBackInteractionView alloc] initWithFrame:CGRectZero docViewType:_isSmallDocView];
    [self.view addSubview:self.interactionView];
    CGFloat h = self.view.frame.size.height - CGRectGetMaxY(_playerView.frame);
    [self.interactionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.playerView.mas_bottom);
        make.left.right.mas_equalTo(self.view);
        make.height.mas_equalTo(h);
    }];
    [_interactionView layoutIfNeeded];}
//#ifdef LockView
/**
 设置锁屏播放器界面
 */
-(void)setLockView{
    if (_lockView) {//如果当前已经初始化，return;
        return;
    }
    _lockView = [[CCLockView alloc] initWithRoomName:_roomName duration:[_offlinePlayBack playerDuration]];
    [self.view addSubview:_lockView];
    [_offlinePlayBack setpauseInBackGround:self.pauseInBackGround];
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

//#endif
#pragma mark - playViewDelegate
/**
 全屏按钮点击代理
 
 @param tag 1视频为主，2文档为主
 */
-(void)quanpingBtnClicked:(NSInteger)tag{
    /// 4.5.1 new
    self.docOrVideoFlag = tag;
    [self interfaceOrientation:UIInterfaceOrientationLandscapeRight];
}
/**
 返回按钮点击代理
 
 @param tag 1.视频为主，2.文档为主
 */
-(void)backBtnClicked:(NSInteger)tag{
    /// 4.5.1 new
    self.docOrVideoFlag = tag;
    [self interfaceOrientation:UIInterfaceOrientationPortrait];
}
/**
 切换视频/文档按钮点击回调
 
 @param tag changeBtn的tag值
 */
-(void)changeBtnClicked:(NSInteger)tag{
    if (tag == 2) {
        
        [_offlinePlayBack changeDocParent:self.playerView.contentView];
        [_offlinePlayBack changeDocFrame:self.playerView.contentView.bounds];
        
        self.hds_contentView = self.playerView.smallVideoView.hdContentView;
        self.hds_contentView.frame = self.playerView.smallVideoView.bounds;
        [self.hds_contentView addSubview:self.hds_playerView];
        self.hds_playerView.frame = self.hds_contentView.bounds;
        self.playerView.headerView.hidden = YES;

    }else{
        
        [_offlinePlayBack changeDocParent:self.playerView.smallVideoView.hdContentView];
        [_offlinePlayBack changeDocFrame:self.playerView.smallVideoView.hdContentView.bounds];
        
        self.hds_contentView = self.playerView.contentView;
        self.hds_contentView.frame = self.playerView.contentView.bounds;
        [self.hds_contentView addSubview:self.hds_playerView];
        self.hds_playerView.frame = self.hds_contentView.bounds;
        self.playerView.headerView.hidden = YES;
    }
}
/**
 *    @brief    播放完成
 */
- (void)playDone
{
    self.isPlayDone = YES;
}
/**
 隐藏互动视图
 
 @param hidden 是否隐藏
 */
-(void)hiddenInteractionView:(BOOL)hidden{
    self.interactionView.hidden = hidden;
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
                                             selector:@selector(appWillEnterBackgroundNotification) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appWillEnterForegroundNotification) name:UIApplicationWillEnterForegroundNotification object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidBecomeActiveNotification)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
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
}

/**
 APP将要进入前台
 */
- (void)appWillEnterForegroundNotification {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        _enterBackGround = NO;
    });
    //#ifdef LockView
    /*  当视频播放被打断时，重新加载视频  */
    if ([_offlinePlayBack getMediaPlayStatus] != HDSMediaPlaybackStatePlaying && self.isPlayDone != YES) {
//        [self.offlinePlayBack replayPlayer];
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
        _lockView.pauseCallBack = ^(BOOL pause) {
            weakSelf.playerView.pauseButton.selected = pause;
            if (pause) {
                [weakSelf.offlinePlayBack pausePlayer];
            }else{
                [weakSelf.offlinePlayBack startPlayer];
            }
        };
        /*     快进/快退回调     */
        _lockView.progressBlock = ^(int time) {
            weakSelf.offlinePlayBack.currentPlaybackTime = time;
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
    if (_enterBackGround == NO && ![_offlinePlayBack isPlaying]) {
        /*  如果当前视频不处于播放状态，重新进行播放,初始化播放状态 */
        if (_isPlayDone == NO) {
            [_offlinePlayBack replayPlayer];
            [_playerView showLoadingView];
        }
        //#ifdef LockView
        [_lockView updateLockView];
        //#endif
    }
    if (![_offlinePlayBack isPlaying] && _isPlayDone == NO) {
        [_offlinePlayBack startPlayer];
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
        } else {
            [_offlinePlayBack changeDocFrame:self.view.frame];
        }
        //隐藏互动视图
        [self hiddenInteractionView:YES];
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
        } else {
            [_offlinePlayBack changeDocFrame:CGRectMake(0, 0, SCREEN_WIDTH, HDGetRealHeight)];
        }
        //显示互动视图
        [self hiddenInteractionView:NO];
    }
}

- (BOOL)prefersHomeIndicatorAutoHidden {
    
    return  YES;
}

/**
 *    @brief    来电监听
 */
- (void)callCenterObserver
{
    __weak __typeof(self)weakSelf = self;
    _callCenter = [[CTCallCenter alloc] init];
    _callCenter.callEventHandler = ^(CTCall* call) {
        if ([call.callState isEqualToString:CTCallStateIncoming]) {

        }
        
        if ([call.callState isEqualToString:CTCallStateDisconnected]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.offlinePlayBack retryReplay];
            });
        }
    };
}
@end
