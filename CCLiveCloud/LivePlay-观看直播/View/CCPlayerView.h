//
//  CCPlayerView.h
//  CCLiveCloud
//
//  Created by MacBook Pro on 2018/10/31.
//  Copyright © 2018 MacBook Pro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomTextField.h"
#import "InformationShowView.h"//提示框
#import "SelectMenuView.h"//更多菜单
#import "LoadingView.h"//加载
#import "CCSDK/PlayParameter.h"
//#ifdef LIANMAI_WEBRTC
#import "LianmaiView.h"//连麦
#import "HDSMultiMediaCallStreamModel.h"
#import "HDSMultiBoardViewActionModel.h"
//#endif
#import "CCDocView.h"//文档视图
#import "CCPublicChatModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^cleanVoteAndTestBlock)(NSInteger type);//收起随堂测/答题卡回调

typedef void (^hds_actionClosure)(HDSMultiBoardViewActionModel *model);

// 4.11.0 new VR眼镜模式开关回调
typedef void (^hds_vrGlassesModelClosure)(BOOL result);
// 4.11.0 new VR陀螺仪开关回调
typedef void (^hds_vrGyroClosure)(BOOL result);

@protocol CCPlayerViewDelegate <NSObject>
/**
 点击全屏按钮代理

 @param tag 1为视频为主，2为文档为主
 */
- (void)quanpingButtonClick:(NSInteger)tag;
/**
 点击退出按钮(返回竖屏或者结束直播)

 @param sender backBtn
 @param tag changeBtn的标记，1为视频为主，2为文档为主
 */
- (void)backButtonClick:(UIButton *)sender changeBtnTag:(NSInteger)tag;
/**
 点击切换视频/文档按钮

 @param tag changeBtn的tag值
 */
- (void)changeBtnClicked:(NSInteger)tag;

@end

@interface CCPlayerView : UIView

@property (nonatomic,copy) void(^selectedRod)(NSInteger);//切换线路
@property (nonatomic,copy) void(^switchAudio)(BOOL);//切换音频模式 yes 音频 no 视频
@property (nonatomic,copy) void(^selectedAudioRod)(NSInteger);//切换音频线路
@property (nonatomic,copy) void(^sendChatMessage)(NSString *);//发送聊天
@property (nonatomic,copy) void(^selectedQuality)(NSString *quality);//切换清晰度
@property (nonatomic,copy) void(^playerRetryBlock)(BOOL retry); //播放失败重试
@property (nonatomic,copy) void(^touchupEvent)(void); //点击事件
@property (nonatomic,copy) void(^publicTipBlock)(NSString *tip);
@property (nonatomic,copy) void(^tapRedPacket)(NSString *redPacketId); //抢红包

@property (nonatomic, weak)id<CCPlayerViewDelegate>       delegate;
@property (nonatomic, strong)UIView                     * topShadowView;//上面的阴影
@property (nonatomic, strong)UIView                     * bottomShadowView;//下面的阴影
@property (nonatomic, strong)UIView                     * selectedIndexView;//选择线路背景视图
@property (nonatomic, strong)UIView                     * contentView;//横屏聊天视图
@property (nonatomic, strong)UILabel                    * titleLabel;//房间标题
@property (nonatomic, strong)UILabel                    * unStart;//直播未开始
@property (nonatomic, strong)UILabel                    * userCountLabel;//在线人数
@property (nonatomic, strong)UIButton                   * backButton;//返回按钮
@property (nonatomic, strong)UIButton                   * changeButton;//切换视频文档按钮
@property (nonatomic, strong)UIButton                   * quanpingButton;//全屏按钮
@property (nonatomic, strong)UIImageView                * liveUnStart;//直播未开始视图
@property(nonatomic,strong)SelectMenuView               *menuView;//选择菜单视图
@property (nonatomic,strong)CCDocView                   *smallVideoView;//文档或者小图

