//
//  HDSToastTool.h
//  CCLiveCloud
//
//  Created by 刘强强 on 2022/3/31.
//  Copyright © 2022 MacBook Pro. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HDSToastTool : NSObject
+ (instancetype)shard;
- (void)showTipWithString:(NSString *)tipStr;
@end

NS_ASSUME_NONNULL_END
