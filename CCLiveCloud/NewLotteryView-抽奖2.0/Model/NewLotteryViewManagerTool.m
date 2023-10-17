//
//  NewLotteryViewManagerTool.m
//  CCLiveCloud
//
//  Created by Apple on 2020/11/13.
//  Copyright © 2020 MacBook Pro. All rights reserved.
//

#import "NewLotteryViewManagerTool.h"
#define kLineMaxCount 4  //每一行最大个数

@implementation NewLotteryViewManagerTool
/**
 *    @brief    计算最大行数
 *    @param    array   数组
 */
+ (NSInteger)getMaxRowWithArray:(NSArray *)array
{
    if (array.count == 0) return 0;
    // 1.求余数
    int remainder = array.count % kLineMaxCount;
    // 2.计算行数
    NSInteger row = array.count / kLineMaxCount;
    row = remainder == 0 ? row : row + 1;
    return row;
}

/**
 *    @brief    获取单个宽高
 *    @param    width   父视图宽度
 */
+ (CGFloat)getSingleWHWithWidth:(CGFloat)width
{
    CGFloat singleWH = width / kLineMaxCount;
    return singleWH;
}

#pragma mark - 富文本设置部分字体颜色
/**
 *    @brief    富文本设置部分字体颜色
 *    @param    text        原始文本
 *    @param    rangeText   需要处理的文本
 *    @param    color       需要设置的颜色
 *    @param    font        字体
 *    @return   attributedString
 */
+ (NSMutableAttributedString *)setupAttributeString:(NSString *)text rangeText:(NSString *)rangeText textColor:(UIColor *)color font:(UIFont *)font
{
    NSRange hightlightTextRange = [text rangeOfString:rangeText];
    NSMutableAttributedString *attributeStr = [[NSMutableAttributedString alloc] initWithString:text];
    if (hightlightTextRange.length > 0) {
        [attributeStr addAttribute:NSForegroundColorAttributeName
                             value:color
                             range:hightlightTextRange];
        [attributeStr addAttribute:NSFontAttributeName value:font range:hightlightTextRange];
        return attributeStr;
    }else {
        return [rangeText copy];
    }
}

/**
 *    @brief    获取指定宽度width,字体大小fontSize,字符串value的高度
 *    @param    value       待计算的字符串
 *    @param    fontSize    字体的大小
 *    @param    width       限制字符串显示区域的宽度
 *    @result   float       返回的高度
 */
+ (CGFloat)heightForString:(NSString *)value fontSize:(float)fontSize andWidth:(float)width
{
    NSMutableAttributedString *textAttri = [[NSMutableAttributedString alloc]initWithString:value];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineBreakMode = UILineBreakModeWordWrap;
    NSDictionary *dict = @{NSFontAttributeName:[UIFont systemFontOfSize:fontSize],NSParagraphStyleAttributeName:style};
    [textAttri addAttributes:dict range:NSMakeRange(0, textAttri.length)];
    CGSize textSize = [textAttri boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX)
                                              options:NSStringDrawingUsesLineFragmentOrigin
                                              context:nil].size;
    textSize.height = ceilf(textSize.height);// + 1;
    return textSize.height;
}
@end
