//
//  CCEntranceViewController.m
//  CCLiveCloud
//
//  Created by MacBook Pro on 2018/10/19.
//  Copyright © 2018 MacBook Pro. All rights reserved.
//



#import "CCEntranceViewController.h"
#import "CCLiveCloud.pch"
#import "CCPlayLoginController.h"
#import "CCPalyBackLoginController.h"
#import "CCPlayerController.h"
#import "CCPlayBackController.h"
#import "CCcommonDefine.h"
#import "CCDownloadViewController.h"
#import "HDSLiveStreamLoginController.h"
#import "HDSPrivacyView.h"
#import "HSAgreementWebController.h"
#import <Masonry/Masonry.h>

#define loginBtnImageName @"default_btn"

@interface CCEntranceViewController ()

@property(nonatomic, strong)HDSPrivacyView                  *pv;
@property(nonatomic, strong)HSAgreementWebController        *pweb;
@property(nonatomic, strong)UIButton                        *yinsBTN;
@property(nonatomic, strong)UIButton                        *fuwuBTN;

@end

@implementation CCEntranceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
/**
 *  @brief  创建UI
 */
    [self setupUI];
    
    [self addObserver];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
/**
 *  @brief  隐藏导航
 */
    self.navigationController.navigationBarHidden = YES;
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
/**
 *  @brief  显示导航
 */
    self.navigationController.navigationBarHidden = NO;
}
/**
 *  @brief  创建UI
 */
