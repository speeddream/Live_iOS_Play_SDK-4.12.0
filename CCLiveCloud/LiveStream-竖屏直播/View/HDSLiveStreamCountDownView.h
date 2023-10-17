//
//  HDSLiveStreamCountDownView.h
//  CCLiveCloud
//
//  Created by richard lee on 12/19/22.
//  Copyright © 2022 MacBook Pro. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger,HDSLiveStreamCountDownViewType) {
    HDSLiveStreamCountDownViewTypeCenter, // 中心展示
    HDSLiveStreamCountDownViewTypeBottom, // 底部展示
};

@interface HDSLiveStreamCountDownView : UIView

@property (nonatomic, copy) NSString *playerBGHint;

- (void)setCountDown:(NSString *)countDown type:(HDSLiveStreamCountDownViewType)type;

@end

NS_ASSUME_NONNULL_END
