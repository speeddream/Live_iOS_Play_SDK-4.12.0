//
//  CCPlayerView.m
//  CCLiveCloud
//
//  Created by MacBook Pro on 2018/10/31.
//  Copyright © 2018 MacBook Pro. All rights reserved.
//

#import "CCPlayerView.h"
#import "Utility.h"
#import "InformationShowView.h"
#import "CCProxy.h"
#import "CCBarrage.h"
#import "CCChatContentView.h"
#import "HDPlayerBaseToolView.h"
#import "HDPlayerBaseModel.h"
#import "UIImage+animatedGIF.h"
#import "HDPlayerBaseView.h"
#import "HDPortraitToolManager.h"
#import "HDPortraitToolModel.h"
#import "HDRedPacketRainEngine.h"
#import "HDRedPacketRainConfiguration.h"
#import "UIColor+RCColor.h"
#import "CCcommonDefine.h"
#import "UIView+Extension.h"
#import <Masonry/Masonry.h>

//#ifdef LIANMAI_WEBRTC
//#import "HDSMultiMediaCallView.h"
#import "HDSMultiMediaBoardView.h"
#import "HDSMultiBoardViewActionModel.h"
#import "HDSMultiMediaCallStreamModel.h"
//#endif

@interface CCPlayerView ()<UITextFieldDelegate
//#ifdef LIANMAI_WEBRTC
, LianMaiDelegate,CCChatContentViewDelegate
//#endif
>

@property (nonatomic, assign)BOOL                       isSound;//是否是音频
@property (nonatomic, assign)BOOL                       shouldHidden;//键盘弹出隐藏导航
@property (nonatomic, assign)BOOL                       screenLandScape;//屏幕方向
@property (nonatomic, strong)UIView                     *secRoadview;//清晰度
@property (nonatomic, strong)NSTimer                    *playerTimer;//隐藏导航
@property (nonatomic, strong)NSArray                    *secRoadArr;//清晰度数组
@property (nonatomic, strong)UIButton                   *qingXiButton;//切换清晰度按钮
@property (nonatomic, strong)UIButton                   *danMuButton;//弹幕
@property (nonatomic, strong)UIImageView                *userCountLogo;//人数logo
@property (nonatomic, assign)BOOL                       isMain;//是否视频为主
@property (nonatomic, assign)BOOL                       isSmallDocView;//是否是文档小窗模式
@property (nonatomic, strong)CCBarrage                  *barrageView;//弹幕
@property (nonatomic, assign)BOOL                       showUserCount;//显示在线人数
@property (nonatomic, assign)BOOL                       openLiveCountDown;//倒计时
@property (nonatomic, assign)BOOL                       barrage;//弹幕
@property (nonatomic, assign)BOOL                       openMarquee;//跑马灯
@property (nonatomic, strong)UILabel                    *unStart1;//直播倒计时
@property (nonatomic, strong)CCChatContentView          *inputView;
@property (nonatomic, assign)BOOL                       isShowShadowView;// 新增控制阴影View
@property (nonatomic, assign)NSInteger                  showShadowCountFlag;// 文档手势冲突 获取屏幕点击回调 计数Flag
@property (nonatomic, assign)BOOL                       keyboardShow;// 键盘显示判断
@property (nonatomic, assign)NSInteger                  barrageStatus;// 弹幕显示状态 2全屏 1关闭 0半屏
/** 是小窗显示视频 */
@property (nonatomic, assign)BOOL                       isSmallVideoView;

/** 收起答题卡按钮 */
@property (nonatomic, strong) UIButton                  *cleanVoteBtn;
/** 收起随堂测按钮 */
@property (nonatomic, strong) UIButton                  *cleanTestBtn;
/** 是否展示收起随堂测按钮 */
@property (nonatomic, assign) BOOL                      showCleanTestBtn;
/** 是否展示收起答题卡按钮 */
@property (nonatomic, assign) BOOL                      showCleanVoteBtn;
/** 工具view */
@property (nonatomic, strong) HDPlayerBaseToolView      *baseToolView;
/** 更多按钮 */
@property (nonatomic, strong) UIButton                  *moreBtn;
/** 聊天按钮 */
@property (nonatomic, strong) UIButton                  *chatBtn;
/** 聊天视图 */
@property (nonatomic, strong) UIView                    *chatBaseView;
/** 正在显示工具view 默认 NO */
@property (nonatomic, assign) BOOL                      isShowToolView;
/** 线路数据锁 */
@property (nonatomic, assign) BOOL                      lineDataLock;
/** 清晰度数据锁 */
@property (nonatomic, assign) BOOL                      qualityDataLock;
/** 默认用户选择线路 */
@property (nonatomic, strong) NSMutableArray            *lineSelectedArray;
/** 默认用户选择清晰度 */
@property (nonatomic, strong) NSMutableArray            *qualitySelectedArray;
/** 用户选择线路下标 */
@property (nonatomic, assign) NSInteger                 userSelectedLineIndex;
/** 用户选择清晰度下标 */
@property (nonatomic, assign) NSInteger                 userSelectedQualityIndex;
/** 包含的线路数组 */
@property (nonatomic, strong) NSMutableArray            *lineArray;
/** 是否包含多清晰度 */
@property (nonatomic, assign) BOOL                      isMutableQuality;
/** 是否有聊天视图 */
@property (nonatomic, assign) BOOL                      isChatView;
/** 只切换音视频模式 */
@property (nonatomic, assign) BOOL                      isOnlyChangePlayMode;
/** 是否开启音频模式 */
@property (nonatomic, assign) BOOL                      isAudioMode;
/** 横屏辅助视图 */
@property (nonatomic, strong) HDPlayerBaseView          *baseView;
/** 竖屏辅助视图 */
@property (nonatomic, strong) HDPlayerBaseView          *portraitBaseView;
/** 竖屏工具视图 */
@property (nonatomic, strong) HDPortraitToolManager     *portraitToolManager;

@property (nonatomic, copy)   NSDictionary              *lineMetaData;

@property (nonatomic, copy)   NSDictionary              *qualityMetaData;

@property (nonatomic, strong) UIButton                  *danMuSettingBtn;

@property (nonatomic, strong) NSMutableArray            *barrageSelectedArray;

@property (nonatomic, strong) HDRedPacketRainEngine     *redPacketRainEngine;

@property (nonatomic, strong) UIView                    *redPacketBoardView;

@property (nonatomic, strong) HDRedPacketRainConfiguration       *redPacketConfig;

@property (nonatomic, copy) NSString                 *lastEndRedPacketId;

/// 3.18.0 new 录屏视图
@property (nonatomic, strong) UIView                    *screenCaptureView;

//#ifdef LIANMAI_WEBRTC
/// 连麦
@property (nonatomic, assign) BOOL                      isWebRTCConnecting;

//MAKR: - 多人连麦
/// 3.18.0 new 是否是多人连麦房间
@property (nonatomic, assign) BOOL                      isMultiMediaCallRoom;
/// 3.18.0 new 多人连麦是否是音视频连麦
@property (nonatomic, assign) BOOL                      isMultiAudioVideo;
/// 3.18.0 new 多人连麦boardView
@property (nonatomic, strong) HDSMultiMediaBoardView    *multiCallBoardView;

@property (nonatomic, strong) NSMutableArray            *multiCallStreamArray;

@property (nonatomic, strong) HDSMultiBoardViewActionModel *multiActionModel;

@end

@implementation CCPlayerView

/**
 *  @brief  初始化
 */
- (instancetype)initWithFrame:(CGRect)frame docViewType:(BOOL)isSmallDocView {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        _isSmallDocView = isSmallDocView;
        _isChatActionKeyboard = YES;
        _showCleanTestBtn = NO;
        _showCleanVoteBtn = NO;
        _isShowToolView = NO;
        _isChatView = NO;
        _isMutableQuality = NO;
        _isOnlyChangePlayMode = NO;
        _isSound = NO;
        if (@available(iOS 11.0, *)) {
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(screenCapture)
                                                         name:UIScreenCapturedDidChangeNotification
                                                       object:nil];
        }
        //#ifdef LIANMAI_WEBRTC
        _isMultiMediaCallRoom = NO;
        _isMultiAudioVideo = NO;
        _isWebRTCConnecting = NO;
        _multiActionModel = [[HDSMultiBoardViewActionModel alloc]init];
        _multiActionModel.isHangup = NO;
        _multiActionModel.isAudioEnable = YES;
        _multiActionModel.isVideoEnable = YES;
        _multiActionModel.isFrontCamera = YES;
        //#endif
        [self setupUI];
    }
    return self;
}

- (void)setScreenCaptureSwitch:(BOOL)screenCaptureSwitch {
    _screenCaptureSwitch = screenCaptureSwitch;
    /// 3.18.0 new 防录屏
    if ([self isCapture]) {
        [self screenCapture];
    }
}


