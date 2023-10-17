//
//  NewLotteryHeaderView.m
//  CCLiveCloud
//
//  Created by Apple on 2020/11/13.
//  Copyright © 2020 MacBook Pro. All rights reserved.
//

#import "NewLotteryHeaderView.h"
#import "NewLotteryViewManagerTool.h"
#import "UIColor+RCColor.h"
#import "CCcommonDefine.h"
#import <Masonry/Masonry.h>

@interface NewLotteryHeaderView ()
/** 提示 */
@property (nonatomic, strong) UILabel       *alertLabel;
/** 中奖图片 */
@property (nonatomic, strong) UIImageView   *image;
/** 结果 */
@property (nonatomic, strong) UILabel       *resultLabel;
/** 底部提示 */
@property (nonatomic, strong) UILabel       *bottomLabel;

@end

@implementation NewLotteryHeaderView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI
{
    //提示
    [self addSubview:self.alertLabel];
    [self.alertLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self).offset(20);
        make.left.mas_equalTo(self).offset(15);
        make.right.mas_equalTo(self).offset(-15);
    }];
    //中奖图片
    [self addSubview:self.image];
    [self.image mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.alertLabel.mas_bottom).offset(15);
        make.left.mas_equalTo(self).offset(44);
        make.right.mas_equalTo(self).offset(-43.5);
        make.height.mas_equalTo(117.5);
    }];
    //中奖信息
    [self.image addSubview:self.resultLabel];
    [self.resultLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.bottom.mas_equalTo(self.image);
        make.right.mas_equalTo(self.image).offset(-50);
    }];
    //底部提示
    [self addSubview:self.bottomLabel];
    [self.bottomLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.image.mas_bottom).offset(20);
        make.left.mas_equalTo(self).offset(15);
        make.bottom.right.mas_equalTo(self).offset(-15);
    }];
}
/**
 *    @brief    设置中奖信息
 *    @param    myself      是否中奖
 *    @param    code        中奖码
 *    @param    prizeName   奖品名称
 *    @param    tip         提示语
 */
- (void)nLottery_HeaderViewWithMySelf:(BOOL)myself code:(NSString *)code prizeName:(NSString *)prizeName tip:(NSString *)tip
{
    NSString *prize = [[NSString alloc]initWithFormat:@"恭喜您获得了【%@】，请牢记您的中奖码",prizeName];
    NSString *rangeText = [[NSString alloc]initWithFormat:@"【%@】",prizeName];
    prize = myself == YES ? prize : [[NSString alloc]initWithFormat:@"很遗憾，您没有获得【%@】",prizeName];
    NSString *imageName = myself ? @"lottery_win" : @"nlottery_losing";
    _image.image = [UIImage imageNamed:imageName];
    if (myself) {
        _alertLabel.attributedText = [NewLotteryViewManagerTool setupAttributeString:prize rangeText:rangeText textColor:[UIColor colorWithHexString:@"#FF412E" alpha:1] font:[UIFont systemFontOfSize:14]];
        _resultLabel.text = code;
        _bottomLabel.text = tip;
        if (tip.length == 0) {
            [self.bottomLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(0);
            }];
        }else {
            [self.bottomLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(self.image.mas_bottom).offset(20);
                make.left.mas_equalTo(self).offset(15);
                make.bottom.right.mas_equalTo(self).offset(-15);
            }];
        }
        _bottomLabel.textAlignment = NSTextAlignmentLeft;
    }else {
        [self.image mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self).offset(20);
            make.left.mas_equalTo(self).offset(44);
            make.right.mas_equalTo(self).offset(-43.5);
            make.height.mas_equalTo(50);  // 设置未中奖图片的高度.
        }];
            
        _alertLabel.text = @"";
        _resultLabel.hidden = YES;
        _bottomLabel.font = [UIFont systemFontOfSize:FontSize_28];
        _bottomLabel.attributedText = [NewLotteryViewManagerTool setupAttributeString:prize rangeText:rangeText textColor:[UIColor colorWithHexString:@"#FF412E" alpha:1] font:[UIFont systemFontOfSize:14]];
        _bottomLabel.textAlignment = NSTextAlignmentCenter;
    }
    [self layoutIfNeeded];
}

#pragma mark - 懒加载
- (UILabel *)alertLabel
{
    if (!_alertLabel) {
        //设置提示
        _alertLabel = [[UILabel alloc] init];
        _alertLabel.font = [UIFont systemFontOfSize:FontSize_28];
        _alertLabel.textColor = [UIColor colorWithHexString:@"#38404B" alpha:1.f];
        _alertLabel.textAlignment = NSTextAlignmentCenter;
        _alertLabel.numberOfLines = 0;
    }
    return _alertLabel;
}

- (UIImageView *)image
{
    if (!_image) {
        _image = [[UIImageView alloc] init];
        _image.backgroundColor = CCClearColor;
        _image.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _image;
}

- (UILabel *)resultLabel
{
    if (!_resultLabel) {
        //设置结果的label
        _resultLabel = [[UILabel alloc] init];
        _resultLabel.textColor = [UIColor colorWithHexString:@"#FF412E" alpha:1.f];
        _resultLabel.textAlignment = NSTextAlignmentCenter;
        _resultLabel.font = [UIFont systemFontOfSize:FontSize_72];
    }
    return _resultLabel;
}

- (UILabel *)bottomLabel
{
    if (!_bottomLabel) {
        //底部提示文字
        _bottomLabel = [[UILabel alloc] init];
        _bottomLabel.textColor = [UIColor colorWithHexString:@"#38404B" alpha:1.f];
        _bottomLabel.textAlignment = NSTextAlignmentLeft;
        _bottomLabel.font = [UIFont systemFontOfSize:FontSize_26];
        _bottomLabel.numberOfLines = 0;
    }
    return _bottomLabel;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if (self.headerTouchBlock) {
        self.headerTouchBlock(@"");
    }
}

@end
