//
//  CCPlayerController.m
//  CCLiveCloud
//
//  Created by MacBook Pro on 2018/10/22.
//  Copyright © 2018 MacBook Pro. All rights reserved.
//

#import "CCPlayerController.h"
#import "CCSDK/RequestData.h"//SDK
#import "CCSDK/SaveLogUtil.h"//日志
#import "LotteryView.h"//抽奖
#import "NewLotteryView.h"//抽奖2.0
#import "CCPlayerView.h"//视频
#import "CCInteractionView.h"//互动视图
#import "QuestionNaire.h"//第三方调查问卷
#import "QuestionnaireSurvey.h"//问卷和问卷统计
#import "QuestionnaireSurveyPopUp.h"//问卷弹窗
#import "RollcallView.h"//签到
#import "VoteView.h"//答题卡
#import "VoteViewResult.h"//答题结果
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import "SelectMenuView.h"//更多菜单
#import "AnnouncementView.h"//公告
#import "CCAlertView.h"//提示框
#import "CCProxy.h"
#import "CCClassTestView.h"//随堂测
#import "CCCupView.h"//奖杯
#import "CCPunchView.h"
/// 4.5.1 new
#import "AppDelegate.h"
/// 3.17.3 new
#import "HDSSupportView.h"
#import "Reachability.h"

/// 4.1.0 new
#import "HDSInteractionManager.h"
#import "HDSInteractionManagerConfig.h"

//#ifdef LIANMAI_WEBRTC
#import "HDSMultiMediaCallBar.h"
#import "HDSMultiMediaCallBarConfiguration.h"
#import <AVFoundation/AVCaptureDevice.h>
#import <AVFoundation/AVMediaFormat.h>
//#endif

//#ifdef LockView
#import "CCLockView.h"//锁屏界面
//#endif
#import "CCLiveCloud-Swift.h"

/// 4.6.0 new
#import "HDSAnimationManager.h"
#import "HDSBaseAnimationModel.h"
#import "HDSAnimationModel.h"

// 4.11.0 new
//#import <HDSPanoramicVideoFramework/HDSPanoramicVideoFramework.h>
#import <HDBaseUtils/HDBaseUtils.h>

#import "AppDelegate.h"
#import "Utility.h"
#import "HDSLoginErrorManager.h"
#import "UIColor+RCColor.h"
#import "HDSPublicTipsView.h"
#import "UIView+Extension.h"
#import "ObjectExtension.h"
#import <Masonry/Masonry.h>

/*
*******************************************************
*      去除锁屏界面功能步骤如下：                          *
*  1。command+F搜索   #ifdef LockView                  *
*                                                     *
*  2.删除 #ifdef LockView 至 #endif之间的代码            *
*******************************************************
*/
@interface CCPlayerController ()<RequestDataDelegate,
//#ifdef LIANMAI_WEBRTC
LianMaiDelegate,
//#endif
UIScrollViewDelegate,UITextFieldDelegate,CCPlayerViewDelegate>
#pragma mark - 房间相关参数
@property (nonatomic,copy)  NSString                 * viewerId;//观看者的id
@property (nonatomic,strong) NSString                 * roomName;//房间名
@property (nonatomic,copy) NSString                 * roomDesc;//房间描述信息
@property (nonatomic,copy) NSString                 * liveStartTime;//房间描述信息
@property(nonatomic, copy) NSString                  *loginUserId;
@property (nonatomic,strong)RequestData              * requestData;//sdk
#pragma mark - UI初始化
@property (nonatomic,strong)CCPlayerView             * playerView;//视频视图
@property (nonatomic,strong)CCInteractionView        * contentView;//互动视图
@property (nonatomic,strong)SelectMenuView           * menuView;//选择菜单视图
#pragma mark - 抽奖
@property (nonatomic,strong)LotteryView              * lotteryView;//抽奖
@property (nonatomic,strong)NewLotteryView           * nLotteryView;//抽奖2.0
#pragma mark - 问卷
@property (nonatomic,assign)NSInteger                submitedAction;//提交事件
@property (nonatomic,strong)QuestionNaire            * questionNaire;//第三方调查问卷
@property (nonatomic,strong)QuestionnaireSurvey      * questionnaireSurvey;//问卷视图
@property (nonatomic,strong)QuestionnaireSurveyPopUp * questionnaireSurveyPopUp;//问卷弹窗
#pragma mark - 签到
@property (nonatomic,weak)  RollcallView             * rollcallView;//签到
@property (nonatomic,assign)NSInteger                duration;//签到时间
#pragma mark - 答题卡
@property(nonatomic,weak)  VoteView                  * voteView;//答题卡
@property(nonatomic,weak)  VoteViewResult            * voteViewResult;//答题结果
@property(nonatomic,assign)NSInteger                 mySelectIndex;//答题单选答案
@property(nonatomic,strong)NSMutableArray            * mySelectIndexArray;//答题多选答案
#pragma mark - 公告
@property(nonatomic,copy)  NSString                  * gongGaoStr;//公告内容
@property(nonatomic,strong)AnnouncementView          * announcementView;//公告视图

#pragma mark - 随堂测
@property(nonatomic,weak)CCClassTestView             * testView;//随堂测
#pragma mark - 打卡视图
@property(nonatomic,strong)CCPunchView                 * punchView;//打卡
#pragma mark - 提示框
@property (nonatomic,strong)CCAlertView              * alertView;//消息弹窗

@property (nonatomic, strong) NSString               * viewerName;

//#ifdef LockView
#pragma make - 锁屏界面
@property (nonatomic,strong)CCLockView               * lockView;//锁屏视图
//#endif LockView

@property (nonatomic,assign)BOOL                     isScreenLandScape;//是否横屏
@property (nonatomic,assign)BOOL                     screenLandScape;//横屏
@property (nonatomic,assign)BOOL                     isHomeIndicatorHidden;//隐藏home条
@property (nonatomic,assign)NSInteger                firRoadNum;//房间线路
@property (nonatomic,strong)NSMutableArray           *secRoadKeyArray;//清晰度数组
@property (nonatomic,assign)BOOL                     firstUnStart;//第一次进入未开始直播
@property (nonatomic,assign)BOOL                     pauseInBackGround;//后台播放是否暂停
#pragma mark - 文档显示模式
@property (nonatomic,assign)BOOL                     isSmallDocView;//是否是文档小窗模式
#pragma mark - 跑马灯
@property (nonatomic, assign)BOOL                    openmarquee;//跑马灯开启
@property (nonatomic,strong)HDMarqueeView            *marqueeView;//跑马灯
@property (nonatomic,strong)NSDictionary             *jsonDict;//跑马灯数据

@property (nonatomic,assign)BOOL                     isLivePlay;//直播间是否已开启
/** 记录切换ppt缩放模式 */
@property (nonatomic, assign)NSInteger               pptScaleMode;
/** 随堂测数据 */
@property (nonatomic, copy) NSMutableDictionary      *testDict;
/** 提示 */
@property (nonatomic, strong)InformationShowView     *informationView;
/** 隐藏私聊 */
@property (nonatomic, assign)BOOL                    isHiddenPrivateChat;
/** 抽奖2.0 抽奖订单ID */
@property (nonatomic, copy) NSString                 *nLotteryId;
/** 提示窗 */
@property (nonatomic,strong)InformationShowView      *tipView;
/** 是否收到抽奖完成得回调 */
@property (nonatomic,assign)BOOL                     isnLotteryComplete;
/** 结束推流的状态 */
@property (nonatomic,assign)BOOL                    endNormal;
/** 是否是在卡顿 */
@property (nonatomic,assign)BOOL                    isPlayerLoadStateStalled;
/** 播放失败 */
@property (nonatomic,assign)BOOL                    isPlayFailed;
/** 当前选择的清晰度下标 */
@property (nonatomic, assign) NSInteger             qualityIndex;

@property (nonatomic,assign)NSInteger                audioLineNum;//音频线路
/** 视音频模式 */
@property (nonatomic,assign)BOOL                     isAudioMode;
/** 是否需要显示提示view */
@property (nonatomic, assign) BOOL                   isShowBaseInfoView;
/** 当前线路下标 */
@property (nonatomic, assign) NSInteger              currentLineIndex;

/// 3.17.3 new  视频区辅助视图
@property (nonatomic, strong) HDSSupportView        *supportView;
/// 3.17.3 new  播放器父视图
@property (nonatomic, strong) UIView                *kPlayerParent;
/// 3.17.3 new  辅助视图类型
@property (nonatomic, assign) HDSSupportViewBaseType kSupportBaseType;

/// 3.18.0 new playerView
@property (nonatomic, strong) UIView                *hds_playerView;

@property (nonatomic, strong) UIView                *hds_playerContentView;
/// 3.18.0 new 文档在大屏
@property (nonatomic, assign) BOOL                  isDocMainScreen;
/// 3.18.0 new 是已获取权限
@property (nonatomic, assign) BOOL                  isGetAuth;

/// 4.1.0 new 点赞功能配置  0:关闭 1:直播间配置 2:全局配置
@property (nonatomic, assign) NSInteger                 like_config;
/// 4.1.0 new 礼物功能配置 0:关闭 1:直播间配置 2:全局配置
@property (nonatomic, assign) NSInteger                 gift_config;
/// 4.1.0 new 礼物特效配置 0:关闭 1:左侧特效 2：全局特效
@property (nonatomic, assign) NSInteger                 gift_specialEffects;

/// 4.1.0 new 投票功能配置 0:关闭 1:直播间配置 2:全局配置
@property (nonatomic, assign) NSInteger                 vote_config;
/// 4.1.0 new 红包雨功能配置 0:关闭 1:直播间配置 2:全局配置
@property (nonatomic, assign) NSInteger                 red_config;
/// 4.3.0 new 邀请卡功能配置 0:关闭 1:直播间配置 2:全局配置
@property (nonatomic, assign) NSInteger                 card_config;
/// 4.3.0 new 问卷功能配置 0:关闭 1:直播间配置 2:全局配置
@property (nonatomic, assign) NSInteger                questionnaire_config;
/// 4.5.0 new 直播带货配置 0：关闭 1：开启
@property (nonatomic, assign) NSInteger                liveStore_config;
/// 4.3.0问卷模式推送方式: 0:手动推送  1:进入直播时  2:直播结束时
@property (nonatomic, assign) NSInteger  sendMode;
/// 4.3.0问卷活动编码
@property (nonatomic, copy) NSString     * _Nullable activityCode;
/// 4.3.0问卷表单编码
@property (nonatomic, copy) NSString     * _Nullable formCode;

/// 4.1.0 new 互动组件 token
@property (nonatomic, copy)   NSString                  *interactionToken;

/// 4.1.0 new
/// 互动组件Manager
@property (nonatomic, strong) HDSInteractionManager     *interManager;
/// 互动组件配置项
@property (nonatomic, strong) HDSInteractionManagerConfig *interManagerConfig;


//#ifdef LIANMAI_WEBRTC
/// 是否是音视频连麦
@property (nonatomic, assign) BOOL                      isAudioVideo;
/// 3.18.0 new 是否是音视频连麦房间（单人连麦为YES，多人连麦需要根据代理回调配置信息）
@property (nonatomic, assign) BOOL                      isAudioVideoRoom;

@property (nonatomic, strong) CCAlertView               *needLogoutAlert;

// MARK: - 多人连麦
/// 3.18.0 new 是否是多人连麦
@property (nonatomic, assign) BOOL                      isMutilMediaCallRoom;
/// 3.18.0 new 多人连麦callBarType
@property (nonatomic, assign) HDSMultiMediaCallBarType  callBarType;
/// 3.18.0 new 多人连麦callBar
@property (nonatomic, strong) HDSMultiMediaCallBar      *callBar;
/// 3.18.0 new 是否开启音频
@property (nonatomic, assign) BOOL                      isAudioEnable;
/// 3.18.0 new 是否开启视频
@property (nonatomic, assign) BOOL                      isVideoEnable;
/// 3.18.0 new 是否是前置摄像头
@property (nonatomic, assign) BOOL                      isFrontCamera;
/// 是否在连麦中
@property (nonatomic, assign) BOOL                      isMediaCalled;
/// 3.18.0 new 连麦连接中..
@property (nonatomic, assign) BOOL                      isMediaCalling;
/// 3.18.0 new 连麦权限开关
@property (nonatomic, assign) BOOL                      isMultiMediaCallOpen;
/// 3.18.0 new 无延迟直播
@property (nonatomic, assign) BOOL                      isRTCLive;
/// 3.18.0 new 自己的callBar配置
@property (nonatomic, strong) HDSMultiMediaCallBarConfiguration *callBarConfig;
/// 3.18.0 new 5s 防抖
@property (nonatomic, assign) BOOL                      isCountDownEnd;
/// 3.18.0 new 需要登出
@property (nonatomic, assign) BOOL                      isNeedLogout;

@property (nonatomic, strong) CCAlertView               *abilityDownAlertView;
/// 3.18.0 new 老师ID
@property (nonatomic, copy)   NSString                  *teacherUserId;
/// 3.18.0 new 房间连麦人数
@property (nonatomic, assign) int                       roomCalledNum;
/// 3.18.0 new 横屏视频连麦接通后，返回竖屏需要更新视图 标记
@property (nonatomic, assign) BOOL                      isNeedUpdateFlag;
/// 3.18.0 new 横屏视频连麦接通后，返回竖屏需要更新视图 状态
@property (nonatomic, assign) BOOL                      isNeedUpdateStatus;
/// 4.5.1 new
@property (nonatomic, assign) NSInteger              docOrVideoFlag;
/// 4.8.0 new
@property (nonatomic, assign) BOOL                   isCloseHistoryAnnouncementView;
/// 4.8.0 new
@property (nonatomic, strong) UIImageView            *showNewAnnouncementTipView;

@property (nonatomic, strong) UILabel                *showNewAnnouncementTipLabel;

// MARK: - 单人连麦
/// 3.18.0 new 远端流
@property (nonatomic, strong) UIView                    *remoteView;
@property (nonatomic, assign) CGSize                    singleOriginSize;
//#endif

@property (nonatomic, assign) BOOL                      isDismiss;
/// 4.6.0 new 0:普通抽奖 1:跑马灯抽奖
@property (nonatomic, assign) NSInteger                 lotteryType;

@property (nonatomic, strong) HDSAnimationManager       *baseAnimationManager;

@property (nonatomic, strong) NewLotteryMessageModel    *lotteryModel;
/// 3.19.0 new 全体禁言/接触全体禁言 使用
@property (nonatomic, assign) BOOL                  isAllowPublicChat;
@property (nonatomic, copy)   NSString *errorTip;

@property (nonatomic, assign) BOOL statusBarSwitch;
 
@property (nonatomic, strong) HDSPublicTipsView         *publicTipsView;
/// 不是首次查询
@property (nonatomic, assign) BOOL                      nonFirstQuery;

@end
@implementation CCPlayerController
//初始化
- (instancetype)initWithRoomName:(NSString *)roomName {
    self = [super init];
    if(self) {
        self.roomName = roomName;
    }
    return self;
}

// MARK: - 自定义表情
- (void)onEmojiLoadingResult:(BOOL)result message:(NSString *)message {
    if (result) {
        [self getCustomEmoji];
    }
}

- (void)getCustomEmoji {
    BOOL customEmojiSwitch = [RequestData hasEmojisUsePermission];
    if (customEmojiSwitch) {
        BOOL emojiLoadComplete = [_requestData isEmojiLoadComplete];
        if (emojiLoadComplete) {
            NSArray *emojis = [RequestData emojisPlistInfo];
            NSMutableDictionary *allEmojiDict = [NSMutableDictionary dictionary];
            for (NSDictionary *emojisDic in emojis) {
                NSString *key = emojisDic[@"name"];
                UIImage *image = [RequestData emojiCachedForName:key];
                [allEmojiDict setValue:image forKey:key];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:@"kLoadCustomEmoji" object:nil userInfo:allEmojiDict];
        }
    }
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
    BOOL emojiOK = [self.requestData isEmojiLoadComplete];
    if(!emojiOK) {
        [self emojiShowTips:@"加载中。。。！"];
    }
    NSDictionary *info = @{
        KK_EMOJI_LOAD_RES:@(emojiOK)
    };
    [[NSNotificationCenter defaultCenter]postNotificationName:KK_KB_EMOJI_CUSTOM_CLICKED_RESULT object:nil userInfo:info];
}

//启动
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    
    
    /*  设置后台是否暂停 ps:后台支持播放时将会开启锁屏播放器 */
    _pauseInBackGround = NO;
    _isLivePlay = NO;
    _qualityIndex = 0;//默认清晰度下标
    _currentLineIndex = 0;
    /// 3.17.3 new
    _kSupportBaseType = HDSSupportViewBaseTypeNone;
    self.isAllowPublicChat = YES;
    //#ifdef LIANMAI_WEBRTC
    self.isCountDownEnd = YES;
    self.isNeedLogout = NO;
    self.isAudioEnable = YES;
    //#endif
    [self setupUI];//创建UI
    [self initSDK_New];
    [self addObserver];//添加通知
    [self getAuth];
}

/// 获取用户授权
- (void)getAuth {
    BOOL cameraAuth = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo] == AVAuthorizationStatusNotDetermined ? YES : NO;
    if (cameraAuth) {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            
        }];
    }
    BOOL micorAuth = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio] == AVAuthorizationStatusNotDetermined ? YES : NO;
    if (micorAuth) {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
            
        }];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _statusBarSwitch = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)getDocAspectRatioOfWidth:(CGFloat)width height:(CGFloat)height {
    NSLog(@"getDocAspectRatioOfWidth = %f and height = %f", width, height);
}

/**
 *    @brief    创建UI
 */
- (void)setupUI {
    /*   设置文档显示类型    YES:表示文档小窗模式   NO:文档在大窗模式  */
    _isSmallDocView = NO;
    //视频视图
    /// 4.5.1 new
    [self.view addSubview:self.playerView];
    [self.playerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(SCREEN_STATUS);
        make.left.right.equalTo(self.view);
        make.height.mas_equalTo(HDGetRealHeight);
    }];
    [_playerView layoutIfNeeded];
    //添加互动视图
    /// 4.5.1 new
    [self.view addSubview:self.contentView];
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.playerView.mas_bottom);
        make.left.right.mas_equalTo(self.view);
        //make.bottom.mas_equalTo(self.view).offset(-kScreenBottom);
        make.bottom.mas_equalTo(self.view);
    }];
    [_contentView layoutIfNeeded];
    
    self.playerView.isChatActionKeyboard = YES;
    self.contentView.isChatActionKeyboard = YES;
    
}

- (void)initSDK_New {
    
    self.hds_playerContentView = _isSmallDocView ? self.playerView.smallVideoView.hdContentView : self.contentView.docView.hdContentView;
    self.loginUserId = [GetFromUserDefaults(WATCH_USERID) stringByReplacingOccurrencesOfString:@" " withString:@""];
    PlayParameter *parameter = [[PlayParameter alloc] init];
    parameter.userId = GetFromUserDefaults(WATCH_USERID);//userId
    parameter.roomId = GetFromUserDefaults(WATCH_ROOMID);//roomId
    parameter.viewerName = GetFromUserDefaults(WATCH_USERNAME);//用户名
    parameter.token = GetFromUserDefaults(WATCH_PASSWORD);//密码
    //默认文档大窗
    parameter.docParent = self.playerView.hdContentView;//视频视图
    parameter.docFrame = self.playerView.hdContentView.bounds;//视频位置,ps:起始位置为视频视图坐标
    parameter.PPTScalingMode = 4;//ppt展示模式,建议值为4
    parameter.defaultColor = @"#FFFFFF";//ppt默认底色，不写默认为白色
    parameter.scalingMode = 1;//屏幕适配方式
    parameter.pauseInBackGround = _pauseInBackGround;//后台是否暂停
    parameter.viewerCustomua = @"viewercustomua";//自定义参数,没有的话这么写就可以
    parameter.pptInteractionEnabled = YES;
    parameter.DocModeType = 0;//设置当前的文档模式
    parameter.groupid = _contentView.groupId;//用户的groupId
    parameter.tpl = 20;
    _pptScaleMode = parameter.PPTScalingMode;
    
    _requestData = [[RequestData alloc] initSDKWithParameter:parameter succed:^(BOOL succed) {
        
    } player:^(UIView * _Nonnull playerView) {
        playerView.frame = self.hds_playerContentView.bounds; // 注意视频大小尺寸
        [self.hds_playerContentView addSubview:playerView];
        if (_hds_playerView) {
            [_hds_playerView removeFromSuperview];
            _hds_playerView = nil;
        }
        _hds_playerView = playerView;
        
    } failed:^(NSError *error, NSString *reason) {
        //[self hds_exitReLoginSingBtnWithTipStr:reason];
    }];
    _requestData.delegate = self;
    
    _kPlayerParent = _isSmallDocView ? self.playerView.smallVideoView.headerView : self.contentView.docView.headerView;
    if (_supportView) {
        [_supportView removeFromSuperview];
        _supportView = nil;
    }
    WS(weakSelf)
    _supportView = [[HDSSupportView alloc]initWithFrame:_kPlayerParent.bounds actionClosure:^{
        [weakSelf.requestData reloadVideo:NO];
    }];
    [_supportView setSupportBaseType:_kSupportBaseType boardView:_kPlayerParent];
    [_kPlayerParent bringSubviewToFront:_supportView];
    
    _supportView.hidden = YES;
}

