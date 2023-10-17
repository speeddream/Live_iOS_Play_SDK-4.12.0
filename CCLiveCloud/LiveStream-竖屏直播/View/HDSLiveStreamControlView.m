//
//  HDSLiveStreamControlView.m
//  CCLiveCloud
//
//  Created by Apple on 2022/12/15.
//  Copyright © 2022 MacBook Pro. All rights reserved.
//

#import "HDSLiveStreamControlView.h"
#import "HDSLiveStreamInfosView.h"
#import "HDSLiveStreamAnnouncementView.h"
#import "HDSLiveStreamCountDownView.h"
#import "HDSLiveStreamRemindView.h"
#import "HDSLiveBottomBar.h"
#import "HDSLiveChatView.h"
#import "CCChatContentView.h"
#import "HDSAnnouncementView.h"
#import "HDSIntroductionView.h"
#import "HDSMoreToolView.h"
#import "HDSStreamLineAndQualityView.h"
#import "HDSLiveStreamTopChatView.h"

#import "CCSDK/PlayParameter.h"
#import "HDSSafeArray.h"
#import "HDSMoreToolItemModel.h"
#import "HDSSteamLineAndQualityModel.h"
#import "UIColor+RCColor.h"
#import "CCcommonDefine.h"
#import "UIImageView+Extension.h"
#import "UIView+Extension.h"
#import <Masonry/Masonry.h>

typedef NS_ENUM(NSUInteger, HDSRoomLiveStatusType) {
    RoomLiveStatusType_NoBeginLive, //未开始
    RoomLiveStatusType_Liveing, //直播中
    RoomLiveStatusType_EndLived, //已结束
    RoomLiveStatusType_Other, //其他状态
};

@interface HDSLiveStreamControlView ()<CCChatContentViewDelegate,HDSLiveChatViewDelegate>

// MARK: - 关闭按钮
/// 关闭按钮
@property (nonatomic, strong) UIButton *closeBtn;
/// 关闭按钮回调
@property (nonatomic, copy)   closeBtnClosure closeClosure;

// MARK: - 房间基础信息
/// 房间基础信息视图
@property (nonatomic, strong) HDSLiveStreamInfosView *infosView;
/// 房间icon
@property (nonatomic, copy)   NSString *roomIcon;
/// 房间在线人数
@property (nonatomic, copy)   NSString *roomOnlineUserCount;
/// 房间是否展示在线人数
@property (nonatomic, assign) BOOL showUserCount;
/// roomInfo
@property (nonatomic, strong) NSDictionary *roomInfo;
/// 直播状态
@property (nonatomic, assign) HDSRoomLiveStatusType liveStatusType;

// MARK: - 公告
/// 公告滚动视图
@property (nonatomic, strong) HDSLiveStreamAnnouncementView *announcementView;
/// 房间公告弹窗视图
@property (nonatomic, strong) HDSAnnouncementView *announcementWindowView;
/// 房间公告信息String
@property (nonatomic, copy)   NSString *roomAnnouncement;

// MARK: - 倒计时
/// 倒计时视图
@property (nonatomic, strong) HDSLiveStreamCountDownView *countDownView;
/// 房间是否展示未开播前倒计时
@property (nonatomic, assign) BOOL openLiveCountDown;
/// 倒计时时长
@property (nonatomic, assign) NSTimeInterval countDownDuration;

// MARK: - 进入房间提醒
/// 进出房间提醒视图
@property (nonatomic, strong) HDSLiveStreamRemindView *remindView;
/// 进入房间提醒数组
@property (nonatomic, strong) HDSSafeArray *remindDataArray;
/// 是否展示用户进出提醒视图
@property (nonatomic, assign) BOOL isShowRemindView;

// MARK: - 聊天
/// 底部工具栏
@property (nonatomic, strong) HDSLiveBottomBar *bottomBar;
/// 聊天区
@property (nonatomic, strong) HDSLiveChatView *chatView;
/// 输入框
@property (nonatomic, strong) CCChatContentView *inputView;
/// 房间是否有聊天模板
@property (nonatomic, assign) BOOL isChatView;
/// 聊天视图高度
@property (nonatomic, assign) CGFloat chatViewH;

// MARK: - 简介
/// 房间简介
@property (nonatomic, strong) HDSIntroductionView *introductionView;

// MARK: - 更多工具视图
/// 更多工具视图
@property (nonatomic, strong) HDSMoreToolView *moreToolView;
/// 更多工具视图数组
@property (nonatomic, strong) NSMutableArray *moreItemArray;
/// 是否展示更多视图线路item
@property (nonatomic, assign) BOOL isShowMoreToolLine;
/// 是否展示更多视图清晰度item
@property (nonatomic, assign) BOOL isShowMoreToolQuailty;

// MARK: - 切换线路&清晰度
/// 切换线路视图
@property (nonatomic, strong) HDSStreamLineAndQualityView *videoLineView;
/// 房间线路数组
@property (nonatomic, strong) NSMutableArray *linesArray;
/// 切换清晰度视图
@property (nonatomic, strong) HDSStreamLineAndQualityView *videoQualityView;
/// 清晰度数组
@property (nonatomic, strong) NSMutableArray *qualityArray;

// MARK: - 播放器背景图及提示语
/// 播放器背景图
@property (nonatomic, strong) UIImageView *playerBGIMG;
/// 播放器背景视图地址
@property (nonatomic, copy)   NSString *playerBGUrl;
/// 播放器背景提示Label （未设置背景图，倒计时，播放器提示语，展示 "直播未开始"或"直播已结束"）
@property (nonatomic, strong) UILabel *playerBGLabel;
/// 播放器提示语
@property (nonatomic, strong) NSString *playerBackgroundHint;
/// 底部图片（没有播放器背景图时展示）
@property (nonatomic, strong) UIImageView *bottomIMGView;
/// 阴影视图，有播放器背景视图且有播放器提示语展示
@property (nonatomic, strong) UIView *shadowView;

// MARK: - 清屏
/// 清屏背景
@property (nonatomic, strong) UIView *cleanBGView;
/// 清屏图片
@property (nonatomic, strong) UIImageView *cleanIMGView;
/// 清屏文字
@property (nonatomic, strong) UILabel *cleanLabel;
/// 清屏按钮
@property (nonatomic, strong) UIButton *cleanBtn;

@property (nonatomic, assign) BOOL isFirstClean;

// MARK: - 聊天置顶
/// 聊天置顶
@property (nonatomic, strong) HDSLiveStreamTopChatView *topChatView;
/// 置顶聊天数组
@property (nonatomic, strong) NSMutableArray *topChatArray;

@property (nonatomic, assign)NSInteger                  showShadowCountFlag;// 文档手势冲突 获取屏幕点击回调 计数Flag


/// 3.18.0 new 录屏视图
@property (nonatomic, strong) UIView                    *screenCaptureView;

@end

@implementation HDSLiveStreamControlView

- (instancetype)initWithFrame:(CGRect)frame closeBtnAction:(nonnull closeBtnClosure)closure {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor colorWithHexString:@"#000000" alpha:0];
        if (closure) {
            _closeClosure = closure;
        }
        [self configureUI];
        [self configureConstraints];
        [self configureData];
        self.remindDataArray = [[HDSSafeArray alloc]init];
        if (@available(iOS 11.0, *)) {
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(screenCapture)
                                                         name:UIScreenCapturedDidChangeNotification
                                                       object:nil];
        }
    }
    return self;
}

