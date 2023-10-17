//
//  HDSRedPacketRankHeaderView.h
//  CCLiveCloud
//
//  Created by 刘强强 on 2022/4/8.
//  Copyright © 2022 MacBook Pro. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
/// 关闭排名
typedef void(^CloseRankClosure)(void);

@interface HDSRedPacketRankHeaderView : UIView

/// 排行榜顶部视图
/// @param frame 布局
/// @param score 得分
/// @param closeRankClosure 关闭按钮的回调
- (instancetype)initWithFrame:(CGRect)frame
                        score:(CGFloat)score
                        tip:(NSString *)tip
             closeRankClosure:(CloseRankClosure)closeRankClosure;

/// 排行榜顶部视图
/// @param frame 布局
/// @param score 得分
/// @param rankBackgroundUrl 背景图
/// @param tip 提示
/// @param closeRankClosure 关闭按钮的回调
- (instancetype)initWithFrame:(CGRect)frame
                        score:(CGFloat)score
            rankBackgroundUrl:(NSString *)rankBackgroundUrl
                        tip:(NSString *)tip
             closeRankClosure:(CloseRankClosure)closeRankClosure;
@end

NS_ASSUME_NONNULL_END
