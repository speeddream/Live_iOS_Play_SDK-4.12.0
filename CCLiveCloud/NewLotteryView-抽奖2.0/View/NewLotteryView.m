//
//  NewLotteryView.m
//  CCLiveCloud
//
//  Created by Apple on 2020/11/13.
//  Copyright © 2020 MacBook Pro. All rights reserved.
//

#import "NewLotteryView.h"
#import "UIImage+animatedGIF.h"
#import "UIColor+RCColor.h"

#import "NewLotteryHeaderView.h"
#import "NewLotteryInfomationView.h"
#import "NewLotteryWinnersView.h"

#import "NewLotteryViewManagerTool.h"
#import "CCSDK/PlayParameter.h"
#import "CCcommonDefine.h"
#import "UIView+Extension.h"
#import <Masonry/Masonry.h>

#define kLotteryImageDefultH 117.5 //中奖默认图片高度
#define kLossLotteryImageDefultH 50 //未中奖默认图片高度

@interface NewLotteryView ()
@property(nonatomic,strong)UIImageView              *giftView;//加载动画视图
@property(nonatomic,strong)UIImageView              *topBgView;//头部视图
@property(nonatomic,strong)UILabel                  *titleLabel;//头部的文字
@property(nonatomic,strong)UIButton                 *closeBtn;//关闭按钮
@property(nonatomic,strong)UIView                   *view;//总视图
@property(nonatomic,assign)BOOL                     isScreenLandScape;//是否是全屏
@property(nonatomic,assign)BOOL                     clearColor;
@property(nonatomic,assign)BOOL                     myself;//自己中奖
@property(nonatomic,strong)UIScrollView             *bgScrollView;//滚动视图
@property(nonatomic,strong)NewLotteryHeaderView     *headerView;//顶部中奖信息view
@property(nonatomic,strong)NewLotteryInfomationView       *userInputView;//用户输入信息view
@property(nonatomic,strong)NewLotteryWinnersView  *footerView;//中奖名单列表
@property(nonatomic,assign)CGFloat                  topHalfHeight;//不包含名单列表的ScrollView高度
@property(nonatomic,assign)NSInteger                index;//用户中奖信息对应行
@end

@implementation NewLotteryView

#pragma mark - 初始化方法
/**
 *    @brief    初始化方法
 *    @param    isScreenLandScape   是否是全屏
 *    @param    clearColor          clearColor
 */
- (instancetype)initIsScreenLandScape:(BOOL)isScreenLandScape clearColor:(BOOL)clearColor
{
    self = [super init];
    if(self) {
        self.isScreenLandScape = isScreenLandScape;
        self.clearColor = clearColor;
        self.myself = NO;
        [self initUI];
        [self addObserver];
    }
    return self;
}
/**
 *    @brief    抽奖结果
 *    @param    model               中奖信息
 *    @param    isScreenLandScape   是否横屏
 */
