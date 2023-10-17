//
//  HDSLiveStreamTopChatCell.h
//  CCLiveCloud
//
//  Created by richard lee on 1/11/23.
//  Copyright © 2023 MacBook Pro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CCSDK/PlayParameter.h>
NS_ASSUME_NONNULL_BEGIN

typedef void(^btnTapBlock)(HDSLiveTopChatModel *tModel,BOOL isOpen,NSIndexPath *indPath);

@interface HDSLiveStreamTopChatCell : UICollectionViewCell

@property (nonatomic, copy) NSString *viewerId;

@property (nonatomic, strong) NSDictionary *customEmojiDict;

@property (nonatomic, strong) HDSLiveTopChatModel *model;

@property (nonatomic, strong) NSIndexPath *indexPath;

@property (nonatomic, copy)   btnTapBlock callBack;

@end

NS_ASSUME_NONNULL_END
