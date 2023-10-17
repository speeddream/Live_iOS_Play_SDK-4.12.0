//
//  HDRedPacketRankHeaderView.h
//  CCLiveCloud
//
//  Created by Richard Lee on 7/1/21.
//  Copyright © 2021 MacBook Pro. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 关闭排名
typedef void(^CloseRankClosure)(void);

@interface HDRedPacketRankHeaderView : UIView

/// 排行榜顶部视图
/// @param frame 布局
/// @param score 得分
/// @param closeRankClosure 关闭按钮的回调
- (instancetype)initWithFrame:(CGRect)frame
                        score:(NSInteger)score
             closeRankClosure:(CloseRankClosure)closeRankClosure;

@end

NS_ASSUME_NONNULL_END
