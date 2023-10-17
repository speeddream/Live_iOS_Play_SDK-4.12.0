//
//  NewLotteryViewManagerTool.h
//  CCLiveCloud
//
//  Created by Apple on 2020/11/13.
//  Copyright © 2020 MacBook Pro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NewLotteryViewManagerTool : NSObject
/**
 *    @brief    计算最大行数
 *    @param    array   数组
 */
+ (NSInteger)getMaxRowWithArray:(NSArray *)array;

/**
 *    @brief    获取单个宽高
 *    @param    width   父视图宽度
 */
+ (CGFloat)getSingleWHWithWidth:(CGFloat)width;

/**
 *    @brief    富文本设置部分字体颜色
 *    @param    text        原始文本
 *    @param    rangeText   需要处理的文本
 *    @param    color       需要设置的颜色
 *    @param    font        字体
 *    @return   attributedString
 */
+ (NSMutableAttributedString *)setupAttributeString:(NSString *)text rangeText:(NSString *)rangeText textColor:(UIColor *)color font:(UIFont *)font;

/**
 *    @brief    获取指定宽度width,字体大小fontSize,字符串value的高度
 *    @param    value       待计算的字符串
 *    @param    fontSize    字体的大小
 *    @param    width       限制字符串显示区域的宽度
 *    @result   float       返回的高度
 */
+ (CGFloat)heightForString:(NSString *)value fontSize:(float)fontSize andWidth:(float)width;
@end

NS_ASSUME_NONNULL_END
