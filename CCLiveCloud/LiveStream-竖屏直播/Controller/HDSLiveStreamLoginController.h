//
//  HDSLiveStreamLoginController.h
//  CCLiveCloud
//
//  Created by richard lee on 4/27/22.
//  Copyright © 2022 MacBook Pro. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HDSLiveStreamLoginController : UIViewController

/// 从网页端调起，如果是直播自动登录，调用此方法;
- (void)loginAction;

@end

NS_ASSUME_NONNULL_END
