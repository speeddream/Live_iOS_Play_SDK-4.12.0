//
//  HDSPublicTipsView.m
//  CCLiveCloud
//
//  Created by richard lee on 3/9/23.
//  Copyright © 2023 MacBook Pro. All rights reserved.
//

#import "HDSPublicTipsView.h"
#import "UIColor+RCColor.h"
#import "CCcommonDefine.h"
#import <Masonry/Masonry.h>

@interface HDSPublicTipsView ()

@property (nonatomic, strong) UIView *boardView;

@property (nonatomic, strong) UILabel *tipsLabel;

@property (nonatomic, copy)   NSString *tipString;

@end

@implementation HDSPublicTipsView

- (instancetype)initWithFrame:(CGRect)frame tips:(NSString *)tips {
    if (self = [super initWithFrame:frame]) {
        self.tipString = tips;
        [self configureUI];
        [self configureConstraints];
        [self configureData];
    }
    return self;
}

- (void)updateTips:(NSString *)tips {
    self.tipString = tips;
    [self configureData];
}

// MARK: - Custom Method
- (void)configureUI {
    
    self.backgroundColor = [UIColor colorWithHexString:@"#000000" alpha:0];
    
    _boardView = [[UIView alloc]init];
    _boardView.backgroundColor = [UIColor colorWithHexString:@"#222222" alpha:0.7];
    _boardView.alpha = 0;
    [self addSubview:_boardView];
    
    _tipsLabel = [[UILabel alloc]init];
    _tipsLabel.font = [UIFont systemFontOfSize:14];
    _tipsLabel.numberOfLines = 0;
    _tipsLabel.textAlignment = NSTextAlignmentCenter;
    _tipsLabel.preferredMaxLayoutWidth = SCREEN_WIDTH - 41;
    _tipsLabel.textColor = [UIColor colorWithHexString:@"#F9F9F9" alpha:1];
    [_boardView addSubview:_tipsLabel];
}

- (void)configureConstraints {
    
    __weak typeof(self) weakSelf = self;
    [_boardView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(weakSelf);
        //make.centerY.mas_equalTo(weakSelf).offset(-80);
        make.centerY.mas_equalTo(weakSelf);
    }];
    
    [_tipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.boardView).offset(8);
        make.left.mas_equalTo(weakSelf.boardView).offset(20);
        make.right.mas_equalTo(weakSelf.boardView).offset(-20);
        make.bottom.mas_equalTo(weakSelf.boardView).offset(-8);
        make.height.mas_greaterThanOrEqualTo(24);
        make.width.mas_greaterThanOrEqualTo(100);
    }];
    
    //动画--淡入
    [UIView animateWithDuration:0.5f delay:0.0f options:UIViewAnimationOptionCurveLinear animations:^{
        self.boardView.alpha = 1.0;
    } completion:^(BOOL finished) {
        
    }];
    
    _boardView.layer.cornerRadius = 2.f;
    _boardView.layer.masksToBounds = YES;
}

- (void)configureData {
    
    CGFloat maxH = [self getTextHeightWith:self.tipString];
    //通过修改文本属性
    NSMutableAttributedString *attriString =
    [[NSMutableAttributedString alloc] initWithString:self.tipString];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:2];//设置距离
    paragraphStyle.alignment = NSTextAlignmentCenter;
    [attriString addAttribute:NSParagraphStyleAttributeName
                        value:paragraphStyle
                        range:NSMakeRange(0, self.tipString.length)];
    _tipsLabel.attributedText = attriString;
    
    [_boardView layoutIfNeeded];
//    __weak typeof(self) weakSelf = self;
//    if (maxH <= 20) {
//        [_tipsLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
//            make.top.mas_equalTo(weakSelf.boardView).offset(5);
//            make.left.mas_equalTo(weakSelf.boardView).offset(15.5);
//            make.right.mas_equalTo(weakSelf.boardView).offset(-14.5);
//            make.bottom.mas_equalTo(weakSelf.boardView).offset(-5);
//            make.width.mas_greaterThanOrEqualTo(100);
//            make.height.mas_equalTo(20);
//        }];
//        [_tipsLabel layoutIfNeeded];
//        _boardView.layer.cornerRadius = 15.f;
//        _boardView.layer.masksToBounds = YES;
//    } else {
//        [_tipsLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
//            make.top.mas_equalTo(weakSelf.boardView).offset(5);
//            make.left.mas_equalTo(weakSelf.boardView).offset(15.5);
//            make.right.mas_equalTo(weakSelf.boardView).offset(-14.5);
//            make.bottom.mas_equalTo(weakSelf.boardView).offset(-5);
//            make.height.mas_greaterThanOrEqualTo(20);
//        }];
//        [_tipsLabel layoutIfNeeded];
//        _boardView.layer.cornerRadius = 4.f;
//        _boardView.layer.masksToBounds = YES;
//    }
}


//计算纯文本行高
- (CGFloat)getTextHeightWith:(NSString *)string {
    CGFloat height;
    //计算文本高度
    float textMaxWidth = SCREEN_WIDTH - 60;
    if (string.length == 0) {
        string = @"  ";
    }
    NSMutableAttributedString *textAttri = [[NSMutableAttributedString alloc] initWithString:string];
    [textAttri addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"#F9F9F9" alpha:1] range:NSMakeRange(0, textAttri.length)];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.alignment = NSTextAlignmentLeft;
    style.minimumLineHeight = 18;
    style.maximumLineHeight = 30;
    style.lineBreakMode = NSLineBreakByCharWrapping;
    NSDictionary *dict = @{NSFontAttributeName:[UIFont systemFontOfSize:14],NSParagraphStyleAttributeName:style};
    [textAttri addAttributes:dict range:NSMakeRange(0, textAttri.length)];
    CGSize textSize = [textAttri boundingRectWithSize:CGSizeMake(textMaxWidth, CGFLOAT_MAX)
                                              options:NSStringDrawingUsesLineFragmentOrigin
                                              context:nil].size;
    textSize.height = ceilf(textSize.height);
    height = textSize.height;
    return height;
}

@end
