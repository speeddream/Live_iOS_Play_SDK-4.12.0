//
//  HDSLiveChatCell.h
//  CCLiveCloud
//
//  Created by Apple on 2022/5/10.
//  Copyright © 2022 MacBook Pro. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class HDSChatDataModel;

@interface HDSLiveChatCell : UITableViewCell

@property (nonatomic, strong) UIView           *backView;

@property (nonatomic, strong) NSDictionary *customEmojiDict;

@property (nonatomic, strong) HDSChatDataModel *model;

@end

NS_ASSUME_NONNULL_END
