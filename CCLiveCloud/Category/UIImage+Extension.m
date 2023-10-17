//
//  UIImage+Extension.m
//  TextUtil
//
//  Created by zx_04 on 15/8/20.
//  Copyright (c) 2015年 joker. All rights reserved.
//

#import "UIImage+Extension.h"
#import <ImageIO/ImageIO.h>

@implementation UIImage (Extension)

+ (UIImage *)resizableImageWithName:(NSString *)imageName
{
    
    // 加载原有图片
    UIImage *norImage = [UIImage imageNamed:imageName];
    // 获取原有图片的宽高的一半
    CGFloat w = norImage.size.width * 0.5;
    CGFloat top = norImage.size.height * 0.9;
    CGFloat bottom = norImage.size.height-top;
    // 生成可以拉伸指定位置的图片
    UIImage *newImage = [norImage resizableImageWithCapInsets:UIEdgeInsetsMake(top, w, bottom, w) resizingMode:UIImageResizingModeStretch];
    
    return newImage;
}
/**
 color转image
 
 @param color color
 @return image
 */
+(UIImage*)imageWithColor:(UIColor*) color
{
    CGRect rect=CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

/**
 *  根据图片url获取图片尺寸
 */
+ (CGSize)getImageSizeWithURL:(id)URL{
    NSURL * url = nil;
    if ([URL isKindOfClass:[NSURL class]]) {
        url = URL;
    }
    if ([URL isKindOfClass:[NSString class]]) {
        url = [NSURL URLWithString:URL];
    }
    if (!URL) {
        return CGSizeZero;
    }
    CGImageSourceRef imageSourceRef =     CGImageSourceCreateWithURL((CFURLRef)url, NULL);
    CGFloat width = 0, height = 0;
    if (imageSourceRef) {
        CFDictionaryRef imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSourceRef, 0, NULL);
        if (imageProperties != NULL) {
            CFNumberRef widthNumberRef = CFDictionaryGetValue(imageProperties, kCGImagePropertyPixelWidth);
            
//            if (widthNumberRef != NULL) {
//                CFNumberGetValue(widthNumberRef, kCFNumberFloat64Type, &width);
//            }
//            CFNumberRef heightNumberRef = CFDictionaryGetValue(imageProperties, kCGImagePropertyPixelHeight);
//            if (heightNumberRef != NULL) {
//                CFNumberGetValue(heightNumberRef, kCFNumberFloat64Type, &height);
//            }
            //判断设备是否为64位
#if defined(__LP64__) && __LP64__
            if (widthNumberRef != NULL) {
                CFNumberGetValue(widthNumberRef, kCFNumberFloat64Type, &width);
            }
            CFNumberRef heightNumberRef = CFDictionaryGetValue(imageProperties, kCGImagePropertyPixelHeight);
            if (heightNumberRef != NULL) {
                CFNumberGetValue(heightNumberRef, kCFNumberFloat64Type, &height);
            }
#else
            if (widthNumberRef != NULL) {
                CFNumberGetValue(widthNumberRef, kCFNumberFloat32Type, &width);
            }
            CFNumberRef heightNumberRef = CFDictionaryGetValue(imageProperties, kCGImagePropertyPixelHeight);
            if (heightNumberRef != NULL) {
                CFNumberGetValue(heightNumberRef, kCFNumberFloat32Type, &height);
            }
#endif
            
            CFRelease(imageProperties);
        }
        CFRelease(imageSourceRef);
    }
    return CGSizeMake(width, height);
}

@end
