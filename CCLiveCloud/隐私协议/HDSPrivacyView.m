//
//  HDSPrivacyView.m
//  CCClassRoom
//
//  Created by 刘强强 on 2022/9/7.
//  Copyright © 2022 cc. All rights reserved.
//

#import "HDSPrivacyView.h"

@interface HDSPrivacyView ()<UITextViewDelegate>

@property(nonatomic, strong) UIView *contentView;
@property(nonatomic, strong) UILabel *titleLb;
@property(nonatomic, strong) UITextView *textView;

@property(nonatomic, strong) UIButton *exitBtn;
@property(nonatomic, strong) UIButton *okBtn;

@property(nonatomic, copy) HDSCallBackAction callBack;
@property(nonatomic, copy) NSString *title;
@property(nonatomic, copy) NSString *contentText;
@property(nonatomic, copy) NSString *heighlighted;
@property(nonatomic, copy) NSString *heighlightedSecd;
@end

@implementation HDSPrivacyView

+ (HDSPrivacyView *)showView:(NSString *)title
                 contentText:(NSString *)contentText
                heighlighted:(NSString *)heighlighted
            heightlightedSecd:(NSString *)heightlightedSecd
                   superRect:(CGRect)rect
                    callBack:(HDSCallBackAction)callBack {
    BOOL isShowPrivacy = [[NSUserDefaults standardUserDefaults] boolForKey:@"HDSOldShowPrivacy"];
    if (isShowPrivacy) {
        return nil;
    }
    
    HDSPrivacyView *view = [[HDSPrivacyView alloc] initWithFrame:rect];
    view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.45];
    view.callBack = callBack;
    view.title = title;
    view.contentText = contentText;
    view.heighlighted = heighlighted;
    view.heighlightedSecd = heightlightedSecd;
    [view updateText];
    
    return view;
}

- (void)remoeView {
    [self removeFromSuperview];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubviews];
    }
    return self;
}

- (void)setupSubviews {
    
    CGFloat width = self.bounds.size.width;
    CGFloat height = self.bounds.size.height;
    
    self.contentView.frame = CGRectMake(0, height - 342, width, 342);
    [self addSubview:self.contentView];
    
    self.titleLb.frame = CGRectMake(0, 20, width, 22);
    [self.contentView addSubview:self.titleLb];
    
    
    self.textView.frame = CGRectMake(20, 66, width - 40, 184);
    [self.contentView addSubview:self.textView];
    
    CGFloat btnWidth = (width - 40 - 12) * 0.5;
    CGFloat btnHeight = 40;
    CGFloat y = CGRectGetMaxY(self.textView.frame) + 20;
    self.exitBtn.frame = CGRectMake(20, y, btnWidth, btnHeight);
    [self.contentView addSubview:self.exitBtn];
    
    self.okBtn.frame = CGRectMake(CGRectGetMaxX(self.exitBtn.frame) + 12, y, btnWidth, btnHeight);
    [self.contentView addSubview:self.okBtn];
    
    UIBezierPath *rounded = [UIBezierPath bezierPathWithRoundedRect:self.contentView.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(20, 20)];
    CAShapeLayer *shape = [[CAShapeLayer alloc] init];

    [shape setPath:rounded.CGPath];

    self.contentView.layer.mask = shape;
    
}

- (void)updateText {
    self.titleLb.text = self.title;
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing= 5;
    NSDictionary*attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:14],
                                NSParagraphStyleAttributeName:paragraphStyle};
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:self.contentText attributes:attributes];
    NSRange range = [self.contentText rangeOfString:self.heighlighted];
    [attributedString addAttribute:NSLinkAttributeName value:@"yinsizhengce://" range:range];
    NSRange rangeSecd = [self.contentText rangeOfString:self.heighlightedSecd];
    [attributedString addAttribute:NSLinkAttributeName value:@"fuwu://" range:rangeSecd];
    
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.65] range:NSMakeRange(0,self.contentText.length)];
    self.textView.attributedText= attributedString;
    //设置被点击字体颜色
    self.textView.linkTextAttributes = @{NSForegroundColorAttributeName:[UIColor colorWithRed:255/255.0 green:110/255.0 blue:10/255.0 alpha:1]};
    
    self.textView.backgroundColor = [UIColor whiteColor];
    self.textView.textColor = [UIColor blackColor];
}

#pragma mark 富文本点击事件
-(BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange interaction:(UITextItemInteraction)interaction {
    if ([[URL scheme] isEqualToString:@"yinsizhengce"]) {
        //NSLog(@"富文本点击 隐私政策");
        if (self.callBack) {
            self.callBack(HDSCallBackActionType_YINSI);
        }
    } else if ([[URL scheme] isEqualToString:@"fuwu"]) {
        if (self.callBack) {
            self.callBack(HDSCallBackActionType_FUWU);
        }
    }
    return YES;
}

- (void)exitBtnAction {
    exit(0);
}

- (void)okBtnAction {
    if (self.callBack) {
        self.callBack(HDSCallBackActionType_OK);
    }
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"HDSOldShowPrivacy"];
}

// MARK: - 懒加载
- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
        _contentView.backgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1];
    }
    return _contentView;
}

- (UILabel *)titleLb {
    if (!_titleLb) {
        _titleLb = [[UILabel alloc] init];
        _titleLb.font = [UIFont boldSystemFontOfSize:16];
        _titleLb.textColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1];
        _titleLb.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLb;
}

- (UITextView *)textView {
    if (!_textView) {
        _textView = [[UITextView alloc] init];
        _textView.textColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.65];
        _textView.font = [UIFont systemFontOfSize:14];
        _textView.editable = NO;
        _textView.delegate = self;
    }
    return _textView;
}

- (UIButton *)exitBtn {
    if (!_exitBtn) {
        _exitBtn = [self getBtn:@selector(exitBtnAction)];
        _exitBtn.backgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1];
        _exitBtn.layer.cornerRadius = 20;
        _exitBtn.layer.masksToBounds = YES;
        _exitBtn.layer.borderWidth = 0.5;
        _exitBtn.layer.borderColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:0.8].CGColor;
        [_exitBtn setTitle:@"不同意并退出" forState:UIControlStateNormal];
        [_exitBtn setTitleColor:[UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1] forState:UIControlStateNormal];
        _exitBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    }
    return _exitBtn;
}

- (UIButton *)okBtn {
    if (!_okBtn) {
        _okBtn = [self getBtn:@selector(okBtnAction)];
        _okBtn.backgroundColor = [UIColor colorWithRed:255/255.0 green:132/255.0 blue:47/255.0 alpha:1];
        _okBtn.layer.cornerRadius = 20;
        _okBtn.layer.masksToBounds = YES;
        [_okBtn setTitle:@"同意并继续" forState:UIControlStateNormal];
        [_okBtn setTitleColor:[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1] forState:UIControlStateNormal];
        _okBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    }
    return _okBtn;
}

- (UIButton *)getBtn:(SEL)sel {
    UIButton *btn = [[UIButton alloc] init];
    [btn addTarget:self action:sel forControlEvents:UIControlEventTouchUpInside];
    return btn;
}

@end
