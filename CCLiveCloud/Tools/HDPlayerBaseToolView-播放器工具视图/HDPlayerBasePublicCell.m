//
//  HDPlayerBasePublicCell.m
//  CCLiveCloud
//
//  Created by Apple on 2020/12/11.
//  Copyright © 2020 MacBook Pro. All rights reserved.
//

#import "HDPlayerBasePublicCell.h"
#import "HDPlayerBaseToolModel.h"
#import "UIColor+RCColor.h"
#import <Masonry/Masonry.h>

@interface HDPlayerBasePublicCell ()

@property (nonatomic, strong) UILabel      *mainTitle;

@end

@implementation HDPlayerBasePublicCell

/**
 *    @brief    初始化
 */
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)setupUI {
    _mainTitle = [[UILabel alloc]init];
    _mainTitle.textColor = [UIColor colorWithHexString:@"#FFFFFF" alpha:1];
    _mainTitle.font = [UIFont systemFontOfSize:16];
    _mainTitle.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:_mainTitle];
    [_mainTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self);
    }];
    [self layoutIfNeeded];
}

- (void)setModel:(HDPlayerBaseToolModel *)model {
    _model = model;
    _mainTitle.text = model.keyDesc;
    _mainTitle.textColor = model.isSelected == YES ? [UIColor colorWithHexString:@"#F89E0F" alpha:1] : [UIColor colorWithHexString:@"#FFFFFF" alpha:1];
}

@end
