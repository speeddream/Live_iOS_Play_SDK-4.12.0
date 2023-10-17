//
//  HDSAnimationManager.m
//  Example
//
//  Created by richard lee on 8/25/22.
//  Copyright © 2022 Jonathan Tribouharet. All rights reserved.
//

#import "HDSAnimationManager.h"
#import "HDSBaseAnimationView.h"
#import "HDSAnimationModel.h"

@interface HDSAnimationManager ()
/// 承载视图
@property (nonatomic, strong) UIView                *boardView;
/// 抽奖基础视图
@property (nonatomic, strong) HDSBaseAnimationView  *baseView;
/// 生成随机序号数组
@property (nonatomic, strong) NSMutableArray        *randomIndexArray;
/// 参与人员原始数据
@property (nonatomic, strong) NSMutableArray        *originArray;
/// 参与人员展示数组
@property (nonatomic, strong) NSMutableArray        *originImageArray;
/// 中奖人员原始数据
@property (nonatomic, strong) NSMutableArray        *highLightArray;
/// 包含中奖人员展示数组
@property (nonatomic, strong) NSMutableArray        *highLightImageArray;
/// 更多按钮点击回到
@property (nonatomic, copy)   btnsTapClosure        tapClosure;
/// 参与抽奖最大展示人数
@property (nonatomic, assign) NSInteger             maxUserCount;
/// 中奖最大展示人数
@property (nonatomic, assign) NSInteger             maxLotteryUserCount;
/// 中奖人数
@property (nonatomic, assign) NSInteger             lotteryUserCount;

@property (nonatomic, strong) HDSBaseAnimationModel *model;

@end

@implementation HDSAnimationManager

// MARK: - API
- (instancetype)initWithBoardView:(UIView *)boardView configure:(nonnull HDSBaseAnimationModel *)configure btnsTapClosure:(nonnull btnsTapClosure)tapClosure {
    if (self = [super init]) {
        NSLog(@"  %s",__func__);
        self.boardView = boardView;
        self.model = configure;
        if (tapClosure) {
            _tapClosure = tapClosure;
        }
        [self initBaseConfigure];
    }
    return self;
}

- (void)setNormalData:(NSArray *)normalDatas {
    NSLog(@"  %s",__func__);
    // 展示最大用户个数
    [self getMaxUserCount:normalDatas.count];
    
    [self.originArray removeAllObjects];
    [self.originArray addObjectsFromArray:normalDatas];
    [self prepareNormalData:normalDatas];
}

- (void)setHighLightData:(NSArray *)highLightDatas {
    NSLog(@"  %s",__func__);
    self.lotteryUserCount = highLightDatas.count;
    [self.highLightArray removeAllObjects];
    [self.highLightArray addObjectsFromArray:highLightDatas];
    [self prepareHighLightData:highLightDatas];
}

- (void)startAnimation {
    NSLog(@"  %s",__func__);
    if (_baseView == nil) {
        return;
    }
    [_baseView startAnimation];
}

- (void)stopAnimation {
    if (_baseView) {
        [_baseView stopAnimation];
    }
}

- (void)killAll {
    if (_baseView) {
        [_baseView removeFromSuperview];
        _baseView = nil;
    }
}

// MARK: - CustomMethods
/// 初始化基础配置项
- (void)initBaseConfigure {
    NSLog(@"  %s",__func__);
    // 1.生成随机下标数组
    [self.randomIndexArray removeAllObjects];
    self.randomIndexArray = [self getRandomIndexArray];
    
    // 2.分成5组
    NSMutableArray *column1 = [NSMutableArray array];
    NSMutableArray *column2 = [NSMutableArray array];
    NSMutableArray *column3 = [NSMutableArray array];
    NSMutableArray *column4 = [NSMutableArray array];
    NSMutableArray *column5 = [NSMutableArray array];
    
    // 3.生成默认数据
    for (int i = 0; i < 50; i++) {
        int index = [self getRandomNumber:0 to:3];
        HDSAnimationModel *oneModel = [[HDSAnimationModel alloc]init];
        oneModel.userName = @"";
        oneModel.userIconUrl = [NSString stringWithFormat:@"img_%d",index];
        
        if (i <= 9) {
            [column1 addObject:oneModel];
        } else if (i > 9 && i <= 19) {
            [column2 addObject:oneModel];
        } else if (i > 19 && i <= 29) {
            [column3 addObject:oneModel];
        } else if (i > 29 && i <= 39) {
            [column4 addObject:oneModel];
        } else  {
            [column5 addObject:oneModel];
        }
    }
    [self.originImageArray addObject:column1];
    [self.originImageArray addObject:column2];
    [self.originImageArray addObject:column3];
    [self.originImageArray addObject:column4];
    [self.originImageArray addObject:column5];
    
    [self.highLightImageArray addObject:column1];
    [self.highLightImageArray addObject:column2];
    [self.highLightImageArray addObject:column3];
    [self.highLightImageArray addObject:column4];
    [self.highLightImageArray addObject:column5];
    
    [self createAnimationView];
}

