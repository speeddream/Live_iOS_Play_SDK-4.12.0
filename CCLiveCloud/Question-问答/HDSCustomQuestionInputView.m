//
//  HDSCustomQuestionInputView.m
//  HDTABC
//
//  Created by richard lee on 3/6/23.
//

#import "HDSCustomQuestionInputView.h"
#import "UIColor+RCColor.h"
#import <Masonry/Masonry.h>
#import "PPStickerTextView.h"
#import "HDSCustomTextView.h"
#import "CCcommonDefine.h"

@interface HDSCustomQuestionInputView ()<UITextViewDelegate>
/// 按钮点击回调
@property (nonatomic, copy)   kBtnsTappedBlock kCallBack;
/// 输入框高度更新回调
@property (nonatomic, copy)   kUpdateInputViewHeight kHeightCallBack;
/// 输入回调
@property (nonatomic, copy)   kCallBackMessage kCallBackMessage;
/// 分割线
@property (nonatomic, strong) UILabel *shadowLine;
/// 容器视图
@property (nonatomic, strong) UIView *containerView;
/// 看我按钮
@property (nonatomic, strong) UIButton *viewMeBtn;
/// 添加图片按钮
@property (nonatomic, strong) UIButton *addIMGBtn;
/// 发送按钮
@property (nonatomic, strong) UIButton *sendBtn;
/// 输入内容
@property (nonatomic, copy)   NSString *resultMessage;
/// 更新TextView圆角
@property (nonatomic, assign) BOOL isNeedUpdateCornerRadius;
/// 更新TextView圆角 YES 多行 NO 单行
@property (nonatomic, assign) BOOL updateCornerRadiusFlag;

@property (nonatomic, strong) UILabel *placeHolder;

@end

@implementation HDSCustomQuestionInputView

/// 初始化输入视图
/// - Parameters:
///   - frame: 布局
///   - btnsTappedClosure: 按钮点击回调
- (instancetype)initWithFrame:(CGRect)frame
            btnsTappedClosure:(nonnull kBtnsTappedBlock)btnsTappedClosure
        updateInputViewHeight:(nonnull kUpdateInputViewHeight)heightChangeClosure
              callBackMessage:(kCallBackMessage)callBackMessageClosure {
    if (self = [super initWithFrame:frame]) {
        if (btnsTappedClosure) {
            _kCallBack = btnsTappedClosure;
        }
        if (heightChangeClosure) {
            _kHeightCallBack = heightChangeClosure;
        }
        if (callBackMessageClosure) {
            _kCallBackMessage = callBackMessageClosure;
        }
        [self configureUI];
        [self configureConstraints];
        [self addObserver];
    }
    return self;
}

- (void)setIsEdit:(BOOL)isEdit {
    _isEdit = isEdit;
    
    _textView.textColor = _isEdit == YES ? [UIColor colorWithHexString:@"#333333" alpha:1] : [UIColor colorWithHexString:@"#999999" alpha:1];
    _textView.userInteractionEnabled = _isEdit == YES ? YES : NO;
    
    if (_allowAddImage) {    
        NSString *addIMGName = _isEdit == YES ? @"图片nor" : @"图片ban";
        [_addIMGBtn setImage:[UIImage imageNamed:addIMGName] forState:UIControlStateNormal];
        _addIMGBtn.userInteractionEnabled = _isEdit == YES ? YES : NO;
    }
    
    _sendBtn.backgroundColor = _isEdit == YES ? [UIColor colorWithHexString:@"#FF842F" alpha:1] : [UIColor colorWithHexString:@"#FF842F" alpha:0.6];
    _sendBtn.userInteractionEnabled = _isEdit == YES ? YES : NO;
}

- (void)setAllowAddImage:(BOOL)allowAddImage {
    _allowAddImage = allowAddImage;
    _addIMGBtn.hidden = !_allowAddImage;
}

