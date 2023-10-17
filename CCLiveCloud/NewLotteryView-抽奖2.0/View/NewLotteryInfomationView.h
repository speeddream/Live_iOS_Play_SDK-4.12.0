//
//  NewLotteryInfomationView.h
//  CCLiveCloud
//
//  Created by Apple on 2020/11/13.
//  Copyright © 2020 MacBook Pro. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^BlockWithContentArray)(NSArray *array);

typedef void (^BlockWithIndex)(NSInteger index);

@interface NewLotteryInfomationView : UIView

/** 用户输入信息数组 */
@property (nonatomic, strong) NSArray               *collectInfoArray;
/** 用户输入的中奖信息 */
@property (nonatomic, copy)   BlockWithContentArray inputBlock;
/** 用户输入的位置 */
@property (nonatomic, copy)   BlockWithIndex        indexBlock;
/** 数据 */
@property (nonatomic, strong) NSMutableArray        *dataArray;
/** 是否能再次提交 */
@property (nonatomic, assign) BOOL                  isAgainCommit;

@end

NS_ASSUME_NONNULL_END
