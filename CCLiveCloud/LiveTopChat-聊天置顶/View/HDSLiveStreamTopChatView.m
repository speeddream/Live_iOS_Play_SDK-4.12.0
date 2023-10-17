//
//  HDSLiveStreamTopChatView.m
//  CCLiveCloud
//
//  Created by richard lee on 1/11/23.
//  Copyright © 2023 MacBook Pro. All rights reserved.
//

#import "HDSLiveStreamTopChatView.h"
#import "HDSLiveStreamTopChatCell.h"
#import "HDSLiveStreamOtherTopChatCell.h"
#import "HDSLiveTopChatModel+BaseModel.h"
#import "UIColor+RCColor.h"
#import "CCcommonDefine.h"
#import <Masonry/Masonry.h>

#define cellID @"HDSLiveStreamTopChatCell"
#define otherCellID @"HDSLiveStreamOtherTopChatCell"

@interface HDSLiveStreamTopChatView ()<UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic, strong) UIImageView *BGIMGView;

@property (nonatomic, strong) UIImageView *rightBGIMGView;

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) NSMutableArray *mutDataArray;

@property (nonatomic, assign) CGFloat itemW;

@property (nonatomic, assign) CGFloat itemH;

@property (nonatomic, assign) HDSLiveStreamTopChatLayoutStyle layoutStyle;

@property (nonatomic, strong) UIButton *topBtn;

@property (nonatomic, strong) UILabel *numLabel;

@property (nonatomic, strong) UIButton *bottomBtn;

@property (nonatomic, strong) NSIndexPath *currentIndexPath;

@property (nonatomic, copy) btnTapEventBlock callBack;

@property (nonatomic, assign) BOOL  isOpen;

@property (nonatomic, strong) HDSLiveTopChatModel *baseModel;

@property (nonatomic, strong) NSDictionary *customEmojiDict;

@end

@implementation HDSLiveStreamTopChatView

- (instancetype)initWithFrame:(CGRect)frame layoutStyle:(HDSLiveStreamTopChatLayoutStyle)layoutStyle closure:(nonnull btnTapEventBlock)closure {
    if (self = [super initWithFrame:frame]) {
        if (closure) {
            _callBack = closure;
        }
        self.backgroundColor = [UIColor colorWithHexString:@"#000000" alpha:0];
        _layoutStyle = layoutStyle;
        if (_layoutStyle == HDSLiveStreamTopChatLayoutStyleLeftRight) {
            [self configureOtherUI];
            [self configureOtherConstraints];
        } else {
            [self configureUI];
            [self configureConstraints];
        }
        [self configureData];
        [self addObserver];
    }
    return self;
}

- (void)addObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadCustomEmoji:) name:@"kLoadCustomEmoji" object:nil];
}

- (void)loadCustomEmoji:(NSNotification *)noti {
    self.customEmojiDict = noti.userInfo;
    [self.collectionView reloadData];
}

- (void)setViewerId:(NSString *)viewerId {
    _viewerId = viewerId;
}

- (void)addItems:(NSArray *)items {
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(scollDown) object:nil];
    
    for (int i = 0; i < self.mutDataArray.count; i++) {
        NSMutableArray *tempArr = [self.mutDataArray[i] mutableCopy];
        for (int i = 0; i < items.count; i++) {
            HDSLiveTopChatModel *oneModel = items[i];
            [tempArr insertObject:oneModel atIndex:0];
        }
        [self.mutDataArray replaceObjectAtIndex:i withObject:tempArr];
    }
    [self.collectionView reloadData];
    
    if (_layoutStyle == HDSLiveStreamTopChatLayoutStyleTopBottom) {
        NSArray *temp = [self.mutDataArray firstObject];
        self.numLabel.text = [NSString stringWithFormat:@"1/%ld",(long)temp.count];
    }
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:1];
    self.currentIndexPath = indexPath;
    [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
    
    [self performSelector:@selector(scollDown) withObject:nil afterDelay:10];
}

