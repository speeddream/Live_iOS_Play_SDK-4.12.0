//
//  HDSRedPacketRankView.m
//  CCLiveCloud
//
//  Created by 刘强强 on 2022/4/8.
//  Copyright © 2022 MacBook Pro. All rights reserved.
//

#import "HDSRedPacketRankView.h"
#import "CCSDK/PlayParameter.h"
#import "HDSRedPacketRankHeaderView.h"
#import "HDSRedPacketRankListCell.h"
#import "UIColor+RCColor.h"
#import "CCcommonDefine.h"

#define kLightGreyColor CCRGBAColor(177, 177, 177, 1)
#define kGreyColor CCRGBAColor(153, 153, 153, 1)
#define kNotPrize  @"没有人抢到红包~"

static NSString *cellID = @"cellID";

@interface HDSRedPacketRankView ()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) HDSRedEnvelopeWinningListModel         *model;

@property (nonatomic, strong) CloseRankClosure              closeRankClosure;

@property (nonatomic, strong) NSMutableArray                *dataArray;

@property (nonatomic, strong) UITableView                   *tableView;

@property (nonatomic, strong) HDSRedPacketRankHeaderView     *headerView;

@property (nonatomic, strong) UIImageView                   *notPrize;

@property (nonatomic, strong) UILabel                       *notPrizeTipLabel;

@property (nonatomic, strong) UIScrollView                  *kScrollView;
@property(nonatomic, assign) CGRect                         bgFrame;
@property (nonatomic, copy) NSString *rankBackgroundUrl;
@end

@implementation HDSRedPacketRankView
// MARK: - API
- (instancetype)initWithFrame:(CGRect)frame
                configuration:(nonnull HDSRedEnvelopeWinningListModel *)model
             closeRankClosure:(nonnull CloseRankClosure)closeRankClosure {
    if (self = [super initWithFrame:UIApplication.sharedApplication.delegate.window.bounds]) {
        self.bgFrame = frame;
        self.model = model;
        self.closeRankClosure = closeRankClosure;
        self.backgroundColor = [UIColor colorWithHexString:@"#000000" alpha:0.5];
        [self setupUI];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame rankBackgroundUrl:(NSString *)rankBackgroundUrl configuration:(HDSRedEnvelopeWinningListModel *)model closeRankClosure:(CloseRankClosure)closeRankClosure {
    if (self = [super initWithFrame:UIApplication.sharedApplication.delegate.window.bounds]) {
        self.bgFrame = frame;
        self.rankBackgroundUrl = rankBackgroundUrl;
        self.model = model;
        self.closeRankClosure = closeRankClosure;
        self.backgroundColor = [UIColor colorWithHexString:@"#000000" alpha:0.5];
        [self setupUI];
    }
    return self;
}

// MARK: - CustomMethod
- (void)setupUI {
    
    self.bgView = [[UIView alloc] initWithFrame:self.bgFrame];
    self.bgView.clipsToBounds = YES;
    self.bgView.layer.cornerRadius = 8;
    self.bgView.layer.masksToBounds = YES;
    self.bgView.backgroundColor = [UIColor whiteColor];
    [self addSubview:_bgView];
    
    /// 我的得分
    NSArray *rankList = self.model.records;
    /// 顶部中奖信息视图
    NSString *tip = self.model.redKind == 1 ? @"元" : @"学分";
    CGFloat score = self.model.totalPrice;
    if (self.model.redKind == 1) {
        score = self.model.totalPrice / 100.0;
    }
//    self.headerView = [[HDSRedPacketRankHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.bgView.frame.size.width, 169) score:score tip:tip closeRankClosure:^{
//        if (self.closeRankClosure) {
//            self.closeRankClosure();
//        }
//    }];
    
    self.headerView = [[HDSRedPacketRankHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.bgView.frame.size.width, 169) score:score rankBackgroundUrl:self.rankBackgroundUrl tip:tip closeRankClosure:^{
        if (self.closeRankClosure) {
            self.closeRankClosure();
        }
    }];
    
    [self.bgView addSubview:self.headerView];
    
    
    if (rankList.count > 0) {
        
        /// 底部标题视图
        CGFloat subTitleViewX = 0;
        CGFloat subTitleViewH = 33;
        CGFloat subTitleViewY = CGRectGetMaxY(self.headerView.frame);
        CGFloat subTitleViewW = self.bgView.frame.size.width;
        UIView *subTitleView = [[UIView alloc]initWithFrame:CGRectMake(subTitleViewX, subTitleViewY, subTitleViewW, subTitleViewH)];
        subTitleView.backgroundColor = [UIColor whiteColor];
        [self.bgView addSubview:subTitleView];
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
        CGFloat subScoreX = self.bgView.frame.size.width - subScoreW - 20;
        CGFloat subScoreY = 0;
        CGFloat subScoreH = 33;
        UILabel *subScore = [[UILabel alloc]initWithFrame:CGRectMake(subScoreX, subScoreY, subScoreW, subScoreH)];
        subScore.textColor = kLightGreyColor;
        subScore.font = [UIFont systemFontOfSize:14];
        if (self.model.redKind == 1) {
            subScore.text = @"元";
        } else {
            subScore.text = @"学分";
        }
        subScore.textAlignment = NSTextAlignmentRight;
        [subTitleView addSubview:subScore];
        
        CGFloat y = CGRectGetMaxY(subTitleView.frame);
        self.tableView.frame = CGRectMake(0, y, self.bgView.frame.size.width, self.bgView.frame.size.height - y);
        [self.bgView addSubview:self.tableView];
        
        [self.dataArray removeAllObjects];
        [self.dataArray addObjectsFromArray:rankList];
        [self.tableView reloadData];
        
    }else {
    
        CGFloat scrollViewX = 0;
        CGFloat scrollViewY = 169;
        CGFloat scrollViewW = self.bgView.frame.size.width;
        CGFloat scrollViewH = self.bgView.frame.size.height - 169;
        self.kScrollView.frame = CGRectMake(scrollViewX, scrollViewY, scrollViewW, scrollViewH);
        [self.bgView addSubview:self.kScrollView];
        
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
    HDSRedPacketRankListCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[HDSRedPacketRankListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    [cell redPacketRankListCellWithModel:self.dataArray[indexPath.row] row:indexPath.row mySelfId:self.model.userId redKind:self.model.redKind];
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
        _tableView.backgroundColor = [UIColor whiteColor];
    }
    return _tableView;
}

@end
