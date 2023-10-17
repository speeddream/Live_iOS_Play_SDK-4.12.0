//
//  NewLotteryInfomationCellModel.h
//  CCLiveCloud
//
//  Created by Apple on 2020/11/13.
//  Copyright © 2020 MacBook Pro. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NewLotteryInfomationCellModel : NSObject
/** 标题 */
@property (nonatomic, copy) NSString    *title;
/** 提示语 */
@property (nonatomic, copy) NSString    *tips;
/** 序号 */
@property (nonatomic, assign)NSInteger  index;
/** 用户输入内容 (自定义字段)*/
@property (nonatomic, copy) NSString    *content;
@end

NS_ASSUME_NONNULL_END
