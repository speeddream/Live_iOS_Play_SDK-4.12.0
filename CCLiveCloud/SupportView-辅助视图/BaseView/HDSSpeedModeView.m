//
//  HDSSpeedModeView.m
//  CCLiveCloud
//
//  Created by Richard Lee on 8/11/21.
//  Copyright © 2021 MacBook Pro. All rights reserved.
//

#import "HDSSpeedModeView.h"
#import "UIColor+RCColor.h"
#import "CCcommonDefine.h"
#import <Masonry/Masonry.h>

@interface HDSSpeedModeView ()

@property (nonatomic, strong) UILabel       *speedLabel;

@property (nonatomic, assign) CGFloat       width;

@end

@implementation HDSSpeedModeView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithHexString:@"#000000" alpha:0.8f];
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    _speedLabel = [[UILabel alloc]init];
    _speedLabel.text = @"";
    _speedLabel.textColor = [UIColor whiteColor];
    _speedLabel.textAlignment = NSTextAlignmentCenter;
    _speedLabel.numberOfLines = 0;
    BOOL scale = self.frame.size.width < SCREEN_WIDTH ? YES : NO;
    _speedLabel.font = [UIFont systemFontOfSize:scale == YES ? 11.f : 14.f];
    [self addSubview:_speedLabel];
    [_speedLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self).offset(10.f);
        make.right.mas_equalTo(self).offset(-10.f);
        make.centerY.mas_equalTo(self);
    }];
}

// MARK: - API
/// 设置缓存速度
/// @param speed 速度
- (void)setSpeed:(NSString *)speed {
    _speedLabel.text = speed;
}

- (void)updateFrame:(CGRect)frame {
    BOOL scale = frame.size.width < SCREEN_WIDTH ? YES : NO;
    self.frame = frame;
    _speedLabel.font = [UIFont systemFontOfSize:scale == YES ? 11.f : 14.f];
    if (_width != frame.size.width) {
        [_speedLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self).offset(10.f);
            make.right.mas_equalTo(self).offset(-10.f);
            make.centerY.mas_equalTo(self);
        }];
    }
    _width = frame.size.width;
}

@end
