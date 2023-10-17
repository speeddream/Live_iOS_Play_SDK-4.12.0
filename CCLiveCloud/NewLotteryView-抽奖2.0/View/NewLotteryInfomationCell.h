//
//  NewLotteryInfomationCell.h
//  CCLiveCloud
//
//  Created by Apple on 2020/11/13.
//  Copyright © 2020 MacBook Pro. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class NewLotteryInfomationCellModel;

typedef void (^infoCellSelectedBlock)(NSInteger index);

typedef void (^infoCellContentBlock)(NewLotteryInfomationCellModel *model);

@interface NewLotteryInfomationCell : UITableViewCell
/** 模板数据 */
@property (nonatomic, strong) NewLotteryInfomationCellModel   *model;
/** 当前选中行的回调 */
@property (nonatomic, copy)   infoCellSelectedBlock     selectedBlock;
/** 当前输入的内容 */
@property (nonatomic, copy)   infoCellContentBlock      contentBlock;
@end

NS_ASSUME_NONNULL_END