- (void)nLottery_resultWithModel:(NewLotteryMessageModel *)model isScreenLandScape:(BOOL)isScreenLandScape
{
    // 1.抽奖一结束
    if (model.type == NEW_LOTTERY_COMPLETE) {
        self.frame = [UIScreen mainScreen].bounds;
        self.hidden = NO;
        BOOL mySelf = [model.infos[@"isWinner"] boolValue];
        if (mySelf) {
            _myself = mySelf;
        }
        _isScreenLandScape = isScreenLandScape;
        //更新_view的约束
        //判断是否是全屏，加载不同的样式
        if(!self.isScreenLandScape) {//竖屏约束
            // 1.显示是否中奖信息
            NSDictionary *infos = model.infos;
            NSString *code = @"";
            NSString *prizeName = infos[@"prize"][@"name"];
            NSString *tip = @"";
            NSArray *array = infos[@"collectTemplate"];
            if (mySelf == YES) {
                code = infos[@"ownUserInfo"][@"prizeCode"];
                if (array.count > 0) {
                    tip = NEWLOTTERY_TIP;
                }
            }
            CGFloat topViewH = 40; // 顶部提示语高度
            CGFloat headerViewH = [self HD_getHeaderViewHeightWithMyself:mySelf prizeName:prizeName tip:tip]; // 中奖个信息高度
            CGFloat userInputH = [self HD_getUserInputViewHeightWithArray:array]; // 用户输入中奖信息高度
            
            NSArray *userInfos = infos[@"userInfos"];
            CGFloat footerViewH = 0; // 中奖名单默认高度
            if (userInfos.count > 0) {
                footerViewH = 34;
            }
            CGFloat viewH = topViewH + headerViewH + userInputH + footerViewH + 20;
            if (viewH > 535.5) { // 最大高度
                viewH = 535.5;
            }else if (viewH < 349) { // 最小高度
                viewH = 349;
            }
            [_view mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(self).offset(25);
                make.right.mas_equalTo(self).offset(-25);
                make.centerY.mas_equalTo(self);
                make.height.mas_equalTo(viewH);
            }];
        } else {//横屏约束
            [_view mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.centerX.mas_equalTo(self);
                make.size.mas_equalTo(CGSizeMake(325, 282.5));
                make.top.mas_equalTo(self).offset(50);
            }];
        }
        [self setLotteryResultUIWithWinner:mySelf withModel:model];
    }
}

/**
 *    @brief    更新中奖名单列表
 *    @param    array   中奖名单
 */
- (void)updateLotteryListWithArray:(NSArray *)array
{
    self.footerView.prizeList = array;
    
    WS(ws)
    self.footerView.updateHeightBlock = ^(CGFloat height) {
        ws.bgScrollView.contentSize = CGSizeMake(ws.view.width, ws.topHalfHeight + height + 25);
    };
}

/**
 *    @brief    设置抽奖结果UI
 *    @param    myself   是否是自己
 */
- (void)setLotteryResultUIWithWinner:(BOOL)myself withModel:(NewLotteryMessageModel *)model
{
    self.titleLabel.text = LOTTERY_RESULT;
    [self.giftView removeFromSuperview];
    _giftView = nil;
    
    // 1.显示是否中奖信息
    NSDictionary *infos = model.infos;
    NSString *code = @"";
    NSString *prizeName = infos[@"prize"][@"name"];
    NSString *tip = @"";
    if (myself == YES) {
        code = infos[@"ownUserInfo"][@"prizeCode"];
        NSArray *collectionTemplate = infos[@"collectTemplate"];
        if (collectionTemplate.count > 0) {
            tip = NEWLOTTERY_TIP;
        }
    }
    WS(ws)
    CGFloat headerViewH = [self HD_getHeaderViewHeightWithMyself:myself prizeName:prizeName tip:tip];
    [self.headerView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(headerViewH);
    }];
    [self.headerView nLottery_HeaderViewWithMySelf:myself code:code prizeName:prizeName tip:tip];
    //点击headerView结束编辑
    self.headerView.headerTouchBlock = ^(NSString * _Nonnull string) {
        [ws endEditing:YES];
    };
    
    //用户信息
    NSArray *collectionTemplate = infos[@"collectTemplate"];
    CGFloat userInputViewH = [self HD_getUserInputViewHeightWithArray:collectionTemplate];
    [self.userInputView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(userInputViewH);
    }];
    self.userInputView.collectInfoArray = collectionTemplate;
    self.userInputView.inputBlock = ^(NSArray * _Nonnull array) {
        if (array.count == 0) return;
        if (ws.contentBlock) {
            ws.contentBlock(array);
        }
    };
    // 键盘弹起更改整个输入框的位置
    self.userInputView.indexBlock = ^(NSInteger index) {
        _index = index - 1;
    };
    
    //中奖列表
    NSArray *userInfos = infos[@"userInfos"];
