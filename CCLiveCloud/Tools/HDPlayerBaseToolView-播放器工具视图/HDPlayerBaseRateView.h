//
//  HDPlayerBaseRateView.h
//  CCLiveCloud
//
//  Created by Apple on 2020/12/11.
//  Copyright © 2020 MacBook Pro. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class HDPlayerBaseModel;
/** 按钮点击事件回调 */
typedef void(^rateBlock)(HDPlayerBaseModel *model);

@interface HDPlayerBaseRateView : UIView

/** 倍速回调 */
@property (nonatomic, copy) rateBlock   rateBlock;
/**
 *    @brief    显示清晰度
 *    @param    rateArray       倍速数组
 *    @param    selectedRate    选中倍速
 */
- (void)playerBaseRateViewWithDataArray:(NSMutableArray *)rateArray
                           selectedRate:(NSString *)selectedRate;

@end

NS_ASSUME_NONNULL_END
