//
//  HDSMultiMediaCallBoardView.m
//  CCLiveCloud
//
//  Created by Richard Lee on 8/28/21.
//  Copyright © 2021 MacBook Pro. All rights reserved.
//

#import "HDSMultiMediaCallBoardView.h"

@implementation HDSMultiMediaCallBoardView

/// 给view设置圆角
/// @param value 圆角大小
/// @param rectCorner 圆角位置
- (void)setCornerRadius:(CGFloat)value addRectCorners:(UIRectCorner)rectCorner {
    [self layoutIfNeeded];//这句代码很重要，不能忘了
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:rectCorner cornerRadii:CGSizeMake(value, value)];
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.frame = self.bounds;
    shapeLayer.path = path.CGPath;
    self.layer.mask = shapeLayer;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
}

@end