/// 3.18.0 new 录屏通知
- (void)screenCapture {
    if (_screenCaptureSwitch == NO) {
        return;
    }
    BOOL isCap = [self isCapture];
    if (isCap) {
        self.screenCaptureView = [[UIView alloc]init];
        self.screenCaptureView.backgroundColor = [UIColor blackColor];
        [self addSubview:self.screenCaptureView];
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

/// 3.18.0 new 是否在录屏
- (BOOL)isCapture {
    if (@available(iOS 11.0, *)) {
        return [UIScreen mainScreen].isCaptured;
    }
    return NO;
}

/**
 *  @dict    房间信息用来处理弹幕开关,是否显示在线人数,直播倒计时等
 */
- (void)roominfo:(NSDictionary *)dict {
    self.titleLabel.text = dict[@"name"];
    
    _isMutableQuality = [dict[@"multiQuality"] boolValue];
    NSInteger templateType = [dict[@"templateType"] integerValue];
    if (templateType != 1 && templateType != 6) {
        _isChatView = YES;
    }else {
        _isChatView = NO;
    }
    
    // 4.11.0 new
    _templateType = templateType;
    /*
     showUserCount 显示在线人数
     openLiveCountDown 倒计时
     barrage 弹幕
     openMarquee 跑马灯
     */
    self.showUserCount = [dict[@"showUserCount"] boolValue];
    self.openLiveCountDown = [dict[@"openLiveCountdown"] boolValue];
    self.barrage = [dict[@"barrage"] boolValue];
    self.openMarquee = [dict[@"openMarquee"] boolValue];
    
    if (self.barrage == YES) {
        // 默认半屏
        self.barrageStatus = 0;
        [self updataBarrageStatus];
    }else {
        self.barrageStatus = 1;
        [self updataBarrageStatus];
    }
    
    if (self.showUserCount == NO) {
        self.userCountLogo.hidden = YES;
        self.userCountLabel.hidden = YES;
    }
    if (self.openLiveCountDown == YES) {
        NSString *live_start_time_str = [NSString stringWithFormat:@"%@", dict[@"liveStartTime"]];
//        [self timeoutWithStr:dict[@"liveStartTime"]];
        [self timeoutWithStr:live_start_time_str];
    }
    //#ifdef LIANMAI_WEBRTC
    _isMultiMediaCallRoom = YES;
    _isMultiAudioVideo = YES;
    //#endif
}

/**
 *  @brief  创建UI
 */
- (void)setupUI {
    _endNormal = YES;
    _isShowShadowView = YES; // 新增显示阴影View 默认显示
    _showShadowCountFlag = 0;
    WS(ws)
    /// 需要传给SDK用的视图
    self.hdContentView = [[UIView alloc] init];
//    self.hdContentView.backgroundColor = [UIColor redColor];
//    self.backgroundColor = UIColor.orangeColor;
    [self addSubview:self.hdContentView];
    [self.hdContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.mas_equalTo(ws);
        make.height.mas_equalTo(HDGetRealHeight);
    }];
    /// 顶部视图（展示辅助视图）
    self.headerView = [[UIView alloc]init];
    [self addSubview:self.headerView];
    [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(ws);
    }];
    
    //#ifdef LIANMAI_WEBRTC
    CGFloat mBoardViewH = 0;
    self.multiCallBoardView = [[HDSMultiMediaBoardView alloc]initWithFrame:CGRectZero closure:^(HDSMultiBoardViewActionModel * _Nonnull model) {
        if (self.hds_actionClosure) {
            self.hds_actionClosure(model);
        }
    }];
    [self addSubview:self.multiCallBoardView];
    [self.multiCallBoardView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.mas_equalTo(self);
        make.height.mas_equalTo(mBoardViewH);
    }];
    [self.multiCallBoardView layoutIfNeeded];
    //#endif
    
    /** 上面阴影 */
    self.topShadowView =[[UIView alloc] init];
    UIImageView *topShadow = [[UIImageView alloc] init];
    topShadow.image = [UIImage imageNamed:@"playerBar_against"];
    [self addSubview:self.topShadowView];
    CGFloat ipadShadowH = 44;
    if ([[UIDevice currentDevice].model isEqualToString:@"iPad"]) {
        ipadShadowH = 64;
    }
    [self.topShadowView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(ws);
        make.height.mas_equalTo(ipadShadowH);
    }];
    [self.topShadowView addSubview:topShadow];
    [topShadow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.topShadowView);
    }];
    /** 返回按钮 */
    self.backButton = [[UIButton alloc] init];
    [self.backButton setImage:[UIImage imageNamed:@"nav_ic_back_nor_white"] forState:UIControlStateNormal];
    self.backButton.tag = 1; // 默认文档大窗
    [self.topShadowView addSubview:_backButton];

    [self.backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(ws.topShadowView);
        make.centerY.equalTo(ws.topShadowView);
        make.width.height.mas_equalTo(ipadShadowH);
    }];
    [self.backButton addTarget:self action:@selector(backBtnClick:) forControlEvents:UIControlEventTouchUpInside];

    /** 更多按钮 */
    self.moreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.moreBtn setImage:[UIImage imageNamed:@"player_top_more"] forState:UIControlStateNormal];
    [self.moreBtn addTarget:self action:@selector(moreBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.topShadowView addSubview:self.moreBtn];
    [self.moreBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(ws.topShadowView).offset(-10);
        make.centerY.mas_equalTo(ws.backButton);
        make.width.height.mas_equalTo(35);
    }];
    /** 在线人数 */
    UILabel *userCountLabel = [[UILabel alloc] init];
    _userCountLabel = userCountLabel;
    userCountLabel.textColor = [UIColor whiteColor];
    userCountLabel.textAlignment = NSTextAlignmentCenter;
    userCountLabel.font = [UIFont systemFontOfSize:FontSize_24];
    [self.topShadowView addSubview:userCountLabel];
    [userCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(ws.backButton);
        make.right.equalTo(ws.moreBtn.mas_left);
        make.width.mas_equalTo(10);
    }];
    /** 在线人数logo */
    UIImageView * userCountLogo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"video_dis_people"]];
    _userCountLogo = userCountLogo;
    userCountLogo.contentMode = UIViewContentModeScaleAspectFit;
    [self.topShadowView addSubview:userCountLogo];
    [userCountLogo mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(ws.userCountLabel.mas_left).offset(-5);
        make.centerY.mas_equalTo(ws.backButton);
        make.width.height.mas_equalTo(12);
    }];
    
    /** 房间标题 */
    UILabel * titleLabel = [[UILabel alloc] init];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.font = [UIFont systemFontOfSize:FontSize_30];
    [self.topShadowView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(ws.backButton.mas_right);
        make.centerY.mas_equalTo(ws.backButton);
        make.right.mas_equalTo(userCountLogo.mas_left).offset(-5);
    }];
    [_titleLabel layoutIfNeeded];
    _titleLabel = titleLabel;
    
    /** 下阴影 */
    self.bottomShadowView =[[UIView alloc] init];
    UIImageView *bottomShadow = [[UIImageView alloc] init];
    bottomShadow.image = [UIImage imageNamed:@"playerBar"];
    [self addSubview:self.bottomShadowView];
    [self.bottomShadowView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(ws);
        make.height.mas_equalTo(44);
    }];
    [self.bottomShadowView addSubview:bottomShadow];
    [bottomShadow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.bottomShadowView);
    }];
    /** 全屏按钮 */
    self.quanpingButton = [[UIButton alloc] init];
    [self.quanpingButton setImage:[UIImage imageNamed:@"player_bottom_switch"] forState:UIControlStateNormal];
    [self.bottomShadowView addSubview:_quanpingButton];
    [self.quanpingButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(ws.bottomShadowView);
        make.right.equalTo(ws.bottomShadowView).offset(-10);
        make.width.height.mas_equalTo(35);
    }];
    [self.quanpingButton addTarget:self action:@selector(quanpingBtnClick) forControlEvents:UIControlEventTouchUpInside];
    /** 切换按钮 */
    self.changeButton = [[UIButton alloc] init];
    self.changeButton.tag = 2;//默认文档大窗
    [self.changeButton setImage:PLAY_CHANGEVIDEO_IMAGE forState:UIControlStateNormal];
    self.changeButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.isSmallVideoView = YES;//视频是否在小窗
    [self.bottomShadowView addSubview:_changeButton];
    [self.changeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(ws.bottomShadowView).offset(-55);
        make.centerY.mas_equalTo(ws.bottomShadowView);
        make.height.mas_equalTo(35);
        make.width.mas_equalTo(35);
    }];
    [self.changeButton addTarget:self action:@selector(changeBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    self.changeButton.hidden = YES;
    /** 清晰度 */
    self.qingXiButton = [[UIButton alloc] init];
    self.qingXiButton.titleLabel.textColor = [UIColor whiteColor];
    self.qingXiButton.titleLabel.font = [UIFont systemFontOfSize:FontSize_30];
    self.qingXiButton.tag = 1;
    [self.qingXiButton setTitle:@"原画" forState:UIControlStateNormal];
    [self.bottomShadowView addSubview:_qingXiButton];
    [self.qingXiButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(ws.bottomShadowView).offset(-10);
        make.centerY.equalTo(ws.bottomShadowView);
        make.height.mas_equalTo(30);
        make.width.mas_equalTo(60);
    }];
    self.qingXiButton.hidden = YES;
    self.qingXiButton.userInteractionEnabled = YES;
    [self.qingXiButton addTarget:self action:@selector(qingXiButtonClick) forControlEvents:UIControlEventTouchUpInside];
    /** 弹幕按钮 */
    _danMuButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_danMuButton setImage:[UIImage imageNamed:@"barrage_close"] forState:UIControlStateNormal];
    [_danMuButton addTarget:self action:@selector(hideDanMuBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    _danMuButton.tag = 2;
    [self.bottomShadowView addSubview:_danMuButton];
    _danMuButton.hidden = YES;
    [_danMuButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(ws.bottomShadowView).offset(IS_IPHONE_X ? -kScreenBottom/2 : 0);
        make.left.mas_equalTo(ws.bottomShadowView.mas_left).offset(10);
        make.width.height.mas_equalTo(44);
    }];
    
    _danMuSettingBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_danMuSettingBtn setImage:[UIImage imageNamed:@"barrage_setting"] forState:UIControlStateNormal];
    [_danMuSettingBtn addTarget:self action:@selector(danMuSettingBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomShadowView addSubview:_danMuSettingBtn];
    _danMuSettingBtn.hidden = YES;
    [_danMuSettingBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(ws.bottomShadowView).offset(IS_IPHONE_X ? -kScreenBottom/2 : 0);
        make.left.mas_equalTo(ws.danMuButton.mas_right).offset(10);
        make.width.height.mas_equalTo(44);
    }];
    [_danMuSettingBtn layoutSubviews];
    
    /** 横屏输入视图 */
    _contentView = [[UIView alloc] init];
    _contentView.userInteractionEnabled = YES;
    _contentView.backgroundColor = [UIColor colorWithHexString:@"#999999" alpha:0.2];
    _contentView.layer.cornerRadius = 4;
    [self.bottomShadowView addSubview:_contentView];
    _contentView.hidden = YES;
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(ws.danMuSettingBtn.mas_right).offset(10);
        make.centerY.mas_equalTo(ws.danMuButton);
        make.width.mas_equalTo(180);
        make.height.mas_equalTo(25);
    }];
    /** 输入视图提示文本 */
    UILabel *chatTipView = [[UILabel alloc]init];
    chatTipView.text = @"我也说两句~";
    chatTipView.textColor = [UIColor colorWithHexString:@"#FFFFFF" alpha:1];
    chatTipView.font = [UIFont systemFontOfSize:12];
    [_contentView addSubview:chatTipView];
    [chatTipView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(ws.contentView).offset(10);
        make.centerY.mas_equalTo(ws.contentView);
    }];
    /** 点击聊天按钮 */
    self.chatBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.chatBtn addTarget:self action:@selector(chatBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [_contentView addSubview:self.chatBtn];
    [self.chatBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(ws.contentView);
    }];
    /** 聊天视图 */
    self.chatBaseView = [[UIView alloc]init];
    self.chatBaseView.backgroundColor = [UIColor colorWithHexString:@"#919191" alpha:0.78];
    [self addSubview:self.chatBaseView];
    self.chatBaseView.hidden = YES;
    [self.chatBaseView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(ws.mas_bottom);
        make.left.right.mas_equalTo(ws.bottomShadowView);
        make.height.mas_equalTo(55);
    }];
    /** 输入背景视图 */
    UIView *inputBGView = [[UIView alloc]init];
    inputBGView.backgroundColor = [UIColor colorWithHexString:@"#FFFFFF" alpha:0.7];
    [self.chatBaseView addSubview:inputBGView];
    [inputBGView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(ws.chatBaseView).offset(10);
        make.right.mas_equalTo(ws.chatBaseView).offset(-10);
        make.height.mas_equalTo(40);
        make.centerY.mas_equalTo(ws.chatBaseView);
    }];
    inputBGView.layer.cornerRadius = 20;
    /** 输入视图 */
    self.inputView = [[CCChatContentView alloc]init];
    self.inputView.isFullScroll = YES;
    [self.chatBaseView addSubview:self.inputView];
    self.inputView.delegate = self;
    [_inputView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(ws.chatBaseView).offset(-7);
        make.left.mas_equalTo(ws.chatBaseView).offset(15);
        make.right.equalTo(ws.chatBaseView).offset(-15);
        make.height.mas_equalTo(40);
    }];
    /** 聊天回调 */
    self.inputView.sendMessageBlock = ^{
        [ws chatSendMessage];
    };
    /** 直播未开始 */
    self.liveUnStart = [[UIImageView alloc] init];
    self.liveUnStart.image = [UIImage imageNamed:@"live_streaming_unstart_bg"];
    [self addSubview:self.liveUnStart];
    //self.liveUnStart.frame = CGRectMake(0, 0, SCREEN_WIDTH, HDGetRealHeight);
    self.liveUnStart.hidden = YES;
    /** 直播未开始图片 */
    UIImageView * alarmClock = [[UIImageView alloc] init];
    alarmClock.image = [UIImage imageNamed:@"live_streaming_unstart"];
    [self.liveUnStart addSubview:alarmClock];
    [alarmClock mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(ws.liveUnStart);
        make.height.width.mas_equalTo(32);
        make.centerY.equalTo(ws.liveUnStart.mas_centerY).offset(-10);
    }];

    self.unStart = [[UILabel alloc] init];
    self.unStart.textColor = [UIColor whiteColor];
    self.unStart.alpha = 0.6f;
    self.unStart.textAlignment = NSTextAlignmentCenter;
    self.unStart.font = [UIFont systemFontOfSize:FontSize_30];
    self.unStart.text = PLAY_UNSTART;
    [self.liveUnStart addSubview:self.unStart];
    //self.unStart.frame = CGRectMake(SCREEN_WIDTH/2-50, 135.5, 100, 30);
    self.unStart1 = [[UILabel alloc] init];
    self.unStart1.textColor = [UIColor whiteColor];
    self.unStart1.alpha = 0.6f;
    self.unStart1.textAlignment = NSTextAlignmentCenter;
    self.unStart1.font = [UIFont systemFontOfSize:FontSize_30];
    [self.liveUnStart addSubview:self.unStart1];
    //self.unStart1.frame = CGRectMake(SCREEN_WIDTH/2-100, 160, 200, 30);
    
    [self.liveUnStart mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(ws);
    }];
    
    [self.unStart mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(alarmClock.mas_bottom).offset(10);
        make.left.mas_equalTo(ws.liveUnStart).offset(20);
        make.right.mas_equalTo(ws.liveUnStart).offset(-20);
        make.height.mas_equalTo(30);
    }];
    
    [self.unStart1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(ws.unStart.mas_bottom).offset(10);
        make.left.mas_equalTo(ws.liveUnStart).offset(20);
        make.right.mas_equalTo(ws.liveUnStart).offset(-20);
        make.height.mas_equalTo(30);
    }];

    /** 隐藏导航 */
    [self stopPlayerTimer];
    CCProxy *weakObject = [CCProxy proxyWithWeakObject:self];
    self.playerTimer = [NSTimer scheduledTimerWithTimeInterval:5.0f target:weakObject selector:@selector(LatencyHiding) userInfo:nil repeats:YES];
    /** 视频小窗 */
