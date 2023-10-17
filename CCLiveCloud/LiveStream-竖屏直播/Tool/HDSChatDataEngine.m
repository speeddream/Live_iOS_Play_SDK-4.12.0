//
//  HDSChatDataEngine.m
//  CCLiveCloud
//
//  Created by Apple on 2022/5/5.
//  Copyright © 2022 MacBook Pro. All rights reserved.
//

#import "HDSChatDataEngine.h"
#import "HDSChatDataModel.h"
#import "Utility.h"
#import "HDSSafeArray.h"

#define kMaxCount 500

@interface HDSChatDataEngine ()

@property (nonatomic, strong) HDSSafeArray      *chat_array;

@property (nonatomic, strong) dispatch_queue_t  chat_queue;

@property (nonatomic, strong) dispatch_semaphore_t chat_semaphore;

@property (nonatomic, assign) BOOL              isDestroy;

@end

@implementation HDSChatDataEngine

- (instancetype)init {
    self = [super init];
    if (self) {
        [self.chat_array removeAllObjects];
        self.isDestroy = NO;
        self.chat_queue = dispatch_queue_create("received_chat_message", DISPATCH_QUEUE_CONCURRENT);
        self.chat_semaphore = dispatch_semaphore_create(1);
    }
    return self;
}

- (void)receiveHistoryChatMessages:(NSArray *)chats {
    if (_isDestroy) return;
    __weak typeof(self) weakSelf = self;
    dispatch_async(self.chat_queue, ^{
        for (NSDictionary *singleChat in chats) {
            HDSChatDataModel *oneModel = [weakSelf transformHistoryChatModelWithDict:singleChat];
            [weakSelf.chat_array addObject:oneModel];
        }
    });
}

- (void)receiveSingleChatMessage:(NSDictionary *)message {
    if (_isDestroy) return;
    __weak typeof(self) weakSelf = self;
    dispatch_async(self.chat_queue, ^{
        HDSChatDataModel *chatModel = [weakSelf transformReceiveSingeChatModelWithDict:message];
        [weakSelf.chat_array addObject:chatModel];
    });
}


- (void)receiveHistoryBoardcast:(NSArray *)boardcasts {
    if (_isDestroy) return;
    __weak typeof(self) weakSelf = self;
    dispatch_async(self.chat_queue, ^{
        for (NSDictionary *singleBoardcast in boardcasts) {
            HDSChatDataModel *oneModel = [weakSelf transformHistoryBoardcastWithDict:singleBoardcast];
            [weakSelf.chat_array addObject:oneModel];
        }
    });
}


- (void)receiveSingleBoardcastMessage:(NSDictionary *)boardcast {
    if (_isDestroy) return;
    __weak typeof(self) weakSelf = self;
    dispatch_async(self.chat_queue, ^{
        HDSChatDataModel *chatModel = [weakSelf transformSingelBoardcastWithDict:boardcast];
        [weakSelf.chat_array addObject:chatModel];
    });
}

- (void)checkNewMessages:(void (^)(NSArray<HDSChatDataModel *> * _Nonnull oneMsgs))closure {
    if (_isDestroy) return;
    __weak typeof(self) weakSelf = self;
    dispatch_semaphore_wait(self.chat_semaphore, DISPATCH_TIME_FOREVER);
    dispatch_async(self.chat_queue, ^{
        if (closure) {
            if (weakSelf.chat_array.count == 0) {
                dispatch_semaphore_signal(weakSelf.chat_semaphore);
                return;
            };
            NSMutableArray *tempArr = [NSMutableArray array];
            /// 仅展示 500 条
            int kNum = 0;
            if (weakSelf.chat_array.count > kMaxCount) {
                kNum = (int)weakSelf.chat_array.count - kMaxCount;
            }
            for (int i = kNum ; i < weakSelf.chat_array.count; i++) {
                HDSChatDataModel *oneMsg = weakSelf.chat_array[i];
//                if (oneMsg.status != 1 || [oneMsg.userId isEqualToString:weakSelf.viewerId]) {
                    [tempArr addObject:oneMsg];
//                }
            }
            // 排序
//            NSArray *sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"time" ascending:YES]];
//            NSMutableArray *chats = [tempArr mutableCopy];
//            if (chats.count > 1) {
//                [chats sortUsingDescriptors:sortDescriptors];
//            }
            closure(tempArr);
        }
        dispatch_semaphore_signal(weakSelf.chat_semaphore);
    });
    if (self.chat_array.count > 0) {
        dispatch_semaphore_wait(self.chat_semaphore, DISPATCH_TIME_FOREVER);
        [self.chat_array removeAllObjects];
        dispatch_semaphore_signal(self.chat_semaphore);
    }
}

