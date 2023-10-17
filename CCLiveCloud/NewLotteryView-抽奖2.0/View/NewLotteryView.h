//
//  NewLotteryView.h
//  CCLiveCloud
//
//  Created by Apple on 2020/11/13.
//  Copyright © 2020 MacBook Pro. All rights reserved.
//

#import <UIKit/UIKit.h>
@class NewLotteryMessageModel;
NS_ASSUME_NONNULL_BEGIN

typedef void (^BlockWithContentArray)(NSArray *array);

typedef void (^BlockWithCloseBtnClick)(BOOL  result);

@interface NewLotteryView : UIView
/** 用户输入中奖信息回调 */
@property (nonatomic, copy)   BlockWithContentArray         contentBlock;
/** 用户输入关闭抽奖页面回调 */
@property (nonatomic, copy)   BlockWithCloseBtnClick        closeBlock;
/** 是否能再次提交 */
@property (nonatomic, assign) BOOL                          isAgainCommit;
/**
 *    @brief    初始化方法
 *    @param    isScreenLandScape   是否是全屏
 *    @param    clearColor          clearColor
 */
- (instancetype)initIsScreenLandScape:(BOOL)isScreenLandScape
                           clearColor:(BOOL)clearColor;

/**
 *    @brief    抽奖结果
 *    @param    model               中奖信息
 *    @param    isScreenLandScape   是否横屏
 */
- (void)nLottery_resultWithModel:(NewLotteryMessageModel *)model
               isScreenLandScape:(BOOL)isScreenLandScape;
/**
 *    @brief    移除视图
 */
- (void)remove;
@end

NS_ASSUME_NONNULL_END