- (void)setIsClean:(BOOL)isClean {
    _isClean = isClean;
    if (_isClean) {    
        _textView.text = nil;
        [self textViewDidChange:_textView];
        _resultMessage = nil;
        [self changeConstraints:NO];
    }
}

- (void)setIsAllAdded:(BOOL)isAllAdded {
    _isAllAdded = isAllAdded;
    if (_allowAddImage) {
        NSString *addIMGName = _isAllAdded == NO ? @"图片nor" : @"图片ban";
        [_addIMGBtn setImage:[UIImage imageNamed:addIMGName] forState:UIControlStateNormal];
    }
}

// MARK: - Custom Method
- (void)configureUI {
    
    self.backgroundColor = [UIColor colorWithHexString:@"#FFFFFF" alpha:1];
    
    _shadowLine = [[UILabel alloc]init];
    _shadowLine.backgroundColor = [UIColor colorWithHexString:@"#EEEEEE" alpha:0.3];
    [self addSubview:_shadowLine];
    
    _sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _sendBtn.tag = 1003;
    _sendBtn.hidden = YES;
    _sendBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [_sendBtn setTitle:@"发送" forState:UIControlStateNormal];
    [_sendBtn setBackgroundColor:[UIColor colorWithHexString:@"#FF842F" alpha:1]];
    [self addSubview:_sendBtn];
    [_sendBtn addTarget:self action:@selector(btnsTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    _containerView = [[UIView alloc]init];
    _containerView.backgroundColor = [UIColor colorWithHexString:@"#F5F5F5" alpha:1];
    [self addSubview:_containerView];
    
    _viewMeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _viewMeBtn.tag = 1001;
    [_viewMeBtn setImage:[UIImage imageNamed:@"question_ic_lookoff"] forState:UIControlStateNormal];
    [_viewMeBtn setImage:[UIImage imageNamed:@"question_ic_lookon"] forState:UIControlStateSelected];
    [_containerView addSubview:_viewMeBtn];
    [_viewMeBtn addTarget:self action:@selector(btnsTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    _textView = [[HDSCustomTextView alloc] init];
    _textView.backgroundColor = [UIColor colorWithHexString:@"#F5F5F5" alpha:1];
    _textView.font = [UIFont systemFontOfSize:14.0f];
    _textView.scrollsToTop = NO;
    _textView.returnKeyType = UIReturnKeyDone;
    _textView.enablesReturnKeyAutomatically = YES;
    _textView.textColor = [UIColor colorWithHexString:@"#333333" alpha:1];
    _textView.textContainerInset = UIEdgeInsetsMake(3, -5, 0, 0);
    _textView.inputAccessoryView = [self addToolbar];
    _textView.delegate = self;
    if (@available(iOS 11.0, *)) {
        _textView.textDragInteraction.enabled = NO;
    }
    [_containerView addSubview:_textView];
    // textview 改变字体的行间距
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 5;// 字体的行间距
    NSDictionary *attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:14],NSParagraphStyleAttributeName:paragraphStyle};
    //textView.attributedText = [[NSAttributedString alloc] initWithString:textView.text attributes:attributes];
    _textView.typingAttributes = attributes;
    
    _placeHolder = [[UILabel alloc]init];
    _placeHolder.text = @"我要提问～";
    _placeHolder.font = [UIFont systemFontOfSize:14];
    _placeHolder.textColor = [UIColor colorWithHexString:@"999999" alpha:0.8f];
    [_textView addSubview:_placeHolder];
    
    _addIMGBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _addIMGBtn.tag = 1002;
    [_addIMGBtn setImage:[UIImage imageNamed:@"图片nor"] forState:UIControlStateNormal];
    [_containerView addSubview:_addIMGBtn];
    [_addIMGBtn addTarget:self action:@selector(btnsTapped:) forControlEvents:UIControlEventTouchUpInside];
    _addIMGBtn.hidden = YES;
}

- (UIToolbar *)addToolbar {
    CGFloat kWidth = [UIScreen mainScreen].bounds.size.width;
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, kWidth, 35)];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"收起" style:UIBarButtonItemStylePlain target:self action:@selector(hiddenKeyboard)];
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [toolbar setItems:@[space,item]];
    return toolbar;
}