@property (nonatomic,strong)LoadingView                 *loadingView;//加载视图
@property (nonatomic,assign)BOOL                        endNormal;//是否直播结束
@property (nonatomic,assign)NSInteger                   templateType;//房间类型
@property (nonatomic,strong)InformationShowView         *informationViewPop;
/** 是否是聊天事件弹起键盘 仅用于聊天功能 */
@property (nonatomic,assign)BOOL                        isChatActionKeyboard;
/** 仅有视频模式 */
@property (nonatomic, assign)BOOL                       isOnlyVideoMode;
/** 视频缓存速度 */
@property (nonatomic, copy) NSString                    *bufferSpeed;
/** 收起随堂测/答题卡事件回调 0 随堂测 1答题卡 */
@property(nonatomic,copy) cleanVoteAndTestBlock         cleanVoteAndTestBlock;

@property (nonatomic, strong) UIView                    *hdContentView;
/// 3.17.3 new
@property (nonatomic, strong) UIView                    *headerView;
/// 4.6.0 new 视频为主
@property (nonatomic, assign) BOOL                      isVideoMainScreen;

//#ifdef LIANMAI_WEBRTC
/// 3.18.0 new  多人连麦是否需要展示流视图
@property (nonatomic, assign) BOOL                  isMultiMediaShowStreamView;
/// 3.18.0 new  是否是无延迟房间
@property (nonatomic, assign) BOOL                  isRTCLive;

@property(nonatomic,strong)LianmaiView              *lianMaiView;//连麦
@property(assign,nonatomic)BOOL                     isAllow;
@property(assign,nonatomic)BOOL                     needReloadLianMainView;
@property(nonatomic,assign)BOOL                     lianMaiHidden;
@property(nonatomic, assign)NSInteger               videoType;
@property(nonatomic,assign)NSInteger                audoType;
@property(copy,nonatomic)  NSString                 *videosizeStr;
@property(nonatomic,assign)BOOL                     isAudioVideo;//YES表示音视频连麦，NO表示音频连麦
@property(strong,nonatomic)UIView                   *remoteView;//远程连麦视图
@property(nonatomic,strong)UIImageView              *connectingImage;//连麦中提示信息
@property(nonatomic,copy) void(^setRemoteView)(CGRect frame);//设置连麦视图回调
@property(nonatomic,copy) void(^connectSpeak)(BOOL connect);//是否断开连麦
@property (nonatomic, copy) hds_actionClosure           hds_actionClosure;
//#endif

/// 4.12.0 new 屏幕开关 YES 开启防录屏 NO 关闭防录屏
@property (nonatomic, assign) BOOL screenCaptureSwitch;

/**
 初始化方法

 @param frame 视图大小
 @param isSmallDocView docView的显示样式
 @return self
 */
- (instancetype)initWithFrame:(CGRect)frame docViewType:(BOOL)isSmallDocView;
/**
 *    @brief    meauView点击方法
 *    @param    selected   是否显示连麦
 */
-(void)menuViewSelected:(BOOL)selected;

#pragma mark - 直播状态相关代理
/**
 *    @brief  收到播放直播状态 0.正在直播 1.未开始直播
 */
- (void)getPlayStatue:(NSInteger)status;
/**
 *    @brief  主讲开始推流
 */
- (void)streamDidBegin;
/**
 *    @brief  停止直播，endNormal表示是否停止推流
 */
- (void)streamDidEnd:(BOOL)endNormal;

#pragma mark- 视频或者文档大窗
/**
 *  @brief  视频或者文档大窗
 *  isMain  1为视频为主, 0为文档为主
 */
- (void)onSwitchVideoDoc:(BOOL)isMain;
/**
 插入弹幕消息

 @param model 弹幕消息模型
 */
- (void)insertDanmuModel:(CCPublicChatModel *)model;
/**
 * 小窗添加
 */
- (void)addSmallView;
/**
 *  @dict    房间信息用来处理弹幕开关,是否显示在线人数,直播倒计时等
 */
- (void)roominfo:(NSDictionary *)dict;
/**
 *  双击PPT时进入全屏，playView 统一的全屏方法
 */
- (void)quanpingBtnClick;
/**
 *  @tag 双击PPT退出全屏，默认tag值传2 playView 统一处理退出全屏
 */
- (void)backBtnClickWithTag:(NSInteger)tag;
/**
 *    @brief    更新答题卡隐藏按钮布局(横屏)
 *    @param    completion  更新回调
 */
