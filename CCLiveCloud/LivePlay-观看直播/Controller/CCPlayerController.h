//
//  CCPlayerController.h
//  CCLiveCloud
//
//  Created by MacBook Pro on 2018/10/22.
//  Copyright © 2018 MacBook Pro. All rights reserved.
//

#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface CCPlayerController : UIViewController

/**
 初始化

 @param roomName 直播间名称
 @return self
 */
- (instancetype)initWithRoomName:(NSString *)roomName;

/// 4.12.0 new 屏幕开关 YES 开启防录屏 NO 关闭防录屏
@property (nonatomic, assign) BOOL screenCaptureSwitch;

@end

NS_ASSUME_NONNULL_END
