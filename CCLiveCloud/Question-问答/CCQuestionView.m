//
//  CCQuestionView.m
//  CCLiveCloud
//
//  Created by MacBook Pro on 2018/11/6.
//  Copyright © 2018 MacBook Pro. All rights reserved.
//

#import "CCQuestionView.h"
//#import "QuestionTextField.h"//问答输入框
#import "HDSCustomQuestionInputView.h"
#import "Dialogue.h"//数据模型
#import "UIImage+Extension.h"//image扩展
#import "InformationShowView.h"//提示视图
#import "UIImageView+WebCache.h"
#import "UIColor+RCColor.h"
#import "CCQuestionViewCell.h"//cell
#import <MJRefresh/MJRefresh.h>
#import "CCProxy.h"
#import "HDSPickToolView.h"
#import "HDSQuestionSelectImageCell.h"
#import "HDSQuestionAddImageItemCell.h"
#import "HDSPhotoActionSheetTool.h"
#import "HDSPreviewView.h"

#import "HDSQuestionCell.h"
#import "HDSAnswerCell.h"
#import "HDSQuestionFooterCell.h"

#import "HDSQuestionSelectImageModel.h"
#import <CCSDK/PlayParameter.h>
#import "UIView+Extension.h"
#import <Masonry/Masonry.h>

#define kSelectImageCellID @"HDSQuestionSelectImageCell"
#define kAddImageItemCellID @"HDSQuestionAddImageItemCell"

#define lowVersionDeviceLoadDataCount 20 // 低版本设备加载数据条数

@interface CCQuestionView()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,HDSCustomQuestionInputViewDelegate,UICollectionViewDelegate,UICollectionViewDataSource>

@property(nonatomic,strong)UITableView                  *questionTableView;//问答视图
//@property(nonatomic,strong)NSMutableArray               *tableArray;
@property(nonatomic,copy)  NSString                     *antename;//名称
@property(nonatomic,copy)  NSString                     *anteid;//id
@property(nonatomic,strong)UIButton                     *leftView;//左侧leftBtn

@property(nonatomic,strong)NSMutableDictionary          *QADic;//问答字典
@property(nonatomic,strong)NSMutableArray               *keysArrAll;//所有的答案数组

@property(nonatomic,strong)NSMutableDictionary          *newQADic;//新问答字典
@property(nonatomic,strong)NSMutableArray               *newKeysArr;//新答案数组

@property(nonatomic,copy)  QuestionBlock                block;//问答回调
@property(nonatomic,assign)BOOL                         input;//是否有输入框

@property(nonatomic,strong)UIView                       *imageView;//

@property(nonatomic,assign)int                          liveCurrentPage;// 直播当前问答分页
@property(nonatomic,assign)int                          replayCurrentPage;// 回放当前问答分页
@property(nonatomic,strong)NSMutableArray               *tempQuestionArray;// 问答临时数组
@property(nonatomic,assign)BOOL                         isDoneAllData; //是否加载完所有数据
@property(nonatomic,assign)BOOL                         isMyQuestion; //是否查看我的提问


/// 问答输入视图
@property (nonatomic, strong) HDSCustomQuestionInputView *questionInputView;
/// 问答输入视图高度
@property (nonatomic, assign) CGFloat inputViewH;
/// 提示背景视图
@property (nonatomic, strong) UIView *tipsBoardView;
/// 提示信息
@property (nonatomic, strong) UILabel *tipsLabel;
/// pick工具视图
@property (nonatomic, strong) HDSPickToolView *pickToolView;
/// 源图片数据
@property (nonatomic, strong) NSMutableArray *sourcesImages;
/// 上次选中图片数组
@property (nonatomic, strong) NSMutableArray <UIImage *>*lastSelectedImages;
@property (nonatomic, strong) NSMutableArray <PHAsset *>*lastSelectedAssets;
/// 图片展示区域
@property (nonatomic, strong) UICollectionView *selectImageCollectionView;
/// 底部安全区域试图
@property (nonatomic, strong) UIView *bottomSafeView;
/// 预览试图
@property (nonatomic, strong) HDSPreviewView *previewView;
/// 发送问答回调
@property (nonatomic, strong) kCommitQuestionBlock kCommitCallBack;
/// 提交的问答数据
@property (nonatomic, copy) NSString *finallyContent;
/// 提交的图片数据信息数组
@property (nonatomic, strong) NSMutableArray *finallyImageDataArray;
/// 是否正在上传
@property (nonatomic, assign) BOOL isUploading;

@end


@implementation CCQuestionView

