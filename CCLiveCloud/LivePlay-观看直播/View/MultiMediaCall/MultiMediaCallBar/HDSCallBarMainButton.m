//
//  HDSCallBarMainButton.m
//  CCLiveCloud
//
//  Created by Richard Lee on 8/28/21.
//  Copyright © 2021 MacBook Pro. All rights reserved.
//

#import "HDSCallBarMainButton.h"

@interface HDSCallBarMainButton ()

@property (nonatomic, assign) HDSCallBarMainButtonType btnType;

@property (nonatomic, assign) BOOL                     isApply;

@end

@implementation HDSCallBarMainButton

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _isApply = YES;
        [self setImage:[UIImage imageNamed:@"callBar_dial"] forState:UIControlStateNormal];
    }
    return self;
}

- (void)updateCallType:(HDSCallBarMainButtonType)type {
    if (_btnType == type) return;
    NSString *imageName = @"";
    switch (type) {
        case HDSCallBarMainButtonTypeApply:
            imageName = @"callBar_dial";
            break;
        case HDSCallBarMainButtonTypeHangup:
            imageName = @"callBar_hangup";
            break;
        case HDSCallBarMainButtonTypeConnected:
            imageName = @"callBar_called_small";
            break;
        default:
            break;
    }
    [self setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    _btnType = type;
}

@end
