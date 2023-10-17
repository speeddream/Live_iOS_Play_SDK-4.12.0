//
//  HDSStreamLiveAndQualityPublicCell.m
//  CCLiveCloud
//
//  Created by richard lee on 1/11/23.
//  Copyright © 2023 MacBook Pro. All rights reserved.
//

#import "HDSStreamLiveAndQualityPublicCell.h"
#import "UIColor+RCColor.h"
#import "CCcommonDefine.h"
#import <Masonry/Masonry.h>

@interface HDSStreamLiveAndQualityPublicCell ()

@property (nonatomic, strong) UILabel *mainLabel;

@end

@implementation HDSStreamLiveAndQualityPublicCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor colorWithHexString:@"#FFFFFF" alpha:1];
        [self configureUI];
        [self configureConstraints];
    }
    return self;
}

- (void)setCellTitle:(NSString *)title isSelected:(BOOL)isSelected {
    _mainLabel.text = title;
    _mainLabel.textColor = [UIColor colorWithHexString:@"#333333" alpha:1];
    _mainLabel.layer.borderColor = [UIColor colorWithHexString:@"#FFFFFF" alpha:1].CGColor;
    _mainLabel.layer.borderWidth = 1;
    if (isSelected) {
        _mainLabel.textColor = [UIColor colorWithHexString:@"#FF842F" alpha:1];
        _mainLabel.layer.borderColor = [UIColor colorWithHexString:@"#FF842F" alpha:1].CGColor;
        _mainLabel.layer.borderWidth = 1;
    }
}

// MARK: - Custom Method
- (void)configureUI {
    _mainLabel = [[UILabel alloc]init];
    _mainLabel.textColor = [UIColor colorWithHexString:@"#333333" alpha:1];
    _mainLabel.font = [UIFont systemFontOfSize:14];
    _mainLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:_mainLabel];
}

- (void)configureConstraints {
    __weak typeof(self) weakSelf = self;
    CGFloat labelWidth = SCREEN_WIDTH / 375 * 105;
    [_mainLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.centerY.mas_equalTo(weakSelf.contentView);
        make.width.mas_equalTo(labelWidth);
        make.height.mas_equalTo(35);
    }];
    _mainLabel.layer.cornerRadius = 17.5;
    _mainLabel.layer.masksToBounds = YES;
    _mainLabel.layer.borderColor = [UIColor colorWithHexString:@"#FFFFFF" alpha:1].CGColor;
    _mainLabel.layer.borderWidth = 1;
}



@end
