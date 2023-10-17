//
//  HDSStreamLineAndQualityView.h
//  CCLiveCloud
//
//  Created by richard lee on 1/11/23.
//  Copyright © 2023 MacBook Pro. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HDSSteamLineAndQualityModel;
NS_ASSUME_NONNULL_BEGIN

typedef void (^closeBtnTapBlock)(void);

typedef void (^changeActionBlock)(HDSSteamLineAndQualityModel *model);

@interface HDSStreamLineAndQualityView : UIView
/// 顶部透明视图
@property (nonatomic, strong) UIView *topView;

@property (nonatomic, strong) changeActionBlock changeActionBlock;
 
/// 初始化
/// - Parameters:
///   - frame: 布局
///   - tabTitle: 当前Tab标题
///   - btnTapClosure: 按钮的点击回调
- (instancetype)initWithFrame:(CGRect)frame tabTitle:(NSString *)tabTitle closeBtnTapClosure:(closeBtnTapBlock)closeBtnTapClosure;

/// 设置数据源
/// - Parameter dataSource: 数据源
- (void)setDataSource:(NSArray <HDSSteamLineAndQualityModel *>*)dataSource;

@end

NS_ASSUME_NONNULL_END