/// 直播带货开关
/// - Parameter liveStoreSwitch: 是否有直播带货功能
- (void)setLiveStoreSwitch:(NSInteger)liveStoreSwitch {
    _liveStoreSwitch = liveStoreSwitch;
    if (_bottomBar) {
        _bottomBar.liveStoreSwitch = liveStoreSwitch;
    }
}

- (void)setViewerId:(NSString *)viewerId {
    _viewerId = viewerId;
    if (_topChatView) {
        _topChatView.viewerId = _viewerId;
    }
}

/// 房间信息
/// - Parameter dict: 房间信息
- (void)roomInfo:(NSDictionary *)dic {
    _infosView.hidden = NO;
    _roomInfo = dic;
    NSString *desc = @"";
    NSString *roomName = @"";
    // 房间名
    if ([dic.allKeys containsObject:@"name"]) {
        roomName = dic[@"name"];
        if (roomName.length == 0) {
            if ([dic.allKeys containsObject:@"baseRecordInfo"]) {
                NSDictionary *baseRecordInfo = dic[@"baseRecordInfo"];
                if ([baseRecordInfo.allKeys containsObject:@"title"]) {
                    roomName = baseRecordInfo[@"title"];
                }
            }
        }
    }
    // 简介
    if ([dic.allKeys containsObject:@"desc"]) {
        desc = dic[@"desc"];
        if (desc.length == 0) {
            if ([dic.allKeys containsObject:@"baseRecordInfo"]) {
                NSDictionary *baseRecordInfo = dic[@"baseRecordInfo"];
                if ([baseRecordInfo.allKeys containsObject:@"description"]) {
                    desc = baseRecordInfo[@"description"];
                }
            }
        }
    }
    if (desc.length == 0) {
        desc = @"暂无简介";
    }
    
    // 是否展示房间人数
    if ([dic.allKeys containsObject:@"showUserCount"]) {
        self.showUserCount = [dic[@"showUserCount"] boolValue];
        [self updateRoomInfos];
    }
    
    // 是否展示倒计时
    if ([dic.allKeys containsObject:@"openLiveCountdown"]) {
        self.openLiveCountDown = [dic[@"openLiveCountdown"] boolValue];
    }
    
    // 播放器背景图
    if ([dic.allKeys containsObject:@"playerBackgroundImageUri"]) {
        self.playerBGUrl = dic[@"playerBackgroundImageUri"];
    }
    
    // 播放器提示语
    if ([dic.allKeys containsObject:@"playerBackgroundHint"]) {
        self.playerBackgroundHint = dic[@"playerBackgroundHint"];
    }
    
    // 直播倒计时
    if (self.openLiveCountDown == YES) {
        if ([dic.allKeys containsObject:@"liveStartTime"]) {
            NSString *live_start_time_str = [NSString stringWithFormat:@"%@", dic[@"liveStartTime"]];
            NSTimeInterval liveStartTime = [self timeWithStr:live_start_time_str];
            NSString *timeStr = [NSString stringWithFormat:@"%ld",(long)liveStartTime];
            NSInteger timeStrInt = [timeStr integerValue];
            self.countDownDuration = timeStrInt;
        }
    }
    
    // 房间是否开启多清晰度
    if ([dic.allKeys containsObject:@"multiQuality"]) {
        BOOL multiQuality = [dic[@"multiQuality"] boolValue];
        self.isShowMoreToolQuailty = multiQuality;
    }

    // 是否有聊天功能
    if ([dic.allKeys containsObject:@"templateType"]) {
        NSInteger templateType = [dic[@"templateType"] integerValue];
        __weak typeof(self) weakSelf = self;
        if (templateType != 1 && templateType != 6) {
            _isChatView = YES;
            CGFloat userRemindViewWidth = 215 * SCREEN_WIDTH / 375;
            [_remindView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.bottom.mas_equalTo(weakSelf.topChatView.mas_top).offset(-4);
                make.left.mas_equalTo(weakSelf).offset(15);
                make.width.mas_equalTo(userRemindViewWidth);
                make.height.mas_equalTo(58);
            }];
            [_remindView layoutIfNeeded];
        }else {
            _isChatView = NO;
            CGFloat userRemindViewWidth = 215 * SCREEN_WIDTH / 375;
            CGFloat remindViewMargin = (12 + (IS_IPHONE_X ? 83 : 49))  * SCREEN_WIDTH / 375;
            [_remindView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(weakSelf).offset(15);
                make.width.mas_equalTo(userRemindViewWidth);
                make.height.mas_equalTo(58);
                make.bottom.mas_equalTo(weakSelf).offset(-remindViewMargin);
            }];
            [_remindView layoutIfNeeded];
        }
        // 隐藏或展示聊天视图
        _chatView.hidden = !_isChatView;
        _inputView.hidden = !_isChatView;
        if (_bottomBar) {
            _bottomBar.isChatSwitch = _isChatView;
        }
    }
    if (_introductionView) {
        [_introductionView roomInfo:dic];
    }
    [self setRoomTitleWithName:roomName];
    
    [self updateRoomBaseInformationsStatus];
}

/// 设置房间icon
/// - Parameter url: 头像地址
- (void)setHomeIconWithUrl:(NSString *)url {
    self.roomIcon = url;
    if (_infosView) {
        [self updateRoomInfos];
        [_infosView setHeaderIconWithUrl:url];
    }
    if (_introductionView) {
        [self.introductionView setHomeIconWithUrl:self.roomIcon];
    }
}

/// 设置房间标题
/// - Parameter name: 标题
- (void)setRoomTitleWithName:(NSString *)name {
    if (_infosView) {
        [_infosView setMainTitleWithName:name];
    }
}

/// 房间历史公告
/// - Parameter announcement: 公告信息
- (void)setHomeHistoryAnnouncement:(NSString *)announcement {
    _roomAnnouncement = announcement;
    [self setRoomAnnouncementText:_roomAnnouncement];
}

/// 接收到新的公告信息
/// - Parameter dict: 公告信息
- (void)receiveNewAnnouncement:(NSDictionary *)dict {
    if ([dict.allKeys containsObject:@"action"]) {
        if([dict[@"action"] isEqualToString:@"release"]) {
            if ([dict.allKeys containsObject:@"announcement"]) {
                _roomAnnouncement = dict[@"announcement"];
            }
        } else if([dict[@"action"] isEqualToString:@"remove"]) {
            _roomAnnouncement = @"";
        }
    }
    
    [self setRoomAnnouncementText:_roomAnnouncement];
    
    // 更新弹窗公告
    if (_announcementWindowView && _announcementView.frame.origin.y != SCREEN_HEIGHT) {
        [_announcementWindowView updateViews:_roomAnnouncement];
    }
}

/// 设置房间人数
/// - Parameter count: 人数
- (void)setRoomOnlineUserCountWithCount:(NSString *)count {
    self.roomOnlineUserCount = count;
    if (_infosView) {
        [self updateRoomInfos];
        [_infosView setUserCountWithCount:count];
    }
    
    if (_introductionView) {
        [self.introductionView setRoomOnlineUserCountWithCount:_roomOnlineUserCount];
    }
}

/// 设置房间公告
/// - Parameter announcementText: 公告信息
- (void)setRoomAnnouncementText:(NSString *)announcementText {
    if (announcementText.length == 0) {
        _announcementView.hidden = YES;
    } else {
        _announcementView.hidden = NO;
        [_announcementView setAnnouncementText:announcementText];
    }
}

/// 设置倒计时
/// - Parameter countDown: 倒计时时间
- (void)setLiveStartCountDown:(NSString *)countDown {
    NSInteger countDownInt = [countDown integerValue];
    if (countDownInt <= 0) {
        _countDownView.hidden = YES;
        return;
    }
    [_countDownView setCountDown:countDown type:HDSLiveStreamCountDownViewTypeBottom];
}

