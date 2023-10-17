//
//  HDSSpeedModeView.h
//  CCLiveCloud
//
//  Created by Richard Lee on 8/11/21.
//  Copyright © 2021 MacBook Pro. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HDSSpeedModeView : UIView

/// 设置速度
/// @param speed 速度
- (void)setSpeed:(NSString *)speed;

/// 跟新布局
/// @param frame 布局
- (void)updateFrame:(CGRect)frame;

@end

NS_ASSUME_NONNULL_END
