//
//  NewLotteryHeaderView.h
//  CCLiveCloud
//
//  Created by Apple on 2020/11/13.
//  Copyright © 2020 MacBook Pro. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^headerTouchBlock)(NSString *string);

@interface NewLotteryHeaderView : UIView
/** 结束编辑 */
@property (nonatomic, copy) headerTouchBlock headerTouchBlock;
/**
 *    @brief    设置中奖信息
 *    @param    myself      是否中奖
 *    @param    code        中奖码
 *    @param    prizeName   奖品名称
 *    @param    tip         提示语
 */
- (void)nLottery_HeaderViewWithMySelf:(BOOL)myself
                                 code:(NSString *)code
                            prizeName:(NSString *)prizeName
                                  tip:(NSString *)tip;
@end

NS_ASSUME_NONNULL_END
