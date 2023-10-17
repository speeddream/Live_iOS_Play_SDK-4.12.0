//
//  HDSLiveStreamRemindView.m
//  HDSTestDemo
//
//  Created by richard lee on 1/5/23.
//

#import "HDSLiveStreamRemindView.h"
#import "HDSLiveStreamRemindCell.h"
#import "HDSSafeArray.h"
#import <Masonry/Masonry.h>

#define tableViewCellID @"HDSLiveStreamRemindCell"

@interface HDSLiveStreamRemindView ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) HDSSafeArray *dataArray;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, copy) remindViewCheckBlock callBackBlock;

@end

@implementation HDSLiveStreamRemindView

// MARK: - API
- (instancetype)initWithFrame:(CGRect)frame checkBlock:(remindViewCheckBlock)closure {
    if (self = [super initWithFrame:frame]) {
        if (closure) {
            _callBackBlock = closure;
        }
        [self.dataArray removeAllObjects];
        [self customUI];
        [self customConstraints];
    }
    return self;
}

- (void)setDataSource:(NSString *)dataSource {
    if (self.tableView.hidden == YES) {
        // 如果tableView隐藏，取消隐藏
        self.tableView.hidden = NO;
    } else {
        // 新的数据源取消隐藏tableView3秒延迟操作
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hiddenTableView) object:nil];
    }
    // 设置数据源
    [self.dataArray addObject:dataSource];
    // 刷新tableView
    [self.tableView reloadData];
    // 5.设置滚动位置
    NSIndexPath *scrollIndex = [NSIndexPath indexPathForRow:self.dataArray.count-1 inSection:0];
    // 6.滚动到指定位置
    [self.tableView scrollToRowAtIndexPath:scrollIndex atScrollPosition:UITableViewScrollPositionNone animated:YES];
    // 设置tableView3秒延迟操作
    [self performSelector:@selector(callBack) withObject:nil afterDelay:1];
    [self performSelector:@selector(hiddenTableView) withObject:nil afterDelay:3];
}

// MARK: - Custom Method
- (void)customUI {
    _tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView.backgroundColor = UIColor.clearColor;
    _tableView.userInteractionEnabled = NO;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.showsHorizontalScrollIndicator = NO;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [_tableView registerClass:[HDSLiveStreamRemindCell class] forCellReuseIdentifier:tableViewCellID];
    [self addSubview:_tableView];
}

- (void)customConstraints {
    __weak typeof(self) weakSelf = self;
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(weakSelf);
    }];
    [_tableView layoutIfNeeded];
}

- (void)hiddenTableView {
    self.tableView.hidden = YES;
    [self.dataArray removeAllObjects];
}

- (void)callBack {
    if (_callBackBlock) {
        _callBackBlock();
    }
}

// MARK: - TableView Delegat & Datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(HDSLiveStreamRemindCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [cell showRemindInfomation:self.dataArray[indexPath.row]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HDSLiveStreamRemindCell *cell = [tableView dequeueReusableCellWithIdentifier:tableViewCellID];
    if (cell == nil) {
        cell = [[HDSLiveStreamRemindCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:tableViewCellID];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 58;
}

// MARK: - Lazy
- (HDSSafeArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [[HDSSafeArray alloc]init];
    }
    return _dataArray;
}


@end
