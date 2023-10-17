//
//  HDSInteractionManager.m
//  CCLiveCloud
//
//  Created by richard lee on 3/16/22.
//  Copyright © 2022 MacBook Pro. All rights reserved.
//

#import "HDSInteractionManager.h"
#import "HDSInteractionManagerConfig.h"
#import "InformationShowView.h"

#import "HDSLiveStreamControlView.h"
///  点赞组件
#import "HDSLikeModule/HDSLikeModule.h"
#import "RLLikeButton.h"
#import "RLLikeConfiguration.h"

///  礼物组件
#import "HDSGiftModule/HDSGiftModule.h"
#import <HDSVoteModule/HDSVoteModule.h>
#import <HDSRedEnvelopeModule/HDSRedEnvelopeModule.h>
#import "CCLiveCloud-Swift.h"
#import "HDSRedPacketRainEngine.h"
#import "HDSRedPacketRainView.h"
#import "HDSRedPacketRainConfiguration.h"

#import "HDSRedPacketHistoryView.h"
#import <HDSInvitationCardModule/HDSInvitationCardModule.h>
#import <HDSQuestionnaireModule/HDSQuestionnaireModule.h>
#import <HDSLiveStoreModule/HDSLiveStoreModule.h>
#import <HDBaseUtils/HDBaseUtils.h>
#import "UIColor+RCColor.h"
#import "CCcommonDefine.h"
#import <Masonry/Masonry.h>

@interface HDSInteractionManager ()<HDSLikeFuncDelegate,HDSGiftFuncDelegate,HDSGiftSelectViewControllerDelegate,HDSVoteFuncDelegate, HDSRedEnvelopeFuncDelegate, HDSRedPacketHistoryViewDelegate, HDSQuestionnaireFuncDelegate,HDSLiveStoreFuncDelegate, HDSGoodAlertViewDelegate, HDSLiveGoodListViewDelegate>
@property(nonatomic, strong) HDSInvitationCardConfigModel * _Nullable configModel;
/// 配置项
@property (nonatomic, strong) HDSInteractionManagerConfig   *config;

/** 提示 */
@property (nonatomic, strong) InformationShowView     *informationView;

// MARK: - 礼物组件
/// 礼物组件
@property (nonatomic, strong) HDSGiftFunc               *giftFunc;
/// 礼物组件配置项
@property (nonatomic, strong) HDSGiftFuncConfig         *giftConfig;

// MARK: - 礼物UI
/// 礼物按钮视图
@property (nonatomic, strong) UIView                    *giftView;
/// 礼物列表按钮
@property (nonatomic, strong) UIButton                  *giftBtn;
/// 礼物列表数组
@property (nonatomic, strong) NSMutableArray            *giftListArray;
/// 礼物选择控制器
@property (nonatomic, strong) HDSGiftSelectViewController *gsVC;
/// 展示礼物控制器
@property (nonatomic, strong) HDSGiftShowViewController   *sgVC;
/// 当前礼物列表页码
@property (nonatomic, assign) NSInteger                 currentPage;
/// 每页礼物个数
@property (nonatomic, assign) NSInteger                 onePageSize;


// MARK: - 点赞组件
/// 点赞组件
@property (nonatomic, strong) HDSLikeFunc               *likeFunc;
/// 点赞组件配置项
@property (nonatomic, strong) HDSLikeFuncConfig         *likeConfig;

// MARK: - 投票组件
/// 投票组件
@property (nonatomic, strong) HDSVoteFunc               *voteFunc;
/// 投票组件配置项
@property (nonatomic, strong) HDSVoteFuncConfig         *voteConfig;
/// 红包雨组件配置项
@property (nonatomic, strong) HDSRedEnvelopeFunc         *redFunc;
/// 红包雨组件配置项
@property (nonatomic, strong) HDSRedEnvelopeConfig        *redConfig;
/// 邀请卡组件配置项
@property (nonatomic, strong) HDSInvitationCardFunc         *cardFunc;
/// 问卷组件配置项
@property (nonatomic, strong) HDSQuestionnaireFunc         *quesFunc;
/// 中奖概率
@property(nonatomic, assign) NSInteger                  redProbability;
/// 红包活动id
@property(nonatomic, copy) NSString                      *redActiveId;
/// 红包历史列表
@property(nonatomic, strong) HDSRedPacketHistoryView *redHistoryView;
@property(nonatomic, assign) NSInteger                  redCurrentPage;

@property (nonatomic, strong) UIButton                    *interActionBtn;

// MARK: - 点赞UI
/// 点赞视图
@property (nonatomic, strong) UIView                    *likeView;
/// 点赞个数背景图
@property (nonatomic, strong) UIView                    *likeCountView;
/// 点赞个数按钮
@property (nonatomic, strong) UILabel                   *likeTotalLabel;
/// 点赞按钮
@property (nonatomic, strong) RLLikeButton              *likeBtn;
/// 点赞按钮配置项
@property (nonatomic, strong) RLLikeConfiguration       *likeBtnConfig;
/// 点赞总数
@property (atomic, assign)    NSInteger                 likeTotalNum;
/// 临时点赞数
@property (atomic, assign)    NSInteger                 tempLikeNum;
/// 定时发送点赞定时器
@property (nonatomic, strong) NSTimer                   *sendLikeTimer;

@property (nonatomic, strong) NSTimer                   *tempTimer;
/// 投票按钮
@property(nonatomic, strong) UIButton                   *voteBtn;
/// 红包雨按钮
@property(nonatomic, strong) UIButton                   *redBtn;
@property(nonatomic, strong) HDSVoteDetailView          *voteDetailView;

@property (nonatomic, assign) double                    k_trillion;

@property (nonatomic, assign) double                    k_billion;
/// 横屏中收到的进行中的投票
@property(nonatomic, strong) NSString               *voteActiveId;
/// 横屏中收到的进行中的红包
@property(nonatomic, strong) NSString               *redActioveId;
/// 横屏中收到的进行中的问卷
@property(nonatomic, strong) HDSQuestionnairePushQuery *quesModel;
/// 问卷详情
@property(nonatomic, strong) HDSQuestionnaireDetailView *detailView;
/// 问卷列表
@property(nonatomic, strong) HDSQuestionnaireHistoryList *quesListView;
/// 投票列表
@property(nonatomic, strong) HDSVoteViewList *listView;
/// 加号按钮弹出视图
@property(nonatomic, strong) HDSMoreInteractionView *moreInteractionView;
/// 邀请卡列表视图
@property(nonatomic, strong) HDSInvitaionCardList *cardListView;
/// 邀请卡排行榜视图
@property(nonatomic, strong) HDSCardRankView *cardRankView;
/// 本地生产的list item数据
@property(nonatomic, strong) HDSQuestionnairePushQuery *pushQuery;
/// 是否被踢出
@property(nonatomic, assign) BOOL isKillAll;
/// 直播带货商品列表
@property(nonatomic, strong) HDSLiveGoodListView *goodListView;
/// 直播带货商品弹框
@property(nonatomic, strong) HDSGoodAlertView *goodAlertView;
/// 4.5.0新增直播带货
@property(nonatomic, strong) UIButton *liveStoreButton;
@property(nonatomic, strong) HDSItemLinkModel * _Nonnull itemLinkModel;
@property(nonatomic, strong) HDSPushItemModel * _Nonnull pushItemModel;
@property(nonatomic, copy) NSString *storeItemId;

// MARK: - 直播带货
@property (nonatomic, strong) HDSLiveStoreFunc  *liveStoreFunc;
@property (nonatomic, strong) HDSLiveStoreFuncConfig  *liveStoreFuncConfig;
@property (nonatomic, copy)   NSString *liveStore_pushingItemID;

// MARK: - 红包雨
@property (nonatomic, copy) NSString *rankBackgroundUrl;
@property (nonatomic, copy) NSArray *driftDownUrls;

@end

@implementation HDSInteractionManager

- (instancetype)initWithConfig:(HDSInteractionManagerConfig *)config {
    self = [super init];
    if (self) {
        self.config = config;
        self.k_trillion = 1000000000000;
        self.k_billion = 1000000000000;
        [self addObserver];
        [self openInteractionFunc];
    }
    return self;
}

/// 添加通知
- (void)addObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(interactionFuncSwitchDidChange:) name:kLiveInteractionFuncSwitchStatusDidiChangeNotification object:nil];
}

- (void)interactionFuncSwitchDidChange:(NSNotification *)notifaction {
    NSDictionary *dict = notifaction.userInfo;
    if ([dict.allKeys containsObject:@"status"]) {
        BOOL status = [dict[@"status"] boolValue];
        _likeBtn.hidden = status;
        _likeCountView.hidden = status;
        _likeView.hidden = status;
        _likeBtn.hidden = status;
        _interActionBtn.hidden = status;
        _liveStoreButton.hidden = status;
        _voteBtn.hidden = status;
        _redBtn.hidden = status;
    }
}

