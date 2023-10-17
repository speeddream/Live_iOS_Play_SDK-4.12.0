//
//  NSDictionary+Log.m
//  CCLiveCloud
//
//  Created by Clark on 2019/7/22.
//  Copyright © 2019 MacBook Pro. All rights reserved.
//

#import "NSDictionary+Log.h"

@implementation NSDictionary (Log)
#ifdef DEBUG
//打印到控制台时会调用该方法
- (NSString *)descriptionWithLocale:(id)locale{
    return self.debugDescription;
}
//有些时候不走上面的方法，而是走这个方法
//- (NSString *)descriptionWithLocale:(id)locale indent:(NSUInteger)level{
//    return self.debugDescription;
//}
//用po打印调试信息时会调用该方法
//- (NSString *)debugDescription{
//    NSError *error = nil;
//    //字典转成json
//    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self options:NSJSONWritingPrettyPrinted  error:&error];
//    //如果报错了就按原先的格式输出
//    if (error) {
//        return [super debugDescription];
//    }
//    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
//    return jsonString;
//}
#endif

@end
