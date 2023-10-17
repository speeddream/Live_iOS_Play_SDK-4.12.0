//
//  HDSCustomTextView.m
//  CCLiveCloud
//
//  Created by richard lee on 3/14/23.
//  Copyright © 2023 MacBook Pro. All rights reserved.
//

#import "HDSCustomTextView.h"

@implementation HDSCustomTextView

- (CGRect)caretRectForPosition:(UITextPosition *)position {
    CGRect originalRect = [super caretRectForPosition:position];
    originalRect.size.height = self.font.lineHeight + 2;
    originalRect.size.width = 2;
    return originalRect;
}

@end