- (void)removeObserver {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

/// 屏幕方向发生改变
/// @param orientation 方向
- (void)screenOrientationDidChange:(ScreenOrientation)orientation {
    BOOL isLandspace = orientation == landspace ? YES : NO;
    if (_likeView) {
        _likeView.hidden = orientation == landspace ? YES : NO;
    }
    if (_sgVC) {
        _sgVC.view.hidden = orientation == landspace ? YES : NO;
    }
    if (_voteDetailView) {
        if (isLandspace) {
            [_voteDetailView removeFromSuperview];
        }
    }
    
    if (!isLandspace) {
        [self updateFuncUI];
        if ([self.voteActiveId isKindOfClass:NSString.class]) {
            if (self.voteActiveId.length > 0) {
                [self showVoteDetail:self.voteActiveId];
            }
        }
        
        if ([self.redActioveId isKindOfClass:NSString.class]) {
            if (self.redActioveId.length > 0) {
                [self startRed:self.redActioveId];
            }
        }
        
        if (self.quesModel != nil) {
            [self getQuestionnaireDetail:self.quesModel];
        }
        
        if (self.itemLinkModel != nil) {
            [self showGoodAlertView];
        }
    }
}

- (void)killAll {
    self.isKillAll = YES;
    if (_giftFunc) {
        [_giftFunc killAll];
    }
    
    if (_likeFunc) {
        [_likeFunc killAll];
    }
    
    if (_voteFunc) {
        [_voteFunc killAll];
    }
    
    if (_redFunc) {
        [_redFunc killAll];
    }
    
    if (_cardFunc) {
        [_cardFunc killAll];
    }
    
    if (_quesFunc) {
        [_quesFunc killAll];
    }
    
    if (_listView) {
        [self.listView removeFromSuperview];
    }
    if (_voteDetailView) {
        [self.voteDetailView removeFromSuperview];
    }
    if (_redHistoryView) {
        [_redHistoryView removeFromSuperview];
    }
    if (_detailView) {
        [_detailView removeFromSuperview];
        _detailView = nil;
    }
    if (_quesListView) {
        [_quesListView removeFromSuperview];
        _quesListView = nil;
    }
    if (_moreInteractionView) {
        [_moreInteractionView removeFromSuperview];
        _moreInteractionView = nil;
    }
    if (_cardListView) {
        [_cardListView removeFromSuperview];
        _cardListView = nil;
    }
    if (_cardRankView) {
        [_cardRankView removeFromSuperview];
        _cardRankView = nil;
    }
    [self liveGoodListCloseAction];
    
    [self goodAlertViewCloseAction];
    
    [[HDSRedPacketRainEngine shared] killAll];
    
    if (_liveStoreFunc) {
        [_liveStoreFunc killAll];
        _liveStoreFunc.delegate = nil;
        _liveStoreFunc = nil;
    }
    
    if (_goodAlertView) {
        [_goodAlertView removeFromSuperview];
        _goodAlertView = nil;
    }
    [self removeObserver];
}

/// 开启互动功能
- (void)openInteractionFunc {
    self.isKillAll = NO;
    [self.giftListArray removeAllObjects];
    
    if (self.config.giftConfig != 0) {
        self.currentPage = 1;
        self.onePageSize = 20;
        [self initGiftModule];
    }
    if (self.config.voteConfig != 0) {
        [self initVoteModule];
    }
    if (self.config.redConfig != 0) {
        [self initRedModule];
    }
    
    if (self.config.cardConfig != 0) {
        [self initCardModule];
    }
    
    if (self.config.questionnaireConfig != 0) {
        [self initQuestionModule];
    }
    
    if (self.config.giftConfig != 0 || self.config.voteConfig != 0 || self.config.redConfig != 0 || self.config.cardConfig != 0 || self.config.questionnaireConfig != 0) {
        [self interActionBtnUI];
    }
    
    if (self.config.liveStoreConfig != 0) {
        [self customLiveStoreUI];
        [self initLiveStoreModule];
    }
    
    if (self.config.likeConfig != 0) {
        [self initLikeModule];
        [self customLikeUI];
    }
}

- (void)updateFuncUI {
    if ((self.config.giftConfig != 0 || self.config.voteConfig != 0 || self.config.redConfig != 0 || self.config.cardConfig != 0 || self.config.questionnaireConfig != 0) && _interActionBtn == nil) {
        [self interActionBtnUI];
    }
    if (self.config.liveStoreConfig != 0) {
        [self customLiveStoreUI];
    }
}

- (void)showTipWithString:(NSString *)tipStr {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_informationView) {
            [_informationView removeFromSuperview];
            _informationView = nil;
        }
        _informationView = [[InformationShowView alloc]initWithLabel:tipStr];
        [APPDelegate.window addSubview:_informationView];
        [_informationView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
        }];
        [NSTimer scheduledTimerWithTimeInterval:.9f target:self selector:@selector(removeInformationView) userInfo:nil repeats:NO];
    });
}

- (void)removeInformationView {
    if (_informationView) {
        [_informationView removeFromSuperview];
        _informationView = nil;
    }
}

- (void)interActionBtnUI {
    if (HDSVoteTool.tool.isLandspace) {
        return;
    }
    if (_config.boardView == nil) {
        self.interActionBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.config.rootVC.view.frame.size.width - 52 ,self.config.rootVC.view.frame.size.height - 194 - kScreenBottom , 43, 43)];
        [self.interActionBtn setImage:[UIImage imageNamed:@"更多加号"] forState:UIControlStateNormal];
        [self.interActionBtn addTarget:self action:@selector(interActionBtnAction) forControlEvents:UIControlEventTouchUpInside];
        [self.config.rootVC.view addSubview:self.interActionBtn];
    }
}

- (void)interActionBtnAction {
    self.moreInteractionView = [[HDSMoreInteractionView alloc] init];
    
    [APPDelegate.window addSubview:self.moreInteractionView];
    [self.moreInteractionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(APPDelegate.window);
    }];
//    self.config.cardRankConfig = self.configModel.showRank;
    [self.moreInteractionView showMoreInteractionView:self.config];
    __weak typeof(self) weakSelf = self;
    [self.moreInteractionView interactionClickCallBack:^(enum HDSMoreInteractionType type) {
        if (type == HDSMoreInteractionTypeRed) {
            [weakSelf redBtnAction];
        } else if (type == HDSMoreInteractionTypeVote) {
            [weakSelf voteBtnAction];
        } else if (type == HDSMoreInteractionTypeGift) {
            [weakSelf showGiftList];
        } else if (type == HDSMoreInteractionTypeCard) {
            if (weakSelf.configModel.showRank) {
                [weakSelf getInvitaionCardRank];
            } else {
                [weakSelf getCardList];
            }
        } else if (type == HDSMoreInteractionTypeQuestionnaire) {
            [weakSelf getInvitaionQuestionnaireList];
        }
    }];
}

- (void)customLiveStoreUI {
    if (HDSVoteTool.tool.isLandspace) {
        return;
    }
    if (_config.boardView == nil) {
        if (_liveStoreButton == nil) {
            self.liveStoreButton = [[UIButton alloc] initWithFrame:CGRectMake(self.config.rootVC.view.frame.size.width - 52 ,self.config.rootVC.view.frame.size.height - 147 - kScreenBottom , 43, 43)];
            [self.liveStoreButton setImage:[UIImage imageNamed:@"ShoppingBags"] forState:UIControlStateNormal];
            [self.liveStoreButton addTarget:self action:@selector(liveStoreButtonAction) forControlEvents:UIControlEventTouchUpInside];
            [self.config.rootVC.view addSubview:self.liveStoreButton];
        }
    }
}


- (void)liveStoreButtonAction {
    [self getLiveStoreItemList:1 pageSize:10];
}

