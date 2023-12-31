//
//  UIImage+Extension.h
//  TextUtil
//
//  Created by zx_04 on 15/8/20.
//  Copyright (c) 2015年 joker. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Extension)

// 图片拉伸
+ (UIImage *)resizableImageWithName:(NSString *)imageName;


/**
 color转image
 
 @param color color
 @return image
 */
+(UIImage*)imageWithColor:(UIColor*) color;

+ (CGSize)getImageSizeWithURL:(id)URL;

@end