//    [self setSmallVideoView];
//    [self addSmallView];
    /** 初始化弹幕 */
    self.barrageView = [[CCBarrage alloc] initWithVideoView:self.hdContentView barrageStyle:NomalBarrageStyle ReferenceView:self];
    /** 根据模板类型显示 收起答题卡/随堂测按钮 */
    if (_templateType != 1) {
        [self addSubview:self.cleanTestBtn];
        self.cleanTestBtn.hidden = YES;
        [self.cleanTestBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(ws).offset(SCREEN_HEIGHT - 120 - kScreenBottom);
            make.left.mas_equalTo(ws).offset(SCREEN_WIDTH - 95);
            make.width.height.mas_equalTo(35);
        }];
        
        [self addSubview:self.cleanVoteBtn];
        self.cleanVoteBtn.hidden = YES;
        [self.cleanVoteBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(ws).offset(SCREEN_HEIGHT - 120 - kScreenBottom);
            make.left.mas_equalTo(ws).offset(SCREEN_WIDTH - 95);
            make.width.height.mas_equalTo(35);
        }];
    }
    /// 3.18.0 new 防录屏
    if ([self isCapture]) {
        [self screenCapture];
    }
}

// MARK: - RedPacketRain 红包雨
- (HDRedPacketRainConfiguration *)redPacketConfig {
    if (!_redPacketConfig) {
        _redPacketConfig = [[HDRedPacketRainConfiguration alloc]init];
    }
    return _redPacketConfig;
}

/// 开始红包雨
/// @param model 红包雨model
- (void)startRedPacketWithModel:(HDSRedPacketModel *)model {
    if (model) {
        
        NSString *redPacketId = [NSString stringWithFormat:@"%@",model.id];
        if ([redPacketId isEqualToString:self.lastEndRedPacketId]) return;
        
        _redPacketRainEngine = [HDRedPacketRainEngine shared];
        if (!self.redPacketBoardView) {
            self.redPacketBoardView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
            self.redPacketBoardView.backgroundColor = CCRGBAColor(0, 0, 0, 0.7);
            self.redPacketBoardView.tag = 1004;
            [APPDelegate.window addSubview:self.redPacketBoardView];
        }
        self.redPacketConfig.duration = model.duration;
        self.redPacketConfig.id = [NSString stringWithFormat:@"%@",model.id];
        self.redPacketConfig.startTime = model.startTime;
        self.redPacketConfig.currentTime = model.currentTime;
        self.redPacketConfig.slidingRate = model.slidingRate;
        BOOL isLandSpec = SCREEN_WIDTH > SCREEN_HEIGHT ? YES : NO;
        if (model.slidingRate == 0) {
            self.redPacketConfig.fallingTime = isLandSpec == YES ? 3.8/1.5 : 3.8;
        }else if (model.slidingRate == 1) {
            self.redPacketConfig.fallingTime = isLandSpec == YES ? 2.8/1.5 : 2.8;
        }else if (model.slidingRate == 2) {
            self.redPacketConfig.fallingTime = isLandSpec == YES ? 1.8/1.5 : 1.8;
        }
        self.redPacketConfig.redPacketImageName = @"redPacket";
        self.redPacketConfig.itemW = 120;
        self.redPacketConfig.itemH = 120;
        self.redPacketBoardView.hidden = NO;
        self.redPacketConfig.boardView = self.redPacketBoardView;
        self.redPacketConfig.isShowCountdownAnimation = (model.currentTime - model.startTime) > 3000 ? NO : YES;
        [self.redPacketRainEngine prepareRedPacketWithConfiguration:self.redPacketConfig tapRedPacketClosure:^(int index) {
            if (self.tapRedPacket) {
                self.tapRedPacket(self.redPacketConfig.id);
            }
        }endRedPacketClosure:^{
            self.redPacketBoardView.hidden = YES;
        }];
        [self.redPacketRainEngine startRedPacketRain];
    }
}

/// 结束红包雨
/// @param redPacketId 红包雨ID
- (void)endRedPacketWithRedPacketId:(NSString *)redPacketId {
    self.lastEndRedPacketId = [NSString stringWithFormat:@"%@",redPacketId];
    [self.redPacketRainEngine stopRedRacketRain];
}

/// 展示红包雨排名
/// @param model 红包雨排名Model
- (void)showRedPacketRankWithModel:(HDSRedPacketRankModel *)model {
    self.redPacketBoardView.hidden = NO;
    [self.redPacketRainEngine showRedPacketRainRank:model closeRankClosure:^{
        self.redPacketBoardView.hidden = YES;
    }];
}


//#ifdef LIANMAI_WEBRTC

- (NSMutableArray *)multiCallStreamArray {
    if (!_multiCallStreamArray) {
        _multiCallStreamArray = [NSMutableArray array];
    }
    return _multiCallStreamArray;
}

- (void)setIsRTCLive:(BOOL)isRTCLive {
    _isRTCLive = isRTCLive;
    if (_isRTCLive) {
        self.moreBtn.hidden = YES;
        [self updateMoreBtnConstraints:YES];
    }
}

/// 更新多人连麦流数据
/// @param streamModel 流数据
- (int)updateMultiMediaCallInfo:(HDSMultiMediaCallStreamModel *)streamModel {
    BOOL isHave = NO;
    NSMutableArray *tempArray = [self.multiCallStreamArray mutableCopy];
    for (int i = 0; i < tempArray.count; i++) {
        HDSMultiMediaCallStreamModel *oneModel = tempArray[i];
        if ([oneModel.userId isEqualToString:streamModel.userId]) {
            if (streamModel.type == kNeedUpateTypeVideo) {
                oneModel.isVideoEnable = streamModel.isVideoEnable;
            }else if (streamModel.type == kNeedUpateTypeAudio) {
                oneModel.isAudioEnable = streamModel.isAudioEnable;
            }
            isHave = YES;
            [self.multiCallStreamArray replaceObjectAtIndex:i withObject:oneModel];
            break;
        }
    }
    if (!isHave && streamModel.nickName.length > 0 && streamModel.streamView != nil) {
        [self.multiCallStreamArray addObject:streamModel];
    }
    [self setupDatasouce:[self.multiCallStreamArray copy]];
    return (int)self.multiCallStreamArray.count;
}

// MARK: - setIsNeedShowMultiBoardView
- (void)setIsMultiMediaShowStreamView:(BOOL)isMultiMediaShowStreamView {
    _isMultiMediaShowStreamView = isMultiMediaShowStreamView;
    [self updateMultiBoardViewFrame];
}

- (void)updateMultiBoardViewFrame {
    if (!_isMultiMediaCallRoom) return;
    if (!_screenLandScape) {
        CGFloat height = _isMultiMediaShowStreamView == YES ? 70 : 0;
        [_multiCallBoardView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.bottom.right.mas_equalTo(self);
            make.height.mas_equalTo(height);
        }];
        //[_multiCallBoardView layoutIfNeeded];
        [_hdContentView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(self.frame.size.width);
            make.height.mas_equalTo(HDGetRealHeight);
        }];
        [_hdContentView layoutIfNeeded];
    }else {
        CGFloat height = _isMultiMediaShowStreamView == YES ? 189.5 : 0;
        [_multiCallBoardView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.right.bottom.mas_equalTo(self);
            make.width.mas_equalTo(height);
        }];
        //[_multiCallBoardView layoutIfNeeded];
        
        [_hdContentView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(self.frame.size.width - height);
            make.height.mas_equalTo(self.frame.size.height);
        }];
        [_hdContentView layoutIfNeeded];
    }
}

- (void)setupDatasouce:(NSArray *)dataArray {
    if (_multiCallBoardView) {
        [_multiCallBoardView setDataSource:dataArray isLandscape:_screenLandScape];
    }
}

/// 移除流视图
/// @param stModel 流信息
/// @param isKillAll 是否移除所有
- (int)removeRemoteView:(HDSMultiMediaCallStreamModel * _Nullable)stModel isKillAll:(BOOL)isKillAll {
    if (isKillAll) {
        [self.multiCallStreamArray removeAllObjects];
    }else {
        HDSMultiMediaCallStreamModel *tempModel = nil;
        for (HDSMultiMediaCallStreamModel *oneModel in self.multiCallStreamArray.reverseObjectEnumerator) {
            if ([oneModel.userId isEqualToString:stModel.userId]) {
                tempModel = oneModel;
                break;
            }
        }
        if (tempModel != nil) {
            [self.multiCallStreamArray removeObject:tempModel];
        }
    }
    if (self.multiCallStreamArray.count == 0) {
        
        [self setIsMultiMediaShowStreamView:NO];
        [_multiCallBoardView removeRemoteView:nil isKillAll:YES];
    }else {
    
        [_multiCallBoardView removeRemoteView:stModel isKillAll:isKillAll];
    }
    return (int)self.multiCallStreamArray.count;
}

//#endif

#pragma mark - 导航栏功能
/**
 *  @brief  隐藏导航,用定时器控制,键盘弹出和隐藏的时候修改self.shouldHidden的值来控制是否隐藏
 */
