//
//  HDAudioModeView.m
//  CCLiveCloud
//
//  Created by Apple on 2020/12/21.
//  Copyright © 2020 MacBook Pro. All rights reserved.
//

#import "HDAudioModeView.h"
#import "UIImage+animatedGIF.h"
#import "UIColor+RCColor.h"
#import "CCcommonDefine.h"
#import <Masonry/Masonry.h>

@implementation HDAudioModeView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithHexString:@"#FFFFFF" alpha:1];
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    BOOL scale = self.frame.size.width < SCREEN_WIDTH ? YES : NO;
    WS(ws)
    /** 音频背景图片 */
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage sd_animatedGIFNamed:@"gif_audio"]];
    [self addSubview:imageView];
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(ws);
        make.centerY.equalTo(ws).offset(20);
    }];
    /** 音频图标 */
    UIImageView *audioView = [[UIImageView alloc]init];
    audioView.image = [UIImage imageNamed:@"player_audio"];
    [self addSubview:audioView];
    CGFloat offSetY = scale == YES ? 1 : 20;
    [audioView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(imageView);
        make.bottom.mas_equalTo(imageView.mas_top).offset(-offSetY);
    }];
    /** 音频模式 */
    UILabel * soundLabel = [[UILabel alloc] init];
    soundLabel.textColor = [UIColor colorWithHexString:@"#000000" alpha:1];
    soundLabel.text = PLAY_SOUND;
    soundLabel.alpha = 0.5f;
    soundLabel.font = [UIFont systemFontOfSize:FontSize_32];
    soundLabel.hidden = scale == NO ? NO : YES;
    [self addSubview:soundLabel];
    [soundLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(imageView);
        make.top.equalTo(imageView.mas_bottom).offset(25);
    }];
    [self layoutIfNeeded];
}

@end
