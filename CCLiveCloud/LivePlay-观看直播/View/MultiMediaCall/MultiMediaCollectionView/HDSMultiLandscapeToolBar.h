//
//  HDSMultiLandscapeToolBar.h
//  CCLiveCloud
//
//  Created by Richard Lee on 8/31/21.
//  Copyright © 2021 MacBook Pro. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class HDSMultiBoardViewActionModel;

typedef void(^landscapeToolBarBtnClickClosure) (HDSMultiBoardViewActionModel *model);

@interface HDSMultiLandscapeToolBar : UIView

/// 初始化 toolBar 工具栏
/// @param frame 布局
/// @param isAudioVideo 是否音视频
/// @param model 数据
/// @param closure 回调
- (instancetype)initWithFrame:(CGRect)frame
                 isAudioVideo:(BOOL)isAudioVideo
                        model:(HDSMultiBoardViewActionModel *)model
                      closure:(landscapeToolBarBtnClickClosure)closure;


/// 更新 toolBar 工具栏状态
/// @param isAudioVideo 是否音视频
/// @param model 数据
- (void)updateToolBarBtnStatus:(BOOL)isAudioVideo model:(HDSMultiBoardViewActionModel *)model;

@end

NS_ASSUME_NONNULL_END
