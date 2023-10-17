//
//  UIImageView+Extension.m
//  CCLiveCloud
//
//  Created by Apple on 2020/11/4.
//  Copyright © 2020 MacBook Pro. All rights reserved.
//

#import "UIImageView+Extension.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "UIImage+animatedGIF.h"

@implementation UIImageView (Extension)

- (void)setHeader:(NSString *)url
{
    UIImage *placeholder = [UIImage imageNamed:@"lottery_icon_nor"];
    
    [self sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:placeholder completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        self.image = image ? image : placeholder;
    }];
}

- (void)setPic:(NSString *)picUrl {
    UIImage *placeholder = [UIImage imageNamed:@"lottery_icon_nor"];
    
    [self sd_setImageWithURL:[NSURL URLWithString:picUrl] placeholderImage:placeholder completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        self.image = image ? image : placeholder;
    }];
}

- (void)setRedPacketImage:(NSString *)url {
    UIImage *placeholder = [UIImage imageNamed:@"redPacket"];
    
    [self sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:placeholder completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        self.image = image ? image : placeholder;
    }];
}

- (void)setRedPacketRankBGImage:(NSString *)url {
    UIImage *placeholder = [UIImage imageNamed:@"redPacket_bg"];
    
    [self sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:placeholder completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        self.image = image ? image : placeholder;
    }];
}

- (void)setBigImage:(NSString *)url {
    UIImage *placeholder = [UIImage imageNamed:@"picture_load_fail"];
    [self sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:placeholder completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
            UIImage *tmpImg = [UIImage sd_animatedGIFWithData:imageData];
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.image = tmpImg ? tmpImg : placeholder;
            });
        });
    }];
}

@end