- (void)killAll {
    
    _isDestroy = YES;
    _chat_queue = nil;
    _chat_semaphore = nil;
    [_chat_array removeAllObjects];
    _chat_array = nil;
}

// MARK: - Custom Method

- (HDSChatDataModel *)transformReceiveSingeChatModelWithDict:(NSDictionary *)message {
    
    HDSChatDataModel *chatModel = [[HDSChatDataModel alloc]init];
    if ([message.allKeys containsObject:@"chatId"]) {
        NSString *chatId = message[@"chatId"];
        if (chatId == nil) {
            chatId = @"";
        }
        chatModel.chatId = chatId;
    }
    
    if ([message.allKeys containsObject:@"checkStatus"]) {
        NSInteger checkStatus = [[NSString stringWithFormat:@"%@",message[@"checkStatus"]] integerValue];
        chatModel.checkStatus = checkStatus;
    }
    
    if ([message.allKeys containsObject:@"filterStatus"]) {
        NSInteger filterStatus = [[NSString stringWithFormat:@"%@",message[@"filterStatus"]] integerValue];
        chatModel.filterStatus = filterStatus;
    }
    
    if ([message.allKeys containsObject:@"groupId"]) {
        NSString *groupId = message[@"groupId"];
        if (groupId == nil) {
            groupId = @"";
        }
        chatModel.groupId = groupId;
    }
    
    if ([message.allKeys containsObject:@"msg"]) {
        NSString *chatMsg = message[@"msg"];
        if (chatMsg == nil) {
            chatMsg = @"";
        }
        if ([chatMsg containsString:@"[uri_"]) {
            chatMsg = [chatMsg stringByReplacingOccurrencesOfString:@"[uri_" withString:@""];
            chatMsg = [chatMsg stringByReplacingOccurrencesOfString:@"]" withString:@""];
        }
        chatModel.msg = chatMsg;
    }
    
    if ([message.allKeys containsObject:@"status"]) {
        NSInteger status = [[NSString stringWithFormat:@"%@",message[@"status"]] integerValue];
        chatModel.status = status;
    }
    
    if ([message.allKeys containsObject:@"time"]) {
        NSString *time = message[@"time"];
        if (time == nil) {
            time = @"";
        }
        chatModel.time = time;
    }
    
    if ([message.allKeys containsObject:@"useravatar"]) {
        NSString *useravatar = message[@"useravatar"];
        if (useravatar == nil) {
            useravatar = @"";
        }
        chatModel.userAvatar = useravatar;
    }
    
    chatModel.isMyself = NO;
    if ([message.allKeys containsObject:@"userid"]) {
        NSString *userid = message[@"userid"];
        if (userid == nil) {
            userid = @"";
        }
        chatModel.userId = userid;
        if ([userid isEqualToString:self.viewerId]) {
            chatModel.isMyself = YES;
        }
    }
    
    if ([message.allKeys containsObject:@"username"]) {
        NSString *username = message[@"username"];
        if (username == nil) {
            username = @"";
        }
        chatModel.userName = username;
    }
    
    if ([message.allKeys containsObject:@"userrole"]) {
        NSString *userrole = message[@"userrole"];
        if (userrole == nil) {
            userrole = @"";
        }
        chatModel.userRole = userrole;
    }
    chatModel.nameWidth = [self calculationUserNameWidht:chatModel];
    chatModel.roleType = [self getRoleType:chatModel];
    return chatModel;
}