// MARK: - 自定义点赞UI
- (void)customLikeUI {

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cleanTheWindow:) name:HDS_Clean_The_WIndow_Notification object:nil];
    
    // 定时发送点赞定时器
    if ([self.sendLikeTimer isValid]) {
        [self.sendLikeTimer invalidate];
        self.sendLikeTimer = nil;
    }
    self.sendLikeTimer = [NSTimer timerWithTimeInterval:2.1 target:self selector:@selector(sendLikeFunc) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.sendLikeTimer forMode:NSRunLoopCommonModes];
    
    // 点赞视图
    if (_likeView) {
        [_likeView removeFromSuperview];
        _likeView = nil;
    }
    
    if (_config.boardView) {
        self.likeView = [[UIView alloc]initWithFrame:CGRectMake(self.config.boardView.frame.size.width - 52 ,self.config.boardView.frame.size.height - 100 - kScreenBottom , 43, 43)];
        self.likeView.backgroundColor = UIColor.clearColor;
        [self.config.boardView addSubview:self.likeView];
    } else {
        self.likeView = [[UIView alloc]initWithFrame:CGRectMake(self.config.rootVC.view.frame.size.width - 52 ,self.config.rootVC.view.frame.size.height - 100 - kScreenBottom , 43, 43)];
        self.likeView.backgroundColor = UIColor.clearColor;
        [self.config.rootVC.view addSubview:self.likeView];
    }
    
    
    // 飘动资源
    UIImage *likeBtn = [UIImage imageNamed:@"点赞home"];
    NSMutableArray *likesArr = [NSMutableArray array];
    for (int i = 0; i < 12; i++) {
        NSString *imageName = [NSString stringWithFormat:@"like_%d",i+1];
        UIImage *image = [UIImage imageNamed:imageName];
        [likesArr addObject:image];
    }

    // 点赞按钮配置项
    self.likeBtnConfig = [[RLLikeConfiguration alloc]init];
    self.likeBtnConfig.likeImages = (NSArray *)likesArr;
    self.likeBtnConfig.likeBtnImage = likeBtn;
    self.likeBtnConfig.likeTimeInterval = 0.2;  // 点赞飘动时间间隔(自动飘动)
    self.likeBtnConfig.likeDuration = 2;        // 点赞持续时间
    self.likeBtnConfig.showMinHeight = 100;     // 点赞飘动最小高度
    self.likeBtnConfig.showMaxHeight = 300;     // 点赞飘动最大高度
    
    // 点赞按钮
    if (_likeBtn) {
        [_likeBtn removeFromSuperview];
        _likeBtn = nil;
    }
    self.likeBtn = [[RLLikeButton alloc]initWithFrame:CGRectMake(0 ,0 , 43, 43) configuration:self.likeBtnConfig closure:^(int touchCount) {
        self.likeTotalNum = self.likeTotalNum + touchCount;
        [self updateLikeCount:self.likeTotalNum];
        // 自己点赞数（临时）
        self.tempLikeNum = self.tempLikeNum + touchCount;
    
    }];
    [self.likeView addSubview:self.likeBtn];
    
    // 点赞个数背景视图
    self.likeCountView = [[UIView alloc]initWithFrame:CGRectZero];
    self.likeCountView.backgroundColor = [UIColor whiteColor];
    self.likeCountView.layer.cornerRadius = 7.f;
    self.likeCountView.layer.masksToBounds = NO;
    self.likeCountView.layer.shadowColor = [UIColor lightGrayColor].CGColor;
    self.likeCountView.layer.shadowOpacity = 0.2;
    self.likeCountView.layer.shadowRadius =  2;
    self.likeCountView.layer.shadowOffset = CGSizeZero;
    CGFloat x = (self.likeBtn.frame.size.width / 2) - 25;
    self.likeCountView.frame = CGRectMake(x, 0, 50, 14);
    [self.likeView addSubview:self.likeCountView];
    // 点赞个数 Label
    self.likeTotalLabel = [[UILabel alloc]initWithFrame:CGRectMake(1, 0, 48, 14)];
    self.likeTotalLabel.textColor = [UIColor orangeColor];
    self.likeTotalLabel.textAlignment = NSTextAlignmentCenter;
    self.likeTotalLabel.font = [UIFont systemFontOfSize:10];
    self.likeTotalLabel.text = @"0";
    [self.likeCountView addSubview:self.likeTotalLabel];
}

- (void)cleanTheWindow:(NSNotification *)noti {
    if ([noti.userInfo.allKeys containsObject:@"status"]) {
        BOOL result = [noti.userInfo[@"status"] boolValue];
        if (result == YES) {
            _likeView.hidden = YES;
            _likeBtn.hidden = YES;
            _likeCountView.hidden = YES;
        } else {
            _likeView.hidden = NO;
            _likeBtn.hidden = NO;
            _likeCountView.hidden = NO;
        }
    }
}

/// 定时发送点赞请求
- (void)sendLikeFunc {
    if (self.tempLikeNum == 0) {
        return;
    }
    [self.likeFunc sendLikeActionWithCount:self.tempLikeNum closure:^(BOOL result, NSString * _Nullable message) {
        if (result) {
            self.tempLikeNum = 0;
        }else {
            NSString *tipStr = [NSString stringWithFormat:@"发送点赞失败 -->:%@",message];
            [self showTipWithString:tipStr];
        }
    }];
}

/// 收到房间的点赞
/// @param count 个数
- (void)doShowLikeWithCount:(NSInteger)count {
    
    if (_likeBtn == nil) {
        return;
    }
    // 收到多个赞 执行点赞动画
    if (count > 1) {
        if ([self.likeBtn getIsAnimation] == NO) { // 不在动画中
            [self.likeBtn startGroupAnimation];
            CGFloat time = (CGFloat)count / (CGFloat)5; // 点赞持续时间 = 总个数 / 5
            if (time > 10) { // 最长时间 10 秒
                time = 10;
            }
            [self performSelector:@selector(doLikeHidden) withObject:nil afterDelay:time];
        }
    }else {
        // 收到单个赞
        [self.likeBtn singleAnimation];
    }
}

/// 停止点赞飘动
- (void)doLikeHidden {
    if ([self.likeBtn getIsAnimation]) {
        [self.likeBtn stopGroupAnimation]; // 停止点赞飘动
    }
}

/// 更新点赞个数
/// @param count 总个数
- (void)updateLikeCount:(NSInteger)count {
    NSString *numStr;
    if (count >= self.k_trillion) { // 万亿
        numStr = [NSString stringWithFormat:@"%.2fT",(double)count / (double)self.k_trillion];
    }else if (count >= 1000000000 && count < self.k_billion) { // 十亿
        numStr = [NSString stringWithFormat:@"%.2fB",(double)count / (double)self.k_billion];
    }else if (count >= 1000000 && count < 1000000000) { // 百万
        numStr = [NSString stringWithFormat:@"%.2fM",(double)count / (double)1000000];
    }else if (count >= 1000 && count < 1000000 ) { // 千
        numStr = [NSString stringWithFormat:@"%.2fK",(double)count / (double)1000];
    }else {
        numStr = [NSString stringWithFormat:@"%zd",count];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        self.likeTotalLabel.text = numStr;
    });
}

//MARK: - 点赞组件
- (void)initLikeModule {
    // 点赞组件配置项
    self.likeConfig = [[HDSLikeFuncConfig alloc]init];
    self.likeConfig.token = self.config.token;
    self.likeConfig.userId = self.config.userId;
    self.likeConfig.userName = self.config.userName;
    self.likeConfig.roomId = self.config.roomId;
    
    // 点赞组件
    self.likeFunc = [[HDSLikeFunc alloc]initLikeFuncWithConfig:self.likeConfig closure:^(BOOL result, NSString * _Nullable message) {
        if (result) {
            [self getHistoryLikeInformation];
        }else {
            NSString *tipStr = [NSString stringWithFormat:@"点赞初始化失败，点赞功能不可用 -->:%@",message];
            [self showTipWithString:tipStr];
        }
    }];
    self.likeFunc.delegate = self;
}
    
/// 获取历史点赞信息
- (void)getHistoryLikeInformation {
    
    [self.likeFunc getLikeInformationClosure:^(BOOL result, NSString * _Nullable message) {
        if (result) {
    
        }else {
    
            NSString *tipStr = [NSString stringWithFormat:@"获取历史点赞信息失败 -->:%@",message];
            [self showTipWithString:tipStr];
        }
    } information:^(HDSLikeFuncInformationModel * _Nullable model) {
    
        self.likeTotalNum = model.currentNumbers;
        [self updateLikeCount:self.likeTotalNum];
    }];
}

// MARK: - Like Delegate
/// 收到点赞消息
/// @param message 点赞消息
- (void)onLikeEventWithMessage:(HDSReceiveLikeInformationModel *)message {
    NSInteger count = message.currentNumbers;
    if (count > self.likeTotalNum) {
        [self updateLikeCount:count];
        NSInteger showCount = count - self.likeTotalNum;
        [self doShowLikeWithCount:showCount];
        self.likeTotalNum = count;
    }
}
// MARK: - 投票组件
- (void)voteBtnAction {
    __weak typeof(self) weakSelf = self;
    [self.voteFunc getVoteListClosure:^(BOOL result, NSString * _Nullable message) {
        if (!result) {
            [weakSelf showTipWithString:message];
        }
    } information:^(NSArray<HDSVoteModel *> * _Nullable model) {
        if ([NSThread isMainThread]) {
            [weakSelf showVoteList:model];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf showVoteList:model];
            });
        }
    }];
}

