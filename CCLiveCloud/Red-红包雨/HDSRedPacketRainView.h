//
//  HDSRedPacketRainView.h
//  CCLiveCloud
//
//  Created by 刘强强 on 2022/4/8.
//  Copyright © 2022 MacBook Pro. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class HDSRedPacketRainConfiguration;
/// 点击红包
typedef void(^TagRedPacketClosure)(int index);
/// 红包雨结束
typedef void(^EndRedPacketClosure)(void);

@interface HDSRedPacketRainView : UIView
/// 初始化红包雨视图
/// @param frame 布局
/// @param configuration 配置信息
/// @param tagRedPacketClosure 点击红包回调
- (instancetype)initWithFrame:(CGRect)frame
                configuration:(HDSRedPacketRainConfiguration *)configuration
          tapRedPacketClosure:(TagRedPacketClosure)tagRedPacketClosure;

/// 开始红包雨
- (void)startPerformance;

/// 结束红包雨
- (void)stopPerformance;
/// 更新红包倒计时
- (void)updateTime:(NSInteger)timeCount;
@end

NS_ASSUME_NONNULL_END