- (HDSChatDataModel *)transformHistoryChatModelWithDict:(NSDictionary *)message {
    
    HDSChatDataModel *chatModel = [[HDSChatDataModel alloc]init];
    if ([message.allKeys containsObject:@"chatId"]) {
        NSString *chatId = message[@"chatId"];
        if (chatId == nil) {
            chatId = @"";
        }
        chatModel.chatId = chatId;
    }
    
    if ([message.allKeys containsObject:@"checkStatus"]) {
        NSInteger checkStatus = [[NSString stringWithFormat:@"%@",message[@"checkStatus"]] integerValue];
        chatModel.checkStatus = checkStatus;
    }
    
    if ([message.allKeys containsObject:@"filterStatus"]) {
        NSInteger filterStatus = [[NSString stringWithFormat:@"%@",message[@"filterStatus"]] integerValue];
        chatModel.filterStatus = filterStatus;
    }
    
    if ([message.allKeys containsObject:@"groupId"]) {
        NSString *groupId = message[@"groupId"];
        if (groupId == nil) {
            groupId = @"";
        }
        chatModel.groupId = groupId;
    }
    
    if ([message.allKeys containsObject:@"content"]) {
        NSString *chatMsg = message[@"content"];
        if (chatMsg == nil) {
            chatMsg = @"";
        }
        if ([chatMsg containsString:@"[uri_"]) {
            chatMsg = [chatMsg stringByReplacingOccurrencesOfString:@"[uri_" withString:@""];
            chatMsg = [chatMsg stringByReplacingOccurrencesOfString:@"]" withString:@""];
        }
        chatModel.msg = chatMsg;
    }
    
    if ([message.allKeys containsObject:@"status"]) {
        NSInteger status = [[NSString stringWithFormat:@"%@",message[@"status"]] integerValue];
        chatModel.status = status;
    }
    
    if ([message.allKeys containsObject:@"time"]) {
        NSString *time = message[@"time"];
        if (time == nil) {
            time = @"";
        }
        chatModel.time = time;
    }
    
    if ([message.allKeys containsObject:@"userAvatar"]) {
        NSString *useravatar = message[@"userAvatar"];
        if (useravatar == nil) {
            useravatar = @"";
        }
        chatModel.userAvatar = useravatar;
    }
    
    chatModel.isMyself = NO;
    if ([message.allKeys containsObject:@"userId"]) {
        NSString *userid = message[@"userId"];
        if (userid == nil) {
            userid = @"";
        }
        chatModel.userId = userid;
        if ([userid isEqualToString:self.viewerId]) {
            chatModel.isMyself = YES;
        }
    }
    
    if ([message.allKeys containsObject:@"userName"]) {
        NSString *username = message[@"userName"];
        if (username == nil) {
            username = @"";
        }
        chatModel.userName = username;
    }
    
    if ([message.allKeys containsObject:@"userRole"]) {
        NSString *userrole = message[@"userRole"];
        if (userrole == nil) {
            userrole = @"";
        }
        chatModel.userRole = userrole;
    }
    chatModel.nameWidth = [self calculationUserNameWidht:chatModel];
    chatModel.roleType = [self getRoleType:chatModel];
    return chatModel;
}


- (HDSChatDataModel *)transformSingelBoardcastWithDict:(NSDictionary *)message {
    
    HDSChatDataModel *chatModel = [[HDSChatDataModel alloc]init];
    
    NSDictionary *valueDict = [NSDictionary dictionary];
    if ([message.allKeys containsObject:@"value"]) {
        valueDict = message[@"value"];
    }
    
    if ([valueDict.allKeys containsObject:@"content"]) {
        NSString *chatMsg = valueDict[@"content"];
        if (chatMsg == nil) {
            chatMsg = @"";
        }
        if ([chatMsg containsString:@"[uri_"]) {
            chatMsg = [chatMsg stringByReplacingOccurrencesOfString:@"[uri_" withString:@""];
            chatMsg = [chatMsg stringByReplacingOccurrencesOfString:@"]" withString:@""];
        }
        chatModel.msg = chatMsg;
    }
    
    if ([valueDict.allKeys containsObject:@"createTime"]) {
        NSString *time = valueDict[@"createTime"];
        if (time == nil) {
            time = @"";
        }
        chatModel.time = time;
    }
    
    if ([valueDict.allKeys containsObject:@"id"]) {
        NSString *boardcastId = valueDict[@"id"];
        if (boardcastId == nil) {
            boardcastId = @"";
        }
        chatModel.boardCastId = boardcastId;
    }
    
    if ([valueDict.allKeys containsObject:@"userid"]) {
        NSString *userid = valueDict[@"userid"];
        if (userid == nil) {
            userid = @"";
        }
        chatModel.userId = userid;
    }
    
    if ([valueDict.allKeys containsObject:@"username"]) {
        NSString *username = valueDict[@"username"];
        if (username == nil) {
            username = @"";
        }
        chatModel.userName = username;
    }
    
    if ([valueDict.allKeys containsObject:@"userrole"]) {
        NSString *userrole = valueDict[@"userrole"];
        if (userrole == nil) {
            userrole = @"";
        }
        chatModel.userRole = userrole;
    }
    chatModel.roleType = @"广播";
    return chatModel;
}

