//
//  Utility.m
//  TextUtil
//
//  Created by zx_04 on 15/8/20.
//  Copyright (c) 2015年 joker. All rights reserved.
//

#import "Utility.h"
#import "CCSDK/RequestData.h"

@implementation Utility
/**
 *  将带有表情符的文字转换为图文混排的文字
 *
 *  @param text      带表情符的文字
 *  @param y         图片的y偏移值
 *
 *  @return 转换后的文字
 */
+ (NSMutableAttributedString *)emotionStrWithString:(NSString *)text y:(CGFloat)y
{
    //1、创建一个可变的属性字符串
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:text];
    //2、通过正则表达式来匹配字符串
    NSString *regex_emoji = @"\\[em2_[0-9][0-9]\\]"; //匹配表情
    regex_emoji = @"\\[.+?\\]";

    NSError *error = nil;
    NSRegularExpression *re = [NSRegularExpression regularExpressionWithPattern:regex_emoji options:NSRegularExpressionCaseInsensitive error:&error];
    if (!re) {
//        NSLog(@"%@", [error localizedDescription]);
        return attributeString;
    }
    
    NSArray *resultArray = [re matchesInString:text options:0 range:NSMakeRange(0, text.length)];
    //3、获取所有的表情以及位置
    //用来存放字典，字典中存储的是图片和图片对应的位置
    NSMutableArray *imageArray = [NSMutableArray arrayWithCapacity:resultArray.count];
    //根据匹配范围来用图片进行相应的替换
    for(NSTextCheckingResult *match in resultArray) {
        //获取数组元素中得到range
        NSRange range = [match range];
        //获取原字符串中对应的值
        NSString *subStr = [text substringWithRange:range];
        
        NSArray *emojiKeys = [RequestData emojiKeys];
        for (NSString *key in emojiKeys) {
            NSString *str = key;
//            NSLog(@"str = %@",str);
            if ([str isEqualToString:subStr]) {
                //face[i][@"png"]就是我们要加载的图片
                //新建文字附件来存放我们的图片,iOS7才新加的对象
                NSTextAttachment *textAttachment = [[NSTextAttachment alloc] init];
                //给附件添加图片
                textAttachment.image = [self getImageFromTag:subStr];
                textAttachment.lineLayoutPadding = 2.0;
                int space = 0;
                if (@available(iOS 15.0, *)) {
                  // code to run when on iOS 11+ and some_condition is true
                    space = 4;
                }
                //调整一下图片的位置,如果你的图片偏上或者偏下，调整一下bounds的y值即可
                textAttachment.bounds = CGRectMake(0, y, textAttachment.image.size.width + space, textAttachment.image.size.height);
                //把附件转换成可变字符串，用于替换掉源字符串中的表情文字
                NSAttributedString *imageStr = [NSAttributedString attributedStringWithAttachment:textAttachment];
                //把图片和图片对应的位置存入字典中
                NSMutableDictionary *imageDic = [NSMutableDictionary dictionaryWithCapacity:2];
                [imageDic setObject:imageStr forKey:@"image"];
                [imageDic setObject:[NSValue valueWithRange:range] forKey:@"range"];
                //把字典存入数组中
                [imageArray addObject:imageDic];
            }
        }

        
        for (int i = 1; i <= 20; i ++) {
            NSString *str = [NSString stringWithFormat:@"[em2_%02d]",i];
//            NSLog(@"str = %@",str);
            
            if ([str isEqualToString:subStr]) {
                //face[i][@"png"]就是我们要加载的图片
                //新建文字附件来存放我们的图片,iOS7才新加的对象
                NSTextAttachment *textAttachment = [[NSTextAttachment alloc] init];
                //给附件添加图片
                NSString *pic = [NSString stringWithFormat:@"%03d",i];
                textAttachment.lineLayoutPadding = 2.0;
//                textAttachment.image = [UIImage imageNamed:pic];
                textAttachment.image = [self getImageFromTag:subStr];
                int space = 0;
                if (@available(iOS 15.0, *)) {
                  // code to run when on iOS 11+ and some_condition is true
                    space = 4;
                }
                //调整一下图片的位置,如果你的图片偏上或者偏下，调整一下bounds的y值即可
                textAttachment.bounds = CGRectMake(0, y, textAttachment.image.size.width + space, textAttachment.image.size.height);
                //把附件转换成可变字符串，用于替换掉源字符串中的表情文字
                NSAttributedString *imageStr = [NSAttributedString attributedStringWithAttachment:textAttachment];
                //把图片和图片对应的位置存入字典中
                NSMutableDictionary *imageDic = [NSMutableDictionary dictionaryWithCapacity:2];
                [imageDic setObject:imageStr forKey:@"image"];
                [imageDic setObject:[NSValue valueWithRange:range] forKey:@"range"];
                //把字典存入数组中
                [imageArray addObject:imageDic];
            }
        }
    }
    
    //4、从后往前替换，否则会引起位置问题
    for (int i = (int)imageArray.count -1; i >= 0; i--) {
        NSRange range;
        [imageArray[i][@"range"] getValue:&range];
        //进行替换
        [attributeString replaceCharactersInRange:range withAttributedString:imageArray[i][@"image"]];
    }
    return attributeString;
}

