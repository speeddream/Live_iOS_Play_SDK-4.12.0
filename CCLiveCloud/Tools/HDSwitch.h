//
//  HDSwitch.h
//  CCLiveCloud
//
//  Created by Apple on 2020/12/15.
//  Copyright © 2020 MacBook Pro. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HDSwitch : UIControl<UIGestureRecognizerDelegate>

@property (nonatomic, getter = isOn) BOOL on;

@property (nonatomic, strong) UIColor *onTintColor;

@property (nonatomic, strong) UIColor *tintColor;

@property (nonatomic, strong) UIColor *thumbTintColor;

@property (nonatomic, assign) BOOL shadow;

@property (nonatomic, strong) UIColor *tintBorderColor;

@property (nonatomic, strong) UIColor *onTintBorderColor;

@end

NS_ASSUME_NONNULL_END
