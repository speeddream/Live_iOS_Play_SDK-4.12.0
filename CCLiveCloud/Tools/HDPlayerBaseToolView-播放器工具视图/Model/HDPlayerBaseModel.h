//
//  HDPlayerBaseModel.h
//  CCLiveCloud
//
//  Created by Apple on 2020/12/15.
//  Copyright © 2020 MacBook Pro. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


typedef NS_ENUM(NSUInteger, HDPlayerBaseDefaultType) {
    HDPlayerBaseVideoLine, //视频线路
    HDPlayerBaseAudioLine, //音频线路
    HDPlayerBaseQuality,   //清晰度
    HDPlayerBaseRate,      //倍速
    HDPlayerBaseBarrage,   //弹幕
};

@interface HDPlayerBaseModel : NSObject
/** 对应值 */
@property (nonatomic, copy)   NSString                     *value;
/** 描述 */
@property (nonatomic, copy)   NSString                     *desc;
/** 下标 */
@property (nonatomic, assign) NSInteger                    index;
/** 功能 */
@property (nonatomic, assign) HDPlayerBaseDefaultType      func;

@end

NS_ASSUME_NONNULL_END
