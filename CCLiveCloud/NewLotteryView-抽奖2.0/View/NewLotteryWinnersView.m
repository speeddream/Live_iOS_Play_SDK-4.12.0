//
//  NewLotteryWinnersView.m
//  CCLiveCloud
//
//  Created by Apple on 2020/11/13.
//  Copyright © 2020 MacBook Pro. All rights reserved.
//

#import "NewLotteryWinnersView.h"
#import "NewLotteryViewManagerTool.h"
#import "NewLotteryWinnersCell.h"
#import "NewLotteryWinnersCellModel.h"
#import <MJExtension/MJExtension.h>
#import "UIColor+RCColor.h"
#import "CCcommonDefine.h"
#import <Masonry/Masonry.h>

#define kAwardsBtn_close @"nLotteryView_close"
#define kAwardsBtn_open @"nLotteryView_open"

#define kLottery_open_status @"lottery_open_status"

#define kAwardsBtnDefaultHeight 34 //列表地关闭默认高度

static NSString *const CollectionViewCellID = @"NewLotteryWinnersCellID";

@interface NewLotteryWinnersView ()<UICollectionViewDataSource,UICollectionViewDelegate>

@property(nonatomic,strong)UIButton                 *awardsListBtn;//中奖名单开关
@property(nonatomic,assign)NSInteger                awardsListStatus;//按钮状态 0 关闭 1 开启 (默认开启)
@property(nonatomic,strong)UIImageView              *awardsBtnImageView;//中奖名单开关图片
@property(nonatomic,strong)UICollectionView         *listView;//中奖名单列表
@property(nonatomic,assign)CGFloat                  selfH;//当前视图高度
@property(nonatomic,assign)CGFloat                  itemH;//每个视图的高度
@property(nonatomic,strong)NSMutableArray           *dataArray;
@property(nonatomic,assign)CGFloat                  listViewH;

@end

@implementation NewLotteryWinnersView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI
{
    UILabel *awardsTitle = [[UILabel alloc]init];
    awardsTitle.text = @"中奖名单";
    awardsTitle.textColor = [UIColor colorWithHexString:@"#38404B" alpha:1];
    awardsTitle.font = [UIFont systemFontOfSize:14];
    [self addSubview:awardsTitle];
    [awardsTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self).offset(10);
        make.centerX.mas_equalTo(self).offset(-5);
    }];
    
    // 按钮状态默认开启
    self.awardsListStatus = 0;
    SaveToUserDefaults(kLottery_open_status, @(self.awardsListStatus));
    self.awardsBtnImageView = [[UIImageView alloc]init];
    self.awardsBtnImageView.image = [UIImage imageNamed:self.awardsListStatus == 0 ? kAwardsBtn_close : kAwardsBtn_open];
    [self addSubview:self.awardsBtnImageView];
    [self.awardsBtnImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(awardsTitle.mas_right).offset(5);
        make.centerY.mas_equalTo(awardsTitle);
    }];
    
    //中间名单开关
    [self addSubview:self.awardsListBtn];
    [_awardsListBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(self);
        make.height.mas_equalTo(kAwardsBtnDefaultHeight);
    }];
    
    [self addSubview:self.listView];
    [self.listView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self).offset(34);
        make.left.mas_equalTo(self).offset(15);
        make.right.mas_equalTo(self).offset(-15);
        make.height.mas_equalTo(0);
    }];
}

- (void)setPrizeList:(NSArray *)prizeList
{
    _prizeList = prizeList;
    
    int awardsListStatus = [GetFromUserDefaults(kLottery_open_status) intValue];
    NSLog(@"--> awardsListStatus:%d",awardsListStatus);
    self.awardsListStatus = awardsListStatus;
    [self.dataArray removeAllObjects];
    NSMutableArray *temp = [NewLotteryWinnersCellModel mj_objectArrayWithKeyValuesArray:self.prizeList];
    [self.dataArray addObjectsFromArray:temp];
    self.selfH = 34;
    self.listViewH = 0;
    if (prizeList.count == 0) return;
    // 1.计算行数
    NSInteger row = [NewLotteryViewManagerTool getMaxRowWithArray:prizeList];
    // 2.计算单个高度
    CGFloat singleW = [NewLotteryViewManagerTool getSingleWHWithWidth:self.frame.size.width - 30];
    // 2.1计算单个高度
    CGFloat singleH = singleW / 4 * 5;
    self.itemH = singleH;
    // 3.计算整个listView的高度
    CGFloat listViewH = singleH * row;
    self.listViewH = listViewH;
    // 4.整个视图的高度
    self.selfH = self.selfH + listViewH + 15;
    
    [self.listView reloadData];
    
    NSLog(@"--> setPrizeList --> awardsListStatus:%d --> updateListView",awardsListStatus);
    [self updateListView];
}

- (void)updateListView {
    // 1.更新当前视图高度
    CGFloat height = self.awardsListStatus == 0 ? kAwardsBtnDefaultHeight : self.selfH;
    // 2.更改按钮图片
    self.awardsBtnImageView.image = self.awardsListStatus == 0 ? [UIImage imageNamed:kAwardsBtn_close] : [UIImage imageNamed:kAwardsBtn_open];
    // 3.更新布局
    //self.listView.hidden = self.awardsListStatus == 0 ? NO : YES;
    [self mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(height);
    }];
    if (self.awardsListStatus == 0) {
        [self.listView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(0);
        }];
    }else {
        [self.listView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(self.listViewH);
        }];
    }
    [self.listView layoutIfNeeded];
    [self layoutIfNeeded];
    NSLog(@"--> updateListView --> listViewH:%f --> height:%f",self.listViewH,height);
    if (self.updateHeightBlock) {
        self.updateHeightBlock(height);
    }
}

#pragma mark - collectionView Datasource & delegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _dataArray.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NewLotteryWinnersCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CollectionViewCellID forIndexPath:indexPath];
    cell.model = self.dataArray[indexPath.row];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(floor(self.itemH * 4 / 5), self.itemH);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

#pragma mark - 中奖名单按钮点击事件
/**
 *    @brief    中奖名单列表开关点击事件
 */
- (void)awardsListBtnClick:(UIButton *)sender
{
    self.awardsListStatus = self.awardsListStatus == 0 ? 1 : 0;
    SaveToUserDefaults(kLottery_open_status, @(self.awardsListStatus));
    NSLog(@"--> awardsListBtnClick --> awardsListStatus:%d --> updateListView",self.awardsListStatus);
    [self updateListView];
}

#pragma mark - 懒加载
/**
 *    @brief    中奖名单开关
 */
- (UIButton *)awardsListBtn
{
    if (!_awardsListBtn) {
        _awardsListBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_awardsListBtn addTarget:self action:@selector(awardsListBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _awardsListBtn;
}
/**
 *    @brief    中奖名单
 */
- (UIView *)listView
{
    if (!_listView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
        _listView = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:layout];
        _listView.backgroundColor = [UIColor clearColor];
        _listView.dataSource = self;
        _listView.delegate = self;
        _listView.showsVerticalScrollIndicator = NO;
        _listView.showsHorizontalScrollIndicator = NO;
        _listView.bounces = NO;
        [_listView registerClass:[NewLotteryWinnersCell class] forCellWithReuseIdentifier:CollectionViewCellID];
    }
    return _listView;
}

- (NSMutableArray *)dataArray
{
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

@end
