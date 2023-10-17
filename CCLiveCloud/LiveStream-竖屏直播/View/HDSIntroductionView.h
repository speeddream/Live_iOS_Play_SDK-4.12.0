//
//  HDSIntroductionView.h
//  CCLiveCloud
//
//  Created by richard lee on 1/9/23.
//  Copyright © 2023 MacBook Pro. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^introductionCloseBtnTapBlock)(void);

@interface HDSIntroductionView : UIView

/// 顶部透明视图
@property (nonatomic, strong) UIView *topView;

/// 初始化
/// - Parameters:
///   - frame: 布局
///   - closure: 关闭按钮回调
- (instancetype)initWithFrame:(CGRect)frame closeBtnTapClosure:(introductionCloseBtnTapBlock)closure;

/// 房间信息
/// - Parameter dict: 房间信息
- (void)roomInfo:(NSDictionary *)dic;

/// 设置房间icon
/// - Parameter url: 头像地址
- (void)setHomeIconWithUrl:(NSString *)url;

/// 设置房间人数
/// - Parameter count: 人数
- (void)setRoomOnlineUserCountWithCount:(NSString *)count;

/// 更新房间直播状态
/// - Parameter state: 是否已开播
- (void)roomLiveStatus:(BOOL)state;

/// 当前房间直播状态
/// - Parameter state: 0.正在直播 1.未开始直播
- (void)currentRoomLiveStatus:(NSInteger)state;

@end

NS_ASSUME_NONNULL_END