- (void)setupUI{
    /// 背景图颜色
    self.view.backgroundColor = [[UIColor alloc] initWithRed:248.0/255.0 green:248.0/255.0 blue:248.0/255.0 alpha:1.0];
    //背景图
    UIImageView *bgView = [[UIImageView alloc] init];
    bgView.backgroundColor = [UIColor whiteColor];
    bgView.frame = self.view.frame;
    if (IS_IPHONE_X) {
        bgView.image = [UIImage imageNamed:@"launch_backgroundImage"];
    } else {
        bgView.image = [UIImage imageNamed:@"default_bg"];
    }
    /// 背景图适配iPad
    bgView.backgroundColor = [UIColor clearColor];
    bgView.contentMode = UIViewContentModeTop;
    [self.view addSubview:bgView];
    if ([[UIDevice currentDevice].model isEqualToString:@"iPad"]) {
        [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self.view);
        }];
    } else {
        [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.view).offset(-[[UIScreen mainScreen] bounds].size.height * 0.08);
            make.left.right.mas_equalTo(self.view);
            make.bottom.mas_equalTo(self.view);
        }];
    }
    
    //观看直播
    UIButton *palyButton = [[UIButton alloc] init];
    [palyButton setBackgroundImage: [UIImage imageNamed:loginBtnImageName] forState:UIControlStateNormal];
    [palyButton setBackgroundImage: [UIImage imageNamed:loginBtnImageName] forState:UIControlStateHighlighted];
    
    [palyButton setTitle:@"横屏观看" forState:UIControlStateNormal];
    [palyButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    palyButton.titleLabel.font = [UIFont systemFontOfSize:FontSize_36];
    palyButton.layer.cornerRadius = 25;
    [self.view addSubview:palyButton];
    CGFloat deviceOffset = iPhone5_5s_5c_5SE ? -40 : 50;
    if (iPhone6_6s_7) {
        deviceOffset = -30;
    }
    [palyButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.view).offset(SCREEN_HEIGHT/2.5+deviceOffset);
        make.width.mas_equalTo(300);
        make.height.mas_equalTo(50);
    }];
    [palyButton layoutIfNeeded];
    [palyButton addTarget:self action:@selector(palyButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    //观看竖屏纯视频直播
    UIButton *liveBtn = [[UIButton alloc] init];
    [liveBtn setBackgroundImage: [UIImage imageNamed:loginBtnImageName] forState:UIControlStateNormal];
    [liveBtn setBackgroundImage: [UIImage imageNamed:loginBtnImageName] forState:UIControlStateHighlighted];
    
    [liveBtn setTitle:@"竖屏观看" forState:UIControlStateNormal];
    [liveBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    liveBtn.titleLabel.font = [UIFont systemFontOfSize:FontSize_36];
    liveBtn.layer.cornerRadius = 25;
    [self.view addSubview:liveBtn];
    [liveBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.height.equalTo(palyButton);
        make.top.equalTo(palyButton.mas_bottom).offset(20);
    }];
    [liveBtn layoutIfNeeded];
    [liveBtn addTarget:self action:@selector(liveBtnClick) forControlEvents:UIControlEventTouchUpInside];
    
    
//观看回放
    UIButton *palyBackButton = [[UIButton alloc] init];
    [palyBackButton setBackgroundImage: [UIImage imageNamed:loginBtnImageName] forState:UIControlStateNormal];
    [palyBackButton setBackgroundImage: [UIImage imageNamed:loginBtnImageName] forState:UIControlStateHighlighted];
    [palyBackButton setTitle:@"观看回放" forState:UIControlStateNormal];
    [palyBackButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    palyBackButton.titleLabel.font = [UIFont systemFontOfSize:FontSize_36];
    palyBackButton.layer.cornerRadius = 25;
    [self.view addSubview:palyBackButton];
    [palyBackButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.height.equalTo(liveBtn);
        make.top.equalTo(liveBtn.mas_bottom).offset(20);
    }];
    [palyBackButton addTarget:self action:@selector(palyBackButtonClick) forControlEvents:UIControlEventTouchUpInside];
    palyBackButton.layer.cornerRadius = 25;
    
    
//离线回放
    UIButton *localPlayButton = [[UIButton alloc]init];
    [localPlayButton setBackgroundImage:[UIImage imageNamed:loginBtnImageName] forState:UIControlStateNormal];
    [localPlayButton setBackgroundImage:[UIImage imageNamed:loginBtnImageName] forState:UIControlStateHighlighted];
    [localPlayButton setTitle:@"离线回放" forState:UIControlStateNormal];
    [localPlayButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    localPlayButton.titleLabel.font = [UIFont systemFontOfSize:FontSize_36];
    [self.view addSubview:localPlayButton];
    [localPlayButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.height.equalTo(palyBackButton);
        make.top.equalTo(palyBackButton.mas_bottom).offset(20);
    }];
    [localPlayButton addTarget:self action:@selector(localPlayButtonClick) forControlEvents:UIControlEventTouchUpInside];
    localPlayButton.layer.cornerRadius = 25;
    
    
    
    UILabel *label = [[UILabel alloc] init];
    label.text = @"版本: hd_sdk_v 4.12.0";
    label.textColor = [UIColor lightGrayColor];
    [self.view addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-30);
    }];
    
    __weak typeof(self) ws = self;

    [self.view addSubview:self.yinsBTN];
    [_yinsBTN mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(ws.view.mas_bottom).offset(-60);
        make.width.mas_equalTo(120);
        make.height.mas_equalTo(30);
        make.centerX.mas_equalTo(ws.view.mas_centerX).offset(-50);
    }];
    
    [self.view addSubview:self.fuwuBTN];
    [_fuwuBTN mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(ws.view.mas_bottom).offset(-60);
        make.width.mas_equalTo(120);
        make.height.mas_equalTo(30);
        make.centerX.mas_equalTo(ws.view.mas_centerX).offset(50);
    }];
    
    self.pv = [HDSPrivacyView showView:@"HD云直播 隐私协议" contentText:@"我们非常看重您的个人信息和隐私保护。为了更好的保护您的个人权益，在您使用我们产品前，请务必审慎阅读《隐私协议》、《使用协议》所有条款。\n如您对以上协议有任何疑问，可发送邮件到sdk@bokecc.com或通过官方反馈后台反馈。您点击“同意”的行为即表示您已阅读完毕并同意以上协议的全部内容。\n请在同意隐私协议政策后再申请获取用户个人信息及权限。" heighlighted:@"隐私协议" heightlightedSecd:@"使用协议" superRect:self.view.bounds callBack:^(HDSCallBackActionType actionType) {
        if (actionType == HDSCallBackActionType_OK) {
            [ws.pv remoeView];
        }
        if (actionType == HDSCallBackActionType_YINSI) {
            [ws routeToAgreementWeb:@"https://admin.bokecc.com/privacy.bo?client=ios"];
        }
        if (actionType == HDSCallBackActionType_FUWU) {
            [ws routeToAgreementWeb:@"https://admin.bokecc.com/agreement.bo?client=ios"];
        }
    }];
    [self.view addSubview:self.pv];
}

-(void)routeToAgreementWeb:(NSString *)address {
    HSAgreementWebController *pweb = [[HSAgreementWebController alloc] init];
    pweb.url = address;
    pweb.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:pweb animated:NO completion:nil];
}

/**
 *  @brief  点击观看直播
 */