- (void)showVoteList:(NSArray<HDSVoteModel *> *)modelList {
    if (HDSVoteTool.tool.isLandspace) {
        [self showTipWithString:@"请切换至竖屏使用投票功能"];
        return;
    }
    self.listView = [[HDSVoteViewList alloc] init];
    [APPDelegate.window addSubview:self.listView];
    [self.listView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(APPDelegate.window);
    }];
    [self.listView updateModelArr:modelList];
    __weak typeof(self) weakSelf = self;
    [self.listView didSelectAction:^(HDSVoteModel * _Nonnull model) {
        [weakSelf showVoteDetail:model.activityId];
    }];
}

- (void)showVoteDetail:(NSString *)activeId {
    self.voteActiveId = nil;
    __weak typeof(self) weakSelf = self;
    [self.voteFunc getVoteDetailClosure:activeId closure:^(BOOL result, NSString * _Nullable message) {
        
        if (!result) {
            [weakSelf showTipWithString:message];
        }
    } information:^(HDSVoteModel * _Nullable model) {
        
        if ([NSThread isMainThread]) {
            [weakSelf showVoteDetailView:model];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf showVoteDetailView:model];
            });
        }
    }];
}

- (void)showVoteDetailView:(HDSVoteModel *)model {
    if (HDSVoteTool.tool.isLandspace) {
        [self showTipWithString:@"请切换至竖屏使用投票功能"];
        return;
    }
    self.voteDetailView = [[HDSVoteDetailView alloc] init];
    
    __weak typeof(self) weakSelf = self;
    [self.voteDetailView submitCallBack:^(HDSVoteModel * _Nonnull model) {
        [weakSelf submitAction:model];
    }];
    [APPDelegate.window addSubview:self.voteDetailView];
    
    [self.voteDetailView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(APPDelegate.window);
    }];
    
    [self.voteDetailView setModel:model];
}

- (void)updateVoteDetail:(NSString *)activeId {
    self.voteActiveId = nil;
    __weak typeof(self) weakSelf = self;
    [self.voteFunc getVoteDetailClosure:activeId closure:^(BOOL result, NSString * _Nullable message) {
        
        if (!result) {
            [weakSelf showTipWithString:message];
        }
    } information:^(HDSVoteModel * _Nullable model) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.voteDetailView setModel:model];
        });
    }];
}

- (void)submitAction:(HDSVoteModel *)model {
    NSMutableArray<NSNumber *> *arr = [NSMutableArray array];
    for (HDSVoteOptionsModel *optionModel in model.voteOptions) {
        if (optionModel.selected) {
            [arr addObject:@(optionModel.voteOptionId)];
        }
    }
    __weak typeof(self) weakSelf = self;
    [self.voteFunc sendVoteActivityId:model.activityId optionIdList:arr closure:^(BOOL result, NSString * _Nullable message) {
        if (!result) {
            [weakSelf showTipWithString:message];
            return;
        }
        [weakSelf updateVoteDetail:model.activityId];
    }];
}

//MARK: - 投票组件
- (void)initVoteModule {

    // 点赞组件配置项
    self.voteConfig = [[HDSVoteFuncConfig alloc] init];
    self.voteConfig.token = self.config.token;
    self.voteConfig.userId = self.config.userId;
    self.voteConfig.userName = self.config.userName;
    self.voteConfig.roomId = self.config.roomId;
    
    // 点赞组件
    self.voteFunc = [[HDSVoteFunc alloc] initVoteFuncWithConfig:self.voteConfig closure:^(BOOL result, NSString * _Nullable message) {
        if (result) {
            
            if ([NSThread isMainThread]) {
                [self checkShowCurrentVote];
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self checkShowCurrentVote];
                });
            }
        }else {
            NSString *tipStr = [NSString stringWithFormat:@"投票初始化失败，投票功能不可用 -->:%@",message];
            [self showTipWithString:tipStr];
            
        }
    }];
    self.voteFunc.delegate = self;
}

- (void)checkShowCurrentVote {
    for (NSDictionary *dic in self.config.interactionArr) {
        NSInteger type = [dic[@"type"] integerValue];
        if (type == 7) {
            [self showVoteDetail:dic[@"id"]];
            if (HDSVoteTool.tool.isLandspace) {
                self.voteActiveId = dic[@"id"];
            }
            break;
        }
    }
}

#pragma make - HDSVoteFuncDelegate
- (void)onVoteEventWithMessage:(HDSVoteModel *)message {
    if (HDSVoteTool.tool.isLandspace) {
        if (message.status == 1) {
            self.voteActiveId = message.activityId;
        } else {
            self.voteActiveId = nil;
        }
        [self showTipWithString:@"请切换至竖屏使用投票功能"];
        return;
    }
    if ([NSThread isMainThread]) {
        [self private_onVoteEventWithMessage:message];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self private_onVoteEventWithMessage:message];
        });
    }
    
}

- (void)private_onVoteEventWithMessage:(HDSVoteModel *)message {
    if (message.status == 1) {
        if (_voteDetailView) {
            [self.voteDetailView removeFromSuperview];
            self.voteDetailView = nil;
        }
        
        [self showVoteDetail:message.activityId];
    } else {
        self.voteActiveId = nil;
        [self.voteDetailView removeFromSuperview];
        self.voteDetailView = nil;
    }
}

// MARK: - 红包组件
- (void)initRedModule {

    // 点赞组件配置项
    self.redConfig = [[HDSRedEnvelopeConfig alloc] init];
    self.redConfig.token = self.config.token;

    self.redConfig.userId = self.config.userId;
    self.redConfig.userName = self.config.userName;
    self.redConfig.roomId = self.config.roomId;
    __weak typeof(self) weakSelf = self;
    // 点赞组件
    self.redFunc = [[HDSRedEnvelopeFunc alloc] initRedEnvelopeFuncWithConfig:self.redConfig closure:^(BOOL result, NSString * _Nullable message) {
        if (result) {

            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf checkShowCurrentRed];
            });
        }else {
            NSString *tipStr = [NSString stringWithFormat:@"红包雨初始化失败，红包雨功能不可用 -->:%@",message];
            [self showTipWithString:tipStr];
        }
    }];
    self.redFunc.delegate = self;
}

- (void)checkShowCurrentRed {
    for (NSDictionary *dic in self.config.interactionArr) {
        NSInteger type = [dic[@"type"] integerValue];
        if (type == 6) {
            [self startRed:dic[@"id"]];
            if (HDSVoteTool.tool.isLandspace) {
                self.redActioveId = dic[@"id"];
            }
            break;
        }
    }
}

- (void)redBtnAction {
    [self loadHistoryData:YES];
}

- (void)loadHistoryData:(BOOL)isFirst {
    self.redCurrentPage = isFirst ? 1 : self.redCurrentPage ++;
    __weak typeof(self) weakSelf = self;
    [self.redFunc getUserRecord:^(BOOL result, NSString * _Nullable message) {
        if (!result) {
            NSString *tipStr = [NSString stringWithFormat:@"获取用户中奖列表失败-->:%@",message];
            [weakSelf showTipWithString:tipStr];
        }
    } infoCallBack:^(HDSRedEnvelopeWinningUserListModel * _Nullable model) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.redHistoryView showHistory:model isFirst:isFirst];
        });
    }];
}

// MARK - HDSRedPacketHistoryViewDelegate
- (void)redPacketHistoryViewLoadMore {
    [self loadHistoryData:NO];
}

- (void)redPacketHistoryViewLoadRefresh {
    [self loadHistoryData:YES];
}

- (void)redPacketHistoryViewClose {
    [self.redHistoryView removeFromSuperview];
    _redHistoryView = nil;
}

- (HDSRedPacketHistoryView *)redHistoryView {
    if (!_redHistoryView) {
        if (_config.boardView) {
            _redHistoryView = [[HDSRedPacketHistoryView alloc] initWithFrame:self.config.boardView.bounds];
        } else {
            _redHistoryView = [[HDSRedPacketHistoryView alloc] initWithFrame:self.config.rootVC.view.bounds];
        }
        _redHistoryView.delegate = self;
        [APPDelegate.window addSubview:_redHistoryView];
    }
    return _redHistoryView;
}