//    CGFloat footerViewH = [self HD_getFooterViewHeightWithArray:userInfos];
    CGFloat footerViewH = 0;
    if (userInfos.count > 0) {
        footerViewH = 34;
    }
    [self.footerView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(footerViewH);
    }];
    [self.footerView layoutIfNeeded];
    
    if (userInfos.count > 0) {
        [self updateLotteryListWithArray:userInfos];
    }
    // 1.获取中奖列表的Y值
    _topHalfHeight = userInputViewH + headerViewH;
    // 2.计算整个scrollView的高度 + 15的间距
    CGFloat bgH = _topHalfHeight + footerViewH + 25;
    
    self.bgScrollView.contentSize = CGSizeMake(_view.width, bgH);
}

/**
 *    @brief    初始化抽奖视图
 */
- (void)initGiftView
{
    [_view removeFromSuperview];
    _view = nil;
    [self initUI];
}

- (void)setIsAgainCommit:(BOOL)isAgainCommit
{
    _isAgainCommit = isAgainCommit;
    self.userInputView.isAgainCommit = isAgainCommit;
}

/**
 *    @brief    移除视图
 */
- (void)remove
{
    [self removeFromSuperview];
//    WS(ws)
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        if (!_myself || (_myself && self.hidden == YES)) {
//            [ws removeFromSuperview];
//        }
//    });
}

/**
 *    @brief    是否能够点击关闭按钮
 *    @return   是否能点击
 */
- (BOOL)isCanCloseBtnClick
{
    [self endEditing:YES];
    BOOL result = self.userInputView.dataArray.count > 0 ? NO : YES;
    return result;
}

#pragma mark - 初始化UI
/**
 *    @brief    初始化UI布局
 */
- (void)initUI {
//    self.type = 0;
    if(self.clearColor) {
        self.backgroundColor = CCClearColor;
    } else {
        self.backgroundColor = CCRGBAColor(0, 0, 0, 0.5);
    }
    _view = [[UIView alloc]init];
    _view.backgroundColor = [UIColor whiteColor];
    _view.layer.cornerRadius = 3;
    [self addSubview:_view];
    //判断是否是全屏，加载不同的样式
    if(!self.isScreenLandScape) {//竖屏约束
        [_view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self).offset(25);
            make.right.mas_equalTo(self).offset(-25);
            make.centerY.mas_equalTo(self);
            make.height.mas_equalTo(282.5);
        }];
    } else {//横屏约束
        [_view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self);
            make.size.mas_equalTo(CGSizeMake(325, 282.5));
            make.top.mas_equalTo(self).offset(50);
        }];
    }
    //顶部背景视图
    [self.view addSubview:self.topBgView];
    [_topBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view);
        make.right.mas_equalTo(self.view);
        make.top.mas_equalTo(self.view);
        make.height.mas_equalTo(40);
    }];
    //背景scrollView
    [self.view addSubview:self.bgScrollView];
    [self.view sendSubviewToBack:self.bgScrollView];
    self.bgScrollView.contentSize = CGSizeMake(_view.width, _view.height);
    [self.bgScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.topBgView.mas_bottom);
        make.left.bottom.right.mas_equalTo(self.view);
    }];
    //顶部标题
    [self.view addSubview:self.titleLabel];
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.topBgView);
    }];
    //顶部关闭按钮
    [self.view addSubview:self.closeBtn];
    [_closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.topBgView).offset(-10);
        make.centerY.mas_equalTo(self.topBgView);
        make.size.mas_equalTo(CGSizeMake(28,28));
    }];
    //添加礼物视图
    [self.view addSubview:self.giftView];
    [_giftView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view);
    }];
    
    [self.bgScrollView addSubview:self.headerView];
    [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.bgScrollView);
        make.left.right.mas_equalTo(self.view);
        make.height.mas_equalTo(0);
    }];
    
    [self.bgScrollView addSubview:self.userInputView];
    [self.userInputView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.headerView.mas_bottom);
        make.left.right.mas_equalTo(self.view);
        make.height.mas_equalTo(0);
    }];
    
    [self.bgScrollView addSubview:self.footerView];
    [self.footerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.userInputView.mas_bottom).offset(15);
        make.left.mas_equalTo(self.view).offset(15);
        make.right.mas_equalTo(self.view).offset(-15);
        make.height.mas_equalTo(0);
    }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self endEditing:YES];
}

