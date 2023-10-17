//
//  NewLotteryInfomationView.m
//  CCLiveCloud
//
//  Created by Apple on 2020/11/13.
//  Copyright © 2020 MacBook Pro. All rights reserved.
//

#import "NewLotteryInfomationView.h"
#import "NewLotteryInfomationCell.h"
#import "NewLotteryInfomationCellModel.h"
#import "CCSDK/PlayParameter.h"
#import "Reachability.h"
#import "InformationShowView.h"
#import "UIColor+RCColor.h"
#import "CCcommonDefine.h"
#import "CCAlertView.h"
#import <Masonry/Masonry.h>

static NSString *cellID = @"cellID";

@interface NewLotteryInfomationView ()<UITableViewDelegate,UITableViewDataSource>

/** 输入信息表单 */
@property (nonatomic, strong) UITableView               *tableView;
/** 提交按钮 */
@property (nonatomic, strong) UIButton                  *commitBtn;
/** 提示语 */
@property (nonatomic, strong) UILabel                   *tipLabel;
/** 填写中奖信息开始时间 */
@property (nonatomic, copy)   NSString                  *beginTime;
/** 提示窗 */
@property (nonatomic, strong) InformationShowView       *tipView;

@property (nonatomic, strong) NSMutableArray            *commintInfos;

@end

@implementation NewLotteryInfomationView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}
/**
 *    @brief    初始化界面
 */
- (void)setupUI
{
    [self addSubview:self.tipLabel];
    [self.tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self);
        make.bottom.mas_equalTo(self).offset(-55);
    }];
    
    [self addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(self);
    }];
    
    [self addSubview:self.commitBtn];
    [self.commitBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self).offset(-5);
        make.width.mas_equalTo(180);
        make.height.mas_equalTo(45);
        make.centerX.mas_equalTo(self);
    }];
    self.commitBtn.layer.cornerRadius = 22.5;
    self.commitBtn.layer.masksToBounds = YES;
    
    [self layoutIfNeeded];
}
/**
 *    @brief    用户信息数组 (根据类型展示对应的信息)
 */
- (void)setCollectInfoArray:(NSArray *)collectInfoArray
{
    // 1.记录开始填写用户信息时间
    _beginTime = [self getNowTimeTimestamp];
    _collectInfoArray = collectInfoArray;
    if (collectInfoArray.count == 0) {
        self.hidden = YES;
        return;
    }
    [self.dataArray removeAllObjects];
    
    if (self.commintInfos.count > 0) {
        [self.dataArray addObjectsFromArray:self.commintInfos];
    } else {
        for (int i = 0; i < _collectInfoArray.count; i++) {
            NSDictionary *dict = _collectInfoArray[i];
            NewLotteryInfomationCellModel *subModel = [[NewLotteryInfomationCellModel alloc]init];
            subModel.title = dict[@"title"];
            subModel.tips = dict[@"tips"];
            subModel.index = [dict[@"index"] integerValue];
            subModel.content = @"";
            [self.dataArray addObject:subModel];
        }
    }
    CGFloat height = _collectInfoArray.count * 50;
    [self.tableView mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.bottom.mas_equalTo(self).offset(-80);
        make.height.mas_equalTo(height);
    }];
    [self.tableView reloadData];
}

