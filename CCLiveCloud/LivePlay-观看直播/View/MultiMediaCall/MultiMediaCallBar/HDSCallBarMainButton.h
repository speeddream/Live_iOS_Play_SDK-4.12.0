//
//  HDSCallBarMainButton.h
//  CCLiveCloud
//
//  Created by Richard Lee on 8/28/21.
//  Copyright © 2021 MacBook Pro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HDSMultiMediaCallBarConfiguration.h"
NS_ASSUME_NONNULL_BEGIN

typedef void(^callBarMainBtnClickClosure)(BOOL isApply);

@interface HDSCallBarMainButton : UIButton

/// 更新按钮状态
/// @param type 类型
- (void)updateCallType:(HDSCallBarMainButtonType)type;

@end

NS_ASSUME_NONNULL_END
