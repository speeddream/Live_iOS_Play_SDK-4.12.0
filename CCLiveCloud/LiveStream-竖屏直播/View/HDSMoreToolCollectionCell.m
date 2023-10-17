//
//  HDSMoreToolCollectionCell.m
//  CCLiveCloud
//
//  Created by richard lee on 1/10/23.
//  Copyright © 2023 MacBook Pro. All rights reserved.
//

#import "HDSMoreToolCollectionCell.h"
#import "HDSMoreToolItemModel.h"
#import "UIColor+RCColor.h"
#import <Masonry/Masonry.h>

@interface HDSMoreToolCollectionCell ()

@property (nonatomic, strong) UIImageView *itemIMGView;

@property (nonatomic, strong) UILabel *itemTitle;

@end

@implementation HDSMoreToolCollectionCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self configureUI];
        [self configureConstraints];
    }
    return self;
}

- (void)setModel:(HDSMoreToolItemModel *)model {
    _model = model;
    _itemIMGView.image = [UIImage imageNamed:model.imageName];
    _itemTitle.text = model.itemName;
}

// MARK: - Custom Method

- (void)configureUI {
    _itemIMGView = [[UIImageView alloc]init];
    _itemIMGView.contentMode = UIViewContentModeScaleAspectFit;
    [self.contentView addSubview:_itemIMGView];
    
    _itemTitle = [[UILabel alloc]init];
    _itemTitle.textColor = [UIColor colorWithHexString:@"#666666" alpha:1];
    _itemTitle.font = [UIFont systemFontOfSize:13];
    _itemTitle.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:_itemTitle];
}

- (void)configureConstraints {
    __weak typeof(self) weakSelf = self;
    [_itemIMGView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.contentView).offset(14);
        make.centerX.mas_equalTo(weakSelf.contentView);
        make.width.height.mas_equalTo(50);
    }];
    
    [_itemTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.itemIMGView.mas_bottom).offset(10);
        make.centerX.mas_equalTo(weakSelf.contentView);
    }];
}

@end
