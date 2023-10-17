//
//  HDRedPacketRankView.m
//  CCLiveCloud
//
//  Created by Richard Lee on 7/1/21.
//  Copyright © 2021 MacBook Pro. All rights reserved.
//

#import "HDRedPacketRankView.h"
#import "CCSDK/PlayParameter.h"
#import "HDRedPacketRankHeaderView.h"
#import "HDRedPacketRankListCell.h"
#import "CCcommonDefine.h"

#define kLightGreyColor CCRGBAColor(177, 177, 177, 1)
#define kGreyColor CCRGBAColor(153, 153, 153, 1)
#define kNotPrize  @"没有人抢到红包~"

static NSString *cellID = @"cellID";

@interface HDRedPacketRankView ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) HDSRedPacketRankModel         *model;

@property (nonatomic, strong) CloseRankClosure              closeRankClosure;

@property (nonatomic, strong) NSMutableArray                *dataArray;

@property (nonatomic, strong) UITableView                   *tableView;

@property (nonatomic, strong) HDRedPacketRankHeaderView     *headerView;

@property (nonatomic, strong) UIImageView                   *notPrize;

@property (nonatomic, strong) UILabel                       *notPrizeTipLabel;

@property (nonatomic, strong) UIScrollView                  *kScrollView;

@end


@implementation HDRedPacketRankView
// MARK: - API
- (instancetype)initWithFrame:(CGRect)frame
                configuration:(nonnull HDSRedPacketRankModel *)model
             closeRankClosure:(nonnull CloseRankClosure)closeRankClosure {
    if (self = [super initWithFrame:frame]) {
        self.model = model;
        self.closeRankClosure = closeRankClosure;
        self.backgroundColor = [UIColor whiteColor];
        self.clipsToBounds = YES;
        self.layer.cornerRadius = 8;
        self.layer.masksToBounds = YES;
        [self setupUI];
    }
    return self;
}

// MARK: - CustomMethod
- (void)setupUI {
    
    /// 我的得分
    NSInteger score = 0;
    NSArray *rankList = self.model.rankList;
    for (HDSRedRacketRankListModel *model in rankList) {
        if (model.isMyself == YES) {
            score = model.amount;
        }
    }
    /// 顶部中奖信息视图
    self.headerView = [[HDRedPacketRankHeaderView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, 169) score:score closeRankClosure:^{
        if (self.closeRankClosure) {
            self.closeRankClosure();
        }
    }];
    [self addSubview:self.headerView];
    
    
    if (rankList.count > 0) {
        
        /// 底部标题视图
        CGFloat subTitleViewX = 0;
        CGFloat subTitleViewH = 33;
        CGFloat subTitleViewY = CGRectGetMaxY(self.headerView.frame);
        CGFloat subTitleViewW = self.frame.size.width;
        UIView *subTitleView = [[UIView alloc]initWithFrame:CGRectMake(subTitleViewX, subTitleViewY, subTitleViewW, subTitleViewH)];
        subTitleView.backgroundColor = [UIColor whiteColor];
        [self addSubview:subTitleView];
        /// 昵称
        CGFloat subNickX = 40;
        CGFloat subNickY = 0;
        CGFloat subNickW = 100;
        CGFloat subNickH = 33;
        UILabel *subNickName = [[UILabel alloc]initWithFrame:CGRectMake(subNickX, subNickY, subNickW, subNickH)];
        subNickName.textColor = kLightGreyColor;
        subNickName.font = [UIFont systemFontOfSize:14];
        subNickName.text = @"昵称";
        subNickName.textAlignment = NSTextAlignmentLeft;
        [subTitleView addSubview:subNickName];
        
        /// 学分
        CGFloat subScoreW = 100;
        CGFloat subScoreX = self.frame.size.width - subScoreW - 20;
        CGFloat subScoreY = 0;
        CGFloat subScoreH = 33;
        UILabel *subScore = [[UILabel alloc]initWithFrame:CGRectMake(subScoreX, subScoreY, subScoreW, subScoreH)];
        subScore.textColor = kLightGreyColor;
        subScore.font = [UIFont systemFontOfSize:14];
        subScore.text = @"学分";
        subScore.textAlignment = NSTextAlignmentRight;
        [subTitleView addSubview:subScore];
        
        CGFloat y = CGRectGetMaxY(subTitleView.frame);
        self.tableView.frame = CGRectMake(0, y, self.frame.size.width, self.frame.size.height - y);
        [self addSubview:self.tableView];
        
        [self.dataArray removeAllObjects];
        [self.dataArray addObjectsFromArray:rankList];
        [self.tableView reloadData];
        
    }else {
    
        CGFloat scrollViewX = 0;
        CGFloat scrollViewY = 169;
        CGFloat scrollViewW = self.frame.size.width;
        CGFloat scrollViewH = self.frame.size.height - 169;
        self.kScrollView.frame = CGRectMake(scrollViewX, scrollViewY, scrollViewW, scrollViewH);
        [self addSubview:self.kScrollView];
        
        self.notPrize = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"redPacket_not_prize"]];
        self.notPrize.frame = CGRectMake(50, 5, scrollViewW - 100, 143);
        [self.kScrollView addSubview:self.notPrize];

        CGFloat notPrizeLabelX = 50;
        CGFloat notPrizeLabelY = CGRectGetMaxY(self.notPrize.frame) + 5;
        CGFloat notPrizeLabelW = scrollViewW - 100;
        CGFloat notPrizeLabelH = 24;
        self.notPrizeTipLabel = [[UILabel alloc]initWithFrame:CGRectMake(notPrizeLabelX, notPrizeLabelY, notPrizeLabelW, notPrizeLabelH)];
        self.notPrizeTipLabel.textColor = kGreyColor;
        self.notPrizeTipLabel.font = [UIFont systemFontOfSize:15];
        self.notPrizeTipLabel.text = kNotPrize;
        self.notPrizeTipLabel.textAlignment = NSTextAlignmentCenter;
        [self.kScrollView addSubview:self.notPrizeTipLabel];
        
        CGFloat H = notPrizeLabelH + notPrizeLabelY;
        self.kScrollView.contentSize = CGSizeMake(scrollViewW, H);
        
    }
}

// MARK: - tableView delegate & dataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HDRedPacketRankListCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[HDRedPacketRankListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    [cell redPacketRankListCellWithModel:self.dataArray[indexPath.row] row:indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

// MARK: - LAZY
- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

- (UIScrollView *)kScrollView {
    if (!_kScrollView) {
        _kScrollView = [[UIScrollView alloc]init];
        _kScrollView.showsHorizontalScrollIndicator = NO;
        _kScrollView.showsVerticalScrollIndicator = NO;
    }
    return _kScrollView;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.showsVerticalScrollIndicator = NO;
    }
    return _tableView;
}

@end
