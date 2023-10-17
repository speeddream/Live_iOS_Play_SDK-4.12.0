//
//  VideoDotInfo.h
//  swiftIJK
//
//  Created by david on 2021/3/1.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface VideoDotInfo : NSObject
@property (nonatomic, strong) NSString  *dotId;
@property (nonatomic, assign) int       time;
@property (nonatomic, strong) NSString  *desc;

- (instancetype)initWith:(NSString *)dotId time:(int)time description:(NSString *)desc;
@end

NS_ASSUME_NONNULL_END
