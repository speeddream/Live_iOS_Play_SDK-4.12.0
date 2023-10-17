//
//  HDSInteractionManager.h
//  CCLiveCloud
//
//  Created by richard lee on 3/16/22.
//  Copyright © 2022 MacBook Pro. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class HDSInteractionManagerConfig;

typedef enum : NSUInteger {
    landspace,      // 横屏
    portrait,       // 竖屏
} ScreenOrientation;

@interface HDSInteractionManager : NSObject

/// 互动组件
/// @param config 配置项
- (instancetype)initWithConfig:(HDSInteractionManagerConfig *)config;

/// 屏幕方向发生改变
/// @param orientation 方向
- (void)screenOrientationDidChange:(ScreenOrientation)orientation;


- (void)killAll;

- (void)streamDidEnd;
@end

NS_ASSUME_NONNULL_END
