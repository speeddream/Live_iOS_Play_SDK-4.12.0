//
//  HDSSteamLineAndQualityModel.h
//  CCLiveCloud
//
//  Created by richard lee on 1/11/23.
//  Copyright © 2023 MacBook Pro. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HDSSteamLineAndQualityModel : NSObject

@property (nonatomic, copy) NSString *title;

@property (nonatomic, assign) NSInteger selectedIndex;

@property (nonatomic, copy) NSString *quality;

@end

NS_ASSUME_NONNULL_END