#pragma mark - 私有方法
/**
 *    @brief    发送聊天
 *    @param    str   聊天内容
 */
- (void)sendChatMessageWithStr:(NSString *)str {
    [_requestData chatMessage:str];
}

// MARK: - 获取互动组件Token 4.1.0
/// 互动功能配置
/// @param configModel 配置信息
- (void)onInteractionFunctionConfig:(HDSInteractionFunctionModel *)configModel {
    HDSInteractionLikeModel *likeModel = configModel.likeModel;
    self.like_config = likeModel.likeFunctionConfig;
    HDSInteractionGiftModel *giftModel = configModel.giftModel;
    self.gift_config = giftModel.giftFunctionConfig;
    self.gift_specialEffects = giftModel.specialEffects;
    self.vote_config = configModel.voteModel.voteFunctionConfig;
    self.red_config = configModel.redModel.redFunctionConfig;
    self.card_config = configModel.cardModel.cardFunctionConfig;
    self.questionnaire_config = configModel.quesModel.quesFunctionConfig;
    self.sendMode = configModel.quesModel.sendMode;
    self.activityCode = configModel.quesModel.activityCode;
    self.formCode = configModel.quesModel.formCode;
    self.liveStore_config = configModel.liveStoreModel.liveStoreSwitch;
    if (self.gift_config != 0 || self.like_config != 0 || self.vote_config != 0 || self.red_config != 0 || self.card_config != 0 || self.questionnaire_config != 0 || self.liveStore_config != 0) {
        [self getInteractionToken];
    }
}

/// 获取互动组件token
- (void)getInteractionToken {
    if (_requestData == nil) return;
    [_requestData getInteractionTokenWithClosure:^(BOOL result, NSString * _Nullable message) {
        if (result) {
            
        }else {
            
            [self showTipInfomationWithTitle:message];
        }
    } tokenClosure:^(NSString * _Nullable token) {
        self.interactionToken = token;
        [self getInteractiveOngoing];
    }];
}

- (void)getInteractiveOngoing {
    [_requestData getInteractiveOngoingWithClosure:^(BOOL result, NSString * _Nullable message) {
        if (result) {
            
        }else {
            
            [self showTipInfomationWithTitle:message];
        }
    } ongoingClosure:^(NSArray * _Nullable arr) {
        
        [self initInteractionManager:arr];
    }];
}

- (void)initInteractionManager:(NSArray *)arr {
    
    if (_isDismiss) {
        return;
    }
    
    self.interManagerConfig = [[HDSInteractionManagerConfig alloc]init];
    self.interManagerConfig.userId = self.viewerId;
    self.interManagerConfig.userName = self.viewerName;
    self.interManagerConfig.roomDesc = self.roomDesc;
    self.interManagerConfig.roomName = self.roomName;
    self.interManagerConfig.liveStartTime = self.liveStartTime;
    self.interManagerConfig.roomId = GetFromUserDefaults(WATCH_ROOMID);
    self.interManagerConfig.roomUrl = [NSString stringWithFormat:@"https://view.csslcloud.net/api/view/index?roomid=%@&userid=%@",self.interManagerConfig.roomId,self.loginUserId];
    self.interManagerConfig.appid = self.loginUserId;
    self.interManagerConfig.token = self.interactionToken;
    self.interManagerConfig.likeConfig = self.like_config;
    self.interManagerConfig.giftConfig = self.gift_config;
    self.interManagerConfig.giftSpecialEffects = self.gift_specialEffects;
    self.interManagerConfig.voteConfig = self.vote_config;
    self.interManagerConfig.redConfig = self.red_config;
    self.interManagerConfig.cardConfig = self.card_config;
    self.interManagerConfig.questionnaireConfig = self.questionnaire_config;
    self.interManagerConfig.liveStoreConfig = self.liveStore_config;
    self.interManagerConfig.sendMode = self.sendMode;
    self.interManagerConfig.activityCode = self.activityCode;
    self.interManagerConfig.formCode = self.formCode;
    self.interManagerConfig.interactionArr = arr;
    self.interManagerConfig.rootVC = self;
    self.interManagerConfig.sdkVersion = [self.requestData getSDKVersion];; 
    
    self.interManager = [[HDSInteractionManager alloc]initWithConfig:self.interManagerConfig];
}

#pragma mark - 主动切换清晰度 & 线路
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

- (void)showTipInfomationWithTitle:(NSString *)title {
    WS(weakSelf)
    dispatch_async(dispatch_get_main_queue(), ^{
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hiddenTipView) object:nil];
        if (weakSelf.tipView) {
            [weakSelf.tipView removeFromSuperview];
        }
        weakSelf.tipView = [[InformationShowView alloc] initWithLabel:title];
        [APPDelegate.window addSubview:weakSelf.tipView];
        [weakSelf.tipView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
        }];
        [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(hiddenTipView) userInfo:nil repeats:NO];
    });
}


// MARK: - 红包雨
/// 开始红包雨
/// @param redPacketId 红包雨ID
- (void)HDSRedPacketDidStart:(NSString *)redPacketId {
    [self requestRedPacketWithRedPacketId:redPacketId];
}

/// 结束红包雨
/// @param redPacketId 红包雨ID
- (void)HDSRedPacketDidEnd:(NSString *)redPacketId {
    [self.playerView endRedPacketWithRedPacketId:redPacketId];
    [self requsetRedPacketRankWithReadPacketId:redPacketId];
}

/// 查询进行中的红包雨
/// @param redPacketId 红包雨ID (无ID 传@"")
- (void)requestRedPacketWithRedPacketId:(NSString *)redPacketId {
    [self.requestData requestRedPacket:redPacketId closure:^(HDSRedPacketModel *model) {
        [self.playerView startRedPacketWithModel:model];
    }];
}

/// 抢红包
/// @param redPacketId 红包雨ID
- (void)gradRedPacketWithRedPacketId:(NSString *)redPacketId {
    [self.requestData gradRedPacket:redPacketId closure:^(BOOL result) {
        
    }];
}

/// 查询红包排行
/// @param redPacketId 红包雨ID
- (void)requsetRedPacketRankWithReadPacketId:(NSString *)redPacketId {
    [self.requestData requestRedPacketRankList:redPacketId closure:^(HDSRedPacketRankModel *model) {
        [self.playerView showRedPacketRankWithModel:model];
    }];
}

// MARK: - 视频区辅助视图
/// 3.17.3 new 更新辅助视图
- (void)updateSupportView {
    //#ifdef LIANMAI_WEBRTC
    if (_isRTCLive || _isMediaCalled) return;
    //#endif
    if (_supportView.hidden == YES) {
        _supportView.hidden = NO;
    }
    [_supportView setSupportBaseType:_kSupportBaseType boardView:_kPlayerParent];
}

/**
 *    The New Method (3.14.0)
 *    @brief    是否开启音频模式
 *    @param    hasAudio   HAVE_AUDIO_LINE_TURE 有音频 HAVE_AUDIO_LINE_FALSE 无音频
 *
 *    触发回调条件 1.初始化SDK登录成功后
 */
- (void)HDAudioMode:(HAVE_AUDIO_LINE)hasAudio {
    [self.playerView HDAudioMode:hasAudio];
}
/**
 *    The New Method (3.14.0)
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
 *    The New Method (3.14.0)
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
/**
 *    @brief    切换音视频模式
 *    @param    isAudio   是否是音频
 */
