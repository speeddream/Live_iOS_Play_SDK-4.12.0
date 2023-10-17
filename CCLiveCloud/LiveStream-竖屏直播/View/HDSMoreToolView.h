//
//  HDSMoreToolView.h
//  CCLiveCloud
//
//  Created by richard lee on 1/9/23.
//  Copyright © 2023 MacBook Pro. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HDSMoreToolItemModel;
NS_ASSUME_NONNULL_BEGIN

typedef void (^moreBtnTapBlock)(NSString *itemName);
typedef void (^closeBtnBlock)(void);

@interface HDSMoreToolView : UIView

@property (nonatomic, copy) closeBtnBlock closeClosure;
/// 顶部透明视图
@property (nonatomic, strong) UIView *topView;
/// 初始化
/// - Parameters:
///   - frame: 布局
///   - tabTitle: 当前Tab标题
///   - btnTapClosure: 按钮的点击回调
- (instancetype)initWithFrame:(CGRect)frame tabTitle:(NSString *)tabTitle btnTapClosure:(moreBtnTapBlock)btnTapClosure;

/// 设置数据源
/// - Parameter dataSource: 数据源
- (void)setDataSource:(NSArray <HDSMoreToolItemModel *>*)dataSource;

@end

NS_ASSUME_NONNULL_END
