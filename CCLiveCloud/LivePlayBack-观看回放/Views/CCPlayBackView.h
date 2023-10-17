//
//  CCPlayBackView.h
//  CCLiveCloud
//
//  Created by MacBook Pro on 2018/11/20.
//  Copyright © 2018 MacBook Pro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MySlider.h"
#import "LoadingView.h"//加载
#import "CCDocView.h"//文档视图
#import "CCButton.h"
#import "CCSDK/PlayParameter.h"
NS_ASSUME_NONNULL_BEGIN

// 4.11.0 new VR眼镜模式开关回调
typedef void (^hds_vrGlassesModelClosure)(BOOL result);
// 4.11.0 new VR陀螺仪开关回调
typedef void (^hds_vrGyroClosure)(BOOL result);

@protocol CCPlayBackViewDelegate <NSObject>

/**
 全屏按钮点击代理

 @param tag 1视频为主，2文档为主
 */
-(void)quanpingBtnClicked:(NSInteger)tag;

/**
 返回按钮点击代理

 @param tag 1.视频为主，2.文档为主
 */
-(void)backBtnClicked:(NSInteger)tag;

/**
 切换视频/文档按钮点击回调

 @param tag changeBtn的tag值
 */
-(void)changeBtnClicked:(NSInteger)tag;

/**
 *    @brief    播放完成
 */
-(void)playDone;

@end

@interface CCPlayBackView : UIView
@property (nonatomic,assign)BOOL                          isScreenLandScape;//是否横屏
@property (nonatomic,assign)float                         playBackRate;//播放速率
@property (nonatomic,strong)NSTimer                     * timer;//计时器
@property (nonatomic,strong)CCDocView                   * smallVideoView;//文档或者小图
@property (nonatomic, strong)UIButton                   * smallCloseBtn;//小窗关闭按钮
@property (nonatomic,strong)LoadingView                 * loadingView;//加载视图
@property (nonatomic, weak)id<CCPlayBackViewDelegate>     delegate;//代理

@property (nonatomic, strong)UILabel                    * titleLabel;//房间标题
@property (nonatomic, strong)UILabel                    * leftTimeLabel;//当前播放时长
@property (nonatomic, strong)UILabel                    * rightTimeLabel;//总时长
@property (nonatomic, strong)MySlider                   * slider;//滑动条
@property (nonatomic, strong)CCButton                   * backButton;//返回按钮
@property (nonatomic, strong)CCButton                   * changeButton;//切换视频文档按钮
@property (nonatomic, strong)CCButton                   * quanpingButton;//全屏按钮
@property (nonatomic, strong)CCButton                   * pauseButton;//暂停按钮
@property (nonatomic, strong)CCButton                   * speedButton;//倍速按钮
@property (nonatomic, assign)NSInteger                    sliderValue;//滑动值
@property (nonatomic, strong)UIView                     * controlView;//控制视图
/** 是否是离线回放 */
@property (nonatomic, assign)BOOL                         isOffline;

@property (nonatomic, strong)UIImageView                * liveEnd;//播放结束视图

@property (nonatomic, assign)BOOL                         playDone;//播放完成
/** 仅有视频模式 */
@property (nonatomic, assign)BOOL                         isOnlyVideoMode;
/** 视频缓存速度 */
@property (nonatomic, copy) NSString                    * bufferSpeed;

/// 内容视图
@property (nonatomic, strong) UIView                    * contentView;
/// 顶部视图
@property (nonatomic, strong) UIView                    * headerView;

/// 是否试看结束
@property (nonatomic, assign) BOOL                      isTrialEnd;
/// 是看结束时间
@property (nonatomic, assign) NSTimeInterval            trialEndDuration;

@property (nonatomic,copy) void(^exitCallBack)(void);//退出直播间回调
@property (nonatomic,copy) void(^sliderCallBack)(int);//滑块回调
@property (nonatomic,copy) void(^sliderMoving)(void);//滑块移动回调
@property (nonatomic,copy) void(^changeRate)(float rate);//改变播放器速率回调
@property (nonatomic,copy) void(^pausePlayer)(BOOL pause);//暂停播放器回调
@property (nonatomic,copy) void(^playerRetryBlock)(BOOL retry);//播放失败重试
@property (nonatomic,copy) void(^selectedRod)(NSInteger);//切换线路
@property (nonatomic,copy) void(^switchAudio)(BOOL);//切换音频模式 yes 音频 no 视频
@property (nonatomic,copy) void(^selectedQuality)(NSString *quality);//切换清晰度
@property (nonatomic,copy) void(^replayBtnTapClosure)(void);//重播

/// 4.12.0 new 屏幕开关 YES 开启防录屏 NO 关闭防录屏
@property (nonatomic, assign) BOOL screenCaptureSwitch;
/**
 初始化方法

 @param frame frame
 @param isSmallDocView 是否是文档小窗
 @return self;
 */
- (instancetype)initWithFrame:(CGRect)frame docViewType:(BOOL)isSmallDocView;
/**
 显示加载中视图
 */
-(void)showLoadingView;

/**
 移除加载中视图
 */
-(void)removeLoadingView;
/**
 *    @brief    展示历史播放记录view
 *    @param    time   历史播放时间
 */
- (void)showRecordHistoryPlayViewWithRecordHistoryTime:(int)time;

/**
 *    @brief    隐藏历史播放记录view
 */
- (void)hiddenRecordHistoryPlayView;
#pragma mark - 屏幕旋转
//转为横屏
//-(void)turnRight;
//转为竖屏
//-(void)turnPortrait;
//添加小窗
- (void)addSmallView;

/**
 *  双击PPT时进入全屏，playView 统一的全屏方法
*/
- (void)quanpingBtnClick;

/**
 *  @tag 双击PPT退出全屏，默认tag值传2 playView 统一处理退出全屏
*/
- (void)backBtnClickWithTag:(NSInteger)tag;
/**
 *  @brief  加载视频失败
 */
- (void)playback_loadVideoFail;
/**
 *    @brief    更新UI层级
 */
- (void)updateUITier;
/**
 *    The New Method (3.13.0)
 *    @brief    是否开启音频模式
 *    @param    hasAudio   HAVE_AUDIO_LINE_TURE 有音频 HAVE_AUDIO_LINE_FALSE 无音频
 *
 *    触发回调条件 1.初始化SDK登录成功后
 */
- (void)HDAudioMode:(HAVE_AUDIO_LINE)hasAudio;
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
- (void)HDReceivedVideoQuality:(NSDictionary *)dict;
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
- (void)HDReceivedVideoAudioLines:(NSDictionary *)dict;
/**
 *    @brief    回放打点数据
 *    @param    dotList   打点信息
 *              @[HDReplayDotModel,HDReplayDotModel]
 */
- (void)HDReplayDotList:(NSArray *)dotList;
@end

NS_ASSUME_NONNULL_END