- (void)changePlayMode:(BOOL)isAudio {
    _isAudioMode = isAudio == YES ? YES : NO;
    WS(ws)
    if (isAudio == YES) {
        [_requestData changePlayMode:PLAY_MODE_TYEP_AUDIO completion:^(NSDictionary *results) {
            NSInteger result = [results[@"success"] integerValue];
            [ws showTextWithIndex:result];
            [ws.playerView updateUITier];
            /// 3.17.3 new
            ws.kSupportBaseType = HDSSupportViewBaseTypeAudio;
        }];
    }else {
        [_requestData changePlayMode:PLAY_MODE_TYEP_VIDEO completion:^(NSDictionary *results) {
            NSInteger result = [results[@"success"] integerValue];
            [ws showTextWithIndex:result];
            [ws.playerView updateUITier];
            /// 3.17.3 new
            ws.kSupportBaseType = HDSSupportViewBaseTypeNone;
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
    [_requestData changeLine:rodIndex completion:^(NSDictionary *results) {
        NSInteger result = [results[@"success"] integerValue];
        [ws showTextWithIndex:result];
        [ws.playerView updateUITier];
        /// 3.17.3 new
        if (ws.isAudioMode == YES) {
            ws.kSupportBaseType = HDSSupportViewBaseTypeAudio;
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
    [_requestData changeQuality:quality completion:^(NSDictionary *results) {
        NSInteger result = [results[@"success"] integerValue];
        [ws showTextWithIndex:result];
        [ws.playerView updateUITier];
    }];
}

/**
 *    @brief    显示答题卡和随堂测
 *    @param    type   1 答题卡 0 随堂测
 */
- (void)updateVoteAndTestWithType:(NSInteger)type
{
    if (type == 1) {
        [self.voteView updateUIWithScreenLandScape:self.screenLandScape];
        [self.voteView show];
    }else {
        [self.testView updateTestViewWithScreenlandscape:self.screenLandScape];
        [self.testView show];
    }
}

#pragma mark - playViewDelegate 以及相关方法
/**
 *    @brief    点击切换视频/文档按钮
 *    @param    tag    1为视频为主，2为文档为主
 */
- (void)changeBtnClicked:(NSInteger)tag {
//    if (self.playerView.isOnlyVideoMode) { return; }
    self.playerView.isVideoMainScreen = tag == 1;
    self.contentView.docContentView.hidden = tag == 2;
    
    if (tag == 2) { // 将文档放在主窗口
        self.isDocMainScreen = YES;
        
        [self.hds_playerView removeFromSuperview];
        [self.requestData changeDocFrame:self.playerView.hdContentView.bounds];
        [self.requestData changeDocParent:self.playerView.hdContentView];
        
        /// 3.18.0 new
        if (_isSmallDocView) { // 将视频放在小窗口
            self.hds_playerView.frame = self.playerView.smallVideoView.hdContentView.bounds;
            [self.playerView.smallVideoView.hdContentView addSubview:self.hds_playerView];
            /// 3.17.3 new
            self.playerView.headerView.hidden = YES;
            self.kPlayerParent = self.playerView.smallVideoView.headerView;
            /// 3.18.0 new
            self.hds_playerContentView = self.playerView.smallVideoView.hdContentView;
        } else {
            [self.contentView.segment setTitle:@"视频" forSegmentAtIndex:0];
            self.hds_playerView.frame = self.contentView.videoContentView.bounds; // 注意视频尺寸
            [self.contentView.videoContentView addSubview:self.hds_playerView];
            /// 3.17.3 new
            self.playerView.headerView.hidden = YES;
            self.kPlayerParent = self.contentView.videoContentView;
            /// 3.18.0 new
            self.hds_playerContentView = self.contentView.videoContentView;
        }
    } else { // 将视频放在主窗口
        self.isDocMainScreen = NO;
        
        /// 3.18.0 new
        [self.hds_playerView removeFromSuperview];
        self.hds_playerView.frame = self.playerView.hdContentView.bounds;
        [self.playerView.hdContentView addSubview:self.hds_playerView];
        /// 3.17.3 new
        self.playerView.headerView.hidden = NO;
        self.kPlayerParent = self.playerView.headerView;
        /// 3.18.0 new
        self.hds_playerContentView = self.playerView.hdContentView;
        
        if (_isSmallDocView) { // 将文档放在小窗口
            [self.requestData changeDocFrame:self.playerView.smallVideoView.hdContentView.bounds];
            [self.requestData changeDocParent:self.playerView.smallVideoView.hdContentView];
        } else {
            [self.contentView.segment setTitle:@"文档" forSegmentAtIndex:0];
            [self.requestData changeDocFrame:self.contentView.docContentView.bounds];
            [self.requestData changeDocParent:self.contentView.docContentView];
        }
    }
    
    [self.playerView.hdContentView bringSubviewToFront:self.marqueeView];
    [self.playerView updateUITier];
    /// 3.17.3 new
    [self updateSupportView];
    
    //#ifdef LIANMAI_WEBRTC
    /// 3.18.0 new
    if (!_isMutilMediaCallRoom) {
        [self updateRemoteView];
    }else {
        [self update_hds_multi_remoteView];
    }
    //#endif
}
/**
 *    @brief    点击全屏按钮代理
 *    @param    tag   1为视频为主，2为文档为主
 */
- (void)quanpingButtonClick:(NSInteger)tag {
    [self.view endEditing:YES];
    [APPDelegate.window endEditing:YES];
    self.docOrVideoFlag = tag;
    [self.contentView.chatView resignFirstResponder];
    [self othersViewHidden:YES];

//    if (_interManager) {
//        [_interManager screenOrientationDidChange:landspace];
//    }
//    HDSVoteTool.tool.isLandspace = YES;
//
//    CGFloat width = self.view.width;
//    //#ifdef LIANMAI_WEBRTC
//    if (_isMutilMediaCallRoom) {
//        if ( _callBarType == HDSMultiMediaCallBarTypeVideoCalled) {
//            width = width - 189.5;
//        }
//        self.callBarConfig.callType = _callBarType;
//        [self updateCallBarStatusConfig:self.callBarConfig];
//    }
//    //#endif
//    if (tag == 1) {
//        /// 3.18.0 new
//        self.hds_playerView.frame = CGRectMake(0, 0, width, self.view.height);
//        self.hds_playerContentView.frame = CGRectMake(0, 0, width, self.view.height);
//        /// 3.17.3 new
//        _kPlayerParent.frame = CGRectMake(0, 0, width, self.view.height);
//    } else {
//        [_requestData changeDocFrame:CGRectMake(0, 0, width, self.view.height)];
//    }
//    /// 3.17.3 new
//    [self updateSupportView];
//    //#ifdef LIANMAI_WEBRTC
//    if (!_isMutilMediaCallRoom) {
//        /// 3.18.0 new
//        [self updateRemoteView];
//    }else {
//        [self update_hds_multi_remoteView];
//    }
//    //#endif
//    WS(ws)
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [ws.marqueeView startMarquee];
//    });
//    self.screenLandScape = YES;
//    if (self.playerView.templateType != 1) {
//        [self.playerView updateVoteWithLandScapeWithCompletion:^(BOOL result) {
//            [ws.voteView updateUIWithScreenLandScape:result];
//        }];
//        [self.playerView updateTestWithLandScapeWithCompletion:^(BOOL result) {
//            [ws.testView updateTestViewWithScreenlandscape:result];
//        }];
//    }
}
/**
 *    @brief    点击退出按钮(返回竖屏或者结束直播)
 *    @param    sender backBtn
 *    @param tag changeBtn的标记，1为视频为主，2为文档为主
 */
- (void)backButtonClick:(UIButton *)sender changeBtnTag:(NSInteger)tag{
    //WS(ws)
    self.docOrVideoFlag = tag;
    if (sender.tag == 2) {//横屏返回竖屏
        self.screenLandScape = NO;
        [self othersViewHidden:NO];
//        HDSVoteTool.tool.isLandspace = NO;
//        if (_interManager) {
//            [_interManager screenOrientationDidChange:portrait];
//        }
//
//
//        //#ifdef LIANMMAI_WERBRTC
//        if (self.isNeedUpdateFlag) {
//            [self updateRoomSubviews:self.isNeedUpdateStatus];
//            self.isNeedUpdateFlag = NO;
//        }
//        //#endif
//        if (tag == 1) {
//            self.hds_playerView.frame = CGRectMake(0, 0, SCREEN_WIDTH, HDGetRealHeight);
//            /// 3.17.3 new
//            _kPlayerParent.frame = CGRectMake(0, 0, SCREEN_WIDTH, HDGetRealHeight);
//            /// 3.18.0 new
//            self.hds_playerContentView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
//        } else {
//            [_requestData changeDocFrame:CGRectMake(0, 0, SCREEN_WIDTH, HDGetRealHeight)];
//        }
//        /// 3.17.3 new
//        [self updateSupportView];
//
//        //#ifdef LIANMAI_WEBRTC
//        if (!_isMutilMediaCallRoom) {
//            [self updateRemoteView];
//        }else {
//            [self update_hds_multi_remoteView];
//        }
//        self.callBarConfig.callType = _callBarType;
//        [self updateCallBarStatusConfig:self.callBarConfig];
//        //#endif
//
//        WS(ws)
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            self.playerView.backButton.userInteractionEnabled = YES;
//            [ws.marqueeView startMarquee];
//        });
    }else if( sender.tag == 1){//结束直播
        [self hds_onExit];
    }
}
/**
 *    @brief    隐藏其他视图,当点击全屏和退出全屏时调用此方法
 *    @param    hidden   是否隐藏
 */
- (void)othersViewHidden:(BOOL)hidden {
    self.screenLandScape = hidden; // 设置横竖屏
    self.contentView.chatView.ccPrivateChatView.hidden = hidden; // 隐藏聊天视图
    self.isScreenLandScape = hidden;
    [self interfaceOrientation: hidden ? UIInterfaceOrientationLandscapeRight : UIInterfaceOrientationPortrait];
    self.contentView.hidden = hidden;//隐藏互动视图
    [self.menuView hiddenMenuViews:hidden];
    self.announcementView.hidden = hidden;//隐藏公告视图
    if (!hidden) {//更新新消息
        [_menuView updateMessageFrame];
    }
}

/**
 *    @brief    退出直播
 */
- (void)exitPlayLive {
    
    UIWindow *keyWindow = APPDelegate.window;
    for (UIView *oneView in keyWindow.subviews) {
        if (oneView.tag != 0) {
            [oneView removeFromSuperview];
        }
    }
    
    [_requestData shutdownPlayer];
    
    [self removeQuestionnaireSurvey];
    
    //#ifdef LIANMAI_WEBRTC
    [self.requestData hangup:nil];
    if (_callBar) {
        [_callBar removeFromSuperview];
        _callBar = nil;
    }
    if (_playerView.lianMaiView) {
        [_playerView removeLianMaiView];
    }
    //#endif
    
    self.requestData.delegate = nil;
    
    if (self.playerView.smallVideoView) {
        [self.playerView.smallVideoView removeFromSuperview];
    }
    if (self.contentView) {
        //移除聊天
        [self.contentView removeChatView];
        [_announcementView removeFromSuperview];
    }
    //移除多功能菜单
    if (self.menuView) {
        [self.menuView removeFromSuperview];
        [self.menuView removeAllInformationView];
    }
    /// 3.17.3 new
    if (_supportView) {
        [_supportView kRelease];
        [_supportView removeFromSuperview];
        _supportView = nil;
    }
    
    /// 3.18.0 new
    if (_kPlayerParent) {
        [_kPlayerParent removeFromSuperview];
        _kPlayerParent = nil;
    }
    
    if (_hds_playerView) {
        [_hds_playerView removeFromSuperview];
        _hds_playerView = nil;
    }
    
    /// 3.18.0 new
    if (_hds_playerContentView) {
        [_hds_playerContentView removeFromSuperview];
        _hds_playerContentView = nil;
    }
    
//    if (_contentView.docView) {
//        [_contentView.docView removeFromSuperview];
//    }

    self.isDismiss = YES;
    if (_interManager) {
        [_interManager killAll];
        _interManager = nil;
    }
    WS(weakSelf)
    [self dismissViewControllerAnimated:YES completion:^{
        [weakSelf.requestData requestCancel];
        weakSelf.requestData = nil;
        weakSelf.requestData.delegate = nil;
        [weakSelf.playerView removeFromSuperview];
        weakSelf.playerView.delegate = nil;
        weakSelf.playerView = nil;
        [weakSelf.contentView removeFromSuperview];
        weakSelf.contentView = nil;
        if (weakSelf.interManager) {
            [weakSelf.interManager killAll];
            weakSelf.interManager = nil;
        }
    }];
}

/// 4.10.0 new
/// 请求登陆成功
- (void)onRequestLoginSucced {
    
}

/// 4.10.0 new
/// 请求登陆失败
/// @param code code值
/// @param message 错误信息
- (void)onRequstLoginFailed:(NSUInteger)code message:(NSString *)message {
    NSString *errorTipString = [HDSLoginErrorManager loginErrorCode:code message:message];
    if (errorTipString.length == 0) {
        errorTipString = [NSString stringWithFormat:@"错误码:%zd",code];
    }
    [self hds_exitReLoginSingBtnWithTipStr:errorTipString];
}
#pragma mark - SDK 必须实现的代理方法
/**
 *    @brief    请求成功
 */
- (void)requestSucceed {

}
/**
 *    @brief    登录请求失败
 */
- (void)requestFailed:(NSError *)error reason:(NSString *)reason {
    NSString *message = nil;
    if (reason == nil) {
        message = [error localizedDescription];
    } else {
        message = reason;
    }
    if (![message isEqualToString:self.errorTip]) {
        if ([message isEqualToString:@"加载视频超时，请重试"]) {
            [self showTipInfomationWithTitle:message];
        } else {
            // 添加提示窗,提示message
            [self addSingleBtnAlertView:message];
        }
        self.errorTip = message;
    }
}

- (void)onError:(HDSOnErrorModel *)model {
    switch (model.type) {
        case OnErrorType_LoginFailed: {
            //[self hds_exitReLoginSingBtnWithTipStr:model.message];
        } break;
            
        case OnErrorType_GetSummaryFailed: {
            [self hds_exitReLoginSingBtnWithTipStr:model.message];
        } break;
            
        case OnErrorType_GetPlaySourceFailed: {
            [self hds_exitReLoginSingBtnWithTipStr:model.message];
        } break;
            
        default:
            break;
    }
}

#pragma mark- 功能代理方法 用哪个实现哪个-----
/**
 *    @brief    播放器初始化完成 (会多次回调)
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
- (void)HDSMediaPlayBackStateDidChange:(HDSMediaPlaybackState)state
{
    switch (state)
    {
        case HDSMediaPlaybackStateStopped: {
            break;
        }
        case HDSMediaPlaybackStatePlaying:{
            self.isPlayerLoadStateStalled = NO; //重试卡顿状态
            self.isPlayFailed = NO; //重置播放失败状态
            /// 3.17.3 new
            if (_supportView && _supportView.hidden == NO && !_isAudioMode) {
                _kSupportBaseType = HDSSupportViewBaseTypeNone;
                _supportView.hidden = YES;
            }
            if (_playerView.loadingView) {
                [_playerView.loadingView removeFromSuperview];
            }
            [[SaveLogUtil sharedInstance] saveLog:@"" action:SAVELOG_ALERT];
            //#ifdef LockView
            if (_pauseInBackGround == NO) {//添加锁屏视图
                if (!_lockView) {
                    _lockView = [[CCLockView alloc] initWithRoomName:_roomName duration:0];
                    [self.view addSubview:_lockView];
                }else{
                    [_lockView updateLockView];
                }
            }
            //#endif
            break;
        }
        case HDSMediaPlaybackStatePaused:{
            break;
        }
        case HDSMediaPlaybackStateInterrupted: {
            break;
        }
        case HDSMediaPlaybackStateSeekingForward:
        case HDSMediaPlaybackStateSeekingBackward: {
            break;
        }
        default: {
            break;
        }
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
        case HDSMediaLoadStateStalled:{
            self.isPlayerLoadStateStalled = YES;
            /// 3.17.3 new
            _isPlayerLoadStateStalled = YES;
        }break;
        default:
            break;
    }
}
/**
 *  @brief  获取ppt当前页数和总页数 (会多次回调)
 *
 *  回调当前翻页的页数信息
 *  白板docTotalPage一直为0, pageNum从1开始
 *  其他文档docTotalPage为正常页数,pageNum从0开始
 *  @param dictionary 翻页信息
 */
- (void)onPageChange:(NSDictionary *)dictionary {
    
}
/**
 *    @brief     获取所有文档列表 需要调用getDocsList
 */
- (void)receivedDocsList:(NSDictionary *)listDic {
    
}
/**
 *    @brief    双击PPT
 */
- (void)doubleCllickPPTView {
    if (_isLivePlay == NO) return;
    if (_screenLandScape) {//如果是横屏状态下
        _screenLandScape = NO;
        _isScreenLandScape = YES;
        // 新增方法 --> 处理全屏双击PPT退出全屏操作，统一由PlayView管理
        // 注：该方法不影响连麦操作
        [_playerView backBtnClickWithTag:2];
    }else{
        _screenLandScape = YES;
        /// 4.5.1 new
        // 新增方法 --> 处理双击PPT进入全屏操作，统一由PlayView管理
        // 注：该方法不影响连麦操作
        [_playerView quanpingBtnClick];
    }
}
#pragma mark - 房间信息
/**
 *    @brief  获取房间信息，主要是要获取直播间模版来类型，根据直播间模版类型来确定界面布局
 *    房间简介：dic[@"desc"];
 *    房间名称：dic[@"name"];
 *    房间模版类型：[dic[@"templateType"] integerValue];
 *    模版类型为1: 聊天互动： 无 直播文档： 无 直播问答： 无
 *    模版类型为2: 聊天互动： 有 直播文档： 无 直播问答： 有
 *    模版类型为3: 聊天互动： 有 直播文档： 无 直播问答： 无
 *    模版类型为4: 聊天互动： 有 直播文档： 有 直播问答： 无
 *    模版类型为5: 聊天互动： 有 直播文档： 有 直播问答： 有
 *    模版类型为6: 聊天互动： 无 直播文档： 无 直播问答： 有
 */
- (void)roomInfo:(NSDictionary *)dic {
    _roomName = dic[@"name"];
    _roomDesc = dic[@"desc"];
    if ([dic.allKeys containsObject:@"liveStartTime"]) {
        _liveStartTime = dic[@"liveStartTime"];
    }
    self.openmarquee = [dic[@"openMarquee"] boolValue];
    //添加更多菜单
    if (_menuView) {
        [_menuView removeFromSuperview];
    }
    [APPDelegate.window addSubview:self.menuView];
        
    [self.playerView roominfo:dic];
    NSInteger type = [dic[@"templateType"] integerValue];
    if (type == 4 || type == 5) {
        self.playerView.isOnlyVideoMode = NO;
        [self.playerView addSmallView];
        self.isDocMainScreen = YES;
    } else {
        /// 3.18.0 new
        self.hds_playerContentView = self.playerView.hdContentView;
        self.playerView.isOnlyVideoMode = YES;
        // 1.仅有视频模式下 视频显示大窗
        [self changeBtnClicked:1];
    }
    _isHiddenPrivateChat = NO;
    if ([dic[@"privateChat"] integerValue] == 0) {
        _isHiddenPrivateChat = YES;
        [_menuView hiddenPrivateBtn];
    }
    _contentView.privateChatStatus = [dic[@"privateChat"] integerValue];
    WS(ws)
    _playerView.cleanVoteAndTestBlock = ^(NSInteger type) {
        [ws updateVoteAndTestWithType:type];
    };
    _contentView.cleanVoteAndTestBlock = ^(NSInteger type) {
        [ws updateVoteAndTestWithType:type];
    };
    
     //设置房间信息
    [_contentView roomInfo:dic withPlayView:self.playerView smallView:self.playerView.smallVideoView];
    _playerView.templateType = type;
    if (type != 1) {//如果只有视频的版型，去除menuView;
        _playerView.menuView = _menuView;
    }else {
        if (_menuView) {
            _menuView.hidden = YES;
            //[_menuView removeFromSuperview];
            //_menuView = nil;
        }
        return;
    }
    if (type == 6) {//去除私聊按钮
        [_menuView hiddenPrivateBtn];
    }
}

// MARK: - 4.11.0 new Room Configure
- (void)onRoomConfigure:(HDSRoomConfigureModel *)configure {
    if (_contentView) {
        [_contentView setQaIcon:configure.QPSwitch];
    }
}

#pragma mark - 获取直播开始时间和直播时长
/**
 *  @brief  获取直播开始时间和直播时长
 *  liveDuration 直播持续时间，单位（s），直播未开始返回-1"
 *  liveStartTime 新增开始直播时间（格式：yyyy-MM-dd HH:mm:ss），如果直播未开始，则返回空字符串
 */
- (void)startTimeAndDurationLiveBroadcast:(NSDictionary *)dataDic {
    NSTimeInterval startTime = [dataDic[@"liveStartTime"] integerValue];
    NSString *startTimeStr = [NSString stringWithFormat:@"%zd",(long)startTime / 1000];
    SaveToUserDefaults(LIVE_STARTTIME, startTimeStr);
    //当第一次进入时为未开始状态,设置此属性,在直播开始时给startTime赋值
    if ([dataDic[@"liveStartTime"] isEqualToString:@""] && !self.firstUnStart) {
        self.firstUnStart = YES;
    }
}
#pragma mark- 收到在线人数
/**
 *    @brief    收到在线人数
 */
- (void)onUserCount:(NSString *)count {
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        //self.playerView.userCountLabel.text = count;
        [weakSelf.playerView updateRoomUserCount:count];
    });
}

#pragma mark - 打卡功能
/**
 *    @brief    移除打卡视图
 */
- (void)removePunchView {
    if (_punchView) {
        [_punchView removeFromSuperview];
        _punchView = nil;
    }
}
/**
 *    @brief    打卡功能
 *    @param    dic   打卡数据
 */
- (void)hdReceivedStartPunchWithDict:(NSDictionary *)dic {
    
    if (_punchView) {
        [_punchView removeFromSuperview];
    }
    WS(weakSelf)
    self.punchView = [[CCPunchView alloc] initWithDict:dic punchBlock:^(NSString * punchid) {
        [weakSelf.requestData hdCommitPunchWithPunchId:punchid];
    } isScreenLandScape:self.isScreenLandScape];
    self.punchView.commitSuccess = ^(BOOL success) {
        [weakSelf removePunchView];
    };
    [APPDelegate.window addSubview:self.punchView];
    _punchView.frame = [UIScreen mainScreen].bounds;
    
    [self showRollCallView];
}
/**
 *    @brief    收到结束打卡
 *    dic{ "punchId": "punchId"}
 */
- (void)hdReceivedEndPunchWithDict:(NSDictionary *)dic {
    [self.punchView updateUIWithFinish:dic];
}
/**
 *    @brief    收到打卡提交结果
 *    dic{
 *    "success": true,
 *    "data": {"isRepeat": false//是否重复提交打卡 }
 }
 */
- (void)hdReceivedPunchResultWithDict:(NSDictionary *)dic {
    [self.punchView updateUIWithDic:dic];
}
#pragma mark - 服务器端给自己设置的信息
/**
 *    @brief    服务器端给自己设置的信息
 *    viewerId 服务器端给自己设置的UserId
 *    groupId 分组id
 *    name 用户名
 */
- (void)setMyViewerInfo:(NSDictionary *) infoDic {
    _viewerId = infoDic[@"viewerId"];
    if ([infoDic.allKeys containsObject:@"name"]) {
        _viewerName = infoDic[@"name"];
    }else {
        _viewerName = GetFromUserDefaults(WATCH_USERNAME);//用户名
    }
    [_contentView setMyViewerInfo:infoDic];
}
#pragma mark - 聊天管理
/**
 *    @brief    聊天管理
 *    status    聊天消息的状态 0 显示 1 不显示
 *    chatIds   聊天消息的id列列表
 */
- (void)chatLogManage:(NSDictionary *) manageDic {
    [_contentView chatLogManage:manageDic];
}
#pragma mark - 聊天
/**
 *    @brief    收到私聊信息
 *    @param    dic {fromuserid         //发送者用户ID
 *                   fromusername       //发送者用户名
 *                   fromuserrole       //发送者角色
 *                   msg                //消息内容
 *                   time               //发送时间
 *                   touserid           //接受者用户ID
 *                   tousername         //接受者用户名}
 */
- (void)OnPrivateChat:(NSDictionary *)dic {
    if (_isHiddenPrivateChat != YES) {
        [_contentView OnPrivateChat:dic withMsgBlock:^{
            [self.menuView showInformationViewWithTitle:NewPrivateMessage];
        }];
    }
}
/**
 *    @brief  历史聊天数据 (会多次回调)
 *    @param  chatLogArr [{ chatId         //聊天ID
                           content         //聊天内容
                           groupId         //聊天组ID
                           time            //时间
                           userAvatar      //用户头像
                           userId          //用户ID
                           userName        //用户名称
                           userRole        //用户角色}]
 */
- (void)onChatLog:(NSArray *)chatLogArr {
    [_contentView onChatLog:chatLogArr];
}
/*
 *  @brief  收到公聊消息
 *  @param  message {  groupId         //聊天组ID
                       msg             //消息内容
                       time            //发布时间
                       useravatar      //用户头像
                       userid          //用户ID
                       username        //用户名称
                       userrole        //用户角色}
 */
- (void)onPublicChatMessage:(NSDictionary *)dic {
    [_contentView onPublicChatMessage:dic];
}
/**
 *  @brief  接收到发送的广播
 *  @param  dic {content     //广播内容
                 userid      //发布者ID
                 username    //发布者名字
                 userrole    //发布者角色 }
 */
- (void)broadcast_msg:(NSDictionary *)dic {
    [_contentView broadcast_msg:dic];
}
/*
 *  @brief  收到自己的禁言消息，如果你被禁言了，你发出的消息只有你自己能看到，其他人看不到
 *  @param  message {  groupId         //聊天组ID
                       msg             //消息内容
                       time            //发布时间
                       useravatar      //用户头像
                       userid          //用户ID
                       username        //用户名称
                       userrole        //用户角色}
 */
- (void)onSilenceUserChatMessage:(NSDictionary *)message {
    [_contentView onSilenceUserChatMessage:message];
}
/**
 *    @brief    历史广播数组
 *    @param    array   历史广播数组
 *              array [{
                           content         //广播内容
                           userid          //发布者ID
                           username        //发布者名字
                           userrole        //发布者角色
                           createTime      //绝对时间
                           time            //相对时间(相对直播)
                           id              //广播ID }]
 */
- (void)broadcastLast_msg:(NSArray *)array {
    [_contentView broadcastLast_msg:array];
}

/**
*    @brief    删除广播
*    @param    dic   广播信息
*              dic {action             //操作 1.删除
                    id                 //广播ID }
*/
- (void)broadcast_delete:(NSDictionary *)dic {
    [_contentView broadcast_delete:dic];
}
#pragma mark - 禁言
/**
 *    @brief    当主讲全体禁言时，你再发消息，会出发此代理方法，information是禁言提示信息
 */
- (void)information:(NSString *)information {
    //添加提示窗
    [self addSingleBtnAlertView:information];
}
/**
 *    @brief  收到踢出消息，停止推流并退出播放（被主播踢出）
 *            dictionary[@"kick_out_type"] 踢出类型
 *            dictionary[@"viewerid"]      用户ID
 *            kick_out_type: 踢出类型
 *                           10 在允许重复登录前提下，后进入者会登录会踢出先前登录者
 *                           20 讲师、助教、主持人通过页面踢出按钮踢出用户
  *
 */
- (void)onKickOut:(NSDictionary *)dictionary {
    if ([_viewerId isEqualToString:dictionary[@"viewerid"]]) {
        [self hds_exitReLoginSingBtnWithTipStr:ALERT_KICKOUT];
    }
}

#pragma mark - 问答

- (void)onQuestionPictureSwitch:(NSInteger)QPSwitch {
//    if (_contentView) {
//        BOOL qaIcon = QPSwitch == 1 ? YES : NO;
//        [_contentView setQaIcon:qaIcon];
//    }
}

/**
 *    @brief    发布问答的id
 */
- (void)publish_question:(NSString *)publishId {
    [_contentView publish_question:publishId];
}
/**
 *    @brief  收到提问，用户观看时和主讲的互动问答信息
 *    @param  questionDic { groupId         //分组ID
                            content         //问答内容
                            userName        //问答用户名
                            userId          //问答用户ID
                            time            //问答时间
                            id              //问答主键ID
                            useravatar      //用户化身 }
 */
- (void)onQuestionDic:(NSDictionary *)questionDic {
    [_contentView onQuestionDic:questionDic];
}
/**
 *    @brief  收到回答
 *    @param  answerDic {content            //回复内容
                         userName           //用户名
                         questionUserId     //问题用户ID
                         time               //回复时间
                         questionId         //问题ID
                         isPrivate          //1 私聊回复 0 公聊回复 }
 */
- (void)onAnswerDic:(NSDictionary *)answerDic{
    [_contentView onAnswerDic:answerDic];
}
/**
 *    @brief  收到历史提问&回答 （会多次回调）
 *    @param  questionArr [{content             //问答内容
                            encryptId           //加密ID
                            groupId             //分组ID
                            isPublish           //1 发布的问答 0 未发布的问答
                            questionUserId      //问答用户ID
                            questionUserName    //问答用户名
                            time                //问答时间
                            triggerTime         //问答具体时间}]
 *    @param  answerArr  [{answerUserId         //回复用户ID
                           answerUserName       //回复名
                           answerUserRole       //回复角色（主讲、助教）
                           content              //回复内容
                           encryptId            //加密ID
                           groupId              //分组ID
                           isPrivate            //1 私聊回复 0 公共回复
                           time = 135;          //回复时间
                           triggerTime          //回复具体时间}]
 */
- (void)onQuestionArr:(NSArray *)questionArr onAnswerArr:(NSArray *)answerArr{
    [_contentView onQuestionArr:questionArr onAnswerArr:answerArr];
}
/**
 *    @brief    提问
 *    @param    message 提问内容
 */
- (void)question:(NSString *)message {
    [_requestData question:message];
}
#pragma mark - 直播未开始和开始
- (NSMutableArray *)secRoadKeyArray
{
    if (!_secRoadKeyArray) {
        _secRoadKeyArray = [NSMutableArray array];
    }
    return _secRoadKeyArray;
}
#pragma mark- 直播未开始和开始
/**
 *    @brief  收到播放直播状态 0.正在直播 1.未开始直播
 */
- (void)getPlayStatue:(NSInteger)status {
    [_playerView getPlayStatue:status];
    //直播状态
    _isLivePlay = status == 0 ? YES : NO;
    if (status == 0 && self.firstUnStart) {
        NSDate *date = [NSDate date];// 获得时间对象
        NSDateFormatter *forMatter = [[NSDateFormatter alloc] init];
        [forMatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSString *dateStr = [forMatter stringFromDate:date];
        SaveToUserDefaults(LIVE_STARTTIME, dateStr);
    }
    if (status == 0 && _nonFirstQuery == NO) {
        // 收到播放直播状态后重新获取随堂测(断网重连后需要重新获取)
        [_requestData getPracticeInformation:@""];
        // 抽奖2.0 查询抽奖状态
        [_requestData queryLotteryStatus];
        if (!_questionnaireSurvey) {
            // 查询正在进行中的问卷
            [_requestData getPublishingQuestionnaire];
        }
        // 打卡
        if (!_punchView) {
            [_requestData hdInquirePunchInformation];
        }
        // 查询正在进行的红包雨
        [self requestRedPacketWithRedPacketId:@""];
        
        _nonFirstQuery = YES;
    } else {
        _nonFirstQuery = NO;
        [_hds_playerView removeFromSuperview];
        _hds_playerView = nil;
        //#ifdef LIANMAI_WEBRTC
        [self hangup:NO];
        //#endif
    }
}
#pragma mark - 开始结束直播
/**
 *    @brief  主讲开始推流 (已废弃)
 */
- (void)onLiveStatusChangeStart {
    _isLivePlay = YES; //直播停止
    [_playerView streamDidBegin];
}
/**
 *    @brief  停止直播，endNormal表示是否停止推流 （已废弃）
 */
- (void)onLiveStatusChangeEnd:(BOOL)endNormal {
    if (_hds_playerView) {
        [_hds_playerView removeFromSuperview];
    }
    _isLivePlay = NO; //直播停止
    if (self.punchView) {
        [self removePunchView];
    }
    [_playerView streamDidEnd:endNormal];
}

/// 主讲开始推流
- (void)streamDidBegin {
    _isLivePlay = YES; //直播停止
    [_playerView streamDidBegin];
}

/// 主讲结束推流
/// @param endNormal 是否正常停止直播
/// @param tip       提示语 (提示语可为空)
- (void)streamDidEnd:(BOOL)endNormal tip:(NSString *)tip {
    
    if (tip.length > 0 && tip != nil) {
        [self addSingleBtnAlertView:tip];
    }
    
    if (_hds_playerView) {
        [_hds_playerView removeFromSuperview];
    }
    _nonFirstQuery = NO;
    _isLivePlay = NO; //直播停止
    if (self.punchView) {
        [self removePunchView];
    }
    [_playerView streamDidEnd:endNormal];
    
    [self.interManager streamDidEnd];
}
#pragma mark - 抽奖2.0

- (void)hds_sendUpdateConstraintNotificationToLotteryView {
    if (_baseAnimationManager == nil) {
        return;
    }
    if ([UIScreen mainScreen].bounds.size.width > [UIScreen mainScreen].bounds.size.height) {
        [self showTipInfomationWithTitle:@"请切换至竖屏参与抽奖！"];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"newLotteryUpdateFrame" object:nil];
}

/**
 *    @brief    抽奖2.0 抽奖状态
 *    @param    model   NewLotteryMessageModel 详情
 */
- (void)HDOnLotteryWithModel:(NewLotteryMessageModel *)model
{
    WS(ws)
    /** 1.抽奖1.0存在 移除抽奖1.0 */
    if (_lotteryView && model.haveLottery) {
        [_lotteryView removeFromSuperview];
    }
    /** 2.当前没有正在进行的抽奖,并且当前不在抽奖完成页面 */
    if (model.type == NEW_LOTTERY_NULL && _isnLotteryComplete == NO) { //无抽奖
        if (_nLotteryView) {
            [_nLotteryView removeFromSuperview];
        }
    }else if (model.type == NEW_LOTTERY_BEGIN) { //开始抽奖
        _isnLotteryComplete = NO;
        if (_nLotteryView) {
            [_nLotteryView removeFromSuperview];
        }
        self.nLotteryView = [[NewLotteryView alloc] initIsScreenLandScape:self.screenLandScape clearColor:NO];
        [APPDelegate.window addSubview:self.nLotteryView];
        _nLotteryView.frame = [UIScreen mainScreen].bounds;
        _nLotteryView.closeBlock = ^(BOOL result) {
            [ws.nLotteryView endEditing:YES];
            ws.nLotteryView.hidden = YES;
        };
        /// 4.6.0 new 区分抽奖类型
        NSDictionary *infos = model.infos;
        if ([infos.allKeys containsObject:@"lotteryType"]) {
            NSInteger lotteryType = [[infos objectForKey:@"lotteryType"] integerValue];
            self.lotteryType = lotteryType;
            self.nLotteryView.hidden = NO;
            if (lotteryType == 1) {
                // 老虎机
                /// [修460Bug] 横屏不能展示老虎机
                /// 38961 【ios_4.6.0】老虎机不应支持横屏
                self.nLotteryView.hidden = YES;
                NSMutableArray *normalDatas = [NSMutableArray array];
                if ([infos.allKeys containsObject:@"onlineUsers"]) {
                    NSArray *users = infos[@"onlineUsers"];
                    for (NSDictionary *dict in users) {
                        [normalDatas addObject:[self getAnimationModel:dict]];
                    }
                }
                HDSBaseAnimationModel *baseModel = [[HDSBaseAnimationModel alloc]init];
                if ([infos.allKeys containsObject:@"prize"]) {
                    NSDictionary *prizeDic = [infos objectForKey:@"prize"];
                    if ([prizeDic.allKeys containsObject:@"name"]) {
                        baseModel.prizeName = [prizeDic objectForKey:@"name"];
                    }
                }
                
                if ([infos.allKeys containsObject:@"prizeNum"]) {
                    baseModel.prizeNum = [[infos objectForKey:@"prizeNum"] integerValue];
                }
                if ([infos.allKeys containsObject:@"onlineNumber"]) {
                    baseModel.onlineNumber = [[infos objectForKey:@"onlineNumber"] integerValue];
                }
                if (_baseAnimationManager) {
                    [_baseAnimationManager killAll];
                    _baseAnimationManager = nil;
                }
                _baseAnimationManager = [[HDSAnimationManager alloc] initWithBoardView:APPDelegate.window configure:baseModel btnsTapClosure:^(NSInteger tag) {
                    [ws btnsTap:tag];
                }];
                [_baseAnimationManager setNormalData:normalDatas];
                
                [self hds_sendUpdateConstraintNotificationToLotteryView];
            }
        }
    }else if (model.type == NEW_LOTTERY_CANCEL) { //抽奖取消
        _isnLotteryComplete = NO;
        if (self.lotteryType == 1) {
            [_baseAnimationManager killAll];
            _baseAnimationManager = nil;
        }
        [self.nLotteryView remove];
        CCAlertView *alertView = [[CCAlertView alloc] initWithAlertTitle:NEWLOTTERY_CANCEL sureAction:SURE cancelAction:nil sureBlock:^{
            ws.playerView.isChatActionKeyboard = YES;
            ws.contentView.isChatActionKeyboard = YES;
        }];
        [APPDelegate.window addSubview:alertView];
    }else if (model.type == NEW_LOTTERY_COMPLETE) { //抽奖结束
        _nLotteryId = model.infos[@"lotteryId"];
        _isnLotteryComplete = YES;
        if (self.lotteryType == 1) {
            if (_baseAnimationManager) {
                _lotteryModel = model;
                NSMutableArray *highLightArray = [NSMutableArray array];
                NSDictionary *infos = model.infos;
                if ([infos.allKeys containsObject:@"userInfos"]) {
                    NSArray *users = infos[@"userInfos"];
                    for (NSDictionary *dict in users) {
                        [highLightArray addObject:[self getHighLightAnimationModel:dict]];
                    }
                }
                [_baseAnimationManager setHighLightData:highLightArray];
                [_baseAnimationManager stopAnimation];
                _baseAnimationManager.endAnimationClosure = ^{
                    if (ws.screenLandScape == NO) {                    
                        [ws showNewLotteryResult:model];
                    }
                };
            }
        } else {
            [self showNewLotteryResult:model];
        }
    }else if (model.type == NEW_LOTTERY_EXIT) { //抽奖异常
        CCAlertView *alertView = [[CCAlertView alloc] initWithAlertTitle:NEWLOTTERY_CANCEL sureAction:SURE cancelAction:nil sureBlock:^{
            ws.playerView.isChatActionKeyboard = YES;
            ws.contentView.isChatActionKeyboard = YES;
            ws.isnLotteryComplete = NO;
        }];
        [APPDelegate.window addSubview:alertView];
    }
}

- (void)btnsTap:(NSInteger)tag {
    if (tag == 1) {
        [self showNewLotteryResult:_lotteryModel];
    } else {
        [_baseAnimationManager killAll];
        _baseAnimationManager = nil;
    }
}

- (HDSAnimationModel *)getHighLightAnimationModel:(NSDictionary *)dict {
    HDSAnimationModel *oneModel = [[HDSAnimationModel alloc]init];
    if ([dict.allKeys containsObject:@"userAvatar"]) {
        oneModel.userIconUrl = dict[@"userAvatar"];
    }
    if ([dict.allKeys containsObject:@"userName"]) {
        oneModel.userName = dict[@"userName"];
    }
    return oneModel;
}

- (HDSAnimationModel *)getAnimationModel:(NSDictionary *)dict {
    HDSAnimationModel *oneModel = [[HDSAnimationModel alloc]init];
    if ([dict.allKeys containsObject:@"avar"]) {
        oneModel.userIconUrl = dict[@"avar"];
    }
    if ([dict.allKeys containsObject:@"name"]) {
        oneModel.userName = dict[@"name"];
    }
    return oneModel;
}

- (void)showNewLotteryResult:(NewLotteryMessageModel *)model {
    
    [APPDelegate.window addSubview:_nLotteryView];
    [APPDelegate.window bringSubviewToFront:_nLotteryView];
    WS(ws)
    [_nLotteryView nLottery_resultWithModel:model isScreenLandScape:self.screenLandScape];
    self.playerView.isChatActionKeyboard = NO;
    self.contentView.isChatActionKeyboard = NO;
    /** 提交中奖信息数据 */
    _nLotteryView.contentBlock = ^(NSArray * _Nonnull array) {
        [ws.requestData commitLottery:array lotteryId:ws.nLotteryId completion:^(BOOL success) {
            ws.playerView.isChatActionKeyboard = YES;
            ws.contentView.isChatActionKeyboard = YES;
            if (success) {
                [NSObject cancelPreviousPerformRequestsWithTarget:ws selector:@selector(hiddenTipView) object:nil];
                if (ws.tipView) {
                    [ws.tipView removeFromSuperview];
                }
                ws.tipView = [[InformationShowView alloc] initWithLabel:NEWLOTTERY_COMMINT_SUCCESS];
                [APPDelegate.window addSubview:ws.tipView];
                [ws.tipView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
                }];
                ws.isnLotteryComplete = NO;
                [ws closeLotteryView];
                [NSTimer scheduledTimerWithTimeInterval:2.0f target:ws selector:@selector(hiddenTipView) userInfo:nil repeats:NO];
                return;
            }else {
                ws.nLotteryView.isAgainCommit = YES; // 提交失败能够再次提交
                [NSObject cancelPreviousPerformRequestsWithTarget:ws selector:@selector(hiddenTipView) object:nil];
                if (ws.tipView) {
                    [ws.tipView removeFromSuperview];
                }
                ws.tipView = [[InformationShowView alloc] initWithLabel:NEWLOTTERY_COMMINT_ERROR];
                [APPDelegate.window addSubview:ws.tipView];
                [ws.tipView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
                }];
                [NSTimer scheduledTimerWithTimeInterval:2.0f target:ws selector:@selector(hiddenTipView) userInfo:nil repeats:NO];
                return;
            }
        }];
    };
    /** 抽奖关闭按钮 */
    _nLotteryView.closeBlock = ^(BOOL result) {
        ws.playerView.isChatActionKeyboard = YES;
        ws.contentView.isChatActionKeyboard = YES;
        if (result == NO) {
            CCAlertView *alertView = [[CCAlertView alloc] initWithAlertTitle:NEWLOTTERY_NOCOMMINT_TIP sureAction:SURE cancelAction:CANCEL sureBlock:^{
                [ws.nLotteryView endEditing:YES];
                [ws.nLotteryView remove];
                ws.isnLotteryComplete = NO;
            }];
            [APPDelegate.window addSubview:alertView];
            return;
        }else {
            ws.isnLotteryComplete = NO;
            [ws.nLotteryView endEditing:YES];
            [ws.nLotteryView remove];
        }
    };
}

/**
 *    @brief    抽奖2.0 关闭抽奖
 */
- (void)closeLotteryView {
    [_nLotteryView remove];
}

- (void)hiddenTipView {
    if (_tipView) {
        [_tipView removeFromSuperview];
        _tipView = nil;
    }
}
#pragma mark - 加载视频失败
/**
 *  @brief  加载视频失败
 */
- (void)play_loadVideoFail {
    self.isPlayFailed = YES;
    /// 3.17.3 new
    //#ifdef LIANMAI_WEBRTC
    if (_isRTCLive || _isMediaCalled) return;
    //#endif
    _kSupportBaseType = HDSSupportViewBaseTypePlayError;
    [self updateSupportView];
}
#pragma mark - 聊天禁言
// MARK: - 直播间封禁
- (void)theRoomWasBanned {
    if (_requestData) {
        [_requestData shutdownPlayer];
    }
    [self.playerView theRoomWasBanned];
}
/**
 *    @brief    收到聊天禁言
 *    mode      禁言类型 1：个人禁言  2：全员禁言
 */
- (void)onBanChat:(NSDictionary *) modeDic {
    NSInteger mode = [modeDic[@"mode"] integerValue];
    if (mode == 2 && self.isAllowPublicChat == NO) {
        return;
    }
    self.isAllowPublicChat = NO;
    NSString *str = ALERT_BANCHAT(mode == 1);
    //添加禁言弹窗
    [self addSingleBtnAlertView:str];
}
/**
 *    @brief    收到聊天禁言并删除聊天记录
 *    viewerId  禁言用户id,是自己的话别删除聊天历史,其他人需要删除该用户的聊天
 */
- (void)onBanDeleteChat:(NSDictionary *)viewerDic {
    [_contentView onBanDeleteChatMessage:viewerDic];
}
/**
 *    @brief    收到解除禁言事件
 *    mode      禁言类型 1：个人禁言  2：全员禁言
 */
- (void)onUnBanChat:(NSDictionary *) modeDic {
    NSInteger mode = [modeDic[@"mode"] integerValue];
    if (mode == 2 && self.isAllowPublicChat == YES) {
        return;
    }
    self.isAllowPublicChat = YES;
    NSString *str = ALERT_UNBANCHAT(mode == 1);
    //添加禁言弹窗
    [self addSingleBtnAlertView:str];
}
#pragma mark - 进出直播间提示
/**
 *    @brief    进出直播间提示
 *    @param    model   提示详情
 */
- (void)HDUserRemindWithModel:(RemindModel *)model {
    NSArray *array = model.clientType;
    if ([array containsObject:@(4)]) {
        [self.contentView HDUserRemindWithModel:model];
    }
}

#pragma mark - 聊天禁言提示
/**
 *    @brief    禁言用户提示
 *    @param    model   BanChatModel    详情
 */
- (void)HDBanChatBroadcastWithModel:(BanChatModel *)model {
    NSString *tipStr = [[NSString alloc]initWithFormat:@"用户:%@%@",model.userName,@"被禁言"];
    if (_informationView) {
        [_informationView removeFromSuperview];
        _informationView = nil;
    }
    _informationView = [[InformationShowView alloc] initWithLabel:tipStr];
    [self.view addSubview:_informationView];
    [_informationView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(removeInformationView) userInfo:nil repeats:NO];
}

#pragma mark - 移除提示信息
- (void)removeInformationView {
    if (_informationView) {
        [_informationView removeFromSuperview];
        _informationView = nil;
    }
}

#pragma mark - 视频或者文档大窗
/**
 *  @brief  视频或者文档大窗
 *  isMain  1为视频为主,0为文档为主"
 */
- (void)onSwitchVideoDoc:(BOOL)isMain {
    /// 修复直播大屏模版视频无画面
    if (self.playerView.isOnlyVideoMode == YES) return;
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (isMain == YES) {
            [weakSelf changeBtnClicked:1];
        } else {
            [weakSelf changeBtnClicked:2];
        }
    });
}
#pragma mark - 抽奖
/**
 *  @brief  开始抽奖
 */
- (void)start_lottery {
    // 抽奖2.0存在取消抽奖2.0
    if (_nLotteryView) {
        [_nLotteryView removeFromSuperview];
    }
    if (_lotteryView) {
        [_lotteryView removeFromSuperview];
    }
    self.lotteryView = [[LotteryView alloc] initIsScreenLandScape:self.screenLandScape clearColor:NO];
    [APPDelegate.window addSubview:self.lotteryView];
    _lotteryView.frame = [UIScreen mainScreen].bounds;
    [self showRollCallView];
}
/**
 *  @brief  抽奖结果
 *  remainNum   剩余奖品数
 */
- (void)lottery_resultWithCode:(NSString *)code
                        myself:(BOOL)myself
                    winnerName:(NSString *)winnerName
                     remainNum:(NSInteger)remainNum {
    [_lotteryView lottery_resultWithCode:code myself:myself winnerName:winnerName remainNum:remainNum IsScreenLandScape:self.screenLandScape];
}
/**
 *  @brief  退出抽奖
 */
- (void)stop_lottery {
    [self.lotteryView remove];
}
#pragma mark - 问卷及问卷统计
/**
 *  @brief  问卷功能
 */
- (void)questionnaireWithTitle:(NSString *)title url:(NSString *)url {
    //问卷横屏输入事件(区分横屏聊天键盘事件)
    self.playerView.isChatActionKeyboard = NO;
    if (self.questionNaire) {
        //初始化第三方问卷视图
        [self.questionNaire removeFromSuperview];
        self.questionNaire = nil;
    }
    [self.view endEditing:YES];
    self.questionNaire = [[QuestionNaire alloc] initWithTitle:title url:url isScreenLandScape:self.screenLandScape];
    //添加第三方问卷视图
    [self addAlerView:self.questionNaire];
}
/**
 *  @brief  提交问卷结果（成功，失败）
 */
- (void)commitQuestionnaireResult:(BOOL)success {
    WS(ws)
    //问卷横屏输入事件(区分横屏聊天键盘事件)
    self.playerView.isChatActionKeyboard = YES;
    [self.questionnaireSurvey commitSuccess:success];
    if(success &&self.submitedAction != 1) {
        [NSTimer scheduledTimerWithTimeInterval:3.0f target:ws selector:@selector(removeQuestionnaireSurvey) userInfo:nil repeats:NO];
    }
}
/**
 *  @brief  发布问卷
 */
- (void)questionnaire_publish {
    [self removeQuestionnaireSurvey];
}
/**
 *  @brief  获取问卷详细内容
 *  @param  detailDic {
            forcibly               //1就是强制答卷，0为非强制答卷
            id                     //问卷主键ID
            subjects               //包含的项目
            submitedAction         //1提交后查看答案，0为提交后不查看答案
            title                  //标题 }
 */
- (void)questionnaireDetailInformation:(NSDictionary *)detailDic {
    [self.view endEditing:YES];
    self.submitedAction     = [detailDic[@"submitedAction"] integerValue];
    //问卷横屏输入事件(区分横屏聊天键盘事件)
    self.playerView.isChatActionKeyboard = NO;
    //初始化问卷详情页面
    self.questionnaireSurvey = [[QuestionnaireSurvey alloc] initWithCloseBlock:^{
        [self removeQuestionnaireSurvey];
    } CommitBlock:^(NSDictionary *dic) {
        //提交问卷结果
        [self.requestData commitQuestionnaire:dic];
    } questionnaireDic:detailDic isScreenLandScape:self.screenLandScape isStastic:NO];
    //添加问卷详情
    [self addAlerView:self.questionnaireSurvey];
}
/**
 *  @brief  结束发布问卷
 */
- (void)questionnaire_publish_stop {
    WS(ws)
    //问卷横屏输入事件(区分横屏聊天键盘事件)
    self.playerView.isChatActionKeyboard = YES;
    [self.questionnaireSurveyPopUp removeFromSuperview];
    self.questionnaireSurveyPopUp = nil;
    if(self.questionnaireSurvey == nil) return;//如果已经结束发布问卷，不需要加载弹窗
    //结束编辑状态
    [self.view endEditing:YES];
    [self.questionnaireSurvey endEditing:YES];
    //初始化结束问卷弹窗
    self.questionnaireSurveyPopUp = [[QuestionnaireSurveyPopUp alloc] initIsScreenLandScape:self.screenLandScape SureBtnBlock:^{
        [ws removeQuestionnaireSurvey];
    }];
    //添加问卷弹窗
    [self addAlerView:self.questionnaireSurveyPopUp];
}
/**
 *  @brief  获取问卷统计
 *  @param  staticsDic {
            forcibly               //1就是强制答卷，0为非强制答卷
            id                     //问卷主键ID
            subjects               //包含的项目
            submitedAction         //1提交后查看答案，0为提交后不查看答案
            title                  //标题 }
 */
- (void)questionnaireStaticsInformation:(NSDictionary *)staticsDic {
    [self.view endEditing:YES];
    if (self.questionnaireSurvey != nil) {
        [self.questionnaireSurvey removeFromSuperview];
        self.questionnaireSurvey = nil;
    }
    //初始化问卷统计视图
    self.questionnaireSurvey = [[QuestionnaireSurvey alloc] initWithCloseBlock:^{
        [self removeQuestionnaireSurvey];
    } CommitBlock:nil questionnaireDic:staticsDic isScreenLandScape:self.screenLandScape isStastic:YES];
    //添加问卷统计视图
    [self addAlerView:self.questionnaireSurvey];
}
#pragma mark - 签到
/**
  *  @brief  开始签到
  */
- (void)start_rollcall:(NSInteger)duration{
    [self removeRollCallView];
    [self.view endEditing:YES];
    self.duration = duration;
    //添加签到视图
    [self addAlerView:self.rollcallView];
    [APPDelegate.window bringSubviewToFront:self.rollcallView];
}
#pragma mark - 答题卡
/**
  *  @brief  开始答题
  */
- (void)start_vote:(NSInteger)count singleSelection:(BOOL)single {
    [self removeVoteView];
    self.mySelectIndex = -1;
    [self.mySelectIndexArray removeAllObjects];
    WS(ws)
    VoteView *voteView = [[VoteView alloc] initWithCount:count singleSelection:single voteSingleBlock:^(NSInteger index) {
        //答单选题
        [ws.requestData reply_vote_single:index];
        ws.mySelectIndex = index;
    } voteMultipleBlock:^(NSMutableArray *indexArray) {
        //答多选题
        [ws.requestData reply_vote_multiple:indexArray];
        ws.mySelectIndexArray = [indexArray mutableCopy];
    } singleNOSubmit:^(NSInteger index) {
//        ws.mySelectIndex = index;
    } multipleNOSubmit:^(NSMutableArray *indexArray) {
//        ws.mySelectIndexArray = [indexArray mutableCopy];
    } isScreenLandScape:self.screenLandScape];
    //收起按钮
    voteView.cleanBlock = ^(BOOL result) {
        [ws updateVoteWithStatus:NO];
    };
    //关闭按钮
    voteView.closeBlock = ^(BOOL result) {
        [ws updateVoteWithStatus:YES];
    };
    voteView.tag = 1006;
    
    //避免强引用 weak指针指向局部变量
    self.voteView = voteView;
    
    //添加voteView
    [self addAlerView:self.voteView];
}
/**
 *  @brief  结束答题
 */
- (void)stop_vote {
    [self updateVoteWithStatus:YES];
    [self removeVoteView];
}
/**
  *  @brief  答题结果
  *  @param  resultDic {answerCount         //参与回答人数
                        correctOption       //正确答案 (单选字符串，多选字符串数组)
                        statisics[{         //统计数组
                                    count   //选择当前选项人数
                                    option  //选项序号
                                    percent //正确率
                                    }]
                        voteCount           //题目数量
                        voteId              //题目ID
                        voteType            //题目类型}
  */
- (void)vote_result:(NSDictionary *)resultDic {
    [self updateVoteWithStatus:YES];
    [self removeVoteView];
    VoteViewResult *voteViewResult = [[VoteViewResult alloc] initWithResultDic:resultDic mySelectIndex:self.mySelectIndex mySelectIndexArray:self.mySelectIndexArray isScreenLandScape:self.screenLandScape];
    _voteViewResult = voteViewResult;
    //添加答题结果
    [self addAlerView:self.voteViewResult];
}
#pragma mark - 跑马灯
/**
 *    @brief    跑马灯
 *    @param    dic action  [{                      //事件
                                duration            //执行时间
                                end {               //结束位置
                                        alpha       //透明度
                                        xpos        //x坐标
                                        ypos        //y坐标 },
                                start {             //开始位置
                                        alpha       //透明度
                                        xpos        //x坐标
                                        ypos        //y坐标}]
                    image {                         //包含图片
                                height              //图片高度
                                image_url           //地址
                                width               //图片宽度}
                    loop                            //循环次数 -1 无限循环
                    text   {                        //文字信息
                                 color              //文字颜色
                                 content            //文字内容
                                 font_size          //字体大小}
                    type                            //当前类型 text 文本 image 图片
 */
- (void)receivedMarqueeInfo:(NSDictionary *)dic {
    if (dic == nil || self.openmarquee == NO) {
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

// MARK: - 聊天置顶
/// 房间历史置顶聊天记录
/// @param model 置顶聊天model
- (void)onHistoryTopChatRecords:(HDSHistoryTopChatModel *)model {
    if (_contentView) {
        [_contentView onHistoryTopChatRecords:model];
    }
}

/// 收到聊天置顶新消息
/// @param model 聊天置顶model
- (void)receivedNewTopChat:(HDSLiveTopChatModel *)model {
    if (_contentView) {
        [_contentView receivedNewTopChat:model];
    }
}

/// 收到批量删除聊天置顶消息
/// @param model 聊天置顶model
- (void)receivedDeleteTopChat:(HDSDeleteTopChatModel *)model {
    if (_contentView) {
        [_contentView receivedDeleteTopChat:model];
    }
}

#pragma mark - 公告
- (void)showAppointAnnouncementTipView {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hiddenAnnouncementTipView) object:nil];
    self.showNewAnnouncementTipView.hidden = NO;
    [self performSelector:@selector(hiddenAnnouncementTipView) withObject:nil afterDelay:3];
}

- (void)hiddenAnnouncementTipView {
    _showNewAnnouncementTipView.hidden = YES;
}

/**
 *  @brief  公告
 */
- (void)announcement:(NSString *)str{
    //刚进入时的公告消息
    _gongGaoStr = StrNotEmpty(str) ? str : @"";
    if (_gongGaoStr.length > 0) {
        [_contentView historyAnnouncementString:str];
        __weak typeof(self) weakSelf = self;
        _contentView.historyAnnouncementCallBack = ^(NSInteger btnTag) {
            if (btnTag == 0) {
                weakSelf.isCloseHistoryAnnouncementView = YES;
                [weakSelf showAppointAnnouncementTipView];
            } else {            
                if(weakSelf.announcementView) {
                    [weakSelf.announcementView updateViews:weakSelf.gongGaoStr];
                    [weakSelf announcementBtnClicked];
                }
            }
        };
    }
}
/**
 *  @brief  监听到有公告消息
 *  @dict   {action         //action 返回release 取出公告内容，action 返回remove 删除公告
             announcement   //公告内容}
 */
- (void)on_announcement:(NSDictionary *)dict {
    if ([dict.allKeys containsObject:@"action"]) {
        NSString *actionStr = [NSString stringWithFormat:@"%@",dict[@"action"]];
        if ([actionStr isEqualToString:@"release"]) {
            if ([dict.allKeys containsObject:@"announcement"]) {
                NSString *announcementStr = [NSString stringWithFormat:@"%@",dict[@"announcement"]];
                _gongGaoStr = announcementStr;
            } else {
                _gongGaoStr = @"";
            }
        } else if ([actionStr isEqualToString:@"remove"]) {
            _gongGaoStr = @"";
        }
    }
    [_contentView historyAnnouncementString:_gongGaoStr];
    __weak typeof(self) weakSelf = self;
    _contentView.historyAnnouncementCallBack = ^(NSInteger btnTag) {
        if (btnTag == 0) {
            weakSelf.isCloseHistoryAnnouncementView = YES;
            [weakSelf showAppointAnnouncementTipView];
        } else {
            if(weakSelf.announcementView) {
                [weakSelf.announcementView updateViews:weakSelf.gongGaoStr];
                [weakSelf announcementBtnClicked];
            }
        }
    };
    if(_announcementView) {
        [_announcementView updateViews:self.gongGaoStr];
    }
}
#pragma mark - 缓存速度
- (void)onBufferSpeed:(NSString *)speed
{
    if (self.isPlayerLoadStateStalled == YES && self.isPlayFailed != YES) {
        /// 3.17.3 new
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

#pragma mark - 随堂测
/**
 *    @brief       接收到随堂测 (3.10更改)
 *    rseultDic    随堂测内容
      resultDic    {
                   isExist                        //是否存在正在发布的随堂测 1 存在 0 不存在
                   practice{
                            id                    //随堂测ID
                            isAnswered            //是否已答题 true: 已答题, false: 未答题
                            options               //选项数组
                            ({
                                  id              //选项ID
                                  index           //选项索引
                            })
                            publishTime           //随堂测发布时间
                            status                //随堂测状态: 1 发布中 2 停止发布 3 已关闭
                            type                  //随堂测类型: 0 判断 1 单选 2 多选
                            submitRecord          //如果已答题，返回该学员答题记录，如果未答题，服务端不返回该字段
                            ({
                                optionId          //选项ID
                                optionIndex       //选项索引
                            })
                          }
                   serverTime                     //分发时间
                  }
 *
 */
- (void)receivePracticeWithDic:(NSDictionary *) resultDic {
    // 1.是否存在正在发布的随堂测 或 随堂测的状态为已关闭
    if ([resultDic[@"isExist"] intValue] == 0 || [resultDic[@"practice"][@"status"] intValue] == 3) {
        [self updateTestWithStatus:YES];
        if (_testView) {
            [_testView removeFromSuperview];
            _testView = nil;
        }
        return;//如果不存在随堂测，返回。
    }
    // 2.随堂测是否已答题 或 随堂测已停止
    if ([resultDic[@"practice"][@"isAnswered"] boolValue] == YES || [resultDic[@"practice"][@"status"] intValue] == 2) {
        // practiceId 随堂测ID
        NSString *practiceId = resultDic[@"practice"][@"id"];
        [_requestData getPracticeStatisWithPracticeId:practiceId];
        [self updateTestWithStatus:YES];
    }
    // 3.随堂测未答题显示答题选项
    NSMutableDictionary *dict = [resultDic mutableCopy];
    [dict setObject:@[] forKey:@"answer"];
    self.testDict = dict;
    [self showTestViewIsScreenLandScape:self.screenLandScape];
}
/**
 *    @brief    更新随堂测收起按钮
 *    @param    status   状态
 */
- (void)updateTestWithStatus:(BOOL)status
{
    [self.contentView testUPWithStatus:status];
    [self.playerView testUPWithStatus:status];
}
/**
 *    @brief    更新答题卡收起按钮
 *    @param    status   状态
 */
- (void)updateVoteWithStatus:(BOOL)status
{
    [self.contentView voteUPWithStatus:status];
    [self.playerView voteUPWithStatus:status];
}

/**
 *    @brief    展示随堂测
 *    @param    isScreenLandScape   NO 竖屏 YES 横屏
 */
- (void)showTestViewIsScreenLandScape:(NSInteger)isScreenLandScape {
    if (_testView) {
       [_testView removeFromSuperview];
       [_testView stopTimer];
        _testView = nil;
    }
    [self.view endEditing:YES];
    [APPDelegate.window endEditing:YES];
    // 初始化随堂测视图
    CCClassTestView *testView = [[CCClassTestView alloc] initWithTestDic:_testDict isScreenLandScape:self.screenLandScape];
    testView.tag = 1005;
    self.testView = testView;
    [APPDelegate.window addSubview:self.testView];
    WS(weakSelf)
    self.testView.CommitBlock = ^(NSArray * _Nonnull arr) {//提交答案回调
       [weakSelf.requestData commitPracticeWithPracticeId:_testDict[@"practice"][@"id"] options:arr];
    };
    _testView.StaticBlock = ^(NSString * _Nonnull practiceId) {//获取统计回调
       [weakSelf.requestData getPracticeStatisWithPracticeId:practiceId];
    };
    // 随堂测收起操作
    _testView.cleanBlock = ^(NSMutableDictionary * _Nonnull result) {
        weakSelf.testDict = result;
        [weakSelf updateTestWithStatus:NO];
    };
}


/**
 *    @brief    随堂测提交结果(3.10更改)
 *    rseultDic    提交结果,调用commitPracticeWithPracticeId:(NSString *)practiceId options:(NSArray *)options后执行
 *
      resultDic {datas {practice                                 //随堂测
                             { answerResult                      //回答是否正确 1 正确 0 错误
                               id                                //随堂测ID
                               isRepeatAnswered                  //是否重复答题 true: 重复答题, false: 第一次答题
                               options ({  count                 //参与人数
                                             id                  //选项主键ID
                                             index               //选项序号
                                             isCorrect           //是否正确
                                             percent             //选项占比})
                               submitRecord 如果重复答题，则返回该学员第一次提交的记录，否则，返回该学员当前提交记录
                                            ({ optionId          //提交记录 提交选项ID
                                               optionIndex       //提交选项序号})
                               type                              //随堂测类型: 0 判断 1 单选 2 多选}}}
 */
- (void)practiceSubmitResultsWithDic:(NSDictionary *) resultDic {
    [_testView practiceSubmitResultsWithDic:resultDic];
}
/**
 *    @brief    随堂测统计结果(3.10更改)
 *    rseultDic    统计结果,调用getPracticeStatisWithPracticeId:(NSString *)practiceId后执行
      resultDic  {practice {                                //随堂测
                            answerPersonNum                 //回答该随堂测的人数
                            correctPersonNum                //回答正确的人数
                            correctRate                     //正确率
                            id                              //随堂测ID
                            options ({                      //选项数组
                                        count               //选择该选项的人数
                                        id                  //选项ID
                                        index               //选项序号
                                        isCorrect           //是否为正确选项 1 正确 0 错误
                                        percent             //选择该选项的百分比})
                            status                          //随堂测状态  1 发布中 2 停止发布
                            type                            //随堂测类型: 0 判断 1 单选 2 多选}}
 */
- (void)practiceStatisResultsWithDic:(NSDictionary *) resultDic {
    [self updateTestWithStatus:YES];
    if (_testView) {
        [self.view endEditing:YES];
        [APPDelegate.window endEditing:YES];
    }
    [_testView getPracticeStatisWithResultDic:resultDic isScreen:self.screenLandScape];
}
/**
 *    @brief    停止随堂测(The new method)
 *    rseultDic    结果
 *    resultDic {practiceId //随堂测主键ID}
 */
- (void)practiceStopWithDic:(NSDictionary *) resultDic {
    [self updateTestWithStatus:YES];
    [_testView stopTest];
    [self.requestData getPracticeRankWithPracticeId:resultDic[@"practiceId"]];
}
/**
 *    @brief    关闭随堂测(The new method)
 *    rseultDic    结果
 *    resultDic {practiceId //随堂测主键ID}
 */
- (void)practiceCloseWithDic:(NSDictionary *) resultDic {
    [self updateTestWithStatus:YES];
    // 移除随堂测视图
    if (self.testView) {
        [self.testView removeFromSuperview];
        self.testView = nil;
    }
}

/**
 *    @brief    收到奖杯(The new method)
 *    dic       结果
 *    "type":  1 奖杯 2 其他
 *    "viewerName": 获奖用户名
 *    "viewerId": 获奖用户ID
 */
- (void)prize_sendWithDict:(NSDictionary *)dic {
    NSString *name = @"";
    [self.view endEditing:YES];
    [APPDelegate.window endEditing:YES];
    if (![dic[@"viewerId"] isEqualToString:self.viewerId]) {
        name = dic[@"viewerName"];
    }
    CCCupView *cupView = [[CCCupView alloc] initWithWinnerName:name isScreen:self.screenLandScape];
    [APPDelegate.window addSubview:cupView];
}
//#ifdef LIANMAI_WEBRTC
// MARK: - 连麦相关代理
/// 3.18.0 new
/// 房间是否允许连麦
/// @param callInfo 房间信息
- (void)onMediaCallStatusDidChange:(HDSRoomCallInfo *)callInfo {
    
    // 房间是否是多人连麦房间
    self.isMutilMediaCallRoom = callInfo.isMultiMediaCallRoom;
    // 房间连麦类型是否是音视频房间
    self.isAudioVideoRoom = callInfo.roomCallType == HDSRoomCallTypeAudioVideo ? YES : NO;
    
    if (callInfo.isMultiMediaCallRoom) {
        // 多人连麦房间
        if (_callBar) {
            [_callBar removeFromSuperview];
            _callBar = nil;
        }
        [_menuView hiddenLianmaiBtn];
        if (callInfo.isMediaCallFuncEnable) {
            if (!_isMultiMediaCallOpen) {
                [self addSingleBtnAlertView:hds_teacher_open_mediaCall];
            }
            _callBarType = self.isAudioVideoRoom == YES ? HDSMultiMediaCallBarTypeVideoApply : HDSMultiMediaCallBarTypeAudioApply;
            _callBarConfig.callType = _callBarType;
            dispatch_async(dispatch_get_main_queue(), ^{
                [APPDelegate.window addSubview:self.callBar];
            });
            _isMultiMediaCallOpen = YES;
        }else {
            if (callInfo.disableReason == HDSMediaCallAbilityDisableReasonTeacherClose) {
                [self addSingleBtnAlertView:hds_teacher_shupdown_mediaCall];
            }
            // 有文档模版下 并且 文档在大窗
            if (!_playerView.isOnlyVideoMode && _isDocMainScreen) {
                [_requestData changeDocFrame:CGRectMake(0, 0, SCREEN_WIDTH, self.playerView.height)];
            }
            [self updateRoomSubviews:NO];
            [self removeRemoteViewWith:nil isKillAll:YES];
            
            if (_isMediaCalled || _isMediaCalling) {
                [self hangup:NO];
            }
            _isMultiMediaCallOpen = NO;
        }
    }else {
        // 单人连麦房间
        [self.playerView allowSpeakInteraction:callInfo.isMediaCallFuncEnable];
        _isMultiMediaCallOpen = callInfo.isMediaCallFuncEnable;
    }
}

/// 连麦模式切换（多人连麦）
/// @param  mode 模式  7 无延迟 / 8 低延迟 / 9 普通
- (void)onMediaCallModeDidChange:(int)mode {
    self.isRTCLive = mode == 7 ? YES : NO;
    if (self.isRTCLive) {
        [self.playerView setupMultiMediaCall:YES connectStatus:YES];
    }
    self.playerView.isRTCLive = self.isRTCLive;
}

/// 远端流可用
/// @param streamModel 流信息
- (void)onRemoteStreamEnable:(HDSStreamModel *)streamModel {
    
    if (_requestData) {
        if (_isMediaCalled == NO && _isMediaCalling == NO && _isRTCLive == NO) {
    
            return;
        }
        HDSStreamUserInfoModel *userModel = streamModel.userInfo;
        [_requestData pullRemoteStream:userModel.userId succed:^(HDSStreamModel * _Nullable stModel) {
            HDSStreamUserInfoModel *oneUser = stModel.userInfo;
            if (_isAudioVideoRoom && !_isMutilMediaCallRoom && _isAudioVideo) {
                /// 单人连麦
   
                self.isMediaCalled = YES;
                self.remoteView = stModel.hds_remoteView;
                self.singleOriginSize = stModel.hds_remoteView.size;
                self.remoteView.tag = 888;
                [self updateRemoteView];
                if (_isAudioVideoRoom) {
                    [_hds_playerView removeFromSuperview];
                    _hds_playerView = nil;
                    for (UIView *subView in self.hds_playerContentView.subviews) {
                        if (subView.tag == 888) {
                            [subView removeFromSuperview];
                        }
                    }
                }
            }else if ((_isMutilMediaCallRoom && _isAudioVideoRoom) || self.isRTCLive) {
                /// 多人连麦
                if (oneUser.userRole == 0) { // 讲师流
                   
                    _supportView.hidden = YES;
                    [_remoteView removeFromSuperview];
                    _remoteView = stModel.hds_remoteView;
                    _remoteView.tag = 888;
                    _remoteView.frame = _kPlayerParent.bounds;
                    [self.hds_playerContentView addSubview:_remoteView];
                    self.teacherUserId = oneUser.userId;
                    
                    if (self.isRTCLive || _isAudioVideoRoom) {
                        [_hds_playerView removeFromSuperview];
                        _hds_playerView = nil;
                    }
                }else {
                    if (_isAudioVideoRoom) {
                    
                        [self updateRoomSubviews:YES];
                        [self addRemoteViewWith:stModel];
                    }
                }
            }
            [self.playerView connectWebRTCSuccess];
        } failed:^(HDSMediaCallError error) {
           
        }];
    }
}

/// 远端流不可用（多人连麦）
/// @param streamModel 流信息
- (void)onRemoteStreamDisable:(HDSStreamModel *)streamModel {
    
    if (_requestData) {
        HDSStreamUserInfoModel *userModel = streamModel.userInfo;
        [_requestData removeRemoteStream:userModel.userId];
        if (![userModel.userId isEqualToString:self.teacherUserId]) {
            [self removeRemoteViewWith:streamModel isKillAll:NO];
        }
    }
}

/// 邀请上麦（多人连麦）
- (void)onInviteCall {
    
    if (_isMutilMediaCallRoom) {
        _isMediaCalling = YES;
        _isMediaCalled = NO;
        _callBarType = self.isAudioVideoRoom == YES ? HDSMultiMediaCallBarTypeVideoInvitation : HDSMultiMediaCallBarTypeAudioInvitation;
        self.callBarConfig.callType = _callBarType;
        [self updateCallBarStatusConfig:self.callBarConfig];
    }
}

/// 取消邀请（多人连麦）
- (void)onInviteCanceled {
    
    _isMediaCalling = NO;
    _isMediaCalled = NO;
    if (_isMutilMediaCallRoom) {
        _callBarType = self.isAudioVideoRoom == YES ? HDSMultiMediaCallBarTypeVideoApply : HDSMultiMediaCallBarTypeAudioApply;
        self.callBarConfig.callType = _callBarType;
        [self updateCallBarStatusConfig:self.callBarConfig];
        [self addSingleBtnAlertView:hds_teacher_cancel_invitation];
        if (!self.isRTCLive) {
            [self hds_multiRoom_updateHangup_callBarStatus];
        }
    }
}

/// 音频状态改变（多人连麦）
/// @param status 是否可用
/// @param userId 用户id
/// @param byTeacher 是否是老师操作
- (void)onAudioStatusDidChange:(BOOL)status userId:(NSString *)userId byTeacher:(BOOL)byTeacher {
    if (_isMutilMediaCallRoom) {
        if (_requestData) {
            if (!byTeacher) {
                _isAudioVideo = status;
                self.callBarConfig.isAudioEnable = _isAudioEnable;
                return;
            };
            if ([userId isEqualToString:self.viewerId]) {
                NSString *tipStr = status == YES ? hds_teacher_open_audio : hds_teacher_close_audio;
                _isAudioEnable = status;
                [self showTipInfomationWithTitle:tipStr];
                self.callBarConfig.callType = _callBarType;
                self.callBarConfig.isAudioEnable = _isAudioEnable;
                self.callBarConfig.isVideoEnable = _isVideoEnable;
                self.callBarConfig.isFrontCamera = _isFrontCamera;
                [self updateCallBarStatusConfig:self.callBarConfig];
            }
        }
    }
}

/// 视频状态改变（多人连麦）
/// @param status 是否可用
/// @param userId 用户id
- (void)onVideoStatusDidChange:(BOOL)status userId:(NSString *)userId {
    if (_isMutilMediaCallRoom) {
        if (_requestData) {
            if ([userId isEqualToString:self.viewerId] && _isAudioVideoRoom) {
                NSString *tipStr = status == YES ? hds_teacher_open_video : hds_teacher_close_video;
                _isVideoEnable = status;
                [self showTipInfomationWithTitle:tipStr];
                self.callBarConfig.callType = _callBarType;
                self.callBarConfig.isAudioEnable = _isAudioEnable;
                self.callBarConfig.isVideoEnable = _isVideoEnable;
                self.callBarConfig.isFrontCamera = _isFrontCamera;
                [self updateCallBarStatusConfig:self.callBarConfig];
            }
            
            if (_isAudioVideoRoom) { // 音视频连麦需要更新 CollectionView
                HDSMultiMediaCallStreamModel *stModel = [[HDSMultiMediaCallStreamModel alloc]init];
                stModel.userId = userId;
                stModel.type = kNeedUpateTypeVideo;
                stModel.isVideoEnable = status;
                // 更新本地预览视图
                self.roomCalledNum = [self.playerView updateMultiMediaCallInfo:stModel];
                
            }
        }
    }
}

/// 被挂断（多人连麦）
- (void)onCallWasHangup {
    [self showTipInfomationWithTitle:hds_teacher_hangup];
    _isMediaCalling = NO;
    _isMediaCalled = NO;
    if (_isMutilMediaCallRoom) {
        HDSStreamModel *stModel = [[HDSStreamModel alloc]init];
        if (self.isRTCLive) {
            if (_isAudioVideoRoom) {
                HDSStreamUserInfoModel *userModel = [[HDSStreamUserInfoModel alloc]init];
                userModel.userId = self.viewerId;
                stModel.userInfo = userModel;
                [self removeRemoteViewWith:stModel isKillAll:NO];
            }else {
                [self hds_multiRoom_updateHangup_callBarStatus];
            }
        }else {
            [self hds_multiRoom_updateHangup_callBarStatus];
            [self removeRemoteViewWith:stModel isKillAll:YES];
        }
    }else {
    
        
        [self.playerView speak_disconnect:YES];
        if (_isAudioVideo) {
            [self updateRemoteView];
        }
    }
}

/// 异常挂断
/// @param error 错误原因
- (void)onConnectionException:(HDSMediaCallError)error {
    [self excpetionWithError:error];
    [self.playerView speak_disconnect:YES];
    _isMediaCalling = NO;
    _isMediaCalled = NO;
    if (_isMutilMediaCallRoom) {
        HDSStreamModel *stModel = [[HDSStreamModel alloc]init];
        if (self.isRTCLive) {
            HDSStreamUserInfoModel *userModel = [[HDSStreamUserInfoModel alloc]init];
            userModel.userId = self.viewerId;
            stModel.userInfo = userModel;
            [self removeRemoteViewWith:stModel isKillAll:NO];
        }else {
            [self hds_multiRoom_updateHangup_callBarStatus];
            [self removeRemoteViewWith:stModel isKillAll:YES];
        }
        self.callBarConfig.callType = _isAudioVideoRoom ? HDSMultiMediaCallBarTypeVideoApply : HDSMultiMediaCallBarTypeAudioApply;
        [self updateCallBarStatusConfig:self.callBarConfig];

    }else {
        [self.playerView speak_disconnect:YES];
        if (_isAudioVideo) {
            [self updateRemoteView];
        }
    }
}

- (void)excpetionWithError:(HDSMediaCallError)error {
    
    if (error == HDSMediaCallErrorConnectTimeOut) return; // 连麦申请超时不提示
    if (self.isNeedLogout) {
        [self hds_alert_abilityDownWithTitle:hds_mediaCall_ability_down];
        return;
    }
    NSString *tipStr = hds_mediaCall_error_retry;
    switch (error) {
        case HDSMediaCallErrorInCalling: {
            tipStr = hds_mediaCall_error_retry;
        } break;
        case HDSMediaCallErrorRoomTypeDidChange: {
            tipStr = hds_mediaCall_room_info_did_change;
            self.isNeedLogout = YES;
            [self hds_exitReLoginSingBtnWithTipStr:tipStr];
            return;
        } break;
        case HDSMediaCallErroronMumberLimit: {
            tipStr = hds_mediaCall_many_people_online;
        } break;
        case HDSMediaCallErrorAbilityDown: {
            tipStr = hds_mediaCall_ability_down;
            self.isNeedLogout = YES;
            [self hds_alert_abilityDownWithTitle:tipStr];
            return;
        } break;
        case HDSMediaCallErrorPullStreamFailed: {
            // 拉流失败
        } break;
        case HDSMediaCallErrorPreparing: {
            tipStr = hds_mediaCall_preparing;
        }
        default:
            break;
    }
    [self addSingleBtnAlertView:tipStr];
}

- (void)onPushStreamQuality:(HDSStreamQuality)quality {

}

- (void)onPullStreamQuality:(NSString *)streamID quality:(HDSStreamQuality)quality {
   
}

- (NSString *)showMediaCallQuality:(HDSStreamQuality)quality {
    switch (quality.rxQuality) {
        case 0:
            return @"网络:优";
        case 1:
            return @"网络:良";
        case 2:
            return @"网络:中";
        case 3:
            return @"网络:差";
        default:
            return @"网络:--";
    }
}

// MARK: - 连麦主动
/// 主动申请上麦
- (void)call {

    BOOL networkStatus = [self isExistenceNetwork];
    if (!networkStatus) {
        [self addSingleBtnAlertView:hds_mediaCall_network_error];
        return;
    }
    // 麦克风权限
    AVAuthorizationStatus micorAuth = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    if (micorAuth == AVAuthorizationStatusRestricted || micorAuth == AVAuthorizationStatusDenied) {
        [self tipAuthWithType:1];
        return;
    }
    // 相机权限
    if (_isAudioVideoRoom) {
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if (authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied) {
            [self tipAuthWithType:0];
            return;
        }
    }
    /// 3.18.0 new 防抖
    if (_isMutilMediaCallRoom) {
        if (![self getCountDownStatus]) {
            [self showTipInfomationWithTitle:hds_mediaCall_repeat_action];
            return;
        }
    }
    if (_requestData) {
        _isMediaCalling = YES;
        _isMediaCalled = NO;
        HDSMediaCallType type = HDSMediaCallTypeAudioVideo;
        if (_isMutilMediaCallRoom) {
            // 多人连麦
            _callBarType = self.isAudioVideoRoom == YES ? HDSMultiMediaCallBarTypeVideoCalling : HDSMultiMediaCallBarTypeAudioCalling;
            if (_callBarType == HDSMultiMediaCallBarTypeAudioCalling) {
                type = HDSMediaCallTypeAudio;
            }
            self.callBarConfig.callType = _callBarType;
            [self updateCallBarStatusConfig:self.callBarConfig];
            [self.playerView setupMultiMediaCall:YES connectStatus:YES];
        }else {
            // 单人连麦
            type =  self.playerView.isAudioVideo == YES ? HDSMediaCallTypeAudioVideo : HDSMediaCallTypeAudio;
            _isAudioVideo = self.playerView.isAudioVideo;
            [self.playerView setupMultiMediaCall:NO connectStatus:YES];
        }
        [_requestData callInPreviewWithType:type succed:^(UIView *preview) {
            
            
            _isMediaCalled = YES;
            self.callBarType = self.isAudioVideoRoom == YES ? HDSMultiMediaCallBarTypeVideoCalled : HDSMultiMediaCallBarTypeAudioCalled;
            self.callBarConfig.callType = _callBarType;
            self.callBarConfig.isAudioVideo = _isAudioVideoRoom ? YES : NO;
            self.callBarConfig.isAudioEnable = YES;
            if (_isMutilMediaCallRoom) {
                if (_isAudioVideoRoom) {
                    self.isAudioEnable = YES;
                    self.isVideoEnable = YES;
                    self.isFrontCamera = YES;
                    self.callBarConfig.isVideoEnable = YES;
                    self.callBarConfig.isFrontCamera = YES;
                    [self addLocalPreviewWith:preview];
                }
                [self updateCallBarStatusConfig:self.callBarConfig];
            }else {
                self.isAudioEnable = YES;
                if (type == HDSMediaCallTypeAudioVideo) {
                    preview.frame = CGRectMake(0, 0, 0, 0);
                    [_remoteView addSubview:preview];
                    if (_hds_playerView) {
                        [_hds_playerView removeFromSuperview];
                    }
                }
            }
        } failed:^(HDSMediaCallError error) {
            
            _isMediaCalling = NO;
            _isMediaCalled = NO;
            [self excpetionWithError:error];
            if (error != HDSMediaCallErrorInCalling) {
                [self hangup:NO];
            }
            if (!_isMutilMediaCallRoom) {
                [self hangup:NO];
                if (_isAudioVideo) {
                    [self updateRemoteView];
                }
                return;
            };
            HDSStreamModel *stModel = [[HDSStreamModel alloc]init];
            if (_isAudioVideoRoom) {
                if (self.isRTCLive) {
                    HDSStreamUserInfoModel *userModel = [[HDSStreamUserInfoModel alloc]init];
                    userModel.userId = self.viewerId;
                    stModel.userInfo = userModel;
                    [self removeRemoteViewWith:stModel isKillAll:NO];
                }else {
                    [self hds_multiRoom_updateHangup_callBarStatus];
                    [self removeRemoteViewWith:stModel isKillAll:YES];
                }
            }
        }];
    }
}

/// 同意上麦（多人连麦）
- (void)agreeCall {

    BOOL networkStatus = [self isExistenceNetwork];
    if (!networkStatus) {
        [self addSingleBtnAlertView:hds_mediaCall_network_error];
        return;
    }
    // 麦克风权限
    AVAuthorizationStatus micorAuth = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    if (micorAuth == AVAuthorizationStatusRestricted || micorAuth == AVAuthorizationStatusDenied) {
        [self tipAuthWithType:1];
        return;
    }
    // 相机权限
    if (_isAudioVideoRoom) {
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if (authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied) {
            [self tipAuthWithType:0];
            return;
        }
    }
    /// 3.18.0 new 防抖
    if (![self getCountDownStatus]) {
        [self showTipInfomationWithTitle:hds_mediaCall_repeat_action];
        return;
    }
    if (_isMutilMediaCallRoom) {
        if (_requestData) {
            _isMediaCalled = NO;
            
            _callBarType = self.isAudioVideoRoom == YES ? HDSMultiMediaCallBarTypeVideoConnecting : HDSMultiMediaCallBarTypeAudioConnecting;
            self.callBarConfig.callType = _callBarType;
            [self updateCallBarStatusConfig:self.callBarConfig];
            _isMediaCalling = YES;
            
            [_requestData agreeCallInPreview:^(UIView *preview) {
                
                _isMediaCalled = YES;
                self.callBarType = self.isAudioVideoRoom == YES ? HDSMultiMediaCallBarTypeVideoCalled : HDSMultiMediaCallBarTypeAudioCalled;
                self.callBarConfig.callType = _callBarType;
                self.callBarConfig.isAudioVideo = _isAudioVideoRoom ? YES : NO;
                self.callBarConfig.isAudioEnable = YES;
                if (_isAudioVideoRoom) {
                    self.isVideoEnable = YES;
                    self.isFrontCamera = YES;
                    self.callBarConfig.isVideoEnable = YES;
                    self.callBarConfig.isFrontCamera = YES;
                    
                    [self addLocalPreviewWith:preview];
                }
                [self updateCallBarStatusConfig:self.callBarConfig];
                [self.playerView setupMultiMediaCall:YES connectStatus:YES];
            } failed:^(HDSMediaCallError error) {
                _isMediaCalling = NO;
                _isMediaCalled = NO;
                [self excpetionWithError:error];
                if (error != HDSMediaCallErrorInCalling) {
                    [self hangup:NO];
                }
                if (!_isMutilMediaCallRoom) return;
                HDSStreamModel *stModel = [[HDSStreamModel alloc]init];
                if (self.isRTCLive) {
                    if (_isAudioVideoRoom) {
                        HDSStreamUserInfoModel *userModel = [[HDSStreamUserInfoModel alloc]init];
                        userModel.userId = self.viewerId;
                        stModel.userInfo = userModel;
                        [self removeRemoteViewWith:stModel isKillAll:NO];
                    }else {
                        [self hds_multiRoom_updateHangup_callBarStatus];
                    }
                }else {
                    [self hds_multiRoom_updateHangup_callBarStatus];
                    [self removeRemoteViewWith:stModel isKillAll:YES];
                }
            }];
        }
    }
}

/// 未授权授权弹窗
/// @param type 0 音视频 1 音频
- (void)tipAuthWithType:(int)type {
    //添加弹窗视图
    NSString *message = type == 1 ? MICORPHONE_ALERTSTRING : SCAN_ALERTSTRING;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"好" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {

    }];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

/// 主动挂断
- (void)hangup:(BOOL)isCareCallBack {
    /// 3.18.0 new 防抖
    if (_isMutilMediaCallRoom) {
        if (![self getCountDownStatus]) {
            [self showTipInfomationWithTitle:hds_mediaCall_repeat_action];
            return;
        }
    }
    _isMediaCalling = NO;
    _isMediaCalled = NO;
    if (_requestData) {
        if (isCareCallBack) {
            [_requestData hangup:^(BOOL succed) {
                if (!succed) {
                    [self addSingleBtnAlertView:hds_mediaCall_hangup_error];
                }
            }];
        }else {
            [_requestData hangup:nil];
        }
    }
    if (_isMutilMediaCallRoom) {
        HDSStreamModel *stModel = [[HDSStreamModel alloc]init];
        if (self.isRTCLive) {
            if (_isAudioVideoRoom) {
                HDSStreamUserInfoModel *userModel = [[HDSStreamUserInfoModel alloc]init];
                userModel.userId = self.viewerId;
                stModel.userInfo = userModel;
                [self removeRemoteViewWith:stModel isKillAll:NO];
            }else {
                [self hds_multiRoom_updateHangup_callBarStatus];
            }
        }else {
            [self hds_multiRoom_updateHangup_callBarStatus];
            [self removeRemoteViewWith:stModel isKillAll:YES];
        }
        [self.playerView speak_disconnect:YES];
    }else {
        

        [self.playerView speak_disconnect:YES];
        if (_isAudioVideo) {
            [self updateRemoteView];
        }
    }
}

/// 拒绝上麦（多人连麦）
- (void)rejectCall {
    if (_requestData) {
        [_requestData rejectCall];
        [self hds_multiRoom_updateHangup_callBarStatus];
    }
}

// MARK: - 自定义方法
/// 更新远端流视图（单人连麦）
- (void)updateRemoteView {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_isMediaCalled) {
            if (_supportView.hidden == NO) {
                _supportView.hidden = YES;
            }
            if (_remoteView) {
                [_remoteView removeFromSuperview];
                _remoteView.frame = _hds_playerContentView.bounds;
                [self.hds_playerContentView addSubview:_remoteView];
            }
        }else {
            for (UIView *subView in self.hds_playerContentView.subviews) {
                if (subView.tag == 888) {
                    [subView removeFromSuperview];
                }
            }
        }
    });
}