-(instancetype)initWithQuestionBlock:(QuestionBlock)questionBlock input:(BOOL)input{
    self = [super init];
    if(self) {
        self.block      = questionBlock;
        self.input      = input;
        self.questionInputView.isEdit = YES;
        [self.newQADic removeAllObjects];
        [self.newKeysArr removeAllObjects];
        [self.lastSelectedAssets removeAllObjects];
        [self.lastSelectedImages removeAllObjects];
        [self.finallyImageDataArray removeAllObjects];
        [self.sourcesImages removeAllObjects];
        
        [self initUI];
        if(self.input) {
            [self addObserver];
        }
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame questionBlock:(kCommitQuestionBlock)questionClosure input:(BOOL)input {
    if (self = [super initWithFrame:frame]) {
        if (questionClosure) {
            _kCommitCallBack = questionClosure;
        }
        self.input      = input;
        self.questionInputView.isEdit = YES;
        [self.newQADic removeAllObjects];
        [self.newKeysArr removeAllObjects];
        [self.lastSelectedAssets removeAllObjects];
        [self.lastSelectedImages removeAllObjects];
        [self.finallyImageDataArray removeAllObjects];
        [self.sourcesImages removeAllObjects];
        
        [self initUI];
        if(self.input) {
            [self addObserver];
        }
    }
    return self;
}

- (void)setQaIcon:(BOOL)qaIcon {
    _qaIcon = qaIcon;
    _questionInputView.allowAddImage = _qaIcon;
}

-(NSMutableArray *)newKeysArr{
    if(!_newKeysArr) {
        _newKeysArr = [[NSMutableArray alloc] init];
    }
    return _newKeysArr;
}

-(NSMutableDictionary *)newQADic {
    if(!_newQADic) {
        _newQADic = [[NSMutableDictionary alloc] init];
    }
    return _newQADic;
}

- (NSMutableArray *)tempQuestionArray
{
    if (!_tempQuestionArray) {
        _tempQuestionArray = [NSMutableArray array];
    }
    return _tempQuestionArray;
}

- (NSMutableArray *)finallyImageDataArray {
    if (!_finallyImageDataArray) {
        _finallyImageDataArray = [NSMutableArray array];
    }
    return _finallyImageDataArray;
}

- (void)updateStatus {
    [self updateSelectImageViewConstraints];
}

/**
*    @brief    重载问答数据
*    @param QADic 问答字典
*    @param keysArrAll 回答Key数组
*    @param questionSourceType 问答数据来源
*    @param currentPage 当前分页 （查看历史问答时传当前分页，否则传0）
                        查看历史问答：QuestionSourceTypeFromLiveHistory 和 QuestionSourceTypeFromReplay
*    @param isDoneAllData 是否加载完所有数据 （查看历史问答时标记是否已加载全部问答，否则传YES）
*/
-(void)reloadQADic:(NSMutableDictionary *)QADic keysArrAll:(NSMutableArray *)keysArrAll questionSourceType:(QuestionSourceType)questionSourceType currentPage:(int)currentPage isDoneAllData:(BOOL)isDoneAllData {
    
    self.QADic = [QADic mutableCopy];
    self.keysArrAll = [keysArrAll mutableCopy];
    [self.newQADic removeAllObjects];
    int keysArrCount = (int)[self.keysArrAll count];
    // 直播模式
    if (questionSourceType == QuestionSourceTypeFromLive) {
        _liveCurrentPage = currentPage;
        [self.newKeysArr removeAllObjects];
        [self questionDataWithKeysArrCount:keysArrCount keysArr:self.keysArrAll questionSourceType:questionSourceType];
    }else if (questionSourceType == QuestionSourceTypeFromReplay) {
        _replayCurrentPage = currentPage;
        _isDoneAllData = isDoneAllData;
        [self.newKeysArr removeAllObjects];
        [self questionDataWithKeysArrCount:keysArrCount keysArr:self.keysArrAll questionSourceType:questionSourceType];
    }else {
        _liveCurrentPage = currentPage;
        _isDoneAllData = isDoneAllData;
        [self questionDataWithKeysArrCount:keysArrCount keysArr:self.keysArrAll questionSourceType:questionSourceType];
    }
}

/**
 *    @brief    初始化下拉刷新（直播查看历史问答）
 */
- (void)setupHeaderRefresh
{
    self.questionTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction: @selector(loadMoreHistoryData)];
    self.questionTableView.mj_header.hidden = YES;
}
/**
 *    @brief    下拉查看历史数据回调
 */
- (void)loadMoreHistoryData
{
    _liveCurrentPage++;
    if ([self.delegate respondsToSelector:@selector(livePlayLoadHistoryDataWithPage:)]) {
        [self.delegate livePlayLoadHistoryDataWithPage:_liveCurrentPage];
    }
}

/**
 *    @brief     初始化上拉加载更多（回放查看历史问答）
 */
- (void)setupFooterRefresh
{
    self.questionTableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
    self.questionTableView.mj_footer.hidden = YES;
}

/**
 *    @brief    上拉查看历史数据回调
 */
- (void)loadMoreData
{
    _replayCurrentPage++;
    if ([self.delegate respondsToSelector:@selector(replayLoadMoreDataWithPage:)]) {
        [self.delegate replayLoadMoreDataWithPage:_replayCurrentPage];
    }
}

/**
 *    @brief    解析问答数据
 *    @param keysArrCount 秘钥条数
 *    @param keysArr 问答秘钥数组
 *    @param questionSouceType 问答来源类型
 */
- (void)questionDataWithKeysArrCount:(int)keysArrCount keysArr:(NSMutableArray *)keysArr questionSourceType:(QuestionSourceType)questionSouceType
{
    dispatch_queue_t queue = dispatch_queue_create("Question", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{
        [self.tempQuestionArray removeAllObjects];
        for(int i = 0;i <keysArrCount ;i++) {
            // 取出秘钥
            NSString *encryptId = [keysArr objectAtIndex:i];
            // 取出对应的问答数组
            NSMutableArray *arr = [self.QADic objectForKey:encryptId];
            NSMutableArray *newArr = [[NSMutableArray alloc] init];
            for(int j = 0;j < [arr count];j++) {
                // 对应的数据模型
                Dialogue *dialogue = [arr objectAtIndex:j];
                if(j == 0 && ![newArr containsObject:dialogue]) {
                    if(dialogue.dataType == NS_CONTENT_TYPE_QA_QUESTION &&
                       ![self.tempQuestionArray containsObject:encryptId] &&
                       ([dialogue.fromuserid isEqualToString:dialogue.myViwerId] ||
                        dialogue.isPublish == YES)) {
                        //dialogue.cellHeight = [self heightForCellOfQuestion:arr];
                        // 查看我的问答
                        if(_isMyQuestion == YES) {
                            if([dialogue.fromuserid isEqualToString:dialogue.myViwerId]) {
                                [self.tempQuestionArray addObject:encryptId];
                                [newArr addObject:dialogue];
                                NSMutableDictionary *param = [NSMutableDictionary dictionary];
                                param[@"arr"] = newArr;
                                param[@"isOpen"] = @(NO);
                                [self.newQADic setObject:param forKey:encryptId];
                            }
                        } else { // 其他问答
                            [self.tempQuestionArray addObject:encryptId];
                            [newArr addObject:dialogue];
                            NSMutableDictionary *param = [NSMutableDictionary dictionary];
                            param[@"arr"] = newArr;
                            param[@"isOpen"] = @(NO);
                            [self.newQADic setObject:param forKey:encryptId];
                        }
                    }
                } else if(![newArr containsObject:dialogue] && [newArr count] > 0) {
                    Dialogue *firstDialogue = [arr objectAtIndex:0];
                    if((dialogue.isPrivate == 0 || (dialogue.isPrivate == 1 && [firstDialogue.fromuserid isEqualToString:dialogue.myViwerId])) && dialogue.dataType == NS_CONTENT_TYPE_QA_ANSWER) {
                        NSDictionary *param = [self.newQADic objectForKey:encryptId];
                        NSMutableArray *newArr = param[@"arr"];
                        if (newArr != nil) {
                            [newArr addObject:dialogue];
                        }
                    }
                }
            }
            if (i == keysArrCount-1) {
                if (questionSouceType == QuestionSourceTypeFromLiveHistory) { //查看直播历史问答
                    [self.newKeysArr removeAllObjects];
                    [self.newKeysArr addObjectsFromArray:self.tempQuestionArray];
                }else {
                    [self.newKeysArr addObjectsFromArray:self.tempQuestionArray];
                }
            }
        }
    });
        
    dispatch_barrier_sync(queue, ^{
        // 等数据处理完 再刷新
    });
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.questionTableView reloadData];
        if (questionSouceType == QuestionSourceTypeFromLive) {
            
            [self.questionTableView.mj_header endRefreshing];
            if (self.newKeysArr != nil && [self.newKeysArr count] != 0 ) {
                
                NSString *encryptId = [self.newKeysArr objectAtIndex:(self.newKeysArr.count-1)];
                NSDictionary *param = [self.newQADic objectForKey:encryptId];
                NSMutableArray *arr = param[@"arr"];
                NSInteger section = self.newKeysArr.count > 0 ? self.newKeysArr.count-1 : 0;
                NSInteger row = arr.count > 0 ? arr.count-1 : 0;
                BOOL isOpen = [param[@"isOpen"] boolValue];
                if (isOpen == NO && row > 4) {
                    /**
                     *  row 内容
                     *
                     *  0   问题
                     *  1   回复1
                     *  2   回复2
                     *  3   回复3
                     *  4   展开
                     */
                    row = 4;
                }
                NSIndexPath *indexPathLast = [NSIndexPath indexPathForItem:row inSection:section];
                [self.questionTableView scrollToRowAtIndexPath:indexPathLast atScrollPosition:UITableViewScrollPositionBottom animated:YES];
            } 
        }else if(questionSouceType == QuestionSourceTypeFromLiveHistory) {
            
            // 包含历史数据显示下拉加载更多
            if (self.questionTableView.mj_header.hidden == YES) {
                self.questionTableView.mj_header.hidden = NO;
            }
            
            [self.questionTableView.mj_header endRefreshing];
            // 下拉无缝加载
            NSInteger row = _newKeysArr.count - _liveCurrentPage * lowVersionDeviceLoadDataCount;
            if (row > 0 && _liveCurrentPage != 0) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
                [self.questionTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
            }
            // 加载完所有数据
            if (_isDoneAllData == YES) {
                self.questionTableView.mj_header.hidden = YES;
            }
        }else {
            self.questionTableView.mj_footer.hidden = self.newKeysArr.count > 0 ? NO : YES;
            [self.questionTableView.mj_footer endRefreshing];
            if (_isDoneAllData == YES) {
                [self.questionTableView.mj_footer endRefreshingWithNoMoreData];
            }else if (self.newKeysArr.count > 0 && self.newKeysArr.count < lowVersionDeviceLoadDataCount) {
                [self.questionTableView.mj_footer endRefreshingWithNoMoreData];
            }
        }
    });
}