/// 设置用户进入房间提醒
/// - Parameter model: 用户数据
- (void)setUserRemindWithModel:(RemindModel *)model {
    
    __weak typeof(self) weakSelf = self;
    dispatch_queue_t queue = dispatch_queue_create(0, 0);
    dispatch_async(queue, ^{
        // 数组中最多保留10条数据
        if (weakSelf.remindDataArray.count >= 10) {
            // 大于10条后移除最早之前的一条
            [weakSelf.remindDataArray removeObjectAtIndex:0];
            // 3.添加最新的一条数据
            [weakSelf.remindDataArray addObject:model];
        }else {
            [weakSelf.remindDataArray addObject:model];
        }
        // 空数组return
        if (weakSelf.remindDataArray.count == 0) {
           return;
        }
        if (weakSelf.isShowRemindView == NO) {
            weakSelf.isShowRemindView = YES;
            [weakSelf addRemindModel:[weakSelf.remindDataArray firstObject]];
            // 移除第一个数据
            if (weakSelf.remindDataArray.count > 0) {
                [weakSelf.remindDataArray removeObjectAtIndex:0];
            }
        }
    });
}

/// 收到单条聊天消息
/// - Parameter chatMsgs: 聊天消息
- (void)receivedNewChatMsgs:(NSArray *)chatMsgs {
    if (_chatView) {
        [_chatView receivedNewChatMsgs:chatMsgs];
    }
}

/// 聊天管理
/// @param    manageDic
/// status    聊天消息的状态 0 显示 1 不显示
/// chatIds   聊天消息的id列列表
- (void)chatLogManage:(NSDictionary *)manageDic {
    if (_chatView) {
        [_chatView chatLogManage:manageDic];
    }
}

/// 删除单个聊天
/// - Parameter dict: 聊天数据
- (void)deleteSingleChat:(NSDictionary *)dict {
    if (_chatView) {
        [_chatView deleteSingleChat:dict];
    }
}

/// 删除单个广播
/// - Parameter dict: 广播信息
- (void)deleteSingleBoardcast:(NSDictionary *)dict{
    if (_chatView) {
        [_chatView deleteSingleBoardcast:dict];
    }
}

/// 更新房间直播状态
/// - Parameter state: 是否已开播
- (void)roomLiveStatus:(BOOL)state {
    if (state == YES) {
        // 开始直播
        self.liveStatusType = RoomLiveStatusType_Liveing;
    } else {
        // 结束直播
        self.liveStatusType = RoomLiveStatusType_EndLived;
    }
    if (_introductionView) {
        [_introductionView roomLiveStatus:state];
    }
    [self configureData];
    [self updateRoomBaseInformationsStatus];
}

/// 当前房间直播状态
/// - Parameter state: 0.正在直播 1.未开始直播
- (void)currentRoomLiveStatus:(NSInteger)state {
    if (state == 0) {
        // 直播中
        self.liveStatusType = RoomLiveStatusType_Liveing;
    } else {
        // 直播未开始
        self.liveStatusType = RoomLiveStatusType_NoBeginLive;
    }
    if (_introductionView) {
        [_introductionView currentRoomLiveStatus:state];
    }
    [self configureData];
    [self updateRoomBaseInformationsStatus];
}

/// 房间线路
- (void)HDReceivedVideoAudioLines:(NSDictionary *)dict {
    if ([dict.allKeys containsObject:@"lineList"]) {
        NSArray *lineArray = dict[@"lineList"];
        _isShowMoreToolLine = lineArray.count > 1 ? YES : NO;
        if (_isShowMoreToolLine) {
            NSInteger indexNum = 0;
            if ([dict.allKeys containsObject:@"indexNum"]) {
                indexNum = [dict[@"indexNum"] integerValue];
            }
            [self.linesArray removeAllObjects];
            if ([dict.allKeys containsObject:@"lineList"]) {
                for (int i = 0; i < lineArray.count; i++) {
                    HDSSteamLineAndQualityModel *oneModel = [[HDSSteamLineAndQualityModel alloc]init];
                    oneModel.selectedIndex = indexNum;
                    oneModel.title = [NSString stringWithFormat:@"线路%d",i+1];
                    [self.linesArray addObject:oneModel];
                }
            }
        }
        [self configureData];
    }
}

/// 房间清晰度
- (void)HDReceivedVideoQuality:(NSDictionary *)dict {
    if (_isShowMoreToolQuailty == NO) {
        return;
    }
    NSString *currentQuality = @"";
    if ([dict.allKeys containsObject:@"currentQuality"]) {
        HDQualityModel *oneModel = dict[@"currentQuality"];
        currentQuality = oneModel.quality;
    }
    [self.qualityArray removeAllObjects];
    if ([dict.allKeys containsObject:@"qualityList"]) {
        NSArray *list = dict[@"qualityList"];
        NSInteger selectedIndex = 0;
        for (int i = 0; i < list.count; i++) {
            HDQualityModel *qModel = list[i];
            if ([qModel.quality isEqualToString:currentQuality]) {
                selectedIndex = i;
            }
        }
        for (int j = 0; j < list.count; j++) {
            HDQualityModel *qModel = list[j];
            HDSSteamLineAndQualityModel *model = [[HDSSteamLineAndQualityModel alloc]init];
            model.title = qModel.desc;
            model.selectedIndex = selectedIndex;
            model.quality = qModel.quality;
            [self.qualityArray addObject:model];
        }
        [self configureData];
    }
}

// MARK: - 聊天置顶
/// 房间历史置顶聊天记录
/// @param model 置顶聊天model
- (void)onHistoryTopChatRecords:(HDSHistoryTopChatModel *)model {
    if (_topChatView == nil) return;
    NSArray *tempArray = model.records;
    if (tempArray.count == 0) return;
    _topChatView.hidden = NO;
    if (_topChatView.frame.size.height == 0) {
        [self updateTopChatConstraintsWithIsOpen:NO];
    }
    [_topChatView addItems:tempArray];
    
    [self.topChatArray addObjectsFromArray:tempArray];
}

/// 收到聊天置顶新消息
/// @param model 聊天置顶model
- (void)receivedNewTopChat:(HDSLiveTopChatModel *)model {
    if (_topChatView == nil) return;
    _topChatView.hidden = NO;
    if (_topChatView.frame.size.height == 0) {
        [self updateTopChatConstraintsWithIsOpen:NO];
    }
    [_topChatView addItems:@[model]];
    
    [self.topChatArray addObject:model];
}

