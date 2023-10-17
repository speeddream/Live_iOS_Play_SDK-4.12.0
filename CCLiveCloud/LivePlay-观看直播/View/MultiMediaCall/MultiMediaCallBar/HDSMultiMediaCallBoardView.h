//
//  HDSMultiMediaCallBoardView.h
//  CCLiveCloud
//
//  Created by Richard Lee on 8/28/21.
//  Copyright © 2021 MacBook Pro. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HDSMultiMediaCallBoardView : UIView

/// 给view设置圆角
/// @param value 圆角大小
/// @param rectCorner 圆角位置
- (void)setCornerRadius:(CGFloat)value addRectCorners:(UIRectCorner)rectCorner;

@end

NS_ASSUME_NONNULL_END
