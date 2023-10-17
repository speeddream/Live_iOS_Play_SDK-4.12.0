//
//  HDRedPacketRankHeaderView.m
//  CCLiveCloud
//
//  Created by Richard Lee on 7/1/21.
//  Copyright © 2021 MacBook Pro. All rights reserved.
//

#import "HDRedPacketRankHeaderView.h"
#import "CCcommonDefine.h"
#import "UIView+Extension.h"
#import <Masonry/Masonry.h>

#define kGoldenColor CCRGBAColor(253, 227, 178, 1)
#define kNotPrize @"很遗憾没有抢到红包，下次努力呀~"
#define kPrize @"恭喜你抢到红包了"

@interface HDRedPacketRankHeaderView ()

@property (nonatomic, copy)   CloseRankClosure  closeRankClosure;
@property (nonatomic, assign) NSInteger         score;
@property (nonatomic, strong) UIImageView       *bgImageView;
@property (nonatomic, strong) UIButton          *closeBtn;
@property (nonatomic, strong) UIView            *prizeView;
@property (nonatomic, strong) UILabel           *scoreLabel;
@property (nonatomic, strong) UILabel           *scoreTipLabel;
@property (nonatomic, strong) UIImageView       *lostPrize;

@property (nonatomic, strong) UILabel           *tipInfoLabel;

@end

@implementation HDRedPacketRankHeaderView

// MARK: - API
- (instancetype)initWithFrame:(CGRect)frame score:(NSInteger)score closeRankClosure:(nonnull CloseRankClosure)closeRankClosure {
    if (self = [super initWithFrame:frame]) {
        self.score = score;
        self.backgroundColor = [UIColor whiteColor];
        self.closeRankClosure = closeRankClosure;
        [self setupUI];
    }
    return self;
}

// MARK: - CustomMethod
- (void)setupUI {
    /// 顶部背景视图
    self.bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"redPacket_bg"]];
    [self addSubview:self.bgImageView];
    [self.bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.mas_equalTo(self);
    }];
    
    /// 关闭按钮
    self.closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.closeBtn setImage:[UIImage imageNamed:@"redPacket_close"] forState:UIControlStateNormal];
    [self.closeBtn addTarget:self action:@selector(closeBtnClick) forControlEvents:UIControlEventTouchUpInside];
    CGFloat btnMargin = 12;
    [self addSubview:self.closeBtn];
    [self.closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self).offset(-btnMargin);
        make.top.mas_equalTo(self).offset(btnMargin);
        make.width.height.mas_equalTo(40);
    }];

    /// 红包雨结果提示
    self.tipInfoLabel = [[UILabel alloc]init];
    self.tipInfoLabel.textColor = kGoldenColor;
    self.tipInfoLabel.font = [UIFont boldSystemFontOfSize:15];
    self.tipInfoLabel.text = self.score > 0 ? kPrize : kNotPrize;
    self.tipInfoLabel.numberOfLines = 2;
    self.tipInfoLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.tipInfoLabel];
    [self.tipInfoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self).offset(38);
        make.right.mas_equalTo(self).offset(-38);
        make.bottom.mas_equalTo(self).offset(-20);
    }];
    [self.tipInfoLabel layoutIfNeeded];

    /// 得分
    if (self.score > 0) {
        /// 中奖分数视图
        CGFloat prizeViewX = 0;
        CGFloat prizeViewY = 53;
        CGFloat prizeViewW = self.frame.size.width;
        CGFloat prizeViewH = 60;
        self.prizeView = [[UIView alloc]initWithFrame:CGRectMake(prizeViewX, prizeViewY, prizeViewW, prizeViewH)];
        [self addSubview:self.prizeView];
        
        /// 分数
        CGFloat scoreLabelW = [self getLabelWidth:[NSString stringWithFormat:@"%zd",self.score] height:self.prizeView.frame.size.height font:[UIFont boldSystemFontOfSize:60]];
        CGFloat scoreLabelX = (self.prizeView.frame.size.width - scoreLabelW) / 2 - 20;
        CGFloat scoreLabelY = 0;
        CGFloat scoreLabelH = self.prizeView.frame.size.height;
        self.scoreLabel = [[UILabel alloc]initWithFrame:CGRectMake(scoreLabelX, scoreLabelY, scoreLabelW, scoreLabelH)];
        self.scoreLabel.textColor = kGoldenColor;
        self.scoreLabel.font = [UIFont boldSystemFontOfSize:60];
        self.scoreLabel.text = [NSString stringWithFormat:@"%zd",self.score];
        self.scoreLabel.textAlignment = NSTextAlignmentRight;
        self.scoreLabel.height = self.prizeView.frame.size.height;
        [self.prizeView addSubview:self.scoreLabel];
        
        /// 中奖提示
        CGFloat scoreTipLabelX = CGRectGetMaxX(self.scoreLabel.frame) + 3;
        CGFloat scoreTipLabelH = 15;
        CGFloat scoreTipLabelY = self.prizeView.frame.size.height - scoreTipLabelH - 10;
        CGFloat scoreTipLabelW = [self getLabelWidth:@"学分" height:15 font:[UIFont systemFontOfSize:15]];
        self.scoreTipLabel = [[UILabel alloc]initWithFrame:CGRectMake(scoreTipLabelX, scoreTipLabelY, scoreTipLabelW, scoreTipLabelH)];
        self.scoreTipLabel.textColor = kGoldenColor;
        self.scoreTipLabel.font = [UIFont systemFontOfSize:15];
        self.scoreTipLabel.text = @"学分";
        self.scoreTipLabel.textAlignment = NSTextAlignmentLeft;
        [self.prizeView addSubview:self.scoreTipLabel];
    
    }else {
        /// 未中奖提示
        self.lostPrize = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"redPacket_cry"]];
        [self addSubview:self.lostPrize];
        [self.lostPrize mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.centerY.mas_equalTo(self);
            make.width.height.mas_equalTo(50);
        }];
        [self.lostPrize layoutIfNeeded];
    }
}

- (CGFloat)getLabelWidth:(NSString *)str height:(CGFloat)height font:(UIFont *)font {
    if (![str isKindOfClass:[NSString class]]) return 0;
    if (str.length == 0) return 0;
    CGRect rect = [str boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, height) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: font} context:nil];
    return rect.size.width;
}


- (void)closeBtnClick {
    if (self.closeRankClosure) {
        self.closeRankClosure();
    }
}

@end