- (void)configureConstraints {
    
    __weak typeof(self) weakSelf = self;
    [_shadowLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(weakSelf);
        make.height.mas_equalTo(0.5);
    }];
    
    [_containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf).offset(5);
        make.left.mas_equalTo(weakSelf).offset(10);
        make.bottom.mas_equalTo(weakSelf).offset(-(5));
        make.right.mas_equalTo(weakSelf).offset(-10);
        make.height.mas_equalTo(35);
    }];
    _containerView.layer.cornerRadius = 17.5f;
    _containerView.layer.masksToBounds = YES;
    
    [_viewMeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.containerView).offset(5);
        make.bottom.mas_equalTo(weakSelf.containerView);
        make.width.height.mas_equalTo(35);
    }];
    
    [_textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.containerView).offset(44);
        make.top.mas_equalTo(weakSelf.containerView).offset(5);
        make.bottom.mas_equalTo(weakSelf.containerView).offset(-5);
        make.right.mas_equalTo(weakSelf.containerView).offset(-28);
    }];
    
    [_placeHolder mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(weakSelf.textView);
        make.left.mas_equalTo(weakSelf.textView);
    }];
    
    [_addIMGBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(weakSelf.containerView);
        make.bottom.mas_equalTo(weakSelf.containerView);
        make.width.height.mas_equalTo(35);
    }];
    
    [_sendBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(weakSelf).offset(-10);
        make.bottom.mas_equalTo(weakSelf).offset(-(6.5));
        make.width.mas_equalTo(50);
        make.height.mas_equalTo(32);
    }];
    _sendBtn.layer.cornerRadius = 2.f;
    _sendBtn.layer.masksToBounds = YES;
    
    self.layer.shadowColor = [UIColor colorWithHexString:@"#DDDDDD" alpha:1].CGColor;
    self.layer.shadowOffset = CGSizeMake(0, -0.5);
}

// MARK: - TextView Delegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([@"\n" isEqualToString:text]) {
        [self hiddenKeyboard];
        return NO;
    }
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView {

    _placeHolder.hidden = textView.text.length == 0 ? NO : YES;
//    // textview 改变字体的行间距
//    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
//    paragraphStyle.lineSpacing = 5;// 字体的行间距
//    NSDictionary *attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:14],NSParagraphStyleAttributeName:paragraphStyle};
//    //textView.attributedText = [[NSAttributedString alloc] initWithString:textView.text attributes:attributes];
//    textView.typingAttributes = attributes;
    
    NSInteger length = 1000;//限制的字数
    if (length != -1) {
        NSString *toBeString = textView.text;
        NSString *lang = textView.textInputMode.primaryLanguage;
        if ([lang isEqualToString:@"zh-Hans"]) { // 简体中文输入，包括简体拼音，健体五笔，简体手写
            UITextRange *selectedRange = [textView markedTextRange];       //获取高亮部分
            UITextPosition *position = [textView positionFromPosition:selectedRange.start offset:0];
            // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
            if (!position || !selectedRange) {
                if (toBeString.length > length) {
                    NSRange rangeIndex = [toBeString rangeOfComposedCharacterSequenceAtIndex:length];
                    if (rangeIndex.length == 1) {
                        textView.text = [toBeString substringToIndex:length];
                    } else {
                        NSRange rangeRange = [toBeString rangeOfComposedCharacterSequencesForRange:NSMakeRange(0, length)];
                        textView.text = [toBeString substringWithRange:rangeRange];
                    }
                    [self tipsShow:ALERT_INPUTLIMITATION];
                }
            }
        } else {
            if (toBeString.length > length) {
                textView.text = [toBeString substringToIndex:length];
                [self tipsShow:ALERT_INPUTLIMITATION];
            }
        }
    }
    
    self.resultMessage = textView.text;
    
    CGFloat height = self.textView.contentSize.height + 4 + 4;
    _updateCornerRadiusFlag = height <= 35 ? NO : YES;
    if (height < 35) {
        height = 35;
    } else if (height > 73) {
        height = 73;
    }
    
    [_containerView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(height);
    }];
    [_containerView layoutIfNeeded];
    
    [self changeTextViewCornerRadius:height];
    
    if (_kHeightCallBack) {
        _kHeightCallBack(height);
    }
}

