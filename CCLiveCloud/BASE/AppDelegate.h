//
//  AppDelegate.h
//  CCLiveCloud
//
//  Created by MacBook Pro on 2018/10/19.
//  Copyright © 2018 MacBook Pro. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

- (void)addFuncView:(UIView *)view;
- (void)removeViewFuncView;
/// 4.5.1 new
@property (nonatomic, assign, getter=isLaunchScreen) BOOL launchScreen;    /**< 是否是横屏 */

@end

