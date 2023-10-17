//
//  HDSSupportView.h
//  CCLiveCloud
//
//  Created by Richard Lee on 8/11/21.
//  Copyright © 2021 MacBook Pro. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, HDSSupportViewBaseType) {
    HDSSupportViewBaseTypeAudio,        // 音频
    HDSSupportViewBaseTypePlayError,    // 播放错误
    HDSSupportViewBaseTypeTrialEnd,     // 试看结束
    HDSSupportViewBaseTypeNone,
};

typedef void(^ActionClosure)(void);

@interface HDSSupportView : UIView

/// 初始化
/// @param frame 布局
/// @param actionClosure 回调
- (instancetype)initWithFrame:(CGRect)frame actionClosure:(ActionClosure)actionClosure;

/// 设置类型
/// @param baseType     类型
/// @param boardView    父视图
- (void)setSupportBaseType:(HDSSupportViewBaseType)baseType boardView:(UIView *)boardView;

/// 缓存速度
/// @param speed 速度
- (void)setSpeed:(NSString *)speed;

/// 隐藏缓存速度
- (void)hiddenSpeed;

/// 释放
- (void)kRelease;
@end

NS_ASSUME_NONNULL_END
