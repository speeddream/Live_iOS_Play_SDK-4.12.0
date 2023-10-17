//
//  HDSLiveChatView.m
//  CCLiveCloud
//
//  Created by richard lee on 4/27/22.
//  Copyright © 2022 MacBook Pro. All rights reserved.
//

#import "HDSLiveChatView.h"
#import "HDSChatDataModel.h"
#import "HDSLiveChatCell.h"
#import "HDSLiveChatImageCell.h"
#import "HDSOccupyBitmapCell.h"
#import "HDSSafeArray.h"
#import "UIImage+Extension.h"
#import <Masonry/Masonry.h>

@interface HDSLiveChatView ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView       *tableView;
@property (nonatomic, strong) HDSSafeArray      *dataArray;
@property (nonatomic, strong) NSMutableArray    *originDataArray;

// 停止自动滚动
@property (nonatomic, assign) BOOL              isStopAutomaticScrolling;
@property (nonatomic, assign) BOOL              isNeedUpdateConstraints;

@property (nonatomic, strong) NSDictionary      *customEmojiDict;

@end

@implementation HDSLiveChatView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = UIColor.clearColor;
        [self.dataArray removeAllObjects];
        [self.originDataArray removeAllObjects];
        [self customUI];
        [self addObserver];
    }
    return self;
}

- (void)addObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadCustomEmoji:) name:@"kLoadCustomEmoji" object:nil];
}

- (void)loadCustomEmoji:(NSNotification *)noti {
    self.customEmojiDict = noti.userInfo;
    [self.tableView reloadData];
}

/// 接收到聊天数据
/// @param chatMsgs 聊天数据
- (void)receivedNewChatMsgs:(NSArray *)chatMsgs {
    __weak typeof(self) weakSelf = self;
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        // 1. 处理需要展示的聊天
        NSMutableArray *tempArr = [NSMutableArray array];
        for (HDSChatDataModel *oneModel in chatMsgs) {
            BOOL isHave = NO;
            for (HDSChatDataModel *model in weakSelf.dataArray) {
                if ([model.chatId isEqualToString:oneModel.chatId]) {
                    isHave = YES;
                }
            }
            // 1.1 过滤重复
            if (isHave == NO) {
                // 1.2 过滤已隐藏的聊天数据
                if (oneModel.status == 0 || oneModel.isMyself) {
                    if ([oneModel.msg hasPrefix:@"[img_"] && [oneModel.msg hasSuffix:@"]"]) {
                        NSString *url = [oneModel.msg stringByReplacingOccurrencesOfString:@"[img_" withString:@""];
                        // Todo: 2023.2.27 ? 需要做判断空校验
                        NSRange range = [url rangeOfString:@"?"];
                        url = [url substringToIndex:range.location];
                        if (url.length > 0) {
                            CGSize originSize =  [UIImage getImageSizeWithURL:url];
                            oneModel.imageSize = [weakSelf getCGSizeWithOriginImageSize:originSize];
                        }
                    }
                    [tempArr addObject:oneModel];
                }
            }
        }
        [weakSelf.dataArray addObjectsFromArray:tempArr];
        // 2. 处理原始数据源
        [weakSelf dealOriginDataSource:chatMsgs];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // 4. 刷新tableView;
            if (tempArr.count > 1) {
                [weakSelf.tableView reloadData];
            } else if (tempArr.count == 1) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:weakSelf.dataArray.count-1 inSection:0];
                [weakSelf.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
            [weakSelf.tableView layoutIfNeeded];
            // 5. 滚动tableView
            [weakSelf scrollPositionBottom];
            // 6. 告知数据源发生改变
            [weakSelf dataSourceDidChange];
        });
    });
}

/// 删除单条广播数据
/// @param dict 广播数据
- (void)deleteSingleBoardcast:(NSDictionary *)dict {
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSString *boardcastId = @"";
        if ([dict.allKeys containsObject:@"id"]) {
            boardcastId = dict[@"id"];
        }
        NSInteger action = 0;
        if ([dict.allKeys containsObject:@"action"]) {
            action = [dict[@"action"] integerValue];
        }
        if (boardcastId.length == 0 || action == 0) {
            return;
        }
        
        for (int i = 0; i < weakSelf.dataArray.count; i++) {
            HDSChatDataModel *oneModel = weakSelf.dataArray[i];
            if ([oneModel.boardCastId isEqualToString:boardcastId] && action == 1) {
                [weakSelf.dataArray removeObject:oneModel];
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSIndexPath *indPath = [NSIndexPath indexPathForRow:i inSection:0];
                    [weakSelf.tableView deleteRowsAtIndexPaths:@[indPath] withRowAnimation:UITableViewRowAnimationNone];
                    [weakSelf dataSourceDidChange];
                });
                break;
            }
        }
    });
}

