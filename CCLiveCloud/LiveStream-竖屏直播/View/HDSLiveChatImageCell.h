//
//  HDSLiveChatImageCell.h
//  CCLiveCloud
//
//  Created by richard lee on 1/8/23.
//  Copyright © 2023 MacBook Pro. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class HDSChatDataModel;
@class CCImageView;

@interface HDSLiveChatImageCell : UITableViewCell

@property (nonatomic, strong) CCImageView *smallImageView;//图片视图
/**
 加载图片cell

 @param model 公聊数据模型
 @param input 是否有输入框
 @param indexPath 位置下标
 */
-(void)setImageModel:(HDSChatDataModel *)model
             isInput:(BOOL)input
           indexPath:(NSIndexPath *)indexPath;

@end

NS_ASSUME_NONNULL_END
