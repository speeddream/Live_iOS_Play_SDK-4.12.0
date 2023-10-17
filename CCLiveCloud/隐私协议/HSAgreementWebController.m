//
//  HSAgreementWebController.m
//  SaasAppIOS
//
//  Created by 刘强强 on 2020/10/24.
//  Copyright © 2020 刘强强. All rights reserved.
//

#import "HSAgreementWebController.h"
#import <WebKit/WKWebView.h>
#import <Masonry/Masonry.h>
#define isIphoneX_YML ({\
int tmp = 0;\
if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) { \
    tmp = 0; \
} \
CGSize size = [UIScreen mainScreen].bounds.size; \
NSInteger notchValue = size.width / size.height * 100; \
if (216 == notchValue || 46 == notchValue) { \
    tmp = 1; \
} else { \
    tmp =0; \
} \
tmp;\
})
#define kStatusBarHeight (isIphoneX_YML ? 44.0 : 20.0)
#define kNavigationHeight 44.0
#define kYOffset (isIphoneX_YML ? -44.0 : 0.0)
#define kNavigationAndStatusBarHeight    (kStatusBarHeight + kNavigationHeight)

@interface HSAgreementWebController ()<WKNavigationDelegate>

@property(nonatomic, strong)UIView *topView;
@property(nonatomic, strong)UIButton *backBtn;
@property(nonatomic, strong)UILabel *titleLb;

@property(nonatomic, strong)WKWebView *webview;

@end

@implementation HSAgreementWebController

- (void)viewDidLoad {
    [super viewDidLoad];
//    self.navigationController.navigationBarHidden = YES;
    [self.view addSubview:self.topView];
    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(self.view);
        make.height.mas_equalTo(kNavigationAndStatusBarHeight);
    }];
    
    [self.topView addSubview:self.backBtn];
    [self.backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.topView).offset(10);
        make.bottom.equalTo(self.topView).offset(-12);
        make.height.width.mas_equalTo(20);
    }];
    
    [self.topView addSubview:self.titleLb];
    [self.titleLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.topView);
        make.bottom.equalTo(self.topView).offset(-13);
    }];
    
    [self.view addSubview:self.webview];
    [self.webview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.topView.mas_bottom);
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
    
    if (self.url != nil) {
        @try {
            NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:self.url]];
            
            [self.webview loadRequest:request];
            
        } @catch (NSException *exception) {
            
        } @finally {
            
        }
    }
}

- (void)backBtnAction {
    [self dismissViewControllerAnimated:NO completion:nil];
//    [self.navigationController popViewControllerAnimated:YES];
    
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    NSString *headerStr = @"document.title";

    [webView evaluateJavaScript:headerStr completionHandler:^(id _Nullable title, NSError * _Nullable error) {
        
        self.titleLb.text = [NSString stringWithFormat:@"%@",title];
    }];
}

#pragma mark - 懒加载
- (UIView *)topView {
    if (!_topView) {
        _topView = [[UIView alloc] init];
        _topView.backgroundColor = [UIColor colorWithRed:251/255.0 green:251/255.0 blue:251/255.0 alpha:1];
    }
    return _topView;
}

- (UIButton *)backBtn {
    if (!_backBtn) {
        _backBtn = [[UIButton alloc] init];
        [_backBtn setImage:[UIImage imageNamed:@"返回黑"] forState:UIControlStateNormal];
        [_backBtn addTarget:self action:@selector(backBtnAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backBtn;
}

- (UILabel *)titleLb {
    if (!_titleLb) {
        _titleLb = [[UILabel alloc] init];
        _titleLb.font = [UIFont boldSystemFontOfSize:18];
        _titleLb.textAlignment = NSTextAlignmentCenter;
        _titleLb.textColor = [UIColor blackColor];
    }
    return _titleLb;
}

- (WKWebView *)webview {
    if (!_webview) {
        _webview = [[WKWebView alloc] init];
        _webview.navigationDelegate = self;
    }
    return _webview;
}

@end
