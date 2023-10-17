//
//  HDSLiveStreamController.m
//  CCLiveCloud
//
//  Created by richard lee on 4/27/22.
//  Copyright © 2022 MacBook Pro. All rights reserved.
//

#import "HDSLiveStreamController.h"
#import "CCSDK/RequestData.h"//SDK
#import "HDSStreamBoardView.h"
#import "HDSLiveStreamControlView.h"
#import "CCAlertView.h"
#import "InformationShowView.h"
// 4.2.0 new
#import "HDSChatDataEngine.h"
#import "HDSChatDataModel.h"
#import "HDSLiveChatView.h"
/// 4.1.0 new
#import "HDSInteractionManager.h"
#import "HDSInteractionManagerConfig.h"
#import "Utility.h"
#import "HDSLoginErrorManager.h"

// 4.11.0 new
#import "HDSPublicTipsView.h"
#import "CCcommonDefine.h"
#import <Masonry/Masonry.h>

@interface HDSLiveStreamController ()<RequestDataDelegate>

// MARK: - SDK
/// SDK
@property (nonatomic, strong) RequestData           *requestData;

// MARK: - 基础数据
/// 房间名称
@property (nonatomic, copy)   NSString              *roomName;
/// 进入后台后暂停
@property (nonatomic, assign) BOOL                  pauseInBackGround;
/// 聊天Engine
@property (nonatomic, strong) HDSChatDataEngine     *chatEngine;
/// 用户ID
@property (nonatomic, copy)   NSString              *viewerId;
/// 聊天定时器
@property (nonatomic, strong) NSTimer               *chatTimer;
/// 用户昵称
@property (nonatomic, strong) NSString              *viewerName;

/// 4.1.0 new 点赞功能配置  0:关闭 1:直播间配置 2:全局配置
@property (nonatomic, assign) NSInteger                 like_config;
/// 4.5.0 new 直播带货功能配置 0:关闭 1:直播间配置 2:全局配置
@property (nonatomic, assign) NSInteger                 liveStore_config;

/// 4.1.0 new 互动组件 token
@property (nonatomic, copy)   NSString                  *interactionToken;

/// 4.1.0 new
/// 互动组件Manager
@property (nonatomic, strong) HDSInteractionManager     *interManager;
/// 互动组件配置项
@property (nonatomic, strong) HDSInteractionManagerConfig *interManagerConfig;

// MARK: - 视图
@property (nonatomic, copy)   NSString              *errorStr;
/// 流视图
@property (nonatomic, strong) UIView                *playerView;
/// 控制层
@property (nonatomic, strong) HDSStreamBoardView    *streamBoardView;
/// 普通弹窗
@property (nonatomic, strong) CCAlertView           *alertView;
/// 单个按钮弹窗
@property (nonatomic, strong) CCAlertView           *singleBtnAlertView;
/// 吐丝视图
@property (nonatomic, strong) InformationShowView      *tipView;

@property (nonatomic, strong) HDSPublicTipsView        *publicTipsView;

@end

@implementation HDSLiveStreamController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureUI];
    [self configureData];
    [self initSDK];
    [self addObserverObj];
}

- (instancetype)initWithRoomName:(NSString *)roomName {
    self = [super init];
    if(self) {
        self.roomName = roomName;
    }
    return self;
}

- (void)setScreenCaptureSwitch:(BOOL)screenCaptureSwitch {
    _screenCaptureSwitch = screenCaptureSwitch;
}

// MARK: - Custom Method

- (void)configureUI {
    WS(weakSelf)
    _streamBoardView = [[HDSStreamBoardView alloc]initWithFrame:CGRectZero closeBtnAction:^{
        [weakSelf exitAlert];
    }];
    [self.view addSubview:_streamBoardView];
    [_streamBoardView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view);
    }];
    [_streamBoardView layoutIfNeeded];
    
    _streamBoardView.screenCaptureSwitch = _screenCaptureSwitch;
    // 发送聊天
    _streamBoardView.sendChatMessage = ^(NSString * _Nonnull msg) {
        [weakSelf sendMessage:msg];
    };
    // 切换静音
    _streamBoardView.muteStreamVoice = ^(BOOL result) {
        [weakSelf changeVideoMute:result];
    };
    // 切换线路
    _streamBoardView.changeLineBlock = ^(NSInteger index) {
        [weakSelf changeVideoLine:index];
    };
    // 切换清晰度
    _streamBoardView.changeQualityBlock = ^(NSString * _Nonnull quality) {
        [weakSelf changeVideoQuality:quality];
    };
}