/// 收到批量删除聊天置顶消息
/// @param model 聊天置顶model
- (void)receivedDeleteTopChat:(HDSDeleteTopChatModel *)model {
    if (_topChatView == nil) return;
    NSArray *chatIds = model.chatIds;
    if (chatIds.count == 0) return;
    [_topChatView deleteItemIdFromArray:chatIds];
    for (NSString *oneId in chatIds) {
        NSArray *tempArray = [self.topChatArray mutableCopy];
        for (int i = 0; i < tempArray.count; i++) {
            HDSLiveTopChatModel *oneModel = tempArray[i];
            if ([oneModel.id isEqualToString:oneId]) {
                [self.topChatArray removeObject:oneModel];
            }
        }
    }
    if (self.topChatArray.count == 0) {
        _topChatView.hidden = YES;
        [_topChatView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(0);
        }];
        
//        __weak typeof(self) weakSelf = self;
//        CGFloat remindViewMargin = (223 + (IS_IPHONE_X ? 83 : 49))  * SCREEN_WIDTH / 375;
//        [_remindView mas_updateConstraints:^(MASConstraintMaker *make) {
//            make.bottom.mas_equalTo(weakSelf).offset(-remindViewMargin);
//        }];
//        [_remindView layoutIfNeeded];
        
//        CGFloat chatViewHeight = 213 * SCREEN_WIDTH / 375;
//        self.chatViewH = chatViewHeight;
//        [_chatView mas_updateConstraints:^(MASConstraintMaker *make) {
//            make.height.mas_equalTo(weakSelf.chatViewH);
//        }];
//        [_chatView layoutIfNeeded];
    };
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
        [self.streamView addSubview:self.screenCaptureView];
        [self.streamView bringSubviewToFront:self.screenCaptureView];
        WS(weakSelf)
        [self.screenCaptureView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(weakSelf.streamView);
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


// MARK: - Custom Method
- (void)configureUI {
    
    __weak typeof(self) weakSelf = self;
    
    _streamView = [[UIView alloc]init];
    _streamView.backgroundColor = [UIColor colorWithHexString:@"#1F1F2A" alpha:1];
    _streamView.hidden = YES;
    [self addSubview:_streamView];
    
    // 房间基础信息视图
    _infosView = [[HDSLiveStreamInfosView alloc]initWithFrame:CGRectZero btnTapClosure:^{
        [weakSelf infosViewTapEvent];
    }];
    [self addSubview:_infosView];
    _infosView.hidden = YES;
    // 公告视图
    _announcementView = [[HDSLiveStreamAnnouncementView alloc]initWithFrame:CGRectZero tapAction:^{
        [weakSelf announcementButtonTap];
    }];
    [self addSubview:_announcementView];
    _announcementView.hidden = YES;
    // 关闭按钮
    _closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_closeBtn setImage:[UIImage imageNamed:@"关闭"] forState:UIControlStateNormal];
    [self addSubview:_closeBtn];
    [_closeBtn addTarget:self action:@selector(closeBtnTap:) forControlEvents:UIControlEventTouchUpInside];
    
    // 播放器背景图
    _playerBGIMG = [[UIImageView alloc]init];
    _playerBGIMG.backgroundColor = [UIColor colorWithHexString:@"#1C1C20" alpha:1];
    _playerBGIMG.contentMode = UIViewContentModeScaleAspectFit;
    _playerBGIMG.layer.opaque = 0.8;
    [self addSubview:_playerBGIMG];
    
    _shadowView = [[UIView alloc]init];
    _shadowView.backgroundColor = [UIColor colorWithHexString:@"#000000" alpha:0.2];
    [self addSubview:_shadowView];
    
    // 倒计时视图
    _countDownView = [[HDSLiveStreamCountDownView alloc]initWithFrame:CGRectZero];
    [self addSubview:_countDownView];
    
    // 提示语
    _playerBGLabel = [[UILabel alloc]init];
    _playerBGLabel.textColor = [UIColor colorWithHexString:@"#FFFFFF" alpha:1];
    _playerBGLabel.textAlignment = NSTextAlignmentCenter;
    _playerBGLabel.font = [UIFont boldSystemFontOfSize:15];
    [self addSubview:_playerBGLabel];
    
    _bottomIMGView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"横屏大"]];
    _bottomIMGView.contentMode = UIViewContentModeCenter;
    [self addSubview:_bottomIMGView];
    
    _countDownView.hidden = YES;
    // 用户进入直播间提醒视图
    _remindView = [[HDSLiveStreamRemindView alloc]initWithFrame:CGRectZero checkBlock:^{
        if (weakSelf.remindDataArray.count == 0) {
            weakSelf.isShowRemindView = NO;
            return;
        }
        [weakSelf addRemindModel:[weakSelf.remindDataArray firstObject]];
        if (weakSelf.remindDataArray.count > 0) {
            [weakSelf.remindDataArray removeObjectAtIndex:0];
        }
    }];
    [self addSubview:_remindView];
    [_remindView layoutIfNeeded];
    
    [self addSubview:self.topChatView];
    
    _bottomBar = [[HDSLiveBottomBar alloc]init];
    [self addSubview:_bottomBar];
    _bottomBar.chatBtnTapClosure = ^{
        [weakSelf chatBtnAction];
    };
    _bottomBar.emojiBtnTapClosure = ^{
        [weakSelf emojiBtnAction];
    };
    _bottomBar.moreBtnTapClosure = ^{
        [weakSelf moreBtnTapAction];
    };
    _bottomBar.otherBtnTapClosure = ^{
        [weakSelf liveStoreBtnTapAction];
    };
    
    // 聊天视图
    _chatView = [[HDSLiveChatView alloc]init];
    _chatView.delegate = self;
    [self addSubview:_chatView];
    
    // 输入框
    _inputView = [[CCChatContentView alloc]init];
    _inputView.backgroundColor = UIColor.whiteColor;
    _inputView.placeHolder = @"赶快发言吧...";
    _inputView.textView.font = [UIFont systemFontOfSize:14];
    _inputView.textView.verticalCenter = YES;
    _inputView.delegate = self;
    [self addSubview:_inputView];
    self.inputView.sendMessageBlock = ^{
        [weakSelf chatSendMessage];
    };
    
    [self addSubview:self.introductionView];
    
    _cleanBGView = [[UIView alloc]init];
    _cleanBGView.backgroundColor = [UIColor colorWithHexString:@"#000000" alpha:0.4];
    [self addSubview:_cleanBGView];
    [self bringSubviewToFront:_cleanBGView];
    _cleanBGView.hidden = YES;
    
    _cleanIMGView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"清屏"]];
    _cleanIMGView.contentMode = UIViewContentModeCenter;
    [_cleanBGView addSubview:_cleanIMGView];
    
    _cleanLabel = [[UILabel alloc]init];
    _cleanLabel.text = @"退出清屏";
    _cleanLabel.textColor = [UIColor colorWithHexString:@"#FFFFFF" alpha:1];
    _cleanLabel.textAlignment = NSTextAlignmentCenter;
    _cleanLabel.font = [UIFont boldSystemFontOfSize:14];
    [_cleanBGView addSubview:_cleanLabel];
    _isFirstClean = YES;
    
    _cleanBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_cleanBGView addSubview:_cleanBtn];
    [_cleanBtn addTarget:self action:@selector(cleanBtnTap) forControlEvents:UIControlEventTouchUpInside];
    
}