- (void)updateVoteWithLandScapeWithCompletion:(void (^)(BOOL result))completion;
/**
 *    @brief    更新随堂测隐藏按钮布局(横屏)
 *    @param    completion  更新回调
 */
- (void)updateTestWithLandScapeWithCompletion:(void (^)(BOOL result))completion;
/**
 *    @brief    随堂测状态控制
 */
- (void)testUPWithStatus:(BOOL)status;
/**
 *    @brief    答题卡状态控制
 */
- (void)voteUPWithStatus:(BOOL)status;
/**
 *    @brief    更新UI层级
 */
- (void)updateUITier;
/**
 *    The New Method (3.14.0)
 *    @brief    是否开启音频模式
 *    @param    hasAudio   HAVE_AUDIO_LINE_TURE 有音频 HAVE_AUDIO_LINE_FALSE 无音频
 *
 *    触发回调条件 1.初始化SDK登录成功后
 */
- (void)HDAudioMode:(HAVE_AUDIO_LINE)hasAudio;
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
- (void)HDReceivedVideoQuality:(NSDictionary *)dict;
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
- (void)HDReceivedVideoAudioLines:(NSDictionary *)dict;

/// 直播间封禁
- (void)theRoomWasBanned;

/// 4.6.0 new
- (void)updateRoomUserCount:(NSString *)userCount;

/// 开始红包雨
/// @param model 红包雨model
- (void)startRedPacketWithModel:(HDSRedPacketModel *)model;

/// 结束红包雨
/// @param redPacketId 红包雨ID
- (void)endRedPacketWithRedPacketId:(NSString *)redPacketId;

/// 展示红包雨排名
/// @param model 红包雨排名model
- (void)showRedPacketRankWithModel:(HDSRedPacketRankModel *)model;

//#ifdef LIANMAI_WEBRTC
#pragma mark - 连麦相关

/// 更新多人连麦流数据
/// @param streamModel 流数据
- (int)updateMultiMediaCallInfo:(HDSMultiMediaCallStreamModel *)streamModel;

/// 移除流视图
/// @param stModel 流信息
/// @param isKillAll 是否移除所有
- (int)removeRemoteView:(HDSMultiMediaCallStreamModel * _Nullable )stModel isKillAll:(BOOL)isKillAll;

/// 设置连麦状态
/// @param isMultiMediaCall 是否是多人连麦
/// @param connectStatus 是否在连麦中
- (void)setupMultiMediaCall:(BOOL)isMultiMediaCall connectStatus:(BOOL)connectStatus;

//连麦点击
-(void)lianmaiBtnClicked;
/*
 *  @brief WebRTC连接成功，在此代理方法中主要做一些界面的更改
 */
- (void)connectWebRTCSuccess;
/*
 *  @brief 当前是否可以连麦
 */
- (void)whetherOrNotConnectWebRTCNow:(BOOL)connect;
/**
 *  @brief 主播端接受连麦请求，在此代理方法中，要调用DequestData对象的
 *  - (void)saveUserInfo:(NSDictionary *)dict remoteView:(UIView *)remoteView;方法
 *  把收到的字典参数和远程连麦页面的view传进来，这个view需要自己设置并发给SDK，SDK将要在这个view上进行渲染
 */
- (void)acceptSpeak:(NSDictionary *)dict;
/*
 *  @brief 主播端发送断开连麦的消息，收到此消息后做断开连麦操作
 */
-(void)speak_disconnect:(BOOL)isAllow;
/*
 *  @brief 本房间为允许连麦的房间，会回调此方法，在此方法中主要设置UI的逻辑，
 *  在断开推流,登录进入直播间和改变房间是否允许连麦状态的时候，都会回调此方法
 */
- (void)allowSpeakInteraction:(BOOL)isAllow;
-(CGRect) calculateRemoteVIdeoRect:(CGRect)rect;
//是否存在远程视图
-(BOOL)exsitRmoteView;
//移除远程视图
-(void)removeRmoteView;
//移除lianmaiView
-(void)removeLianMaiView;
//#endif

@end

NS_ASSUME_NONNULL_END