- (void)startRed:(NSString *)avtiveId {
    if (HDSVoteTool.tool.isLandspace) {
        [self showTipWithString:@"请切换至竖屏使用红包功能"];
        return;
    }
    
    self.redActioveId = nil;
    __weak typeof(self) weakSelf = self;
    [self.redFunc getRedDetail:avtiveId closure:^(BOOL result, NSString * _Nullable message) {
        if (result) {
        }else {
            NSString *tipStr = [NSString stringWithFormat:@"获取红包雨详情失败，红包雨功能不可用 -->:%@",message];
            [self showTipWithString:tipStr];
            
        }
        
    } infoCallBack:^(HDSRedEnvelopeModel * _Nullable model) {
        if ([NSThread isMainThread]) {
            [weakSelf showRedView:model];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf showRedView:model];
            });
        }
        
    }];
}

- (void)showRedView:(HDSRedEnvelopeModel *)model {
    if (HDSVoteTool.tool.isLandspace) {
        [self showTipWithString:@"请切换至竖屏使用红包功能"];
        return;
    }
    
    self.redProbability = model.redProbability;
    self.redActiveId = model.redActivityId;
    __weak typeof(self) weakSelf = self;
    HDSRedPacketRainConfiguration *config = [[HDSRedPacketRainConfiguration alloc] init];
    BOOL isLandSpec = SCREEN_WIDTH > SCREEN_HEIGHT ? YES : NO;
    if (model.redSpeed == 1) {
        config.fallingTime = isLandSpec == YES ? 3.8/1.5 : 3.8;
    } else if (model.redSpeed == 2) {
        config.fallingTime = isLandSpec == YES ? 2.8/1.5 : 2.8;
    } else if (model.redSpeed == 3) {
        config.fallingTime = isLandSpec == YES ? 2.8/1.5 : 1.8;
    } else {
        config.fallingTime = isLandSpec == YES ? 1.8/1.5 : 1;
    }
    config.itemW = 120;
    config.itemH = 120;
    config.isShowCountdownAnimation = YES;
    config.boardView = APPDelegate.window;
    
    if (_driftDownUrls.count > 0) {
        config.driftDownUrls = self.driftDownUrls;
    } else {
        config.redPacketImageName = @"redPacket";
    }
    config.rankBackgroundUrl = self.rankBackgroundUrl;
    
    config.id = [NSString stringWithFormat:@"%@",model.redActivityId];
    config.duration = model.redDuration;
    NSTimeInterval time = [self timeSwitchTimestamp:model.redSendTime andFormatter:@"yyyy-MM-dd HH:mm:ss"];
    
    config.startTime = time;
    config.currentTime = model.serverTime / 1000;
    config.slidingRate = model.redSpeed;
    
    [[HDSRedPacketRainEngine shared] prepareRedPacketWithConfiguration:config tapRedPacketClosure:^(int index) {
        // 选中红包
        [weakSelf grabARedEnvelope:model.redActivityId];
    } endRedPacketClosure:^{
        if (weakSelf.isKillAll) {
            return;
        }
        // 显示结果页
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf showRedPacketRainRank:weakSelf.redActiveId];
        });
    }];
    
    [[HDSRedPacketRainEngine shared] startRedPacketRain];
    
}

- (void)grabARedEnvelope:(NSString *)redActivityId {
    __weak typeof(self) weakSelf = self;
    [self.redFunc robRed:redActivityId closure:^(BOOL result, NSString * _Nullable message) {
        if (result) {
            // 抢中
        }
    }];
}

- (BOOL)checkLoadHttp {
    // 本地判断是否中奖
    float val = (float)arc4random() / UINT32_MAX;
    float redProbabilityF = self.redProbability / 100.0;
    if (val <= redProbabilityF) {
        return YES;
    }
    return NO;
}

- (void)showRedPacketRainRank:(NSString *)activeId {
    [self.redFunc getRankList:activeId closure:^(BOOL result, NSString * _Nullable message) {
        if (!result) {
            NSString *tipStr = [NSString stringWithFormat:@"获取红包雨排行榜失败-->:%@",message];
            [self showTipWithString:tipStr];
        }
    } infoCallBack:^(HDSRedEnvelopeWinningListModel * _Nullable model) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (HDSVoteTool.tool.isLandspace) {
                [self showTipWithString:@"请切换至竖屏使用红包功能"];
                return;
            }
            [[HDSRedPacketRainEngine shared] showRedPacketRainRank:model closeRankClosure:^{
                
            }];
        });
    }];
}

- (void)testRed {
    HDSRedEnvelopeWinningListModel *model = [[HDSRedEnvelopeWinningListModel alloc] init];
    model.totalPrice = 1;
    model.win = @"1";
    model.userId = @"1231";
    model.redKind = 1;
    HDSRedEnvelopeWinningListRecordModel *record = [[HDSRedEnvelopeWinningListRecordModel alloc] init];
    record.userId = @"1231";
    record.userName = @"测试";
    record.winPrice = 1;
    record.headUrl = @"https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fwww.2008php.com%2F09_Website_appreciate%2F10-07-11%2F1278861720_g.jpg&refer=http%3A%2F%2Fwww.2008php.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=auto?sec=1652863748&t=09d773ba3d6d6dd33cd25179eea87e38";
    record.winTime = @"2022-04-18 10:00";
    model.records = @[record];
    [[HDSRedPacketRainEngine shared] showRedPacketRainRank:model closeRankClosure:^{
        
    }];
}
// MARK: 邀请卡
- (void)initCardModule {
    // 邀请卡组件配置项
    HDSInvitationCardConfig *cardConfig = [[HDSInvitationCardConfig alloc] init];
    cardConfig.token = self.config.token;
    cardConfig.userId = self.config.userId;
    cardConfig.userName = self.config.userName;
    cardConfig.roomId = self.config.roomId;
    __weak typeof(self) weakSelf = self;
    // 邀请卡组件
    self.cardFunc = [[HDSInvitationCardFunc alloc] initCardFuncWithConfig:cardConfig closure:^(BOOL result, NSString * _Nullable message) {
        if (result) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf getCardConfig];
            });
        } else {
            [weakSelf showTipWithString:message];
        }
    }];
}
/// 获取开关配置
- (void)getCardConfig {
    __weak typeof(self) weakSelf = self;
    [self.cardFunc getInvitationConfig:^(BOOL result, NSString * _Nullable message) {
        if (!result) {
            
            [weakSelf showTipWithString:message];
        }
    } dataCallBack:^(BOOL result, HDSInvitationCardConfigModel * _Nullable configModel) {
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.configModel = configModel;
        });
    }];
}

/// 获取邀请卡列表
- (void)getCardList {
    __weak typeof(self) weakSelf = self;
    [self.cardFunc getInvitaionCardList:^(BOOL result, NSString * _Nullable message) {
        if (!result) {
            [weakSelf showTipWithString:message];
        }
    } dataCallBack:^(BOOL result, NSArray<HDSInvitationCardModel *> * _Nullable cardModel) {
        
        [weakSelf getCardSortUrl:cardModel];
    }];
}

- (void)getCardSortUrl:(NSArray<HDSInvitationCardModel *> *)cardModel {
    __weak typeof(self) weakSelf = self;
    [self.cardFunc getShortUrl:self.config.roomUrl closure:^(BOOL result, NSString * _Nullable message) {
        if (result) {
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.config.sortUrl = message;
                [weakSelf showCardListView:cardModel];
            });
        } else {
            [weakSelf showTipWithString:message];
        }
    }];
}

- (void)showCardListView:(NSArray<HDSInvitationCardModel *> *)cardModel {
    
    if (self.configModel == nil) {
        [self showTipWithString:@"邀请卡未准备好"];
        return;
    }
    __weak typeof(self) weakSelf = self;
    self.cardListView = [[HDSInvitaionCardList alloc] init];
    [self.cardListView longGesAction:^{
        [weakSelf showTipWithString:@"已保存到相册"];
    }];
    [self.cardListView setModel:cardModel :self.configModel : self.config];
    [APPDelegate.window addSubview:self.cardListView];
    
    [self.cardListView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(APPDelegate.window);
    }];
}

- (void)getInvitaionCardRank {
    __weak typeof(self) weakSelf = self;
    [self.cardFunc getInvitaionCardRank:^(BOOL result, NSString * _Nullable message) {
        if (!result) {
            [weakSelf showTipWithString:message];
        }
    } dataCallBack:^(BOOL result, NSArray<HDSInvitationCardRankModel *> * _Nullable rankModel) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf showCardRankView:rankModel];
        });
    }];
}