- (HDSChatDataModel *)transformHistoryBoardcastWithDict:(NSDictionary *)message {
    
    HDSChatDataModel *chatModel = [[HDSChatDataModel alloc]init];
    if ([message.allKeys containsObject:@"content"]) {
        NSString *chatMsg = message[@"content"];
        if (chatMsg == nil) {
            chatMsg = @"";
        }
        if ([chatMsg containsString:@"[uri_"]) {
            chatMsg = [chatMsg stringByReplacingOccurrencesOfString:@"[uri_" withString:@""];
            chatMsg = [chatMsg stringByReplacingOccurrencesOfString:@"]" withString:@""];
        }
        chatModel.msg = chatMsg;
    }
    
    if ([message.allKeys containsObject:@"time"]) {
        NSString *time = message[@"time"];
        if (time == nil) {
            time = @"";
        }
        chatModel.time = time;
    }
    
    if ([message.allKeys containsObject:@"id"]) {
        NSString *boardcastId = message[@"id"];
        if (boardcastId == nil) {
            boardcastId = @"";
        }
        chatModel.boardCastId = boardcastId;
    }
    
    if ([message.allKeys containsObject:@"publisherId"]) {
        NSString *userid = message[@"publisherId"];
        if (userid == nil) {
            userid = @"";
        }
        chatModel.userId = userid;
    }
    
    if ([message.allKeys containsObject:@"publisherName"]) {
        NSString *username = message[@"publisherName"];
        if (username == nil) {
            username = @"";
        }
        chatModel.userName = username;
    }
    
    if ([message.allKeys containsObject:@"publisherRole"]) {
        NSString *userrole = message[@"publisherRole"];
        if (userrole == nil) {
            userrole = @"";
        }
        chatModel.userRole = userrole;
    }
    chatModel.roleType = @"广播";
    return chatModel;
}


- (CGFloat)calculationUserNameWidht:(HDSChatDataModel *)model {
    CGFloat userNameWidht;
    CGFloat textHeight = 17;
    NSString *userName = model.userName;
    if (userName.length > 8) {
        userName = [userName substringToIndex:8];
    }
    if (model.isMyself) {
        userName = [NSString stringWithFormat:@"%@(我)：",userName];
    } else {
        userName = [NSString stringWithFormat:@"%@：",userName];
    }
    NSMutableAttributedString *textAttri = [[NSMutableAttributedString alloc]initWithString:userName];
    [textAttri addAttribute:NSForegroundColorAttributeName value:UIColor.whiteColor range:NSMakeRange(0, textAttri.length)];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.alignment = NSTextAlignmentLeft;
    style.minimumLineHeight = 0;
    style.maximumLineHeight = 0;
    style.lineBreakMode = NSLineBreakByCharWrapping;
    NSDictionary *dict = @{NSFontAttributeName:[UIFont systemFontOfSize:14],NSParagraphStyleAttributeName:style};
    [textAttri addAttributes:dict range:NSMakeRange(0, textAttri.length)];

    CGSize textSize = [textAttri boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, textHeight)
                                              options:NSStringDrawingUsesLineFragmentOrigin
                                              context:nil].size;
    textSize.width = ceilf(textSize.width);
    userNameWidht = textSize.width;
    
    return userNameWidht;
}

- (NSString *)getRoleType:(HDSChatDataModel *)model {
    NSString *roleStr = @"学生";
    if ([model.userRole isEqualToString:@"publisher"]) {//主讲
        roleStr = @"讲师";
    } else if ([model.userRole isEqualToString:@"student"]) {//学生或观众
        roleStr = @"观众";
    } else if ([model.userRole isEqualToString:@"host"]) {//主持人
        roleStr = @"主持人";
    } else if ([model.userRole isEqualToString:@"unknow"]) {//其他没有角色
        roleStr = @"";
    } else if ([model.userRole isEqualToString:@"teacher"]) {//助教
        roleStr = @"助教";
    }
    return roleStr;
}

// MARK: - Lazy
- (HDSSafeArray *)chat_array {
    if (!_chat_array) {
        _chat_array = [[HDSSafeArray alloc] init];
    }
    return _chat_array;
}

- (void)dealloc {
    
}

@end