- (void)configureData {
    _pauseInBackGround = NO; //进入后台后暂停
    _chatEngine = [[HDSChatDataEngine alloc]init];
    [self startChatTimer];
}

- (void)addObserverObj {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityDidChange:) name:kHDSReachabilityStatus object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(emojiCustomClicked) name:KK_KB_EMOJI_CUSTOM_CLICKED object:nil];
}

- (void)removeObserverObj {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kHDSReachabilityStatus object:nil];
}

- (void)startChatTimer {
    [self stopChatTimer];
    _chatTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(getChat) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_chatTimer forMode:NSRunLoopCommonModes];
}

- (void)stopChatTimer {
    if ([_chatTimer isValid]) {
        [_chatTimer invalidate];
        _chatTimer = nil;
    }
}

- (void)getChat {
    if (_chatEngine) {
        WS(weakSelf)
        [_chatEngine checkNewMessages:^(NSArray<HDSChatDataModel *> * _Nonnull oneMsgs) {
            [weakSelf.streamBoardView receivedNewChatMsgs:oneMsgs];
        }];
    }
}

// MARK: - 初始化SDK
- (void)initSDK {
    PlayParameter *parameter = [[PlayParameter alloc] init];
    parameter.userId = GetFromUserDefaults(WATCH_LIVE_USERID);//userId
    parameter.roomId = GetFromUserDefaults(WATCH_LIVE_ROOMID);//roomId
    parameter.viewerName = GetFromUserDefaults(WATCH_LIVE_USERNAME);//用户名
    parameter.token = GetFromUserDefaults(WATCH_LIVE_PASSWORD);//密码
    parameter.scalingMode = 2;//屏幕适配方式
    parameter.pauseInBackGround = _pauseInBackGround;//后台是否暂停
    parameter.viewerCustomua = @"viewercustomua";//自定义参数,没有的话这么写就可以
    parameter.tpl = 20;
    WS(weakSelf)
    _requestData = [[RequestData alloc] initSDKWithParameter:parameter succed:^(BOOL succed) {
        
    } player:^(UIView * _Nonnull playerView) {
        [weakSelf addLiveStreamView:playerView];
    } failed:^(NSError * _Nullable error, NSString * _Nonnull reason) {
        
    }];
    _requestData.delegate = self;
}

- (void)addLiveStreamView:(UIView *)playerView {
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        HDSLiveStreamControlView *ctrlView = weakSelf.streamBoardView.ctrlView;
        playerView.frame = ctrlView.streamView.bounds;
        [ctrlView.streamView addSubview:playerView];
    });
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
    
    [self showSingleAlertView:errorTipString closure:^{
        [self exitLive];
    }];
}

// MARK: - RequestData 代理
- (void)requestFailed:(NSError *)error reason:(NSString *)reason {
    
    if ([reason isEqualToString:_errorStr]) {
        return;
    }
    _errorStr = reason;
    if (reason.length == 0 || reason == nil) {
        _errorStr = error.localizedDescription;
    }
    if ([_errorStr isEqualToString:@"文档初始化失败"]) return;
    
    if ([_errorStr isEqualToString:@"加载视频超时，请重试"]) {
        [self showTipInfomationWithTitle:_errorStr];
    } else {
        [self showSingleAlertView:_errorStr closure:^{
            
        }];
    }
}

/**
 *    @brief    服务器端给自己设置的UserId
 */
- (void)setMyViewerId:(NSString *)viewerId {
    self.viewerId = viewerId;
    self.chatEngine.viewerId = self.viewerId;
    if (_streamBoardView) {
        _streamBoardView.viewerId = self.viewerId;
    }
}

/**
 *    @brief    服务器端给自己设置的信息
 *    viewerId 服务器端给自己设置的UserId
 *    groupId 分组id
 *    name 用户名
 */
- (void)setMyViewerInfo:(NSDictionary *)infoDic {
    if ([infoDic.allKeys containsObject:@"name"]) {
        _viewerName = infoDic[@"name"];
    }else {
        _viewerName = GetFromUserDefaults(WATCH_LIVE_USERNAME);//用户名
    }
}

/// 收到播放直播状态
/// @param status 0.正在直播 1.未开始直播
- (void)getPlayStatue:(NSInteger)status {
    if (_streamBoardView) {
        [_streamBoardView currentRoomLiveStatus:status];
    }
}

