//
//  HDSPreviewView.m
//  CCLiveCloud
//
//  Created by richard lee on 3/14/23.
//  Copyright © 2023 MacBook Pro. All rights reserved.
//

#import "HDSPreviewView.h"
#import <SDWebImage/SDWebImage.h>
#import "CCChatViewDataSourceManager.h"
#import "UIColor+RCColor.h"
#import "CCcommonDefine.h"
#import <Masonry/Masonry.h>

@interface HDSPreviewView()<UICollectionViewDelegate,UICollectionViewDataSource>
/// 数据源
@property (nonatomic, strong) NSMutableArray *dataArray;

@property (nonatomic, strong) NSMutableArray *networkIMGArray;
/// 已删除数组
@property (nonatomic, strong) NSMutableArray *deleteArray;
/// dismiss 回调
@property (nonatomic, copy) dissmissCallBack dismissCallBack;
/// 删除操作回调
@property (nonatomic, copy) deleteImageCallback deleteCallback;
/// 网络图片
@property (nonatomic, assign) BOOL networkIMG;
/// 当前下标
@property (nonatomic, assign) int currentIndex;
/// 允许删除
@property (nonatomic, assign) BOOL allowDelete;
/// 导航栏显示状体
@property (nonatomic, assign) BOOL navigationBarShow;

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) UIView *navigationBar;

@property (nonatomic, strong) UIButton *backBtn;

@property (nonatomic, strong) UILabel *indexLabel;

@property (nonatomic, strong) UIButton *deleteBtn;

@end

@implementation HDSPreviewView

/// 初始化
/// - Parameters:
///   - frame: 布局
///   - currentIndex 当前位置
///   - dataSource: 数据源
///   - dismissClosure: dissmiss 回调
- (instancetype)initWithFrame:(CGRect)frame
                 currentIndex:(int)currentIndex
                   dataSource:(NSArray <UIImage *>*)dataSource
               dismissClosure:(dissmissCallBack)dismissClosure {
    if (self = [super initWithFrame:frame]) {
        
        [self.dataArray removeAllObjects];
        [self.dataArray addObjectsFromArray:dataSource];
        [self.deleteArray removeAllObjects];
        
        self.currentIndex = currentIndex;
        if (dismissClosure) {
            _dismissCallBack = dismissClosure;
        }
        [self configureUI];
        [self configureConstraints];
        [self configureData];
    }
    return self;
}

/// 初始化(网络图片)
/// - Parameters:
///   - frame: 布局
///   - currentIndex 当前位置
///   - dataSource: 数据源
///   - dismissClosure: dissmiss 回调
- (instancetype)initWithFrame:(CGRect)frame
                 currentIndex:(int)currentIndex
         networkIMGdataSource:(NSArray <NSString *>*)dataSource
               dismissClosure:(dissmissCallBack)dismissClosure {
    if (self = [super initWithFrame:frame]) {
        
        [self.dataArray removeAllObjects];
        [self.dataArray addObjectsFromArray:dataSource];
        
        [self.networkIMGArray removeAllObjects];
        [self.networkIMGArray addObjectsFromArray:dataSource];
        
        self.currentIndex = currentIndex;
        self.networkIMG = YES;
        if (dismissClosure) {
            _dismissCallBack = dismissClosure;
        }
        [self configureUI];
        [self configureConstraints];
        [self configureData];
    }
    return self;
}

/// 初始化（支持删除）
/// - Parameters:
///   - frame: 布局
///   - currentIndex 当前位置
///   - dataSource: 数据源
///   - deleteClosure: 删除回调
///   - dismissClosure: dissmiss 回调
- (instancetype)initWithFrame:(CGRect)frame
                 currentIndex:(int)currentIndex
                   dataSource:(NSArray <UIImage *>*)dataSource
                deleteClosure:(deleteImageCallback)deleteClosure
               dismissClosure:(dissmissCallBack)dismissClosure {
    
    if (self = [super initWithFrame:frame]) {
        [self.dataArray removeAllObjects];
        [self.dataArray addObjectsFromArray:dataSource];
        self.currentIndex = currentIndex;
        self.allowDelete = YES;
        self.navigationBarShow = YES;
        if (dismissClosure) {
            _dismissCallBack = dismissClosure;
        }
        if (deleteClosure) {
            _deleteCallback = deleteClosure;
        }
        [self configureUI];
        [self configureConstraints];
        [self configureData];
    }
    return self;
}

// MARK: - Custom Method

- (void)configureUI {
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc]init];
    flowLayout.itemSize = CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT);
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    flowLayout.minimumLineSpacing = 0;
    flowLayout.minimumInteritemSpacing = 0;
    _collectionView = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:flowLayout];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.pagingEnabled = YES;
    _collectionView.showsVerticalScrollIndicator = NO;
    _collectionView.showsVerticalScrollIndicator = NO;
    [_collectionView registerClass:[HDSPreviewCell class] forCellWithReuseIdentifier:@"HDSPreviewCell"];
    [self addSubview:_collectionView];
    
    _navigationBar = [[UIView alloc]init];
    _navigationBar.backgroundColor = [UIColor colorWithHexString:@"#373B3E" alpha:1];
    [self addSubview:_navigationBar];
    
    _backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_backBtn setImage:[UIImage imageNamed:@"返回"] forState:UIControlStateNormal];
    [_navigationBar addSubview:_backBtn];
    [_backBtn addTarget:self action:@selector(backBtnTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    _indexLabel = [[UILabel alloc]init];
    _indexLabel.textColor = [UIColor colorWithHexString:@"#FFFFFF" alpha:1];
    _indexLabel.textAlignment = NSTextAlignmentCenter;
    _indexLabel.font = [UIFont systemFontOfSize:16];
    [_navigationBar addSubview:_indexLabel];
    
    if (self.allowDelete) {
        _deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_deleteBtn setImage:[UIImage imageNamed:@"删除"] forState:UIControlStateNormal];
        [_navigationBar addSubview:_deleteBtn];
        [_deleteBtn addTarget:self action:@selector(deleteBtnTapped:) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)configureConstraints {
    __weak typeof(self) weakSelf = self;
    [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(weakSelf);
    }];
    [_collectionView layoutIfNeeded];

    CGFloat navigationBarH = IS_IPHONE_X ? 88 : 64;
    [_navigationBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(weakSelf);
        make.height.mas_equalTo(navigationBarH);
    }];
    
    [_backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.mas_equalTo(weakSelf.navigationBar);
        make.width.height.mas_equalTo(44);
    }];
    
    if (self.allowDelete) {
        [_deleteBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.bottom.mas_equalTo(weakSelf.navigationBar);
            make.width.height.mas_equalTo(44);
        }];
    }
    
    [_indexLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(weakSelf.navigationBar);
        make.centerY.mas_equalTo(weakSelf.backBtn.mas_centerY);
    }];
    
    [self.collectionView reloadData];
}