#pragma mark - otherMethod (布局改变后,请重新计算控件高度)
/**
 *    @brief    获取中奖信息的高度
 */
- (CGFloat)HD_getHeaderViewHeightWithMyself:(BOOL)myself prizeName:(NSString *)prizeName tip:(NSString *)tip
{
    CGFloat height = 0;
    // 1.最大宽度
    CGFloat width = self.view.width - 30;
    if (myself) {
        // 2.奖品提示语高度
        NSString *prize = [[NSString alloc]initWithFormat:@"恭喜您获得了【%@】，请牢记您的中奖码",prizeName];
        height = [NewLotteryViewManagerTool heightForString:prize fontSize:FontSize_28 andWidth:width];
        // 3.图片高度
        height = height + kLotteryImageDefultH;
        // 4.底部提示语高度
        if (tip.length > 0) { // 4.1有提示语
            height = height + [NewLotteryViewManagerTool heightForString:tip fontSize:FontSize_26 andWidth:width];
            // 5.加上间距的高度
            height = height + 20 * 2 + 15 * 2;
        }else { // 4.1无提示语
            // 5.加上间距的高度
            height = height + 20 + 15 * 2;
        }
    }else {
        // 2.奖品提示语高度
        NSString *prize = [[NSString alloc]initWithFormat:@"很遗憾，您没有获得【%@】",prizeName];
        height = [NewLotteryViewManagerTool heightForString:prize fontSize:FontSize_28 andWidth:width];
        // 3.图片高度
        height = height + kLossLotteryImageDefultH;
        // 4.间距高度
        height = height + 20 * 2 + 15;
    }
    return height;
}

/**
 *    @brief    获取用户信息高度
 */
- (CGFloat)HD_getUserInputViewHeightWithArray:(NSArray *)array
{
//    NSArray *array = @[@{@"title":@"姓名",@"tips":@"请输入姓名",@"index":@(0)},
//    @{@"title":@"手机号",@"tips":@"请输入手机号",@"index":@(1)},
//    @{@"title":@"地址",@"tips":@"请输入地址",@"index":@(2)},
//    @{@"title":@"地址2",@"tips":@"请输入地址2",@"index":@(3)},
//    @{@"title":@"地址3",@"tips":@"请输入地址3",@"index":@(4)}];
    if (array.count == 0) return 0;
    CGFloat height = 0;
    // 1.tableView高度
    height = array.count * 50;
    // 2.提示语及按钮高度
    height = height + 45;
    // 3.间距高度
    height = height + 25 + 15;
    return height;
}
/**
 *    @brief    获取中奖名单高度
 */
- (CGFloat)HD_getFooterViewHeightWithArray:(NSArray *)array
{
    if (array.count == 0) return 0;
    // 1.计算行数
    NSInteger row = [NewLotteryViewManagerTool getMaxRowWithArray:array];
    // 2.计算单个宽度
    CGFloat singleW = [NewLotteryViewManagerTool getSingleWHWithWidth:self.view.width - 60];
    // 2.1计算单个高度
    CGFloat singleH = singleW / 4 * 5;
    // 3.计算整个listView的高度
    CGFloat listViewH = singleH * row;
    // 4.footerView高度 = listViewH + 间距 + 按钮高度
    CGFloat height = listViewH + 15 + 34;
    
    return height;
}

#pragma mark - 懒加载
/**
 *    @brief    中奖名单
 */
- (NewLotteryWinnersView *)footerView
{
    if (!_footerView) {
        UIColor *color = [UIColor colorWithHexString:@"#999999" alpha:1];
        _footerView = [[NewLotteryWinnersView alloc]initWithFrame:CGRectZero];
        _footerView.backgroundColor = [color colorWithAlphaComponent:0.1];
        _footerView.layer.cornerRadius = 10;
        _footerView.layer.masksToBounds = YES;
    }
    return _footerView;
}
/**
 *    @brief    中奖用户填写信息
 */
