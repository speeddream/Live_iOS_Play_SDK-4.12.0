//
//  UIImageView+Extension.h
//  CCLiveCloud
//
//  Created by Apple on 2020/11/4.
//  Copyright © 2020 MacBook Pro. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImageView (Extension)

/** 头像占位图 */
- (void)setHeader:(NSString *)url;
/** 图片 */
- (void)setPic:(NSString *)picUrl;

- (void)setRedPacketImage:(NSString *)url;

- (void)setRedPacketRankBGImage:(NSString *)url;

- (void)setBigImage:(NSString *)url;

@end

NS_ASSUME_NONNULL_END
