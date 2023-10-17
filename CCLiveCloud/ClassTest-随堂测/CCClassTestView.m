//
//  CCClassTestView.m
//  CCLiveCloud
//
//  Created by 何龙 on 2019/2/25.
//  Copyright © 2019 MacBook Pro. All rights reserved.
//

#import "CCClassTestView.h"
#import "TopView.h"
#import "CCProxy.h"
#import "NSString+Extension.h"
#import "UIButton+Extension.h"
#import "CCClassTestProgressView.h"
#import "InformationShowView.h"
#import "Reachability.h"
#import "UIColor+RCColor.h"
#import "CCcommonDefine.h"
#import "NSString+CCSwitchTime.h"
#import "UILabel+Extension.h"
#import "UIImage+Extension.h"
#import "UIView+Extension.h"
#import <Masonry/Masonry.h>

@interface CCClassTestView ()
@property (nonatomic, strong) NSDictionary              * testDic;//随堂测字典
@property (nonatomic, assign) BOOL                        isScreenLandScape;//是否是全屏
@property (nonatomic, copy) NSString                  * practiceId;//随堂测id
@property (nonatomic, assign) BOOL                      isSingle;//是否是单选
@property (nonatomic, assign) BOOL                      isJudge;//是否是判断
@property (nonatomic, assign) NSInteger                count;//选项总数
//@property (nonatomic, strong) UIButton                * closeBtn;//关闭按钮
@property (nonatomic, strong) UIButton                * cleanLandscape;//横屏最小化按钮

@property(nonatomic,strong)TopView                  *topView;//顶部视图
@property(nonatomic,strong)UILabel                  *titleLabel;//标题label
@property(nonatomic,strong)UIView                   *labelBgView;//label背景视图
@property(nonatomic,strong)UILabel                  *centerLabel;//中间的文本提示
@property(nonatomic,strong)UIButton                 *submitBtn;//发布按钮
@property(nonatomic,strong)UIButton                 *cleanBtn;//收起按钮
@property(nonatomic,strong)UIView                   *view;//背景视图

@property(nonatomic,strong)UIButton                 *aButton;//选项A按钮
@property(nonatomic,strong)UIButton                 *bButton;//选项B按钮
@property(nonatomic,strong)UIButton                 *cButton;//选项C按钮
@property(nonatomic,strong)UIButton                 *dButton;//选项D按钮
@property(nonatomic,strong)UIButton                 *eButton;//选项E按钮
@property(nonatomic,strong)UIButton                 *fButton;//选项F按钮
@property(nonatomic,assign)float                    buttonOffset;//btn偏移量
@property(nonatomic,strong)NSArray                  *optinsArr;//选项数组
@property(nonatomic,strong)NSMutableArray           *selectedArr;//选择后的数组
@property(nonatomic,strong)NSMutableArray           *norOptionsArr;//默认选项状态数组

@property(nonatomic,strong)UIImageView              *testImageView;//测试结果展示图片
@property(nonatomic,assign)BOOL                     isCorrect;//是否正确
@property(nonatomic,assign)BOOL                     result;//结果
#pragma mark - 答题计时器
@property(nonatomic,strong)NSTimer                  *timer;//答题timer
@property(nonatomic,strong)UIImageView              *clockImageView;//时钟
@property(nonatomic,strong)UILabel                  *clockLabel;//时间label
@property(nonatomic,strong)NSTimer                  *requestTimer;//请求结果timer
@property(nonatomic,assign)NSInteger                durtion;//答题时间
@property(nonatomic,assign)NSInteger                mistiming;//时间差
#pragma mark - 答题失败
@property(nonatomic,strong)UILabel                  *commitFailedLabel;//提交失败提示
@property(nonatomic,strong)InformationShowView      *informationView;//提示视图
#pragma mark - 答题结果
@property(nonatomic,strong)NSDictionary             *resultDic;//答题结果字典
@property(nonatomic,strong)UIImageView              *resultImageView;//答题结果视图
@property(nonatomic,strong)UILabel                  *resultLabel;//结果label

#pragma mark - 答题统计
@property(nonatomic,strong)UILabel                  *myAnswerLabel;//我的答案label
@property(nonatomic,strong)UILabel                  *correctAnswerLabel;//正确答案label
@property(nonatomic,assign)NSInteger                answerPersonNum;//回答人数
@property(nonatomic,copy)NSString                   *correctRate;//正确率
@property(nonatomic,strong)CCClassTestProgressView  *progressView;//进度条视图
#pragma mark - 答题结束
@property(nonatomic,assign)BOOL                     finish;//是否答题结束
@property(nonatomic,assign)BOOL                     shouldRmove;//是否需要移除

@property(nonatomic,assign)BOOL                     isSubmited;//是否已提交
@end

//#define BUTTON_SCALE ((SCREEN_WIDTH / 375) > 1 ? 1 : (SCREEN_WIDTH / 375))
#define BUTTON_SCALE 1
#define BUTTON_WIDTH(isScreenLandScape) (isScreenLandScape ? 41 :50)
#define BUTTON_IMGNAME(isScreenLandScape, Btn) [NSString stringWithFormat:@"%@_nor%@", Btn, isScreenLandScape?@"_landscape":@""]
#define BUTTON_SELIMGNAME(isScreenLandScape, Btn) [NSString stringWithFormat:@"%@_sel%@", Btn, isScreenLandScape?@"_landscape":@""]
#define RESULTTEXT(isCorrect) (isCorrect?@"恭喜，答对啦!":@"哎呀，答错了，下次继续努力!")
#define RESULTIMAGE(isCorrect) (isCorrect?@"class_right":@"class_false")
#define COMMITFAILED @"网络异常，请重试"
@implementation CCClassTestView

/**
 *    @brief    初始化方法
 *    @param testDic 随堂测答题选项字典 testDic[@"practice"][@"Type"] :0 判断，1 单选，2 多选
 *    @param isScreenLandScape 是否是全屏
 *    @return self;
 */
- (instancetype)initWithTestDic:(NSDictionary *)testDic isScreenLandScape:(BOOL)isScreenLandScape{
    self = [super init];
    if (self) {
        self.frame = [UIScreen mainScreen].bounds;
        self.backgroundColor = CCRGBAColor(0, 0, 0, 0.5);
        self.testDic = testDic;//
        self.practiceId = testDic[@"practice"][@"id"];//随堂测id
        self.optinsArr = testDic[@"practice"][@"options"];
        self.isSingle = [testDic[@"practice"][@"type"]intValue] == 1? YES:NO;
        // 新增判断题处理
        self.isJudge = [testDic[@"practice"][@"type"]intValue] == 0? YES:NO;
        
        self.count = self.optinsArr.count;
        self.finish = NO;
//        NSLog(@"%ld个选项", self.count);
        self.isScreenLandScape = isScreenLandScape;
        [self setUpUI];
        // 1.获取时间差
        [self getMistiming];
        self.shouldRmove = NO;
        self.result = NO;
    }
    return self;
}
-(void)dealloc{
//    NSLog(@"移除随堂测视图");
}
#pragma mark - 设置UI
/**
 *    @brief    设置UI
 */