/// 直播间在线人数
- (void)onUserCount:(NSString *)count {
    if (_streamBoardView) {
        [_streamBoardView setRoomOnlineUserCountWithCount:count];
    }
}

/// 房间头像 (根据房间配置，可能存在为空)
/// - Parameter iconUrl: 头像地址
- (void)roomIcon:(NSString *)iconUrl {

}

/// 房间信息
- (void)roomInfo:(NSDictionary *)dic {
    // 房间名
    if ([dic.allKeys containsObject:@"name"]) {
        _roomName = dic[@"name"];
        if (_roomName.length == 0) {
            if ([dic.allKeys containsObject:@"baseRecordInfo"]) {
                NSDictionary *baseRecordInfo = dic[@"baseRecordInfo"];
                if ([baseRecordInfo.allKeys containsObject:@"title"]) {
                    _roomName = baseRecordInfo[@"title"];
                }
            }
        }
    }
    if (_streamBoardView) {
        [_streamBoardView roomInfo:dic];
    }
}

- (void)onRoomConfigure:(HDSRoomConfigureModel *)configure {
    if (_streamBoardView) {
        [_streamBoardView setHomeIconWithUrl:configure.roomIcon];
    }
}
// MARK: - 自定义表情

- (void)onEmojiLoadingResult:(BOOL)result message:(NSString *)message {
    if (result) {
        [self getCustomEmoji];
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

/// 进入房间后的公告信息
/// - Parameter str: 公告
- (void)announcement:(NSString *)str {
    if (_streamBoardView) {
        [_streamBoardView setHomeHistoryAnnouncement:str];
    }
}

/// 收到新的公告信息
/// - Parameter dict: 公告信息
- (void)on_announcement:(NSDictionary *)dict {
    if (_streamBoardView) {
        [_streamBoardView receiveNewAnnouncement:dict];
    }
}

/// 房间开始直播
- (void)streamDidBegin {
    if (_streamBoardView) {
        [_streamBoardView roomLiveStatus:YES];
    }
}

/// 房间直播已结束
- (void)streamDidEnd:(BOOL)endNormal tip:(NSString *)tip {
    if (tip.length > 0 && tip != nil) {
        [self showSingleAlertView:tip closure:^{
            
        }];
    }
    if (_streamBoardView) {
        [_streamBoardView roomLiveStatus:NO];
    }
    [self.interManager streamDidEnd];
}

/// 发送聊天
- (void)sendMessage:(NSString *)msg {
    if (msg.length > 0 && _requestData) {
        [_requestData chatMessage:msg];
    }
}

/// 历史聊天
- (void)onChatLog:(NSArray *)chatLogArr {
    if (_chatEngine) {
        [_chatEngine receiveHistoryChatMessages:chatLogArr];
    }
}

/// 接收到的公聊
- (void)onPublicChatMessage:(NSDictionary *)message {
    if (_chatEngine) {
        [_chatEngine receiveSingleChatMessage:message];
    }
}

/// 收到聊天禁言
/// mode 禁言类型 1：个人禁言  2：全员禁言
- (void)onBanChat:(NSDictionary *)modeDic {
    if ([modeDic.allKeys containsObject:@"mode"]) {
        NSInteger mode = [modeDic[@"mode"] integerValue];
        NSString *str = ALERT_BANCHAT(mode == 1);
        [self showSingleAlertView:str closure:^{
            
        }];
    }
}

/// 收到解除禁言事件
/// mode 禁言类型 1：个人禁言  2：全员禁言
- (void)onUnBanChat:(NSDictionary *)modeDic {
    if ([modeDic.allKeys containsObject:@"mode"]) {
        NSInteger mode = [modeDic[@"mode"] integerValue];
        NSString *str = ALERT_UNBANCHAT(mode == 1);
        [self showSingleAlertView:str closure:^{
            
        }];
    }
}

/// 收到聊天禁言并删除聊天记录
/// viewerId  禁言用户id,是自己的话别删除聊天历史,其他人需要删除该用户的聊天
- (void)onBanDeleteChat:(NSDictionary *)viewerDic {
    if (_streamBoardView) {
        [_streamBoardView deleteSingleChat:viewerDic];
    }
}
/**
 *    @brief    聊天管理
 *    status    聊天消息的状态 0 显示 1 不显示
 *    chatIds   聊天消息的id列列表
 */
- (void)chatLogManage:(NSDictionary *)manageDic {
    if (_streamBoardView) {
        [_streamBoardView chatLogManage:manageDic];
    }
}

/// 收到广播
- (void)broadcast_msg:(NSDictionary *)dic {
    if (_chatEngine) {
        [_chatEngine receiveSingleBoardcastMessage:dic];
    }
}

/// 历史广播
- (void)broadcastLast_msg:(NSArray *)array {
    if (_chatEngine) {
        [_chatEngine receiveHistoryBoardcast:array];
    }
}

/// 删除广播
- (void)broadcast_delete:(NSDictionary *)dic {
    if (_streamBoardView) {
        [_streamBoardView deleteSingleBoardcast:dic];
    }
}

/// 用户进入房间提醒
- (void)HDUserRemindWithModel:(RemindModel *)model {
    if (_streamBoardView) {
        [_streamBoardView setUserRemindWithModel:model];
    }
}

/// 房间清晰度
- (void)HDReceivedVideoQuality:(NSDictionary *)dict {
    if (_streamBoardView) {
        [_streamBoardView HDReceivedVideoQuality:dict];
    }
}

/// 房间线路
- (void)HDReceivedVideoAudioLines:(NSDictionary *)dict {
    if (_streamBoardView) {
        [_streamBoardView HDReceivedVideoAudioLines:dict];
    }
}

// MARK: - 聊天置顶
/// 房间历史置顶聊天记录
/// @param model 置顶聊天model
- (void)onHistoryTopChatRecords:(HDSHistoryTopChatModel *)model {
    if (_streamBoardView) {
        [_streamBoardView onHistoryTopChatRecords:model];
    }
}

/// 收到聊天置顶新消息
/// @param model 聊天置顶model
- (void)receivedNewTopChat:(HDSLiveTopChatModel *)model {
    if (_streamBoardView) {
        [_streamBoardView receivedNewTopChat:model];
    }
}

/// 收到批量删除聊天置顶消息
/// @param model 聊天置顶model
- (void)receivedDeleteTopChat:(HDSDeleteTopChatModel *)model {
    if (_streamBoardView) {
        [_streamBoardView receivedDeleteTopChat:model];
    }
}

// MARK: - 静音
- (void)changeVideoMute:(BOOL)result {
    __weak typeof(self) weakSelf = self;
    [weakSelf.requestData mutePlayerVoice:result closure:^(BOOL result) {
        [weakSelf.requestData getPlayerMuteStatus:^(BOOL status) {
            NSString *str = [NSString stringWithFormat:@"%@",(long)status == YES ? @"静音": @"解除静音"];
            [weakSelf showTipInfomationWithTitle:str];
        }];
    }];
}

// MARK: - 切换线路&清晰度
/// 切换视频线路
/// - Parameter index: 线路下标
- (void)changeVideoLine:(NSInteger)index {
    __weak typeof(self) weakSelf = self;
    [_requestData changeLine:index completion:^(NSDictionary *results) {
        NSInteger result = [results[@"success"] integerValue];
        [weakSelf showTextWithIndex:result];
    }];
}

/// 切换视频清晰度
/// - Parameter quality: 清晰度
- (void)changeVideoQuality:(NSString *)quality {
    __weak typeof(self) weakSelf = self;
    [_requestData changeQuality:quality completion:^(NSDictionary *results) {
        NSInteger result = [results[@"success"] integerValue];
        [weakSelf showTextWithIndex:result];
    }];
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

// MARK: - 获取互动组件Token 4.1.0
/// 互动功能配置
/// @param configModel 配置信息
- (void)onInteractionFunctionConfig:(HDSInteractionFunctionModel *)configModel {
    
    HDSInteractionLikeModel *likeModel = configModel.likeModel;
    self.like_config = likeModel.likeFunctionConfig;
    self.liveStore_config = configModel.liveStoreModel.liveStoreSwitch;
    if (_streamBoardView) {
        _streamBoardView.liveStoreSwitch = self.liveStore_config;
    }
    if (self.liveStore_config != 0 || self.like_config != 0) {
        [self getInteractionToken];
    }
}

/// 获取互动组件token
- (void)getInteractionToken {
    if (_requestData == nil) return;
    __weak typeof(self) weakSelf = self;
    [_requestData getInteractionTokenWithClosure:^(BOOL result, NSString * _Nullable message) {
        if (result) {

        }else {

            [weakSelf showTipInfomationWithTitle:message];
        }
    } tokenClosure:^(NSString * _Nullable token) {
        weakSelf.interactionToken = token;
        [weakSelf getInteractiveOngoing];
    }];
}

/// 获取正在进行中的互动
- (void)getInteractiveOngoing {
    __weak typeof(self) weakSelf = self;
    [_requestData getInteractiveOngoingWithClosure:^(BOOL result, NSString * _Nullable message) {
        if (result) {
            
        }else {
            
            [weakSelf showTipInfomationWithTitle:message];
        }
    } ongoingClosure:^(NSArray * _Nullable arr) {
        [weakSelf initInteractionManager:arr];
    }];
}

/// 初始化互动Manager
- (void)initInteractionManager:(NSArray *)arr {
    
    self.interManagerConfig = [[HDSInteractionManagerConfig alloc]init];
    self.interManagerConfig.userId = self.viewerId;
    self.interManagerConfig.userName = self.viewerName;
    self.interManagerConfig.roomId = GetFromUserDefaults(WATCH_LIVE_ROOMID);
    self.interManagerConfig.token = self.interactionToken;
    self.interManagerConfig.likeConfig = self.like_config;
    self.interManagerConfig.liveStoreConfig = self.liveStore_config;
    self.interManagerConfig.interactionArr = arr;
    self.interManagerConfig.rootVC = self;
    self.interManagerConfig.boardView = self.streamBoardView.ctrlView;
    
    self.interManager = [[HDSInteractionManager alloc]initWithConfig:self.interManagerConfig];
}

// MARK: - 退出直播
- (void)exitAlert {
    __weak typeof(self) weakSelf = self;
    [self showDoubleAlertView:ALERT_EXITPLAY closure:^{
        [weakSelf exitLive];
    }];
}

/// 退出直播
- (void)exitLive {
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (weakSelf.interManager) {
            [weakSelf.interManager killAll];
            weakSelf.interManager = nil;
        }
        if (weakSelf.requestData) {
            [weakSelf.requestData shutdownPlayer];
            [weakSelf.requestData requestCancel];
            weakSelf.requestData = nil;
        }
        [weakSelf stopChatTimer];
        if (weakSelf.playerView) {
            [weakSelf.playerView removeFromSuperview];
            weakSelf.playerView = nil;
        }
        [weakSelf dismissViewControllerAnimated:NO completion:^{
            
        }];
    });
}

// MARK: - 弹窗
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

/// 展示两个按钮的弹窗
/// - Parameters:
///   - titleStr: 展示信息
///   - closure: 操作回调
- (void)showDoubleAlertView:(NSString *)titleStr closure:(void(^)(void))closure {
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (weakSelf.alertView) {
            [weakSelf.alertView removeFromSuperview];
            weakSelf.alertView = nil;
        }
        if (weakSelf.singleBtnAlertView) {
            [weakSelf.singleBtnAlertView removeFromSuperview];
            weakSelf.singleBtnAlertView = nil;
        }
        weakSelf.alertView = [[CCAlertView alloc] initWithAlertTitle:titleStr sureAction:SURE cancelAction:CANCEL sureBlock:^{
            if (closure) {
                closure();
            }
        }];
        [APPDelegate.window addSubview:weakSelf.alertView];
    });
}

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

/// 展示吐丝信息视图
/// - Parameter title: 展示信息
- (void)showTipInfomationWithTitle:(NSString *)title {
    __weak typeof(self) weakSelf = self;
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

/// 隐藏吐丝视图
- (void)hiddenTipView {
    if (_tipView) {
        [_tipView removeFromSuperview];
        _tipView = nil;
    }
}

// MARK: - 网络状态监听
- (void)reachabilityDidChange:(NSNotification *)noti {
    NSDictionary *dict = noti.userInfo;
    if ([dict.allKeys containsObject:@"status"]) {
        NSString *status = dict[@"status"];
        NSString *tipStr = @"";
        if ([status isEqualToString:@"NotReachable"]) {
            tipStr = @"当前无网络连接，请检查网络";
        } else if ([status isEqualToString:@"ReachableViaWiFi"]) {
            tipStr = @"已连接WiFi";
        } else if ([status isEqualToString:@"ReachableViaWWAN"]) {
            tipStr = @"已连接蜂窝网络";
        }
        if (tipStr.length == 0) {
            return;
        }
        [self showTipInfomationWithTitle:tipStr];
    }
}

- (void)dealloc {
    [self removeObserverObj];
}

@end