- (void)LatencyHiding {
    [self showOrHiddenShadowView];
    [self stopPlayerTimer];
}
/**
 *  @brief  隐藏导航
 */
- (void)showOrHiddenShadowView {
    if (_isShowToolView == YES) {
        [self stopPlayerTimer];
        self.bottomShadowView.hidden = YES;
        self.topShadowView.hidden = YES;
        return;
    };
    /** 编辑状态时,先退出编辑状态 */
    if (_keyboardShow != YES) {
        if (_isShowShadowView == NO) {
            [self bringSubviewToFront:self.topShadowView];
            [self bringSubviewToFront:self.bottomShadowView];
            self.bottomShadowView.hidden = NO;
            self.topShadowView.hidden = NO;
            [self.topShadowView becomeFirstResponder];
        } else {
            self.bottomShadowView.hidden = YES;
            self.topShadowView.hidden = YES;
            [self.topShadowView resignFirstResponder];
        }
    }
}

#pragma mark - 功能按钮点击事件
/**
 *    @brief    聊天按钮点击事件
 */
- (void)chatBtnClick:(UIButton *)sender {
    [self.inputView.textView becomeFirstResponder];
}
/**
 *    @brief    更多按钮点击事件
 */
- (void)moreBtnClick:(UIButton *)sender {
    if (_endNormal) {
        // 直播未开始不能点击
        return;
    }
    if (self.touchupEvent) {
        self.touchupEvent();
    }
    if (self.lineArray.count == 0) {
        if (self.publicTipBlock) {
            self.publicTipBlock(@"当前模式不支持该功能");
        }
        return;
    }
    // 连麦中不支持
    if (_isWebRTCConnecting) {
        if (self.publicTipBlock) {
            self.publicTipBlock(@"连麦中，该功能不可用");
        }
        return;
    }
    if (_isShowToolView == NO) {
        if (_screenLandScape == YES) {
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
        BOOL isRate = NO;
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
        //NSLog(@"---切换----视频线路:%zd",model.index);
        
        self.isSound = NO;
        if (self.isMutableQuality) {
            self.qingXiButton.hidden = NO;
        }
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
        //NSLog(@"---切换----音频线路:%zd",model.index);
        self.qingXiButton.hidden = YES;
        self.isSound = YES;
        
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
        
    }else if (model.func == HDPlayerBaseBarrage) {
        
        newModel.func = model.func;
        newModel.desc = model.value;
        newModel.index = model.index;
        [self.barrageSelectedArray replaceObjectAtIndex:0 withObject:newModel];
        _barrageStatus = model.index == 0 ? 2 : 0;
        [self updataBarrageStatus];
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
            [self.qingXiButton setTitle:qualityStr forState:UIControlStateNormal];
        }
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
        
        CGFloat w = 210;
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
    [self initBaseToolView];
    [UIView animateWithDuration:0.35 animations:^{
        CGFloat w = 210;
        CGFloat h = SCREEN_HEIGHT;
        CGFloat x = SCREEN_WIDTH - w;
        CGFloat y = 0;
        ws.baseToolView.frame = CGRectMake(x, y, w, h);
        if (type == 2) {
            HDPlayerBaseModel *model = [ws.qualitySelectedArray firstObject];
            [ws.baseToolView showInformationWithType:HDPlayerBaseToolViewTypeQuality infos:ws.secRoadArr defaultData:model];
        }else if (type == 3) {
            HDPlayerBaseModel *model = [ws.barrageSelectedArray firstObject];
            [ws.baseToolView showInformationWithType:HDPlayerBaseToolViewTypeBarrage infos:@[] defaultData:model];
        }else if (type == 0) {
            HDPlayerBaseModel *model = [ws.lineSelectedArray firstObject];
            [ws.baseToolView showInformationWithType:HDPlayerBaseToolViewTypeLine infos:ws.lineArray defaultData:model];
        }
    } completion:^(BOOL finished) {
        ws.isShowToolView = YES;
        ws.isShowShadowView = YES;
        [ws showOrHiddenShadowView];
    }];
    
    self.baseView.touchBegin = ^(NSString * _Nonnull string) {
        [ws hiddenToolView];
    };
    self.baseToolView.switchAudio = ^(BOOL result) {
        ws.isOnlyChangePlayMode = YES;
        ws.isSound = result;
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
        CGFloat w = 210;
        CGFloat h = SCREEN_HEIGHT;
        CGFloat x = SCREEN_WIDTH;
        CGFloat y = 0;
        ws.baseToolView.frame = CGRectMake(x,y,w,h);
    } completion:^(BOOL finished) {
        ws.baseToolView.hidden = YES;
        ws.isShowToolView = NO;
        ws.isShowShadowView = NO;
        [ws showOrHiddenShadowView];
    }];
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

- (NSMutableArray *)barrageSelectedArray {
    if (!_barrageSelectedArray) {
        _barrageSelectedArray = [NSMutableArray array];
    }
    return _barrageSelectedArray;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (_isShowToolView == YES) {
        [self hiddenToolView];
        _isShowToolView = NO;
    }
}
#pragma mark - 随堂测&答题卡收起按钮
/**
 *    @brief    更新随测试隐藏按钮布局(横屏)
 *    @param    completion  更新回调
 */
- (void)updateTestWithLandScapeWithCompletion:(void (^)(BOOL))completion
{
    if (self.showCleanTestBtn != YES) {
        self.cleanTestBtn.hidden = YES;
        return;
    }
    WS(ws)
    if (_cleanVoteBtn.hidden == YES) {
        [self.cleanTestBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(ws).offset(IS_IPHONE_X ? - 110 : -75);
            make.right.mas_equalTo(ws).offset(IS_IPHONE_X ? -55 : -15);
            make.width.height.mas_equalTo(35);
        }];
    }else {

        [self.cleanTestBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(ws).offset(IS_IPHONE_X ? - 110 : -75);
            make.right.mas_equalTo(ws).offset(IS_IPHONE_X ? -95 : -55);
            make.width.height.mas_equalTo(35);
        }];
    }
    if (completion != nil) {
        completion(YES);
    }
}
/**
 *    @brief    更新答题卡隐藏按钮布局(横屏)
 *    @param    completion  更新回调
 */
- (void)updateVoteWithLandScapeWithCompletion:(void (^)(BOOL))completion
{
    if (self.showCleanVoteBtn != YES) {
        self.cleanVoteBtn.hidden = YES;
        return;
    }
    WS(ws)
    if (_cleanTestBtn.hidden == YES) {
        [self.cleanVoteBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(ws).offset(IS_IPHONE_X ? - 110 : -75);
            make.right.mas_equalTo(ws).offset(IS_IPHONE_X ? -55 : -15);
            make.width.height.mas_equalTo(35);
        }];
    }else {
        [self.cleanVoteBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(ws).offset(IS_IPHONE_X ? - 110 : -75);
            make.right.mas_equalTo(ws).offset(IS_IPHONE_X ? -95 : -55);
            make.width.height.mas_equalTo(35);
        }];
    }
    if (completion != nil) {
        completion(YES);
    }
}
/**
 *    @brief    答题卡状态更改
 */
- (void)voteUPWithStatus:(BOOL)status {
    self.showCleanVoteBtn = !status;
    if (_screenLandScape == YES && self.showCleanVoteBtn == YES) {
        self.cleanVoteBtn.hidden = NO;
        [self bringSubviewToFront:_cleanVoteBtn];
        [self updateVoteWithLandScapeWithCompletion:^(BOOL result) {
            
        }];
    }else {
        self.cleanVoteBtn.hidden = YES;
    }
}
/**
 *    @brief    随堂测状态更改
 */
- (void)testUPWithStatus:(BOOL)status {
    self.showCleanTestBtn = !status;
    if (_screenLandScape == YES && self.showCleanTestBtn == YES) {
        self.cleanTestBtn.hidden = NO;
        [self bringSubviewToFront:_cleanTestBtn];
        [self updateTestWithLandScapeWithCompletion:^(BOOL result) {
            
        }];
    }else {
        self.cleanTestBtn.hidden = YES;
    }
}

// MARK: - update
/// 更新直播间在线人数
/// @param userCount 在线人数
- (void)updateRoomUserCount:(NSString *)userCount {
    CGFloat width = userCount.length * 9;
    if (width < 9) {
        width = 9;
    }
    if (width > 45) {
        width = 45;
    }
    CGFloat rightOffset = -10;
    if (self.moreBtn.hidden == NO) {
        rightOffset = -54;
    }
    _userCountLabel.text = [NSString stringWithFormat:@"%@",userCount];
    [_userCountLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(width);
    }];
    [_userCountLabel layoutIfNeeded];
}

/// 更新更多按钮约束
/// @param isHidden 是否隐藏
- (void)updateMoreBtnConstraints:(BOOL)isHidden {
    CGFloat offset = -10;
    if (IS_IPHONE_X) {
        offset = _screenLandScape == YES ? -54 : -10;
    }
    if (isHidden) {
        __weak typeof(self) weakSelf = self;
        [_moreBtn mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(0);
            make.right.mas_equalTo(weakSelf.topShadowView).offset(offset);
        }];
    } else {
        __weak typeof(self) weakSelf = self;
        [_moreBtn mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(35);
            make.right.mas_equalTo(weakSelf.topShadowView).offset(offset);
        }];
    }
}

#pragma mark - 横竖屏切换
/**
 *    @brief    横竖屏切换
 *    @param    screenLandScape 横竖屏
 */