-(void)setUpUI{
    self.buttonOffset = _isScreenLandScape?9.f:4.f;
    _view = [[UIView alloc]init];
    _view.backgroundColor = [UIColor whiteColor];
    _view.layer.cornerRadius = 5;
    [self addSubview:_view];
    // NSString *text = type == 1?@"单选题":@"多选题";
    // 随堂测类型 0 判断 1 单选 2 多选
    // 新增判断题处理
    NSInteger type = [self.testDic[@"practice"][@"type"] integerValue];
    NSString *text = @"单选题";
    if (type == 0) {
        text = @"判断题";
    }else if (type == 2) {
        text = @"多选题";
    }
    
    if (!_isScreenLandScape) {//竖屏
        [_view mas_makeConstraints:^(MASConstraintMaker *make) {
//            if (SCREEN_WIDTH < 375) { //屏幕尺寸小于375
//                make.left.mas_equalTo(self).offset(10);
//                make.right.mas_equalTo(self).offset(-10);
//                make.bottom.mas_equalTo(self).offset (-46);
//                make.height.mas_equalTo(338);
//            }else {
                make.centerX.mas_equalTo(self);
                make.centerY.mas_equalTo(self).offset(90);
                make.size.mas_equalTo(CGSizeMake(355, 338));
//            }
        }];
        [self layoutIfNeeded];
        
        WS(weakSelf)
        _topView = [[TopView alloc] initWithFrame:CGRectMake(0, 0, _view.frame.size.width, 40) Title:@"随堂测" titleStyle:TopViewTitleLabelStyleCenter closeBlock:^{
            [weakSelf closeBtnClicked];
        }];
        _topView.closeBtn.hidden = YES;
        [self.view addSubview:_topView];
        //答题卡提示
        _titleLabel = [UILabel labelWithText:text fontSize:[UIFont systemFontOfSize:18] textColor:CCRGBAColor(30, 31, 33, 1.0) textAlignment:NSTextAlignmentCenter];
        [self.view addSubview:_titleLabel];
        [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.view);
            make.top.mas_equalTo(_topView.mas_bottom).offset(20);
//            make.size.mas_equalTo(CGSizeMake(100, 18));
        }];
        
        //题干提示背景视图
        [self.view addSubview:self.labelBgView];
        [_labelBgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.view);
            make.top.mas_equalTo(_titleLabel.mas_bottom).offset(16);
            make.size.mas_equalTo(CGSizeMake(195, 20));
        }];
        //题干部分提示文字
        _centerLabel = [UILabel labelWithText:ALERT_VOTE fontSize:[UIFont systemFontOfSize:FontSize_24] textColor:CCRGBAColor(102, 102, 102, 1) textAlignment:NSTextAlignmentCenter];
        [_labelBgView addSubview:_centerLabel];
        [_centerLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self.labelBgView);
        }];
        //收起按钮
        [self.view addSubview:self.cleanBtn];
        [_cleanBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.view);
            make.bottom.mas_equalTo(self.view).offset(-10);
            make.size.mas_equalTo(CGSizeMake(180, 45));
        }];
        //提交按钮
        [self.view addSubview:self.submitBtn];
        [_submitBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.view);
            make.bottom.mas_equalTo(self.cleanBtn.mas_top).offset(-10);
            make.size.mas_equalTo(CGSizeMake(180, 45));
        }];
        [self.submitBtn setEnabled:NO];
        self.submitBtn.layer.cornerRadius = 22.5;
        self.submitBtn.layer.masksToBounds = YES;
        NSString *imageName = _isScreenLandScape?@"default_btn_landScape":@"default_btn";
        [_submitBtn setBackgroundImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
        
        //时钟图片
        _clockImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon-time"]];
        [self.view addSubview:_clockImageView];
        [_clockImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.titleLabel);
            make.right.mas_equalTo(self.view).offset(-52);
            make.size.mas_equalTo(CGSizeMake(12, 12));
        }];
        
        _clockLabel = [UILabel labelWithText:@"00:00" fontSize:[UIFont systemFontOfSize:12] textColor:CCRGBColor(255, 102, 51) textAlignment:NSTextAlignmentLeft];
        [self.view addSubview:_clockLabel];
        [_clockLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.titleLabel);
            make.left.mas_equalTo(self.clockImageView.mas_right).offset(5);
        }];

//        [self showAnimation];
    }else{//横屏
        [_view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self);
            make.left.mas_equalTo(self);
            make.right.mas_equalTo(self);
            make.height.mas_equalTo(60);
        }];
        [self layoutIfNeeded];
        //添加closeBtn
//        _closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//        _closeBtn.backgroundColor = CCClearColor;
//        _closeBtn.contentMode = UIViewContentModeScaleAspectFit;
//        [_closeBtn addTarget:self action:@selector(closeBtnClicked) forControlEvents:UIControlEventTouchUpInside];
//        [_closeBtn setBackgroundImage:[UIImage imageNamed:@"popup_close"] forState:UIControlStateNormal];
//        [self addSubview:_closeBtn];
//        [_closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.right.mas_equalTo(self.view).offset(-5);
//            make.top.mas_equalTo(self.view).offset(5);
//            make.size.mas_equalTo(CGSizeMake(28, 28));
//        }];
        //添加缩放Btn
        [self addSubview:self.cleanLandscape];
        [_cleanLandscape mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.right.mas_equalTo(_closeBtn.mas_left).offset(-5);
            make.right.mas_equalTo(self.view).offset(-5);
            make.top.mas_equalTo(self.view).offset(5);
            make.size.mas_equalTo(CGSizeMake(28, 28));
        }];
        //添加随堂测图片
        _testImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_classTest"]];
        [self.view addSubview:_testImageView];
        [_testImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.view).offset(15);
            make.centerY.mas_equalTo(self.view);
            make.size.mas_equalTo(CGSizeMake(58, 20));
        }];
        
        //答题卡提示
        _titleLabel = [UILabel labelWithText:text fontSize:[UIFont systemFontOfSize:15] textColor:CCRGBAColor(121, 128, 139, 1.0) textAlignment:NSTextAlignmentCenter];
        [self.view addSubview:_titleLabel];
        [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.view);
            make.left.mas_equalTo(self.view).offset(93);
//            make.size.mas_equalTo(CGSizeMake(50, 15));
        }];
        
        //提交按钮
        [self.view addSubview:self.submitBtn];
        [_submitBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.view);
            make.right.mas_equalTo(_cleanLandscape.mas_left).offset(-10);
            make.size.mas_equalTo(CGSizeMake(75, 30));
        }];
        [self.submitBtn setEnabled:NO];
        self.submitBtn.layer.cornerRadius = 3;
        self.submitBtn.layer.masksToBounds = YES;
        NSString *imageName = _isScreenLandScape?@"default_btn_landScape":@"default_btn";
        [_submitBtn setBackgroundImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
        
        //时钟图片
        _clockImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon-time"]];
        [self.view addSubview:_clockImageView];
        [_clockImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.view).offset(23);
            make.right.mas_equalTo(self.submitBtn.mas_left).offset(-51);
            make.size.mas_equalTo(CGSizeMake(15, 15));
        }];
        
        _clockLabel = [UILabel labelWithText:@"00:00" fontSize:[UIFont systemFontOfSize:15] textColor:CCRGBColor(255, 102, 51) textAlignment:NSTextAlignmentLeft];
        [self.view addSubview:_clockLabel];
        [_clockLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.view);
            make.left.mas_equalTo(self.clockImageView.mas_right).offset(6);
            make.size.mas_equalTo(CGSizeMake(45, 15));
        }];
    }
//    [self layoutIfNeeded];
    [self setAnswerUI];
    [self showAnimation];
//    [self setupSelectedAnswer];
    //设置选择btn
    [self startTimer];
}

/**
 *    @brief    更新UI视图
 */
