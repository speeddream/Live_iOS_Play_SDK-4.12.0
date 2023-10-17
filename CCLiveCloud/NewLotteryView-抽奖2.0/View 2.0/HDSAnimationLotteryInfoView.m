//
//  HDSAnimationLotteryInfoView.m
//  Example
//
//  Created by richard lee on 8/30/22.
//  Copyright © 2022 Jonathan Tribouharet. All rights reserved.
//

#import "HDSAnimationLotteryInfoView.h"
#import "HDSBaseAnimationModel.h"
#import "UIColor+RCColor.h"

@interface HDSAnimationLotteryInfoView ()

@property (nonatomic, strong) UIImageView *bgIMG;

@property (nonatomic, strong) UIImageView *titleIMG;

@property (nonatomic, strong) UILabel *lotteryName;

@property (nonatomic, strong) UILabel *lotteryNumText;

@property (nonatomic, strong) UILabel *lotteryNum;

@property (nonatomic, strong) UILabel *joinNumsText;

@property (nonatomic, strong) UILabel *joinNums;

@end

@implementation HDSAnimationLotteryInfoView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = UIColor.clearColor;
        [self configurateView];
    }
    return self;
}

// MARK: - SetValue
- (void)setModel:(HDSBaseAnimationModel *)model {
    _model = model;
    _lotteryName.text = [NSString stringWithFormat:@"%@",model.prizeName];
    _lotteryNum.text = [NSString stringWithFormat:@"%ld份",(long)model.prizeNum];
    _joinNums.text = [NSString stringWithFormat:@"%ld人",(long)model.onlineNumber];
}

// MARK: - CustomMethods
- (void)configurateView {
    
    UIImageView *bgIMG = [self createImageView:@"抽奖bg"];
    bgIMG.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    [self.layer addSublayer:bgIMG.layer];
    self.bgIMG = bgIMG;
    
    CGFloat titleIMGW = 115;
    CGFloat titleIMGX = (self.frame.size.width - titleIMGW) / 2;
    CGFloat titleIMGY = 15;
    CGFloat titleIMGH = 20.5;
    UIImageView *titleIMG = [self createImageView:@"本轮开奖奖品"];
    titleIMG.frame =CGRectMake(titleIMGX, titleIMGY, titleIMGW, titleIMGH);
    [bgIMG.layer addSublayer:titleIMG.layer];
    self.titleIMG = titleIMG;
    
    CGFloat lotteryNameX = 15;
    CGFloat lotteryNameW = self.frame.size.width - 30;
    CGFloat lotteryNameY = CGRectGetMaxY(titleIMG.frame) + 5;
    CGFloat lotteryNameH = 34;
    self.lotteryName.frame = CGRectMake(lotteryNameX, lotteryNameY, lotteryNameW, lotteryNameH);
    [bgIMG.layer addSublayer:self.lotteryName.layer];
    
    CGFloat lotteryNumTextX = 15;
    CGFloat lotteryNumTextW = self.frame.size.width / 2;
    CGFloat lotteryNumTextY = CGRectGetMaxY(_lotteryName.frame) + 5;
    CGFloat lotteryNumTextH = 15;
    self.lotteryNumText.frame = CGRectMake(lotteryNumTextX, lotteryNumTextY, lotteryNumTextW, lotteryNumTextH);
    [bgIMG.layer addSublayer:self.lotteryNumText.layer];
    
    CGFloat lotteryNumX = CGRectGetMaxX(_lotteryNumText.frame);
    CGFloat lotteryNumW = self.frame.size.width - lotteryNameX - 15;
    CGFloat lotteryNumY = CGRectGetMaxY(_lotteryName.frame) + 5;
    CGFloat lotteryNumH = 15;
    self.lotteryNum.frame = CGRectMake(lotteryNumX, lotteryNumY, lotteryNumW, lotteryNumH);
    [bgIMG.layer addSublayer:self.lotteryNum.layer];
    
    
    CGFloat joinNumTextX = 15;
    CGFloat joinNumTextW = self.frame.size.width / 2;
    CGFloat joinNumTextY = CGRectGetMaxY(_lotteryNumText.frame) + 5;
    CGFloat joinNumTextH = 12;
    self.joinNumsText.frame = CGRectMake(joinNumTextX, joinNumTextY, joinNumTextW, joinNumTextH);
    [bgIMG.layer addSublayer:self.joinNumsText.layer];
    
    CGFloat joinNumX = CGRectGetMaxX(_joinNumsText.frame);
    CGFloat joinNumW = self.frame.size.width - joinNumX - 15;
    CGFloat joinNumY = CGRectGetMaxY(_lotteryNum.frame) + 5;
    CGFloat joinNumH = 12;
    self.joinNums.frame = CGRectMake(joinNumX, joinNumY, joinNumW, joinNumH);
    [bgIMG.layer addSublayer:self.joinNums.layer];
}

- (UIImageView *)createImageView:(NSString *)imageName {
    UIImageView *oneIMG = [[UIImageView alloc]initWithImage:[UIImage imageNamed:imageName]];
    return oneIMG;
}

//MARK: - LAZY
- (UILabel *)lotteryName {
    if (!_lotteryName) {
        UILabel *label = [[UILabel alloc]init];
        label.textColor = [UIColor colorWithHexString:@"#F7F7F7" alpha:1];
        label.font = [UIFont boldSystemFontOfSize:14];
        label.numberOfLines = 0;
        label.textAlignment = NSTextAlignmentCenter;
        label.text = @"奖品名称";
        _lotteryName = label;
    }
    return _lotteryName;
}

- (UILabel *)lotteryNumText {
    if (!_lotteryNumText) {
        UILabel *label = [[UILabel alloc]init];
        label.textColor = [UIColor colorWithHexString:@"#FFF2CD" alpha:1];
        label.font = [UIFont boldSystemFontOfSize:12];
        label.textAlignment = NSTextAlignmentRight;
        label.text = @"奖品数量：";
        _lotteryNumText = label;
    }
    return _lotteryNumText;
}

- (UILabel *)joinNumsText {
    if (!_joinNumsText) {
        UILabel *label = [[UILabel alloc]init];
        label.textColor = [UIColor colorWithHexString:@"#FFF2CD" alpha:1];
        label.font = [UIFont boldSystemFontOfSize:12];
        label.textAlignment = NSTextAlignmentRight;
        label.text = @"参与人数：";
        _joinNumsText = label;
    }
    return _joinNumsText;
}

- (UILabel *)lotteryNum {
    if (!_lotteryNum) {
        UILabel *label = [[UILabel alloc]init];
        label.textColor = [UIColor colorWithHexString:@"#FFFFFF" alpha:1];
        label.font = [UIFont boldSystemFontOfSize:12];
        label.textAlignment = NSTextAlignmentLeft;
        label.text = @"0份";
        _lotteryNum = label;
    }
    return _lotteryNum;
}

- (UILabel *)joinNums {
    if (!_joinNums) {
        UILabel *label = [[UILabel alloc]init];
        label.textColor = [UIColor colorWithHexString:@"#FFFFFF" alpha:1];
        label.font = [UIFont boldSystemFontOfSize:12];
        label.textAlignment = NSTextAlignmentLeft;
        label.text = @"0人";
        _joinNums = label;
    }
    return _joinNums;
}

- (void)dealloc {
    
}


@end
