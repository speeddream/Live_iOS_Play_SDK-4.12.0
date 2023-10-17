//
//  HDRedPacketRankView.h
//  CCLiveCloud
//
//  Created by Richard Lee on 7/1/21.
//  Copyright © 2021 MacBook Pro. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class HDSRedPacketRankModel;
/// 关闭排名
typedef void(^CloseRankClosure)(void);

@interface HDRedPacketRankView : UIView

/// 初始化红包雨视图
/// @param model 配置信息
/// @param closeRankClosure 关闭排行视图
- (instancetype)initWithFrame:(CGRect)frame
                configuration:(HDSRedPacketRankModel *)model
             closeRankClosure:(CloseRankClosure)closeRankClosure;

@end

NS_ASSUME_NONNULL_END