- (void)updateUI
{
    NSInteger type = [self.testDic[@"practice"][@"type"] integerValue];
    NSString *text = @"单选题";
    if (type == 0) {
    text = @"判断题";
    }else if (type == 2) {
    text = @"多选题";
    }
    WS(weakSelf)
    if (!_isScreenLandScape) {//竖屏
        // 1.重置随堂测自身的frame
        [self mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.left.bottom.right.mas_equalTo(0);
        }];
        // 2.重置背景view的frame
        [_view mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(weakSelf);
            make.centerY.mas_equalTo(weakSelf).mas_offset(90);
            make.size.mas_equalTo(CGSizeMake(355, 338));
        }];
        [_view layoutIfNeeded];
        // 3.顶部View
        if (!_topView) {
            _topView = [[TopView alloc]initWithFrame:CGRectMake(0, 0, _view.width, 40) Title:@"随堂测" titleStyle:TopViewTitleLabelStyleCenter closeBlock:^{
                [weakSelf closeBtnClicked];
            }];
            [self.view addSubview:_topView];
            [_topView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.left.right.mas_equalTo(weakSelf.view);
                make.height.mas_equalTo(40);
            }];
            [_topView layoutIfNeeded];
            _topView.closeBtn.hidden = YES;
        }else {
            _topView.hidden = NO;
            _topView.frame = CGRectMake(0, 0, _view.width, 40);
            [_topView layoutIfNeeded];
        }
        // 4.答题卡提示
        if (!_titleLabel) {
            _titleLabel = [UILabel labelWithText:text fontSize:[UIFont systemFontOfSize:18] textColor:CCRGBAColor(30, 31, 33, 1.0) textAlignment:NSTextAlignmentCenter];
            [self.view addSubview:_titleLabel];
            [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.mas_equalTo(weakSelf.view);
                make.top.mas_equalTo(_topView.mas_bottom).offset(20);
//                make.size.mas_equalTo(CGSizeMake(100, 18));
            }];
        }else {
            _titleLabel.font = [UIFont systemFontOfSize:18];
            _titleLabel.textColor = CCRGBAColor(30, 31, 33, 1.0);
            [_titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.centerX.mas_equalTo(weakSelf.view);
                make.top.mas_equalTo(weakSelf.topView.mas_bottom).offset(20);
//                make.size.mas_equalTo(CGSizeMake(100, 18));
            }];
        }
        // 5.题干提示背景视图
        if (!_labelBgView) {
            [self.view addSubview:self.labelBgView];
            [_labelBgView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(weakSelf.titleLabel.mas_bottom).offset(16);
                make.centerX.mas_equalTo(weakSelf.view);
                make.size.mas_equalTo(CGSizeMake(195, 20));
            }];
        }else {
            _labelBgView.hidden = NO;
            [_labelBgView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(weakSelf.titleLabel.mas_bottom).offset(16);
                make.centerX.mas_equalTo(weakSelf.view);
                make.size.mas_equalTo(CGSizeMake(195, 20));
//                make.size.mas_equalTo(CGSizeMake(100, 18));
            }];
        }
        
        // 6.题干部分提示文字
        if (!_centerLabel) {
            _centerLabel = [UILabel labelWithText:ALERT_VOTE fontSize:[UIFont systemFontOfSize:FontSize_24] textColor:CCRGBAColor(102, 102, 102, 1) textAlignment:NSTextAlignmentCenter];
            [_labelBgView addSubview:_centerLabel];
            [_centerLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.mas_equalTo(weakSelf.labelBgView);
            }];
        }else {
            _centerLabel.hidden = NO;
            [_centerLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.edges.mas_equalTo(weakSelf.labelBgView);
            }];
        }
        // 7.竖屏收起按钮
        if (!_cleanBtn) {
            [self.view addSubview:self.cleanBtn];
            [_cleanBtn mas_makeConstraints:^(MASConstraintMaker *make) {
              make.centerX.mas_equalTo(weakSelf.view);
              make.bottom.mas_equalTo(weakSelf.view).offset(-10);
              make.size.mas_equalTo(CGSizeMake(180, 45));
            }];
        }else {
            self.cleanBtn.hidden = NO;
            [_cleanBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
              make.centerX.mas_equalTo(weakSelf.view);
              make.bottom.mas_equalTo(weakSelf.view).offset(-10);
              make.size.mas_equalTo(CGSizeMake(180, 45));
            }];
        }
        // 8.竖屏提交按钮
        if (!_submitBtn) {
            [self addSubview:self.submitBtn];
            [_submitBtn mas_makeConstraints:^(MASConstraintMaker *make) {
              make.centerX.mas_equalTo(weakSelf.view);
              make.bottom.mas_equalTo(weakSelf.cleanBtn.mas_top).offset(-10);
              make.size.mas_equalTo(CGSizeMake(180, 45));
            }];
            [self.submitBtn setEnabled:NO];
        }else {
            [_submitBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
              make.centerX.mas_equalTo(weakSelf.view);
              make.bottom.mas_equalTo(weakSelf.cleanBtn.mas_top).offset(-10);
              make.size.mas_equalTo(CGSizeMake(180, 45));
            }];
        }
        self.submitBtn.layer.cornerRadius = 22.5;
        self.submitBtn.layer.masksToBounds = YES;
        NSString *imageName = _isScreenLandScape?@"default_btn_landScape":@"default_btn";
        [_submitBtn setBackgroundImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
        
        // 9.时钟图片
        if (!_clockImageView) {
            _clockImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon-time"]];
            [self.view addSubview:_clockImageView];
            [_clockImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.mas_equalTo(weakSelf.titleLabel);
                make.right.mas_equalTo(weakSelf.view).offset(-52);
                make.size.mas_equalTo(CGSizeMake(12, 12));
            }];
        }else {
            [_clockImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.centerY.mas_equalTo(weakSelf.titleLabel);
                make.right.mas_equalTo(weakSelf.view).offset(-52);
                make.size.mas_equalTo(CGSizeMake(12, 12));
            }];
        }
        // 10.时间显示
        if (!_clockLabel) {
            _clockLabel = [UILabel labelWithText:@"00:00" fontSize:[UIFont systemFontOfSize:12] textColor:CCRGBColor(255, 102, 51) textAlignment:NSTextAlignmentLeft];
            [self addSubview:self.clockLabel];
            [_clockLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.mas_equalTo(weakSelf.titleLabel);
                make.left.mas_equalTo(weakSelf.clockImageView.mas_right).offset(5);
            }];
        }else {
            _clockLabel.font = [UIFont systemFontOfSize:12];
            _clockLabel.textColor = CCRGBColor(255, 102, 51);
            [_clockLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.centerY.mas_equalTo(weakSelf.titleLabel);
                make.left.mas_equalTo(weakSelf.clockImageView.mas_right).offset(5);
            }];
        }
        // 11.处理横屏多余按钮
        if (_cleanLandscape) {
            _cleanLandscape.hidden = YES;
        }
        if (_testImageView) {
            _testImageView.hidden = YES;
        }
        if (_commitFailedLabel) {
            _commitFailedLabel.hidden = NO;
        }
        
    }else{//横屏
        
        // 1.重置随堂测自身的frame
        [self mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.left.bottom.right.mas_offset(0);
        }];
        // 2.重置背景view的frame
        [_view mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(weakSelf);
            make.left.mas_equalTo(weakSelf);
            make.right.mas_equalTo(weakSelf);
            make.height.mas_equalTo(60);
        }];
        // 3.缩放Btn
        if (_cleanLandscape) {
            _cleanLandscape.hidden = NO;
        }else {
            [self addSubview:self.cleanLandscape];
            [_cleanLandscape mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.mas_equalTo(weakSelf.view).offset(-5);
                make.top.mas_equalTo(weakSelf.view).offset(5);
                make.size.mas_equalTo(CGSizeMake(28, 28));
            }];
        }
        // 4.添加随堂测图片
        if (!_testImageView) {
            _testImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_classTest"]];
            [self.view addSubview:_testImageView];
            [_testImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(weakSelf.view).offset(15);
                make.centerY.mas_equalTo(weakSelf.view);
                make.size.mas_equalTo(CGSizeMake(58, 20));
            }];
        }else {
            _testImageView.hidden = NO;
        }
        // 5.答题卡提示
        if (!_titleLabel) {
            _titleLabel = [UILabel labelWithText:text fontSize:[UIFont systemFontOfSize:15] textColor:CCRGBAColor(121, 128, 139, 1.0) textAlignment:NSTextAlignmentCenter];
            [self.view addSubview:self.titleLabel];
            [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.mas_equalTo(weakSelf.view);
                make.left.mas_equalTo(weakSelf.view).offset(93);
//                make.size.mas_equalTo(CGSizeMake(50, 15));
            }];
        }else {
            _titleLabel.font = [UIFont systemFontOfSize:15];
            _titleLabel.textColor = CCRGBAColor(121, 128, 139, 1.0);
            [_titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.centerY.mas_equalTo(weakSelf.view);
                make.left.mas_equalTo(weakSelf.view).offset(93);
//                make.size.mas_equalTo(CGSizeMake(50, 15));
            }];
        }
        // 6.提交按钮
        if (!_submitBtn) {
           [self.view addSubview:self.submitBtn];
           [_submitBtn mas_makeConstraints:^(MASConstraintMaker *make) {
               make.centerY.mas_equalTo(weakSelf.view);
               make.right.mas_equalTo(weakSelf.cleanLandscape.mas_left).offset(-10);
               make.size.mas_equalTo(CGSizeMake(75, 30));
           }];
            [self.submitBtn setEnabled:NO];
        }else {
            [_submitBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.centerY.mas_equalTo(weakSelf.view);
                make.right.mas_equalTo(_cleanLandscape.mas_left).offset(-10);
                make.size.mas_equalTo(CGSizeMake(75, 30));
            }];
        }
        self.submitBtn.layer.cornerRadius = 3;
        self.submitBtn.layer.masksToBounds = YES;
        NSString *imageName = _isScreenLandScape?@"default_btn_landScape":@"default_btn";
        [_submitBtn setBackgroundImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
        // 7.时钟图片
        if (!_clockLabel) {
            _clockImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon-time"]];
            [self.view addSubview:self.clockImageView];
            [_clockImageView mas_makeConstraints:^(MASConstraintMaker *make) {
               make.top.mas_equalTo(weakSelf.view).offset(23);
               make.right.mas_equalTo(weakSelf.submitBtn.mas_left).offset(-51);
               make.size.mas_equalTo(CGSizeMake(15, 15));
            }];
        }else {
            [_clockImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
               make.top.mas_equalTo(weakSelf.view).offset(23);
               make.right.mas_equalTo(weakSelf.submitBtn.mas_left).offset(-51);
               make.size.mas_equalTo(CGSizeMake(15, 15));
            }];
        }
        // 8.定时器时间
        if (!_clockLabel) {
            _clockLabel = [UILabel labelWithText:@"00:00" fontSize:[UIFont systemFontOfSize:15] textColor:CCRGBColor(255, 102, 51) textAlignment:NSTextAlignmentLeft];
            [self.view addSubview:self.clockLabel];
            [_clockLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.mas_equalTo(weakSelf.view);
                make.left.mas_equalTo(weakSelf.clockImageView.mas_right).offset(6);
                make.size.mas_equalTo(CGSizeMake(45, 15));
            }];
        }else {
            _clockLabel.font = [UIFont systemFontOfSize:15];
            _clockLabel.textColor = CCRGBColor(255, 102, 51);
            [_clockLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.centerY.mas_equalTo(weakSelf.view);
                make.left.mas_equalTo(weakSelf.clockImageView.mas_right).offset(6);
                make.size.mas_equalTo(CGSizeMake(45, 15));
            }];
        }
        // 9.处理竖屏多余按钮
        if (_topView) {
            _topView.hidden = YES;
        }
        if (_labelBgView) {
            _labelBgView.hidden = YES;
        }
        if (_centerLabel) {
            _centerLabel.hidden = YES;
        }
        if (_cleanBtn) {
            _cleanBtn.hidden = YES;
        }
        if (_commitFailedLabel) {
            _commitFailedLabel.hidden = YES;
        }
    }
    //    [self layoutIfNeeded];
    [self setAnswerUI];
    [self showAnimation];
    if (self.selectedArr.count > 0) {
        _submitBtn.enabled = YES;
    }else{
        _submitBtn.enabled = NO;
    }
    _submitBtn.userInteractionEnabled = YES;
}
//竖屏约束
//横屏约束
#pragma mark - 设置答题选项
/**
 *    @brief    设置答案视图
 */
