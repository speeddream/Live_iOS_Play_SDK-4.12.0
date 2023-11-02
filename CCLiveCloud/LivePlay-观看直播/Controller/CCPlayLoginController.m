//
//  CCPlayLoginController.m
//  CCLiveCloud
//
//  Created by MacBook Pro on 2018/10/29.
//  Copyright © 2018 MacBook Pro. All rights reserved.
//

#import "CCPlayLoginController.h"
#import "TextFieldUserInfo.h"
#import "CCSDK/CCLiveUtil.h"
#import "CCSDK/RequestData.h"
#import <AVFoundation/AVFoundation.h>
#import "ScanViewController.h"
#import "CCLiveCloud.pch"
#import <UIKit/UIKit.h>
#import "CCPlayerController.h"
#import "LoadingView.h"
#import "InformationShowView.h"
#import "HDSLoginErrorManager.h"
#import "UIColor+RCColor.h"
#import "CCcommonDefine.h"
#import "CCAlertView.h"
#import <Masonry/Masonry.h>

@interface CCPlayLoginController ()<UITextFieldDelegate,RequestDataDelegate>

@property (nonatomic, copy)NSString               * roomName;//房间名
@property (nonatomic, strong)UILabel              * informationLabel;//直播间信息
@property (nonatomic, strong)UIButton             * loginBtn;//登录按钮
@property (nonatomic, strong)LoadingView          * loadingView;//加载视图
@property (nonatomic, strong)UIBarButtonItem      * rightBarBtn;//扫码
@property (nonatomic, strong)UIBarButtonItem      * leftBarBtn;//返回
@property (nonatomic, strong)TextFieldUserInfo    * textFieldUserId;//UserId
@property (nonatomic, strong)TextFieldUserInfo    * textFieldRoomId;//RoomId
@property (nonatomic, strong)TextFieldUserInfo    * textFieldUserName;//用户名
@property (nonatomic, strong)TextFieldUserInfo    * textFieldUserPassword;//密码
@property (nonatomic, strong)InformationShowView  * informationView;//提示
@property (nonatomic, assign)BOOL                  isShowTipView;//是否已显示输入过长提示框
@property (nonatomic, assign)RequestData          * requestData;
@property (nonatomic, assign)NSTimeInterval         loginBtnClickInterval;

@end

@implementation CCPlayLoginController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];//创建UI
    [self addObserver];//添加通知
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //设置导航栏信息
    self.navigationItem.title = LOGIN_PLAY;
    self.view.backgroundColor = [UIColor colorWithHexString:@"#f5f5f5" alpha:1.0f];
    self.navigationItem.leftBarButtonItem=self.leftBarBtn;
    self.navigationItem.rightBarButtonItem=self.rightBarBtn;
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithHexString:@"38404b" alpha:1.0f],NSForegroundColorAttributeName,[UIFont systemFontOfSize:FontSize_34],NSFontAttributeName,nil]];
    [self.navigationController.navigationBar setBackgroundImage:
     [self createImageWithColor:CCRGBColor(255,255,255)] forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;

    //设置输入框和登陆按钮
    self.textFieldUserId.text = GetFromUserDefaults(WATCH_USERID);//userId
    self.textFieldRoomId.text = GetFromUserDefaults(WATCH_ROOMID);//roomId
    self.textFieldUserName.text = GetFromUserDefaults(WATCH_USERNAME);//userName
    self.textFieldUserPassword.text = GetFromUserDefaults(WATCH_PASSWORD);//password
    if(StrNotEmpty(_textFieldUserId.text) && StrNotEmpty(_textFieldRoomId.text)) {
        self.loginBtn.enabled = YES;
        [_loginBtn.layer setBorderColor:[CCRGBAColor(255,71,0,1) CGColor]];
    } else {
        self.loginBtn.enabled = NO;
        [_loginBtn.layer setBorderColor:[CCRGBAColor(255,71,0,0.6) CGColor]];
    }
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.textFieldUserId.text = @"5BD067B602DE357D";
    self.textFieldRoomId.text = @"F66286F3A277B2E69C33DC5901307461";
    self.textFieldUserPassword.text = @"1198324798280347648";
    self.textFieldUserName.text = @"xkw_317427709";
}

#pragma mark- 点击登录
/**
 *    @brief    点击登陆按钮
 */
