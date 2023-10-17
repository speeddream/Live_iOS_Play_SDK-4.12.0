//
//  HDSLiveChatView.h
//  CCLiveCloud
//
//  Created by richard lee on 4/27/22.
//  Copyright © 2022 MacBook Pro. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol HDSLiveChatViewDelegate <NSObject>

- (void)liveChatDataDourceDidChangeTableViewH:(CGFloat)tableViewH;

@end

@interface HDSLiveChatView : UIView

@property (nonatomic, assign)id<HDSLiveChatViewDelegate>delegate;

/// 收到新的聊天消息
/// @param chatMsgs 聊天消息
- (void)receivedNewChatMsgs:(NSArray *)chatMsgs;

/// 删除单个广播
/// - Parameter dict: 广播信息
- (void)deleteSingleBoardcast:(NSDictionary *)dict;

/// 聊天管理
/// @param manageDic
/// status    聊天消息的状态 0 显示 1 不显示
/// chatIds   聊天消息的id列列表
- (void)chatLogManage:(NSDictionary *)manageDic;

/// 删除单个聊天
/// - Parameter dict: 聊天数据
- (void)deleteSingleChat:(NSDictionary *)dict;

@end

NS_ASSUME_NONNULL_END
