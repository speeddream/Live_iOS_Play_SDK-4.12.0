//
//  HDSRedPacketView.m
//  CCLiveCloud
//
//  Created by Richard Lee on 7/6/21.
//  Copyright © 2021 MacBook Pro. All rights reserved.
//

#import "HDSRedPacketView.h"

@implementation HDSRedPacketView

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if ([self.delegate respondsToSelector:@selector(hdsViewDidTouch:)]) {
        [self.delegate hdsViewDidTouch:self];
    }
}

@end