/// 更新远端流视图 （多人连麦）
- (void)update_hds_multi_remoteView {
    
    __weak typeof(self) weakSelf = self;
    if (!_isMutilMediaCallRoom) return;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (weakSelf.isMediaCalled || weakSelf.isRTCLive) {
            if (weakSelf.supportView.hidden == NO) {
                weakSelf.supportView.hidden = YES;
            }
            if (weakSelf.remoteView) {
                [weakSelf.remoteView removeFromSuperview];
                if (!weakSelf.isDocMainScreen && weakSelf.screenLandScape && weakSelf.isMediaCalled && weakSelf.isAudioVideoRoom) {
                    weakSelf.remoteView.frame = weakSelf.hds_playerContentView.frame;
                }else {
                    weakSelf.remoteView.frame = weakSelf.hds_playerContentView.frame;
                }
                [weakSelf.hds_playerContentView addSubview:weakSelf.remoteView];
            }
        }
    });
}

/// 添加本地预览（多人连麦）
- (void)addLocalPreviewWith:(UIView *)preview {
    
    _isMediaCalled = YES;
    
    if (_isAudioVideoRoom) {
        [self updateRoomSubviews:YES];
        HDSMultiMediaCallStreamModel *stModel = [[HDSMultiMediaCallStreamModel alloc]init];
        stModel.isMyself = YES;
        stModel.userId = self.viewerId;
        stModel.nickName = self.viewerName;
        stModel.isAudioEnable = YES;
        stModel.isVideoEnable = YES;
        stModel.streamView = preview;
        // 更新本地预览视图
        self.roomCalledNum = [self.playerView updateMultiMediaCallInfo:stModel];
        
    }
}

