//
//  HDSMultiBoardViewActionModel.h
//  CCLiveCloud
//
//  Created by Richard Lee on 8/31/21.
//  Copyright © 2021 MacBook Pro. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HDSMultiBoardViewActionModel : NSObject
/// 麦克风是否可用
@property (nonatomic, assign) BOOL      isAudioEnable;
/// 摄像头是否可用
@property (nonatomic, assign) BOOL      isVideoEnable;
/// 是否是前置
@property (nonatomic, assign) BOOL      isFrontCamera;
/// 是否挂断
@property (nonatomic, assign) BOOL      isHangup;

@end

NS_ASSUME_NONNULL_END