- (void)dealloc {
    [self removeObserver];
}
/**
 *    @brief    初始化视图
 */
-(void)initUI {
    self.backgroundColor = [UIColor whiteColor];
    _liveCurrentPage = 0;   // 直播默认起始页码
    _replayCurrentPage = 0; // 回放默认起始页码
    _isDoneAllData = NO;    // 初始化加载更多 无数据显示
    _isMyQuestion = NO;     // 查看我的问答
    if(self.input) {
        //添加问答tableView
        __weak typeof(self) weakSelf = self;
        _inputViewH = 45;
        //todo 添加底部间距视图，collectionView 应该是固定高度91，不能加上底部安全区域
        _bottomSafeView = [[UIView alloc]init];
        _bottomSafeView.backgroundColor = [UIColor colorWithHexString:@"#FFFFFF" alpha:1];
        [self addSubview:_bottomSafeView];
        [_bottomSafeView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.mas_equalTo(weakSelf);
            make.height.mas_equalTo(TabbarSafeBottomMargin);
            make.bottom.mas_equalTo(weakSelf);
        }];
        
        [self addSubview:self.selectImageCollectionView];
        [_selectImageCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.mas_equalTo(weakSelf);
            make.bottom.mas_equalTo(weakSelf.bottomSafeView.mas_top);
            make.height.mas_equalTo(0);
        }];
        
        [self addSubview:self.questionInputView];
        [_questionInputView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(weakSelf.selectImageCollectionView.mas_top);
            make.left.right.mas_equalTo(weakSelf);
            make.height.mas_equalTo(weakSelf.inputViewH);
        }];
        
        [self addSubview:self.questionTableView];
        [self sendSubviewToBack:self.questionTableView];
        [_questionTableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.and.right.and.left.mas_equalTo(weakSelf);
            make.bottom.mas_equalTo(weakSelf.questionInputView.mas_top);
        }];
        
        _tipsBoardView = [[UIView alloc]init];
        _tipsBoardView.backgroundColor = [UIColor colorWithHexString:@"#000000" alpha:0.6];
        [self addSubview:_tipsBoardView];
        [_tipsBoardView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(weakSelf.questionInputView.centerX);
            make.bottom.mas_equalTo(weakSelf.questionInputView.mas_top).offset(-4.5);
            make.width.mas_greaterThanOrEqualTo(100);
            make.height.mas_equalTo(30);
        }];
        _tipsBoardView.layer.cornerRadius = 15.f;
        _tipsBoardView.layer.masksToBounds = YES;
        _tipsBoardView.hidden = YES;
        
        _tipsLabel = [[UILabel alloc]init];
        _tipsLabel.font = [UIFont systemFontOfSize:14];
        _tipsLabel.textColor = [UIColor colorWithHexString:@"#F9F9F9" alpha:1];
        _tipsLabel.textAlignment = NSTextAlignmentCenter;
        [_tipsBoardView addSubview:_tipsLabel];
        
        [_tipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.mas_equalTo(weakSelf.tipsBoardView);
            make.left.mas_equalTo(weakSelf.tipsBoardView).offset(15.5);
            make.right.mas_equalTo(weakSelf.tipsBoardView).offset(-14.5);
        }];
        
        [self setupHeaderRefresh];
    } else {//没有输入时
        //添加问答视图
        [self addSubview:self.questionTableView];
        [_questionTableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self);
        }];
        [self setupFooterRefresh];
    }
}