/// 添加远端流 (多人连麦)
/// @param stModel 流信息
- (void)addRemoteViewWith:(HDSStreamModel *)stModel {
    
    if (_isAudioVideoRoom) {
        HDSStreamUserInfoModel *userModel = stModel.userInfo;
        HDSMultiMediaCallStreamModel *oneModel = [[HDSMultiMediaCallStreamModel alloc]init];
        oneModel.isMyself = NO;
        oneModel.streamView = stModel.hds_remoteView;
        oneModel.userId = userModel.userId;
        oneModel.nickName = userModel.userName;
        oneModel.isAudioEnable = userModel.isAudioEnable;
        oneModel.isVideoEnable = userModel.isVideoEnable;
        // 更新本地预览视图
        self.roomCalledNum = [self.playerView updateMultiMediaCallInfo:oneModel];
    
    }
}

/// 移除远端流（多人连麦）
/// @param stModel 流信息
/// @param isKillAll 是否全部移除
- (void)removeRemoteViewWith:(HDSStreamModel *)stModel isKillAll:(BOOL)isKillAll {
    
    if (isKillAll) {
        HDSMultiMediaCallStreamModel *oneModel = [[HDSMultiMediaCallStreamModel alloc]init];
        self.roomCalledNum = [self.playerView removeRemoteView:oneModel isKillAll:YES];
        if (self.roomCalledNum == 0) {
            [self updateRoomSubviews:NO];
        }
        _callBarType = self.isAudioVideoRoom == YES ? HDSMultiMediaCallBarTypeVideoApply : HDSMultiMediaCallBarTypeAudioApply;
        self.callBarConfig.callType = _callBarType;
        [self updateCallBarStatusConfig:self.callBarConfig];
        
    }else {
        HDSStreamUserInfoModel *userModel = stModel.userInfo;
        HDSMultiMediaCallStreamModel *oneModel = [[HDSMultiMediaCallStreamModel alloc]init];
        BOOL isMyself = [userModel.userId isEqualToString:self.viewerId] ? YES : NO;
        if (isMyself) {
            oneModel.isMyself = isMyself;
            _callBarType = self.isAudioVideoRoom == YES ? HDSMultiMediaCallBarTypeVideoApply : HDSMultiMediaCallBarTypeAudioApply;
            self.callBarConfig.callType = _callBarType;
            [self updateCallBarStatusConfig:self.callBarConfig];
        }
        oneModel.streamView = stModel.hds_remoteView;
        oneModel.userId = userModel.userId;
        oneModel.nickName = userModel.userName;
        oneModel.isAudioEnable = userModel.isAudioEnable;
        oneModel.isVideoEnable = userModel.isVideoEnable;
        self.roomCalledNum = [self.playerView removeRemoteView:oneModel isKillAll:NO];
        if (self.roomCalledNum == 0) {
            [self updateRoomSubviews:NO];
        }
    }
}

