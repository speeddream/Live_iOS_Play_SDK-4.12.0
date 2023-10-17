//
//  HDSRedPacketHistoryView.h
//  CCLiveCloud
//
//  Created by 刘强强 on 2022/4/11.
//  Copyright © 2022 MacBook Pro. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HDSRedEnvelopeWinningUserListModel;
NS_ASSUME_NONNULL_BEGIN

@protocol HDSRedPacketHistoryViewDelegate <NSObject>

@optional
- (void)redPacketHistoryViewLoadMore;

- (void)redPacketHistoryViewLoadRefresh;

- (void)redPacketHistoryViewClose;

@end

@interface HDSRedPacketHistoryView : UIView

@property(nonatomic, weak) id<HDSRedPacketHistoryViewDelegate> delegate;

- (void)showHistory:(HDSRedEnvelopeWinningUserListModel *)model isFirst:(BOOL)isFirst;

@end

NS_ASSUME_NONNULL_END
