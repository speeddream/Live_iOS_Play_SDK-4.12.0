//
//  HDPortraitToolAudioModeView.m
//  CCLiveCloud
//
//  Created by Apple on 2021/3/15.
//  Copyright © 2021 MacBook Pro. All rights reserved.
//

#import "HDPortraitToolAudioModeView.h"
#import "HDSwitch.h"
#import "HDPortraitToolModel.h"
#import "UIColor+RCColor.h"
#import "CCcommonDefine.h"
#import <Masonry/Masonry.h>

#define MainTitle @"音频模式："
#define kSelectedColor @"#F89E0F"
#define kDefaultColor @"#E1E1E1"
#define kDefaultTintColor @"#FFFFFF"

@interface HDPortraitToolAudioModeView ()

@property (nonatomic, strong) UILabel       *titleLabel;

@property (nonatomic, strong) HDSwitch      *audioSwitch;

@property (nonatomic, assign) BOOL          hasAudioMode;

@end

@implementation HDPortraitToolAudioModeView

//MARK: - API
- (instancetype)initWithFrame:(CGRect)frame hasAudioMode:(BOOL)hasAudioMode {
    self = [super initWithFrame:frame];
    if (self) {
        self.hasAudioMode = hasAudioMode;
        [self configureView];
    }
    return self;
}

- (void)setTargetModel:(HDPortraitToolModel *)targetModel {
    _targetModel = targetModel;
    if (self.hasAudioMode == NO) return;
    self.audioSwitch.on = _targetModel.isSelected;
}

//MARK: - CUSTOM METHOD
- (void)configureView {
    
    _titleLabel = [[UILabel alloc]init];
    _titleLabel.font = [UIFont systemFontOfSize:15];
    _titleLabel.textColor = [UIColor colorWithHexString:@"#666666" alpha:1];
    _titleLabel.text = MainTitle;
    [self addSubview:_titleLabel];
    WS(ws)
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(ws).offset(24);
        make.centerY.mas_equalTo(ws);
        make.width.mas_equalTo(75);
    }];
    [_titleLabel layoutIfNeeded];
    
    _audioSwitch = [[HDSwitch alloc]initWithFrame:CGRectMake(0, 0, 40, 17)];
    [_audioSwitch setTintColor:[UIColor colorWithHexString:kDefaultColor alpha:1]]; //关闭背景色
    [_audioSwitch setOnTintColor:[UIColor colorWithHexString:kSelectedColor alpha:1]]; //开启背景色
    [_audioSwitch setThumbTintColor:[UIColor colorWithHexString:kDefaultTintColor alpha:1]]; //按钮颜色
    [_audioSwitch addTarget:self action:@selector(audioSwitch:) forControlEvents:UIControlEventValueChanged];
    [self addSubview:_audioSwitch];
    [_audioSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(ws.titleLabel.mas_right).offset(10);
        make.centerY.mas_equalTo(ws);
        make.width.mas_equalTo(40);
        make.height.mas_equalTo(17);
    }];
    [_audioSwitch layoutIfNeeded];
}

- (void)audioSwitch:(HDSwitch *)sender {
    HDPortraitToolModel *model = [[HDPortraitToolModel alloc]init];
    model.value = @"";
    model.index = 0;
    model.isSelected = sender.isOn;
    model.desc = @"";
    model.type = HDPortraitToolTypeWithAudioMode;
    if (self.updateBlock) {
        self.updateBlock(model);
    }
}

@end