- (void)deleteItemIdFromArray:(NSArray *)itemIdArray {
    if (self.mutDataArray.count == 0) {
        return;
    }
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(scollDown) object:nil];
    
    for (NSString *oneId in itemIdArray) {
        for (int i = 0; i < self.mutDataArray.count; i++) {
            NSArray *tempArray = self.mutDataArray[i];
            NSMutableArray *tempMutableArray = [NSMutableArray array];
            [tempMutableArray addObjectsFromArray:tempArray];
            for (HDSLiveTopChatModel *oneModel in tempArray) {
                if ([oneModel.id isEqualToString:oneId]) {
                    [tempMutableArray removeObject:oneModel];
                }
            }
            [self.mutDataArray replaceObjectAtIndex:i withObject:tempMutableArray];
        }
    }
    
    [self.collectionView reloadData];
    
    NSArray *temp = [self.mutDataArray firstObject];
    if (temp.count == 0) {
        return;
    }
    if (_layoutStyle == HDSLiveStreamTopChatLayoutStyleTopBottom) {
        self.numLabel.text = [NSString stringWithFormat:@"1/%ld",(long)temp.count];
    }
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:1];
    self.currentIndexPath = indexPath;
    [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
    
    [self performSelector:@selector(scollDown) withObject:nil afterDelay:10];
    
}

// MARK: - Custom Method

- (void)configureUI {
    
    _BGIMGView = [[UIImageView alloc]init];
    _BGIMGView.image = [UIImage imageNamed:@"置顶背景"];
    [self addSubview:_BGIMGView];
    
    _rightBGIMGView = [[UIImageView alloc]init];
    _rightBGIMGView.image = [UIImage imageNamed:@"右背景"];
    [self addSubview:_rightBGIMGView];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    _collectionView = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:layout];
    _collectionView.backgroundColor = [UIColor clearColor];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    _collectionView.showsVerticalScrollIndicator = NO;
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.bounces = NO;
    _collectionView.scrollEnabled = NO;
    _collectionView.pagingEnabled = YES;
    [_collectionView registerClass:[HDSLiveStreamTopChatCell class] forCellWithReuseIdentifier:cellID];
    [self addSubview:_collectionView];
    
    _topBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_topBtn setImage:[UIImage imageNamed:@"上翻"] forState:UIControlStateNormal];
    [self addSubview:_topBtn];
    [_topBtn addTarget:self action:@selector(topBtnTap:) forControlEvents:UIControlEventTouchUpInside];
    
    _numLabel = [[UILabel alloc]init];
    _numLabel.textColor = [UIColor colorWithHexString:@"#FFFFFF" alpha:1];
    _numLabel.layer.opacity = 0.6;
    _numLabel.font = [UIFont systemFontOfSize:12];
    _numLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_numLabel];
    
    _bottomBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_bottomBtn setImage:[UIImage imageNamed:@"下翻"] forState:UIControlStateNormal];
    [self addSubview:_bottomBtn];
    [_bottomBtn addTarget:self action:@selector(bottomBtnTap:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)configureConstraints {
    __weak typeof(self) weakSelf = self;
    CGFloat BGViewH = 83 * SCREEN_WIDTH / 375;
    [_BGIMGView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.mas_equalTo(weakSelf);
    }];
    
    CGFloat collectionViewW = 264 * SCREEN_WIDTH / 375;
    [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.mas_equalTo(weakSelf);
        make.width.mas_equalTo(collectionViewW);
        make.height.mas_equalTo(BGViewH);
    }];
    
    CGFloat rightBGIMGW = 36 * SCREEN_WIDTH / 375;
    [_rightBGIMGView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.BGIMGView.mas_top);
        make.right.mas_equalTo(weakSelf.BGIMGView.mas_right);
        make.width.mas_equalTo(rightBGIMGW);
        make.height.mas_equalTo(BGViewH);
    }];
    
    CGFloat btnH = 30 * SCREEN_WIDTH / 375;
    [_topBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.rightBGIMGView.mas_top);
        make.right.mas_equalTo(weakSelf.rightBGIMGView.mas_right);
        make.width.mas_equalTo(rightBGIMGW);
        make.height.mas_equalTo(btnH);
    }];
    
    [_bottomBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(weakSelf.rightBGIMGView.mas_bottom);
        make.right.mas_equalTo(weakSelf.rightBGIMGView.mas_right);
        make.width.mas_equalTo(rightBGIMGW);
        make.height.mas_equalTo(btnH);
    }];
    
    [_numLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.topBtn.mas_bottom);
        make.right.mas_equalTo(weakSelf.rightBGIMGView.mas_right).offset(-3);
        make.left.mas_equalTo(weakSelf.rightBGIMGView.mas_left).offset(3);
        make.bottom.mas_equalTo(weakSelf.bottomBtn.mas_top);
    }];
}

