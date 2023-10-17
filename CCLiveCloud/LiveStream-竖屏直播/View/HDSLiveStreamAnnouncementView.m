//
//  HDSLiveStreamAnnouncementView.m
//  CCLiveCloud
//
//  Created by richard lee on 12/19/22.
//  Copyright © 2022 MacBook Pro. All rights reserved.
//

#import "HDSLiveStreamAnnouncementView.h"
#import "HDSLiveStreamAutoScrollLabel.h"
#import "UIColor+RCColor.h"
#import <Masonry/Masonry.h>

@interface HDSLiveStreamAnnouncementView ()

@property (nonatomic, strong) UIImageView *announcementImageV;

@property (nonatomic, strong) HDSLiveStreamAutoScrollLabel *announcementLabel;

@property (nonatomic, strong) UIButton *tapBtn;

@property (nonatomic, copy) buttonTap buttonTap;

@end

@implementation HDSLiveStreamAnnouncementView

- (instancetype)initWithFrame:(CGRect)frame tapAction:(nonnull buttonTap)tapAction {
    if (self = [super initWithFrame:frame]) {
        __weak typeof(self) weakSelf = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            weakSelf.backgroundColor = [UIColor colorWithHexString:@"#000000" alpha:0.4];
            if (tapAction) {
                weakSelf.buttonTap = tapAction;
            }
            [weakSelf customUI];
            [weakSelf customConstraints];
        });
    }
    return self;
}

- (void)setAnnouncementText:(NSString *)text {
    _announcementLabel.text = text;
}

// MARK: - Custom UI
- (void)customUI {
    _announcementImageV = [[UIImageView alloc]init];
    _announcementImageV.image = [UIImage imageNamed:@"公告"];
    _announcementImageV.contentMode = UIViewContentModeCenter;
    [self addSubview:_announcementImageV];
    
    _announcementLabel = [[HDSLiveStreamAutoScrollLabel alloc]init];
    _announcementLabel.textColor = [UIColor colorWithHexString:@"#FFFFFF" alpha:1];
    [self addSubview:_announcementLabel];
    
    _tapBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self addSubview:_tapBtn];
    [_tapBtn addTarget:self action:@selector(buttonTap:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)customConstraints {
    __weak typeof(self) weakSelf = self;
    [_announcementImageV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf).offset(8);
        make.centerY.mas_equalTo(weakSelf);
        make.width.height.mas_equalTo(16);
    }];
    [_announcementImageV layoutIfNeeded];
    
    [_announcementLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf).offset(6);
        make.left.mas_equalTo(weakSelf.announcementImageV.mas_right).offset(5);
        make.bottom.mas_equalTo(weakSelf).offset(-6);
        make.right.mas_equalTo(weakSelf).offset(-5);
    }];
    [_announcementLabel layoutIfNeeded];
    
    [_tapBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(weakSelf);
    }];
}

- (void)buttonTap:(UIButton *)sender {
    if (_buttonTap) {
        _buttonTap();
    }
}

@end
