//
//  HDSLoginErrorManager.h
//  CCLiveCloud
//
//  Created by richard lee on 6/19/23.
//  Copyright © 2023 MacBook Pro. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HDSLoginErrorManager : NSObject

+ (NSString *)loginErrorCode:(NSUInteger)code message:(NSString * _Nullable)message;

@end

NS_ASSUME_NONNULL_END
