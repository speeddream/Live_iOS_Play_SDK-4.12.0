//
//  HDSMultiMediaBoardView.h
//  CCLiveCloud
//
//  Created by Richard Lee on 8/30/21.
//  Copyright © 2021 MacBook Pro. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class HDSMultiBoardViewActionModel;
@class HDSMultiMediaCallStreamModel;

typedef void (^multiBoardViewClosure)(HDSMultiBoardViewActionModel *model);

@interface HDSMultiMediaBoardView : UIView

/// 初始化
/// @param frame 布局
/// @param btnActionClosure 回调（横屏 toolBar 按钮回调）
- (instancetype)initWithFrame:(CGRect)frame closure:(multiBoardViewClosure)btnActionClosure;

/// 设置横屏 toolBar
/// @param model 数据
//- (void)setupLandscapeToolBarStatus:(HDSMultiBoardViewActionModel *)model;

/// 更新数据
/// @param dataArray 数据源
- (void)setDataSource:(NSArray *)dataArray isLandscape:(BOOL)isLandscape;

/// 移除流视图
/// @param stModel 流信息
/// @param isKillAll 是否移除所有
- (void)removeRemoteView:(HDSMultiMediaCallStreamModel * _Nullable )stModel isKillAll:(BOOL)isKillAll;

@end

NS_ASSUME_NONNULL_END
