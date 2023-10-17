//
//  UIView+YYHCB_Extension.m
//  YYHComponentsBased
//
//  Created by 刘强强 on 2019/7/22.
//  Copyright © 2019 刘强强. All rights reserved.
//

#import "UIView+YYHCB_Extension.h"
#import <objc/runtime.h>

@implementation UIView (YYHCB_layerExtension)

+ (void)load {
    Method YYHCB__layoutSubviews = class_getInstanceMethod(self, @selector(YYHCB__layoutSubviews));
    Method layoutSubviews = class_getInstanceMethod(self, @selector(layoutSubviews));
    method_exchangeImplementations(YYHCB__layoutSubviews, layoutSubviews);
}

- (void)yyhcb_addShadowLayerWithCorner:(UIRectCorner)corner shadowSize:(CGSize)shadowSize
{
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc]init];
    self.layer.mask = maskLayer;
    objc_setAssociatedObject(self, "YYHCB_maskLayer", maskLayer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(self, "YYHCB_corner", @(corner), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(self, "YYHCB_shadowSize", [NSValue valueWithCGSize:shadowSize], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)YYHCB__layoutSubviews {
    [self YYHCB__layoutSubviews];
    CAShapeLayer *layer = objc_getAssociatedObject(self, "YYHCB_maskLayer");
    if (layer) {
        UIRectCorner corner = [objc_getAssociatedObject(self, "YYHCB_corner") unsignedIntegerValue];
        CGSize shadowSize =  [(NSValue *)objc_getAssociatedObject(self, "YYHCB_shadowSize") CGSizeValue];
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:corner cornerRadii:shadowSize];
        layer.path = maskPath.CGPath;
        layer.frame = self.bounds;
    }
}

@end


@implementation UIView (YYHCB_FindFirstResponder)

- (id)yyhcb_findFirstResponder
{
    if (self.isFirstResponder) {
        return self;
    }
    for (UIView *subView in self.subviews) {
        id responder = [subView yyhcb_findFirstResponder];
        if (responder) return responder;
    }
    return nil;
}
@end

@implementation UIView (YYHCB_KeyboardCover)

@dynamic keyboardHideTapGesture;
@dynamic objectView;

#pragma mark - setter getter

- (void)setKeyboardHideTapGesture:(UITapGestureRecognizer *)keyboardHideTapGesture{
    objc_setAssociatedObject(self, _cmd, keyboardHideTapGesture, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id)keyboardHideTapGesture{
    return objc_getAssociatedObject(self, @selector(setKeyboardHideTapGesture:));
}

- (void)setObjectView:(UIView *)objectView{
    objc_setAssociatedObject(self, _cmd, objectView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id)objectView{
    return objc_getAssociatedObject(self, @selector(setObjectView:));
}

- (void)setYyhcb_keyboardMargin:(CGFloat)keyboardMargin {
    objc_setAssociatedObject(self, _cmd, @(keyboardMargin), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGFloat)yyhcb_keyboardMargin {
    return [objc_getAssociatedObject(self, @selector(setYyhcb_keyboardMargin:)) floatValue];
}


- (void)yyhcb_addKeyboardCorverNotification{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardNotify:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardNotify:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardNotify:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

#pragma mark - 增加手势

- (void)yyhcb_addKeyboardCorverGesture
{
    UITapGestureRecognizer* tap =  [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    //设置成NO表示当前控件响应后会传播到其他控件上，默认为YES
    tap.cancelsTouchesInView = NO;
    tap.delegate = self;
    [self setKeyboardHideTapGesture:tap];
    [self addGestureRecognizer:self.keyboardHideTapGesture];
    
    objc_setAssociatedObject(self, _cmd, tap, OBJC_ASSOCIATION_ASSIGN);
    
    if ([self respondsToSelector:@selector(gestureRecognizer:shouldRecognizeSimultaneouslyWithGestureRecognizer:)]) {
        Method gestureRecognizer = class_getInstanceMethod(self.class, @selector(gestureRecognizer:shouldRecognizeSimultaneouslyWithGestureRecognizer:));
        Method __gestureRecognizer = class_getInstanceMethod(self.class, @selector(__gestureRecognizer:shouldRecognizeSimultaneouslyWithGestureRecognizer:));
        method_exchangeImplementations(gestureRecognizer, __gestureRecognizer);
    }
    
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)__gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if ([otherGestureRecognizer.view.class conformsToProtocol:NSProtocolFromString(@"UITextInput")]  && [gestureRecognizer isEqual:objc_getAssociatedObject(self, @selector(yyhcb_addKeyboardCorverGesture))]) {
        return NO;
    }
    return [self __gestureRecognizer:gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:otherGestureRecognizer];
}

- (void)yyhcb_removeKeyboardCorverGesture {
    
    [self dismissKeyboard];
    [self removeGestureRecognizer:self.keyboardHideTapGesture];
}

- (void)dismissKeyboard
{
    [[UIApplication sharedApplication].keyWindow endEditing:YES];
    
}

- (void)yyhcb_removeKeyboardCorverNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)findFirstResponse:(UIView *)view{
    UIView * ojView = self.objectView;
    ojView = nil;
    for (UIView * tempView in view.subviews) {
        if ([tempView isFirstResponder] &&
            ([tempView isKindOfClass:[UITextField class]] ||
             [tempView isKindOfClass:[UITextView class]])) {//要进行类型判断
                [self setObjectView:tempView];
            }
        if (tempView.subviews.count != 0) {
            [self findFirstResponse:tempView];
        }
    }
}

#pragma mark - UIKeyboardWillHideNotification UIKeyboardWillShowNotification

- (void)keyboardNotify:(NSNotification *)notify{
    
    NSValue * frameNum = [notify.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect rect = frameNum.CGRectValue;
    CGFloat keyboardHeight = rect.size.height;//键盘高度
    
    CGFloat duration = [[notify.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];//获取键盘动画持续时间
    NSInteger curve = [[notify.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];//获取动画曲线
    
    if ([notify.name isEqualToString:UIKeyboardWillShowNotification] //键盘显示
        || [notify.name isEqualToString:UIKeyboardWillChangeFrameNotification]) {
        //键盘高度变化，主要用于第三方键盘会多次触发键盘弹起及高度变化的通知
        [self findFirstResponse:self];
        UIView * tempView = self.objectView;
        CGPoint point = [tempView convertPoint:CGPointMake(0, 0) toView:[UIApplication sharedApplication].keyWindow];//计算响应者到和屏幕的绝对位置
        CGFloat screenH = [UIScreen mainScreen].bounds.size.height;
        CGFloat keyboardY = screenH - keyboardHeight;
        CGFloat tempHeight = point.y + tempView.frame.size.height + tempView.yyhcb_keyboardMargin;
        CGRect beginRect = [[notify.userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
        
        if (tempHeight > keyboardY || beginRect.size.height > rect.size.height) {
            CGFloat offsetY;
            if (screenH-tempHeight < 0) {//判断是否超出了屏幕,超出屏幕做偏移纠正
                offsetY = keyboardY - tempHeight + (tempHeight-screenH);
            } else {
                offsetY = keyboardY - tempHeight;
            }
            
            CGAffineTransform transform = CGAffineTransformTranslate(self.transform, 0, offsetY);
            CGPoint applyPoint = CGPointApplyAffineTransform(CGPointZero, transform);
            if (applyPoint.y > 0) {// 如果是向下偏移，则忽略
                return;
            }
            if (duration > 0) {
                [UIView animateWithDuration:duration delay:0 options:curve animations:^{
                    self.transform = CGAffineTransformTranslate(self.transform, 0, offsetY);// CGAffineTransformMakeTranslation(0, offsetY);
                } completion:^(BOOL finished) {
                    
                }];
            }else{
                self.transform = CGAffineTransformTranslate(self.transform, 0, offsetY);//CGAffineTransformMakeTranslation(0, offsetY);
            }
            
        }
        
    } else if ([notify.name isEqualToString:UIKeyboardWillHideNotification]) {//键盘隐藏
        if (duration > 0) {
            [UIView animateWithDuration:duration delay:0 options:curve animations:^{
                self.transform = CGAffineTransformIdentity;
            } completion:^(BOOL finished) {
                
            }];
        }else{
            self.transform = CGAffineTransformIdentity;
        }
    }
}

@end

@implementation UIViewController (YYHCB_KeyboardCover)

- (void)yyhcb_addKeyboardCorverNotification{
    [self.view yyhcb_addKeyboardCorverNotification];
}

- (void)yyhcb_addKeyboardCorverGesture
{
    [self.view yyhcb_addKeyboardCorverGesture];
}

- (void)yyhcb_removeKeyboardCorverNotification
{
    [self.view yyhcb_removeKeyboardCorverNotification];
}

- (void)yyhcb_removeKeyboardCorverGesture
{
    [self.view yyhcb_removeKeyboardCorverGesture];
}

@end