// MARK: - collectionView
- (UICollectionView *)selectImageCollectionView {
    if (!_selectImageCollectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc]init];
        flowLayout.itemSize = CGSizeMake(75.f, 75.f);
        flowLayout.sectionInset = UIEdgeInsetsMake(8, 8, 8, 0);
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _selectImageCollectionView = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        _selectImageCollectionView.delegate = self;
        _selectImageCollectionView.dataSource = self;
        _selectImageCollectionView.backgroundColor = [UIColor colorWithHexString:@"#FFFFFF" alpha:1];
        [_selectImageCollectionView registerClass:[HDSQuestionSelectImageCell class] forCellWithReuseIdentifier:kSelectImageCellID];
        [_selectImageCollectionView registerClass:[HDSQuestionAddImageItemCell class] forCellWithReuseIdentifier:kAddImageItemCellID];
    }
    return _selectImageCollectionView;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 2;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (section == 0) {
        return _sourcesImages.count;
    } else {
        _questionInputView.isAllAdded = _sourcesImages.count >= 6 ? YES : NO;
        return _sourcesImages.count == 6 ? 0 : 1;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        HDSQuestionSelectImageModel *imageModel = self.sourcesImages[indexPath.row];
        HDSQuestionSelectImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kSelectImageCellID forIndexPath:indexPath];
        __weak typeof(self) weakSelf = self;
        [cell sourceData:imageModel tipsBtnTapped:^(NSString * _Nonnull tipsString) {
            [weakSelf uploadFileErrorTip:tipsString];
        } deleteBtnTapped:^{
            [weakSelf deleteImageFile:(int)indexPath.row image:imageModel.image];
        }];
        cell.isUploading = _isUploading;
        return cell;
    } else {
        HDSQuestionAddImageItemCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kAddImageItemCellID forIndexPath:indexPath];
        cell.isEdit = _questionInputView.isEdit;
        return cell;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self.questionInputView.textView endEditing:YES];
    if (_isUploading == YES) {
        return;
    }
    if (indexPath.section == 0) {
        [self showPreviewViewWithIndex:(int)indexPath.row dataSource:self.lastSelectedImages hasDelete:YES];
    } else {
        [self showImagePickToolView];
    }
}

