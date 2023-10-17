//
//  HDSCallBarFunctionModel.h
//  CCLiveCloud
//
//  Created by Richard Lee on 8/28/21.
//  Copyright © 2021 MacBook Pro. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HDSCallBarFunctionModel : NSObject
    
/// 是否是音视频连麦
@property (nonatomic, assign) BOOL      isAudioVideo;
/// 麦克风是否可用
@property (nonatomic, assign) BOOL      isAudioEnable;
/// 摄像头是否可用
@property (nonatomic, assign) BOOL      isVideoEnable;
/// 是否是前置摄像头
@property (nonatomic, assign) BOOL      isFrontCamera;

@end

NS_ASSUME_NONNULL_END
