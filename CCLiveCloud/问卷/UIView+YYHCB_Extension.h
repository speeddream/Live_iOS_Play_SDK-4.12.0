//
//  UIView+YYHCB_Extension.h
//  YYHComponentsBased
//
//  Created by 刘强强 on 2019/7/22.
//  Copyright © 2019 刘强强. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

#pragma mark - YYHCB_layerExtension

@interface UIView (YYHCB_layerExtension)

/**
 给UIView增加圆角
 
 @param corner UIRectCorner
 @param shadowSize 圆角size
 */
- (void)yyhcb_addShadowLayerWithCorner:(UIRectCorner)corner shadowSize:(CGSize)shadowSize;

@end

#pragma mark - YYHCB_FindFirstResponder

@interface UIView (YYHCB_FindFirstResponder)

/**
 查找当前第一响应者
 
 @return 第一响应者
 */
- (id)yyhcb_findFirstResponder;

@end

#pragma mark - YYHCB_KeyboardCover

@interface UIView (YYHCB_KeyboardCover)<UIGestureRecognizerDelegate>

@property (strong, nonatomic) UITapGestureRecognizer * keyboardHideTapGesture;
@property (strong, nonatomic) UIView * objectView;

/// 第一响应者底部距键盘上沿间距，default 0
@property (nonatomic, assign) CGFloat yyhcb_keyboardMargin;
/**
 在initWithFrame中调用
 */
- (void)yyhcb_addKeyboardCorverNotification;
- (void)yyhcb_addKeyboardCorverGesture;

/**
 在dealloc中调用
 */
- (void)yyhcb_removeKeyboardCorverNotification;
- (void)yyhcb_removeKeyboardCorverGesture;

@end

@interface UIViewController (YYHCB_KeyboardCover)

/**
 在viewDidLoad中调用
 */
- (void)yyhcb_addKeyboardCorverNotification;
- (void)yyhcb_addKeyboardCorverGesture;

/**
 在dealloc中调用
 */
- (void)yyhcb_removeKeyboardCorverNotification;
- (void)yyhcb_removeKeyboardCorverGesture;


@end

NS_ASSUME_NONNULL_END