- (void)updateSelectImageViewConstraints {
    CGFloat collectionH = 0;
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    if (_sourcesImages.count > 0) {
        collectionH = 91;
        dict[@"status"] = @(YES);
    } else {
        dict[@"status"] = @(NO);
    }
    [_selectImageCollectionView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(collectionH);
    }];
    /// 4.9.0 new 更新直播互动按钮状态显隐
    [[NSNotificationCenter defaultCenter] postNotificationName:kLiveInteractionFuncSwitchStatusDidiChangeNotification object:nil userInfo:dict];
}

- (void)uploadFileErrorTip:(NSString *)tips {
    if (tips.length == 0) {
        return;
    }
    [self showTipsView:tips];
}

- (void)deleteImageFile:(int)row image:(UIImage *)image {
    __weak typeof(self) weakSelf = self;
    int index = -1;
    for (int i = 0; i < _sourcesImages.count; i++) {
        HDSQuestionSelectImageModel *oneModel = _sourcesImages[i];
        if (oneModel.image == image) {
            index = i;
        }
    }
    if (index == -1) return;
    [_selectImageCollectionView performBatchUpdates:^{
        [weakSelf.sourcesImages removeObjectAtIndex:index];
        [weakSelf.lastSelectedImages removeObjectAtIndex:index];
        [weakSelf.lastSelectedAssets removeObjectAtIndex:index];
        NSIndexPath *indexP = [NSIndexPath indexPathForRow:index inSection:0];
        [weakSelf.selectImageCollectionView deleteItemsAtIndexPaths:@[indexP]];
    } completion:^(BOOL finished) {
        
    }];
    if (_sourcesImages.count == 0) {
        [self updateSelectImageViewConstraints];
    }
}

// MARK: - PreviewView (预览视图)
- (void)showPreviewViewWithIndex:(int)index dataSource:(NSArray *)images hasDelete:(BOOL)hasDelete {
    if (_previewView) {
        [_previewView removeFromSuperview];
        _previewView = nil;
    }
    __weak typeof(self) weakSelf = self;
    if (hasDelete) {
        _previewView = [[HDSPreviewView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT) currentIndex:index dataSource:images deleteClosure:^(NSArray<UIImage *> * _Nonnull deleteImages) {
            [weakSelf deleteSelectImages:deleteImages];
        } dismissClosure:^{
            [weakSelf dismissPreview];
        }];
        [APPDelegate.window addSubview:_previewView];
    } else {
        _previewView = [[HDSPreviewView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT) currentIndex:index networkIMGdataSource:images dismissClosure:^{
            [weakSelf dismissPreview];
        }];
        [APPDelegate.window addSubview:_previewView];
    }
}

- (void)dismissPreview {
    if (_previewView) {
        [_previewView removeFromSuperview];
        _previewView = nil;
    }
}

- (void)deleteSelectImages:(NSArray <UIImage *>*)images {
    if (images.count == 0 || _lastSelectedImages.count == 0) return;
    for (UIImage *image in images) {
        for (int i = 0; i < _lastSelectedImages.count; i++) {
            UIImage *oneImage = _lastSelectedImages[i];
            if (oneImage == image) {
                [self deleteImageFile:i image:image];
            }
        }
    }
}

// MARK: - 问答输入框
- (HDSCustomQuestionInputView *)questionInputView {
    if (!_questionInputView) {
        __weak typeof(self) weakSelf = self;
        _questionInputView = [[HDSCustomQuestionInputView alloc]initWithFrame:CGRectZero btnsTappedClosure:^(int tag) {
            [weakSelf btnsTappedAction:tag];
        } updateInputViewHeight:^(CGFloat height) {
            [weakSelf updateInputViewHeight:height];
        } callBackMessage:^(NSString * _Nonnull message) {
            weakSelf.finallyContent = message;
            if (message.length == 0) {
                [weakSelf showTipsView:ALERT_EMPTYMESSAGE];
            }
        }];
        _questionInputView.delegate = self;
    }
    return _questionInputView;
}

