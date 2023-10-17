//
//  RLLikeButton.h
//  ExampleDemo
//
//  Created by richard lee on 2/17/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class RLLikeConfiguration;

typedef void(^touchAction)(int touchCount);

@interface RLLikeButton : UIButton

/// 示例化
/// @param frame 布局
/// @param configuration 配置项
/// @param closure 点击回调
- (instancetype)initWithFrame:(CGRect)frame
                configuration:(RLLikeConfiguration *)configuration
                      closure:(touchAction)closure;

/// 是否在动画中
- (BOOL)getIsAnimation;

/// 单个动画
- (void)singleAnimation;

/// 开始组动画
- (void)startGroupAnimation;

/// 停止组动画
- (void)stopGroupAnimation;

@end

NS_ASSUME_NONNULL_END