- (void)configureConstraints {
    
    __weak typeof(self) weakSelf = self;
    
    // 流视图
    [_streamView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(weakSelf);
        make.left.right.mas_equalTo(weakSelf);
        make.height.mas_equalTo(SCREEN_WIDTH * 16 / 9);
    }];
    
    CGFloat infosViewOffset = IS_IPHONE_X ? 68 : 44;
    CGFloat infosViewW = SCREEN_WIDTH / 375 * 181.5;
    CGFloat margin = 10;
    CGFloat bottomBarH = IS_IPHONE_X ? 72 : 49;
    [_infosView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf).offset(infosViewOffset);
        make.left.mas_equalTo(weakSelf).offset(15);
        make.width.mas_equalTo(infosViewW);
        make.height.mas_equalTo(47);
    }];
    [_infosView layoutIfNeeded];
    
    [_announcementView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.infosView.mas_bottom).offset(4);
        make.left.mas_equalTo(weakSelf).offset(15);
        make.width.mas_equalTo(infosViewW);
        make.height.mas_equalTo(28);
    }];
    [_announcementView layoutIfNeeded];
    [_announcementView setCornerRadius:14 addRectCorners:UIRectCornerAllCorners];
    
    CGFloat closeBtnOffset = IS_IPHONE_X ? 70 : 46;
    [_closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf).offset(closeBtnOffset);
        make.right.mas_equalTo(weakSelf).offset(-15);
        make.width.height.mas_equalTo(35);
    }];
    
    CGFloat scale = SCREEN_HEIGHT / 812;
    CGFloat countDownTopMargin = 64 * scale;
    CGFloat BGIMGHeight = SCREEN_WIDTH / 375 * 221;
    // 播放器背景视图
    [_playerBGIMG mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.infosView.mas_bottom).offset(countDownTopMargin);
        make.left.right.mas_equalTo(weakSelf);
        make.height.mas_equalTo(BGIMGHeight);
    }];

    [_countDownView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.infosView.mas_bottom).offset(countDownTopMargin);
        make.left.right.mas_equalTo(weakSelf);
        make.height.mas_equalTo(BGIMGHeight);
    }];
    
    [_shadowView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.playerBGIMG.mas_top);
        make.left.mas_equalTo(weakSelf.playerBGIMG.mas_left);
        make.bottom.mas_equalTo(weakSelf.playerBGIMG.mas_bottom);
        make.right.mas_equalTo(weakSelf.playerBGIMG.mas_right);
    }];
    
    // 播放器提示语
    [_playerBGLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(weakSelf.playerBGIMG.mas_centerX);
        make.centerY.mas_equalTo(weakSelf.playerBGIMG.mas_centerY);
        make.left.mas_equalTo(weakSelf).offset(10);
        make.right.mas_equalTo(weakSelf).offset(-10);
        make.height.mas_equalTo(30);
    }];
    
    CGFloat bottomIMGH = SCREEN_WIDTH / 375 * 67;
    [_bottomIMGView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(weakSelf);
        make.bottom.mas_equalTo(weakSelf.playerBGIMG.mas_bottom);
        make.height.mas_equalTo(bottomIMGH);
    }];
    
    [_bottomBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(weakSelf);
        make.height.mas_equalTo(bottomBarH);
    }];
    
    CGFloat tabBarH = 55;
    [_inputView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(weakSelf);
        make.top.mas_equalTo(weakSelf.mas_bottom);
        make.height.mas_equalTo(tabBarH);
    }];
    [_inputView layoutIfNeeded];
    
    CGFloat topChatViewW = 300 * SCREEN_WIDTH / 375;
    [_topChatView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf).offset(15);
        make.bottom.mas_equalTo(weakSelf.chatView.mas_top).offset(-4);
        make.width.mas_equalTo(topChatViewW);
        make.height.mas_equalTo(0);
    }];
    [_topChatView layoutIfNeeded];
    
    CGFloat chatViewHeight = 36 * SCREEN_WIDTH / 375;
    self.chatViewH = chatViewHeight;
    [_chatView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf).offset(margin);
        make.bottom.mas_equalTo(weakSelf.bottomBar.mas_top).offset(-margin);
        make.right.mas_equalTo(weakSelf).offset(-60);
        make.height.mas_equalTo(chatViewHeight);
    }];
    
    CGFloat userRemindViewWidth = 215 * SCREEN_WIDTH / 375;
    //CGFloat remindViewMargin = (251 + (IS_IPHONE_X ? 83 : 49))  * SCREEN_WIDTH / 375;
    [_remindView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(weakSelf.topChatView.mas_top).offset(-4);
        make.left.mas_equalTo(weakSelf).offset(15);
        make.width.mas_equalTo(userRemindViewWidth);
        make.height.mas_equalTo(58);
    }];
    [_remindView layoutIfNeeded];
    
    CGFloat cleanBGBottomMargin = IS_IPHONE_X ? 87 : 43;
    CGFloat cleanBGViewW = 103 * SCREEN_WIDTH / 375;
    [_cleanBGView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(weakSelf).offset(-15);
        make.bottom.mas_equalTo(weakSelf).offset(-cleanBGBottomMargin);
        make.width.mas_equalTo(cleanBGViewW);
        make.height.mas_equalTo(35);
    }];
    _cleanBGView.layer.cornerRadius = 17.5;
    _cleanBGView.layer.masksToBounds = YES;
    
    [_cleanIMGView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.cleanBGView).offset(4);
        make.centerY.mas_equalTo(weakSelf.cleanBGView);
        make.width.height.mas_equalTo(35);
    }];
    
    [_cleanLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.cleanIMGView.mas_right).offset(-2);
        make.right.mas_equalTo(weakSelf.cleanBGView).offset(-8);
        make.centerY.mas_equalTo(weakSelf.cleanBGView);
        make.height.mas_equalTo(35);
    }];
    
    [_cleanBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(weakSelf.cleanBGView);
    }];
}

/// 配置更多按钮地址展示元素
- (void)configureData {
    
    HDSMoreToolItemModel *muteModel = [[HDSMoreToolItemModel alloc]init];
    muteModel.itemName = @"静音";
    muteModel.imageName = @"静音";
    for (HDSMoreToolItemModel *oneModel in self.moreItemArray) {
        if ([oneModel.itemName isEqualToString:@"解除静音"]) {
            muteModel.itemName = @"解除静音";
            muteModel.imageName = @"解除静音";
        } 
    }
    
    [self.moreItemArray removeAllObjects];
    HDSMoreToolItemModel *lineModel = [[HDSMoreToolItemModel alloc]init];
    lineModel.itemName = @"线路";
    lineModel.imageName = @"线路";

    HDSMoreToolItemModel *qulityModel = [[HDSMoreToolItemModel alloc]init];
    qulityModel.itemName = @"清晰度";
    qulityModel.imageName = @"清晰度";

    HDSMoreToolItemModel *cleanModel = [[HDSMoreToolItemModel alloc]init];
    cleanModel.itemName = @"清屏";
    cleanModel.imageName = @"清屏_大";
    
    if (_isShowMoreToolLine && _liveStatusType == RoomLiveStatusType_Liveing) {
        [self.moreItemArray addObject:lineModel];
    }
    
    if (_liveStatusType == RoomLiveStatusType_Liveing) {
        [self.moreItemArray addObject:muteModel];
    }

    if (_isShowMoreToolQuailty && _liveStatusType == RoomLiveStatusType_Liveing) {
        [self.moreItemArray addObject:qulityModel];
    }
    
    [self.moreItemArray addObject:cleanModel];
}

/// 添加进出房间提醒
- (void)addRemindModel:(RemindModel *)model {
    
    NSMutableArray *array = [[NSMutableArray alloc]init];
    NSString *userName = model.userName;
    if (model.userName != nil && model.userName.length > 6) {
       userName = [userName substringToIndex:6];
       userName = [userName stringByAppendingString:@"..."];
    }
    if (model.prefixContent != nil && model.suffixContent != nil) {
        NSString *string = [[NSString alloc]initWithFormat:@"%@【%@】%@",model.prefixContent,userName,model.suffixContent];
        [array addObject:string];
    }

    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf.remindView setDataSource:[array firstObject]];
    });
}

