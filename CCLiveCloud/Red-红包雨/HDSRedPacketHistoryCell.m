//
//  HDSRedPacketHistoryCell.m
//  CCLiveCloud
//
//  Created by 刘强强 on 2022/4/11.
//  Copyright © 2022 MacBook Pro. All rights reserved.
//

#import "HDSRedPacketHistoryCell.h"
#import "UIColor+RCColor.h"
#import <Masonry/Masonry.h>

@import HDSRedEnvelopeModule;

@interface HDSRedPacketHistoryCell ()

@property(nonatomic, strong)UIImageView *iconImg;
@property(nonatomic, strong)UILabel *nameLb;
@property(nonatomic, strong)UILabel *subTitleLb;
@property(nonatomic, strong)UILabel *moneyLb;
@property(nonatomic, strong)UILabel *timeLb;
@property(nonatomic, strong)UIView *lineView;
@end

@implementation HDSRedPacketHistoryCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupSubview];
    }
    return self;
}

- (void)setupSubview {
    
    [self.contentView addSubview:self.iconImg];
    [self.iconImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@14.5);
        make.top.equalTo(@14.5);
//        make.centerY.equalTo(self.contentView.mas_centerY);
        make.width.height.equalTo(@40);
        make.bottom.equalTo(@(-14.5));
    }];
    
    [self.contentView addSubview:self.moneyLb];
    [self.moneyLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView.mas_right).offset(-12);
        make.top.equalTo(self.contentView.mas_top).offset(15);
        make.width.equalTo(@100);
        make.height.equalTo(@16);
    }];
    
    [self.contentView addSubview:self.nameLb];
    [self.nameLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.iconImg.mas_right).offset(8);
        make.top.equalTo(self.contentView.mas_top).offset(15);
        make.right.equalTo(self.moneyLb.mas_left).offset(-5);
        make.height.equalTo(@16);
    }];
    
    
    [self.contentView addSubview:self.timeLb];
    [self.timeLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.moneyLb.mas_right);
        make.top.equalTo(self.moneyLb.mas_bottom).offset(7.5);
        make.height.equalTo(@14);
        make.bottom.equalTo(@(-14.5));
    }];
    
    
    [self.contentView addSubview:self.subTitleLb];
    [self.subTitleLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.nameLb.mas_left);
        make.top.equalTo(self.nameLb.mas_bottom).offset(8.5);
        make.height.equalTo(@14);
        make.bottom.equalTo(@(-14.5));
    }];
    
    [self.contentView addSubview:self.lineView];
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(12);
        make.right.equalTo(self.contentView);
        make.height.mas_equalTo(0.5);
        make.bottom.equalTo(self.contentView);
    }];
}

- (void)setModel:(HDSRedEnvelopeWinningUserListRecordModel *)model {
    _model = model;
    self.iconImg.image = [UIImage imageNamed:@"编组 3"];
    self.nameLb.text = model.redName;
    if (model.redKind == 1) {
        self.subTitleLb.text = @"红包雨";
        self.moneyLb.text = [NSString stringWithFormat:@"%.2f元",model.winPrice / 100.0];
    } else {
        self.subTitleLb.text = @"积分雨";
        self.moneyLb.text = [NSString stringWithFormat:@"%.2f分",model.winPrice];
    }
    self.timeLb.text = model.redSendTime;
}

#pragma mark - 懒加载
- (UIImageView *)iconImg {
    if (!_iconImg) {
        _iconImg = [[UIImageView alloc] init];
    }
    return _iconImg;
}

- (UILabel *)nameLb {
    if (!_nameLb) {
        _nameLb = [[UILabel alloc] init];
        _nameLb.numberOfLines = 1;
        _nameLb.font = [UIFont systemFontOfSize:15];
        _nameLb.textColor = [UIColor colorWithHexString:@"#121212" alpha:1];
    }
    return _nameLb;
}

- (UILabel *)subTitleLb {
    if (!_subTitleLb) {
        _subTitleLb = [[UILabel alloc] init];
        _subTitleLb.numberOfLines = 1;
        _subTitleLb.font = [UIFont systemFontOfSize:13];
        _subTitleLb.textColor = [UIColor colorWithHexString:@"#474747" alpha:1];
    }
    return _subTitleLb;
}

- (UILabel *)moneyLb {
    if (!_moneyLb) {
        _moneyLb = [[UILabel alloc] init];
        _moneyLb.textAlignment = NSTextAlignmentRight;
        _moneyLb.font = [UIFont systemFontOfSize:16];
        _moneyLb.numberOfLines = 1;
        _moneyLb.textColor = [UIColor colorWithHexString:@"#474747" alpha:1];
    }
    return _moneyLb;
}

- (UILabel *)timeLb {
    if (!_timeLb) {
        _timeLb = [[UILabel alloc] init];
        _timeLb.font = [UIFont systemFontOfSize:14];
        _timeLb.textAlignment = NSTextAlignmentRight;
        _timeLb.numberOfLines = 1;
        _timeLb.textColor = [UIColor colorWithHexString:@"#474747" alpha:1];
    }
    return _timeLb;
}

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc] init];
        _lineView.backgroundColor = [UIColor colorWithHexString:@"#EAEAEA" alpha:1];
    }
    return _lineView;
}
@end