- (void)palyButtonClick {
    CCPlayLoginController *vc = [[CCPlayLoginController alloc] init];
//两周跳转方式
//    [self presentViewController:vc animated:YES completion:nil];
    [self.navigationController pushViewController:vc animated:NO];
}

- (void)liveBtnClick {
    HDSLiveStreamLoginController *vc = [[HDSLiveStreamLoginController alloc]init];
    [self.navigationController pushViewController:vc animated:NO];
}

/**
 *  @brief  点击观看回放
 */
- (void)palyBackButtonClick {
    CCPalyBackLoginController *vc = [[CCPalyBackLoginController alloc] init];
//两种跳转方式
//        [self presentViewController:vc animated:YES completion:nil];
    [self.navigationController pushViewController:vc animated:NO];
}
/**
 *  @brief  点击观看离线回放
 */
- (void)localPlayButtonClick {
    CCDownloadViewController *vc = [[CCDownloadViewController alloc] init];
//两种跳转方式
//        [self presentViewController:vc animated:YES completion:nil];
    [self.navigationController pushViewController:vc animated:NO];
}


- (UIButton *)yinsBTN {
    if (_yinsBTN == nil) {
        _yinsBTN = [[UIButton alloc] init];
        [_yinsBTN setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
        _yinsBTN.titleLabel.font = [UIFont systemFontOfSize:13];
        [_yinsBTN setTitle:@"《隐私协议》" forState:UIControlStateNormal];
        [_yinsBTN addTarget:self action:@selector(yinsTapped:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _yinsBTN;
}

- (UIButton *)fuwuBTN {
    if (_fuwuBTN == nil) {
        _fuwuBTN = [[UIButton alloc] init];
        [_fuwuBTN setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
        _fuwuBTN.titleLabel.font = [UIFont systemFontOfSize:13];
        [_fuwuBTN setTitle:@"《使用协议》" forState:UIControlStateNormal];
        [_fuwuBTN addTarget:self action:@selector(fuwuTapped:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _fuwuBTN;
}

- (void)yinsTapped:(UIButton *)sender {
    [self routeToAgreementWeb:@"https://admin.bokecc.com/privacy.bo"];
}

- (void)fuwuTapped:(UIButton *)sender {
    [self routeToAgreementWeb:@"https://admin.bokecc.com/agreement.bo"];
}

/**
 *  @brief  旋转屏设置
 */
- (BOOL)shouldAutorotate{
    return YES;
}
//返回优先方向
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}
//返回支持的方向
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}
#pragma mark - 添加通知
-(void)addObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(openUrl:)
                                                 name:@"openUrl"
                                               object:nil];
}
-(void)removeObserver {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"openUrl" object:nil];
}

-(void)dealloc {
    [self removeObserver];
}
-(void)openUrl:(NSNotification *)info {
    for (UIViewController *controller in self.navigationController.viewControllers) {
        /*        当存在登录直播页面或者直播回放页面时   需要清除这些控制器     */
        if ([controller isKindOfClass:[CCPlayLoginController class]] || [controller isKindOfClass:[CCPalyBackLoginController class]]) {
            if (controller.presentedViewController) {
                [controller.presentedViewController dismissViewControllerAnimated:NO completion:nil];
                /* 移除控制器中一些添加在window上的视图  */
                for (UIView *view in APPDelegate.window.subviews) {
                    [view removeFromSuperview];
                }
            }
            [self.navigationController popToRootViewControllerAnimated:NO];
            break;
        }
    }
    
    NSString *roomType = info.userInfo[@"roomType"];
    if ([roomType isEqualToString:@"live"]) {//进入观看直播
        CCPlayLoginController *vc = [[CCPlayLoginController alloc] init];
        //两周跳转方式
        //    [self presentViewController:vc animated:YES completion:nil];
        [self.navigationController pushViewController:vc animated:NO];
        if ([GetFromUserDefaults(AUTOLOGIN) isEqualToString:@"true"]) {
            /*     自动登录      */
            [vc loginAction];
        }
    }else{//进入观看回放
        CCPalyBackLoginController *vc = [[CCPalyBackLoginController alloc] init];
        //两种跳转方式
        //        [self presentViewController:vc animated:YES completion:nil];
        [self.navigationController pushViewController:vc animated:NO];
        if ([GetFromUserDefaults(AUTOLOGIN) isEqualToString:@"true"]) {
            /*     自动登录      */
            [vc loginAction];
        }
    }
    
}
@end