/// 更新房间基础信息类型
- (void)updateRoomInfos {
    if (_infosView == nil) {
        return;
    }
    if (self.roomIcon.length == 0 && self.roomOnlineUserCount.length > 0) {
        if (self.showUserCount == YES) {
            _infosView.type = HDSLiveStreamInfosViewType_NoHeaderIcon;
        } else {
            _infosView.type = HDSLiveStreamInfosViewType_NoHeaderIcon_NoUserCount;
        }
    } else if (self.roomIcon.length > 0 && (self.roomOnlineUserCount.length == 0 || self.showUserCount == NO)) {
        _infosView.type = HDSLiveStreamInfosViewType_NoUserCount;
    } else if (self.roomIcon.length == 0 && (self.roomOnlineUserCount.length == 0 || self.showUserCount == NO)) {
        _infosView.type = HDSLiveStreamInfosViewType_NoHeaderIcon_NoUserCount;
    } else {
        if (self.showUserCount == YES) {
            _infosView.type = HDSLiveStreamInfosViewType_Normal;
        } else {
            _infosView.type = HDSLiveStreamInfosViewType_NoUserCount;
        }
    }
}

- (NSTimeInterval)timeWithStr:(NSString *)time {
    if (time.length == 0 || time == nil) {
        return 0;
    }
    /// 这里加了判断，原因是新的接口返回值timeout与旧接口不一致
    NSTimeInterval interval;
    if (time.length >= 19) {
        
        NSString * strings = [time substringToIndex:19];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        //24小时制：yyyy-MM-dd HH:mm:ss  12小时制：yyyy-MM-dd hh:mm:ss
        dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        NSDate *tmp_date = [dateFormatter dateFromString:strings];
        interval = [tmp_date timeIntervalSince1970];
    } else {
        interval = (NSTimeInterval)time.integerValue;
    }

    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    NSTimeInterval countDown = interval - now;
    if (countDown < 0) {
        countDown = 0;
    }
    return countDown;
}

/// 更新房间基本信息状态
- (void)updateRoomBaseInformationsStatus {
    [self updatePlayerBackgroundViewStatus];
    [self updateCountdownViewStatus];
    [self updatePlayerHintStatus];
}

/// 更新播放器提示语状态
- (void)updatePlayerHintStatus {
    if (_playerBackgroundHint.length == 0) {
        /**
         * 条件1 房间没有开启倒计时
         * 条件2 房间未设置播放器提示
         * 条件3 开启倒计时了，但是已经过了开播时间
         */
        if (_liveStatusType == RoomLiveStatusType_NoBeginLive && (_openLiveCountDown == NO || _countDownDuration == 0)) {
            _playerBGLabel.text = @"直播等待中";
            _playerBGLabel.hidden = NO;
            if (_playerBGUrl.length > 0) {
                _shadowView.hidden = NO;
                _shadowView.backgroundColor = [UIColor colorWithHexString:@"#000000" alpha:0.2];
            } else {
                _shadowView.hidden = YES;
                _shadowView.backgroundColor = [UIColor colorWithHexString:@"#000000" alpha:0];
            }
        } else if (_liveStatusType == RoomLiveStatusType_EndLived) {
            _playerBGLabel.text = @"直播已结束";
            _playerBGLabel.hidden = NO;
            if (_playerBGUrl.length > 0) {
                _shadowView.hidden = NO;
                _shadowView.backgroundColor = [UIColor colorWithHexString:@"#000000" alpha:0.2];
            } else {
                _shadowView.hidden = YES;
                _shadowView.backgroundColor = [UIColor colorWithHexString:@"#000000" alpha:0];
            }
        } else {
            _playerBGLabel.hidden = YES;
            _shadowView.hidden = YES;
        }
    } else {
        if (_liveStatusType != RoomLiveStatusType_Liveing) {
            if (_playerBackgroundHint.length == 0) {
                _playerBGLabel.hidden = YES;
                _shadowView.backgroundColor = [UIColor colorWithHexString:@"#000000" alpha:0];
            } else {
                _playerBGLabel.hidden = NO;
                _shadowView.backgroundColor = [UIColor colorWithHexString:@"#000000" alpha:0.2];
                if (_playerBGUrl.length > 0) {
                    _shadowView.hidden = NO;
                    _playerBGLabel.text = _playerBackgroundHint;
                    [self addSubview:_countDownView];
                    [self sendSubviewToBack:_countDownView];
                } else {
                    _playerBGLabel.text = @"";
                    _shadowView.hidden = YES;
                    _countDownView.playerBGHint = _playerBackgroundHint;
                }
            }
        } else {
            _shadowView.hidden = YES;
            _playerBGLabel.hidden = YES;
        }
    }
}

/// 更新播放器背景视图状态
- (void)updatePlayerBackgroundViewStatus {
    if (_liveStatusType != RoomLiveStatusType_Liveing) {
        _playerBGIMG.hidden = NO;
        _bottomIMGView.hidden = _playerBGUrl.length == 0 ? NO : YES;
        if (_playerBGUrl.length > 0) {
            [_playerBGIMG setPic:_playerBGUrl];
        }
    } else {
        _bottomIMGView.hidden = YES;
        _playerBGIMG.hidden = YES;
    }
}

/// 更新倒计时视图状态
- (void)updateCountdownViewStatus {
    if (_countDownDuration > 0 && _openLiveCountDown && _liveStatusType == RoomLiveStatusType_NoBeginLive) {
        self.countDownView.hidden = NO;
        NSString *countDownDurationStr = [NSString stringWithFormat:@"%ld",(long)_countDownDuration];
        if (self.playerBGUrl.length == 0) {
            if (_countDownView) {
                [_countDownView setCountDown:countDownDurationStr type:HDSLiveStreamCountDownViewTypeCenter];
            }
        } else {
            if (_countDownView) {
                [_countDownView setCountDown:countDownDurationStr type:HDSLiveStreamCountDownViewTypeBottom];
            }
        }
    } else {
        self.countDownView.hidden = YES;
    }
}

// MARK: - Tap Action Event
/// 公告按钮点击
- (void)announcementButtonTap {

    [self announcementBtnTapEvent];
}
/// 关闭按钮点击
- (void)closeBtnTap:(UIButton *)sender {

    if (_closeClosure) {
        _closeClosure();
    }
}
/// 聊天按钮点击
- (void)chatBtnAction {
    
    [self.inputView faceBoardClick_base:NO];
    [self.inputView.textView becomeFirstResponder];
}
/// 表情按钮点击
- (void)emojiBtnAction {
    
    [self.inputView faceBoardClick_base:YES];
    [self.inputView.textView becomeFirstResponder];
}
/// 更多按钮点击
- (void)moreBtnTapAction {
    
    [self showMoreToolView];
}
/// 直播带货按钮点击
- (void)liveStoreBtnTapAction {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:HDS_Show_Live_Store_Item_List_Notification object:nil userInfo:nil];
}
/// 清屏按钮点击
- (void)cleanBtnTap {
    [self showTheWindow];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.inputView.textView resignFirstResponder];
}

// MARK: - sendMsg
- (void)chatSendMessage {
    NSString *str = _inputView.plainText;
    if(str == nil || str.length == 0) {
        return;
    }
    // 发送公聊信息
    if (self.sendChatMessage) {    
        self.sendChatMessage(str);
    }
    _inputView.textView.text = nil;
    [_inputView.textView resignFirstResponder];
}

// MARK: - Keyboard Delegate

- (void)keyBoardWillShow:(CGFloat)height endEditIng:(BOOL)endEditIng {
    
    if (endEditIng == YES) {
        [self endEditing:YES];
        return;
    }
    
    NSInteger selfHeight = SCREEN_HEIGHT - height;
    NSInteger contentHeight = selfHeight > 55 ? ( -height) : ( 55 - SCREEN_HEIGHT);
    [_inputView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.left.mas_equalTo(self);
        make.bottom.mas_equalTo(self.mas_bottom).offset(contentHeight);
        make.height.mas_equalTo(55);
    }];
    
    CGFloat chatHeight = self.chatViewH;
    CGFloat margin = 10;
    [_chatView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self).offset(margin);
        make.bottom.mas_equalTo(self.inputView.mas_top).offset(-margin);
        make.right.mas_equalTo(self).offset(-60);
        make.height.mas_equalTo(chatHeight);
    }];
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.35 animations:^{
        weakSelf.infosView.hidden = YES;
        weakSelf.announcementView.hidden = YES;
        weakSelf.closeBtn.hidden = YES;
        [weakSelf layoutIfNeeded];
    }];
    
}

