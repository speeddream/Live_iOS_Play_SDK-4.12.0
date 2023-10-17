//
//  HDSAddressModel.m
//  CCLiveCloud
//
//  Created by 刘强强 on 2022/5/6.
//  Copyright © 2022 MacBook Pro. All rights reserved.
//

#import "HDSAddressModel.h"
#import <MJExtension/MJExtension.h>

@implementation HDSRegionModel

+ (NSDictionary *)mj_objectClassInArray {
    return @{@"children":@"HDSRegionModel"};
}

@end

@implementation HDSAddressModel

+ (NSDictionary *)mj_objectClassInArray {
    return @{@"region":@"HDSRegionModel"};
}

+ (HDSAddressModel *)getAddressModel {
    
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *path = [bundle pathForResource:@"city" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSError *error;
    NSDictionary *provinceLise = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
    
    HDSAddressModel *model = [HDSAddressModel mj_objectWithKeyValues:provinceLise];
    
    return model;
}



@end