#pragma mark - tableView Delegate & Datasouse
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NewLotteryInfomationCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
       cell = [[NewLotteryInfomationCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    cell.model = self.dataArray[indexPath.row];
    WS(ws)
    cell.selectedBlock = ^(NSInteger index) {
        [ws beginScrollWithIndex:index];
    };
    cell.contentBlock = ^(NewLotteryInfomationCellModel * _Nonnull model) {
        [ws updateListWithModel:model];
    };
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

/**
 *    @brief    开始滚动
 *    @param    index   对应行
 */
- (void)beginScrollWithIndex:(NSInteger)index
{
    if (self.indexBlock) {
        self.indexBlock(index);
    }
}
/**
 *    @brief    更新数据
 *    @param    model   对应数据
 */
- (void)updateListWithModel:(NewLotteryInfomationCellModel *)model
{
    if (model.index <= 0) return;
    NSInteger index = model.index - 1;
    [self.dataArray replaceObjectAtIndex:index withObject:model];
    
    [self.commintInfos removeAllObjects];
    [self.commintInfos addObjectsFromArray:self.dataArray];
}

- (void)showTipView
{
    [_tipView removeFromSuperview];
    _tipView = nil;
}

/**
 *    @brief    校验手机号
 *    @param    number   手机号
 */
- (BOOL)isPhoneNumber:(NSString *)number
{
//    NSString *phoneRegex1=@"1[0-9]([0-9]){9}";
    NSString *phoneRegex1=@"\\d{11}";
    NSPredicate *phoneTest1 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",phoneRegex1];
    return  [phoneTest1 evaluateWithObject:number];
}

- (void)setIsAgainCommit:(BOOL)isAgainCommit
{
    _isAgainCommit = isAgainCommit;
    if (isAgainCommit == YES) {
        self.commitBtn.enabled = YES;
        self.tableView.userInteractionEnabled = YES;
        [self.commitBtn setTitle:@"提交" forState:UIControlStateNormal];
    }
}


#pragma mark - otherMethod
/**
 *    @brief    提交按钮点击事件
 */
- (void)commitBtnClick:(UIButton *)sender
{
    [self endEditing:YES];
    // 1.网络异常提示
    if ([self isExistenceNetwork] == NO) {
        self.tipLabel.hidden = NO;
        self.tipLabel.text = @"网络异常，请稍后再试";
        return;
    }
    self.tipLabel.hidden = YES;
    self.tipLabel.text = @"";
    // 2.超过30分钟提示
    NSString *endTime = [self getNowTimeTimestamp];
    if ([endTime integerValue] - [self.beginTime integerValue] > 30 * 60 * 1000) {
        CCAlertView *alertView = [[CCAlertView alloc] initWithAlertTitle:@"已超过提交时间，提交失败！" sureAction:SURE cancelAction:nil sureBlock:^{
            self.commitBtn.enabled = NO;
            self.tableView.userInteractionEnabled = YES;
            [self.commitBtn setTitle:@"提交" forState:UIControlStateNormal];
        }];
        [APPDelegate.window addSubview:alertView];
        return;
    }
    
    NSMutableArray *array = [NSMutableArray array];
    for (NewLotteryInfomationCellModel *model in self.dataArray) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[@"index"] = @(model.index);
        if (model.content.length == 0) {
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showTipView) object:nil];
            [_tipView removeFromSuperview];
            NSString *tip = [[NSString alloc]initWithFormat:@"%@不能为空",model.title];
            _tipView = [[InformationShowView alloc] initWithLabel:tip];
            [APPDelegate.window addSubview:_tipView];
            [_tipView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
            }];
            [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(showTipView) userInfo:nil repeats:NO];
            return;
        }else if ([model.title isEqualToString:@"手机号"] && model.content.length > 0) {
            BOOL result = [self isPhoneNumber:model.content];
            if (result == NO) {
                
                [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showTipView) object:nil];
                [_tipView removeFromSuperview];
                _tipView = [[InformationShowView alloc] initWithLabel:@"请输入正确的手机号"];
                [APPDelegate.window addSubview:_tipView];
                [_tipView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
                }];
                [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(showTipView) userInfo:nil repeats:NO];
                return;
            }
        }
        dict[@"value"] = model.content;
        [array addObject:dict];
    }
    self.commitBtn.enabled = NO;
    self.tableView.userInteractionEnabled = NO;
    [self.commitBtn setTitle:@"已提交" forState:UIControlStateNormal];
    if (self.inputBlock) {
        self.inputBlock(array);
    }
}
#pragma mark - 懒加载
- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.bounces = NO;
        _tableView.showsVerticalScrollIndicator = NO;
    }
    return _tableView;
}

- (UILabel *)tipLabel
{
    if (!_tipLabel) {
        _tipLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        _tipLabel.textColor = [UIColor colorWithHexString:@"#FF412E" alpha:1];
        _tipLabel.font = [UIFont systemFontOfSize:13];
        _tipLabel.hidden = YES;
        _tipLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _tipLabel;
}

- (UIButton *)commitBtn
{
    if (!_commitBtn) {
        _commitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_commitBtn setTitle:@"提交" forState:UIControlStateNormal];
        [_commitBtn setTitleColor:[UIColor colorWithHexString:@"#FFFFFF" alpha:1] forState:UIControlStateNormal];
        [_commitBtn addTarget:self action:@selector(commitBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [_commitBtn setBackgroundImage:[UIImage imageNamed:@"default_btn"] forState:UIControlStateNormal];
    }
    return _commitBtn;
}

- (NSMutableArray *)dataArray
{
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
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
/**
 *    @brief    获取当前时间戳(毫秒)
 *    @return   当前时间戳
 */
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
    NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)([datenow timeIntervalSince1970]*1000) ];
    return timeSp;
}

- (NSMutableArray *)commintInfos {
    if (!_commintInfos) {
        _commintInfos = [NSMutableArray array];
    }
    return _commintInfos;
}

@end