- (void)showCardRankView:(NSArray<HDSInvitationCardRankModel *> *)rankModel {
    self.cardRankView = [[HDSCardRankView alloc] init];
    [APPDelegate.window addSubview:self.cardRankView];
    __weak typeof(self) weakSelf = self;
    [self.cardRankView addBottomBlock:^{
        [weakSelf.cardRankView removeFromSuperview];
        [weakSelf getCardList];
    }];
    
    [self.cardRankView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(APPDelegate.window);
    }];
    [self.cardRankView setModel:rankModel];
}
// MARK: - 问卷
- (void)initQuestionModule {
    // 问卷组件配置项
    HDSQuestionnaireConfig *quesConfig = [[HDSQuestionnaireConfig alloc] init];
    quesConfig.token = self.config.token;
    quesConfig.userId = self.config.userId;
    quesConfig.userName = self.config.userName;
    quesConfig.roomId = self.config.roomId;
    __weak typeof(self) weakSelf = self;
    // 问卷组件
    self.quesFunc = [[HDSQuestionnaireFunc alloc] initQuestionnaireFuncWithConfig:quesConfig closure:^(BOOL result, NSString * _Nullable message) {
        if (result) {
            [weakSelf checkQuestionnaire];
        } else {
            [weakSelf showTipWithString:message];
        }
    }];
    self.quesFunc.delegate = self;
}

- (void)checkQuestionnaire {
    if (self.config.formCode != nil) {
        __weak typeof(self) weakSelf = self;
        [self.quesFunc getUserCode:^(BOOL result, NSString * _Nullable message) {
            if (result) {
                HDSQuestionnairePushQuery *model = [[HDSQuestionnairePushQuery alloc] init];
                model.formCode = weakSelf.config.formCode;
                model.userCode = message;
                if (HDSVoteTool.tool.isLandspace) {
                    weakSelf.quesModel = model;
                    [weakSelf showTipWithString:@"请切换至竖屏使用问卷功能"];
                    return;
                }
                [weakSelf getJoinQuestionnaireDetail:model];
            } else {
                [weakSelf showTipWithString:message];
            }
        }];
    }
}

- (void)streamDidEnd {
    if (self.quesModel.existence == 0 && self.config.sendMode == 2) {
        [self getQuestionnaireDetail:self.pushQuery];
    }
}

/// 获取问卷列表
- (void)getInvitaionQuestionnaireList {
    __weak typeof(self) weakSelf = self;
    [self.quesFunc getPushQuery:^(BOOL result, NSString * _Nullable message) {
        if (!result) {
            [weakSelf showTipWithString:message];
        }
    } dataCallBack:^(BOOL result, NSArray<HDSQuestionnairePushQuery *> * _Nullable pushQueryArray) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf showQuestionnaireHistoryListView:pushQueryArray];
        });
    }];
}
/// 显示问卷列表
- (void)showQuestionnaireHistoryListView:(NSArray<HDSQuestionnairePushQuery *> *)pushQueryArray {
    if (HDSVoteTool.tool.isLandspace) {
        return;
    }
    if (_quesListView) {
        [self.quesListView removeFromSuperview];
    }
    NSMutableArray *pushQueryArrayMut = pushQueryArray.mutableCopy;
    if (self.pushQuery) {
        if (pushQueryArray.count) {
            [pushQueryArrayMut insertObject:self.pushQuery atIndex:0];
        } else {
            [pushQueryArrayMut addObject:self.pushQuery];
        }
    }
    self.quesListView = [[HDSQuestionnaireHistoryList alloc] init];
    [APPDelegate.window addSubview:self.quesListView];
    
    [self.quesListView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(APPDelegate.window);
    }];
    __weak typeof(self) weakSelf = self;
    [self.quesListView setModelArr:pushQueryArrayMut :^(HDSQuestionnairePushQuery * _Nonnull model) {
        [weakSelf getQuestionnaireDetail:model];
    }];
}
/// 获取问卷详情
- (void)getQuestionnaireDetail:(HDSQuestionnairePushQuery *)model {
    __weak typeof(self) weakSelf = self;
    [self.quesFunc getFormsQueryDetail:model.userCode formCode:model.formCode closure:^(BOOL result, NSString * _Nullable message) {
        if (!result) {
            [weakSelf showTipWithString:message];
        }
    } dataCallBack:^(BOOL result, HDSQuestionnaireQueryDetail * _Nullable pushQueryDetail) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (pushQueryDetail.valiad == 1) {
                if ([pushQueryDetail.formCode isEqualToString:self.config.formCode]) {
                    
                    [weakSelf getExistence:pushQueryDetail];
                }
                [weakSelf showQuestionnaireDetailView:pushQueryDetail];
            } else {
                [weakSelf showTipWithString:@"问卷不可用"];
            }
        });
    }];
}

/// 获取问卷详情1
- (void)getJoinQuestionnaireDetail:(HDSQuestionnairePushQuery *)model {
    __weak typeof(self) weakSelf = self;
    [self.quesFunc getFormsQueryDetail:model.userCode formCode:model.formCode closure:^(BOOL result, NSString * _Nullable message) {
        if (!result) {
            [weakSelf showTipWithString:message];
        }
    } dataCallBack:^(BOOL result, HDSQuestionnaireQueryDetail * _Nullable pushQueryDetail) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (pushQueryDetail.valiad == 1) {
                [weakSelf getExistence:pushQueryDetail];
                // 0:手动推送  1:进入直播时  2:直播结束时
                if (weakSelf.config.sendMode == 1) {
                    [weakSelf showQuestionnaireDetailView:pushQueryDetail];
                }
            }
        });
    }];
}

- (void)getExistence:(HDSQuestionnaireQueryDetail * _Nullable)pushQueryDetail {
    __weak typeof(self) weakSelf = self;
    [self.quesFunc getExistence:self.config.activityCode formCode:pushQueryDetail.formCode closure:^(BOOL result, NSString * _Nullable message) {
        if (result) {
            /// 需要生成list数据
            weakSelf.pushQuery = [[HDSQuestionnairePushQuery alloc] init];
            weakSelf.pushQuery.formCode = pushQueryDetail.formCode;
            weakSelf.pushQuery.userCode = pushQueryDetail.userCode;
            weakSelf.pushQuery.formPushDate = [self getDateStringWithTimeStr:[NSString stringWithFormat:@"%.0f",[[NSDate date] timeIntervalSince1970] * 1000]];
            weakSelf.pushQuery.formName = pushQueryDetail.formName;
            weakSelf.pushQuery.existence = [message integerValue];
        }
    }];
}

// 时间戳转时间,时间戳为13位是精确到毫秒的，10位精确到秒
- (NSString *)getDateStringWithTimeStr:(NSString *)str{
    NSTimeInterval time = [str doubleValue] / 1000;//传入的时间戳str如果是精确到毫秒的记得要/1000
    NSDate *detailDate=[NSDate dateWithTimeIntervalSince1970:time];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init]; //实例化一个NSDateFormatter对象
    //设定时间格式,这里可以设置成自己需要的格式
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *currentDateStr = [dateFormatter stringFromDate: detailDate];
    return currentDateStr;
}

/// 显示问卷详情
- (void)showQuestionnaireDetailView:(HDSQuestionnaireQueryDetail *)detailModel {
    self.quesModel = nil;
    if (HDSVoteTool.tool.isLandspace) {
        return;
    }
    self.detailView = [[HDSQuestionnaireDetailView alloc] init];
    self.detailView.quesFunc = self.quesFunc;
    self.detailView.vc = self.config.rootVC;
    [APPDelegate.window addSubview:self.detailView];
    
    [self.detailView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(APPDelegate.window);
    }];
    [self.detailView setModel:detailModel];
    __weak typeof(self) weakSelf = self;
    [self.detailView setTipsCallBack:^(NSString * _Nullable tips) {
        [weakSelf showTipWithString:tips];
    }];
    [self.detailView setNavBackCallBack:^(NSString * _Nullable message) {
        [weakSelf.detailView removeFromSuperview];
        weakSelf.detailView = nil;
    }];
    [self.detailView setCloseCallBack:^(NSString * _Nullable message) {
        [weakSelf.detailView removeFromSuperview];
        weakSelf.detailView = nil;
    }];
    [self.detailView setSubmitCallBack:^(NSString * _Nullable message) {
        if ([weakSelf.pushQuery.formCode isEqualToString:message]) {
            weakSelf.pushQuery.existence = 1;            
        }
        [weakSelf getInvitaionQuestionnaireList];
    }];
}
// MARK: - 收到问卷消息
- (void)onFormPush:(HDSQuestionnairePushQuery *)model {
    if (model != nil) {
        if (HDSVoteTool.tool.isLandspace) {
            self.quesModel = model;
            [self showTipWithString:@"请切换至竖屏使用问卷功能"];
            return;
        }
        [self getQuestionnaireDetail:model];
    }
}