- (void)configureData {
    [self.mutDataArray removeAllObjects];
    for (int i = 0; i < 3; i++) {
        NSArray *oneArray = @[];
        [self.mutDataArray addObject:oneArray];
    }
    if (_layoutStyle == HDSLiveStreamTopChatLayoutStyleTopBottom) {
        self.itemW = 264 * SCREEN_WIDTH / 375;
        self.itemH = 83 * SCREEN_WIDTH / 375;
    } else {
        self.itemW = SCREEN_WIDTH - 60;
        self.itemH = 83 * SCREEN_WIDTH / 375;
    }
}

- (void)configureOtherUI {
        
    _topBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_topBtn setImage:[UIImage imageNamed:@"上一条"] forState:UIControlStateNormal];
    [self addSubview:_topBtn];
    [_topBtn addTarget:self action:@selector(topBtnTap:) forControlEvents:UIControlEventTouchUpInside];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    _collectionView = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:layout];
    _collectionView.backgroundColor = [UIColor clearColor];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    _collectionView.showsVerticalScrollIndicator = NO;
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.bounces = NO;
    _collectionView.scrollEnabled = NO;
    _collectionView.pagingEnabled = YES;
    [_collectionView registerClass:[HDSLiveStreamOtherTopChatCell class] forCellWithReuseIdentifier:otherCellID];
    [self addSubview:_collectionView];
    
    _bottomBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_bottomBtn setImage:[UIImage imageNamed:@"下一条"] forState:UIControlStateNormal];
    [self addSubview:_bottomBtn];
    [_bottomBtn addTarget:self action:@selector(bottomBtnTap:) forControlEvents:UIControlEventTouchUpInside];
    
}

- (void)configureOtherConstraints {
    
    __weak typeof(self) weakSelf = self;
    [_topBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf).offset(3);
        make.left.mas_equalTo(weakSelf);
        make.width.mas_equalTo(30);
        make.height.mas_equalTo(60);
    }];
    
    [_bottomBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf).offset(3);
        make.right.mas_equalTo(weakSelf);
        make.width.mas_equalTo(30);
        make.height.mas_equalTo(60);
    }];
    
    [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf).offset(0);
        make.left.mas_equalTo(weakSelf.topBtn.mas_right);
        make.bottom.mas_equalTo(weakSelf);
        make.right.mas_equalTo(weakSelf.bottomBtn.mas_left);
    }];
}

- (void)updateCollectionViewConstraints:(BOOL)isOpen {
    CGFloat collectionViewH = isOpen ? 156 : 83;
    collectionViewH = collectionViewH * SCREEN_WIDTH / 375;
    
    [_BGIMGView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(collectionViewH);
    }];
    
    [_collectionView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(collectionViewH);
    }];
    [_collectionView layoutIfNeeded];
}