/// 聊天管理
/// @param    manageDic
/// status    聊天消息的状态 0 显示 1 不显示
/// chatIds   聊天消息的id列列表
- (void)chatLogManage:(NSDictionary *)manageDic {
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSArray *chatIds = [NSArray array];
        if ([manageDic.allKeys containsObject:@"chatIds"]) {
            chatIds = manageDic[@"chatIds"];
        }
        NSInteger status = 0;
        if ([manageDic.allKeys containsObject:@"status"]) {
            status = [manageDic[@"status"] integerValue];
        }
        
        for (int i = 0; i < chatIds.count; i++) {
            NSString *chatId = chatIds[i];
        
            // 原始数据 Index
            int originIndex = [weakSelf getChatModelOriginIndexFromChatId:chatId];
        
            if (originIndex != -1) {
                // 原始数据
                HDSChatDataModel *originModel = [weakSelf.originDataArray objectAtIndex:originIndex];
                if (originModel.isMyself == YES) {
        
                    continue;
                }
        
    
                // 更新原始数据值
                originModel.status = status;
                [weakSelf.originDataArray replaceObjectAtIndex:originIndex withObject:originModel];
                if (originIndex > 0) {
                    if (originModel.status == 1) {
                        // 该消息要求删除
                        if (status == 1) {
                            [weakSelf deleteChatItemWithOriginModel:originModel];
                        }
                    } else {
                        
                        // 该消息需要添加
                        if (status == 0) {
                            int lastRealIndex = [weakSelf getLastRealIndexFromOriginIndex:originIndex];
                            HDSChatDataModel *lastRealModel = [weakSelf.originDataArray objectAtIndex:lastRealIndex];
                            
                            [weakSelf insertChatItemWithLastRealModel:lastRealModel originModel:originModel];
                        }
                    }
                } else {
                    if (originModel.status == 1) {
                        
                        [weakSelf deleteChatItemWithOriginModel:originModel];
                    } else {
                        
                        [weakSelf insertChatItemWithLastRealModel:originModel originModel:originModel];
                    }
                }
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [weakSelf.tableView reloadData];
            [weakSelf dataSourceDidChange];
        });
    });
}

/// 删除单个聊天
/// - Parameter dict: 聊天数据
- (void)deleteSingleChat:(NSDictionary *)dict {
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSString *viewerId = @"";
        if ([dict.allKeys containsObject:@"viewerId"]) {
            viewerId = dict[@"viewerId"];
        }
        
        for (int i = 0; i < weakSelf.dataArray.count; i++) {
            HDSChatDataModel *oneModel = weakSelf.dataArray[i];
            if ([oneModel.userId isEqualToString:viewerId]) {
                [weakSelf.dataArray removeObject:oneModel];
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSIndexPath *indPath = [NSIndexPath indexPathForRow:i inSection:0];
                    [weakSelf.tableView deleteRowsAtIndexPaths:@[indPath] withRowAnimation:UITableViewRowAnimationNone];
                    [weakSelf dataSourceDidChange];
                });
                break;
            }
        }
    });
}

// MARK: - Custom Method
- (void)customUI {
    [self addSubview:self.tableView];
    __weak typeof(self) weakSelf = self;
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.bottom.mas_equalTo(weakSelf);
    }];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // 当用户手指与设备屏幕接触并产生移动时为YES
    self.isStopAutomaticScrolling = scrollView.dragging;
}

- (void)scrollPositionBottom {
    if (self.isStopAutomaticScrolling == YES) {
        return;
    }
    NSInteger section = [self.tableView numberOfSections];  //有多少组
    if (section < 1) return;  //无数据时不执行 要不会crash
    NSInteger row = [self.tableView numberOfRowsInSection:section - 1]; //最后一组有多少行
    if (row < 1) return;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row - 1 inSection:section - 1];  //取最后一行数据
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];//滚动到最后一行
}

/// 处理原始数据源
/// - Parameter chatArr: 数据源（获取房间历史数据可能多次回调需要过滤房间历史数据）
- (void)dealOriginDataSource:(NSArray *)chatArr {
    for (HDSChatDataModel *oneModel in chatArr) {
        BOOL isHave = NO;
        for (HDSChatDataModel *originModel in self.originDataArray) {
            if ([originModel.chatId isEqualToString:oneModel.chatId]) {
                isHave = YES;
            }
        }
        if (isHave == NO) {
            
            [self.originDataArray addObject:oneModel];
        }
    }
}

/// 从原数据聊天数据中取出操作的聊天数据下标
/// - Parameter chatId: 聊天ID
- (int)getChatModelOriginIndexFromChatId:(NSString *)chatId {
    for (int i = 0; i < self.originDataArray.count; i++) {
        HDSChatDataModel *model = self.originDataArray[i];
        
        if ([model.chatId isEqualToString:chatId]) {
        
            return i;
        }
    }
    return -1;
}