- (void)hiddenKeyBoard {
    
    CGFloat tabBarH = 55;
    [_inputView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self);
        make.top.mas_equalTo(self.mas_bottom);
        make.height.mas_equalTo(tabBarH);
    }];
    [_inputView layoutIfNeeded];
    
    CGFloat chatHeight = self.chatViewH;
    CGFloat margin = 10;
    [_chatView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self).offset(margin);
        make.bottom.mas_equalTo(self.bottomBar.mas_top).offset(-margin);
        make.right.mas_equalTo(self).offset(-60);
        make.height.mas_equalTo(chatHeight);
    }];
    
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.35 animations:^{
        weakSelf.infosView.hidden = NO;
        weakSelf.announcementView.hidden = NO;
        weakSelf.closeBtn.hidden = NO;
        [weakSelf layoutIfNeeded];
    }];
}

- (void)liveChatDataDourceDidChangeTableViewH:(CGFloat)tableViewH {

    CGFloat chatViewHeight = 213 * SCREEN_WIDTH / 375;
    CGFloat realH = chatViewHeight;
    if (tableViewH < chatViewHeight) {
        realH = tableViewH;
    }
    self.chatViewH = realH;
    [_chatView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(realH);
    }];
}

// MARK: - 展示公告
- (HDSAnnouncementView *)announcementWindowView {
    if (!_announcementWindowView) {
        __weak typeof(self) weakSelf = self;
        _announcementWindowView = [[HDSAnnouncementView alloc] initWithAnnouncementStr:_roomAnnouncement closeBtnTapClosure:^{
            [weakSelf announcementCloseBtnTapEvent];
        }];
        _announcementWindowView.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT);
    }
    return _announcementWindowView;
}
/// 点击公告按钮
- (void)announcementBtnTapEvent {
    [self addSubview:self.announcementWindowView];
    [self bringSubviewToFront:self.announcementWindowView];
    
    // 隐藏简介
    if (_introductionView) {
        [self introductionViewCloseBtnTapEvent];
    }
    // 隐藏更多
    if (_moreToolView) {
        [self moreToolViewCloseBtnTagEvent];
    }
    
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.35 animations:^{
       weakSelf.announcementWindowView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    } completion:^(BOOL finished) {
        weakSelf.announcementWindowView.topView.backgroundColor = [UIColor colorWithHexString:@"#000000" alpha:0.4];
    }];
}

/// 关闭公告视图
- (void)announcementCloseBtnTapEvent {
    __weak typeof(self) weakSelf = self;
    self.announcementWindowView.topView.backgroundColor = [UIColor colorWithHexString:@"#000000" alpha:0];
    [UIView animateWithDuration:0.35 animations:^{
        weakSelf.announcementWindowView.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT);
    } completion:^(BOOL finished) {
        [weakSelf.announcementWindowView removeFromSuperview];
    }];
}

// MARK: - 展示简介
- (HDSIntroductionView *)introductionView {
    if (!_introductionView) {
        __weak typeof(self) weakSelf = self;
        _introductionView = [[HDSIntroductionView alloc]initWithFrame:CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT) closeBtnTapClosure:^{
            [weakSelf introductionViewCloseBtnTapEvent];
        }];
    }
    return _introductionView;
}

/// 展示简介视图
- (void)infosViewTapEvent {
    [self bringSubviewToFront:self.introductionView];
    
    // 隐藏公告
    if (_announcementView) {
        [self announcementCloseBtnTapEvent];
    }
    
    // 隐藏更多
    if (_moreToolView) {
        [self moreToolViewCloseBtnTagEvent];
    }
    
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.35 animations:^{
       weakSelf.introductionView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    } completion:^(BOOL finished) {
        weakSelf.introductionView.topView.backgroundColor = [UIColor colorWithHexString:@"#000000" alpha:0.4];
    }];
}

/// 简介视图关闭按钮点击事件
- (void)introductionViewCloseBtnTapEvent {
    if (_introductionView.frame.origin.y == SCREEN_HEIGHT) {
        return;
    }
    __weak typeof(self) weakSelf = self;
    self.introductionView.topView.backgroundColor = [UIColor colorWithHexString:@"#000000" alpha:0];
    [UIView animateWithDuration:0.35 animations:^{
        weakSelf.introductionView.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT);
    }];
}

// MARK: - 更多工具视图
- (void)showMoreToolView {
    // 隐藏公告
    if (_announcementView) {
        [self announcementCloseBtnTapEvent];
    }
    // 隐藏简介
    if (_introductionView) {
        [self introductionViewCloseBtnTapEvent];
    }
    
    __weak typeof(self) weakSelf = self;
    _moreToolView = [[HDSMoreToolView alloc]initWithFrame:CGRectZero tabTitle:@"更多" btnTapClosure:^(NSString * _Nonnull itemName) {
        if ([itemName isEqualToString:@"关闭"]) {
            [weakSelf moreToolViewCloseBtnTagEvent];
        } else {
            [weakSelf moreToolTapItem:itemName];
        }
    }];
    _moreToolView.closeClosure = ^{
        [weakSelf moreToolViewCloseBtnTagEvent];
    };
    
    _moreToolView.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT);
    [self addSubview:_moreToolView];
    [self bringSubviewToFront:_moreToolView];
    
    [_moreToolView setDataSource:self.moreItemArray];
    
    [UIView animateWithDuration:0.35 animations:^{
        weakSelf.moreToolView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    } completion:^(BOOL finished) {
        weakSelf.moreToolView.topView.backgroundColor = [UIColor colorWithHexString:@"#000000" alpha:0.4];
    }];
}

/// 更多工具视图关闭按钮点击事件
- (void)moreToolViewCloseBtnTagEvent {
    __weak typeof(self) weakSelf = self;
    self.moreToolView.topView.backgroundColor = [UIColor colorWithHexString:@"#000000" alpha:0];
    [UIView animateWithDuration:0.35 animations:^{
        weakSelf.moreToolView.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT);
    } completion:^(BOOL finished) {
        [weakSelf.moreToolView removeFromSuperview];
    }];
}

/// 更多工具视图 点击事件
/// - Parameter itemName: itemName
- (void)moreToolTapItem:(NSString *)itemName {
    if (itemName.length == 0) return;
    if ([itemName isEqualToString:@"清屏"]) {
        [self moreToolViewCloseBtnTagEvent];
        [self cleanTheWindow];
    } else if ([itemName isEqualToString:@"静音"]) {
        if (_muteStreamVoice) {
            _muteStreamVoice(NO);
        }
        [self configureData];
        [self moreToolViewCloseBtnTagEvent];
    } else if ([itemName isEqualToString:@"解除静音"]) {
        if (_muteStreamVoice) {
            _muteStreamVoice(YES);
        }
        [self configureData];
        [self moreToolViewCloseBtnTagEvent];
    } else if ([itemName isEqualToString:@"线路"]) {
        [self showVideoLineView];
    } else if ([itemName isEqualToString:@"清晰度"]) {
        [self showVideoQualityView];
    }
}

- (NSMutableArray *)moreItemArray {
    if (!_moreItemArray) {
        _moreItemArray = [NSMutableArray array];
    }
    return _moreItemArray;
}

