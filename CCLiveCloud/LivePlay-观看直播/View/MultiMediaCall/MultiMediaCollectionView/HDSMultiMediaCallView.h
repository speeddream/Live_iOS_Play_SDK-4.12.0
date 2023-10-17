//
//  HDSMultiMediaCallView.h
//  CCLiveCloud
//
//  Created by Richard Lee on 8/27/21.
//  Copyright © 2021 MacBook Pro. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class HDSMultiMediaCallStreamModel;

@interface HDSMultiMediaCallView : UIView

/// 设置数据源
/// @param dataSource 数据源
- (void)setDataSource:(NSArray *)dataSource isLandscape:(BOOL)isLandscape;

/// 移除流视图
/// @param stModel 流信息
/// @param isKillAll 是否移除所有
- (void)removeRemoteView:(HDSMultiMediaCallStreamModel * _Nullable )stModel isKillAll:(BOOL)isKillAll;

@end

NS_ASSUME_NONNULL_END