/// 挂断后更新本地callBar状态 (多人连麦)
- (void)hds_multiRoom_updateHangup_callBarStatus {
    

    _callBarType = self.isAudioVideoRoom == YES ? HDSMultiMediaCallBarTypeVideoApply : HDSMultiMediaCallBarTypeAudioApply;
    self.callBarConfig.callType = _callBarType;
    [self updateCallBarStatusConfig:self.callBarConfig];
    if (_isAudioVideoRoom) {
        self.isVideoEnable = NO;
        self.isFrontCamera = NO;
    }
    if (self.roomCalledNum == 0) {
        [self updateRoomSubviews:NO];
    }
}

/// 设置本地麦克风状态 (多人连麦)
/// @param isEnable 是否可用
- (void)setMicEnable:(BOOL)isEnable {
    
    if (_isMutilMediaCallRoom) {
        if (_requestData) {
            BOOL result = [_requestData setLocalAudioEnable:isEnable];
            HDSMultiMediaCallStreamModel *stModel = [[HDSMultiMediaCallStreamModel alloc]init];
            stModel.userId = self.viewerId;
            stModel.type = kNeedUpateTypeAudio;
            if (result) {
                stModel.isAudioEnable = isEnable;
                NSString *tipStr = isEnable == YES ? hds_student_open_audio : hds_student_close_audio;
                [self showTipInfomationWithTitle:tipStr];
            }else {
                stModel.isAudioEnable = !isEnable;
            }
            // 更新本地预览视图
            if (_isAudioVideoRoom) {
                self.roomCalledNum = [self.playerView updateMultiMediaCallInfo:stModel];
                
            }
        }
    }
}