-(void)setAnswerUI{
    [self initWithABtnAndBtn];
    if (self.count >= 3){
        [self initWithCButton];
        if (self.count >= 4){
            [self initWithDButton];
        }
        if (self.count >= 5){
            [self initWithEButton];
        }
        if (self.count == 6){
            [self initWithFButton];
        }
    }
}

/**
 *    @brief    设置A选项和B选项
 */
-(void)initWithABtnAndBtn{
//    CGFloat view_WIDTH = SCREEN_WIDTH < 375 ? (SCREEN_WIDTH - 10) : 355;
    CGFloat view_WIDTH = 355;
    CGFloat leftOffset = (view_WIDTH - self.count * BUTTON_WIDTH(_isScreenLandScape) * BUTTON_SCALE - (self.buttonOffset * (self.count - 1)))/2;
    if (self.isScreenLandScape) {
        leftOffset = 153;
    }
    if (!_aButton) {
        //设置rightButton的样式和约束
        [self.view addSubview:self.aButton];
        [_aButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.view).offset(self.isScreenLandScape?7:143);
            make.left.mas_equalTo(self.view).offset(leftOffset);
            make.size.mas_equalTo(CGSizeMake(BUTTON_WIDTH(_isScreenLandScape)*BUTTON_SCALE, BUTTON_WIDTH(_isScreenLandScape)*BUTTON_SCALE));
        }];
    }else {
        [_aButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.view).offset(self.isScreenLandScape?7:143);
            make.left.mas_equalTo(self.view).offset(leftOffset);
            make.size.mas_equalTo(CGSizeMake(BUTTON_WIDTH(_isScreenLandScape)*BUTTON_SCALE, BUTTON_WIDTH(_isScreenLandScape)*BUTTON_SCALE));
        }];
    }
    
    if (!_bButton) {
        //设置wrongButton的样式和约束
        [self.view addSubview:self.bButton];
        [_bButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.aButton);
            make.left.mas_equalTo(self.aButton.mas_right).offset(self.buttonOffset);
            make.size.mas_equalTo(CGSizeMake(BUTTON_WIDTH(_isScreenLandScape)*BUTTON_SCALE, BUTTON_WIDTH(_isScreenLandScape)*BUTTON_SCALE));
        }];
    }else {
        [_bButton mas_remakeConstraints:^(MASConstraintMaker *make) {
           make.centerY.mas_equalTo(self.aButton);
           make.left.mas_equalTo(self.aButton.mas_right).offset(self.buttonOffset);
           make.size.mas_equalTo(CGSizeMake(BUTTON_WIDTH(_isScreenLandScape)*BUTTON_SCALE, BUTTON_WIDTH(_isScreenLandScape)*BUTTON_SCALE));
        }];
    }
}

/**
 *    @brief    设置C选项
 */
-(void)initWithCButton{
    //设置cButton的样式和约束
    if (!_cButton) {
        [self.view addSubview:self.cButton];
        [_cButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.bButton);
            make.left.mas_equalTo(self.bButton.mas_right).offset(self.buttonOffset);
            make.size.mas_equalTo(CGSizeMake(BUTTON_WIDTH(_isScreenLandScape)*BUTTON_SCALE, BUTTON_WIDTH(_isScreenLandScape)*BUTTON_SCALE));
        }];
    }else {
        [_cButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.bButton);
            make.left.mas_equalTo(self.bButton.mas_right).offset(self.buttonOffset);
            make.size.mas_equalTo(CGSizeMake(BUTTON_WIDTH(_isScreenLandScape)*BUTTON_SCALE, BUTTON_WIDTH(_isScreenLandScape)*BUTTON_SCALE));
        }];
    }
}

/**
 *    @brief    设置D选项
 */
-(void)initWithDButton{
    //设置dButton的样式和约束
    if (!_dButton) {
        [self.view addSubview:self.dButton];
        [_dButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.cButton);
            make.left.mas_equalTo(self.cButton.mas_right).offset(self.buttonOffset);
            make.size.mas_equalTo(CGSizeMake(BUTTON_WIDTH(_isScreenLandScape)*BUTTON_SCALE, BUTTON_WIDTH(_isScreenLandScape)*BUTTON_SCALE));
        }];
    }else {
        [_dButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.cButton);
            make.left.mas_equalTo(self.cButton.mas_right).offset(self.buttonOffset);
            make.size.mas_equalTo(CGSizeMake(BUTTON_WIDTH(_isScreenLandScape)*BUTTON_SCALE, BUTTON_WIDTH(_isScreenLandScape)*BUTTON_SCALE));
        }];
    }
}

/**
 *    @brief    设置E选项
 */
-(void)initWithEButton{
    //设置eButton的样式和约束
    if (!_eButton) {
        [self.view addSubview:self.eButton];
        [_eButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.dButton);
            make.left.mas_equalTo(self.dButton.mas_right).offset(self.buttonOffset);
            make.size.mas_equalTo(CGSizeMake(BUTTON_WIDTH(_isScreenLandScape)*BUTTON_SCALE, BUTTON_WIDTH(_isScreenLandScape)*BUTTON_SCALE));
        }];
    }else {
        [_eButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.dButton);
            make.left.mas_equalTo(self.dButton.mas_right).offset(self.buttonOffset);
            make.size.mas_equalTo(CGSizeMake(BUTTON_WIDTH(_isScreenLandScape)*BUTTON_SCALE, BUTTON_WIDTH(_isScreenLandScape)*BUTTON_SCALE));
        }];
    }
}

/**
 *    @brief    设置F选项
 */
-(void)initWithFButton{
    if (!_fButton) {
        //设置eButton的样式和约束
        [self.view addSubview:self.fButton];
        [_fButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.eButton);
            make.left.mas_equalTo(self.eButton.mas_right).offset(self.buttonOffset);
            make.size.mas_equalTo(CGSizeMake(BUTTON_WIDTH(_isScreenLandScape)*BUTTON_SCALE, BUTTON_WIDTH(_isScreenLandScape)*BUTTON_SCALE));
        }];
    }else {
        [_fButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.eButton);
            make.left.mas_equalTo(self.eButton.mas_right).offset(self.buttonOffset);
            make.size.mas_equalTo(CGSizeMake(BUTTON_WIDTH(_isScreenLandScape)*BUTTON_SCALE, BUTTON_WIDTH(_isScreenLandScape)*BUTTON_SCALE));
        }];
    }
}
#pragma mark - btn点击事件
/**
 *    @brief    避免选择答案的时候点击提交按钮，误触
 */
