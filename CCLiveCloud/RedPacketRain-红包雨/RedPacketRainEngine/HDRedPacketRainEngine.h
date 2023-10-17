//
//  HDRedPacketRainEngine.h
//  CCLiveCloud
//
//  Created by Richard Lee on 7/1/21.
//  Copyright © 2021 MacBook Pro. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class HDRedPacketRainConfiguration;
@class HDSRedPacketRankModel;

/// 点击红包
typedef void(^TagRedPacketClosure)(int index);
/// 红包雨结束
typedef void(^EndRedPacketClosure)(void);
/// 关闭排名
typedef void(^CloseRankClosure)(void);

@interface HDRedPacketRainEngine : NSObject

+ (instancetype)shared;

/// 准备红包雨信息
/// @param configuration 配置信息
/// @param tagRedPacketClosure 点击红包回调
/// @param endRedPacketClosure 红包雨结束回调
- (void)prepareRedPacketWithConfiguration:(HDRedPacketRainConfiguration *)configuration
                      tapRedPacketClosure:(TagRedPacketClosure)tagRedPacketClosure
                      endRedPacketClosure:(EndRedPacketClosure)endRedPacketClosure;

/// 开始红包雨
- (void)startRedPacketRain;

/// 停止红包雨
- (void)stopRedRacketRain;

/// 显示红包雨排名
- (void)showRedPacketRainRank:(HDSRedPacketRankModel *)model
             closeRankClosure:(CloseRankClosure)closeRankClosure;

@end

NS_ASSUME_NONNULL_END