/// 更新输入框高度
/// - Parameter height: 高度
- (void)updateInputViewHeight:(CGFloat)height {
    CGFloat kHeight = height + 10;
    _inputViewH = kHeight;
    [self.questionInputView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(kHeight);
    }];
    [self.questionInputView layoutIfNeeded];
}

/// 输入框提示信息代理
/// - Parameter tipString: 提示信息
- (void)onTipsCallBack:(NSString *)tipString {
    [self showTipsView:tipString];
}

// MARK: - 键盘通知
/// 添加键盘通知观察者
- (void)addObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(commitQAStateDidChange:)
                                                 name:kLiveQAStatusDidChangeNotification
                                               object:nil];
}

- (void)commitQAStateDidChange:(NSNotification *)noti {
    
    _questionInputView.isEdit = YES;
    _isUploading = NO;
    BOOL result = NO;
    if ([noti.userInfo.allKeys containsObject:@"result"]) {
        result = [noti.userInfo[@"result"] boolValue];
    }
    
    NSArray *failedArray = [NSArray array];
    if ([noti.userInfo.allKeys containsObject:@"failedArray"]) {
        failedArray = noti.userInfo[@"failedArray"];
    }
    
    NSArray *tempArr = [self.sourcesImages copy];
    for (int i = 0; i < tempArr.count; i++) {
        HDSQuestionSelectImageModel *oneModel = tempArr[i];
        for (int j = 0; j < failedArray.count; j++) {
            HDSUploadErrorModel *errorModel = failedArray[j];
            if (errorModel.order == oneModel.older && errorModel.code != 0) {
                oneModel.result = NO;
                oneModel.message = errorModel.message;
                [self.sourcesImages replaceObjectAtIndex:i withObject:oneModel];
            }
        }
    }
    /// 发布成功
    if (result == YES) {
        _questionInputView.isClean = YES;
        NSArray *tempArr = self.sourcesImages.copy;
        for (int i = 0; i < tempArr.count ; i++) {
            HDSQuestionSelectImageModel *model = tempArr[i];
            [self deleteImageFile:i image:model.image];
        }
    }
    [self.selectImageCollectionView reloadData];
}

/// 移除键盘通知观察者
- (void)removeObserver {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kLiveQAStatusDidChangeNotification object:nil];
}

/// 键盘将要展示
- (void)keyboardWillShow:(NSNotification *)notif {
    CGRect frame = [[[notif userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat questionViewH = frame.size.height - TabbarSafeBottomMargin;
    __weak typeof(self) weakSelf = self;
    //self.questionTableView.transform = CGAffineTransformIdentity;
    self.questionInputView.transform = CGAffineTransformIdentity;
    self.tipsBoardView.transform = CGAffineTransformIdentity;
    self.selectImageCollectionView.transform = CGAffineTransformIdentity;
    self.bottomSafeView.transform = CGAffineTransformIdentity;
    if (IS_IPHONE_6_OR_7) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"k4_7InchDeviceOffsetNotification" object:nil userInfo:@{@"isHidden":@"NO"}];
        questionViewH = questionViewH - 88;
    }
    [UIView animateWithDuration:0.45 animations:^{
        //weakSelf.questionTableView.transform = CGAffineTransformMakeTranslation(0, -questionViewH);
        weakSelf.questionInputView.transform = CGAffineTransformMakeTranslation(0, -questionViewH);
        weakSelf.tipsBoardView.transform = CGAffineTransformMakeTranslation(0, -questionViewH);
        weakSelf.selectImageCollectionView.transform = CGAffineTransformMakeTranslation(0, -questionViewH);
        weakSelf.bottomSafeView.transform = CGAffineTransformMakeTranslation(0, -questionViewH);
    } completion:^(BOOL finished) {
        
    }];
}

/// 键盘将要隐藏
- (void)keyboardWillHide:(NSNotification *)notif {
    __weak typeof(self) weakSelf = self;
    if (IS_IPHONE_6_OR_7) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"k4_7InchDeviceOffsetNotification" object:nil userInfo:@{@"isHidden":@"YES"}];
    }
    [UIView animateWithDuration:0.45 animations:^{
        //weakSelf.questionTableView.transform = CGAffineTransformIdentity;
        weakSelf.questionInputView.transform = CGAffineTransformIdentity;
        weakSelf.tipsBoardView.transform = CGAffineTransformIdentity;
        weakSelf.selectImageCollectionView.transform = CGAffineTransformIdentity;
        weakSelf.bottomSafeView.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        
    }];
}

// MARK: - 问答提示视图
/// 提示视图--现
/// - Parameter tips: 提示信息
- (void)showTipsView:(NSString *)tips {
    if (tips.length == 0) return;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hiddenTipsView) object:nil];
    self.tipsBoardView.hidden = NO;
    self.tipsLabel.text = tips;
    [self performSelector:@selector(hiddenTipsView) withObject:nil afterDelay:2];
}

/// 提示视图--隐
- (void)hiddenTipsView {
    self.tipsBoardView.hidden = YES;
}

