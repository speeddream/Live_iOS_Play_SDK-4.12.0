//
//  HDSLiveBottomBar.h
//  CCLiveCloud
//
//  Created by richard lee on 4/28/22.
//  Copyright © 2022 MacBook Pro. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^chatBtnClosure)(void);

typedef void(^emojiBtnClosure)(void);

typedef void(^moreBtnClosure)(void);

typedef void(^otherBtnClosure)(void);

@interface HDSLiveBottomBar : UIView

@property (nonatomic, strong) chatBtnClosure chatBtnTapClosure;

@property (nonatomic, strong) emojiBtnClosure emojiBtnTapClosure;

@property (nonatomic, strong) moreBtnClosure moreBtnTapClosure;

@property (nonatomic, strong) otherBtnClosure otherBtnTapClosure;

/// 直播带货开关 0:关闭 1:直播间配置 2:全局配置
@property (nonatomic, assign) NSInteger liveStoreSwitch;
/// 聊天开关 YES 开 NO 关
@property (nonatomic, assign) BOOL isChatSwitch;

@end

NS_ASSUME_NONNULL_END
