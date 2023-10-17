//
//  HDSCallBarTipView.h
//  CCLiveCloud
//
//  Created by Richard Lee on 2021/8/29.
//  Copyright © 2021 MacBook Pro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HDSMultiMediaCallBarConfiguration.h"
NS_ASSUME_NONNULL_BEGIN

typedef void(^tipViewHangupBtnClosure)(void);

@interface HDSCallBarTipView : UIView

/// 初始化
/// @param frame 布局
/// @param closure 挂断按钮回掉（邀请连麦情况下）
- (instancetype)initWithFrame:(CGRect)frame
                         type:(HDSMultiMediaCallBarType)type
                      closure:(tipViewHangupBtnClosure)closure;

/// 更新视图
/// @param type 类型
- (void)updateCallBarTipViewWithType:(HDSMultiMediaCallBarType)type;

@end

NS_ASSUME_NONNULL_END