// MARK: - Button Tapped Action
/// 按钮点击事件
/// - Parameter tag: 按钮标签 1001 查看我 1002 选择图片 1003 发送按钮
- (void)btnsTappedAction:(int)tag {
    if (tag == 1001) {
        // 是否查看我的问答
        _isMyQuestion = !_isMyQuestion;
        // 重载我的问答和所有问答
        [self reloadQADic:self.QADic keysArrAll:self.keysArrAll questionSourceType:QuestionSourceTypeFromLive currentPage:0 isDoneAllData:YES];
    } else if (tag == 1002) {
        [self showImagePickToolView];
    } else if (tag == 1003) {
        /// 发布问答
        [self commitQuestion];
    }
}

// MARK: - commit question
- (void)commitQuestion {
    _isUploading = YES;
    _questionInputView.isEdit = NO;
    [_selectImageCollectionView reloadData];
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self.finallyImageDataArray removeAllObjects];
        for (int i = 0; i < weakSelf.lastSelectedImages.count; i++) {
            NSMutableDictionary *tempDict = [NSMutableDictionary dictionary];
            UIImage *oneImage = weakSelf.lastSelectedImages[i];
            
            // 1.取出文件名
            NSString *fileName = @"";
            if (i > weakSelf.lastSelectedAssets.count) {
                fileName = [NSString stringWithFormat:@"%ld.png",(long)[[NSDate date] timeIntervalSince1970] * 1000];
            } else {
                PHAsset *oneAsset = weakSelf.lastSelectedAssets[i];
                fileName = [oneAsset valueForKey:@"_filename"];
                if (fileName.length == 0) {
                    fileName = [NSString stringWithFormat:@"%ld.png",(long)[[NSDate date] timeIntervalSince1970] * 1000];
                }
            }
            // 2.取出文件类型
            NSRange tRange = [fileName rangeOfString:@"."];
            NSString *name = [fileName substringToIndex:tRange.location];
            fileName = [NSString stringWithFormat:@"%@.png",name];
            tempDict[@"name"] = fileName;
            
            tempDict[@"type"] = @"png";
            // 3.取出文件大小
            NSData *oneImageData = [NSData dataWithData:UIImagePNGRepresentation(oneImage)];
            NSInteger oneIMGSize = oneImageData.length;
            tempDict[@"size"] = @(oneIMGSize);
            // 4.保存图片到tmp文件夹
            NSString *tmpDir = NSTemporaryDirectory();
            NSString *filePath = [NSString stringWithFormat:@"%@%@",tmpDir,fileName];
            [oneImageData writeToFile:filePath atomically:YES];
            tempDict[@"fullPath"] = filePath;
            // 5.序号
            tempDict[@"order"] = @(i);
            [weakSelf.finallyImageDataArray addObject:tempDict];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (weakSelf.kCommitCallBack) {
                weakSelf.kCommitCallBack(weakSelf.finallyContent, weakSelf.finallyImageDataArray);
            }
        });
    });
}

// MARK: - Image Pick Tool View
- (void)showImagePickToolView {
    if (_sourcesImages.count >= 6) {
        [self showTipsView:@"最多选择6张图片"];
        return;
    }
    if (_pickToolView) {
        [_pickToolView removeFromSuperview];
        _pickToolView = nil;
    }
    __weak typeof(self) weakSelf = self;
    int photoMaxCount = 6;
    if (_sourcesImages.count > 0) {
        photoMaxCount = 6 - (int)_sourcesImages.count;
    }
    photoMaxCount = photoMaxCount < 0 ? 0 : photoMaxCount;
    photoMaxCount = photoMaxCount > 6 ? 6 : photoMaxCount;
    // 允许选择同一张照片
    _pickToolView = [[HDSPickToolView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT) photoMaxCount:photoMaxCount closure:^(NSArray<UIImage *> * _Nullable images, NSArray<PHAsset *> * _Nonnull assets, BOOL isOriginal) {
        if (images.count > 0) {
            [weakSelf.selectImageCollectionView performBatchUpdates:^{
                [weakSelf.sourcesImages addObjectsFromArray:[weakSelf setImagesModel:images]];
                [weakSelf.lastSelectedImages addObjectsFromArray:images];
                [weakSelf.lastSelectedAssets addObjectsFromArray:assets];
                [weakSelf updateSelectImageViewConstraints];
            } completion:^(BOOL finished) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [weakSelf.selectImageCollectionView reloadData];
                });
            }];
        }
    }];
    
    // 不允许选择同一张照片
//    _pickToolView = [[HDSPickToolView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT) lastSelectAssets:self.lastSelectedAssets closure:^(NSArray<UIImage *> * _Nullable images, NSArray<PHAsset *> * _Nonnull assets, BOOL isOriginal) {
//        [weakSelf.sourcesImages addObjectsFromArray:images];
//        weakSelf.lastSelectedImages = images.mutableCopy;
//        weakSelf.lastSelectedAssets = assets.mutableCopy;
//    }];
    [APPDelegate.window addSubview:_pickToolView];
    [_pickToolView showPickToolView];
}

