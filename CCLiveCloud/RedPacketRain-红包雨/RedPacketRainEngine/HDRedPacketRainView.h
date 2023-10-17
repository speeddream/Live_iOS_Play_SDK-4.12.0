//
//  HDRedPacketRainView.h
//  CCLiveCloud
//
//  Created by Richard Lee on 7/1/21.
//  Copyright © 2021 MacBook Pro. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class HDRedPacketRainConfiguration;
/// 点击红包
typedef void(^TagRedPacketClosure)(int index);
/// 红包雨结束
typedef void(^EndRedPacketClosure)(void);

@interface HDRedPacketRainView : UIView

/// 初始化红包雨视图
/// @param frame 布局
/// @param configuration 配置信息
/// @param tagRedPacketClosure 点击红包回调
- (instancetype)initWithFrame:(CGRect)frame
                configuration:(HDRedPacketRainConfiguration *)configuration
          tapRedPacketClosure:(TagRedPacketClosure)tagRedPacketClosure;

/// 开始红包雨
- (void)startPerformance;

/// 结束红包雨
- (void)stopPerformance;

@end

NS_ASSUME_NONNULL_END