- (void)layouUI:(BOOL)screenLandScape {
    _screenLandScape = screenLandScape;
    WS(ws)
    if (self.redPacketBoardView) {
        self.redPacketBoardView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    }
    
    if (self.moreBtn.hidden == NO && _isRTCLive == NO) {
        [self updateMoreBtnConstraints:NO];
    } else {
        [self updateMoreBtnConstraints:YES];
    }
    
    if (screenLandScape == YES) {
        /*  实现横屏状态下切换线路功能，将self.qingXiButton.hidden 设置为NO */
        if (self.isMutableQuality) {
            self.qingXiButton.hidden = self.isSound == YES ? YES : NO;
        }else {
            self.qingXiButton.hidden = YES;
        }
        
        self.danMuButton.hidden = _isChatView == YES ? NO : YES;
        self.quanpingButton.hidden = YES;
        self.changeButton.hidden = _isOnlyVideoMode == YES ? YES : NO;
        if (self.showCleanVoteBtn == YES) {
            self.cleanVoteBtn.hidden = NO;
            [self bringSubviewToFront:self.cleanVoteBtn];
        }
        if (self.showCleanTestBtn == YES) {
            self.cleanTestBtn.hidden = NO;
            [self bringSubviewToFront:_cleanTestBtn];
        }
        CGFloat offset = IS_IPHONE_X ? 44 : 0;
        /// 3.18.0 new
        CGFloat hdContentViewW = SCREEN_WIDTH;
        //#ifdef LIANMAI_WEBRTC
        if (_isMultiMediaCallRoom && _isMultiAudioVideo && _isMultiMediaShowStreamView) {
            hdContentViewW = SCREEN_WIDTH - 189.5;
            [self updateMultiBoardViewFrame];
            [self setupDatasouce:[_multiCallStreamArray copy]];
        }
        //#endif
        [_hdContentView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(hdContentViewW);
            make.height.mas_equalTo(ws.frame.size.height);
        }];
        [_hdContentView layoutIfNeeded];
        
        [self.bottomShadowView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(64);
        }];
        if (self.changeButton.hidden != YES) {
//            [self.changeButton mas_remakeConstraints:^(MASConstraintMaker *make) {
//                make.right.mas_equalTo(ws.bottomShadowView.mas_right).offset(-(10+offset));
//                make.centerY.mas_equalTo(ws.bottomShadowView);
//            }];
        }

        if (_isOnlyVideoMode == YES && self.qingXiButton.hidden != YES) {
            [self.qingXiButton mas_updateConstraints:^(MASConstraintMaker *make) {
                make.right.mas_equalTo(self.bottomShadowView.mas_right).offset(-(10+offset));
            }];
        }
        /** 更新弹幕状态 */
        [self updataBarrageStatus];
        
        [self.backButton mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(ws.topShadowView.mas_left).offset(offset);
        }];
        [self.backButton layoutIfNeeded];
        
        [self.danMuButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(ws.bottomShadowView.mas_left).offset(offset+10);
            make.centerY.mas_equalTo(ws.bottomShadowView);
        }];
        [self.danMuButton layoutIfNeeded];
        
        [self.danMuSettingBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(ws.danMuButton.mas_right).offset(10);
            make.centerY.mas_equalTo(ws.bottomShadowView);
        }];
        
        [self layoutIfNeeded];
        self.liveUnStart.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
        self.unStart.frame = CGRectMake(20, 190, SCREEN_WIDTH - 40, 30);
        self.unStart1.frame = CGRectMake(20, 210, SCREEN_WIDTH - 40, 30);
    } else {
        self.isShowToolView = NO;
        self.cleanVoteBtn.hidden = YES;
        self.cleanTestBtn.hidden = YES;
        self.qingXiButton.hidden = YES;
        self.changeButton.hidden = _isOnlyVideoMode == YES ? YES : NO;
        if (_endNormal == NO) {
            self.quanpingButton.hidden = NO;
        }else {
            self.changeButton.hidden = YES;
        }
        self.danMuButton.hidden = YES;
        self.danMuSettingBtn.hidden = YES;
        self.contentView.hidden = YES;
        /// 3.18.0 new
        //#ifdef LIANMAI_WEBRTC
        if (_isMultiMediaCallRoom && _isMultiAudioVideo && _isMultiMediaShowStreamView) {
            [self updateMultiBoardViewFrame];
            [self setupDatasouce:[_multiCallStreamArray copy]];
        }
        //#endif
        [_hdContentView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(SCREEN_WIDTH);
            make.height.mas_equalTo(HDGetRealHeight);
        }];
        [_hdContentView layoutIfNeeded];
        
        [self.bottomShadowView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(44);
        }];
        [self.bottomShadowView layoutIfNeeded]; //:横屏隐藏按钮不显示bug修复
        
        if (self.changeButton.hidden != YES) {
//            [self.changeButton mas_remakeConstraints:^(MASConstraintMaker *make) {
//                make.right.mas_equalTo(ws.quanpingButton.mas_left).offset(-10);
//                make.centerY.mas_equalTo(ws.quanpingButton);
//            }];
//            [self.changeButton layoutIfNeeded];
        }
        
        /*  关闭弹幕  */
        [self.barrageView barrageClose];
        
        [self.backButton mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(ws.topShadowView.mas_left);
        }];
        [self.backButton layoutIfNeeded];
        
        [self layoutIfNeeded];
        
        self.liveUnStart.frame = CGRectMake(0, 0, SCREEN_WIDTH, HDGetRealHeight);
        self.unStart.frame = CGRectMake(20, 135.5, SCREEN_WIDTH - 40, 30);
        self.unStart1.frame = CGRectMake(20, 160, SCREEN_WIDTH - 40, 30);
    }
}

- (void)setIsVideoMainScreen:(BOOL)isVideoMainScreen {
    _isVideoMainScreen = isVideoMainScreen;
    self.changeButton.tag = _isVideoMainScreen == YES ? 1 : 2;
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
 *    The New Method (3.14.0)
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
    /** 清晰度列表 */
    self.qualityMetaData = [dict copy];
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
    [self.qingXiButton setTitle:qualityModel.desc forState:UIControlStateNormal];
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
#pragma mark - 切换线路相关
/**
 *    @brief    点击清晰度
 */
- (void)qingXiButtonClick {
    /// 连麦中，不支持
    if (_isWebRTCConnecting) {
        if (self.publicTipBlock) {
            self.publicTipBlock(@"多人连麦模式，不支持切换清晰度");
        }
        return;
    }
    if (_isShowToolView == NO) {
        [self showToolViewWithType:2];
    }
}

#pragma mark - 私有方法
//发送公聊信息
-(void)chatSendMessage{
    NSString *str = _inputView.plainText;
    if(str == nil || str.length == 0) {
        return;
    }
    // 发送公聊信息
//    self.sendChatMessage(str);
    _inputView.textView.text = nil;
    [_inputView.textView resignFirstResponder];
}

#pragma mark - inputView deleaget输入键盘的代理
- (void)setIsChatActionKeyboard:(BOOL)isChatActionKeyboard {
    _isChatActionKeyboard = isChatActionKeyboard;
}

//键盘将要出现
-(void)keyBoardWillShow:(CGFloat)height endEditIng:(BOOL)endEditIng{

    //键盘弹出 隐藏shadowView
//    [self showOrHiddenShadowView];
    self.keyboardShow = YES;
    //防止图片和键盘弹起冲突
    if (endEditIng == YES) {
        [self endEditing:YES];
        return;
    }
    WS(ws)
    // 横屏聊天更改输入框位置
    if (_screenLandScape == YES && _isChatActionKeyboard == YES) {
        NSInteger selfHeight = self.frame.size.height - height;
        NSInteger contentHeight = selfHeight>55?(-height):(55-self.frame.size.height);
        _chatBaseView.tag = 100;
        _chatBaseView.hidden = NO;
        [[UIApplication sharedApplication].keyWindow addSubview:self.chatBaseView];
        CGFloat offset = IS_IPHONE_X ? 44 : 0;
        [self.chatBaseView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(ws.bottomShadowView).offset(offset);
            make.height.mas_equalTo(55);
            make.right.mas_equalTo(ws.bottomShadowView).offset(-offset);
            make.bottom.mas_equalTo(ws.mas_bottom).offset(contentHeight);
        }];
    }
}
//隐藏键盘
-(void)hiddenKeyBoard{

    self.keyboardShow = NO;
    // 横屏聊天时更改输入框位置
//    if (_screenLandScape == YES && _isChatActionKeyboard == YES) {
    if (_isChatActionKeyboard == YES) {
        [self endEditing:YES];
        [[[UIApplication sharedApplication].keyWindow viewWithTag:100] removeFromSuperview];
        [self addSubview:self.chatBaseView];
        CGFloat offset = IS_IPHONE_X ? 44 : 0;
        [self.chatBaseView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.mas_bottom);
            make.left.mas_equalTo(self.bottomShadowView).offset(offset);
            make.height.mas_equalTo(50);
            make.right.mas_equalTo(self.bottomShadowView).offset(-offset);
        }];
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

#pragma mark - 新增的共有点击事件方法
/**
 *    @brief    点击全屏按钮
 */
-(void)quanpingBtnClick{
    //全屏按钮代理
    _screenLandScape = YES;
    [self.delegate quanpingButtonClick:_changeButton.tag];
    
//    CGRect frame = [UIScreen mainScreen].bounds;
    self.backButton.tag = 2;
    [UIApplication sharedApplication].statusBarHidden = YES;
    UIView *view = [self superview];
    [self mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(view);
        make.height.mas_equalTo(SCREEN_HEIGHT);
    }];
    [self layoutIfNeeded];//
    //#ifdef LIANMAI_WEBRTC
    //如果正在连麦，更改连麦视图大小,并且设置连麦窗口
    if(_remoteView) {
        //判断当前是否是正在申请连麦
        BOOL connecting = !_lianMaiView.cancelLianmainBtn.hidden;
        if (connecting) {//如果当前是正在申请连麦
            [_remoteView removeFromSuperview];
            _remoteView = nil;
        }else{
            [_remoteView removeFromSuperview];
            if (_changeButton.tag == 2) {
                [self.smallVideoView addSubview:self.remoteView];
                self.remoteView.frame = [self calculateRemoteVIdeoRect:CGRectMake(0, 0, self.smallVideoView.frame.size.width, self.smallVideoView.frame.size.height)];
            }else{
                [self.hdContentView addSubview:self.remoteView];
                self.remoteView.frame = [self calculateRemoteVIdeoRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
            }
            [self bringSubviewToFront:self.topShadowView];
            [self bringSubviewToFront:self.bottomShadowView];
            // 设置远程连麦窗口的大小，连麦成功后调用才生效，连麦不成功调用不生效
            self.setRemoteView(self.remoteView.frame);
        }
    }
    //#endif
    
    //隐藏其他视图
    [self layouUI:YES];
    //smallVideoView
    if (_isSmallDocView) {
        // 1.更换小窗横屏位置
        CGFloat y = CGRectGetMaxY(self.topShadowView.frame);
        [self.smallVideoView setFrame:CGRectMake((IS_IPHONE_X ? 44:0), y, 100, 75)];
    }
    
    //#ifdef LIANMAI_WEBRTC
    //隐藏连麦
    if (_lianMaiView) {
        _lianMaiView.hidden = YES;
    }
    //#endif
}

/**
 *    @brief    结束直播和退出全屏
 *    @param    sender 点击按钮
 */
- (void)backBtnClick:(UIButton *)sender {
    _screenLandScape = NO;
    self.backButton.userInteractionEnabled = NO;
    [self endEditing:YES];
    //#ifdef LIANMAI_WEBRTC
    //连麦视图显示
    if (_lianMaiView && _menuView.menuBtn.selected == YES && _menuView.lianmaiBtn.selected == YES) {
        _lianMaiView.hidden = NO;
    }
    //#endif
    //返回按钮代理
    [self.delegate backButtonClick:sender changeBtnTag:_changeButton.tag];
    if (sender.tag == 2) {
        // 返回按钮在进入全屏的情况下 tag 被设置为 2
        sender.tag = 1;
        [self backBtnClickWithTag:_changeButton.tag];
        self.inputView.textView.text = nil;
        [self.inputView.textView resignFirstResponder];
    }
}

/**
 *    @brief    返回按钮事件处理
 *    @param    tag 按钮的tag
 */
