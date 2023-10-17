//
//  HDSAnnouncementView.h
//  CCLiveCloud
//
//  Created by richard lee on 1/9/23.
//  Copyright © 2023 MacBook Pro. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^closeBtnTapBlock)(void);

@interface HDSAnnouncementView : UIView

@property (nonatomic, strong) UIView *topView;

/// 初始化公告
/// - Parameter str: 公告信息
- (instancetype)initWithAnnouncementStr:(NSString *)str closeBtnTapClosure:(closeBtnTapBlock)closure;

/// 更新公告
/// - Parameter str: 公告信息
- (void)updateViews:(NSString *)str;

@end

NS_ASSUME_NONNULL_END
