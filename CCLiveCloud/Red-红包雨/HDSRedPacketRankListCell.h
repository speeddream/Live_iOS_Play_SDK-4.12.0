//
//  HDSRedPacketRankListCell.h
//  CCLiveCloud
//
//  Created by 刘强强 on 2022/4/8.
//  Copyright © 2022 MacBook Pro. All rights reserved.
//

#import <UIKit/UIKit.h>
@import HDSRedEnvelopeModule;
@class HDSRedRacketRankListModel;

NS_ASSUME_NONNULL_BEGIN

@interface HDSRedPacketRankListCell : UITableViewCell
/// cell数据源
/// @param model 排名数据
/// @param row 对应行
- (void)redPacketRankListCellWithModel:(HDSRedEnvelopeWinningListRecordModel *)model
                                   row:(NSInteger)row
                              mySelfId:(NSString *)mySelfId
                               redKind:(NSInteger)redKind;
@end

NS_ASSUME_NONNULL_END