-(void)loginAction {
    [self.view endEditing:YES];
    NSTimeInterval nowTime = [[NSDate date] timeIntervalSince1970] * 1000;
    if (nowTime - self.loginBtnClickInterval < 1000) {
        return;
    }
    self.loginBtnClickInterval = nowTime;
    //限制用户名长度
    if(self.textFieldUserName.text.length > 40) {
        [self showInformationView];
        return;
    }
    //添加提示视图
    [self showLoadingView];
    
    //配置SDK
    [self integrationSDK];
}
/**
 *    @brief    配置SDK
 */
-(void)integrationSDK{
    if (_requestData) {
        _requestData = nil;
    }
    PlayParameter *parameter = [[PlayParameter alloc] init];
    parameter.userId = self.textFieldUserId.text;//userId
    parameter.roomId = self.textFieldRoomId.text;//roomId
    parameter.viewerName = self.textFieldUserName.text;//观看者昵称
    parameter.token = self.textFieldUserPassword.text;//登陆密码
    parameter.viewerCustomua = @"viewercustomua";//自定义参数
    parameter.tpl = 20;
    RequestData *requestData = [[RequestData alloc] initLoginWithParameter:parameter];
    requestData.delegate = self;
    _requestData = requestData;
}
/**
*    @brief    显示昵称长图超出20字提示窗
*/
- (void)showTipView
{
    _isShowTipView = YES;
    CCAlertView *alertView = [[CCAlertView alloc] initWithAlertTitle:USERNAME_CONFINE sureAction:ALERT_SURE cancelAction:nil sureBlock:^{
        _isShowTipView = NO;
        [self.view endEditing:YES];
    }];
    [APPDelegate.window addSubview:alertView];
}

/**
 *    @brief    用户名过长提示
 */
-(void)showInformationView{
    [_informationView removeFromSuperview];
    _informationView = [[InformationShowView alloc] initWithLabel:USERNAME_CONFINE];
    [self.view addSubview:_informationView];
    [_informationView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(removeInformationView) userInfo:nil repeats:NO];
}
/**
 *    @brief    添加正在登录提示视图
 */
-(void)showLoadingView{
    if (_loadingView) {
        [_loadingView removeFromSuperview];
        _loadingView = nil;
    }
    _loadingView = [[LoadingView alloc] initWithLabel:LOGIN_LOADING centerY:NO];
    [self.view addSubview:_loadingView];
    
    [_loadingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    [_loadingView layoutIfNeeded];
}
#pragma mark- 必须实现的代理方法RequestDataDelegate
//@optional
/**
 *    @brief    请求成功
 */
-(void)loginSucceedPlay {
    if (_requestData) {
        [_requestData requestCancel];
        _requestData.delegate = nil;
        _requestData = nil;
    }
    SaveToUserDefaults(WATCH_USERID,_textFieldUserId.text);
    SaveToUserDefaults(WATCH_ROOMID,_textFieldRoomId.text);
    SaveToUserDefaults(WATCH_USERNAME,_textFieldUserName.text);
    SaveToUserDefaults(WATCH_PASSWORD,_textFieldUserPassword.text);
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSelf.loadingView removeFromSuperview];
        weakSelf.loadingView = nil;
        [UIApplication sharedApplication].idleTimerDisabled=YES;
        CCPlayerController *playForPCVC = [[CCPlayerController alloc] initWithRoomName:weakSelf.roomName];
        playForPCVC.modalPresentationStyle = 0;
        playForPCVC.screenCaptureSwitch = YES;
        [weakSelf presentViewController:playForPCVC animated:YES completion:^{
            
        }];
    });
}

/// 4.10.0 new 登陆失败错误回调（仅登陆方法响应代理）
/// @param code code值
/// @param message 错误信息
- (void)onLoginFailed:(NSUInteger)code message:(NSString *)message {
    
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

    [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(removeInformationView) userInfo:nil repeats:NO];
}

/**
 *    @brief  获取房间信息
 *    房间名称：dic[@"name"];
 */
-(void)roomInfo:(NSDictionary *)dic {
    _roomName = dic[@"name"];
}
#pragma mark - 导航栏按钮点击事件
/**
 *    @brief    点击返回按钮
 */
