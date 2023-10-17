//
//  HDSMultiMediaCallBar.h
//  CCLiveCloud
//
//  Created by Richard Lee on 8/28/21.
//  Copyright © 2021 MacBook Pro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HDSMultiMediaCallBarConfiguration.h"
NS_ASSUME_NONNULL_BEGIN

typedef void(^mediaCallClosure)(HDSMultiMediaCallBarConfiguration *model);

@interface HDSMultiMediaCallBar : UIView    

/// 初始化
/// @param frame 布局
/// @param configuration 配置项
/// @param closure 回调
- (instancetype)initWithFrame:(CGRect)frame
            callConfiguration:(HDSMultiMediaCallBarConfiguration *)configuration
                      closure:(mediaCallClosure)closure;

/// 更新连麦bar状态
/// @param configuration 配置项
- (void)updateMediaCallBarConfiguration:(HDSMultiMediaCallBarConfiguration *)configuration;


/// 获取 callBar 对应宽度
/// @param type 类型
- (CGFloat)getCallBarWidthWithType:(HDSMultiMediaCallBarType)type;
                    

@end

NS_ASSUME_NONNULL_END
