//
//  HDSAudioModeView.m
//  CCLiveCloud
//
//  Created by Apple on 2020/12/21.
//  Copyright © 2020 MacBook Pro. All rights reserved.
//

#import "HDSAudioModeView.h"
#import "UIImage+animatedGIF.h"
#import "UIColor+RCColor.h"
#import "CCcommonDefine.h"
#import <Masonry/Masonry.h>

@interface HDSAudioModeView ()

@property (nonatomic, strong) UIImageView *kImageView;

@property (nonatomic, strong) UIImageView *audioView;

@property (nonatomic, strong) UILabel * soundLabel;

@end


@implementation HDSAudioModeView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithHexString:@"#FFFFFF" alpha:1];
        
        [self setupUI];
    }
    return self;
}

- (void)updateFrame:(CGRect)frame {
    
    self.frame = frame;
    
    [self setupUI];
}

- (void)setupUI {
    
    BOOL scale = self.frame.size.width < SCREEN_WIDTH ? YES : NO;
    WS(ws)
    if (_kImageView) {
        [_kImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(ws);
            make.centerY.equalTo(ws).offset(20);
        }];
    }else {
        /** 音频背景图片 */
        _kImageView = [[UIImageView alloc] initWithImage:[UIImage sd_animatedGIFNamed:@"gif_audio"]];
        [self addSubview:_kImageView];
        [_kImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(ws);
            make.centerY.equalTo(ws).offset(20);
        }];
    }
    CGFloat offSetY = scale == YES ? 1 : 20;
    if (_audioView) {
        [_audioView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(_kImageView);
            make.bottom.mas_equalTo(_kImageView.mas_top).offset(-offSetY);
        }];
    }else {
        /** 音频图标 */
        _audioView = [[UIImageView alloc]init];
        _audioView.image = [UIImage imageNamed:@"player_audio"];
        [self addSubview:_audioView];
        [_audioView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(_kImageView);
            make.bottom.mas_equalTo(_kImageView.mas_top).offset(-offSetY);
        }];
    }
    if (_soundLabel) {
        [_soundLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_kImageView);
            make.top.equalTo(_kImageView.mas_bottom).offset(25);
        }];
    }else {
        /** 音频模式 */
        _soundLabel = [[UILabel alloc] init];
        _soundLabel.textColor = [UIColor colorWithHexString:@"#000000" alpha:1];
        _soundLabel.text = PLAY_SOUND;
        _soundLabel.alpha = 0.5f;
        _soundLabel.font = [UIFont systemFontOfSize:FontSize_32];
        [self addSubview:_soundLabel];
        [_soundLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_kImageView);
            make.top.equalTo(_kImageView.mas_bottom).offset(25);
        }];
    }
    _soundLabel.hidden = scale == NO ? NO : YES;
}

- (void)dealloc {
    
}

@end
