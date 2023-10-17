//
//  HDSChatDataModel.h
//  CCLiveCloud
//
//  Created by Apple on 2022/5/5.
//  Copyright © 2022 MacBook Pro. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HDSChatDataModel : NSObject

@property (nonatomic, copy)   NSString      *chatId;

@property (nonatomic, assign) NSInteger     checkStatus;

@property (nonatomic, assign) NSInteger     filterStatus;

@property (nonatomic, copy)   NSString      *groupId;

@property (nonatomic, copy)   NSString      *msg;

@property (nonatomic, assign) NSInteger     status;

@property (nonatomic, copy)   NSString      *time;

@property (nonatomic, copy)   NSString      *userAvatar;

@property (nonatomic, copy)   NSString      *userId;

@property (nonatomic, copy)   NSString      *userName;

@property (nonatomic, copy)   NSString      *userRole;

@property (nonatomic, copy)   NSString      *roleType;

@property (nonatomic, copy)   NSString      *roleTypeColor;

@property (nonatomic, assign) BOOL          isMyself;

@property (nonatomic, assign) CGFloat       nameWidth;

@property (nonatomic, copy)   NSString      *boardCastId;

@property (nonatomic, assign) CGSize        imageSize;
@end

NS_ASSUME_NONNULL_END
