//
//  HDSCallBarFunctionView.h
//  CCLiveCloud
//
//  Created by Richard Lee on 8/28/21.
//  Copyright © 2021 MacBook Pro. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class HDSCallBarFunctionModel;

typedef void(^functionViewBtnClickClosure) (NSInteger tag, HDSCallBarFunctionModel *model);

@interface HDSCallBarFunctionView : UIView

/// 初始化
/// @param frame 布局
/// @param model 配置项
/// @param closure 回调
- (instancetype)initWithFrame:(CGRect)frame model:(HDSCallBarFunctionModel *)model closure:(functionViewBtnClickClosure)closure;

/// 更新连麦类型
/// @param model 配置项
- (void)updateCallBarTypeWithModel:(HDSCallBarFunctionModel *)model;

@end

NS_ASSUME_NONNULL_END