- (void)configureData {
    
    [self updateIndexLabel];
    if (_currentIndex > 0 && _currentIndex < _dataArray.count) {
        __weak typeof(self) weakSelf = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:weakSelf.currentIndex inSection:0];
            [weakSelf.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
        });
    }
}

- (void)updateIndexLabel {
    
    int index = _currentIndex + 1;;
    if (_currentIndex >= (int)_dataArray.count && (int)_dataArray.count > 0) {
        index = (int)_dataArray.count;
        _currentIndex = index - 1;
    }
    
    NSString *indexStr = [NSString stringWithFormat:@"%d/%ld",index,_dataArray.count];
    _indexLabel.text = indexStr;
}

- (void)updateNavigationBarStatus {
    _navigationBarShow = !_navigationBarShow;
    _navigationBar.hidden = !_navigationBarShow;
}

// MARK: - CollectionView
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _dataArray.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    HDSPreviewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"HDSPreviewCell" forIndexPath:indexPath];
    if (_networkIMG) {
        [cell setImageUrl:self.networkIMGArray[indexPath.row]];
    } else {
        cell.image = self.dataArray[indexPath.row];
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self updateNavigationBarStatus];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    int index = scrollView.contentOffset.x / SCREEN_WIDTH;
    
    _currentIndex = index;
    
    [self updateIndexLabel];
}

// MARK: - Button Action
- (void)backBtnTapped:(UIButton *)sender {
    
    [self backBtnTap];
}

- (void)backBtnTap {
    if (_dismissCallBack) {
        _dismissCallBack();
    }
}

- (void)deleteBtnTapped:(UIButton *)sender {
    if (_currentIndex >= _dataArray.count) return;
    __weak typeof(self) weakSelf = self;
    UIImage *image = _dataArray[_currentIndex];
    [self.deleteArray addObject:image];
    [_collectionView performBatchUpdates:^{
        [weakSelf.dataArray removeObjectAtIndex:weakSelf.currentIndex];
        NSIndexPath *indexP = [NSIndexPath indexPathForRow:weakSelf.currentIndex inSection:0];
        [weakSelf.collectionView deleteItemsAtIndexPaths:@[indexP]];
    } completion:^(BOOL finished) {
        if (weakSelf.dataArray.count == 0) {
            [weakSelf backBtnTap];
        } else {
        
            [weakSelf updateIndexLabel];
        }
    }];
    if (_allowDelete && _deleteCallback) {
        _deleteCallback(self.deleteArray);
    }
}


// MARK: - LAZY
- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

- (NSMutableArray *)networkIMGArray {
    if (!_networkIMGArray) {
        _networkIMGArray = [NSMutableArray array];
    }
    return _networkIMGArray;
}

- (NSMutableArray *)deleteArray {
    if (!_deleteArray) {
        _deleteArray = [NSMutableArray array];
    }
    return _deleteArray;
}

@end

@interface HDSPreviewCell ()

@property (nonatomic, strong) UIImageView *imageView;

@end


@implementation HDSPreviewCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor colorWithHexString:@"#000000" alpha:1];
        [self configureUI];
    }
    return self;
}

- (void)setImage:(UIImage *)image {
    _image = image;
    _imageView.image = image;
}

- (void)setImageUrl:(NSString *)imageUrl {
    _imageUrl = imageUrl;
    [self downloadImage:_imageUrl index:0 imageView:_imageView];
}

- (void)configureUI {
    _imageView = [[UIImageView alloc]init];
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    _imageView.layer.masksToBounds = YES;
    [self.contentView addSubview:_imageView];
    __weak typeof(self) weakSelf = self;
    [_imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(weakSelf);
    }];
}

- (void)downloadImage:(NSString *)URL index:(int)index imageView:(UIImageView *)imageView {
    WS(ws)
    [imageView sd_setImageWithURL:[NSURL URLWithString:URL] placeholderImage:[UIImage imageNamed:@"picture_loading"] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        //判断是否已下载，if down return
        BOOL exist = [[CCChatViewDataSourceManager sharedManager] existImageWithUrl:URL];
        if (exist) {
            return;
        }
        if (error) {
            //加载失败,显示图片加载失败
            UIImage *errorImage = [UIImage imageNamed:@"picture_load_fail"];
            [[CCChatViewDataSourceManager sharedManager] setURL:URL withImageSize:errorImage.size];
            ws.imageView.image = errorImage;
            
        }else{
            //缓存图片信息
            [[CCChatViewDataSourceManager sharedManager] setURL:URL withImageSize:image.size];
            ws.imageView.image = image;
        }
    }];
}

- (void)dealloc {
    
}

@end