- (NSArray *)setImagesModel:(NSArray *)images {
    NSMutableArray *tempArr = [NSMutableArray array];
    int lastOrder = (int)_sourcesImages.count;
    for (int i = 0; i < images.count; i++) {
        UIImage *image = images[i];
        HDSQuestionSelectImageModel *oneModel = [[HDSQuestionSelectImageModel alloc]init];
        oneModel.image = image;
        oneModel.older = lastOrder+i;
        oneModel.message = @"";
        oneModel.result = YES;
        [tempArr addObject:oneModel];
    }
    return [tempArr copy];
}

- (NSMutableArray *)sourcesImages {
    if (!_sourcesImages) {
        _sourcesImages = [NSMutableArray array];
    }
    return _sourcesImages;
}

- (NSMutableArray<UIImage *> *)lastSelectedImages {
    if (!_lastSelectedImages) {
        _lastSelectedImages = [NSMutableArray array];
    }
    return _lastSelectedImages;
}

- (NSMutableArray<PHAsset *> *)lastSelectedAssets {
    if (!_lastSelectedAssets) {
        _lastSelectedAssets = [NSMutableArray array];
    }
    return _lastSelectedAssets;
}

// MARK: - TableView
/**
 *    @brief    问答tableView
 */
- (UITableView *)questionTableView {
    if(!_questionTableView) {
        _questionTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _questionTableView.backgroundColor = [UIColor colorWithHexString:@"#f5f5f5" alpha:1.0f];
        _questionTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _questionTableView.delegate = self;
        _questionTableView.dataSource = self;
        _questionTableView.showsVerticalScrollIndicator = NO;
        _questionTableView.estimatedRowHeight = 88;
        _questionTableView.estimatedSectionHeaderHeight = 0;
        _questionTableView.estimatedSectionFooterHeight = 0;
        if (@available(iOS 11.0, *)) {
            _questionTableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
    }
    return _questionTableView;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.newKeysArr count];
}

//返回行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSString *encryptId = [self.newKeysArr objectAtIndex:section];
    NSDictionary *param = [self.newQADic objectForKey:encryptId];
    NSMutableArray *arr = param[@"arr"];
    BOOL isOpen = NO;
    if ([param.allKeys containsObject:@"isOpen"]) {
        isOpen = [param[@"isOpen"] boolValue];
    }
    if (arr.count > 4) {
        // 未展开时最多展示5条
        NSInteger row = isOpen == YES ? arr.count + 1 : 5;
        return row;
    } else {
        return arr.count + 1;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self endEditing:YES];
}

// MARK: - 设置cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //解析数据
    NSString *encryptId = [self.newKeysArr objectAtIndex:indexPath.section];
    NSDictionary *param = [self.newQADic objectForKey:encryptId];
    NSMutableArray *arr = param[@"arr"];
    
    BOOL isOpen = NO;
    if ([param.allKeys containsObject:@"isOpen"]) {
        isOpen = [param[@"isOpen"] boolValue];
    }
    
    NSInteger otherCount = 0;
    
    NSInteger lastRow = -1;
    if (arr.count > 4) {
        // 未展开时最多展示5条
        lastRow = isOpen == YES ? arr.count : 4;
        otherCount = arr.count - 4;
    } else {
        lastRow = arr.count;
    }
    
    __weak typeof(self) weakSelf = self;
    if (indexPath.row == 0) {
        NSString *cellID = [NSString stringWithFormat:@"%@_%ld_%ld",@"HDSQuestionCell",indexPath.section,indexPath.row];
        HDSQuestionCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (cell == nil) {
            cell = [[HDSQuestionCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        }
        Dialogue *dialogue = [arr objectAtIndex:0];
        BOOL moreAnswer = arr.count > 1 ? YES : NO;
        [cell setDatasource:dialogue moreAnswer:moreAnswer btnsTapBlock:^(int index, NSArray * _Nonnull images) {
            [weakSelf showPreviewViewWithIndex:index dataSource:images hasDelete:NO];
        }];
        return cell;
    } else if (indexPath.row == lastRow) {
        
        NSString *cellID = [NSString stringWithFormat:@"%@_%ld_%ld",@"HDSQuestionFooterCell",indexPath.section,indexPath.row];
        HDSQuestionFooterCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (cell == nil) {
            cell = [[HDSQuestionFooterCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        }
        [cell setDataOpen:isOpen otherCount:(int)otherCount section:indexPath.section closure:^(BOOL isOpen, NSInteger section) {
            [param setValue:@(isOpen) forKey:@"isOpen"];
            [self.newQADic setValue:param forKey:encryptId];
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.questionTableView reloadData];
            });
        }];
        return cell;
        
    } else {
        NSString *cellID = [NSString stringWithFormat:@"%@_%ld_%ld",@"HDSAnswerCell",indexPath.section,indexPath.row];
        Dialogue *dialogue = [arr objectAtIndex:indexPath.row];
        HDSAnswerCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (cell == nil) {
            cell = [[HDSAnswerCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        }
        [cell setDatasource:dialogue btnsTapBlock:^(int index, NSArray * _Nonnull images) {
            [weakSelf showPreviewViewWithIndex:index dataSource:images hasDelete:NO];
        }];
        return cell;
    }
}

@end