+ (NSMutableAttributedString *)exchangeString:(NSString *)string withText:(NSString *)text imageName:(NSString *)imageName
{
    //1、创建一个可变的属性字符串
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:text];
    
    //2、匹配字符串
    NSError *error = nil;
    NSRegularExpression *re = [NSRegularExpression regularExpressionWithPattern:string options:NSRegularExpressionCaseInsensitive error:&error];
    if (!re) {
//        NSLog(@"%@", [error localizedDescription]);
        return attributeString;
    }
    
    NSArray *resultArray = [re matchesInString:text options:0 range:NSMakeRange(0, text.length)];
    //3、获取所有的图片以及位置
    //用来存放字典，字典中存储的是图片和图片对应的位置
    NSMutableArray *imageArray = [NSMutableArray arrayWithCapacity:resultArray.count];
    //根据匹配范围来用图片进行相应的替换
    for(NSTextCheckingResult *match in resultArray) {
        //获取数组元素中得到range
        NSRange range = [match range];
        //新建文字附件来存放我们的图片(iOS7才新加的对象)
        NSTextAttachment *textAttachment = [[NSTextAttachment alloc] init];
        //给附件添加图片
        textAttachment.image = [UIImage imageNamed:imageName];
        //修改一下图片的位置,y为负值，表示向下移动
        textAttachment.bounds = CGRectMake(0, -2, textAttachment.image.size.width, textAttachment.image.size.height);
        //把附件转换成可变字符串，用于替换掉源字符串中的表情文字
        NSAttributedString *imageStr = [NSAttributedString attributedStringWithAttachment:textAttachment];
        //把图片和图片对应的位置存入字典中
        NSMutableDictionary *imageDic = [NSMutableDictionary dictionaryWithCapacity:2];
        [imageDic setObject:imageStr forKey:@"image"];
        [imageDic setObject:[NSValue valueWithRange:range] forKey:@"range"];
        //把字典存入数组中
        [imageArray addObject:imageDic];
    }
    
    //4、从后往前替换，否则会引起位置问题
    for (int i = (int)imageArray.count -1; i >= 0; i--) {
        NSRange range;
        [imageArray[i][@"range"] getValue:&range];
        //进行替换
        [attributeString replaceCharactersInRange:range withAttributedString:imageArray[i][@"image"]];
    }
    
    return attributeString;
}

+ (UIImage *)getImageFromTag:(NSString *)tag {
    UIImage *img = nil;
    if([tag containsString:@"[em2_"]) {
        img = [self getImageFromTagLocal:tag];
    } else {
        img = [self getImageFromTagDowmload:tag];
    }
    return img;
}

+ (UIImage *)getImageFromTagLocal:(NSString *)tag {
    NSString *path = [NSBundle.mainBundle pathForResource:@"Emotions" ofType:@"plist"];
    if (!path) {
        return nil;
    }
    NSArray *array = [[NSArray alloc] initWithContentsOfFile:path];
    NSString *exprName = @"";
    for (NSDictionary *stickerDict in array) {
        NSArray *emojiArr = stickerDict[@"emoticons"];
        for (NSDictionary *emojiDict in emojiArr) {
            NSString *imageName = emojiDict[@"image"];
            NSString *emojiDescription = emojiDict[@"text"];
            NSString *imageTag = emojiDict[@"imageTag"];

            NSString *tagss = [NSString stringWithFormat:@"[%@]",imageTag];
            if([tagss isEqualToString:tag]) {
                exprName = imageName;
                break;
            }
        }
    }
    UIImage *emojiImage = [UIImage imageNamed:[@"Emotion.bundle" stringByAppendingPathComponent:exprName]];
    return emojiImage;
}
+ (UIImage *)getImageFromTagDowmload:(NSString *)tag {
    return [RequestData emojiCachedForName:tag];
}

+ (UIImage *)emojiFromEmojiName:(NSString *)emojiName {
    UIImage *img = nil;
    if([emojiName isEqualToString:@"[em2_"] || [emojiName containsString:@"Expression_"]) {
        img = [UIImage imageNamed:[@"Emotion.bundle" stringByAppendingPathComponent:emojiName]];
    } else {
        img = [RequestData emojiCachedForName:emojiName];
    }
    return img;
}


@end