- (void)backBtnClickWithTag:(NSInteger)tag
{
    if (tag == 2) {
        UIButton *button = [[UIButton alloc]init];
        button.tag = 2;
        [self.delegate backButtonClick:button changeBtnTag:_changeButton.tag];
        self.backButton.tag = 1;
    }
    [UIApplication sharedApplication].statusBarHidden = NO;
    self.selectedIndexView.hidden = YES;
    self.contentView.hidden = YES;
    UIView *view = [self superview];
    
    CGFloat selfH = HDGetRealHeight;
    //#ifdef LIANMAI_WEBRTC
    // todo:返回按钮更新布局 需要根据是否是视频连麦计算高度
    if (_isMultiMediaCallRoom && _isMultiAudioVideo && _isMultiMediaShowStreamView) {
        selfH = selfH + 70;
    }
    //#endif
    [self mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(view);
        make.height.mas_equalTo(HDGetRealHeight);
        make.top.equalTo(view).offset(SCREEN_STATUS);
    }];
    [self layoutIfNeeded];
    //#ifdef LIANMAI_WEBRTC
        if(_remoteView) {//设置竖屏状态下连麦窗口
            [_remoteView removeFromSuperview];
            if (_changeButton.tag == 2) {//如果是视频小窗
                [self.smallVideoView addSubview:self.remoteView];
                self.remoteView.frame = [self calculateRemoteVIdeoRect:CGRectMake(0, 0, self.smallVideoView.frame.size.width, self.smallVideoView.frame.size.height)];
            }else{
                [self.hdContentView addSubview:self.remoteView];
                self.remoteView.frame = [self calculateRemoteVIdeoRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
            }
            [self bringSubviewToFront:self.topShadowView];
            [self bringSubviewToFront:self.bottomShadowView];
            // 设置远程连麦窗口的大小，连麦成功后调用才生效，连麦不成功调用不生效
            self.setRemoteView(self.remoteView.frame);
        }
    //#endif
    if (_isSmallDocView) {
        /// 4.5.1 new
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.smallVideoView setFrame:CGRectMake(self.frame.size.width -110, HDGetRealHeight+41+(IS_IPHONE_X? 44:20), 100, 75)];
        });
    }
    [self layouUI:NO];
    //#ifdef LIANMAI_WEBRTC
    //连麦视图显示
//    if (_lianMaiView) {
//        _lianMaiView.hidden = NO;
//    }
    //#endif
}

/**
 切换视频和文档
 
 @param sender 切换
 */
-(void)changeBtnClick:(UIButton *)sender{
    [self endEditing:YES];
    if (_smallVideoView.hidden && !_changeButton.hidden && _isSmallDocView) {
        NSString *title = _changeButton.tag == 1 ? PLAY_CHANGEDOC : PLAY_CHANGEVIDEO;
        UIImage *image = _changeButton.tag == 1 ? PLAY_CHANGEDOC_IMAGE : PLAY_CHANGEVIDEO_IMAGE;
        self.isSmallVideoView = [title isEqualToString:PLAY_CHANGEVIDEO] ? YES : NO;
//        [_changeButton setTitle:title forState:UIControlStateNormal];
        [_changeButton setImage:image forState:UIControlStateNormal];
        _smallVideoView.hidden = NO;
        return;
    }
    if (sender.tag == 1) {//切换文档大屏
        sender.tag = 2;
//        [sender setTitle:PLAY_CHANGEVIDEO forState:UIControlStateNormal];
        [sender setImage:PLAY_CHANGEVIDEO_IMAGE forState:UIControlStateNormal];
        self.isSmallVideoView = YES;
        //切换视频时remote的视图大小
        //#ifdef LIANMAI_WEBRTC
        if(_remoteView) {//设置竖屏状态下连麦窗口
            // 防止没有移除
            [_remoteView removeFromSuperview];
            [self.smallVideoView addSubview:self.remoteView];
            self.remoteView.frame = [self calculateRemoteVIdeoRect:CGRectMake(0, 0, self.smallVideoView.frame.size.width, self.smallVideoView.frame.size.height)];
            // 设置远程连麦窗口的大小，连麦成功后调用才生效，连麦不成功调用不生效
            self.setRemoteView(self.remoteView.frame);
        }
        //#endif
    } else {//切换文档小屏
        sender.tag = 1;
//        [sender setTitle:PLAY_CHANGEDOC forState:UIControlStateNormal];
        [sender setImage:PLAY_CHANGEDOC_IMAGE forState:UIControlStateNormal];
        self.isSmallVideoView = NO;
        //#ifdef LIANMAI_WEBRTC
        if(_remoteView) {//设置竖屏状态下连麦窗口
            [_remoteView removeFromSuperview];
            [self.hdContentView addSubview:self.remoteView];
            self.remoteView.frame = [self calculateRemoteVIdeoRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
            // 设置远程连麦窗口的大小，连麦成功后调用才生效，连麦不成功调用不生效
            self.setRemoteView(self.remoteView.frame);
        }
        //#endif
    }
    if (self.delegate) {//changeBtn按钮点击代理
        [self.delegate changeBtnClicked:sender.tag];
    }
}
/**
 *    @brief    更新UI层级
 */
- (void)updateUITier {
    [self bringSubviewToFront:self.topShadowView];
    [self bringSubviewToFront:self.bottomShadowView];
}

#pragma mark - 懒加载
/**
 *    @brief    收起状态下 随堂测按钮
 */
- (UIButton *)cleanTestBtn
{
    if (!_cleanTestBtn) {
        _cleanTestBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cleanTestBtn setImage:[UIImage imageNamed:@"clean_testView"] forState:UIControlStateNormal];
        _cleanTestBtn.hidden = YES;
        [_cleanTestBtn addTarget:self action:@selector(cleanTestBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cleanTestBtn;
}
/**
 *    @brief    收起状态下随堂测按钮点击事件
 */
- (void)cleanTestBtnClick
{
    self.cleanTestBtn.hidden = YES;
    if (self.cleanVoteAndTestBlock) {
        self.cleanVoteAndTestBlock(0);
    }
}
/**
 *    @brief    收起状态下 答题卡按钮
 */
- (UIButton *)cleanVoteBtn
{
    if (!_cleanVoteBtn) {
        _cleanVoteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cleanVoteBtn setImage:[UIImage imageNamed:@"clean_voteView"] forState:UIControlStateNormal];
        _cleanVoteBtn.hidden = YES;
        [_cleanVoteBtn addTarget:self action:@selector(cleanVoteBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cleanVoteBtn;
}
/**
 *    @brief    收起状态下随堂测按钮点击事件
 */
- (void)cleanVoteBtnClick
{
    self.cleanVoteBtn.hidden = YES;
    if (self.cleanVoteAndTestBlock) {
        self.cleanVoteAndTestBlock(1);
    }
}

/**
 移除加载
 */
-(void)removeInformationViewPop {
    if (_informationViewPop) {
        [_informationViewPop removeFromSuperview];
        //    _informationViewPop = nil;
    }
}
// MARK: - 弹幕

- (void)danMuSettingBtnClick:(UIButton *)sender {
    if (_screenLandScape) {
        [self showToolViewWithType:3];
    }
}

/**
 *    @brief    更新弹幕状态
 */
- (void)updataBarrageStatus
{
    if (_endNormal == YES) return;
    
    if (self.barrageSelectedArray.count == 0) {
        HDPlayerBaseModel *model = [[HDPlayerBaseModel alloc]init];
        model.func = HDPlayerBaseToolViewTypeBarrage;
        model.desc = @"半屏";
        model.index = 2;
        model.value = model.desc;
        [self.barrageSelectedArray removeAllObjects];
        [self.barrageSelectedArray addObject:model];
    }
    [self.barrageView barrageClose];
    NSString *barrageImageName = @"barrage_close";
    self.contentView.hidden = YES;
    if (_barrageStatus == 2) { //全屏
        self.contentView.hidden = NO;
        _danMuButton.tag = 1;
        barrageImageName = @"barrage_open";
        _danMuSettingBtn.hidden = NO;
        if (_screenLandScape) {
            [self.barrageView barrageOpen];
            [self.barrageView changeRenderViewStyle:RenderViewFullScreen];
        }
    }else if(_barrageStatus == 0) {
        
        barrageImageName = @"barrage_open";
        self.contentView.hidden = NO;
        _danMuSettingBtn.hidden = NO;
        if (_screenLandScape) {
            [self.barrageView barrageOpen];
            [self.barrageView changeRenderViewStyle:RenderViewCenter];
        }
    }
    [_danMuButton setImage:[UIImage imageNamed:barrageImageName] forState:UIControlStateNormal];
}

/**
 弹幕开关
 */
-(void)hideDanMuBtnClicked {
    if (_danMuButton.tag == 1){//关闭弹幕
        self.contentView.hidden = YES;
        _barrageStatus = 1;
        [_danMuButton setImage:[UIImage imageNamed:@"barrage_close"] forState:UIControlStateNormal];
        _danMuButton.tag = 2;
        _danMuSettingBtn.hidden = YES;
        [self.barrageView barrageClose];
    }else if (_danMuButton.tag == 2){//开启全屏弹幕
        self.contentView.hidden = NO;
        _barrageStatus = 2;
        [_danMuButton setImage:[UIImage imageNamed:@"barrage_open"] forState:UIControlStateNormal];
        _danMuButton.tag = 1;
        _danMuSettingBtn.hidden = NO;
        [self.barrageView barrageOpen];
        [self.barrageView changeRenderViewStyle:RenderViewFullScreen];
    }
}
// MARK: - hitTest
/**
 *    @brief    playerView 触摸事件 （直播文档模式，文档手势冲突）
 *    @param    point   触碰当前区域的点
 */
- (nullable UIView *)hitTest:(CGPoint)point withEvent:(nullable UIEvent *)event
{
    // 每次触摸事件 此方法会进行两次回调，_showShadowCountFlag 标记第二次回调处理事件
    _showShadowCountFlag++;
    CGFloat selfH = self.frame.size.height;
    if (point.y > 0 && point.y <= self.topShadowView.size.height) { //过滤掉顶部shadowView
        if (_showShadowCountFlag == 2) {
            _showShadowCountFlag = 0;
        }
        return [super hitTest:point withEvent:event];
    }else if (point.y >= selfH - self.bottomShadowView.size.height && point.y <= selfH) { ////过滤掉底部shadowView
        if (_showShadowCountFlag == 2) {
            _showShadowCountFlag = 0;
        }
        return [super  hitTest:point withEvent:event];
    }else if (point.y <= selfH / 2 + 40 && point.y >= selfH / 2 && point.x <= SCREEN_WIDTH / 2 + 20 && point.x >= SCREEN_WIDTH / 2 - 20) {
        if (_showShadowCountFlag == 2) {
            _showShadowCountFlag = 0;
        }
        UIButton *playErrorBtn = (UIButton *)[self viewWithTag:1000];
        return playErrorBtn;
    }
    //#ifdef LIANMAI_WEBRTC
    /// 多人音视频连麦 横屏stream 视图区域过滤
    else if (point.x > self.width - 189.5 && _isMultiMediaCallRoom && _isMultiAudioVideo && _isMultiMediaShowStreamView && _screenLandScape) {
        if (_showShadowCountFlag == 2) {
            _showShadowCountFlag = 0;
        }
        return [super hitTest:point withEvent:event];
    }
    //#endif
    else {
        if (_showShadowCountFlag == 2) {
            _isShowShadowView = _isShowShadowView == YES ? NO : YES;
            if (self.keyboardShow == YES && _screenLandScape == YES) {
                self.keyboardShow = NO;
            }else {
                [self showOrHiddenShadowView];
            }
            _showShadowCountFlag = 0;
            return [super hitTest:point withEvent:event];
        }
        return nil;
    }
}

/**
 *    @brief    弹幕
 *    @param    model 弹幕数据模型
 */
- (void)insertDanmuModel:(CCPublicChatModel *)model {
    if (_screenLandScape) {
        [self.barrageView insertBarrageMessage:model];
    }
}

- (void)timeoutWithStr:(NSString *)str {
    /// 这里加了判断，原因是新的接口返回值timeout与旧接口不一致
    NSTimeInterval interval;
    if (str.length >= 19) {
        
        NSString * strings = [str substringToIndex:19];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        //24小时制：yyyy-MM-dd HH:mm:ss  12小时制：yyyy-MM-dd hh:mm:ss
        dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        NSDate *tmp_date = [dateFormatter dateFromString:strings];
        interval = [tmp_date timeIntervalSince1970];
    } else {
        interval = (NSTimeInterval)str.integerValue;
    }
    
    NSTimeInterval interval1 = [[NSDate date] timeIntervalSince1970];
    __block int timeout = (int)interval - (int)interval1; //倒计时时
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
    dispatch_source_set_timer(_timer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0); //每秒执行
    dispatch_source_set_event_handler(_timer, ^{

        if(timeout==0){ //倒计时结束，关闭
            dispatch_source_cancel(_timer);
            dispatch_async(dispatch_get_main_queue(), ^{
                //设置界面的按钮显示 根据自己需求设置（倒计时结束后调用）
                //self.ShouMIdate.text =@"0天0时0分0秒";
                self.unStart1.text = @"即将开始";
            });
        }else if(timeout > 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                //设置界面的按钮显示 根据自己需求设置
                
                int second =timeout%60;//秒
                int minutes = timeout/60%60;//分钟的。
                int hour = timeout/60/60%24;//小时
                int day = timeout/60/60/24;//天
                day = day > 99 ? 99 : day;
                NSString *strTime = [NSString stringWithFormat:@"%d天%d小时%d分钟%d秒",day,hour,minutes,second ];
                //_ShouMIdate.text =strTime;
                self.unStart1.text = strTime;
            });
            timeout--;
        }
    });
    dispatch_resume(_timer);
}


-(void)dealloc {
    
    
    if (@available(iOS 11.0, *)) {
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:UIScreenCapturedDidChangeNotification
                                                      object:nil];
    }
    //#ifdef LIANMAI_WEBRTC
    //连麦视图显示
    if (_lianMaiView) {
        [self removeLianMaiView];
    }
    //#endif
    [self stopPlayerTimer];
}

//#endif

/**
 关闭播放计时器
 */
-(void)stopPlayerTimer {
    if([self.playerTimer isValid]) {
        [self.playerTimer invalidate];
        self.playerTimer = nil;
    }
}

#pragma mark - 小窗视图

/**
 设置小窗视图
 */
-(void)setSmallVideoView{
//    if (_isSmallDocView) {
//        if (_smallVideoView) {
//            [_smallVideoView removeFromSuperview];
//            _smallVideoView = nil;
//        }
//        _smallVideoView = [[CCDocView alloc] initWithType:_isSmallDocView];
//        _smallVideoView.tag = 1001;
//        __weak typeof(self)weakSelf = self;
//        _smallVideoView.hiddenSmallVideoBlock = ^{
//            [weakSelf hiddenSmallVideoview];
//        };
//    }
}
/**
 *    @brief    小窗添加
 */
- (void)addSmallView
{
    if (_isSmallDocView) {
        if (_smallVideoView) {
            [_smallVideoView removeFromSuperview];
            _smallVideoView = nil;
        }
        _smallVideoView = [[CCDocView alloc] initWithType:_isSmallDocView];
        _smallVideoView.screenCaptureSwitch = _screenCaptureSwitch;
        _smallVideoView.tag = 1001;
        __weak typeof(self)weakSelf = self;
        _smallVideoView.hiddenSmallVideoBlock = ^{
            [weakSelf hiddenSmallVideoview];
        };
        [APPDelegate.window addSubview:_smallVideoView];
    }
}
/**
 *    @brief    小窗隐藏
 */
-(void)hiddenSmallVideoview{
    self.smallVideoView.hidden = YES;
    UIImage *image = _changeButton.tag == 1 ? PLAY_SHOWDOC_IMAGE : PLAY_SHOWVIDEO_IMAGE;
    [_changeButton setImage:image forState:UIControlStateNormal];
    //[_changeButton setTitle:title forState:UIControlStateNormal];
}
#pragma mark - 直播状态相关代理
/**
 *    @brief  收到播放直播状态 0.正在直播 1.未开始直播
 */
- (void)getPlayStatue:(NSInteger)status{
    if(status == 1) {
        self.liveUnStart.hidden = NO;
        [self bringSubviewToFront:self.liveUnStart];
        self.smallVideoView.hidden = YES;
        self.changeButton.hidden = YES;
        self.unStart.text = PLAY_UNSTART;
        _endNormal = YES;
        self.quanpingButton.hidden = YES;
        self.moreBtn.hidden = YES;
        [self updateMoreBtnConstraints:YES];
    } else {
        _endNormal = NO;
        if (_isRTCLive == NO) {
            self.moreBtn.hidden = NO;
            [self updateMoreBtnConstraints:NO];
        }
        if (_isOnlyVideoMode) {
            self.changeButton.hidden = YES;
        } else {
            self.changeButton.hidden = NO;
        }
        if (_screenLandScape == NO) {
            self.quanpingButton.hidden = NO;
        }
        self.smallVideoView.hidden = NO;
        self.liveUnStart.hidden = YES;
        [self switchVideoDoc:_isMain];
        //#ifdef LIANMAI_WEBRTC
        if (_multiCallStreamArray.count > 0) {
            [_multiCallStreamArray removeAllObjects];
            [self removeRemoteView:nil isKillAll:YES];
        }
        //#endif
    }
}

- (void)updateShowSmallVideoView
{
    if (![NSThread currentThread].isMainThread) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.smallVideoView.hidden != NO) {
                self.smallVideoView.hidden = NO;
            }
        });
    }else {
        if (self.smallVideoView.hidden != NO) {
            self.smallVideoView.hidden = NO;
        }
    }
}