// MARK: - 清晰度&线路
- (void)showVideoLineView {
    // 隐藏更多
    if (_moreToolView) {
        [self moreToolViewCloseBtnTagEvent];
    }
    
    __weak typeof(self) weakSelf = self;
    _videoLineView = [[HDSStreamLineAndQualityView alloc]initWithFrame:CGRectZero tabTitle:@"线路" closeBtnTapClosure:^{
        [weakSelf closeVideoLineView];
    }];
    _videoLineView.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT);
    [self addSubview:_videoLineView];
    [self bringSubviewToFront:_videoLineView];
    
    [_videoLineView setDataSource:self.linesArray];
    _videoLineView.changeActionBlock = ^(HDSSteamLineAndQualityModel * _Nonnull model) {
        [weakSelf changeVideoLine:model];
    };
    
    [UIView animateWithDuration:0.35 animations:^{
        weakSelf.videoLineView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    } completion:^(BOOL finished) {
        weakSelf.videoLineView.topView.backgroundColor = [UIColor colorWithHexString:@"#000000" alpha:0.4];
    }];
}
/// 切换线路
- (void)changeVideoLine:(HDSSteamLineAndQualityModel *)model {
    if (_changeLineBlock) {
        _changeLineBlock(model.selectedIndex);
    }
    [self closeVideoLineView];
}

/// 关闭切换线路视图
- (void)closeVideoLineView {
    __weak typeof(self) weakSelf = self;
    self.videoLineView.topView.backgroundColor = [UIColor colorWithHexString:@"#000000" alpha:0];
    [UIView animateWithDuration:0.35 animations:^{
        weakSelf.videoLineView.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT);
    } completion:^(BOOL finished) {
        [weakSelf.videoLineView removeFromSuperview];
    }];
}

- (NSMutableArray *)linesArray {
    if (!_linesArray) {
        _linesArray = [NSMutableArray array];
    }
    return _linesArray;
}

// MARK: - 切换清晰度

- (void)showVideoQualityView {
    // 隐藏更多
    if (_moreToolView) {
        [self moreToolViewCloseBtnTagEvent];
    }
    
    __weak typeof(self) weakSelf = self;
    _videoQualityView = [[HDSStreamLineAndQualityView alloc]initWithFrame:CGRectZero tabTitle:@"清晰度" closeBtnTapClosure:^{
        [weakSelf closeVideoQualityView];
    }];
    _videoQualityView.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT);
    [self addSubview:_videoQualityView];
    [self bringSubviewToFront:_videoQualityView];
    
    [_videoQualityView setDataSource:self.qualityArray];
    _videoQualityView.changeActionBlock = ^(HDSSteamLineAndQualityModel * _Nonnull model) {
        [weakSelf changeVideoQuailtiy:model];
    };
    
    [UIView animateWithDuration:0.35 animations:^{
        weakSelf.videoQualityView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    } completion:^(BOOL finished) {
        weakSelf.videoQualityView.topView.backgroundColor = [UIColor colorWithHexString:@"#000000" alpha:0.4];
    }];
}

/// 切换清晰度
- (void)changeVideoQuailtiy:(HDSSteamLineAndQualityModel *)model {
    if (_changeQualityBlock) {
        _changeQualityBlock(model.quality);
    }
    [self closeVideoQualityView];
}

/// 关闭切换清晰度
- (void)closeVideoQualityView {
    __weak typeof(self) weakSelf = self;
    self.videoQualityView.topView.backgroundColor = [UIColor colorWithHexString:@"#000000" alpha:0];
    [UIView animateWithDuration:0.35 animations:^{
        weakSelf.videoQualityView.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT);
    } completion:^(BOOL finished) {
        [weakSelf.videoQualityView removeFromSuperview];
    }];
}

- (NSMutableArray *)qualityArray {
    if (!_qualityArray) {
        _qualityArray = [NSMutableArray array];
    }
    return _qualityArray;
}
   
// MARK: - 清屏
// 清屏
- (void)cleanTheWindow {
    _cleanBGView.hidden = NO;
    _infosView.hidden = YES;
    _announcementView.hidden = YES;
    _closeBtn.hidden = YES;
    _remindView.hidden = YES;
    _chatView.hidden = YES;
    _bottomBar.hidden = YES;
    _topChatView.hidden = YES;
    // 发送清屏通知（互动组件功能需要使用）
    [[NSNotificationCenter defaultCenter] postNotificationName:HDS_Clean_The_WIndow_Notification object:nil userInfo:@{@"status":@(YES)}];
    
    if (_isFirstClean == YES) {
        [self performSelector:@selector(reduceCleanBtn) withObject:nil afterDelay:3];
    }
}

// 恢复
- (void)showTheWindow {
    _cleanBGView.hidden = YES;
    _infosView.hidden = NO;
    if (_roomAnnouncement.length > 0) {
        _announcementView.hidden = NO;
    }
    _closeBtn.hidden = NO;
    if (_isShowRemindView) {
        _remindView.hidden = NO;
    }
    
    if (_isChatView) {
        _chatView.hidden = NO;
        _bottomBar.hidden = NO;
        if (_topChatView && _topChatArray.count > 0) {
            _topChatView.hidden = NO;
        }
    }
    // 发送恢复屏幕通知（互动组件功能需要使用）
    [[NSNotificationCenter defaultCenter] postNotificationName:HDS_Clean_The_WIndow_Notification object:nil userInfo:@{@"status":@(NO)}];
}

- (void)reduceCleanBtn {
    _isFirstClean = NO;
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:3 animations:^{
        CGFloat cleanBGBottomMargin = IS_IPHONE_X ? 87 : 43;
        [weakSelf.cleanBGView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(weakSelf).offset(-15);
            make.bottom.mas_equalTo(weakSelf).offset(-cleanBGBottomMargin);
            make.width.mas_equalTo(35);
            make.height.mas_equalTo(35);
        }];
        _cleanBGView.layer.cornerRadius = 17.5;
        _cleanBGView.layer.masksToBounds = YES;
    }];
}

// MARK: - 聊天置顶
- (HDSLiveStreamTopChatView *)topChatView {
    if (!_topChatView) {
        __weak typeof(self) weakSelf = self;
        _topChatView = [[HDSLiveStreamTopChatView alloc]initWithFrame:CGRectZero layoutStyle:HDSLiveStreamTopChatLayoutStyleTopBottom closure:^(BOOL isOpen) {
            [weakSelf updateTopChatConstraintsWithIsOpen:isOpen];
        }];
        _topChatView.hidden = YES;
    }
    return _topChatView;
}

- (void)updateTopChatConstraintsWithIsOpen:(BOOL)isOpen {
    
    CGFloat chatViewHeight = self.chatViewH;
    if (self.chatViewH >= 213) {
        chatViewHeight = isOpen == YES ? chatViewHeight - 83 : chatViewHeight;
    }
    [_chatView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(chatViewHeight);
    }];
    [_chatView layoutIfNeeded];
    
    CGFloat topChatViewH = isOpen ? 156 : 83;
    topChatViewH = topChatViewH * SCREEN_WIDTH / 375;
    [_topChatView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(topChatViewH);
    }];
    [_topChatView layoutIfNeeded];
}

- (NSMutableArray *)topChatArray {
    if (!_topChatArray) {
        _topChatArray = [NSMutableArray array];
    }
    return _topChatArray;
}


- (void)dealloc {
    
    if (@available(iOS 11.0, *)) {
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:UIScreenCapturedDidChangeNotification
                                                      object:nil];
    }
}

@end