- (void)onSelectVC {
    [self.navigationController popViewControllerAnimated:NO];
}
/**
 点击扫码按钮
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
            ScanViewController *scanViewController = [[ScanViewController alloc] initWithType:2];
            [self.navigationController pushViewController:scanViewController animated:NO];
        }
            break;
        case AVAuthorizationStatusDenied:
        case AVAuthorizationStatusRestricted: {
            // 用户明确地拒绝授权，或者相机设备无法访问
            ScanViewController *scanViewController = [[ScanViewController alloc] initWithType:2];
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
    WS(ws)
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (granted) {//如果同意请求
                ScanViewController *scanViewController = [[ScanViewController alloc] initWithType:2];;
                [ws.navigationController pushViewController:scanViewController animated:NO];
            }
        });
    }];
}
#pragma mark - 移除提示信息
-(void)removeInformationView {
    [_informationView removeFromSuperview];
    _informationView = nil;
}
//监听touch事件
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
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
        if (textField.text.length > 118) { //相当于20个字符
        
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

#pragma mark UITextField Delegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidChange:(UITextField *) TextField {
    if(StrNotEmpty(_textFieldUserId.text) && StrNotEmpty(_textFieldRoomId.text)) {
        self.loginBtn.enabled = YES;
        [_loginBtn.layer setBorderColor:[CCRGBAColor(255,71,0,1) CGColor]];
    } else {
        self.loginBtn.enabled = NO;
        [_loginBtn.layer setBorderColor:[CCRGBAColor(255,71,0,0.6) CGColor]];
    }
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
//移除通知
-(void)removeObserver {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark keyboard notification
- (void)keyboardWillShow:(NSNotification *)notif {
    if(![self.textFieldRoomId isFirstResponder] && ![self.textFieldUserId isFirstResponder] && [self.textFieldUserName isFirstResponder] && ![self.textFieldUserPassword isFirstResponder]) {
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
                make.width.mas_equalTo(ws.view.mas_width).multipliedBy(0.5);
                make.height.mas_equalTo(12);
            }];
            [UIView animateWithDuration:0.25f animations:^{
                [ws.view layoutIfNeeded];
            }];
        }
    }
}
//键盘将要隐藏
- (void)keyboardWillHide:(NSNotification *)notif {
    
}

/**
 UI布局
 */
- (void)setupUI {
    //添加输入框和登陆按钮
    [self.view addSubview:self.textFieldUserId];
    [self.view addSubview:self.textFieldRoomId];
    [self.view addSubview:self.textFieldUserName];
    [self.view addSubview:self.textFieldUserPassword];
    [self.view addSubview:self.informationLabel];
    [self.view addSubview:self.loginBtn];
    
    [self.textFieldUserName addTarget:self action:@selector(textFieldEditChanged:) forControlEvents:UIControlEventEditingChanged];
    //直播间信息
    [self.informationLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view).with.offset(20);
        make.top.mas_equalTo(self.view).with.offset(20);
        make.width.mas_equalTo(self.view.mas_width).multipliedBy(0.3);
        make.height.mas_equalTo(12);
    }];
    //userId输入框
    [self.textFieldUserId mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.view);
        make.top.mas_equalTo(self.informationLabel.mas_bottom).with.offset(11);
        make.height.mas_equalTo(46);
    }];
    //直播间Id输入框
    [self.textFieldRoomId mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.textFieldUserId);
        make.top.mas_equalTo(self.textFieldUserId.mas_bottom);
        make.height.mas_equalTo(self.textFieldUserId.mas_height);
    }];
    //昵称输入框
    [self.textFieldUserName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.textFieldUserId);
        make.top.mas_equalTo(self.textFieldRoomId.mas_bottom);
        make.height.mas_equalTo(self.textFieldRoomId.mas_height);
    }];
    //密码输入框
    [self.textFieldUserPassword mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.textFieldUserId);
        make.top.mas_equalTo(self.textFieldUserName.mas_bottom);
        make.height.mas_equalTo(self.textFieldUserName);
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
    //登陆按钮约束
    [_loginBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(line.mas_bottom).with.offset(40);
        make.centerX.equalTo(self.view);
        make.height.mas_equalTo(50);
        make.width.mas_equalTo(300);
    }];
}