/// 设置本地摄像头状态 (多人连麦)
/// @param isEnable 是否可用
- (void)setCameraEnable:(BOOL)isEnable {
    
    if (_isMutilMediaCallRoom && _isAudioVideoRoom) {
        if (_requestData) {
            BOOL result = [_requestData setLocalVideoEnable:isEnable];
            HDSMultiMediaCallStreamModel *stModel = [[HDSMultiMediaCallStreamModel alloc]init];
            stModel.userId = self.viewerId;
            stModel.type = kNeedUpateTypeVideo;
            if (result) {
                stModel.isVideoEnable = isEnable;
                if (_isAudioVideoRoom) {
                    NSString *tipStr = isEnable == YES ? hds_student_open_video : hds_student_close_video;
                    [self showTipInfomationWithTitle:tipStr];
                }
            }else {
                stModel.isVideoEnable = !isEnable;
            }
            // 更新本地预览视图
            self.roomCalledNum = [self.playerView updateMultiMediaCallInfo:stModel];
            
        }
    }
}

/// 切换本地摄像头 (多人连麦)
- (void)switchCamera {
    
    if (_isMutilMediaCallRoom) {
        if (!_isVideoEnable) {
            //todo 提示摄像头禁用不可切换
            [self showTipInfomationWithTitle:@"摄像头已禁用，不可切换"];
            return;
        }
        if (_requestData) {
            if (_isAudioVideoRoom) {
                _isFrontCamera = !_isFrontCamera;
                NSString *tipStr = _isFrontCamera == YES ? hds_student_switch_frontCamera : hds_student_switch_backCamera;
                [self showTipInfomationWithTitle:tipStr];
            }
            [_requestData switchCamera];
        }
    }
}

/// 根据房间是否是音视频连麦更新子视图布局（多人连麦）
/// @param isNeedUpdate 是否需要更新
/// 1.开始预览 2.视频连麦成功 isNeedUpdate == YES
- (void)updateRoomSubviews:(BOOL)isNeedUpdate {
    WS(weakSelf)
    if (SCREEN_WIDTH > SCREEN_HEIGHT && _isAudioVideoRoom) {
        self.isNeedUpdateFlag = YES;
        self.isNeedUpdateStatus = isNeedUpdate;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        CGFloat h = HDGetRealHeight ;
        if (SCREEN_WIDTH < SCREEN_HEIGHT && isNeedUpdate && _roomCalledNum > 0) {
            h = h + 70;
        }
        
        [weakSelf.playerView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(weakSelf.view);
            make.top.equalTo(weakSelf.view).offset(SCREEN_STATUS);
            make.height.mas_equalTo(h);
        }];
        [weakSelf.playerView layoutIfNeeded];
        if (isNeedUpdate && _roomCalledNum > 0) {
            weakSelf.playerView.isMultiMediaShowStreamView = YES;
            if (_isDocMainScreen && _screenLandScape) {
                [_requestData changeDocFrame:CGRectMake(0, 0, SCREEN_WIDTH - 189.5, SCREEN_HEIGHT)];
            }
        }else {
            weakSelf.playerView.isMultiMediaShowStreamView = NO;
            if (_isDocMainScreen && _screenLandScape) {
                [_requestData changeDocFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
            }
        }
        
        [weakSelf.contentView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(weakSelf.playerView.mas_bottom);
            make.left.bottom.right.mas_equalTo(weakSelf.view);
        }];
        [weakSelf.contentView layoutIfNeeded];
        [weakSelf.contentView updateScrollViewContentSizeWithPlayerViewHeight:SCREEN_HEIGHT - SCREEN_STATUS - h];
        
        [weakSelf update_hds_multi_remoteView];
    });
}

// MARK: - callBar (多人连麦)
- (HDSMultiMediaCallBar *)callBar {
    if (!_callBar) {
        CGFloat w = 144;
        CGFloat h = 45;
        CGFloat x = SCREEN_WIDTH - w;
        CGFloat y =  SCREEN_WIDTH < SCREEN_HEIGHT ? 400 : 200;
        _callBar = [[HDSMultiMediaCallBar alloc]initWithFrame:CGRectMake(x, y, w, h)
                                            callConfiguration:self.callBarConfig
                                                      closure:^(HDSMultiMediaCallBarConfiguration * _Nonnull model) {
            [self callBarBtnActionClosure:model];
        }];
    }
    return _callBar;
}

/// 自定义方法 更新 callBar 状态 (多人连麦)
/// @param config 配置信息
- (void)updateCallBarStatusConfig:(HDSMultiMediaCallBarConfiguration *)config {
    @synchronized (self) {
        if (_isMutilMediaCallRoom) {
            if (_callBar) {
                [_callBar updateMediaCallBarConfiguration:config];
                if (_isMediaCalled && _callBarType == HDSMultiMediaCallBarTypeVideoCalled) {
                    if (SCREEN_WIDTH > SCREEN_HEIGHT) {
                        CGFloat w = 55;
                        CGFloat h = _isAudioVideoRoom ? 197.5 : 102.5;
                        CGFloat x = SCREEN_WIDTH - w;
                        CGFloat y = (SCREEN_HEIGHT - h) / 2;
                        [_callBar setFrame:CGRectMake(x, y, w, h)];
                    }else {
                        CGFloat w = [self.callBar getCallBarWidthWithType:_callBarType];
                        CGFloat h = 45;
                        CGFloat x = SCREEN_WIDTH - w;
                        CGFloat y = self.callBar.y < 300 ? 300 : self.callBar.y;
                        [_callBar setFrame:CGRectMake(x, y, w, h)];
                    }
                }else {
                    if (SCREEN_WIDTH > SCREEN_HEIGHT) {
                        CGFloat h = 45;
                        CGFloat y = self.callBar.y > SCREEN_HEIGHT - h ? 200 : self.callBar.y;
                        CGFloat w = [self.callBar getCallBarWidthWithType:_callBarType];
                        CGFloat x = SCREEN_WIDTH - w;
                        [_callBar setFrame:CGRectMake(x, y, w, h)];
                    }else {
                        CGFloat w = [self.callBar getCallBarWidthWithType:_callBarType];
                        CGFloat h = 45;
                        CGFloat x = SCREEN_WIDTH - w;
                        CGFloat y = self.callBar.y < 300 ? 300 : self.callBar.y;
                        [_callBar setFrame:CGRectMake(x, y, w, h)];
                    }
                }
            }
        }
    }
}

- (HDSMultiMediaCallBarConfiguration *)callBarConfig {
    if (!_callBarConfig) {
        _callBarConfig = [[HDSMultiMediaCallBarConfiguration alloc]init];
        _callBarConfig.callType = _callBarType;
        _callBarConfig.minY = 300;
        _callBarConfig.delayDuration = 10;
        _callBarConfig.actionType = HDSMultiMediaCallUserActionTypeApply;
        _callBarConfig.isAudioVideo = _isAudioVideoRoom ? YES : NO;
        _callBarConfig.isAudioEnable = YES;
        _callBarConfig.isVideoEnable = YES;
        _callBarConfig.isFrontCamera = YES;
    }
    return _callBarConfig;
}

/// callBar 按钮点击回调 (多人连麦)
/// @param model 当前状态
- (void)callBarBtnActionClosure:(HDSMultiMediaCallBarConfiguration *)model {
    
    switch (model.callType) {
        case HDSMultiMediaCallBarTypeVideoApply: {
    
            [self call];
        } break;
        case HDSMultiMediaCallBarTypeAudioApply: {
    
            [self call];
        } break;
        case HDSMultiMediaCallBarTypeVideoCalling: {
    
            [self hds_alert_cancelMultiMediaCallWithTitle:hds_student_cancel_apply_mediaCall];
        } break;
        case HDSMultiMediaCallBarTypeAudioCalling: {
    
            [self hds_alert_cancelMultiMediaCallWithTitle:hds_student_cancel_apply_mediaCall];
        } break;
        case HDSMultiMediaCallBarTypeVideoInvitation: {
            if (model.actionType == HDSMultiMediaCallUserActionTypeApply) {
    
                [self agreeCall];
            }else if (model.actionType == HDSMultiMediaCallUserActionTypeHangup) {
    
                [self hds_alert_cancelMultiMediaCallWithTitle:hds_student_reject_incitation];
            }
        } break;
        case HDSMultiMediaCallBarTypeAudioInvitation: {
            if (model.actionType == HDSMultiMediaCallUserActionTypeApply) {
    
                [self agreeCall];
            }else if (model.actionType == HDSMultiMediaCallUserActionTypeHangup) {
    
                [self hds_alert_cancelMultiMediaCallWithTitle:hds_student_reject_incitation];
            }
        } break;
        case HDSMultiMediaCallBarTypeVideoConnecting: {
    
            [self hds_alert_cancelMultiMediaCallWithTitle:hds_student_cancel_apply_mediaCall];
        } break;
        case HDSMultiMediaCallBarTypeAudioConnecting: {
    
            [self hds_alert_cancelMultiMediaCallWithTitle:hds_student_cancel_apply_mediaCall];
        } break;
        case HDSMultiMediaCallBarTypeVideoCalled: {
            if (model.actionType == HDSMultiMediaCallUserActionTypeHangup) {
    
                [self hds_alert_cancelMultiMediaCallWithTitle:hds_student_hangup];
            }else if (model.actionType == HDSMultiMediaCallUserActionTypeMic) {
    
                _isAudioEnable = !_isAudioEnable;
                [self setMicEnable:model.isAudioEnable];
            }else if (model.actionType == HDSMultiMediaCallUserActionTypeCamera) {
    
                _isVideoEnable = !_isVideoEnable;
                [self setCameraEnable:model.isVideoEnable];
            }else if (model.actionType == HDSMultiMediaCallUserActionTypeChangeCamera) {
    
                [self switchCamera];
            }
        } break;
        case HDSMultiMediaCallBarTypeAudioCalled: {
            if (model.actionType == HDSMultiMediaCallUserActionTypeHangup) {
    
                [self hds_alert_cancelMultiMediaCallWithTitle:hds_student_hangup];
            }else if (model.actionType == HDSMultiMediaCallUserActionTypeMic) {
    
                _isAudioEnable = !_isAudioEnable;
                [self setMicEnable:model.isAudioEnable];
            }
        } break;
        default:
            break;
    }
}

/// 获取倒计时状态（防抖）
/// @return 是否结束
- (BOOL)getCountDownStatus {
    
    BOOL isEnd = NO;
    if (self.isCountDownEnd) {
    
        self.isCountDownEnd = NO;
        isEnd = YES;
        [self performSelector:@selector(countDown) withObject:nil afterDelay:5];
    }
    return isEnd;
}

- (void)countDown {
    
    self.isCountDownEnd = YES;
}


//#endif
#pragma mark - 添加通知
-(void)addObserver
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appWillEnterBackgroundNotification)
                                                 name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appWillEnterForegroundNotification)
                                                 name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(kBackQuestionSegment:)
                                                 name:@"kBackQuestionSegment" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(kVCViewOffset:)
                                                 name:@"k4_7InchDeviceOffsetNotification"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                            selector:@selector(emojiCustomClicked)
                                                name:KK_KB_EMOJI_CUSTOM_CLICKED
                                              object:nil];
}

- (void)kVCViewOffset:(NSNotification *)noti {
    NSDictionary *dict = noti.userInfo;
    BOOL isHidden = YES;
    if ([dict.allKeys containsObject:@"isHidden"]) {
        isHidden = [dict[@"isHidden"] boolValue];
    }
    [UIView animateWithDuration:0.45 animations:^{    
        if (isHidden == NO) {
            self.view.transform = CGAffineTransformMakeTranslation(0, -88);
        } else {
            self.view.transform = CGAffineTransformIdentity;
        }
    }];
}

- (void)kBackQuestionSegment:(NSNotification *)notif {
    if (_contentView) {
        [_contentView changeSegment];
    }
}

-(void)removeObserver
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidEnterBackgroundNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationWillEnterForegroundNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"kBackQuestionSegment"
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    //#ifdef LIANMAI_WEBRTC
    //删除菜单按钮的selected属性监听
    Class class = object_getClass(self.menuView.menuBtn);
    NSString *classString = NSStringFromClass(class);
    if ([classString containsString:@"NSKVONotifying"]) {    
        [self.menuView.menuBtn removeObserver:self forKeyPath:@"selected"];
    }
    //#endif
}
/**
 APP将要进入后台
 */
- (void)appWillEnterBackgroundNotification {
//#ifdef LockView
    if (_pauseInBackGround == NO) {
        [_lockView updateLockView];
    }
//#endif
}
/**
 APP将要进入前台
 */
- (void)appWillEnterForegroundNotification {

}


#pragma mark - 添加弹窗类事件
-(void)addAlerView:(UIView *)view{
    WS(weakSelf)
    dispatch_async(dispatch_get_main_queue(), ^{
        [APPDelegate.window addSubview:view];
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(weakSelf.view);
        }];
        [weakSelf showRollCallView];
    });
}

