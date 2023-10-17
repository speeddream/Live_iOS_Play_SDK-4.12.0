//
//  NewLotteryInfomationCell.m
//  CCLiveCloud
//
//  Created by Apple on 2020/11/13.
//  Copyright © 2020 MacBook Pro. All rights reserved.
//

#import "NewLotteryInfomationCell.h"
#import "NewLotteryInfomationCellModel.h"
#import "HDTextField.h"
#import "UIColor+RCColor.h"
#import "CCcommonDefine.h"
#import <Masonry/Masonry.h>

@interface NewLotteryInfomationCell ()<UITextFieldDelegate>
/** 标题 */
@property (nonatomic, strong) UILabel       *titleLabel;
/** 输入框 */
@property (nonatomic, strong) HDTextField   *textField;

@end

@implementation NewLotteryInfomationCell

/**
 *    @brief    初始化
 */
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
/**
 *    @brief    初始化UI
 */
- (void)setupUI
{
    [self.contentView addSubview:self.textField];
    [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self).offset(-15);
        make.top.mas_equalTo(self).offset(5);
        make.left.mas_equalTo(self).offset(82);
        make.bottom.mas_equalTo(self).offset(-5);
    }];
    [self.contentView addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.textField.mas_left).offset(-5);
        make.centerY.mas_equalTo(self.textField);
        make.left.mas_equalTo(self).offset(5);
    }];
    [self layoutIfNeeded];
}
/**
 *    @brief    赋值
 */
- (void)setModel:(NewLotteryInfomationCellModel *)model
{
    _model = model;
    if ([model.title isEqualToString:@"手机号"]) {
       _textField.maxTextLength = 11;
       _textField.keyboardType = UIKeyboardTypeNumberPad;
    }
    _textField.placeholder = model.tips;
    _titleLabel.text = model.title;
}

#pragma mark - 懒加载
- (UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        _titleLabel.textColor = [UIColor colorWithHexString:@"#38404B" alpha:1];
        _titleLabel.font = [UIFont systemFontOfSize:FontSize_28];
        _titleLabel.textAlignment = NSTextAlignmentRight;
    }
    return _titleLabel;
}

- (HDTextField *)textField
{
    if (!_textField) {
        _textField = [[HDTextField alloc]init];
        //设置字体大小
        _textField.font = [UIFont systemFontOfSize:FontSize_28];
        _textField.delegate = self;
    }
    return _textField;
}

#pragma mark - textFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self endEditing:YES];
    return YES;
}
/**
 *    @brief    开始编辑
 */
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (self.selectedBlock) {
        self.selectedBlock(_model.index);
    }
}
/**
 *    @brief    结束编辑
 */
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if ([_model.content isEqualToString:textField.text]) return;
    _model.content = textField.text.length > 0 ? textField.text : @"";
    if (self.contentBlock) {
        self.contentBlock(_model);
    }
}

@end