-(void)optionsBtnTouched{
//    NSLog(@"点击了a按钮");
    _submitBtn.userInteractionEnabled = NO;
}

/**
 *    @brief    点击选项后调用
 */
-(void)optionsBtnCanceled{
//    NSLog(@"可以点击发布按钮");
    _submitBtn.userInteractionEnabled = YES;
}
/**
 *    @brief    点击选项按钮
 *    @param    button 选项按钮
 */
-(void)optionsBtnClicked:(UIButton *)button{
    if (_isSingle || _isJudge) {
        [self.selectedArr removeAllObjects];
        //取消所有btn的选择
        [self cancelAllBtnsSelected];
        button.selected = YES;
        [self.selectedArr addObject:[NSString stringWithFormat:@"%@", self.optinsArr[button.tag][@"id"]]];
    }else{
        button.selected = !button.selected;
        if ([self.selectedArr containsObject:[NSString stringWithFormat:@"%@", self.optinsArr[button.tag][@"id"]]]) {
            [self.selectedArr removeObject:[NSString stringWithFormat:@"%@", self.optinsArr[button.tag][@"id"]]];
        }else{
            [self.selectedArr addObject:[NSString stringWithFormat:@"%@", self.optinsArr[button.tag][@"id"]]];
        }
    }
    if (self.selectedArr.count > 0) {
        _submitBtn.enabled = YES;
    }else{
        _submitBtn.enabled = NO;
    }
//    NSLog(@"可以点击发布按钮");
    _submitBtn.userInteractionEnabled = YES;
}

/**
 *    @brief    取消所有btn的selected属性
 */
-(void)cancelAllBtnsSelected{
    _aButton.selected = NO;
    _bButton.selected = NO;
    if (_cButton) {
        _cButton.selected = NO;
    }
    if (_dButton) {
        _dButton.selected = NO;
    }
    if (_eButton) {
        _eButton.selected = NO;
    }
    if (_fButton) {
        _fButton.selected = NO;
    }
}
/**
 *    @brief    点击发布按钮
 */
-(void)submitBtnClicked{
    if (self.result == YES) {
        return;
    }
    //判断是否有网络
    if (![self isExistenceNetwork]) {
        _commitFailedLabel.text = COMMITFAILED;
        [self commitResult:NO];
        return;
    }
    _commitFailedLabel.text = @"";
    if (self.isSubmited == YES) {
        NSLog(@"isSubmited");
        return;
    }
    
    self.isSubmited = YES;
    self.submitBtn.enabled = NO;
    [self.submitBtn setTitleColor:CCRGBAColor(255, 255, 255, 0.4) forState:UIControlStateDisabled];
    [self.submitBtn setBackgroundImage:[UIImage imageWithColor:CCRGBAColor(197, 197, 197, 1.0)] forState:UIControlStateDisabled];
    
    NSArray *arr = [NSArray arrayWithObject:self.selectedArr];
    //处理selectedArr,返回选项id
    self.CommitBlock(arr[0]);
    WS(ws)
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        ws.isSubmited = NO;
        ws.submitBtn.enabled = NO;
        [ws.submitBtn setTitleColor:CCRGBAColor(255, 255, 255, 1) forState:UIControlStateNormal];
        NSString *imageName = ws.isScreenLandScape ? @"default_btn_landScape" : @"default_btn";
        [ws.submitBtn setBackgroundImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    });
}

/**
 *    @brief    是否提交成功
 *    @param    success 是否提交成功
 */
-(void)commitResult:(BOOL)success{
    if (success == NO) {
        if (!_isScreenLandScape) {//竖屏模式下提示信息
            if (!_commitFailedLabel) {
                _commitFailedLabel = [UILabel labelWithText:COMMITFAILED fontSize:[UIFont systemFontOfSize:15] textColor:CCRGBColor(243, 75, 95) textAlignment:NSTextAlignmentCenter];
                [self.view addSubview:_commitFailedLabel];
            }
            [_commitFailedLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.bottom.mas_equalTo(self.submitBtn.mas_top).offset(-10);
                make.centerX.mas_equalTo(self.view);
                make.size.mas_equalTo(CGSizeMake(130, 15));
            }];
        }else{//横屏模式下提示信息
            [self removeInformationView];
            [self layoutIfNeeded];
            _informationView = [[InformationShowView alloc] initWithFrame:CGRectMake((self.frame.size.width - 180) / 2, (self.frame.size.height - 55) / 2, 180, 55) WithLabel:COMMITFAILED];
            [APPDelegate.window addSubview:_informationView];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self removeInformationView];
            });
        }
    }else{//成功的话加载提交结果样式
        if (_commitFailedLabel) {
            [_commitFailedLabel removeFromSuperview];
        }
        _isCorrect = [_resultDic[@"datas"][@"practice"][@"answerResult"] intValue] == 0?NO:YES;
//        NSLog(@"回答%@", _isCorrect?@"正确":@"错误");
        self.result = YES;
        _resultDic = _resultDic[@"datas"];
        [self showAnswerView];
        //设置回答结果样式
        [self showResultView];
        //两秒后请求答题统计,block
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self stopResultView];
        });
    }
}

/**
 *    @brief    移除提示视图
 */
-(void)removeInformationView{
    if (_informationView) {
        [_informationView removeFromSuperview];
    }
}
#pragma mark - 获取时间差
/**
 *    @brief    获取时间差 (获取一次随堂测更新一次)
 */
- (void)getMistiming
{
    NSInteger nowTime =  [[self getNowTimeTimestamp] integerValue];
    NSInteger serverTime = [NSString timeSwitchTimestamp:_testDic[@"serverTime"] andFormatter:@"yyyy-MM-dd HH:mm:ss"];
    _mistiming = nowTime - serverTime;
}

- (NSString *)getNowTimeTimestamp
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"]; // ----------设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制
    //设置时区,这个对于时间的处理有时很重要
    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];
    [formatter setTimeZone:timeZone];
    NSDate *datenow = [NSDate date];//现在时间,你可以输出来看下是什么格式
    NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)[datenow timeIntervalSince1970]];
    return timeSp;
}
#pragma mark - 开启计时器
/**
 *    @brief    开启定时器
 */
- (void)startTimer
{
    if (_timer) {
        [_timer invalidate];
    }
    // 2.初始化定时器
    CCProxy *weakObject = [CCProxy proxyWithWeakObject:self];
    _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:weakObject selector:@selector(updateTime) userInfo:nil repeats:YES];
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    [runLoop addTimer:_timer forMode:NSDefaultRunLoopMode];
}

#pragma mark - 更新时间
/**
 *    @brief    更新时间
 */
- (void)updateTime
{
    //获取初始化秒数
    NSInteger nowTime = [[NSString getNowTimeTimestamp] integerValue];
    NSInteger publishTime = [NSString timeSwitchTimestamp:_testDic[@"practice"][@"publishTime"] andFormatter:@"yyyy-MM-dd HH:mm:ss"];
    _durtion = nowTime - _mistiming - publishTime;
    self.clockLabel.text = [NSString stringWithFormat:@"%@", [NSString timeFormat:_durtion]];
}
#pragma mark - 停止计时器
/**
 *    @brief    停止计时器
 */
-(void)stopTimer
{
    [_timer invalidate];
    [_requestTimer invalidate];
}

/**
 *    @brief    是否隐藏（当视图隐藏的时候关闭timer)
 *    @param hidden hidden
 */
-(void)setHidden:(BOOL)hidden{
    [super setHidden:hidden];
    if (hidden) {
        [_timer invalidate];
        [_requestTimer invalidate];
    }
}
#pragma mark - 答题结果
/**
 *    @brief    随堂测提交结果(The new method)
 *    rseultDic    提交结果,调用commitPracticeWithPracticeId:(NSString *)practiceId options:(NSArray *)options后执行
 */
- (void)practiceSubmitResultsWithDic:(NSDictionary *) resultDic
{
    _resultDic = resultDic;
    BOOL success = [_resultDic[@"success"] intValue] == 1?YES:NO;
    //解析答题结果字典，判断是否正确
    [self commitResult:success];
}
#pragma mark - 结束答题结果显示

/**
 *    @brief    移除提交结果
 */
