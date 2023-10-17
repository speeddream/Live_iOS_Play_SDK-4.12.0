//
//  HDSStreamLineAndQualityView.m
//  CCLiveCloud
//
//  Created by richard lee on 1/11/23.
//  Copyright © 2023 MacBook Pro. All rights reserved.
//

#import "HDSStreamLineAndQualityView.h"
#import "HDSStreamLiveAndQualityPublicCell.h"
#import "HDSSteamLineAndQualityModel.h"
#import "UIColor+RCColor.h"
#import "CCcommonDefine.h"
#import <Masonry/Masonry.h>

#define cellID @"HDSStreamLiveAndQualityPublicCell"

@interface HDSStreamLineAndQualityView ()<UICollectionViewDelegate,UICollectionViewDataSource>
/// 关闭按钮回调
@property (nonatomic, copy)  closeBtnTapBlock callBack;
/// 白色背景视图
@property (nonatomic, strong) UIView *BGView;
/// 顶部视图
@property (nonatomic, strong) UIView *headerView;
/// 关闭按钮
@property (nonatomic, strong) UIButton *closeBtn;
/// 简介提示语
@property (nonatomic, strong) UILabel *mainTitle;
/// 第一条分割线
@property (nonatomic, strong) UILabel *snipLine;

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) UIButton *topBtn;

@property (nonatomic, copy)   NSString *tabTitleName;

@property (nonatomic, strong) NSMutableArray *dataArray;

@property (nonatomic, assign) CGFloat itemW;

@property (nonatomic, assign) CGFloat itemH;

@end

@implementation HDSStreamLineAndQualityView


/// 初始化
/// - Parameters:
///   - frame: 布局
///   - tabTitle: 当前Tab标题
///   - btnTapClosure: 按钮的点击回调
- (instancetype)initWithFrame:(CGRect)frame tabTitle:(NSString *)tabTitle closeBtnTapClosure:(closeBtnTapBlock)closeBtnTapClosure {
    if (self = [super initWithFrame:frame]) {
        if (closeBtnTapClosure) {
            _callBack = closeBtnTapClosure;
        }
        self.backgroundColor = [UIColor colorWithHexString:@"#000000" alpha:0];
        self.tabTitleName = tabTitle;
        [self configureUI];
        [self configureConstraions];
        [self configureData];
    }
    return self;
}

/// 设置数据源
/// - Parameter dataSource: 数据源
- (void)setDataSource:(NSArray<HDSSteamLineAndQualityModel *> *)dataSource {
    
    [self.dataArray removeAllObjects];
    [self.dataArray addObjectsFromArray:dataSource];
    [self.collectionView reloadData];
    
    CGFloat collectionViewH = 83;
    if (self.dataArray.count % 4 == 0) {
        NSInteger row = self.dataArray.count / 4;
        if (row > 1) {
            collectionViewH = collectionViewH * row;
        }
    } else {
        NSInteger row = self.dataArray.count / 4;
        if (row >= 0) {
            collectionViewH = collectionViewH * (row + 1);
        }
    }
    
    if (dataSource.count <= 4) {
        self.itemW = SCREEN_WIDTH / dataSource.count;
        self.itemH = SCREEN_WIDTH / 375 * 83;
    } else {
        self.itemW = SCREEN_WIDTH / 4;
        self.itemH = SCREEN_WIDTH / 375 * 83;
    }
    
    [_collectionView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(collectionViewH);
    }];
}

// MARK: - Custom Method

