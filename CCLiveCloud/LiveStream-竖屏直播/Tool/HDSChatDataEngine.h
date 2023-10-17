//
//  HDSChatDataEngine.h
//  CCLiveCloud
//
//  Created by Apple on 2022/5/5.
//  Copyright © 2022 MacBook Pro. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class HDSChatDataModel;

@interface HDSChatDataEngine : NSObject

@property (nonatomic, copy) NSString *viewerId;

/// 收到房间历史聊天数据
/// - Parameter chats: 历史聊天数组
- (void)receiveHistoryChatMessages:(NSArray *)chats;

/// 收到单个聊天
/// - Parameter message: 聊天数据
- (void)receiveSingleChatMessage:(NSDictionary *)message;

/// 收到历史广播消息数据
/// - Parameter boardcasts: 历史广播数组
- (void)receiveHistoryBoardcast:(NSArray *)boardcasts;

/// 收到单个广播消息
/// - Parameter boardcast: 广播数据
- (void)receiveSingleBoardcastMessage:(NSDictionary *)boardcast;

/// ？？？
/// - Parameter closure: ？？？
- (void)checkNewMessages:(void(^)(NSArray <HDSChatDataModel *> *oneMsgs))closure;

- (void)killAll;

@end

NS_ASSUME_NONNULL_END
