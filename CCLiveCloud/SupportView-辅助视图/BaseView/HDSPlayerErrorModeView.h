//
//  HDSPlayerErrorModeView.h
//  CCLiveCloud
//
//  Created by Richard Lee on 8/11/21.
//  Copyright © 2021 MacBook Pro. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^BtnActionClosure)(void);

@interface HDSPlayerErrorModeView : UIView

/// 是否是音频
@property (nonatomic, assign) BOOL             isAudio;
/// 事件回调
@property (nonatomic, copy) BtnActionClosure   btnActionClosure;

/// 更新布局
/// @param frame 布局
- (void)updateFrame:(CGRect)frame;

/// 重制
- (void)reset;

@end

NS_ASSUME_NONNULL_END
