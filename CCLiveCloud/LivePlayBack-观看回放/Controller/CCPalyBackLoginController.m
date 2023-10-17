//
//  CCPalyBackLoginController.m
//  CCLiveCloud
//
//  Created by MacBook Pro on 2018/10/29.
//  Copyright © 2018 MacBook Pro. All rights reserved.
//

#import "CCPalyBackLoginController.h"
#import "TextFieldUserInfo.h"
#import <AVFoundation/AVFoundation.h>
#import "ScanViewController.h"
#import "CCSDK/CCLiveUtil.h"
#import "CCSDK/RequestDataPlayBack.h"
#import "InformationShowView.h"
#import "LoadingView.h"
#import "CCPlayBackController.h"
#import "CCSDK/SaveLogUtil.h"
#import "HDSLoginErrorManager.h"
#import "UIColor+RCColor.h"
#import "CCcommonDefine.h"
#import "CCAlertView.h"
#import <Masonry/Masonry.h>

@interface CCPalyBackLoginController ()<UITextFieldDelegate,RequestDataPlayBackDelegate>

@property(nonatomic,strong)UILabel                      * informationLabel;//直播间信息
@property(nonatomic,strong)UIButton                     * loginBtn;//登录
@property(nonatomic,strong)LoadingView                  * loadingView;//加载视图
@property(nonatomic,strong)UIBarButtonItem              * leftBarBtn;//返回按钮
@property(nonatomic,strong)UIBarButtonItem              * rightBarBtn;//扫码
@property(nonatomic,strong)TextFieldUserInfo            * textFieldUserId;//UserId
@property(nonatomic,strong)TextFieldUserInfo            * textFieldRoomId;//RoomId
@property(nonatomic,strong)TextFieldUserInfo            * textFieldRecordId;//RecordId
@property(nonatomic,strong)TextFieldUserInfo            * textFieldUserName;//用户名
@property(nonatomic,strong)TextFieldUserInfo            * textFieldUserPassword;//密码
@property(nonatomic,strong)InformationShowView          * informationView;//提示窗
@property(nonatomic,assign)BOOL                         isShowTipView;//是否已显示输入过长提示框
@property (nonatomic,strong)RequestDataPlayBack         *requestDataPlayBack;

@end

@implementation CCPalyBackLoginController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];//创建UI
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //设置导航栏
    self.view.backgroundColor = [UIColor colorWithHexString:@"#f5f5f5" alpha:1.0f];
    self.navigationItem.leftBarButtonItem=self.leftBarBtn;
    self.navigationItem.rightBarButtonItem=self.rightBarBtn;
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithHexString:@"38404b" alpha:1.0f],NSForegroundColorAttributeName,[UIFont systemFontOfSize:FontSize_34],NSFontAttributeName,nil]];
    [self.navigationController.navigationBar setBackgroundImage:
     [self createImageWithColor:CCRGBColor(255,255,255)] forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    
    //设置输入框和登陆按钮
    [self setTextfields];
}

/**
 设置输入框和登陆按钮
 */
-(void)setTextfields{
    self.textFieldUserId.text = GetFromUserDefaults(PLAYBACK_USERID);
    self.textFieldRoomId.text = GetFromUserDefaults(PLAYBACK_ROOMID);
    self.textFieldRecordId.text = GetFromUserDefaults(PLAYBACK_RECORDID);
    self.textFieldUserName.text = GetFromUserDefaults(PLAYBACK_USERNAME);
    self.textFieldUserPassword.text = GetFromUserDefaults(PLAYBACK_PASSWORD);
    //设置登录按钮样式
    if(StrNotEmpty(_textFieldUserId.text) && StrNotEmpty(_textFieldRoomId.text)) {
        self.loginBtn.enabled = YES;
        [_loginBtn.layer setBorderColor:[CCRGBAColor(255,71,0,1) CGColor]];
    } else {
        self.loginBtn.enabled = NO;
        [_loginBtn.layer setBorderColor:[CCRGBAColor(255,71,0,0.6) CGColor]];
    }
}
#pragma mark- 必须实现的代理方法RequestDataPlayBackDelegate
/**
 *    @brief    请求成功
 */
