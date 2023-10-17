//
//  HDSRedPacketRankView.h
//  CCLiveCloud
//
//  Created by 刘强强 on 2022/4/8.
//  Copyright © 2022 MacBook Pro. All rights reserved.
//

#import <UIKit/UIKit.h>
@import HDSRedEnvelopeModule;
NS_ASSUME_NONNULL_BEGIN
@class HDSRedPacketRankModel;
/// 关闭排名
typedef void(^CloseRankClosure)(void);

@interface HDSRedPacketRankView : UIView

/// 初始化红包雨视图
/// @param model 配置信息
/// @param closeRankClosure 关闭排行视图
- (instancetype)initWithFrame:(CGRect)frame
                configuration:(HDSRedEnvelopeWinningListModel *)model
             closeRankClosure:(CloseRankClosure)closeRankClosure;

/// 初始化红包雨视图
/// @param model 配置信息
/// @param closeRankClosure 关闭排行视图
- (instancetype)initWithFrame:(CGRect)frame
            rankBackgroundUrl:(NSString *)rankBackgroundUrl
                configuration:(HDSRedEnvelopeWinningListModel *)model
             closeRankClosure:(CloseRankClosure)closeRankClosure;
@end

NS_ASSUME_NONNULL_END
