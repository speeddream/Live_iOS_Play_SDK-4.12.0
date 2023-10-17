//
//  HDRedPacketRainInfo.h
//  CCLiveCloud
//
//  Created by Richard Lee on 7/1/21.
//  Copyright © 2021 MacBook Pro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HDRedPacketRainConfiguration : NSObject

/// 红包在屏幕上显示的时间
@property (nonatomic, assign) NSTimeInterval fallingTime;
/// 红包宽
@property (nonatomic, assign) CGFloat   itemW;
/// 红包高
@property (nonatomic, assign) CGFloat   itemH;
/// 是否显示倒计时动画
@property (nonatomic, assign) BOOL      isShowCountdownAnimation;
/// 父视图
@property (nonatomic, strong) UIView    *boardView;
/// 红包视图
@property (nonatomic, copy)   NSString  *redPacketImageName;
/// 红包封面图
@property (nonatomic, strong) NSArray                      *driftDownUrls;
/// 红包排行榜背景图
@property (nonatomic, copy)   NSString                     *rankBackgroundUrl;

/// ID
@property (nonatomic, copy)   NSString  *id;
/// 红包雨时长
@property (nonatomic, assign) NSInteger duration;
/// 红包雨开始时间
@property (nonatomic, assign) NSInteger startTime;
/// 当前系统时间
@property (nonatomic, assign) NSInteger currentTime;
/// 红包雨滑动速率  0:慢 1:中 2:快
@property (nonatomic, assign) NSInteger slidingRate;

@end

NS_ASSUME_NONNULL_END