- (void)scollUP {
    // 0.只有1条或者没有数据时不滚动
    NSArray *tempArray = [self.mutDataArray firstObject];
    if (tempArray.count == 0 || tempArray.count == 1) {
        return;
    }
    if (_baseModel.isOpen == YES) {
        _baseModel.isOpen = NO;
        self.itemH = 83 * SCREEN_WIDTH / 375;
        if (_layoutStyle == HDSLiveStreamTopChatLayoutStyleTopBottom) {
            [self updateCollectionViewConstraints:NO];
        }
        if (_callBack) {
            _callBack(NO);
        }
        [self.collectionView reloadData];
    }
    // 1.取出当前组
    NSInteger section = _currentIndexPath.section;
    // 2.取出当前行
    NSInteger row = _currentIndexPath.row;
    NSIndexPath *indexPath;
    if ((section == 0 || section == 2) && row == 0) {
        // 3.当前为第0组或者第2组，第0条数据数据时，滚动数据到第1组最后一条数据
        NSArray *tempArr = self.mutDataArray[1];
        NSInteger count = tempArr.count;
        count = count == 0 ? 0 : count-1;
        if (count == 0) return;
        indexPath = [NSIndexPath indexPathForRow:count inSection:1];
    } else if (section == 1 && row == 0) {
        // 3.当前为第1组的第0条数据数据时，滚动数据到第0组最后一条数据
        NSArray *tempArr = self.mutDataArray[0];
        NSInteger count = tempArr.count;
        count = count == 0 ? 0 : count-1;
        if (count == 0) return;
        indexPath = [NSIndexPath indexPathForRow:count inSection:0];
    } else {
        // 3.当前组还未滚动到第0条数据，接着向上滚动
        indexPath = [NSIndexPath indexPathForRow:row - 1 inSection:section];
    }
    self.numLabel.text = [NSString stringWithFormat:@"%ld/%ld",indexPath.row+1,tempArray.count];
    [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
    // 4.记录当前位置
    _currentIndexPath = indexPath;
    // 5.设置10秒的延时执行继续向下滚动
    [self performSelector:@selector(scollDown) withObject:nil afterDelay:10];
}

- (void)scollDown {
    // 0.只有1条或者没有数据时不滚动
    NSArray *tempArray = [self.mutDataArray firstObject];
    if (tempArray.count == 0 || tempArray.count == 1) {
        return;
    }
    if (_baseModel.isOpen == YES) {
        _baseModel.isOpen = NO;
        self.itemH = 83 * SCREEN_WIDTH / 375;
        if (_layoutStyle == HDSLiveStreamTopChatLayoutStyleTopBottom) {
            [self updateCollectionViewConstraints:NO];
        }
        if (_callBack) {
            _callBack(NO);
        }
        [self.collectionView reloadData];
    }
    // 1.取出当前组
    NSInteger section = _currentIndexPath.section;
    // 2.取出当前行
    NSInteger row = _currentIndexPath.row;
    // 3.取出当前组中有几条数据
    NSArray *currentArr = self.mutDataArray[section];
    NSInteger count = currentArr.count;
    // 4. 没有数据置
    count = count == 0 ? 0 : count - 1;
    if (count == 0) return;
    NSIndexPath *indexPath;
    if ((section == 0 || section == 2) && row == count) {
        // 5. 当为第0或者第2组时并且，当前行为本组最后一条数据，滚动到第1组第0条
        indexPath = [NSIndexPath indexPathForRow:0 inSection:1];
    } else if (section == 1 && row == count) {
        // 5.当前为第1组的最后一条数据数据时，滚动数据到第2组第一条数据
        indexPath = [NSIndexPath indexPathForRow:0 inSection:2];
    } else {
        // 5. 当往前组还未滚完，接着向下一个滚动
        indexPath = [NSIndexPath indexPathForRow:row + 1 inSection:section];
    }
    self.numLabel.text = [NSString stringWithFormat:@"%ld/%ld",indexPath.row+1,tempArray.count];
    [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
    // 6.记录当前滚动的位置
    _currentIndexPath = indexPath;
    // 7.设置10秒的延时执行继续向下滚动
    [self performSelector:@selector(scollDown) withObject:nil afterDelay:10];
}

// MARK: - button tap event
- (void)topBtnTap:(UIButton *)sender {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(scollDown) object:nil];
    NSArray *tempArray = [self.mutDataArray firstObject];
    if (tempArray.count == 0 || tempArray.count == 1) {
        return;
    }
    [self scollUP];
    if (_layoutStyle == HDSLiveStreamTopChatLayoutStyleTopBottom) {
        _rightBGIMGView.image = [UIImage imageNamed:@"右背景"];
    }
}

- (void)bottomBtnTap:(UIButton *)sender {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(scollDown) object:nil];
    NSArray *tempArray = [self.mutDataArray firstObject];
    if (tempArray.count == 0 || tempArray.count == 1) {
        return;
    }
    [self scollDown];
    if (_layoutStyle == HDSLiveStreamTopChatLayoutStyleTopBottom) {
        _rightBGIMGView.image = [UIImage imageNamed:@"右背景"];
    }
}

