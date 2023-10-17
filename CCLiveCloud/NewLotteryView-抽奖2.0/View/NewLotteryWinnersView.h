//
//  NewLotteryWinnersView.h
//  CCLiveCloud
//
//  Created by Apple on 2020/11/13.
//  Copyright © 2020 MacBook Pro. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^updateLotteryPrizeListHeight)(CGFloat height);

@interface NewLotteryWinnersView : UIView
/** 中奖名单 */
@property (nonatomic, strong) NSArray                      *prizeList;
/** 更新高度block */
@property (nonatomic, copy)   updateLotteryPrizeListHeight updateHeightBlock;

@end

NS_ASSUME_NONNULL_END