#pragma mark - 懒加载
//登陆按钮
-(UIButton *)loginBtn {
    if(_loginBtn == nil) {
        _loginBtn = [[UIButton alloc] init];
        [_loginBtn setTitle:@"登 录" forState:UIControlStateNormal];
        [_loginBtn.titleLabel setFont:[UIFont systemFontOfSize:FontSize_36]];
        [_loginBtn setTitleColor:CCRGBAColor(255, 255, 255, 1) forState:UIControlStateNormal];
        [_loginBtn setTitleColor:CCRGBAColor(255, 255, 255, 0.4) forState:UIControlStateDisabled];
        [_loginBtn setBackgroundImage:[UIImage imageNamed:@"default_btn"] forState:UIControlStateNormal];
        _loginBtn.layer.cornerRadius = 25;
        [_loginBtn addTarget:self action:@selector(loginAction) forControlEvents:UIControlEventTouchUpInside];
        [_loginBtn.layer setMasksToBounds:YES];
    }
    return _loginBtn;
}
//右侧导航按钮
-(UIBarButtonItem *)rightBarBtn {
    if(_rightBarBtn == nil) {
        UIImage *aimage = [UIImage imageNamed:@"nav_ic_code"];
        UIImage *image = [aimage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        _rightBarBtn = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(onSweepCode)];
    }
    return _rightBarBtn;
}
//左侧返回按钮
-(UIBarButtonItem *)leftBarBtn {
    if(_leftBarBtn == nil) {
        UIImage *aimage = [UIImage imageNamed:@"nav_ic_back_nor"];
        UIImage *image = [aimage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        _leftBarBtn = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(onSelectVC)];
    }
    return _leftBarBtn;
}
//userId输入框
-(TextFieldUserInfo *)textFieldUserId {
    if(_textFieldUserId == nil) {
        _textFieldUserId = [[TextFieldUserInfo alloc] init];
        [_textFieldUserId textFieldWithLeftText:LOGIN_TEXT_USERID placeholder:LOGIN_TEXT_USERID_PLACEHOLDER lineLong:YES text:GetFromUserDefaults(WATCH_USERID)];
        _textFieldUserId.delegate = self;
        _textFieldUserId.tag = 1;
        _textFieldUserId.rightView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 20, 0)];
        //设置显示模式为永远显示(默认不显示 必须设置 否则没有效果)
        _textFieldUserId.rightViewMode = UITextFieldViewModeAlways;
        [_textFieldUserId addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    }
    return _textFieldUserId;
}
//直播间id输入框
-(TextFieldUserInfo *)textFieldRoomId {
    if(_textFieldRoomId == nil) {
        _textFieldRoomId = [[TextFieldUserInfo alloc] init];
        [_textFieldRoomId textFieldWithLeftText:LOGIN_TEXT_ROOMID placeholder:LOGIN_TEXT_ROOMID_PLACEHOLDER lineLong:NO text:GetFromUserDefaults(WATCH_ROOMID)];
        _textFieldRoomId.delegate = self;
        _textFieldRoomId.tag = 2;
        _textFieldRoomId.rightView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 20, 0)];
        //设置显示模式为永远显示(默认不显示 必须设置 否则没有效果)
        _textFieldRoomId.rightViewMode = UITextFieldViewModeAlways;
        [_textFieldRoomId addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    }
    return _textFieldRoomId;
}
//昵称输入框
-(TextFieldUserInfo *)textFieldUserName {
    if(_textFieldUserName == nil) {
        _textFieldUserName = [[TextFieldUserInfo alloc] init];
        [_textFieldUserName textFieldWithLeftText:LOGIN_TEXT_USERNAME placeholder:LOGIN_TEXT_USERNAME_PLACEHOLDER lineLong:NO text:GetFromUserDefaults(WATCH_USERNAME)];
        _textFieldUserName.delegate = self;
        _textFieldUserName.tag = 3;
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
        [_textFieldUserPassword textFieldWithLeftText:LOGIN_TEXT_PASSWORD placeholder:LOGIN_TEXT_PASSWORD_PLACEHOLDER lineLong:NO text:GetFromUserDefaults(WATCH_PASSWORD)];
        _textFieldUserPassword.delegate = self;
        _textFieldUserPassword.tag = 4;
        _textFieldUserPassword.rightView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 20, 0)];
        //设置显示模式为永远显示(默认不显示 必须设置 否则没有效果)
        _textFieldUserPassword.rightViewMode = UITextFieldViewModeAlways;
        [_textFieldUserPassword addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        _textFieldUserPassword.secureTextEntry = YES;
    }
    return _textFieldUserPassword;
}
//直播间信息提示文本
-(UILabel *)informationLabel {
    if(_informationLabel == nil) {
        _informationLabel = [[UILabel alloc] init];
        [_informationLabel setFont:[UIFont systemFontOfSize:FontSize_24]];
        [_informationLabel setTextColor:CCRGBColor(102, 102, 102)];
        [_informationLabel setTextAlignment:NSTextAlignmentLeft];
        [_informationLabel setText:LOGIN_TEXT_INFOR];
    }
    return _informationLabel;
}
//用color返回一个image
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

-(void)dealloc {
    [self removeObserver];
}

@end