- (void)createAnimationView {
    NSLog(@"  %s",__func__);
    if (_baseView) {
        [_baseView removeFromSuperview];
        _baseView = nil;
    }
    __weak typeof(self) weakSelf = self;
    _baseView = [[HDSBaseAnimationView alloc]initWithFrame:self.boardView.bounds closure:^(NSInteger tag) {
        [weakSelf btnTapsWithTag:tag];
    } endAniBlock:^{
        if (weakSelf.endAnimationClosure) {
            weakSelf.endAnimationClosure();
        }
    }];
    [self.boardView addSubview:_baseView];
    _baseView.model = self.model;
}

- (void)prepareNormalData:(NSArray *)normalDatas {
    if (normalDatas.count == 0) {
        
        return;
    }
    
    for (int i = 0; i < self.randomIndexArray.count; i++) {
        // 1.超过最大用户展示个数结束循环
        if (i >= self.maxUserCount) {
            break;
        }
        // 2.获取随机数
        NSInteger result = [[self.randomIndexArray objectAtIndex:i] integerValue];
        // 3.对应列
        NSInteger column = result / 10;
        // 4.下标
        NSInteger index = result % 10;
        if (column < self.originImageArray.count) {
            // 5.取出原始图片数组
            NSMutableArray *tempArray = [self.originImageArray objectAtIndex:column];
            if (index < tempArray.count) {
                if (self.originArray.count == 0) {
                    break;
                }
                // 6.取出用户信息
                HDSAnimationModel *originModel = [self.originArray firstObject];
                // 7.生成新数据
                HDSAnimationModel *oneModel = [tempArray objectAtIndex:index];
                oneModel.userName = originModel.userName;
                oneModel.userIconUrl = originModel.userIconUrl;
                [tempArray replaceObjectAtIndex:index withObject:oneModel];
                // 8.删除已添加数据
                [self.originArray removeObjectAtIndex:0];
            }
        }
    }
    // 9.设置数据
    self.baseView.originDatas = self.originImageArray;
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.35 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSelf.baseView startAnimation];
    });
}

/// 准备中奖人数据
/// @param highLightDatas 中奖人数据
- (void)prepareHighLightData:(NSArray *)highLightDatas {
    
    for (int i = 0; i < self.randomIndexArray.count; i++) {
        // 1.中奖人数不超过5人
        if (highLightDatas.count <= 5 && i < 5) {
            // 1.1 取出每列数据
            NSMutableArray *tempArray = [self.highLightImageArray objectAtIndex:i];
            // 1.2 无人中奖
            if (highLightDatas.count == 0) {
                int index = [self getRandomNumber:0 to:3];
                HDSAnimationModel *oneModel = [[HDSAnimationModel alloc]init];
                oneModel.userIconUrl = [NSString stringWithFormat:@"img_%d",index];
                oneModel.userName = @"";
                // 1.3 替换第一个数据
                [tempArray replaceObjectAtIndex:0 withObject:oneModel];
                continue;
            }
            
            // 1.2 中奖者不足5人，插入随机图片
            if (i >= highLightDatas.count) {
                int index = [self getRandomNumber:0 to:3];
                HDSAnimationModel *oneModel = [[HDSAnimationModel alloc]init];
                oneModel.userIconUrl = [NSString stringWithFormat:@"img_%d",index];
                oneModel.userName = @"";
                // 1.3 替换第一个数据
                [tempArray replaceObjectAtIndex:0 withObject:oneModel];
                continue;
            }
            // 1.3 替换中奖者数据
            HDSAnimationModel *originModel = [self.highLightArray firstObject];
            HDSAnimationModel *oneModel = [[HDSAnimationModel alloc]init];
            oneModel.userIconUrl = originModel.userIconUrl;
            oneModel.userName = originModel.userName;
            // 1.4 替换第一个数据
            [tempArray replaceObjectAtIndex:0 withObject:oneModel];
            // 1.5 删除已添加数据
            [self.highLightArray removeObjectAtIndex:0];
            continue;
        }
    
        // 1.中奖人数超过5人
        if (i < 5 && highLightDatas.count > 5) {
            // 1.1 取出每列数据
            NSMutableArray *tempArray = [self.highLightImageArray objectAtIndex:i];
//            // 1.2 中奖者超过5人，第五列展示查看全部
//            if (i == 4) {
//                HDSAnimationModel *oneModel = [[HDSAnimationModel alloc]init];
//                oneModel.userIconUrl = @"查看全部";
//                oneModel.userName = @"";
//                // 1.3 替换第一个数据
//                [tempArray replaceObjectAtIndex:0 withObject:oneModel];
//                continue;
//            }
            // 1.3 替换中奖者数据
            HDSAnimationModel *originModel = [self.highLightArray firstObject];
            HDSAnimationModel *oneModel = [[HDSAnimationModel alloc]init];
            oneModel.userIconUrl = originModel.userIconUrl;
            oneModel.userName = originModel.userName;
            // 1.4 替换第一个数据
            [tempArray replaceObjectAtIndex:0 withObject:oneModel];
            // 1.5 删除已添加数据
            [self.highLightArray removeObjectAtIndex:0];
            continue;
        }
        
        // 2.获取随机数
        NSInteger result = [[self.randomIndexArray objectAtIndex:i] integerValue];
        // 3.对应列
        NSInteger column = result / 10;
        // 4.下标
        NSInteger index = result % 10;
        if (column < self.highLightImageArray.count) {
            // 5.取出原始图片数组
            NSMutableArray *tempArray = [self.highLightImageArray objectAtIndex:column];
            if (index < tempArray.count) {
                // 5.1 每列第一个数据展示中奖者，跳过
                if (index == 0) {
                    continue;
                }
                // 5.2 超出中奖者最大展示人数，结束循环
                if (i > self.maxLotteryUserCount) {
                    break;
                }
                // 5.3 取出用户信息
                HDSAnimationModel *originModel = [self.highLightArray firstObject];
                HDSAnimationModel *oneModel = [tempArray objectAtIndex:index];
                oneModel.userName = originModel.userName;
                oneModel.userIconUrl = originModel.userIconUrl;
                // 5.4 替换对应数据
                [tempArray replaceObjectAtIndex:index withObject:oneModel];
                // 5.5 删除已添加数据
                [self.highLightArray removeObjectAtIndex:0];
            }
        }
    }
    // 6.设置中奖者展示数据
    self.baseView.lotteryUserDatas = self.highLightImageArray;
    self.baseView.lotteryUserCount = self.lotteryUserCount;
    [self.baseView startAnimation];
}