#pragma mark - 将某个时间Str转化成 时间戳
- (NSTimeInterval)timeSwitchTimestamp:(NSString *)formatTime andFormatter:(NSString *)format {
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:format];  //（@"YYYY-MM-dd hh:mm:ss"）----------注意>hh为12小时制,HH为24小时制
    
    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/Beijing"];
    [formatter setTimeZone:timeZone];
    
    NSDate* date = [formatter dateFromString:formatTime];
    NSTimeInterval timeSp = [date timeIntervalSince1970];
    return timeSp;
}

// MARK: - HDSRedEnvelopeFuncDelegate
// 红包雨socket消息
- (void)onRedEnvelopeEventWithMessage:(HDSRedEnvelopeModel *)message {
    if (HDSVoteTool.tool.isLandspace) {
        [self showTipWithString:@"请切换至竖屏使用红包功能"];
        if (message.redStatus == 3) {
            self.redActioveId = message.redActivityId;
        } else {
            self.redActioveId = nil;
        }
        return;
    }
    if (message.redStatus == 3) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (HDSVoteTool.tool.isLandspace) {
                [self showTipWithString:@"请切换至竖屏使用红包功能"];
                return;
            }
            [self startRed:message.redActivityId];
        });
        
    } else {
        self.redActiveId = message.redActivityId;
        // 结束
        [HDSRedPacketRainEngine.shared stopRedRacketRain];
    }
}

- (void)onRedEnvelopeCustomStyle:(HDSRedEnvelopeStyleModel *)model {
    self.rankBackgroundUrl = model.rankBackgroundUrl;
    self.driftDownUrls = model.driftDownUrls;
}

// MARK: - 礼物组件

/// 展示礼物列表
- (void)showGiftList {

    if (self.giftListArray.count == 0) {

        NSString *tipStr = [NSString stringWithFormat:@"礼物列表数据未准备完成"];
        [self showTipWithString:tipStr];
        return;
    }
    // 礼物列表
    self.gsVC = [[HDSGiftSelectViewController alloc] initWithGiftArray:self.giftListArray];
    self.gsVC.delegate = self;
    [self.config.rootVC addChildViewController:self.gsVC];
    if (_config.boardView) {
        self.gsVC.view.frame = CGRectMake(0, HDGetRealHeight + SCREEN_STATUS, self.config.boardView.frame.size.width, self.config.boardView.frame.size.height - HDGetRealHeight - SCREEN_STATUS);
        [self.config.boardView addSubview:self.gsVC.view];
    } else {
        self.gsVC.view.frame = CGRectMake(0, HDGetRealHeight + SCREEN_STATUS, self.config.rootVC.view.frame.size.width, self.config.rootVC.view.frame.size.height - HDGetRealHeight - SCREEN_STATUS);
        [self.config.rootVC.view addSubview:self.gsVC.view];
    }
}

// 点击礼物关闭按钮
- (void)hdsGiftSelectViewControllerDidCancel {
     
    self.gsVC.delegate = nil;
    self.gsVC = nil;
}

/// 选中的礼物
/// @param gift 礼物
/// @param count 个数
- (void)hdsGiftSelectViewControllerDidDonateWithGift:(HDSGiftListSingleModel * _Nonnull)gift count:(NSInteger)count {
     
    self.gsVC.delegate = nil;
    self.gsVC = nil;
    
    if (count > 99) {
        [self showTipWithString:@"礼物数量不能大于99"];
        return;
    }
    
    // 发送点赞
    HDSSendSingleGiftModel *sendSingleModel = [[HDSSendSingleGiftModel alloc]init];
    sendSingleModel.giftNum = count;
    sendSingleModel.giftId = gift.giftId;
    sendSingleModel.giftType = 1;
     
    [self.giftFunc sendGiftActionWithGift:sendSingleModel closure:^(BOOL result, NSString * _Nullable message) {
        if (result) {
             
        }else {
             
            NSString *tipStr = [NSString stringWithFormat:@"发送礼物失败 -->:%@",message];
            [self showTipWithString:tipStr];
        }
    }];
    
    HDSReceivedGiftModel *oneModel = [[HDSReceivedGiftModel alloc]init];
    oneModel.fromUser = self.config.userName;
    oneModel.fromUserId = self.config.userId;
    oneModel.avatar = @"";
    oneModel.giftImg = gift.giftThumbnail;
    oneModel.giftName = gift.giftName;
    oneModel.giftNum = count;
    [self showReceivedGiftWithModel:oneModel isMine:YES];
}

// MARK: - 礼物组件
/// 初始化礼物组件
- (void)initGiftModule {

    self.sgVC = [[HDSGiftShowViewController alloc] init];
    if (self.config.giftSpecialEffects != 0) {
        self.sgVC.bornFromLeftSide = self.config.giftSpecialEffects == 1 ? true : false;
    }
    if (self.config.giftSpecialEffects != 0) {
        self.sgVC.playLimitCount = self.config.giftSpecialEffects == 1 ? 50 : 10;
    }
    self.sgVC.view.userInteractionEnabled = NO;
    [self.config.rootVC addChildViewController:self.sgVC];
    if (_config.boardView) {
        self.sgVC.view.frame = CGRectMake(10, HDGetRealHeight + SCREEN_STATUS, self.config.boardView.frame.size.width - 20, self.config.boardView.frame.size.height - HDGetRealHeight - SCREEN_STATUS);
        [self.config.boardView addSubview:self.sgVC.view];
    } else {
        self.sgVC.view.frame = CGRectMake(10, HDGetRealHeight + SCREEN_STATUS, self.config.rootVC.view.frame.size.width - 20, self.config.rootVC.view.frame.size.height - HDGetRealHeight - SCREEN_STATUS);
        [self.config.rootVC.view addSubview:self.sgVC.view];
    }
    
     
    // 配置项
    self.giftConfig = [[HDSGiftFuncConfig alloc]init];
    self.giftConfig.token = self.config.token;
    self.giftConfig.userId = self.config.userId;
    self.giftConfig.userName = self.config.userName;
    self.giftConfig.roomId = self.config.roomId;

    // 礼物组件
    self.giftFunc = [[HDSGiftFunc alloc]initGiftFuncWithConfig:self.giftConfig closure:^(BOOL result, NSString * _Nullable message) {
        if (result) {
             
            [self getHistorcalGiftRecords];
            [self getGiftListWithCurrentPage:self.currentPage pageSize:self.onePageSize];
        }else {
             
            NSString *tipStr = [NSString stringWithFormat:@"礼物初始化失败，礼物功能不可用 -->:%@",message];
            [self showTipWithString:tipStr];
        }
    }];
    self.giftFunc.delegate = self;
}

/// 获取历史礼物记录
- (void)getHistorcalGiftRecords {
     
    [self.giftFunc getHistoricalGiftRecordsWithClosure:^(BOOL result, NSString * _Nullable message) {
        NSString *str = @"";
        if (result) {
     
            str = @"成功   ";
        }else {
     
            NSString *tipStr = [NSString stringWithFormat:@"获取历史礼物记录失败 -->:%@",message];
            str = [NSString stringWithFormat:@"失败    %@",message];
            [self showTipWithString:tipStr];
        }
    }];
}

/// 获取礼物列表
- (void)getGiftListWithCurrentPage:(NSInteger)page pageSize:(NSInteger)pageSize {
     
    [self.giftFunc getGiftListWithPageNum:page pageSize:pageSize closure:^(BOOL result, NSString * _Nullable message) {
        if (result) {
     
        }else {
     
            NSString *tipStr = [NSString stringWithFormat:@"获取礼物列表失败 -->:%@",message];
            [self showTipWithString:tipStr];
        }
    }];
}

- (void)showReceivedGiftWithModel:(HDSReceivedGiftModel *)model isMine:(BOOL)isMine {
    if (self.config.giftSpecialEffects == 0) {
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.sgVC != nil) {
            if (isMine == YES) {
                [self.sgVC addMineGiftOCWithGift:model];
            }else {
                [self.sgVC addNewGiftOCWithGift:model];
            }
        }
    });
}

- (NSMutableArray *)giftListArray {
    if (!_giftListArray) {
        _giftListArray = [NSMutableArray array];
    }
    return _giftListArray;
}


// MARK: - Gift Delegate

/// 礼物历史记录
/// @param giftRecords 历史记录
- (void)onHistoricalGiftRecords:(NSArray *)giftRecords {
     
}