- (void)configureUI {
    _topView = [[UIView alloc]init];
    [self addSubview:_topView];
    
    _topBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self addSubview:_topBtn];
    [_topBtn addTarget:self action:@selector(topBtnTapped) forControlEvents:UIControlEventTouchUpInside];
    
    _BGView = [[UIView alloc]init];
    _BGView.backgroundColor = [UIColor colorWithHexString:@"#FFFFFF" alpha:1];
    [self addSubview:_BGView];
    
    _headerView = [[UIView alloc]init];
    [_BGView addSubview:_headerView];
    
    _closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_closeBtn setImage:[UIImage imageNamed:@"popup_close"] forState:UIControlStateNormal];
    [_headerView addSubview:_closeBtn];
    [_closeBtn addTarget:self action:@selector(closeBtnTapAction:) forControlEvents:UIControlEventTouchUpInside];
    
    _mainTitle = [[UILabel alloc]init];
    _mainTitle.textColor = [UIColor colorWithHexString:@"#333333" alpha:1];
    _mainTitle.font = [UIFont systemFontOfSize:15];
    _mainTitle.textAlignment = NSTextAlignmentCenter;
    [_headerView addSubview:_mainTitle];
    
    _snipLine = [[UILabel alloc]init];
    _snipLine.backgroundColor = [UIColor colorWithHexString:@"#E8E9EB" alpha:1];
    [_headerView addSubview:_snipLine];
    
    
    [_BGView addSubview:self.collectionView];
}

- (void)configureConstraions {
    
    __weak typeof(self) weakSelf = self;
    CGFloat maxHeight = IS_IPHONE_X ? SCREEN_HEIGHT - 175 : SCREEN_HEIGHT - 141;
    [_topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(weakSelf);
        make.width.mas_equalTo(SCREEN_WIDTH);
        make.height.mas_lessThanOrEqualTo(maxHeight);
    }];
    
    [_topBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(weakSelf);
    }];
    
    [_BGView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.topView.mas_bottom);
        make.left.bottom.right.mas_equalTo(weakSelf);
        make.width.mas_equalTo(SCREEN_WIDTH);
    }];
    
    [_headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(_BGView);
        make.height.mas_equalTo(40);
    }];
    
    [_closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.headerView).offset(6);
        make.right.mas_equalTo(weakSelf.headerView).offset(-15);
        make.width.mas_equalTo(30);
        make.height.mas_equalTo(30);
    }];
    
    [_mainTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(weakSelf.headerView);
        make.top.mas_equalTo(weakSelf.headerView).offset(6);
        make.width.mas_equalTo(60);
        make.height.mas_equalTo(30);
    }];
    
    [_snipLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.closeBtn.mas_bottom).offset(6);
        make.left.right.mas_equalTo(weakSelf.headerView);
        make.height.mas_equalTo(0.5);
    }];
    
    [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.snipLine.mas_bottom);
        make.left.right.mas_equalTo(weakSelf.BGView);
        make.height.mas_equalTo(101);
    }];
}

- (void)configureData {
    _mainTitle.text = self.tabTitleName;
    self.itemW = SCREEN_WIDTH / 4;
    self.itemH = SCREEN_WIDTH / 375 * 83;
}

// MARK: - collection delegate & datasource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _dataArray.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    HDSStreamLiveAndQualityPublicCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[HDSStreamLiveAndQualityPublicCell alloc]init];
    }
    HDSSteamLineAndQualityModel *oneModel = self.dataArray[indexPath.row];
    BOOL isSelected = oneModel.selectedIndex == indexPath.row ? YES : NO;
    [cell setCellTitle:oneModel.title isSelected:isSelected];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    for (int i = 0; i < self.dataArray.count; i++) {
        HDSSteamLineAndQualityModel *oneModel = self.dataArray[i];
        oneModel.selectedIndex = indexPath.row;
        [self.dataArray replaceObjectAtIndex:i withObject:oneModel];
    }
    [self.collectionView reloadData];
    HDSSteamLineAndQualityModel *model = self.dataArray[indexPath.row];
    if (_changeActionBlock) {
        _changeActionBlock(model);
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(self.itemW, self.itemH);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

// MARK: - button Tap Event
- (void)closeBtnTapAction:(UIButton *)sender {
    if (_callBack) {
        _callBack();
    }
}

- (void)topBtnTapped {
    if (_callBack) {
        _callBack();
    }
}

// MARK: - LAZY
- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
        _collectionView = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.bounces = NO;
        [_collectionView registerClass:[HDSStreamLiveAndQualityPublicCell class] forCellWithReuseIdentifier:cellID];
    }
    return _collectionView;
}

@end