// MARK: - collection delegate & dataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return _mutDataArray.count;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSMutableArray *tempArr = _mutDataArray[section];
    return tempArr.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (_layoutStyle == HDSLiveStreamTopChatLayoutStyleLeftRight) {
        
        HDSLiveStreamOtherTopChatCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:otherCellID forIndexPath:indexPath];
        cell.customEmojiDict = self.customEmojiDict;
        NSArray *tempArr = self.mutDataArray[indexPath.section];
        cell.viewerId = self.viewerId;
        cell.totalNum = tempArr.count;
        cell.indexPath = indexPath;
        cell.model = tempArr[indexPath.row];
        __weak typeof(self) weakSelf = self;
        cell.callBack = ^(HDSLiveTopChatModel * _Nonnull tModel, BOOL isOpen, NSIndexPath * _Nonnull indPath) {
            [weakSelf userDidSelectedOneRowOpenBtn:isOpen indexPath:indPath model:tModel];
        };
        return cell;
        
    } else {
        
        HDSLiveStreamTopChatCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
        cell.customEmojiDict = self.customEmojiDict;
        NSArray *tempArr = self.mutDataArray[indexPath.section];
        cell.viewerId = self.viewerId;
        cell.model = tempArr[indexPath.row];
        cell.indexPath = indexPath;
        __weak typeof(self) weakSelf = self;
        cell.callBack = ^(HDSLiveTopChatModel * _Nonnull tModel, BOOL isOpen, NSIndexPath * _Nonnull indPath) {
            [weakSelf userDidSelectedOneRowOpenBtn:isOpen indexPath:indPath model:tModel];
        };
        return cell;
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

- (void)userDidSelectedOneRowOpenBtn:(BOOL)isOpen indexPath:(NSIndexPath *)indPath model:(HDSLiveTopChatModel *)model {
    
    if (_isOpen != isOpen) {
        if (isOpen == YES) {
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(scollDown) object:nil];
        } else {
            [self performSelector:@selector(scollDown) withObject:nil afterDelay:10];
        }
    }
    _baseModel = model;
    _isOpen = isOpen;
    self.itemH = isOpen == YES ? 156 * SCREEN_WIDTH / 375 : 83 * SCREEN_WIDTH / 375;
    [self.collectionView reloadData];
    if (_layoutStyle == HDSLiveStreamTopChatLayoutStyleTopBottom) {
        _rightBGIMGView.image = isOpen ? [UIImage imageNamed:@"右背景_开"] : [UIImage imageNamed:@"右背景"];
        [self updateCollectionViewConstraints:isOpen];
    }
    if (_callBack) {
        _callBack(isOpen);
    }
}


- (NSMutableArray *)mutDataArray {
    if (!_mutDataArray) {
        _mutDataArray = [NSMutableArray array];
    }
    return _mutDataArray;
}

@end
