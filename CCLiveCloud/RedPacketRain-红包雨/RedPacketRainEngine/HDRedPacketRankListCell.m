//
//  HDRedPacketRankListCell.m
//  CCLiveCloud
//
//  Created by Richard Lee on 7/2/21.
//  Copyright © 2021 MacBook Pro. All rights reserved.
//

#import "HDRedPacketRankListCell.h"
#import "CCSDK/PlayParameter.h"
#import "CCcommonDefine.h"
#import <Masonry/Masonry.h>

#define kSubTitleColor CCRGBAColor(51, 51, 51, 1)
#define kMyselfColor CCRGBAColor(242, 86, 66, 1)
#define kGlod @"redPacket_gold"
#define kSilver @"redPacket_silver"
#define kBronze @"redPacket_bronze"

@interface HDRedPacketRankListCell ()

@property (nonatomic, strong) UIImageView   *iconView;

@property (nonatomic, strong) UILabel       *subTitle;

@property (nonatomic, strong) UILabel       *scoreLabel;

@end

@implementation HDRedPacketRankListCell

// MARK: - API
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
        if (@available(iOS 12.0, *)) {
            switch (self.traitCollection.userInterfaceStyle) {
                case UIUserInterfaceStyleDark :{
                    self.backgroundColor = [UIColor whiteColor];
                }break;
                default:
                    break;
            }
        }
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

/// cell数据源
/// @param model 排名数据
/// @param row 对应行
- (void)redPacketRankListCellWithModel:(HDSRedRacketRankListModel *)model row:(NSInteger)row {
    if (row == 0) { // 金牌
        self.iconView.hidden = NO;
        self.iconView.image = [UIImage imageNamed:kGlod];
    }else if (row == 1) { // 银牌
        self.iconView.hidden = NO;
        self.iconView.image = [UIImage imageNamed:kSilver];
    }else if (row == 2) { // 铜牌
        self.iconView.hidden = NO;
        self.iconView.image = [UIImage imageNamed:kBronze];
    }else {
        self.iconView.hidden = YES;
    }
    if (model.isMyself == YES) {
        self.subTitle.text = [NSString stringWithFormat:@"%@ (我)",model.userName];
        self.subTitle.textColor = kMyselfColor;
    }else {
        self.subTitle.text = model.userName;
        self.subTitle.textColor = kSubTitleColor;
    }
    self.scoreLabel.text = [NSString stringWithFormat:@"%zd",model.amount];
}

// MARK: - CustomMethod
- (void)setupUI {
    
    /// 图片
    self.iconView = [[UIImageView alloc]init];
    self.iconView.hidden = YES;
    [self addSubview:self.iconView];
    [self.iconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self).offset(10);
        make.centerY.mas_equalTo(self);
        make.width.height.mas_equalTo(25);
    }];
    
    /// 得分
    self.scoreLabel = [[UILabel alloc]init];
    self.scoreLabel.font = [UIFont systemFontOfSize:15];
    self.scoreLabel.textColor = kSubTitleColor;
    self.scoreLabel.textAlignment = NSTextAlignmentRight;
    [self addSubview:self.scoreLabel];
    [self.scoreLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self).offset(-20);
        make.centerY.mas_equalTo(self);
    }];
    
    /// 昵称
    self.subTitle = [[UILabel alloc]init];
    self.subTitle.font = [UIFont systemFontOfSize:15];
    self.subTitle.textColor = kSubTitleColor;
    [self addSubview:self.subTitle];
    [self.subTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.iconView.mas_right).offset(5);
        make.centerY.mas_equalTo(self);
        make.right.mas_equalTo(self.scoreLabel.mas_left).offset(-5);
    }];
    
}


@end
