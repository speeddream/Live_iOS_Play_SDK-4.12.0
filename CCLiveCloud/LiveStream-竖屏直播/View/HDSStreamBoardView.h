//
//  HDSStreamBoardView.h
//  CCLiveCloud
//
//  Created by richard lee on 4/27/22.
//  Copyright © 2022 MacBook Pro. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HDSLiveStreamControlView;
#import "CCSDK/PlayParameter.h"
NS_ASSUME_NONNULL_BEGIN

typedef void(^closeBtnClosure)(void);
typedef void(^sendChatMessage)(NSString *msg);
typedef void(^muteStreamVoice)(BOOL result);
typedef void(^changeLineBlock)(NSInteger index);
typedef void(^changeQualityBlock)(NSString *quality);

@interface HDSStreamBoardView : UIView

/// 流视图层
@property (nonatomic, strong) UIView *streamView;
/// 控制层
@property (nonatomic, strong) HDSLiveStreamControlView *ctrlView;
/// 发送聊天消息回调
@property (nonatomic, strong) sendChatMessage sendChatMessage;
/// 是否禁用声音
@property (nonatomic, copy) muteStreamVoice muteStreamVoice;
/// 直播带货开关 0:关闭 1:直播间配置 2:全局配置
@property (nonatomic, assign) NSInteger liveStoreSwitch;
/// 切换线路回调
@property (nonatomic, copy) changeLineBlock changeLineBlock;
/// 切换清晰度回调
@property (nonatomic, copy) changeQualityBlock changeQualityBlock;

@property (nonatomic, copy) NSString *viewerId;

/// 4.12.0 new 屏幕开关 YES 开启防录屏 NO 关闭防录屏
@property (nonatomic, assign) BOOL screenCaptureSwitch;

/// 实例化
/// - Parameters:
///   - frame: 布局
///   - closure: 关闭按钮回调
- (instancetype)initWithFrame:(CGRect)frame closeBtnAction:(closeBtnClosure)closure;

/// 房间信息
/// - Parameter dict: 房间信息
- (void)roomInfo:(NSDictionary *)dic;

/// 设置房间icon
/// - Parameter url: 头像地址
- (void)setHomeIconWithUrl:(NSString *)url;

/// 房间历史公告
/// - Parameter announcement: 公告信息
- (void)setHomeHistoryAnnouncement:(NSString *)announcement;

/// 接收到新的公告信息
/// - Parameter dict: 公告信息
- (void)receiveNewAnnouncement:(NSDictionary *)dict;

/// 设置房间人数
/// - Parameter count: 人数
- (void)setRoomOnlineUserCountWithCount:(NSString *)count;

/// 设置用户进入房间提醒
/// - Parameter model: 用户数据
- (void)setUserRemindWithModel:(RemindModel *)model;

/// 收到单条聊天消息
/// - Parameter chatMsgs: 聊天消息
- (void)receivedNewChatMsgs:(NSArray *)chatMsgs;

/// 聊天管理
/// @param manageDic
/// status    聊天消息的状态 0 显示 1 不显示
/// chatIds   聊天消息的id列列表
- (void)chatLogManage:(NSDictionary *)manageDic;

/// 删除单个聊天
/// - Parameter dict: 聊天数据
- (void)deleteSingleChat:(NSDictionary *)dict;

/// 删除单个广播
/// - Parameter dict: 广播信息
- (void)deleteSingleBoardcast:(NSDictionary *)dict;

/// 更新房间直播状态（已在房间后，收到讲师发起的直播开始和直播结束消息）
/// - Parameter state: 是否已开播
- (void)roomLiveStatus:(BOOL)state;

/// 当前房间直播状态
/// - Parameter state: 0.正在直播 1.未开始直播
- (void)currentRoomLiveStatus:(NSInteger)state;

/// 房间线路
/// @param dict 房间视频音频线路
- (void)HDReceivedVideoAudioLines:(NSDictionary *)dict;

/// 房间清晰度
/// @param dict 房间清晰度
- (void)HDReceivedVideoQuality:(NSDictionary *)dict;

/// 房间历史置顶聊天记录
/// @param model 置顶聊天model
- (void)onHistoryTopChatRecords:(HDSHistoryTopChatModel *)model;

/// 收到聊天置顶新消息
/// @param model 聊天置顶model
- (void)receivedNewTopChat:(HDSLiveTopChatModel *)model;

/// 收到批量删除聊天置顶消息
/// @param model 聊天置顶model
- (void)receivedDeleteTopChat:(HDSDeleteTopChatModel *)model;

@end

NS_ASSUME_NONNULL_END
