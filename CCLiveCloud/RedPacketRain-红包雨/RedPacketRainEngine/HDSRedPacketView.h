//
//  HDSRedPacketView.h
//  CCLiveCloud
//
//  Created by Richard Lee on 7/6/21.
//  Copyright © 2021 MacBook Pro. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class HDSRedPacketView;
@protocol HDSRedPacketViewDelegate <NSObject>

- (void)hdsViewDidTouch:(HDSRedPacketView *)touchView;

@end

@interface HDSRedPacketView : UIImageView

@property (nonatomic, weak) id<HDSRedPacketViewDelegate>delegate;

@end

NS_ASSUME_NONNULL_END
