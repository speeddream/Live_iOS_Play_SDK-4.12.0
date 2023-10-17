//
//  HDSRedPacketView2.m
//  CCLiveCloud
//
//  Created by 刘强强 on 2022/4/8.
//  Copyright © 2022 MacBook Pro. All rights reserved.
//

#import "HDSRedPacketView2.h"
#import "UIImageView+Extension.h"

@implementation HDSRedPacketView2

- (void)setUrl:(NSString *)url {
    _url = url;
    [self setRedPacketImage:url];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if ([self.delegate respondsToSelector:@selector(hdsViewDidTouch:)]) {
        [self.delegate hdsViewDidTouch:self];
    }
}

@end
