//
//  InputTextField.m
//  NewCCDemo
//
//  Created by cc on 2016/12/6.
//  Copyright © 2016年 cc. All rights reserved.
//

#import "QuestionTextField.h"
#import "CCcommonDefine.h"

@interface QuestionTextField()


@end
#define QUESTIONTEXT @"我要提问~"
@implementation QuestionTextField

-(instancetype)init {
    self = [super init];
    if(self) {
        self.borderStyle = UITextBorderStyleNone;
        self.backgroundColor = CCRGBAColor(245,245,245,1.0f);
        self.placeholder = QUESTIONTEXT;
        self.font = [UIFont systemFontOfSize:FontSize_30];
        self.textColor = CCRGBColor(51, 51, 51);
        self.clearButtonMode = UITextFieldViewModeNever;
        self.autocorrectionType = UITextAutocorrectionTypeDefault;
        self.clearsOnBeginEditing = NO;
        self.textAlignment = NSTextAlignmentLeft;
        self.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        self.keyboardType = UIKeyboardTypeDefault;
        self.autocapitalizationType = UITextAutocapitalizationTypeNone;
        self.returnKeyType = UIReturnKeySend;
        self.keyboardAppearance = UIKeyboardAppearanceDefault;
        self.leftViewMode = UITextFieldViewModeAlways;
        self.rightViewMode = UITextFieldViewModeNever;
        self.layer.cornerRadius = 2;
        self.layer.masksToBounds = YES;
        self.rightView = self.rightView;
        self.inputAccessoryView = [self addToolbar];
    }
    return self;
}

-(CGRect)placeholderRectForBounds:(CGRect)bounds
{
    CGRect inset = CGRectMake(bounds.origin.x + 10 + 45 , bounds.origin.y + (bounds.size.height - [UIFont systemFontOfSize:FontSize_30].lineHeight) / 2, bounds.size.width - 10 - 45, bounds.size.height);
    return inset;
}

- (CGRect)leftViewRectForBounds:(CGRect)bounds {
    CGRect inset = CGRectMake(bounds.origin.x+5 , bounds.origin.y, 45, bounds.size.height);
    return inset;
}

- (UIToolbar *)addToolbar
{
    CGFloat kWidth = [UIScreen mainScreen].bounds.size.width;
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, kWidth, 35)];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"收起" style:UIBarButtonItemStylePlain target:self action:@selector(hiddenKeyboard)];
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [toolbar setItems:@[space,item]];
    return toolbar;
}

- (void)hiddenKeyboard {
    [self resignFirstResponder];
}

//- (CGRect)rightViewRectForBounds:(CGRect)bounds {
//    CGRect inset = CGRectMake(bounds.size.width - 7.5 - 24 , bounds.origin.y, 24, bounds.size.height);
//    return inset;
//}

//控制placeHolder的颜色、字体
- (void)drawPlaceholderInRect:(CGRect)rect
{
    NSMutableParagraphStyle *style = [self.defaultTextAttributes[NSParagraphStyleAttributeName] mutableCopy];
    
    style.minimumLineHeight = self.font.lineHeight - (self.font.lineHeight - [UIFont systemFontOfSize:FontSize_30].lineHeight) / 2.0;
    
    NSDictionary *dict = @{NSFontAttributeName:[UIFont systemFontOfSize:FontSize_30],NSForegroundColorAttributeName:CCRGBColor(102,102,102),NSParagraphStyleAttributeName:style};
    
    [self.placeholder drawInRect:rect withAttributes:dict];
}

// 重写来编辑区域，可以改变光标起始位置，以及光标最右到什么地方，placeHolder的位置也会改变
-(CGRect)editingRectForBounds:(CGRect)bounds
{
    CGRect inset = CGRectMake(bounds.origin.x + 10 +45, bounds.origin.y, bounds.size.width - 10 - 45, bounds.size.height);//更好理解些
    return inset;
}

@end