/// 根据原数据数据下表找到上一条未隐藏的聊天下标
/// - Parameter originIndex: 原始数据下标
- (int)getLastRealIndexFromOriginIndex:(int)originIndex {
    if (originIndex == 0) return -1;
    
    for (int i = originIndex - 1; i >= 0; i--) {
        HDSChatDataModel *originModel = self.originDataArray[i];
    
        if (originModel.status == 0 || originModel.isMyself == YES) {
    
            return i;
        }
    }
    return -1;
}

/// 插入聊天数据
/// - Parameters:
///   - lastRealModel: 上一条未隐藏的聊天数据
///   - originModel: 操作的数据
- (void)insertChatItemWithLastRealModel:(HDSChatDataModel *)lastRealModel originModel:(HDSChatDataModel *)originModel {
    __weak typeof(self) weakSelf = self;
    BOOL isNeedInsertFirstIndex = YES;
    for (int i = 0; i < self.dataArray.count; i++) {
        HDSChatDataModel *oneModel = self.dataArray[i];
        
        // 重复不添加
        if ([oneModel.chatId isEqualToString:originModel.chatId]) {
        
            return;
        }
        
        if ([oneModel.chatId isEqualToString:lastRealModel.chatId]) {
        
            isNeedInsertFirstIndex = NO;
            [self.dataArray insertObject:originModel index:i+1];
        
            continue;
        }
    }
    // 需要插入到首位
    if (isNeedInsertFirstIndex == YES) {
        
        [self.dataArray insertObject:originModel index:0];
    }
}

/// 删除聊天数据
/// - Parameter originModel: 操作的聊天数据
- (void)deleteChatItemWithOriginModel:(HDSChatDataModel *)originModel {
    if (self.dataArray.count == 0) return;
    for (int i = 0; i < self.dataArray.count; i++) {
        HDSChatDataModel *oneModel = self.dataArray[i];
        if ([oneModel.chatId isEqualToString:originModel.chatId]) {

            [self.dataArray removeObject:oneModel];
            __weak typeof(self) weakSelf = self;
            dispatch_async(dispatch_get_main_queue(), ^{
                NSIndexPath *indPath = [NSIndexPath indexPathForRow:i inSection:0];
                [weakSelf.tableView deleteRowsAtIndexPaths:@[indPath] withRowAnimation:UITableViewRowAnimationNone];
                [weakSelf dataSourceDidChange];
            });
            break;
        }
    }
}

/// 数据源发生改变
- (void)dataSourceDidChange {
    [_tableView layoutIfNeeded];
    CGFloat chatViewH = _tableView.contentSize.height;
    if ([self.delegate respondsToSelector:@selector(liveChatDataDourceDidChangeTableViewH:)]) {
        [self.delegate liveChatDataDourceDidChangeTableViewH:chatViewH];
    }
}

// MARK: - TableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HDSChatDataModel *oneModel = self.dataArray[indexPath.row];
    if ([oneModel.roleType isEqualToString:@"占位图"]) {
        HDSOccupyBitmapCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HDSOccupyBitmapCell"];
        if (cell == nil) {
            cell = [[HDSOccupyBitmapCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"HDSOccupyBitmapCell"];
        }
        return cell;
    } else if ([oneModel.msg hasPrefix:@"[img_"] && [oneModel.msg hasSuffix:@"]"]) {
        NSString *cellId = [NSString stringWithFormat:@"HDSLiveChatImageCell_%ld",indexPath.row];
        HDSLiveChatImageCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
        if (cell == nil) {
            cell = [[HDSLiveChatImageCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        }
        [cell setImageModel:oneModel isInput:NO indexPath:indexPath];
        return cell;
    } else {
        HDSLiveChatCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HDSLiveChatCell"];
        if (cell == nil) {
            cell = [[HDSLiveChatCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"HDSLiveChatCell"];
        }
        cell.customEmojiDict = self.customEmojiDict;
        cell.model = oneModel;
        return cell;
    }
}

// MARK: - Lazy
- (UITableView *)tableView {
    if(!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.estimatedRowHeight = 88;
    }
    return _tableView;
}

- (HDSSafeArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [[HDSSafeArray alloc]init];
    }
    return _dataArray;
}

- (NSMutableArray *)originDataArray {
    if (!_originDataArray) {
        _originDataArray = [NSMutableArray array];
    }
    return _originDataArray;
}

- (CGSize)getCGSizeWithOriginImageSize:(CGSize)originImageSize {
    CGSize imageSize = originImageSize;
    //先判断图片的宽度和高度哪一个大
    if (originImageSize.width > originImageSize.height) {
        //以宽度为准，设置最大宽度
        if (imageSize.width > 219) {
            imageSize.height = 219 / imageSize.width * imageSize.height;
            imageSize.width = 219;
        }
    }else{
        //以高度为准，设置最大高度
        if (imageSize.height >= 219) {
            imageSize.width = 219 / imageSize.height * imageSize.width;
            imageSize.height = 219;
        }
    }
    return imageSize;
}

@end