/// 礼物列表
/// @param listModel 礼物数据
- (void)onGiftListModel:(HDSGiftListModel *)listModel {
     
    [self.giftListArray addObjectsFromArray:listModel.giftList];
    NSInteger kValue = listModel.total / self.onePageSize;
    
    if (kValue < self.currentPage) {
        return;
    }
    
    self.currentPage++;
    [self getGiftListWithCurrentPage:self.currentPage pageSize:self.onePageSize];

}

/// 收到礼物消息
/// @param message 礼物消息
- (void)onGiftEventWithMessage:(HDSReceivedGiftModel *)message {
     
    if (![message.fromUserId isEqualToString:self.config.userId]) {
        [self showReceivedGiftWithModel:message isMine:NO];
    }
}

// MARK: - 直播带货
- (void)initLiveStoreModule {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showLiveStore:) name:HDS_Show_Live_Store_Item_List_Notification object:nil];
    
    self.liveStoreFuncConfig = [[HDSLiveStoreFuncConfig alloc]init];
    self.liveStoreFuncConfig.token = self.config.token;
    self.liveStoreFuncConfig.userId = self.config.appid;
    self.liveStoreFuncConfig.userName = self.config.userName;
    self.liveStoreFuncConfig.roomId = self.config.roomId;
    self.liveStoreFuncConfig.viewerId = self.config.userId;
    self.liveStoreFuncConfig.sourceType = SourceTypeLive;
    self.liveStoreFuncConfig.sourceSDKVersion = self.config.sdkVersion;
    self.liveStoreFuncConfig.uuid = [self checkString:[HDUniversalUtils uniqueMark]];
    __weak typeof(self) weakSelf = self;
    self.liveStoreFunc = [[HDSLiveStoreFunc alloc]initLiveStoreFuncWithConfig:self.liveStoreFuncConfig closure:^(BOOL result, NSString * _Nullable message) {
        
        if (result) {
            if ([NSThread mainThread]) {
                [weakSelf checkShowCurrentPushingItem];
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf checkShowCurrentPushingItem];
                });
            }
        }
    }];
    self.liveStoreFunc.delegate = self;
}

- (void)showLiveStore:(NSNotification *)noti {
    if (_liveStoreFunc) {
        [self liveStoreButtonAction];
    }
}

- (void)checkShowCurrentPushingItem {
    for (NSDictionary *dic in self.config.interactionArr) {
        NSInteger type = [dic[@"type"] integerValue];
        if (type == 8) {
            [self getPushingItem:dic[@"id"]];
            self.storeItemId = dic[@"id"];
            if (HDSVoteTool.tool.isLandspace) {
                self.liveStore_pushingItemID = dic[@"id"];
            }
            break;
        }
    }
}

- (void)getPushingItem:(NSString *)itemId {
    __weak typeof(self) weakSelf = self;
    
    [self.liveStoreFunc getPushingItem:itemId closure:^(BOOL result, NSString * _Nullable message) {
    
    } pushingItem:^(HDSPushItemModel * _Nonnull model) {
    
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.pushItemModel = model;
            [weakSelf showGoodAlertView];
        });
    }];
}

- (void)getLiveStoreItemList:(NSInteger)pageNum pageSize:(NSInteger)pageSize {
    
    __weak typeof(self) weakSelf = self;
    [self.liveStoreFunc getItemList:pageNum pageSize:pageSize closure:^(BOOL result, NSString * _Nullable message) {
    
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.goodListView endRefreshing];
        });
    } itemsModel:^(HDSItemListModel * _Nonnull model) {
    
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.goodListView endRefreshing];
            [weakSelf showGoodListView:model];
        });
    }];
}

- (void)getLiveStoreItemLink:(NSString *)itemId itemType:(ItemType)itemType isGotoSafari:(BOOL)isGotoSafari {
    __weak typeof(self) weakSelf = self;
    
    [self.liveStoreFunc getItemLink:itemId itemType:itemType closure:^(BOOL result, NSString * _Nullable message) {
    
        if (result == NO) {
            [weakSelf showTipWithString:message];
        }
    } itemLinkModel:^(HDSItemLinkModel * _Nonnull model) {
    
        weakSelf.itemLinkModel = model;
        if (isGotoSafari) {
            [weakSelf gotoSafariWithLink:model.link];
        }
    }];
}

// MARK: Live Store Delegate
- (void)onPushItem:(HDSPushItemModel *)model {
    
    self.pushItemModel = model;
    self.storeItemId = model.id;
    [self showGoodAlertView];
}

- (void)onCancelPushingItem:(HDSCancelPushItemModel *)model {
    
    _itemLinkModel = nil;
    _pushItemModel = nil;
    if (_goodAlertView) {
        [_goodAlertView removeFromSuperview];
        _goodAlertView = nil;
    }
}

//MARK: - 直播带货
- (HDSLiveGoodListView *)goodListView {
    if (!_goodListView) {
        CGFloat height = HDGetRealHeight;
        if (IS_IPHONE_X) {
            height += 44;
        } else {
            height += 20;
        }
        _goodListView = [[HDSLiveGoodListView alloc] initWithFrame:CGRectZero topHeight:height];
        [_goodListView setupDelegateWithDelegate:self];
    }
    return _goodListView;
}

- (void)showGoodListView:(HDSItemListModel * _Nonnull)model {
    if (HDSVoteTool.tool.isLandspace) {
        return;
    }
    [APPDelegate.window addSubview:self.goodListView];
    [self.goodListView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(APPDelegate.window);
    }];
    [self.goodListView showViewWithModel:model];
}

- (HDSGoodAlertView *)goodAlertView {
    if (!_goodAlertView) {
        _goodAlertView = [[HDSGoodAlertView alloc] init];
        _goodAlertView.backgroundColor = UIColor.clearColor;
        [_goodAlertView setupDelegateWithDelegate:self];
    }
    return _goodAlertView;
}

- (void)showGoodAlertView {
    
    if (HDSVoteTool.tool.isLandspace || _isKillAll) {
        return;
    }
    if (_goodListView) {
        [APPDelegate.window insertSubview:self.goodAlertView belowSubview:self.goodListView];
    } else {
        [APPDelegate.window addSubview:self.goodAlertView];
    }
    CGFloat offset = IS_IPHONE_X ? -93 : -55;
    [self.goodAlertView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(APPDelegate.window).offset(offset);
        make.right.equalTo(APPDelegate.window).offset(-65);
        make.width.mas_equalTo(125);
        make.height.mas_equalTo(191);
    }];
    [self.goodAlertView setupModelWithModel:self.pushItemModel];
    [APPDelegate.window layoutIfNeeded];
    // 阴影颜色
    self.goodAlertView.layer.shadowColor = [UIColor colorWithHexString:@"#000000" alpha:1].CGColor;
    // 阴影偏移，默认(0, -3)
    self.goodAlertView.layer.shadowOffset = CGSizeMake(0, 3);
    // 阴影透明度，默认0.7
    self.goodAlertView.layer.shadowOpacity = 0.2f;
    // 阴影半径，默认3
    self.goodAlertView.layer.shadowRadius = 2.5;
}

//MARK: HDSGoodAlertViewDelegate
- (void)goodAlertViewCloseAction {
    if (_goodAlertView) {
        [_goodAlertView removeFromSuperview];
        _goodAlertView = nil;
        _pushItemModel = nil;
    }
}

- (void)goodAlertViewBuyTapAction {
    [self getLiveStoreItemLink:self.storeItemId itemType:ItemTypeFuchuang isGotoSafari:YES];
}

//MARK: HDSLiveGoodListViewDelegate
- (void)liveGoodListRefreshData {
    [self getLiveStoreItemList:1 pageSize:10];
}

- (void)liveGoodListLoadMoreDataWithCurPage:(NSInteger)curPage {
    [self getLiveStoreItemList:curPage + 1 pageSize:10];
}

- (void)liveGoodListCloseAction {
    if (_goodListView) {
        [_goodListView removeFromSuperview];
        _goodListView = nil;
    }
}

- (void)liveGoodListCellBuyActionWithItemid:(NSString *)itemid {
    [self getLiveStoreItemLink:itemid itemType:ItemTypeList isGotoSafari:YES];
}

- (void)liveGoodListCellBuyActionCallBackLinkWithLink:(NSString *)link {
    [self gotoSafariWithLink:link];
}

- (void)gotoSafariWithLink:(NSString *)link {
    NSURL *url = [NSURL URLWithString:link];
    if (url == nil) {
        [self showTipWithString:@"链接不能为空"];
    }
    //@{UIApplicationOpenURLOptionUniversalLinksOnly : @YES}
    [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:^(BOOL success) {
        
    }];
}

/** 检查参数 */
- (NSString *)checkString:(id)value
{
    if ([value isKindOfClass:[NSNull class]])
    {
        value = @"";
    }
    return value;
}
@end
