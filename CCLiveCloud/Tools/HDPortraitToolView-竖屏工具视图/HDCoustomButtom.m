//
//  HDCoustomButtom.m
//  CCLiveCloud
//
//  Created by Richard Lee on 3/31/21.
//  Copyright © 2021 MacBook Pro. All rights reserved.
//

#import "HDCoustomButtom.h"
#import "UIColor+RCColor.h"
#import "CCcommonDefine.h"
#import <Masonry/Masonry.h>

#define kFontSize 15
#define kTextColor @"#333333"
#define kSelectTextColor @"#FF842F"

@implementation HDCoustomButtom

// MARK: - API
- (instancetype)initWithFrame:(CGRect)frame textAlignment:(HDButtonTextAlignment)textAlignment {
    self = [super initWithFrame:frame];
    if (self) {
        _titleFont = [UIFont systemFontOfSize:kFontSize];
        _titleColor = [UIColor colorWithHexString:kTextColor alpha:1];
        _selectedTitleColor = [UIColor colorWithHexString:kSelectTextColor alpha:1];
        _isSelected = NO;
        _textAlignment = textAlignment;
    }
    return self;
}

- (void)setIsSelected:(BOOL)isSelected {
    _isSelected = isSelected;
    _btnTitleLabel.textColor = isSelected == YES ? _selectedTitleColor : _titleColor;
}

- (UILabel *)btnTitleLabel {
    if (!_btnTitleLabel) {
        _btnTitleLabel = [[UILabel alloc]init];
        _btnTitleLabel.font = _titleFont;
        _btnTitleLabel.textColor = _titleColor;
        [self addSubview:_btnTitleLabel];
        WS(weakSelf)
        [_btnTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            if (weakSelf.textAlignment == HDButtonTextAlignmentLeft) {
                make.left.mas_equalTo(weakSelf);
                make.centerY.mas_equalTo(weakSelf);
            }else if (weakSelf.textAlignment == HDButtonTextAlignmentRight) {
                make.right.mas_equalTo(weakSelf);
                make.centerY.mas_equalTo(weakSelf);
            }else {
                make.centerX.mas_equalTo(weakSelf);
                make.centerY.mas_equalTo(weakSelf);
            }
        }];
    }
    return _btnTitleLabel;
}

@end