// MARK: - 直播间封禁
- (void)theRoomWasBanned {
    if (_smallVideoView) {
        _smallVideoView.hidden = YES;
    }
    if (_liveUnStart) {
        _liveUnStart.hidden = NO;
    }
    if (_unStart) {
        _unStart.hidden = NO;
        _unStart.text = ROOM_IS_BAN;
    }
    if (_unStart1) {
        _unStart1.hidden = YES;
    }
    if (_quanpingButton) {
        _quanpingButton.hidden = YES;
    }
    if (_changeButton) {
        _changeButton.hidden = YES;
    }
    if (_moreBtn) {
        _moreBtn.hidden = YES;
        [self updateMoreBtnConstraints:YES];
    }
}


/**
 *    @brief  主讲开始推流
 */
- (void)streamDidBegin {
    
    _endNormal = NO;
    if (_loadingView) {
        [_loadingView removeFromSuperview];
        //    _loadingView = nil;
    }
//    _loadingView = nil;
    self.moreBtn.hidden = NO;
    [self updateMoreBtnConstraints:NO];
    self.liveUnStart.hidden = YES;
    if ((_templateType == 4 || _templateType == 5) && _isSmallDocView) {
        if (_smallVideoView) {
            _smallVideoView.hidden = NO;
        }else {
            [self addSmallView];
        }
        self.changeButton.hidden = NO;
    }
    if (_endNormal == NO) {
        if (self.screenLandScape == NO) {
            self.quanpingButton.hidden = NO;
        }
    }
}
/**
 *    @brief  停止直播，endNormal表示是否停止推流
 */
- (void)streamDidEnd:(BOOL)endNormal{
    
    _endNormal = endNormal;
    self.liveUnStart.hidden = endNormal == YES ? NO : YES;
    self.moreBtn.hidden = YES;
    [self updateMoreBtnConstraints:YES];
    if (_smallVideoView) {
        self.smallVideoView.hidden = YES;
    }
    self.changeButton.hidden = YES;
    self.unStart.text = PLAY_OVER;
    self.unStart1.hidden = YES;
    self.quanpingButton.hidden = YES;
    self.qingXiButton.hidden = YES;
    [self bringSubviewToFront:_liveUnStart];
    [_loadingView removeFromSuperview];
}

#pragma mark- 视频或者文档大窗
/**
 *  @brief  视频或者文档大窗(The new method)
 *  isMain 1为视频为主,0为文档为主"
 */
- (void)onSwitchVideoDoc:(BOOL)isMain{
    _isMain = isMain;
    [self switchVideoDoc:_isMain];
}
#pragma mark - 初始化直播间状态（私有调用方法)
//当第一次进入和收到直播状态的时候需要调用此方法
-(void)switchVideoDoc:(BOOL)isMain{
    if (!_isSmallDocView) {
        return;
    }
    /* 当房间类型不支持文档时，隐藏changeButton */
    if (_templateType == 1 || _templateType == 2|| _templateType == 3||_templateType == 6) {
        _changeButton.hidden = YES;
        return;
    }
    /* 根据视频或者文档大窗参数布局视频和文档 */
//    _changeButton.hidden = NO;
    if (isMain) {//视频为主
        if (self.changeButton.tag != 1) {
            [self changeBtnClick:self.changeButton];
        }
    } else {//文档为主
        //[self.changeButton setTitle:PLAY_CHANGEDOC forState:UIControlStateNormal];
        //[self.changeButton setImage:PLAY_CHANGEDOC_IMAGE forState:UIControlStateNormal];
        if (self.changeButton.tag != 2) {
            [self changeBtnClick:self.changeButton];
        }
    }
}
//#ifdef LIANMAI_WEBRTC
#pragma mark - lianmaiView
//连麦
-(LianmaiView *)lianMaiView {
    if(!_lianMaiView) {
        _lianMaiView = [[LianmaiView alloc] init];
        // 阴影颜色
        _lianMaiView.layer.shadowColor = [UIColor grayColor].CGColor;
        // 阴影偏移，默认(0, -3)
        _lianMaiView.layer.shadowOffset = CGSizeMake(0, 3);
        // 阴影透明度，默认0.7
        _lianMaiView.layer.shadowOpacity = 0.2f;
        // 阴影半径，默认3
        _lianMaiView.layer.shadowRadius = 3;
        _lianMaiView.contentMode = UIViewContentModeScaleAspectFit;
        _lianMaiView.delegate = self;
    }
    return _lianMaiView;
}
//连麦中提示
-(UIImageView *)connectingImage{
    if (!_connectingImage) {
        _connectingImage = [[UIImageView alloc] init];
        _connectingImage.image = [UIImage imageNamed:@"lianmai_connecting"];
    }
    return _connectingImage;
}
#pragma mark - 连麦相关
-(void)menuViewSelected:(BOOL)selected{
    if (_lianMaiView) {
        _lianMaiView.hidden = !selected;
    }
}
//连麦点击
-(void)lianmaiBtnClicked {
    if(!_isAllow) {
        //未开启连麦功能提示
        if (_informationViewPop) {
            [_informationViewPop removeFromSuperview];
        }
        _informationViewPop = [[InformationShowView alloc] initWithLabel:ALERT_LIANMAIFAILED];
        [APPDelegate.window addSubview:_informationViewPop];
        [_informationViewPop mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
        }];
        [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(removeInformationViewPop) userInfo:nil repeats:NO];
        [self removeLianMaiView];
        return;
    }
    if(!_lianMaiView) {
        [APPDelegate.window addSubview:self.lianMaiView];
        _menuView.lianmaiBtn.selected = YES;
//        AVAuthorizationStatus statusVideo = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
//        AVAuthorizationStatus statusAudio = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {

            if (granted) {
                _videoType = 3;
                [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (granted) {
                            _audoType = 3;

                            [self judgeLianMaiLocationWithVideoPermission:_videoType AudioPermission:_audoType];
                            [self.lianMaiView initUIWithVideoPermission:_videoType AudioPermission:_audoType];
                        } else {
                            _audoType = 2;

                            [self judgeLianMaiLocationWithVideoPermission:_videoType AudioPermission:_audoType];
                            [self.lianMaiView initUIWithVideoPermission:_videoType AudioPermission:_audoType];
                        }
                    });
                }];
            } else {
                _videoType = 2;
                [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (granted) {
                            _audoType = 3;

                            [self judgeLianMaiLocationWithVideoPermission:_videoType AudioPermission:_audoType];
                            [self.lianMaiView initUIWithVideoPermission:_videoType AudioPermission:_audoType];
                        } else {
                            _audoType = 2;

                            [self judgeLianMaiLocationWithVideoPermission:_videoType AudioPermission:_audoType];
                            [self.lianMaiView initUIWithVideoPermission:_videoType AudioPermission:_audoType];
                        }
                    });
                }];
            }
        }];
    } else if(_lianMaiView && _lianMaiView.hidden == NO && _lianMaiView.needToRemoveLianMaiView == YES) {
        [self removeLianMaiView];
    } else {
        BOOL hidden = self.lianMaiView.hidden;
        self.lianMaiView.hidden = !hidden;
        _menuView.lianmaiBtn.selected = hidden;
    }
}
- (void) getType{
    [self judgeLianMaiLocationWithVideoPermission:_videoType AudioPermission:_audoType];
    [self.lianMaiView initUIWithVideoPermission:_videoType AudioPermission:_audoType];

}
-(void)judgeLianMaiLocationWithVideoPermission:(AVAuthorizationStatus)statusVideo AudioPermission:(AVAuthorizationStatus)statusAudio {
    UIView *view = [self superview];
    AVAuthorizationStatus statusVideo1 = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    AVAuthorizationStatus statusAudio1 = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
//    dispatch_async(dispatch_get_main_queue(), ^{
        WS(ws)
        if(_screenLandScape) {//横屏模式
            if (statusVideo1 == AVAuthorizationStatusAuthorized && statusAudio1 == AVAuthorizationStatusAuthorized) {
                [_lianMaiView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.left.mas_equalTo(ws).offset(154);
                    make.size.mas_equalTo(CGSizeMake(171.5, 105.5));
                }];
            } else {
                _lianMaiView.frame = CGRectMake(57, 135, 195, 140);
            }
        } else {//竖屏模式
            if (statusVideo1 == AVAuthorizationStatusAuthorized && statusAudio1 == AVAuthorizationStatusAuthorized) {
                [_lianMaiView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.right.mas_equalTo(view).offset(-49.5);
                    make.bottom.mas_equalTo(view).offset(-120-kScreenBottom);
                    make.size.mas_equalTo(CGSizeMake(171.5, 105.5));
                }];
            } else {
                [_lianMaiView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.right.mas_equalTo(view).offset(-49.5);
                    make.bottom.mas_equalTo(view).offset(-85-kScreenBottom);
                    make.size.mas_equalTo(CGSizeMake(201.5, 140.5));
                }];
            }
        }