-(void)loginSucceedPlayBack {
    SaveToUserDefaults(PLAYBACK_USERID,_textFieldUserId.text);
    SaveToUserDefaults(PLAYBACK_ROOMID,_textFieldRoomId.text);
    SaveToUserDefaults(PLAYBACK_RECORDID,_textFieldRecordId.text);
    SaveToUserDefaults(PLAYBACK_USERNAME,_textFieldUserName.text);
    SaveToUserDefaults(PLAYBACK_PASSWORD,_textFieldUserPassword.text);
    [_loadingView removeFromSuperview];
    _loadingView = nil;
    [UIApplication sharedApplication].idleTimerDisabled=YES;
    CCPlayBackController *playBackVC = [[CCPlayBackController alloc] init];
    playBackVC.screenCaptureSwitch = YES;
    playBackVC.modalPresentationStyle = 0;
    [self presentViewController:playBackVC animated:YES completion:^{
        _requestDataPlayBack = nil;
    }];
}

- (void)onLoginPlaybackFailed:(NSUInteger)code message:(NSString *)message {
    NSString *errorTipString = [HDSLoginErrorManager loginErrorCode:code message:message];
    if (errorTipString.length == 0) {
        errorTipString = [NSString stringWithFormat:@"错误码:%zd",code];
    }
    [_loadingView removeFromSuperview];
    _loadingView = nil;
    [_informationView removeFromSuperview];
    _informationView = [[InformationShowView alloc] initWithLabel:errorTipString];
    [self.view addSubview:_informationView];
    [_informationView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(informationViewRemove) userInfo:nil repeats:NO];
}


#pragma mark - 点击登录
/**
 点击登录
 */
-(void)loginAction {
    [self.view endEditing:YES];
    [self keyboardHide];
    if(self.textFieldUserName.text.length > 40) {
        [self showInformationView];//输入限制提示
        return;
    }
    //正在登录提示视图
    [self showLoadingView];
    //配置SDK
    [self integrationSDK];
}
/**
 配置SDK
 */
-(void)integrationSDK{
    
    PlayParameter *parameter = [[PlayParameter alloc] init];
    parameter.userId = self.textFieldUserId.text;//userId
    parameter.roomId = self.textFieldRoomId.text;//直播间Id
    parameter.recordId = self.textFieldRecordId.text;//回放Id
    parameter.viewerName = self.textFieldUserName.text;//昵称
    parameter.token = self.textFieldUserPassword.text;//密码
    parameter.viewerCustomua = @"viewerCustomua"; //用户自定义UA信息 可选。数据格式：字符串，限制40个字符
    parameter.viewercustominfo = @"viewercustominfo";// 用户自定义信息 可选。数据格式：字符串，最大长度200个字符
    self.requestDataPlayBack = [[RequestDataPlayBack alloc] initLoginWithParameter:parameter];
    self.requestDataPlayBack.delegate = self;
}
/**
 添加正在登录提示视图
 */