-(void)stopResultView
{
    [self requestStatis];
    if (_requestTimer) {
        [_requestTimer invalidate];
    }
    CCProxy *weakObject = [CCProxy proxyWithWeakObject:self];
    _requestTimer = [NSTimer scheduledTimerWithTimeInterval:3 target:weakObject selector:@selector(requestStatis) userInfo:nil repeats:YES];
}

/**
 *    @brief    移除结果提示视图
 */
- (void)removeResultView
{
    if (_resultImageView) {
        [_resultImageView removeFromSuperview];
    }
    if (_resultLabel) {
        [_resultLabel removeFromSuperview];
    }
}
/**
 *    @brief    显示提交结果样式
 */
- (void)showResultView
{
    [self removeResultView];
    //添加结果提示
    _resultImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:RESULTIMAGE(_isCorrect)]];
    [self.view addSubview:_resultImageView];
    //添加文字提示
    _resultLabel = [UILabel labelWithText:RESULTTEXT(_isCorrect) fontSize:[UIFont systemFontOfSize:15] textColor:CCRGBAColor(255, 100, 61, 1.f) textAlignment:NSTextAlignmentCenter];
    [self.view addSubview:_resultLabel];
    if (_isScreenLandScape) {
        [self layoutIfNeeded];
        [_view mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.center.mas_equalTo(self);
            make.size.mas_equalTo(CGSizeMake(230, 140));
        }];
        [self otherViewsHidden:YES];
        [_resultImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.view);
            make.top.mas_equalTo(self.view).offset(30);
            make.size.mas_equalTo(CGSizeMake(45, 45));
        }];
        [_resultLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.view);
            make.top.mas_equalTo(self.view).offset(95);
            make.height.mas_equalTo(16);
        }];
        [self showAnimation];//加载动画
    }else{
        
        [self otherViewsHidden:YES];
        [_resultImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.mas_equalTo(self.view);
            make.size.mas_equalTo(CGSizeMake(45, 45));
        }];
        [_resultLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.view);
            make.top.mas_equalTo(self.resultImageView.mas_bottom).offset(20);
            make.height.mas_equalTo(16);
        }];
    }
}

/**
 *    @brief    隐藏其他视图
 *    @param    hidden 是否隐藏
 */
- (void)otherViewsHidden:(BOOL)hidden
{
    _clockImageView.hidden = hidden;
    _clockLabel.hidden = hidden;
    _testImageView.hidden = hidden;
    _centerLabel.hidden = hidden;
    _labelBgView.hidden = hidden;
    _aButton.hidden = hidden;
    _bButton.hidden = hidden;
    _cButton.hidden = hidden;
    _dButton.hidden = hidden;
    _eButton.hidden = hidden;
    _fButton.hidden = hidden;
    _titleLabel.hidden = hidden;
    _submitBtn.hidden = hidden;
    _cleanBtn.hidden = hidden;
//    _closeBtn.hidden = hidden;
    _cleanLandscape.hidden = hidden;
    _commitFailedLabel.hidden = hidden;
    if (_isScreenLandScape) {
        _topView.hidden = hidden;
    }else{
        [_topView hiddenCloseBtn:hidden];
    }
}

/**
 *    @brief    开启动画
 */
- (void)showAnimation
{
    self.view.alpha = 0.1f;
    [UIView animateKeyframesWithDuration:0.3 delay:0 options:UIViewKeyframeAnimationOptionBeginFromCurrentState animations:^{
        [self layoutIfNeeded];
        self.view.alpha = 1.f;
    } completion:nil];
}
#pragma mark - 我的答案和正确答案

/**
 *    @brief    更新我的答案字典
 *    @param    arr 需要被更新的数组
 */
- (void)updateSelectArr:(NSArray *)arr
{
    [_selectedArr removeAllObjects];
    [_selectedArr addObject:arr];
}

/**
 *    @brief    显示答案视图
 */
- (void)showAnswerView
{
    NSString *myAnswerText = @"您的答案：";
    NSString *correctAnswerText = @"正确答案：";
    for (NSDictionary *dic in _resultDic[@"practice"][@"options"]) {
        NSInteger type = [_resultDic[@"practice"][@"type"] integerValue];
        if([_selectedArr containsObject:dic[@"id"]]){
//            NSLog(@"我选择的答案：%d", [dic[@"index"] intValue]);
            myAnswerText = [myAnswerText stringByAppendingString:[NSString stringWithFilterStr:dic[@"index"] withType:type]];
        }
        if ([dic[@"isCorrect"] intValue] == 1 ) {
//            NSLog(@"正确答案：%d", [dic[@"index"] intValue]);
            correctAnswerText = [correctAnswerText stringByAppendingString:[NSString stringWithFilterStr:dic[@"index"] withType:type]];
        }
    }
    if (self.result == NO) {//如果选择了答案没有提交。。。todo
        myAnswerText = @"您的答案：";
    }
    //添加我的答案和正确答案提示
    UIColor *textColor = self.isCorrect?CCRGBColor(23, 188, 47):CCRGBColor(255, 100, 61);
    _myAnswerLabel = [UILabel labelWithText:myAnswerText fontSize:[UIFont systemFontOfSize:16] textColor:textColor textAlignment:NSTextAlignmentRight];
    _myAnswerLabel.attributedText = [self getAttributedStrWithStr:myAnswerText];
    _myAnswerLabel.hidden = YES;
    [self.view addSubview:_myAnswerLabel];
    [_myAnswerLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.view.mas_centerX).offset(-4);
        make.top.mas_equalTo(self.view).offset(130);
//        make.height.mas_equalTo(17);
        make.left.mas_equalTo(self.view).offset(15);
    }];
    
    _correctAnswerLabel = [UILabel labelWithText:correctAnswerText fontSize:[UIFont systemFontOfSize:16] textColor:CCRGBColor(23, 188, 47) textAlignment:NSTextAlignmentLeft];
    _correctAnswerLabel.attributedText = [self getAttributedStrWithStr:correctAnswerText];
    _correctAnswerLabel.hidden = YES;
    [self.view addSubview:_correctAnswerLabel];
    [_correctAnswerLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view.mas_centerX).offset(4);
        make.top.mas_equalTo(self.view).offset(130);
//        make.height.mas_equalTo(17);
        make.right.mas_equalTo(self.view).offset(-15);
    }];
}
#pragma mark - 统计结果

/**
 *    @brief    请求统计回调
 */
- (void)requestStatis
{
    self.StaticBlock(_practiceId);
}

/**
 *    @brief    得到答题统计
 *    @param    resultDic 统计结果字典
 *    @param    isScreen  是否全屏
 */
-(void)getPracticeStatisWithResultDic:(NSDictionary *)resultDic isScreen:(BOOL)isScreen
{
    self.isScreenLandScape = isScreen;
    [self otherViewsHidden:YES];
    _resultDic = resultDic;
    //回答人数
    _answerPersonNum = [_resultDic[@"practice"][@"answerPersonNum"] integerValue];
    //正确率
    _correctRate = [NSString stringWithFormat:@"%@", _resultDic[@"practice"][@"correctRate"]];
    //判断是否已经结束
    NSInteger status = [_resultDic[@"practice"][@"status"] integerValue];
    if (_finish == NO) {
         if (status == 1) {
            _titleLabel.text = @"答题进行中";
            _titleLabel.textColor = CCRGBColor(255, 100, 61);
         }else if (status == 2) {
             [self stopTest];
         }
    }
    
    if (!_myAnswerLabel && !_correctAnswerLabel) {
        [self showAnswerView];
    }
    //设置统计结果
    [self removeResultView];
    _clockLabel.font = [UIFont systemFontOfSize:12];
    [self showPracticeStatisView];
    if (_finish == YES) {
        self.hidden = NO;//如果没有参与答题，就不显示结果页面
    }
}
/**
 *    @brief    显示统计结果视图
 */
