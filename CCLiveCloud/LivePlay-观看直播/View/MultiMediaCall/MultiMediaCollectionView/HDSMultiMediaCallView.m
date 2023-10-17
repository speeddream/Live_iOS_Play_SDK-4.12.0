//
//  HDSMultiMediaCallView.m
//  CCLiveCloud
//
//  Created by Richard Lee on 8/27/21.
//  Copyright © 2021 MacBook Pro. All rights reserved.
//

#import "HDSMultiMediaCallView.h"
#import "HDSMultiMediaCallStreamModel.h"
#import "HDSMultiMediaStreamCell.h"
#import "HDSPortraitLayout.h"
#import "HDSLandscapeLayout.h"
#import "UIColor+RCColor.h"
#import <Masonry/Masonry.h>

@interface HDSMultiMediaCallView ()<UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView           *collectionView;
@property (nonatomic, strong) NSMutableArray             *dataArray;
@property (nonatomic, strong) UICollectionViewFlowLayout *layout;
@property (nonatomic, assign) BOOL                       isLandscape;
@end

@implementation HDSMultiMediaCallView

// MARK: - API
/// 初始化
/// @param frame 布局
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self customUI];
    }
    return self;
}

/// 移除流视图
/// @param stModel 流信息
/// @param isKillAll 是否移除所有
- (void)removeRemoteView:(HDSMultiMediaCallStreamModel * _Nullable)stModel isKillAll:(BOOL)isKillAll {
    if (isKillAll) {
        [_dataArray removeAllObjects];
        //NSLog(@"🔴⚪️🟡  dataArray removeAllObjects");
    }else {
        HDSMultiMediaCallStreamModel *tempModel = nil;
        for (int i = 0; i < self.dataArray.count; i++) {
            HDSMultiMediaCallStreamModel *model = self.dataArray[i];
            if ([stModel.userId isEqualToString:model.userId]) {
                tempModel = model;
                //NSLog(@"🔴⚪️🟡 - dataArray removeOne userID:%@",model.userId);
                break;
            }
        }
        if (tempModel != nil && self.dataArray.count > 0) {
            [self.dataArray removeObject:tempModel];
            //NSLog(@"🔴⚪️🟡 - collectionView reloadData");
        }
    }
    [self.collectionView reloadData];
    //NSLog(@"🔴⚪️🟡🟢  %s reloadData",__func__);
}

/// 设置数据源
/// @param dataSource 数据源
- (void)setDataSource:(NSArray *)dataSource isLandscape:(BOOL)isLandscape {
    //NSLog(@"🔴⚪️🟡🟢  %s --> %ld --> %ld",__func__,(long)dataSource.count,(long)self.dataArray.count);
    if (isLandscape != self.isLandscape) {
        if (isLandscape) {
            self.layout.scrollDirection = UICollectionViewScrollDirectionVertical;
            self.layout.minimumLineSpacing = 5;
            self.layout.minimumInteritemSpacing = 5;
            self.layout.sectionInset = UIEdgeInsetsMake(5,5,5,5);
        } else {
            self.layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
            self.layout.minimumLineSpacing = 0;
            self.layout.minimumInteritemSpacing = 0;
            self.layout.sectionInset = UIEdgeInsetsMake(0,0,0,0);
        }
        self.isLandscape = isLandscape;
    }
    [self.dataArray removeAllObjects];
    [self.dataArray addObjectsFromArray:dataSource];
    
    [self.collectionView reloadData];
}

// MARK: - Custom Method
- (void)customUI {
    
    self.layout = [[UICollectionViewFlowLayout alloc]init];
    //设置滚动方向为横向滚动
    self.layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    //设置单元格的大小
    self.layout.itemSize = CGSizeMake(124.5, 70);
    //设置item间距
    self.layout.minimumInteritemSpacing = 0;
    self.layout.minimumLineSpacing = 0;
    self.layout.sectionInset = UIEdgeInsetsMake(0,0,0,0);
    self.isLandscape = NO;
    _collectionView = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:self.layout];
    _collectionView.showsVerticalScrollIndicator = NO;
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.backgroundColor = [UIColor colorWithHexString:@"#41464C" alpha:1];
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.showsVerticalScrollIndicator = NO;
    if (@available(iOS 11.0, *)) {
        _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    [self addSubview:_collectionView];
    [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self);
    }];
    [_collectionView layoutIfNeeded];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _dataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *indentifier = [NSString stringWithFormat:@"%@%ld",@"HDSMultiMediaStreamCell",indexPath.row];
    [self.collectionView registerClass:[HDSMultiMediaStreamCell class] forCellWithReuseIdentifier:indentifier];
    HDSMultiMediaStreamCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:indentifier forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[HDSMultiMediaStreamCell alloc]initWithFrame:CGRectMake(0, 0, 124.5, 70)];
    }
    if (_dataArray.count > 0 && indexPath.row < _dataArray.count) {
        [cell setupDataWithModel:_dataArray[indexPath.row] row:indexPath.row];
    }
    return cell;
}

// MARK: - LAZY
- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

@end
