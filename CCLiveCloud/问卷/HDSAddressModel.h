//
//  HDSAddressModel.h
//  CCLiveCloud
//
//  Created by 刘强强 on 2022/5/6.
//  Copyright © 2022 MacBook Pro. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HDSAddressModel;
NS_ASSUME_NONNULL_BEGIN

@interface HDSRegionModel : NSObject

@property(nonatomic, strong) NSMutableArray<HDSRegionModel *> *children;
@property(nonatomic, copy) NSString *mergerName;
@property(nonatomic, copy) NSString *name;
@property(nonatomic, assign) NSInteger parentId;
@property(nonatomic, assign) NSInteger regionId;
@property(nonatomic, copy) NSString *pinyin;
@end

@interface HDSAddressModel : NSObject

+ (HDSAddressModel *)getAddressModel;

@property(nonatomic, strong) NSMutableArray<HDSRegionModel *> *region;

@end

NS_ASSUME_NONNULL_END
/*
 {
     "children": [
         {
             "children": [
                 {
                     
                     "mergerName": "北京,北京市,东城区",
                     "name": "东城区",
                     "parentId": 110100,
                     "pinyin": "Dongcheng",
                     "regionId": 110101
                 },
                 {
                     
                     "mergerName": "北京,北京市,西城区",
                     "name": "西城区",
                     "parentId": 110100,
                     "pinyin": "Xicheng",
                     "regionId": 110102
                 },
                 {
                     
                     "mergerName": "北京,北京市,朝阳区",
                     "name": "朝阳区",
                     "parentId": 110100,
                     "pinyin": "Chaoyang",
                     "regionId": 110105
                 },
                 {
                     
                     "mergerName": "北京,北京市,丰台区",
                     "name": "丰台区",
                     "parentId": 110100,
                     "pinyin": "Fengtai",
                     "regionId": 110106
                 },
                 {
                     
                     "mergerName": "北京,北京市,石景山区",
                     "name": "石景山区",
                     "parentId": 110100,
                     "pinyin": "Shijingshan",
                     "regionId": 110107
                 },
                 {
                     
                     "mergerName": "北京,北京市,海淀区",
                     "name": "海淀区",
                     "parentId": 110100,
                     "pinyin": "Haidian",
                     "regionId": 110108
                 },
                 {
                     
                     "mergerName": "北京,北京市,门头沟区",
                     "name": "门头沟区",
                     "parentId": 110100,
                     "pinyin": "Mentougou",
                     "regionId": 110109
                 },
                 {
                     
                     "mergerName": "北京,北京市,房山区",
                     "name": "房山区",
                     "parentId": 110100,
                     "pinyin": "Fangshan",
                     "regionId": 110111
                 },
                 {
                     
                     "mergerName": "北京,北京市,通州区",
                     "name": "通州区",
                     "parentId": 110100,
                     "pinyin": "Tongzhou",
                     "regionId": 110112
                 },
                 {
                     
                     "mergerName": "北京,北京市,顺义区",
                     "name": "顺义区",
                     "parentId": 110100,
                     "pinyin": "Shunyi",
                     "regionId": 110113
                 },
                 {
                     
                     "mergerName": "北京,北京市,昌平区",
                     "name": "昌平区",
                     "parentId": 110100,
                     "pinyin": "Changping",
                     "regionId": 110114
                 },
                 {
                     
                     "mergerName": "北京,北京市,大兴区",
                     "name": "大兴区",
                     "parentId": 110100,
                     "pinyin": "Daxing",
                     "regionId": 110115
                 },
                 {
                     
                     "mergerName": "北京,北京市,怀柔区",
                     "name": "怀柔区",
                     "parentId": 110100,
                     "pinyin": "Huairou",
                     "regionId": 110116
                 },
                 {
                     
                     "mergerName": "北京,北京市,平谷区",
                     "name": "平谷区",
                     "parentId": 110100,
                     "pinyin": "Pinggu",
                     "regionId": 110117
                 },
                 {
                     
                     "mergerName": "北京,北京市,密云县",
                     "name": "密云县",
                     "parentId": 110100,
                     "pinyin": "Miyun",
                     "regionId": 110228
                 },
                 {
                     
                     "mergerName": "北京,北京市,延庆县",
                     "name": "延庆县",
                     "parentId": 110100,
                     "pinyin": "Yanqing",
                     "regionId": 110229
                 }
             ],
             "mergerName": "北京,北京市",
             "name": "北京市",
             "parentId": 110000,
             "pinyin": "Beijing",
             "regionId": 110100
         }
     ],
     "mergerName": "北京",
     "name": "北京",
     "parentId": 100000,
     "pinyin": "Beijing",
     "regionId": 110000
 }
 */
