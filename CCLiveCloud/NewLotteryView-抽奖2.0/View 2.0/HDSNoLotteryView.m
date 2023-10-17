//
//  HDSNoLotteryView.m
//  HDSExample
//
//  Created by richard lee on 9/1/22.
//

#import "HDSNoLotteryView.h"
#import "UIColor+RCColor.h"

@interface HDSNoLotteryView ()

@property (nonatomic, strong) UIImageView *iconIMG;

@property (nonatomic, strong) UILabel     *tipsLabel;

@end

@implementation HDSNoLotteryView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor colorWithHexString:@"#FFE2BD" alpha:1];
        [self configureView];
    }
    return self;
}

- (void)configureView {
    CGFloat imgW = 45;
    CGFloat imgH = 46;
    CGFloat imgX = (self.frame.size.width - imgW) / 2;
    CGFloat imgY = (self.frame.size.height - imgH) / 2 - 10;
    UIImageView *iconIMG = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"未中奖"]];
    iconIMG.frame = CGRectMake(imgX, imgY, imgW, imgH);
    [self.layer addSublayer:iconIMG.layer];
    self.iconIMG = iconIMG;
    
    CGFloat labelX = 20;
    CGFloat labelY = CGRectGetMaxY(iconIMG.frame) + 5;
    CGFloat labelW = self.frame.size.width - 40;
    CGFloat labelH = 15;
    UILabel *tipsLabel = [[UILabel alloc]init];
    tipsLabel.frame = CGRectMake(labelX, labelY, labelW, labelH);
    tipsLabel.text = @"很遗憾，本轮无人中奖";
    tipsLabel.font = [UIFont boldSystemFontOfSize:12];
    tipsLabel.textAlignment = NSTextAlignmentCenter;
    tipsLabel.textColor = [UIColor colorWithHexString:@"#CD6322" alpha:1];
    [self.layer addSublayer:tipsLabel.layer];
    self.tipsLabel = tipsLabel;
    
}

- (void)dealloc {
    
}

@end