// MARK: - Keyboard Observer
- (void)addObserver {
    // 键盘出现的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(kKeyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    // 键盘消失的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(kKeyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)removeObserver {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)kKeyboardWillShow:(NSNotification *)noti {
    [self changeConstraints:YES];
}

- (void)kKeyboardWillHide:(NSNotification *)noti {
    [self changeConstraints:NO];
}

- (void)hiddenKeyboard {
    [_textView resignFirstResponder];
}

// MARK: - Update Constraints
- (void)changeConstraints:(BOOL)isShow {
    NSString *inputMsg = _textView.text;
    CGFloat textViewLeftMargin = 44;
    CGFloat containerViewRightMargin = 10;
    CGFloat sendBtnBottomMargin = 6.5;
    _sendBtn.hidden = YES;
    if (inputMsg.length > 0 || isShow == YES) {
        textViewLeftMargin = 10;
        containerViewRightMargin = 70;
        sendBtnBottomMargin = 6.5;
        _sendBtn.hidden = NO;
    }
    __weak typeof(self) weakSelf = self;
    CGFloat textViewRightMargin = _allowAddImage == YES ? 28 : 3;
    [UIView animateWithDuration:0.35 animations:^{
        [weakSelf.textView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(weakSelf.containerView).offset(textViewLeftMargin);
            make.right.mas_equalTo(weakSelf.containerView).offset(-textViewRightMargin);
        }];
        [weakSelf.containerView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(weakSelf).offset(-containerViewRightMargin);
        }];
    }];
}

- (void)changeTextViewCornerRadius:(CGFloat)height {
    if (height <= 35) {
        if (_isNeedUpdateCornerRadius != _updateCornerRadiusFlag) {
            [UIView animateWithDuration:0.35 animations:^{
                _containerView.layer.cornerRadius = 17.5f;
                _containerView.layer.masksToBounds = YES;
            }];
        }
        _isNeedUpdateCornerRadius = NO;
    } else {
        if (_isNeedUpdateCornerRadius != _updateCornerRadiusFlag) {
            [UIView animateWithDuration:0.35 animations:^{
                _containerView.layer.cornerRadius = 4.f;
                _containerView.layer.masksToBounds = YES;
            }];
        }
        _isNeedUpdateCornerRadius = YES;
    }
}

// MARK: - Tip Information View
- (void)tipsShow:(NSString *)message {
    if ([self.delegate respondsToSelector:@selector(onTipsCallBack:)]) {
        [self.delegate onTipsCallBack:message];
    }
}

// MARK: - Button Tapped Action
- (void)btnsTapped:(UIButton *)sender {
    
    [self hiddenKeyboard];
    
    int btnsTag = (int)sender.tag;
    if (_kCallBack) {
        _kCallBack(btnsTag);
    }
    
    /// 查看我按钮点击事件
    if (btnsTag == 1001) {
        _viewMeBtn.selected = !sender.selected;
        [self tipsShow:ALERT_CHECKQUESTION(_viewMeBtn.selected)];
    }
    
    /// 发送问答按钮点击事件
    if (btnsTag == 1003) {
        if (_kCallBackMessage) {
            _kCallBackMessage(_resultMessage);
        }
        [self textViewDidChange:self.textView];
    }
}

- (void)dealloc {
    [self removeObserver];
}

@end