- (void)showPracticeStatisView {
    self.frame = [UIScreen mainScreen].bounds;
    if (_isScreenLandScape) {//横屏模式下
        //更新约束
        [self.view mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.center.mas_equalTo(self);
            make.size.mas_equalTo(CGSizeMake(355, 319 + (self.count - 6) * 27));
        }];
        [self layoutIfNeeded];
        if (!_topView) {
            WS(weakSelf)
            _topView = [[TopView alloc] initWithFrame:CGRectMake(0, 0, _view.frame.size.width, 40) Title:@"随堂测" titleStyle:TopViewTitleLabelStyleCenter closeBlock:^{
                [weakSelf closeBtnClicked];
            }];
            [self.view addSubview:_topView];
        }
        //更新titlelabel约束
        [_titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.topView.mas_bottom).offset(13);
            make.centerX.mas_equalTo(self.view);
        }];
        
        //题干提示背景视图
        [self.view addSubview:self.labelBgView];
        [_labelBgView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.view);
            make.top.mas_equalTo(_titleLabel.mas_bottom).offset(13);
            make.size.mas_equalTo(CGSizeMake(195, 20));
        }];
        
        //题干部分提示文字
        if (!_centerLabel) {
            _centerLabel = [UILabel labelWithText:ALERT_VOTE fontSize:[UIFont systemFontOfSize:FontSize_24] textColor:CCRGBAColor(102, 102, 102, 1) textAlignment:NSTextAlignmentCenter];
            [_labelBgView addSubview:_centerLabel];
        }
        [_centerLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self.labelBgView);
        }];
        //更新闹钟和提示label的约束
        [_clockImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.titleLabel.centerY);
            make.left.mas_equalTo(self.view).offset(291);
            make.size.mas_equalTo(CGSizeMake(12, 12));
        }];
        [_clockLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.titleLabel);
            make.left.mas_equalTo(self.clockImageView.mas_right).offset(5);
        }];
        
        [_myAnswerLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(self.view.mas_centerX).offset(-4);
            make.top.mas_equalTo(self.view).offset(118);
            make.height.mas_equalTo(17);
            make.left.mas_equalTo(self.view).offset(15);
        }];
        
        [_correctAnswerLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.view.mas_centerX).offset(4);
            make.top.mas_equalTo(self.view).offset(118);
            make.height.mas_equalTo(17);
            make.right.mas_equalTo(self.view).offset(-15);
        }];
        
    }else{//竖屏约束
        
        [self.view mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self);
            make.centerY.mas_equalTo(self).offset(90);
            make.size.mas_equalTo(CGSizeMake(355, 371 + (self.count - 6) * 34));
        }];
        [self layoutIfNeeded];
        if (!_topView) {
            WS(weakSelf)
            _topView = [[TopView alloc] initWithFrame:CGRectMake(0, 0, _view.frame.size.width, 40) Title:@"随堂测" titleStyle:TopViewTitleLabelStyleCenter closeBlock:^{
                [weakSelf closeBtnClicked];
            }];
            [self.view addSubview:_topView];
        }
        //答题卡提示
        _titleLabel.font = [UIFont systemFontOfSize:18];
        [_titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.view);
            make.top.mas_equalTo(_topView.mas_bottom).offset(20);
        }];
        
        //题干提示背景视图
        [self.view addSubview:self.labelBgView];
        [_labelBgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.view);
            make.top.mas_equalTo(_titleLabel.mas_bottom).offset(16);
            make.size.mas_equalTo(CGSizeMake(195, 20));
        }];
        //题干部分提示文字
        _centerLabel = [UILabel labelWithText:ALERT_VOTE fontSize:[UIFont systemFontOfSize:FontSize_24] textColor:CCRGBAColor(102, 102, 102, 1) textAlignment:NSTextAlignmentCenter];
        [_labelBgView addSubview:_centerLabel];
        [_centerLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self.labelBgView);
        }];
        
        //时钟图片
        [_clockImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.titleLabel);
            make.left.mas_equalTo(self.view).offset(291);
            make.size.mas_equalTo(CGSizeMake(12, 12));
        }];
    
        [_clockLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.titleLabel);
            make.left.mas_equalTo(self.clockImageView.mas_right).offset(5);
        }];
        
    }
    [self.view layoutIfNeeded];
    _centerLabel.text = [NSString stringWithFormat:@"共%zd人回答，正确率%@", _answerPersonNum, _correctRate];
    
    //设置统计结果
    if (!_progressView) {
        CGFloat origionY = _isScreenLandScape?154:171;
        _progressView = [[CCClassTestProgressView alloc] initWithFrame:CGRectMake(0, origionY, self.view.frame.size.width, self.view.frame.size.height - origionY) ResultDic:_resultDic isScreen:self.isScreenLandScape];
        [self.view addSubview:_progressView];
    }else{
        CGFloat origionY = _isScreenLandScape?154:171;
        _progressView.frame = CGRectMake(0, origionY, self.view.frame.size.width, self.view.frame.size.height - origionY);
        [_progressView updateWithResultDic:_resultDic isScreen:_isScreenLandScape];
    }
    _topView.frame = CGRectMake(0, 0, _view.frame.size.width, 40);
    _topView.hidden = NO;
    [_topView hiddenCloseBtn:NO];
    _titleLabel.hidden = NO;
    _labelBgView.hidden = NO;
    _centerLabel.hidden = NO;
    _clockImageView.hidden = NO;
    _clockLabel.hidden = NO;
    _myAnswerLabel.hidden = NO;
    _correctAnswerLabel.hidden = NO;
}
#pragma mark - 停止答题
/**
 *    @brief    停止答题
 */
- (void)stopTest
{
    //关闭定时器
    [self stopTimer];
    _finish = YES;
    self.shouldRmove = YES;
    //设置titleLabel的字体和样式
    _titleLabel.text = @"答题结束";
    _titleLabel.textColor = CCRGBColor(30, 31, 33);
    
    //设置闹钟的图片和样式
    _clockImageView.image = [UIImage imageNamed:@"icon-time-gray"];
    _clockLabel.textColor = CCRGBColor(102, 102, 102);
    NSInteger stopTime = [_resultDic[@"practice"][@"stopTime"] integerValue];
    if (stopTime > 0) {
        stopTime = stopTime -1;
    }
    if (_durtion > 0) {
        stopTime = _durtion;
    }
    _clockLabel.text = [NSString stringWithFormat:@"%@", [NSString timeFormat:stopTime]];
    
    //再次调用答题结果，判断当前是否停止答题
    self.StaticBlock(self.practiceId);
}
#pragma mark - 点击关闭按钮
/**
 *    @brief    点击关闭按钮
 */
- (void)closeBtnClicked
{
    if (self.shouldRmove) {
        [self removeFromSuperview];
    }else{
        [self setHidden:YES];
    }
    if (_requestTimer) {
        [_requestTimer invalidate];
    }
}

#pragma mark - 更新随堂测布局
- (void)updateTestViewWithScreenlandscape:(BOOL)isScreenlandscape
{
    _isScreenLandScape = isScreenlandscape;
    [self updateUI];
}

- (void)show
{
    self.hidden = NO;
    [self startTimer];
}

#pragma mark - 点击缩放按钮
/**
 *    @brief    点击收起按钮
 */
- (void)cleanBtnClicked
{
    self.hidden = YES;
    NSMutableDictionary *dict = [self.testDic mutableCopy];
    dict[@"answer"] = self.selectedArr;
//    [self closeBtnClicked];
    if (self.cleanBlock) {
        self.cleanBlock(dict);
    }
}
#pragma mark - 懒加载
/**
 *    @brief    label背景视图
 */
-(UIView *)labelBgView {
    if(!_labelBgView) {
        _labelBgView = [[UIView alloc] init];
        _labelBgView.backgroundColor = [UIColor colorWithHexString:@"#ffffff" alpha:1.f];
        _labelBgView.layer.masksToBounds = YES;
        _labelBgView.layer.cornerRadius = 10;
        _labelBgView.layer.borderColor = [UIColor colorWithHexString:@"#dddddd" alpha:1.f].CGColor;
        _labelBgView.layer.borderWidth = 0.5;
    }
    return _labelBgView;
}
/**
 *    @brief    发布按钮
 */