//    });

}
#pragma mark - 连麦代理
-(void)requestLianmaiBtnClicked:(BOOL)isVideo {
    _isAudioVideo = isVideo;
    //将要连接WebRTC
    self.connectSpeak(YES);
}
// 观看端主动断开连麦时候需要调用的接口
//取消连麦点击
-(void)cancelLianmainBtnClicked {
//断开连麦
    self.connectSpeak(NO);
    [self disconnectWithUI];
}
//挂断连麦点击
-(void)hungupLianmainiBtnClicked {
    //断开连麦
    self.connectSpeak(NO);
    [self disconnectWithUI];
}
//移除lianmaiView
-(void)removeLianMaiView
{
    if (_lianMaiView) {
        [_lianMaiView removeFromSuperview];
        _lianMaiView = nil;
    }
}

-(void)disconnectWithUI {
    if(_lianMaiView && _lianMaiView.audioBtn.hidden == YES &&_lianMaiView.videoBtn.hidden == YES && (_lianMaiView.cancelLianmainBtn.hidden == NO || _lianMaiView.hungupLianmainBtn.hidden == NO)) {
        [_lianMaiView initialState];
    } else if(_lianMaiView.audioBtn.hidden != NO && _lianMaiView.videoBtn.hidden != NO) {
        [self removeLianMaiView];
    }
    if (_remoteView) {
        [_remoteView removeFromSuperview];
        _remoteView = nil;
    }

    //挂断后移除连麦视图,并关闭更多菜单
    if (_lianMaiView) {
        [self removeLianMaiView];
    }
    //收回菜单视图
//    [self hiddenMenuView];
}

- (void)setupMultiMediaCall:(BOOL)isMultiMediaCall connectStatus:(BOOL)connectStatus {
    if(connectStatus == YES) {
        _isWebRTCConnecting = YES;
    } else {
        _isWebRTCConnecting = NO;
    }
    if (!isMultiMediaCall) {
        if(connectStatus == YES) {
            [_lianMaiView connectingToRTC];
            if(_isAudioVideo == YES) {
                if (_changeButton.tag == 2 && self.smallVideoView.hidden == NO) {
                    [self.smallVideoView addSubview:self.remoteView];
                    [self.smallVideoView sendSubviewToBack:self.remoteView];
                }else{
                    [self.hdContentView addSubview:self.remoteView];
                    [self.hdContentView sendSubviewToBack:self.remoteView];
                }
                [self bringSubviewToFront:self.topShadowView];
                [self bringSubviewToFront:self.bottomShadowView];
            }
        } else {
            [_lianMaiView hasNoNetWork];
        }
    }
}

#pragma mark - sdk连麦代理事件
/*
 *  @brief WebRTC连接成功，在此代理方法中主要做一些界面的更改
 */
- (void)connectWebRTCSuccess {
    [_lianMaiView connectWebRTCSuccess];
    WS(ws)
    //添加连麦中视图
//    [APPDelegate.window addSubview:self.connectingImage];
//    [_connectingImage mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.mas_equalTo(ws.menuView.mas_bottom).offset(5);
//        make.centerX.mas_equalTo(ws.menuView);
//        make.size.mas_equalTo(CGSizeMake(55, 20));
//    }];

    //添加提示信息
    UILabel *connectingLabel = [UILabel new];
    connectingLabel.text = @"连麦中";
    connectingLabel.font = [UIFont systemFontOfSize:FontSize_24];
    connectingLabel.textColor = [UIColor colorWithHexString:@"#12ad1a" alpha:1.f];
    [self.connectingImage addSubview:connectingLabel];
    [connectingLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(ws.connectingImage);
        make.left.mas_equalTo(ws.connectingImage).offset(13.5);
        make.right.mas_equalTo(ws.connectingImage);
    }];
    
    /// 这里设置声音解决连麦后声音从听筒而不从外放出来的问题 ---> bug 38385
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker error:nil];
}

/*
 *  @brief 当前是否可以连麦
 */
- (void)whetherOrNotConnectWebRTCNow:(BOOL)connect {
    if(connect == YES) {
        _isWebRTCConnecting = YES;
        [_lianMaiView connectingToRTC];
        if(_isAudioVideo == YES) {
            if (_changeButton.tag == 2 && self.smallVideoView.hidden == NO) {
                [self.smallVideoView addSubview:self.remoteView];
                [self.smallVideoView sendSubviewToBack:self.remoteView];
            }else{
                [self.hdContentView addSubview:self.remoteView];
                [self.hdContentView sendSubviewToBack:self.remoteView];
            }
            [self bringSubviewToFront:self.topShadowView];
            [self bringSubviewToFront:self.bottomShadowView];
        }
    } else {
        _isWebRTCConnecting = NO;
        [_lianMaiView hasNoNetWork];
    }
}
/**
 *  @brief 主播端接受连麦请求，在此代理方法中，要调用DequestData对象的
 *  - (void)saveUserInfo:(NSDictionary *)dict remoteView:(UIView *)remoteView;方法
 *  把收到的字典参数和远程连麦页面的view传进来，这个view需要自己设置并发给SDK，SDK将要在这个view上进行渲染
 *
 *  @param dict {type               //audio 音频  audiovideo 音视频
 *               videosize          //视频尺寸
 *               viewerId           //申请连麦ID
 *               viewerName         //申请连麦名}
 */
- (void)acceptSpeak:(NSDictionary *)dict {
    _videosizeStr = dict[@"videosize"];
    if(_isAudioVideo) {
        if (_changeButton.tag == 2) {
            self.remoteView.frame = [self calculateRemoteVIdeoRect:self.smallVideoView.frame];
        }else{
            self.remoteView.frame = [self calculateRemoteVIdeoRect:self.frame];
        }
    }
}

/*
 *  @brief 主播端发送断开连麦的消息，收到此消息后做断开连麦操作
 */
-(void)speak_disconnect:(BOOL)isAllow {
    dispatch_async(dispatch_get_main_queue(), ^{
        _isWebRTCConnecting = NO;
        if (_connectingImage) {
            [_connectingImage removeFromSuperview];
        }
        [self disconnectWithUI];    
    });
}
/*
 *  @brief 本房间为允许连麦的房间，会回调此方法，在此方法中主要设置UI的逻辑，
 *  在断开推流,登录进入直播间和改变房间是否允许连麦状态的时候，都会回调此方法
 */
- (void)allowSpeakInteraction:(BOOL)isAllow {
    _isAllow = isAllow;
    if(!_isAllow) {
        [self removeLianMaiView];
    }
}
//设置远程视图
-(UIView *)remoteView {
    if(!_remoteView) {
        _remoteView = [UIView new];
        _remoteView.backgroundColor = CCClearColor;
    }
    return _remoteView;
}
-(BOOL)exsitRmoteView{
    if (_remoteView) {
        return YES;
    }
    return NO;
}
-(void)removeRmoteView{
    if (_remoteView) {    
        [_remoteView removeFromSuperview];
        //    _remoteView = nil;
    }
}
-(CGRect) calculateRemoteVIdeoRect:(CGRect)rect {
    /*
     ****************************************************
     *    连麦申请中调用，主播关闭连麦，此时_videosizeStr为空, *
     *    调用_remoteView.frame时会造成崩溃，              *
     *    在这里需要判断_videoSzieStr是否为空               *
     ****************************************************
     */
    if (!_videosizeStr) {
        return CGRectMake(0, 0, 0, 0);
    }
    //字符串是否包含有某字符串
    NSRange range = [_videosizeStr rangeOfString:@"x"];
    float remoteSizeWHPercent = [[_videosizeStr substringToIndex:range.location] floatValue] / [[_videosizeStr substringFromIndex:(range.location + 1)] floatValue];

    float videoParentWHPercent = rect.size.width / rect.size.height;

    CGSize remoteVideoSize = CGSizeZero;

    if(remoteSizeWHPercent > videoParentWHPercent) {
        remoteVideoSize = CGSizeMake(rect.size.width, rect.size.width / remoteSizeWHPercent);
    } else {
        remoteVideoSize = CGSizeMake(rect.size.height * remoteSizeWHPercent, rect.size.height);
    }

    CGRect remoteVideoRect = CGRectMake((rect.size.width - remoteVideoSize.width) / 2, (rect.size.height - remoteVideoSize.height) / 2, remoteVideoSize.width, remoteVideoSize.height);
    return remoteVideoRect;
}
//#endif
@end
