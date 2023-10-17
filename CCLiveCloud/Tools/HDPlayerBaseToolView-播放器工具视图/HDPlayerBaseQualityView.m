//
//  HDPlayerBaseQualityView.m
//  CCLiveCloud
//
//  Created by Apple on 2020/12/11.
//  Copyright © 2020 MacBook Pro. All rights reserved.
//

#import "HDPlayerBaseQualityView.h"
#import "HDPlayerBasePublicCell.h"
#import "HDPlayerBaseToolModel.h"
#import "HDPlayerBaseModel.h"
#import "CCSDK/PlayParameter.h"
#import "CCcommonDefine.h"

static NSString *cellID = @"cellID";

#define rowH 75
#define rowMargin 10    // 行间距
#define maxMargin 40   // 最大间距

@interface HDPlayerBaseQualityView ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) NSMutableArray    *dataArray;

@property (nonatomic, strong) UITableView       *qualityView;

@end

@implementation HDPlayerBaseQualityView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    _qualityView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
    _qualityView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _qualityView.delegate = self;
    _qualityView.dataSource = self;
    _qualityView.bounces = NO;
    _qualityView.showsVerticalScrollIndicator = NO;
    _qualityView.backgroundColor = [UIColor clearColor];
    _qualityView.rowHeight = rowH;
    _qualityView.hidden = YES;
    [self addSubview:_qualityView];
}

- (void)playerBaseQualityViewWithDataArray:(NSMutableArray *)qualityArray selectedQuality:(nonnull NSString *)selectedQuality {
    [self.dataArray removeAllObjects];
    if (selectedQuality.length == 0) {
        selectedQuality = @"0";
    }
    for (int i = 0; i < qualityArray.count; i++) {
        HDPlayerBaseToolModel *model = [[HDPlayerBaseToolModel alloc]init];
        HDQualityModel *qualityModel = qualityArray[i];
        model.keyDesc = qualityModel.desc;
        model.primaryKey = qualityModel.quality;
        model.isSelected = [model.primaryKey isEqualToString:selectedQuality] ? YES : NO;
        model.index = i;
        [self.dataArray addObject:model];
    }
    // 计算布局
    [self updateTableViewFrameWithQualityArrayCount:qualityArray.count];
}
/**
 *    @brief    根据数据条数计算列表布局
 *    @param    count   数据条数
 */
- (void)updateTableViewFrameWithQualityArrayCount:(NSInteger)count {
    CGFloat h = count * rowH + (count - 1) * rowMargin;
    CGFloat y = 0;
    CGFloat x = 0;
    CGFloat w = self.frame.size.width;
    if (h < SCREEN_HEIGHT) {
        if (h < rowH) {
            h = rowH;
        }
        y = (SCREEN_HEIGHT - h) / 2;
    }
    _qualityView.frame = CGRectMake(x,y,w,h);
    if (_qualityView.hidden == NO) {
        return;
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.35 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        _qualityView.hidden = NO;
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

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    /// [修460 Bug] 刘海屏横屏点原画，原画被遮挡
//    /// 38944
//    return 28;
//}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    HDPlayerBaseToolModel *nModel = self.dataArray[indexPath.section];
    HDPlayerBaseModel *model = [[HDPlayerBaseModel alloc]init];
    model.value = nModel.primaryKey;
    model.index = indexPath.section;
    model.func = HDPlayerBaseQuality;
    if (self.qulityBlock) {
        self.qulityBlock(model);
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