#pragma mark - 移除答题卡视图
-(void)removeVoteView{
    [_voteView removeFromSuperview];
    _voteView = nil;
    [_voteViewResult removeFromSuperview];
    _voteViewResult = nil;
    [self.view endEditing:YES];
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

#pragma mark - 懒加载
//playView
-(CCPlayerView *)playerView{
    if (!_playerView) {
        //视频视图
        _playerView = [[CCPlayerView alloc] initWithFrame:CGRectZero docViewType:_isSmallDocView];
        // 4.12.0 new
        _playerView.screenCaptureSwitch = self.screenCaptureSwitch;
        _playerView.delegate = self;
        WS(weakSelf)
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
        //发送聊天
        _playerView.sendChatMessage = ^(NSString * sendChatMessage) {
            [weakSelf sendChatMessageWithStr:sendChatMessage];
        };
        _playerView.touchupEvent = ^{
            [weakSelf.contentView shouldHiddenKeyBoard];
        };
        //抢红包
        _playerView.tapRedPacket = ^(NSString * _Nonnull redPacketId) {
            [weakSelf gradRedPacketWithRedPacketId:redPacketId];
        };
        _playerView.publicTipBlock = ^(NSString * _Nonnull tip) {
            [weakSelf showTipInfomationWithTitle:tip];
        };
        //#ifdef LIANMAI_WEBRTC
        //是否是请求连麦
        _playerView.connectSpeak = ^(BOOL connect) {
            if (connect) {
                [weakSelf call];
            }else{
                [weakSelf hangup:YES];
            }
        };
        
        _playerView.hds_actionClosure = ^(HDSMultiBoardViewActionModel * _Nonnull model) {
            if (model.isHangup) {
                [weakSelf hds_alert_cancelMultiMediaCallWithTitle:hds_student_hangup];
            }else {
                //todo 需要加个type audio 和 video
            }
        };
        
        //设置连麦视图
        _playerView.setRemoteView = ^(CGRect frame) {
            
        };
        //#endif
    }
    return _playerView;
}
//contentView
-(CCInteractionView *)contentView{
    if (!_contentView) {
        WS(ws)
        _contentView = [[CCInteractionView alloc] initWithFrame:CGRectZero hiddenMenuView:^{
            [ws hiddenMenuView];
        } chatBlock:^(NSString * _Nonnull msg) {
            [ws.requestData chatMessage:msg];
        } privateChatBlock:^(NSString * _Nonnull anteid, NSString * _Nonnull msg) {
            [ws.requestData privateChatWithTouserid:anteid msg:msg];
        } questionBlock:^(NSString * _Nonnull message, NSArray * _Nullable imageDataArray) {
//            if (_isLivePlay == NO) {
//                [ws addSingleBtnAlertView:@"直播未开始，无法提问"];
//                return;
//            }
            [ws submitMessage:message imageDataArray:imageDataArray];
        } docViewType:_isSmallDocView];
        _contentView.playerView = self.playerView;
    }
    return _contentView;
}

// MARK: - 发送问答
- (void)submitMessage:(NSString *)content imageDataArray:(NSArray *)imageDataArray {
    
    if (content.length == 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kLiveQAStatusDidChangeNotification object:nil userInfo:@{@"result":@"NO",@"failedArray":@[]}];
        return;
    }
    
    NSMutableArray *imageList = [NSMutableArray array];
    for (NSDictionary *imgDict in imageDataArray) {
        HDSCommitImageModel *model = [[HDSCommitImageModel alloc]init];
        model.name = imgDict[@"name"];
        model.order = [imgDict[@"order"] integerValue];
        model.size = [imgDict[@"size"] integerValue];
        model.type = imgDict[@"type"];
        model.fullPath = imgDict[@"fullPath"];
        [imageList addObject:model];
    }
    __weak typeof(self) weakSelf = self;
    [_requestData commitQuestion:content imageArray:imageList closure:^(BOOL succed, NSString * _Nonnull message, NSArray<HDSUploadErrorModel *> * _Nullable failedArray) {
        NSMutableDictionary *param = [NSMutableDictionary dictionary];
        if (succed == NO) {
            if (failedArray.count > 0) {
                HDSUploadErrorModel *model = [failedArray firstObject];
                NSString *tipStr = [weakSelf compactPromptMessageWithErrorMessage:model.message];
                if (tipStr.length > 0) {
                    [weakSelf showQuestionError:tipStr];
                }
            } else {
                if (message.length > 0) {
                    [weakSelf showQuestionError:[weakSelf compactPromptMessageWithErrorMessage:message]];
                }
            }
            NSMutableArray *tempArr = [NSMutableArray array];
            for (HDSUploadErrorModel *errorModel in failedArray) {
                HDSUploadErrorModel *oneModel = [[HDSUploadErrorModel alloc]init];
                oneModel.code = errorModel.code;
                oneModel.name = errorModel.name;
                oneModel.order = errorModel.order;
                oneModel.message = [weakSelf compactPromptMessageWithErrorMessage:errorModel.message];
                [tempArr addObject:oneModel];
            }
            param[@"result"] = @(NO);
            param[@"failedArray"] = tempArr;
        } else {
            param[@"result"] = @(YES);
            param[@"failedArray"] = @[];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:kLiveQAStatusDidChangeNotification object:nil userInfo:param];
    }];
}

- (NSString *)compactPromptMessageWithErrorMessage:(NSString *)errorMessage {
    NSString *message = @"";
    if ([errorMessage isEqualToString:@"ERROR_NOT_LIVING"]) {
        message = @"请在直播中发送问答";
    } else if ([errorMessage isEqualToString:@"ERROR_TEMPLATE_INVALID"]) {
        message = @"房间不支持问答";
    } else if ([errorMessage isEqualToString:@"ERROR_DEBOUNCE"]) {
        message = @"操作太频繁了，休息一下吧";
    } else if ([errorMessage isEqualToString:@"ERROR_CONTENT_EMPTY"]) {
        message = @"请输入内容，内容不可为空";
    } else if ([errorMessage isEqualToString:@"ERROR_CONTENT_INVALID"]) {
        message = @"请输入内容，并保证长度小于1000";
    } else if ([errorMessage isEqualToString:@"ERROR_IMG_NUMBER_INVALID"]) {
        message = @"最多只能发送6张图片";
    } else if ([errorMessage isEqualToString:@"ERROR_FILE_INVALID"]) {
        message = @"图片文件校验失败，包括文件不存在、接口返回文件不合法";
    } else if ([errorMessage isEqualToString:@"ERROR_REQUEST_FAILED"]) {
        message = @"请求失败，请检查网络";
    } else if ([errorMessage isEqualToString:@"ERROR_FILE_UPLOAD_FAILED"]) {
        message = @"图片文件上传失败，请重试";
    } else if ([errorMessage isEqualToString:@"ERROR_FILE_LARGE"]) {
        message = @"图片过大，请上传小于20M的图片";
    } else if ([errorMessage isEqualToString:@"ERROR_FILE_TYPE_SUPPORTED"]) {
        message = @"格式不支持，请选择 JPG、PNG、JPED、BMP格式的图片";
    } else if ([errorMessage isEqualToString:@"ERROR_FILE_PARAMETER"]) {
        message = @"参数错误，请稍后重试，或联系客服";
    } else if ([errorMessage isEqualToString:@"ERROR_FILE_LOGIN_FAILED"]) {
        message = @"登陆异常，请重新登陆或者刷新后重试";
    } else if ([errorMessage isEqualToString:@"ERROR_FILE_NOT_EXISTS"]) {
        message = @"图片文件不存在，请重试";
    } else if ([errorMessage isEqualToString:@"FILE_UPLOAD_SUCCED"]) {
        message = @"图片文件上传成功";
    } else if ([errorMessage isEqualToString:@"COMMIT_QUESTION_SUCCED"]) {
        message = @"问答提交成功";
    }
    return message;
}

- (void)showQuestionError:(NSString *)errorMessage {
    if (errorMessage.length == 0) {
        return;
    }
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf showTipInfomationWithTitle:errorMessage];
    });
}

//竖屏模式下点击空白退出键盘
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (self.screenLandScape == NO) {
        [self.view endEditing:YES];
    }
}

//隐藏home条
- (BOOL)prefersHomeIndicatorAutoHidden {
    return  YES;
}

//问卷和问卷统计
//移除问卷视图
-(void)removeQuestionnaireSurvey {
    [_questionnaireSurvey removeFromSuperview];
    _questionnaireSurvey = nil;
    [_questionnaireSurveyPopUp removeFromSuperview];
    _questionnaireSurveyPopUp = nil;
}
//签到
-(RollcallView *)rollcallView {
    if(!_rollcallView) {
        WS(weakSelf)
        RollcallView *rollcallView = [[RollcallView alloc] initWithDuration:weakSelf.duration lotteryblock:^{
            [weakSelf.requestData answer_rollcall];//签到
        } isScreenLandScape:self.screenLandScape];
        _rollcallView = rollcallView;
    }
    return _rollcallView;
}
//移除签到视图
-(void)removeRollCallView {
    [_rollcallView removeFromSuperview];
    _rollcallView = nil;
}
//显示签到视图
-(void)showRollCallView{
    if (_rollcallView) {
        [APPDelegate.window bringSubviewToFront:_rollcallView];
    }
}
/**
 *    @brief    随堂测数据
 */
- (NSMutableDictionary *)testDict
{
    if (!_testDict) {
        _testDict = [NSMutableDictionary dictionary];
    }
    return _testDict;
}

//更多菜单
-(SelectMenuView *)menuView{
    if (!_menuView) {
        WS(ws)
        _menuView = [[SelectMenuView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 50, SCREEN_HEIGHT - 230 - kScreenBottom, 35, 35)];
        _menuView.tag = 1002;
        //私聊按钮回调
        _menuView.privateBlock = ^{
            [ws.contentView.chatView privateChatBtnClicked];
            [APPDelegate.window bringSubviewToFront:ws.contentView.chatView.ccPrivateChatView];
        };
        //#ifdef LIANMAI_WEBRTC
        //连麦按钮回调
        _menuView.lianmaiBlock = ^{
            [ws.playerView lianmaiBtnClicked];
        };
        [_menuView.menuBtn addObserver:self forKeyPath:@"selected" options:NSKeyValueObservingOptionNew context:nil];
        //#endif
        //公告按钮回调
        _menuView.announcementBlock = ^{
            [ws announcementBtnClicked];
            [APPDelegate.window bringSubviewToFront:ws.announcementView];
        };
        if (_showNewAnnouncementTipView == nil) {
            UILabel *tipLabel = [[UILabel alloc]init];
            tipLabel.textColor = [UIColor colorWithHexString:@"#FFFFFF" alpha:1];
            tipLabel.font = [UIFont systemFontOfSize:14];
            tipLabel.textAlignment = NSTextAlignmentCenter;
            tipLabel.text = @"公告消息可在更多中查看";
            _showNewAnnouncementTipLabel = tipLabel;
            _showNewAnnouncementTipView = [[UIImageView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH - 50 - 2 - 184, SCREEN_HEIGHT - 230 - kScreenBottom, 184, 32)];
            _showNewAnnouncementTipView.image = [UIImage imageNamed:@"提示气泡"];
            [_showNewAnnouncementTipView addSubview:_showNewAnnouncementTipLabel];
           
            [tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(ws.showNewAnnouncementTipView).offset(10);
                make.right.mas_equalTo(ws.showNewAnnouncementTipView).offset(-10);
                make.centerY.mas_equalTo(ws.showNewAnnouncementTipView);
            }];
            
            [APPDelegate.window addSubview:_showNewAnnouncementTipView];
            [APPDelegate.window bringSubviewToFront:_showNewAnnouncementTipView];
            _showNewAnnouncementTipView.hidden = YES;
            _showNewAnnouncementTipView.layer.cornerRadius = 16.f;
            _showNewAnnouncementTipView.layer.masksToBounds = YES;
        }
    }
    return _menuView;
}
//收回菜单
-(void)hiddenMenuView{
    //#ifdef LIANMAI_WEBRTC
    //如果菜单是展开状态,切换时关闭菜单
    if (_menuView.isOpen) {
        [_menuView hiddenAllBtns:YES];
    }
    //#endif
}
//#ifdef LIANMAI_WEBRTC
//监听菜单按钮的selected属性
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    BOOL hidden = change[@"new"] == 0 ? YES: NO;
    [_playerView menuViewSelected:hidden];
}
//#endif
//公告
-(AnnouncementView *)announcementView{
    if (!_announcementView) {
        _announcementView = [[AnnouncementView alloc] initWithAnnouncementStr:_gongGaoStr];
        _announcementView.tag = 1003;
        _announcementView.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 417.5);
    }
    return _announcementView;
}
//点击公告按钮
-(void)announcementBtnClicked{
    [APPDelegate.window addSubview:self.announcementView];
    WS(ws)
    [UIView animateWithDuration:0.3 animations:^{
       ws.announcementView.frame = CGRectMake(0, HDGetRealHeight+SCREEN_STATUS, SCREEN_WIDTH,IS_IPHONE_X ? 417.5 + 90:417.5);
    } completion:^(BOOL finished) {
        if (ws.isCloseHistoryAnnouncementView == YES) {
            ws.showNewAnnouncementTipView.hidden = YES;
        }
    }];
}

// MARK: - Alert View
/// 需要直接退出房间的alert
/// @param tipStr 提示语
- (void)hds_exitReLoginSingBtnWithTipStr:(NSString *)tipStr {
    WS(weakSelf)
    dispatch_async(dispatch_get_main_queue(), ^{
        if (weakSelf.abilityDownAlertView) return;
        if (weakSelf.alertView) {
            [weakSelf.alertView removeFromSuperview];
            weakSelf.alertView = nil;
        }
        [weakSelf.callBar removeFromSuperview];
        weakSelf.callBar = nil;
        if (weakSelf.needLogoutAlert) {
            [weakSelf.needLogoutAlert removeFromSuperview];
            weakSelf.needLogoutAlert = nil;
        }
        weakSelf.needLogoutAlert = [[CCAlertView alloc]initWithAlertTitle:tipStr sureAction:SURE cancelAction:nil sureBlock:^{
            [self exitPlayLive];
        }];
        [APPDelegate.window addSubview:weakSelf.needLogoutAlert];
    });
}

/**
 *    @brief    主动退出直播间
 */
- (void)hds_onExit {
    
    WS(ws)
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (ws.alertView) {
            [ws.alertView removeFromSuperview];
            ws.alertView = nil;
        }
        ws.alertView = [[CCAlertView alloc] initWithAlertTitle:ALERT_EXITPLAY sureAction:SURE cancelAction:CANCEL sureBlock:^{
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (ws.lockView) {
                    [ws.lockView removeFromSuperview];
                    ws.lockView = nil;
                }
                [ws exitPlayLive];
                ws.playerView.backButton.enabled = NO;
            });
        }];
        [APPDelegate.window addSubview:ws.alertView];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            ws.playerView.backButton.userInteractionEnabled = YES;
        });
    });
}

/// 多人连麦挂断连麦alert提示
/// @param title 提示信息
- (void)hds_alert_cancelMultiMediaCallWithTitle:(NSString *)title {
    WS(weakSelf)
    dispatch_async(dispatch_get_main_queue(), ^{
        if (weakSelf.alertView) {
            [weakSelf.alertView removeFromSuperview];
            weakSelf.alertView = nil;
        }
        CCAlertView *alertView = [[CCAlertView alloc] initWithAlertTitle:title sureAction:SURE cancelAction:CANCEL sureBlock:^{
            if ([title isEqualToString:hds_student_reject_incitation]) {
                [weakSelf rejectCall];
            }else {
                [weakSelf hangup:YES];
            }
        }];
        [APPDelegate.window addSubview:alertView];
    });
}

/// 多人连麦连麦功能不可用提示
/// @param title 提示信息
- (void)hds_alert_abilityDownWithTitle:(NSString *)title {
    WS(weakSelf)
    dispatch_async(dispatch_get_main_queue(), ^{
        if (weakSelf.needLogoutAlert) return;
        if (weakSelf.alertView) {
            [weakSelf.alertView removeFromSuperview];
            weakSelf.alertView = nil;
        }
        [weakSelf.callBar removeFromSuperview];
        weakSelf.callBar = nil;
        if (weakSelf.abilityDownAlertView) {
            [weakSelf.abilityDownAlertView removeFromSuperview];
            weakSelf.abilityDownAlertView = nil;
        }
        weakSelf.abilityDownAlertView = [[CCAlertView alloc] initWithAlertTitle:title sureAction:SURE cancelAction:CANCEL sureBlock:^{
            [weakSelf exitPlayLive];
        }];
        [APPDelegate.window addSubview:weakSelf.abilityDownAlertView];
    });
}

- (void)addSingleBtnAlertView:(NSString *)str {
    WS(weakSelf)
    dispatch_async(dispatch_get_main_queue(), ^{
        if (weakSelf.alertView) {
            [weakSelf.alertView removeFromSuperview];
            weakSelf.alertView = nil;
        }
        weakSelf.alertView = [[CCAlertView alloc] initWithAlertTitle:str sureAction:ALERT_SURE cancelAction:nil sureBlock:nil];
        [APPDelegate.window addSubview:weakSelf.alertView];
    });
}


#pragma mark - 屏幕旋转
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

/**
 *    @brief    强制转屏
 *    @param    orientation   旋转方向
 */
- (void)interfaceOrientation:(UIInterfaceOrientation)orientation {
    /// 4.5.1 new
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
    WS(ws)
    if (isLaunchScreen == YES) {
        [self.playerView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self.view);
        }];
        [_playerView layoutIfNeeded];
        
        if (_interManager) {
            [_interManager screenOrientationDidChange:landspace];
        }
        HDSVoteTool.tool.isLandspace = YES;
        
        CGFloat width = self.view.width;
        //#ifdef LIANMAI_WEBRTC
        if (_isMutilMediaCallRoom) {
            if ( _callBarType == HDSMultiMediaCallBarTypeVideoCalled) {
                width = width - 189.5;
            }
            self.callBarConfig.callType = _callBarType;
            [self updateCallBarStatusConfig:self.callBarConfig];
        }
        //#endif
        
        [self.playerView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.top.bottom.equalTo(self.view);
            make.width.mas_equalTo(SCREEN_WIDTH);
        }];
        [_playerView layoutIfNeeded];
        
        [self.playerView.hdContentView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(width);
            make.height.mas_equalTo(SCREEN_HEIGHT);
        }];
        [self.playerView.hdContentView layoutIfNeeded];
        
        if (self.docOrVideoFlag == 1) {
            /// 3.18.0 new
            self.hds_playerView.frame = CGRectMake(0, 0, width, self.view.height);
            self.hds_playerContentView.frame = CGRectMake(0, 0, width, self.view.height);
            /// 3.17.3 new
            _kPlayerParent.frame = CGRectMake(0, 0, width, self.view.height);
        } else {
            [_requestData changeDocFrame:CGRectMake(0, 0, width, self.view.height)];
        }
        /// 3.17.3 new
        [self updateSupportView];
        //#ifdef LIANMAI_WEBRTC
        if (!_isMutilMediaCallRoom) {
            /// 3.18.0 new
            [self updateRemoteView];
        }else {
            [self update_hds_multi_remoteView];
        }
        //#endif
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [ws.marqueeView startMarquee];
        });
        self.screenLandScape = YES;
    } else {
        HDSVoteTool.tool.isLandspace = NO;
        if (_interManager) {
            [_interManager screenOrientationDidChange:portrait];
        }
        
        CGFloat height = HDGetRealHeight;
        //#ifdef LIANMAI_WEBRTC
        if (_isMutilMediaCallRoom) {
            if ( _callBarType == HDSMultiMediaCallBarTypeVideoCalled) {
                height = height + 70;
            }
            self.callBarConfig.callType = _callBarType;
            [self updateCallBarStatusConfig:self.callBarConfig];
        }
        //#endif
        
        [self.playerView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view).offset(SCREEN_STATUS);
            make.left.right.equalTo(self.view);
            make.height.mas_equalTo(height);
        }];
        [_playerView layoutIfNeeded];
        
        [self.playerView.hdContentView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(SCREEN_WIDTH);
            make.height.mas_equalTo(HDGetRealHeight);
        }];
        [self.playerView.hdContentView layoutIfNeeded];
        
        //#ifdef LIANMMAI_WERBRTC
        if (self.isNeedUpdateFlag) {
            [self updateRoomSubviews:self.isNeedUpdateStatus];
            self.isNeedUpdateFlag = NO;
        }
        //#endif
        if (self.docOrVideoFlag == 1) {
            self.hds_playerView.frame = CGRectMake(0, 0, SCREEN_WIDTH, HDGetRealHeight);
            /// 3.17.3 new
            _kPlayerParent.frame = CGRectMake(0, 0, SCREEN_WIDTH, HDGetRealHeight);
            /// 3.18.0 new
            self.hds_playerContentView.frame = CGRectMake(0, 0, SCREEN_WIDTH, HDGetRealHeight);
        } else {
            [_requestData changeDocFrame:CGRectMake(0, 0, SCREEN_WIDTH, HDGetRealHeight)];
        }
        /// 3.17.3 new
        [self updateSupportView];
        
        //#ifdef LIANMAI_WEBRTC
        if (!_isMutilMediaCallRoom) {
            [self updateRemoteView];
        }else {
            [self update_hds_multi_remoteView];
        }
        self.callBarConfig.callType = _callBarType;
        [self updateCallBarStatusConfig:self.callBarConfig];
        //#endif
        
        WS(ws)
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.playerView.backButton.userInteractionEnabled = YES;
            [ws.marqueeView startMarquee];
        });
    }
    [self hds_sendUpdateConstraintNotificationToLotteryView];
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

- (void)dealloc {
    
    /*      自动登录情况下，会存在移除控制器但是SDK没有销毁的情况 */
    if (_requestData) {
        [_requestData requestCancel];
        _requestData = nil;
    }
    [self removeObserver];//移除通知
}

@end