- (UIButton *)submitBtn
{
    if(!_submitBtn) {
        _submitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_submitBtn setTitle:@"提交" forState:UIControlStateNormal];
        [_submitBtn.titleLabel setFont:[UIFont systemFontOfSize:FontSize_32]];
        [_submitBtn setTitleColor:CCRGBAColor(255, 255, 255, 1) forState:UIControlStateNormal];
        [_submitBtn setTitleColor:CCRGBAColor(255, 255, 255, 0.4) forState:UIControlStateDisabled];
        [_submitBtn addTarget:self action:@selector(submitBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        NSString *imageName = _isScreenLandScape?@"default_btn_landScape":@"default_btn";
        [_submitBtn setBackgroundImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
        [_submitBtn setBackgroundImage:[UIImage imageWithColor:CCRGBAColor(197, 197, 197, 1.0)] forState:UIControlStateDisabled];
    }
    return _submitBtn;
}
/**
 *    @brief    收起按钮
 */
- (UIButton *)cleanBtn
{
    if(!_cleanBtn) {
        _cleanBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cleanBtn setTitle:@"收起" forState:UIControlStateNormal];
        [_cleanBtn.titleLabel setFont:[UIFont systemFontOfSize:FontSize_32]];
        [_cleanBtn setTitleColor:CCRGBColor(255,102,61) forState:UIControlStateNormal];
        
        [_cleanBtn.layer setMasksToBounds:YES];
        [_cleanBtn.layer setCornerRadius:_isScreenLandScape?3:22.5];
        [_cleanBtn.layer setBorderColor:CCRGBColor(255,102,61).CGColor];
        [_cleanBtn.layer setBorderWidth:1];
    
        [_cleanBtn addTarget:self action:@selector(cleanBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cleanBtn;
}

- (UIButton *)cleanLandscape
{
    if (!_cleanLandscape) {
        _cleanLandscape = [UIButton buttonWithType:UIButtonTypeCustom];
        _cleanLandscape.backgroundColor = CCClearColor;
        _cleanLandscape.contentMode = UIViewContentModeScaleAspectFit;
        [_cleanLandscape addTarget:self action:@selector(cleanBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        [_cleanLandscape setBackgroundImage:[UIImage imageNamed:@"test_clean_landscape"] forState:UIControlStateNormal];
    }
    return _cleanLandscape;
}

- (UIButton *)aButton
{
    if (!_aButton) {
        // 新增判断题处理
        NSString *optionATitle = _isJudge == YES ? @"judge_right" : @"A";
        _aButton = [UIButton buttonWithImageName:BUTTON_IMGNAME(_isScreenLandScape, optionATitle) selectedImageName:BUTTON_SELIMGNAME(_isScreenLandScape, optionATitle) tag:0 target:self sel:@selector(optionsBtnClicked:)];
        [_aButton addTarget:self action:@selector(optionsBtnTouched) forControlEvents:UIControlEventTouchDown];
        [_aButton addTarget:self action:@selector(optionsBtnCanceled) forControlEvents:UIControlEventTouchCancel];
    }
    return _aButton;
}

- (UIButton *)bButton
{
    if (!_bButton) {
        // 新增判断题处理
        NSString *optionBTitle = _isJudge == YES ? @"judge_wrong" : @"B";
        
        _bButton = [UIButton buttonWithImageName:BUTTON_IMGNAME(_isScreenLandScape, optionBTitle) selectedImageName:BUTTON_SELIMGNAME(_isScreenLandScape, optionBTitle) tag:1 target:self sel:@selector(optionsBtnClicked:)];
        [_bButton addTarget:self action:@selector(optionsBtnTouched) forControlEvents:UIControlEventTouchDown];
        [_bButton addTarget:self action:@selector(optionsBtnCanceled) forControlEvents:UIControlEventTouchCancel];
    }
    return _bButton;
}

- (UIButton *)cButton
{
    if (!_cButton) {
        _cButton = [UIButton buttonWithImageName:BUTTON_IMGNAME(_isScreenLandScape, @"C") selectedImageName:BUTTON_SELIMGNAME(_isScreenLandScape, @"C") tag:2 target:self sel:@selector(optionsBtnClicked:)];
        [_cButton addTarget:self action:@selector(optionsBtnTouched) forControlEvents:UIControlEventTouchDown];
        [_cButton addTarget:self action:@selector(optionsBtnCanceled) forControlEvents:UIControlEventTouchCancel];
    }
    return _cButton;
}

- (UIButton *)dButton
{
    if (!_dButton) {
        _dButton = [UIButton buttonWithImageName:BUTTON_IMGNAME(_isScreenLandScape, @"D") selectedImageName:BUTTON_SELIMGNAME(_isScreenLandScape, @"D") tag:3 target:self sel:@selector(optionsBtnClicked:)];
        [_dButton addTarget:self action:@selector(optionsBtnTouched) forControlEvents:UIControlEventTouchDown];
        [_dButton addTarget:self action:@selector(optionsBtnCanceled) forControlEvents:UIControlEventTouchCancel];
    }
    return _dButton;
}

- (UIButton *)eButton
{
    if (!_eButton) {
        _eButton = [UIButton buttonWithImageName:BUTTON_IMGNAME(_isScreenLandScape, @"E") selectedImageName:BUTTON_SELIMGNAME(_isScreenLandScape, @"E") tag:4 target:self sel:@selector(optionsBtnClicked:)];
        [_eButton addTarget:self action:@selector(optionsBtnTouched) forControlEvents:UIControlEventTouchDown];
        [_eButton addTarget:self action:@selector(optionsBtnCanceled) forControlEvents:UIControlEventTouchCancel];
    }
    return _eButton;
}

- (UIButton *)fButton
{
    if (!_fButton) {
        _fButton = [UIButton buttonWithImageName:BUTTON_IMGNAME(_isScreenLandScape, @"F") selectedImageName:BUTTON_SELIMGNAME(_isScreenLandScape, @"F") tag:5 target:self sel:@selector(optionsBtnClicked:)];
        [_fButton addTarget:self action:@selector(optionsBtnTouched) forControlEvents:UIControlEventTouchDown];
        [_fButton addTarget:self action:@selector(optionsBtnCanceled) forControlEvents:UIControlEventTouchCancel];
    }
    return _fButton;
}

/**
 *    @brief    选择后的数组
 */
-(NSMutableArray *)selectedArr{
    if (!_selectedArr) {
        _selectedArr = [NSMutableArray array];
    }
    return _selectedArr;
}
/**
 *    @brief    默认显示选项状态数组
 */
- (NSMutableArray *)norOptionsArr
{
    if (!_norOptionsArr) {
        _norOptionsArr = [NSMutableArray array];
    }
    return _norOptionsArr;
}

#pragma mark - 拖拽手势
/**
 *    @brief    拖拽小屏
 */
- (void)handlePan:(UIPanGestureRecognizer*) recognizer
{
    if (_resultDic) {
        return;
    }
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
            break;
        case UIGestureRecognizerStateChanged:
        {
            CGPoint translation = [recognizer translationInView:APPDelegate.window];
            recognizer.view.center = CGPointMake(recognizer.view.center.x + translation.x,
                                                 recognizer.view.center.y + translation.y);
            [recognizer setTranslation:CGPointZero inView:APPDelegate.window];
        }
            break;
        case UIGestureRecognizerStateEnded:
        {
            CGRect smallVideoRect = self.view.frame;
            CGRect frame = [UIScreen mainScreen].bounds;
            CGFloat x = smallVideoRect.origin.x < frame.origin.x ? 0 : smallVideoRect.origin.x;
            
            CGFloat y = smallVideoRect.origin.y < frame.origin.y ? 0 : smallVideoRect.origin.y;
            
            x = (x + smallVideoRect.size.width) > (frame.origin.x + frame.size.width) ? (frame.origin.x + frame.size.width - smallVideoRect.size.width) : x;
            
            y = (y + smallVideoRect.size.height) > (frame.origin.y + frame.size.height) ? (frame.origin.y + frame.size.height - smallVideoRect.size.height) : y;
            
            [UIView animateWithDuration:0.25f animations:^{
                [self.view setFrame:CGRectMake(x, y, smallVideoRect.size.width, smallVideoRect.size.height)];
            } completion:^(BOOL finished) {
            }];
        }
            break;
        case UIGestureRecognizerStateCancelled:
            break;
        case UIGestureRecognizerStateFailed:
            break;
        default:
            break;
    }
}
#pragma mark - 判断是否有网络
/**
 *    @brief    判断当前是否有网络
 *    @return   是否有网
 */
- (BOOL)isExistenceNetwork
{
    BOOL isExistenceNetwork = YES;
    Reachability *reach = [Reachability reachabilityForInternetConnection];
    switch ([reach currentReachabilityStatus]) {
        case NotReachable:{
            isExistenceNetwork = NO;
            break;
        }
        case ReachableViaWiFi:{
            isExistenceNetwork = YES;
            break;
        }
        case ReachableViaWWAN:{
            isExistenceNetwork = YES;
            break;
        }
    }
    return isExistenceNetwork;
}
#pragma mark - 修改特定字符颜色
/**
 *    @brief    修改特定字符颜色
 *    @param    str   字符串
 *    @return   处理过的字符串
 */
- (NSMutableAttributedString *)getAttributedStrWithStr:(NSString *)str
{
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:str];
    //修改颜色
    [string addAttribute:NSForegroundColorAttributeName value:CCRGBColor(121, 128, 139) range:NSMakeRange(0, 5)];
    return string;
}
@end