// MARK: - TapEvent
- (void)btnTapsWithTag:(NSInteger)tag {
    NSLog(@"tag:%ld",__func__,tag);
    if (tag == 0) {
        [self killAll];
    }
    
    if (_tapClosure) {
        _tapClosure(tag);
    }
}

// MARK: - BaseTool
/// 生产随机不重复数组
- (NSMutableArray *)getRandomIndexArray {
    NSArray *temp = [NSArray arrayWithObjects:@"0",@"1", @"2", @"3", @"4", @"5",@"6",@"7",@"8",@"9",
                     @"10",@"11", @"12", @"13", @"14", @"15",@"16",@"17",@"18",@"19",
                     @"20",@"21", @"22", @"23", @"24", @"25",@"26",@"27",@"28",@"29",
                     @"30",@"31", @"32", @"33", @"34", @"35",@"36",@"37",@"38",@"39",
                     @"40",@"41", @"42", @"43", @"44", @"45",@"46",@"47",@"48",@"49",nil];
    NSMutableArray *tempArray = [[NSMutableArray alloc] initWithArray:temp];
    NSMutableArray *resultArray = [NSMutableArray array];
    for (int i = 0; i < temp.count; i ++) {
        int index = arc4random() % (temp.count - i);
        [resultArray addObject:[tempArray objectAtIndex:index]];
        [tempArray removeObjectAtIndex:index];
    }
    return resultArray;
}

/// 获取随机数
- (int)getRandomNumber:(int)from to:(int)to {
    return (int)(from + (arc4random() % (to - from + 1)));
}

/// 获取参与抽奖最大展示人数
/// @param count 参与人数
- (void)getMaxUserCount:(NSInteger)count {
    
    if (count > 25 && count <= 50) {
        self.maxUserCount = 40;
    } else if (count > 50 && count < 75) {
        self.maxUserCount = 30;
    } else if (count >= 75 && count < 100) {
        self.maxUserCount = 35;
    } else if (count >= 100) {
        self.maxUserCount = 40;
    } else {
        self.maxUserCount = count;
    }
}

/// 获取中奖最大展示人数
/// @param count 中奖人数
- (void)getMaxLotteryUserCount:(NSInteger)count {
    if (count > 10) {
        self.maxUserCount = 10;
    } else {
        self.maxUserCount = count;
    }
}

// MARK: - LAZY
- (NSMutableArray *)randomIndexArray {
    if (!_randomIndexArray) {
        _randomIndexArray = [NSMutableArray array];
    }
    return _randomIndexArray;
}

- (NSMutableArray *)originArray {
    if (!_originArray) {
        _originArray = [NSMutableArray array];
    }
    return _originArray;
}

- (NSMutableArray *)highLightArray {
    if (!_highLightArray) {
        _highLightArray = [NSMutableArray array];
    }
    return _highLightArray;
}

- (NSMutableArray *)originImageArray {
    if (!_originImageArray) {
        _originImageArray = [NSMutableArray array];
    }
    return _originImageArray;
}

- (NSMutableArray *)highLightImageArray {
    if (!_highLightImageArray) {
        _highLightImageArray = [NSMutableArray array];
    }
    return _highLightImageArray;
}

- (void)dealloc {
    NSLog(@"%s",__func__);
}

@end
