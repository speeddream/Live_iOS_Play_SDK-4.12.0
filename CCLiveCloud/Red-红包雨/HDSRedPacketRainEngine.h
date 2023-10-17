//
//  HDSRedPacketRainEngine.h
//  CCLiveCloud
//
//  Created by 刘强强 on 2022/4/8.
//  Copyright © 2022 MacBook Pro. All rights reserved.
//

#import <Foundation/Foundation.h>
@import HDSRedEnvelopeModule;
NS_ASSUME_NONNULL_BEGIN


@class HDSRedPacketRainConfiguration;
@class HDSRedPacketRankModel;

/// 点击红包
typedef void(^TagRedPacketClosure)(int index);
/// 红包雨结束
typedef void(^EndRedPacketClosure)(void);
/// 关闭排名
typedef void(^CloseRankClosure)(void);

@interface HDSRedPacketRainEngine : NSObject
+ (instancetype)shared;

/// 准备红包雨信息
/// @param configuration 配置信息
/// @param tagRedPacketClosure 点击红包回调
/// @param endRedPacketClosure 红包雨结束回调
- (void)prepareRedPacketWithConfiguration:(HDSRedPacketRainConfiguration *)configuration
                      tapRedPacketClosure:(TagRedPacketClosure)tagRedPacketClosure
                      endRedPacketClosure:(EndRedPacketClosure)endRedPacketClosure;

/// 开始红包雨
- (void)startRedPacketRain;

/// 停止红包雨
- (void)stopRedRacketRain;

/// 显示红包雨排名
- (void)showRedPacketRainRank:(HDSRedEnvelopeWinningListModel *)model
             closeRankClosure:(CloseRankClosure)closeRankClosure;

- (void)killAll;

@end


NS_ASSUME_NONNULL_END
