//
//  NewLotteryWinnersCellModel.h
//  CCLiveCloud
//
//  Created by Apple on 2020/11/13.
//  Copyright © 2020 MacBook Pro. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NewLotteryWinnersCellModel : NSObject
/** 头像 */
@property (nonatomic, copy) NSString    *userAvatar;
/** 名称 */
@property (nonatomic, copy) NSString    *userName;
@end

NS_ASSUME_NONNULL_END
