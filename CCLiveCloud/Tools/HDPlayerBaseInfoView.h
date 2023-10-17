//
//  HDPlayerBaseInfoView.h
//  CCLiveCloud
//
//  Created by Apple on 2020/11/27.
//  Copyright © 2020 MacBook Pro. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSUInteger, HDPlayerBaseInfoViewType) {
    HDPlayerBaseInfoViewTypeHidden = 0, //隐藏提示窗
    HDPlayerBaseInfoViewTypeWithError = 1, //提示错误信息
    HDPlayerBaseInfoViewTypeWithhRetry     = 2, //提示尝试中
    HDPlayerBaseInfoViewTypeWithOther     = 3, //提示其他信息
};
/** 按钮点击事件回调 */
typedef void(^actionBtnClickBlock)(NSString *string);

@interface HDPlayerBaseInfoView : UIView
/** 按钮事件回调 */
@property (nonatomic, copy)   actionBtnClickBlock   actionBtnClickBlock;

- (void)updatePlayerBaseInfoViewWithFrame:(CGRect)frame;
/**
 *    @brief    根据类型展示提示语
 *    @param    type    类型
 *    @param    tipStr  提示文字
 */
- (void)showTipStrWithType:(HDPlayerBaseInfoViewType)type withTipStr:(NSString *)tipStr;

@end

NS_ASSUME_NONNULL_END
