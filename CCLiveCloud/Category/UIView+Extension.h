//
//  UIView+Extension.h
//  demo
//
//  Created by Clark on 2017/10/24.
//  Copyright © 2017年 Clark. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Extension)

//宽高位置大小
@property (nonatomic, assign) CGFloat x;
@property (nonatomic, assign) CGFloat y;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, assign) CGSize size;

//中心点的x与y
@property (nonatomic, assign) CGFloat centerX;
@property (nonatomic, assign) CGFloat centerY;

/**
 * setCornerRadius   给view设置圆角
 * @param value      圆角大小
 * @param rectCorner 圆角位置
 **/
- (void)setCornerRadius:(CGFloat)value addRectCorners:(UIRectCorner)rectCorner;

@end
