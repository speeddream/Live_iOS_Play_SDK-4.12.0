//
//  HDPlayerBaseRateView.m
//  CCLiveCloud
//
//  Created by Apple on 2020/12/11.
//  Copyright © 2020 MacBook Pro. All rights reserved.
//

#import "HDPlayerBaseRateView.h"
#import "HDPlayerBasePublicCell.h"
#import "HDPlayerBaseToolModel.h"
#import "HDPlayerBaseModel.h"
#import "UIView+Extension.h"

static NSString *cellID = @"cellID";

#define rowH 50
#define rowMargin 10    // 行间距
#define maxMargin 40   // 最大间距

@interface HDPlayerBaseRateView ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) NSMutableArray    *dataArray;

@property (nonatomic, strong) UITableView       *rateView;

@end

@implementation HDPlayerBaseRateView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    _rateView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
    _rateView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _rateView.delegate = self;
    _rateView.dataSource = self;
    _rateView.bounces = NO;
    _rateView.showsVerticalScrollIndicator = NO;
    _rateView.backgroundColor = [UIColor clearColor];
    _rateView.rowHeight = rowH;
    _rateView.hidden = YES;
    [self addSubview:_rateView];
}

- (void)playerBaseRateViewWithDataArray:(NSMutableArray *)rateArray selectedRate:(NSString *)selectedRate {
    [self.dataArray removeAllObjects];
    for (int i = 0; i < rateArray.count; i++) {
        HDPlayerBaseToolModel *model = [[HDPlayerBaseToolModel alloc]init];
        NSString *rate = rateArray[i];
        model.primaryKey = rate;
        model.keyDesc = rate;
        model.isSelected = [rate isEqualToString:selectedRate] ? YES : NO;
        model.index = i;
        [self.dataArray addObject:model];
    }
    [self updateTableViewFrameWithQualityArrayCount:self.dataArray.count];
}

/**
 *    @brief    根据数据条数计算列表布局
 *    @param    count   数据条数
 */
- (void)updateTableViewFrameWithQualityArrayCount:(NSInteger)count {
    CGFloat h = count * rowH + (count - 1) * rowMargin;
    if (h != _rateView.frame.size.height && h >= rowH) {
        //h = self.height - h < maxMargin ? self.height - h : h;
        h = h < maxMargin ? maxMargin : h;
        CGFloat y = (self.height - h) / 2;
        CGFloat x = 0;
        CGFloat w = self.width;
        _rateView.frame = CGRectMake(x,y,w,h);
    }
    [_rateView reloadData];
    if (_rateView.hidden == NO) {
        return;
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.35 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        _rateView.hidden = NO;
    });
}

#pragma mark - tableView Delegate & Datasouse
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _dataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HDPlayerBasePublicCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
       cell = [[HDPlayerBasePublicCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    cell.model = self.dataArray[indexPath.section];
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [[UIView alloc]init];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) return 0;
    return rowMargin;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    HDPlayerBaseToolModel *nModel = self.dataArray[indexPath.section];
    HDPlayerBaseModel *model = [[HDPlayerBaseModel alloc]init];
    model.value = nModel.primaryKey;
    model.index = indexPath.section;
    model.func = HDPlayerBaseRate;
    if (self.rateBlock) {
        self.rateBlock(model);
    }
}

- (NSMutableArray *)dataArray
{
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

@end
