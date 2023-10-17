//
//  HDSPublicTipsView.h
//  CCLiveCloud
//
//  Created by richard lee on 3/9/23.
//  Copyright © 2023 MacBook Pro. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HDSPublicTipsView : UIView

/// 初始化提示视图
/// - Parameters:
///   - frame: 布局
///   - tips: 展示信息
- (instancetype)initWithFrame:(CGRect)frame tips:(NSString *)tips;

/// 更新提示信息
/// - Parameter tips: 提示信息
- (void)updateTips:(NSString *)tips;

@end

NS_ASSUME_NONNULL_END