-(void)showLoadingView{
    _loadingView = [[LoadingView alloc] initWithLabel:LOGIN_LOADING centerY:NO];
    [self.view addSubview:_loadingView];
    
    [_loadingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    [_loadingView layoutIfNeeded];
}
/**
 *    @brief    显示昵称长图超出20字提示窗
 */
- (void)showTipView
{
    _isShowTipView = YES;
    CCAlertView *alertView = [[CCAlertView alloc] initWithAlertTitle:USERNAME_CONFINE sureAction:ALERT_SURE cancelAction:nil sureBlock:^{
        _isShowTipView = NO;
    }];
    [APPDelegate.window addSubview:alertView];
}
/**
 显示输入限制提示视图
 */
-(void)showInformationView{
    [_informationView removeFromSuperview];
    _informationView = [[InformationShowView alloc] initWithLabel:USERNAME_CONFINE];
    [self.view addSubview:_informationView];
    [_informationView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    //2秒后移除提示信息
    [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(informationViewRemove) userInfo:nil repeats:NO];
}

/**
 移除提示信息
 */
-(void)informationViewRemove {
    [_informationView removeFromSuperview];
    _informationView = nil;
}

#pragma mark UITextField Delegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

- (void) textFieldDidChange:(UITextField *) TextField {
    if(StrNotEmpty(_textFieldUserId.text) && StrNotEmpty(_textFieldRoomId.text)) {
        self.loginBtn.enabled = YES;
        [_loginBtn.layer setBorderColor:[CCRGBAColor(255,71,0,1) CGColor]];
    } else {
        self.loginBtn.enabled = NO;
        [_loginBtn.layer setBorderColor:[CCRGBAColor(255,71,0,0.6) CGColor]];
    }
}
//监听touch事件
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
    [self keyboardHide];
}

/**
 userName输入框长度改变
 */
- (void)textFieldEditChanged:(UITextField *)textField
{
    if (textField.markedTextRange == nil)//点击完选中的字之后
    {
        if (textField.text.length > 40) {
            if (_isShowTipView == NO) {
                [self showTipView];
            }
        }
    }
    else//没有点击出现的汉字,一直在点击键盘
    {
        if (textField.text.length > 118) { //等同于20个文字

        }
    }
    
    NSString *lang = [textField textInputMode].primaryLanguage;
    if ([lang isEqualToString:@"zh-Hans"]) {
        //输入简体中文内容
        //获取高亮部分，如拼音
        UITextRange *selectedRange = [textField markedTextRange];
        UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
        if (!position) {
            [self handleTextFieldCharLength:textField];
        }
    }
    else{
        //输入简体中文以外的内容
        [self handleTextFieldCharLength:textField];
    }
}

- (void)handleTextFieldCharLength:(UITextField *)textField
{
    NSString *toBeString = textField.text;
    if (textField.text.length > 40) {
        //获取超过50最大字符数的多余字符range
        NSRange rangeIndex = [toBeString rangeOfComposedCharacterSequenceAtIndex:40];
        if (rangeIndex.length == 1){
            //如果多余字符的length = 1，则直接截取最大字符数
            textField.text = [toBeString substringToIndex:40];
        }
        else{
            //如果多余字符的length > 1，则截取位置为（0.50），按输入内容单位截取
            NSRange rangeRange = [toBeString rangeOfComposedCharacterSequencesForRange:NSMakeRange(0, 40)];
            textField.text = [toBeString substringWithRange:rangeRange];
        }
    }
}

#pragma mark - 懒加载
//直播间信息
-(UILabel *)informationLabel {
    if(_informationLabel == nil) {
        _informationLabel = [[UILabel alloc] init];
        [_informationLabel setBackgroundColor:CCRGBColor(250, 250, 250)];
        [_informationLabel setFont:[UIFont systemFontOfSize:FontSize_24]];
        [_informationLabel setTextColor:CCRGBColor(102, 102, 102)];
        [_informationLabel setTextAlignment:NSTextAlignmentLeft];
        [_informationLabel setText:LOGIN_TEXT_INFOR];
    }
    return _informationLabel;
}
//左侧返回Btn
-(UIBarButtonItem *)leftBarBtn {
    if(_leftBarBtn == nil) {
        UIImage *aimage = [UIImage imageNamed:@"nav_ic_back_nor"];
        UIImage *image = [aimage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        _leftBarBtn = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(onSelectVC)];
    }
    return _leftBarBtn;
}
//右侧扫描按钮
-(UIBarButtonItem *)rightBarBtn {
    if(_rightBarBtn == nil) {
        UIImage *aimage = [UIImage imageNamed:@"nav_ic_code"];
        UIImage *image = [aimage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        _rightBarBtn = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(onSweepCode)];
    }
    return _rightBarBtn;
}


/**
 点击扫描按钮
 */
-(void)onSweepCode {
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    switch (status) {
        case AVAuthorizationStatusNotDetermined:{
            // 许可对话没有出现，发起授权许可
            [self requestAccess];
        }
            break;
        case AVAuthorizationStatusAuthorized:{
            // 已经开启授权，可继续
            ScanViewController *scanViewController = [[ScanViewController alloc] initWithType:3];
            [self.navigationController pushViewController:scanViewController animated:NO];
        }
            break;
        case AVAuthorizationStatusDenied:
        case AVAuthorizationStatusRestricted: {
            // 用户明确地拒绝授权，或者相机设备无法访问
            ScanViewController *scanViewController = [[ScanViewController alloc] initWithType:3];
            [self.navigationController pushViewController:scanViewController animated:NO];
        }
            break;
        default:
            break;
    }
}
/**
 发起授权许可
 */
-(void)requestAccess{
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (granted) {
                ScanViewController *scanViewController = [[ScanViewController alloc] initWithType:3];;
                [self.navigationController pushViewController:scanViewController animated:NO];
            }
        });
    }];
}
#pragma mark - UI布局
- (void)setupUI {
    self.title = LOGIN_PLAYBACK;
    //直播间信息
    [self.view addSubview:self.informationLabel];
    [_informationLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view).with.offset(20);
        make.top.mas_equalTo(self.view).with.offset(15);
        make.height.mas_equalTo(12);
    }];
    
    //添加输入框
    [self.view addSubview:self.textFieldUserId];
    [self.view addSubview:self.textFieldRoomId];
    [self.view addSubview:self.textFieldRecordId];
    [self.view addSubview:self.textFieldUserName];
    [self.view addSubview:self.textFieldUserPassword];
    //test   groupId
    //    [self.view addSubview:self.groupId];
    
    [self.textFieldUserName addTarget:self action:@selector(textFieldEditChanged:) forControlEvents:UIControlEventEditingChanged];
    //userId输入框
    [self.textFieldUserId mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.view);
        make.top.mas_equalTo(self.informationLabel.mas_bottom).with.offset(11);
        make.height.mas_equalTo(46);
    }];
    //roomId输入框
    [self.textFieldRoomId mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.textFieldUserId);
        make.top.mas_equalTo(self.textFieldUserId.mas_bottom);
        make.height.mas_equalTo(self.textFieldUserId.mas_height);
    }];
    //回放Id输入框
    [self.textFieldRecordId mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.textFieldUserId);
        make.top.mas_equalTo(self.textFieldRoomId.mas_bottom);
        make.height.mas_equalTo(self.textFieldRoomId.mas_height);
    }];
    //昵称输入框
    [self.textFieldUserName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.textFieldUserId);
        make.top.mas_equalTo(self.textFieldRecordId.mas_bottom);
        make.height.mas_equalTo(self.textFieldUserId.mas_height);
    }];
    //密码输入框
    [self.textFieldUserPassword mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.textFieldUserId);
        make.top.mas_equalTo(self.textFieldUserName.mas_bottom);
        make.height.mas_equalTo(self.textFieldUserId);
    }];
    //分界线
    UIView *line = [[UIView alloc] init];
    [self.view addSubview:line];
    [line setBackgroundColor:CCRGBColor(238,238,238)];
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.mas_equalTo(self.view);
        make.top.mas_equalTo(self.textFieldUserPassword.mas_bottom);
        make.height.mas_equalTo(1);
    }];
    //登录按钮
    [self.view addSubview:self.loginBtn];
    [_loginBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(line.mas_bottom).with.offset(40);
        make.centerX.equalTo(self.view);
        make.height.mas_equalTo(50);
        make.width.mas_equalTo(300);
    }];
    //添加通知
    [self addObserver];
}

