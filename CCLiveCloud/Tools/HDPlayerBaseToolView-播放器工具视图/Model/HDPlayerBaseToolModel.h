//
//  HDPlayerBaseToolModel.h
//  CCLiveCloud
//
//  Created by Apple on 2020/12/14.
//  Copyright © 2020 MacBook Pro. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, HDPlayerBaseToolModelType) {
    HDPlayerBaseToolModelTypeLine,       //线路
    HDPlayerBaseToolModelTypeTypeRate,   //倍速
    HDPlayerBaseToolModelTypeQuality,    //清晰度
};
@interface HDPlayerBaseToolModel : NSObject
/** 下标 */
@property (nonatomic, assign) NSInteger                 index;
/** 主键 */
@property (nonatomic, copy)   NSString                  *primaryKey;
/** 描述 */
@property (nonatomic, copy)   NSString                  *keyDesc;
/** 是否选中 */
@property (nonatomic, assign) BOOL                      isSelected;
/** 类型 */
@property (nonatomic, assign) HDPlayerBaseToolModelType type;

@end

NS_ASSUME_NONNULL_END
