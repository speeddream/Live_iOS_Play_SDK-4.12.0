//
//  HDSRedPacketView2.h
//  CCLiveCloud
//
//  Created by 刘强强 on 2022/4/8.
//  Copyright © 2022 MacBook Pro. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class HDSRedPacketView2;
@protocol HDSRedPacketView2Delegate <NSObject>

- (void)hdsViewDidTouch:(HDSRedPacketView2 *)touchView;

@end

@interface HDSRedPacketView2 : UIImageView
@property (nonatomic, weak) id<HDSRedPacketView2Delegate>delegate;
@property (nonatomic, copy) NSString *url;
@end

NS_ASSUME_NONNULL_END