#pragma mark - 懒加载
//userId输入框
-(TextFieldUserInfo *)textFieldUserId {
    if(_textFieldUserId == nil) {
        _textFieldUserId = [[TextFieldUserInfo alloc] init];
        _textFieldUserId.delegate = self;
        [_textFieldUserId textFieldWithLeftText:LOGIN_TEXT_USERID placeholder:LOGIN_TEXT_USERID_PLACEHOLDER lineLong:YES text:GetFromUserDefaults(PLAYBACK_USERID)];
        _textFieldUserId.rightView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 20, 0)];
        //设置显示模式为永远显示(默认不显示 必须设置 否则没有效果)
        _textFieldUserId.rightViewMode = UITextFieldViewModeAlways;
        [_textFieldUserId addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    }
    return _textFieldUserId;
}
//roomId输入框
-(TextFieldUserInfo *)textFieldRoomId {
    if(_textFieldRoomId == nil) {
        _textFieldRoomId = [[TextFieldUserInfo alloc] init];
        _textFieldRoomId.delegate = self;
        [_textFieldRoomId textFieldWithLeftText:LOGIN_TEXT_ROOMID placeholder:LOGIN_TEXT_ROOMID_PLACEHOLDER lineLong:NO text:GetFromUserDefaults(PLAYBACK_ROOMID)];
        _textFieldRoomId.rightView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 20, 0)];
        //设置显示模式为永远显示(默认不显示 必须设置 否则没有效果)
        _textFieldRoomId.rightViewMode = UITextFieldViewModeAlways;
        [_textFieldRoomId addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    }
    return _textFieldRoomId;
}
//回放Id输入框
-(TextFieldUserInfo *)textFieldRecordId {
    if(_textFieldRecordId == nil) {
        _textFieldRecordId = [[TextFieldUserInfo alloc] init];
        _textFieldRecordId.delegate = self;
        [_textFieldRecordId textFieldWithLeftText:LOGIN_TEXT_RECORDID placeholder:LOGIN_TEXT_RECORDID_PLACEHOLDER lineLong:NO text:GetFromUserDefaults(PLAYBACK_RECORDID)];
        _textFieldRecordId.rightView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 20, 0)];
        //设置显示模式为永远显示(默认不显示 必须设置 否则没有效果)
        _textFieldRecordId.rightViewMode = UITextFieldViewModeAlways;
        [_textFieldRecordId addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    }
    return _textFieldRecordId;
}
//昵称输入框
-(TextFieldUserInfo *)textFieldUserName {
    if(_textFieldUserName == nil) {
        _textFieldUserName = [[TextFieldUserInfo alloc] init];
        _textFieldUserName.delegate = self;
        [_textFieldUserName textFieldWithLeftText:LOGIN_TEXT_USERNAME placeholder:LOGIN_TEXT_USERNAME_PLACEHOLDER lineLong:NO text:GetFromUserDefaults(PLAYBACK_USERNAME)];
        _textFieldUserName.rightView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 20, 0)];
        //设置显示模式为永远显示(默认不显示 必须设置 否则没有效果)
        _textFieldUserName.rightViewMode = UITextFieldViewModeAlways;
        [_textFieldUserName addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    }
    return _textFieldUserName;
}
//密码输入框
-(TextFieldUserInfo *)textFieldUserPassword {
    if(_textFieldUserPassword == nil) {
        _textFieldUserPassword = [[TextFieldUserInfo alloc] init];
        _textFieldUserPassword.delegate = self;
        [_textFieldUserPassword textFieldWithLeftText:LOGIN_TEXT_PASSWORD placeholder:LOGIN_TEXT_PASSWORD_PLACEHOLDER lineLong:NO text:GetFromUserDefaults(PLAYBACK_PASSWORD)];
        _textFieldUserPassword.rightView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 20, 0)];
        //设置显示模式为永远显示(默认不显示 必须设置 否则没有效果)
        _textFieldUserPassword.rightViewMode = UITextFieldViewModeAlways;
        [_textFieldUserPassword addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        _textFieldUserPassword.secureTextEntry = YES;
    }
    return _textFieldUserPassword;
}