- (NewLotteryInfomationView *)userInputView
{
    if (!_userInputView) {
        _userInputView = [[NewLotteryInfomationView alloc]initWithFrame:CGRectZero];
    }
    return _userInputView;
}
/**
 *    @brief    中奖信息
 */
- (NewLotteryHeaderView *)headerView
{
    if (!_headerView) {
        _headerView = [[NewLotteryHeaderView alloc]init];
    }
    return _headerView;
}
/**
 *    @brief    背景ScrollView
 */
- (UIScrollView *)bgScrollView
{
    if (!_bgScrollView) {
        _bgScrollView = [[UIScrollView alloc]init];
        _bgScrollView.showsHorizontalScrollIndicator = NO;
        _bgScrollView.showsVerticalScrollIndicator = NO;
    }
    return _bgScrollView;
}
/**
 *    @brief    提示文本
 */
- (UILabel *)titleLabel {
    if(!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.text = @"抽奖啦";
        _titleLabel.textColor = [UIColor colorWithHexString:@"#38404b" alpha:1.f];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = [UIFont systemFontOfSize:FontSize_32];
    }
    return _titleLabel;
}
/**
 *    @brief    关闭按钮
 */
- (UIButton *)closeBtn {
    if(!_closeBtn) {
        _closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _closeBtn.backgroundColor = CCClearColor;
        _closeBtn.contentMode = UIViewContentModeScaleAspectFit;
        [_closeBtn addTarget:self action:@selector(closeBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        [_closeBtn setBackgroundImage:[UIImage imageNamed:@"popup_close"] forState:UIControlStateNormal];
    }
    return _closeBtn;
}
/**
 *    @brief    关闭按钮点击事件
 */
- (void)closeBtnClicked
{
    SaveToUserDefaults(@"lottery_open_status", @(0));
    if (self.closeBlock) {
        self.closeBlock([self isCanCloseBtnClick]);
    }
//    [self endEditing:YES];
//    self.hidden = YES;
}
/**
 *    @brief    礼物视图
 */
- (UIImageView *)giftView {
    if(!_giftView) {
        _giftView = [[UIImageView alloc] initWithImage:[UIImage sd_animatedGIFNamed:@"gift_loading_gif"]];
        _giftView.backgroundColor = CCClearColor;
        _giftView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _giftView;
}
/**
 *    @brief    头部背景视图
 */
- (UIImageView *)topBgView {
    if(!_topBgView) {
        _topBgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Bar"]];
        _topBgView.backgroundColor = CCClearColor;
        _topBgView.userInteractionEnabled = YES;
        // 阴影颜色
        _topBgView.layer.shadowColor = [UIColor grayColor].CGColor;
        // 阴影偏移，默认(0, -3)
        _topBgView.layer.shadowOffset = CGSizeMake(0, 3);
        // 阴影透明度，默认0.7
        _topBgView.layer.shadowOpacity = 0.2f;
        // 阴影半径，默认3
        _topBgView.layer.shadowRadius = 3;
        _topBgView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _topBgView;
}

#pragma mark - 添加通知
- (void)addObserver {
    //键盘将要弹出
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    //键盘将要消失
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}
#pragma mark - 键盘事件
/**
 *    @brief    键盘将要出现
 */
- (void)keyboardWillShow:(NSNotification *)noti
{
    NSDictionary *userInfo = [noti userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    CGFloat y = keyboardRect.size.height;

    [self updateBackgroundScollViewFrameWithHeight:y];
}
/**
 *    @brief    键盘将要消失
 */
- (void)keyboardWillHide:(NSNotification *)notif
{
    [self updateBackgroundScollViewFrameWithHeight:0];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)updateBackgroundScollViewFrameWithHeight:(CGFloat)height
{
//    if (_myself) {
//        CGRect rect = [_userInputView convertRect:_userInputView.bounds toView:self];
//        CGFloat top = height == 0 ? 0 :height - rect.origin.y;

//        self.bgScrollView.contentInset = UIEdgeInsetsMake(top, 0, 0, 0);
//        [self layoutIfNeeded];
//    }
}

@end
