//
//  HDPortraitToolModel.h
//  CCLiveCloud
//
//  Created by Apple on 2021/3/15.
//  Copyright © 2021 MacBook Pro. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, HDPortraitToolType) {
    HDPortraitToolTypeWithQuality,     //清晰度
    HDPortraitToolTypeWithRate,        //倍速
    HDPortraitToolTypeWithLine,        //线路
    HDPortraitToolTypeWithAudioMode,   //音频模式
};

@interface HDPortraitToolModel : NSObject

@property (nonatomic, assign) HDPortraitToolType    type;

@property (nonatomic, assign) int                   index;

@property (nonatomic, copy)   NSString              *desc;

@property (nonatomic, copy)   NSString              *value;

@property (nonatomic, assign) BOOL                  isSelected;

@end

NS_ASSUME_NONNULL_END
