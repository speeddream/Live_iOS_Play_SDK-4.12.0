//
//  Utility.h
//  TextUtil
//
//  Created by zx_04 on 15/8/20.
//  Copyright (c) 2015年 joker. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

//点击自定义键盘按钮通知
#define KK_KB_EMOJI_CUSTOM_CLICKED            @"KK_KEYBOARD_EMOJI_CUSTOM_CLICKED"
//controller处理完通知
#define KK_KB_EMOJI_CUSTOM_CLICKED_RESULT     @"KK_KEYBOARD_EMOJI_CUSTOM_CLICKED_RESULT"

#define KK_EMOJI_LOAD_RES                     @"KK_EMOJI_LOAD_RES"

@interface Utility : NSObject

+ (NSMutableAttributedString *)emotionStrWithString:(NSString *)text y:(CGFloat)y;
/**
 *  将个别文字转换为特殊的图片
 *
 *  @param string    原始文字段落
 *  @param text      特殊的文字
 *  @param imageName 要替换的图片
 *
 *  @return  NSMutableAttributedString
 */
+ (NSMutableAttributedString *)exchangeString:(NSString *)string withText:(NSString *)text imageName:(NSString *)imageName;

+ (UIImage *)emojiFromEmojiName:(NSString *)emojiName;
@end
