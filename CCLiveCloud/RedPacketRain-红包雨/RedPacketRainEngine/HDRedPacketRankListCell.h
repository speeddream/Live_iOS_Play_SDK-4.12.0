//
//  HDRedPacketRankListCell.h
//  CCLiveCloud
//
//  Created by Richard Lee on 7/2/21.
//  Copyright © 2021 MacBook Pro. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class HDSRedRacketRankListModel;

@interface HDRedPacketRankListCell : UITableViewCell

/// cell数据源
/// @param model 排名数据
/// @param row 对应行
- (void)redPacketRankListCellWithModel:(HDSRedRacketRankListModel *)model
                                   row:(NSInteger)row;

@end

NS_ASSUME_NONNULL_END