/**
 点击返回按钮
 */
-(void)onSelectVC {
    [self.navigationController popToRootViewControllerAnimated:YES];
}
#pragma mark - 添加通知
-(void)addObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

-(void)removeObserver {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

-(void)dealloc {
    [self removeObserver];
}

#pragma mark keyboard notification
- (void)keyboardWillShow:(NSNotification *)notif {
    if(![self.textFieldRoomId isFirstResponder] && ![self.textFieldUserId isFirstResponder] && [self.textFieldUserName isFirstResponder] && ![self.textFieldUserPassword isFirstResponder]  && ![self.textFieldRecordId isFirstResponder]) {
        return;
    }
    NSDictionary *userInfo = [notif userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    CGFloat y = keyboardRect.size.height;

    for (int i = 1; i <= 4; i++) {
        UITextField *textField = [self.view viewWithTag:i];
        if ([textField isFirstResponder] == true && (SCREEN_HEIGHT - (CGRectGetMaxY(textField.frame) + 5)) < y) {
            WS(ws)
            [self.informationLabel mas_updateConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(ws.view).with.offset(20);
                make.top.mas_equalTo(ws.view).with.offset( - (y - (SCREEN_HEIGHT - (CGRectGetMaxY(textField.frame) + 5))));
                make.height.mas_equalTo(12);
            }];
            [UIView animateWithDuration:0.25f animations:^{
                [ws.view layoutIfNeeded];
            }];
        }
    }
}
//隐藏键盘
-(void)keyboardHide {
    WS(ws)
    [self.informationLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(ws.view).with.offset(20);
        make.top.mas_equalTo(ws.view).with.offset(20);;
        make.height.mas_equalTo(12);
    }];
    
    [UIView animateWithDuration:0.25f animations:^{
        [ws.view layoutIfNeeded];
    }];
}
//键盘将要隐藏
- (void)keyboardWillHide:(NSNotification *)notif {
    [self keyboardHide];
}


/**
 color转image

 @param color color
 @return image
 */
- (UIImage*)createImageWithColor:(UIColor*) color
{
    CGRect rect=CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}
//登录按钮
-(UIButton *)loginBtn {
    if(_loginBtn == nil) {
        _loginBtn = [[UIButton alloc] init];
        [_loginBtn setTitle:@"登 录" forState:UIControlStateNormal];
        [_loginBtn.titleLabel setFont:[UIFont systemFontOfSize:FontSize_36]];
        [_loginBtn setTitleColor:CCRGBAColor(255, 255, 255, 1) forState:UIControlStateNormal];
        [_loginBtn setTitleColor:CCRGBAColor(255, 255, 255, 0.4) forState:UIControlStateDisabled];
        [_loginBtn setBackgroundImage:[UIImage imageNamed:@"default_btn"] forState:UIControlStateNormal];
        [_loginBtn setBackgroundImage: [UIImage imageNamed:@"default_btn"] forState:UIControlStateHighlighted];
        _loginBtn.layer.cornerRadius = 25;
        [_loginBtn addTarget:self action:@selector(loginAction) forControlEvents:UIControlEventTouchUpInside];
        [_loginBtn.layer setMasksToBounds:YES];
    }
    return _loginBtn;
}
#pragma mark - 屏幕旋转
- (BOOL)shouldAutorotate{
    return NO;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}
@end
