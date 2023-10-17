//
//  VideoDotInfo.m
//  swiftIJK
//
//  Created by david on 2021/3/1.
//

#import "VideoDotInfo.h"

@implementation VideoDotInfo
- (instancetype)initWith:(NSString *)dotId time:(int)time description:(NSString *)desc {
    self = [super init];
    if (self) {
        _dotId = dotId;
        _time = time;
        _desc = desc;
    }
    return self;
}
@end
