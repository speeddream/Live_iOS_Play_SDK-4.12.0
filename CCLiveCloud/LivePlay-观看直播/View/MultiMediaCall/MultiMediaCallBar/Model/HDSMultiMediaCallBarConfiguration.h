//
//  HDSMultiMediaCallBarConfiguration.h
//  CCLiveCloud
//
//  Created by Richard Lee on 8/28/21.
//  Copyright © 2021 MacBook Pro. All rights reserved.
//

#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, HDSMultiMediaCallBarType) {
    HDSMultiMediaCallBarTypeUnknow,
    HDSMultiMediaCallBarTypeVideoApply,         /// 视频申请
    HDSMultiMediaCallBarTypeAudioApply,         /// 音频申请
    HDSMultiMediaCallBarTypeVideoCalling,       /// 视频申请中...
    HDSMultiMediaCallBarTypeAudioCalling,       /// 视频申请中...
    HDSMultiMediaCallBarTypeVideoInvitation,    /// 视频邀请
    HDSMultiMediaCallBarTypeAudioInvitation,    /// 音频邀请
    HDSMultiMediaCallBarTypeVideoConnecting,    /// 视频连接中...
    HDSMultiMediaCallBarTypeAudioConnecting,    /// 音频连接中...
    HDSMultiMediaCallBarTypeVideoCalled,        /// 视频连麦中
    HDSMultiMediaCallBarTypeAudioCalled,        /// 音频连麦中
};

typedef NS_ENUM(NSUInteger, HDSCallBarMainButtonType) {
    HDSCallBarMainButtonTypeApply,              /// 申请
    HDSCallBarMainButtonTypeHangup,             /// 挂断
    HDSCallBarMainButtonTypeConnected,          /// 通话中（收起用） 🔗
};

/// 用户事件类型
typedef NS_ENUM(NSUInteger, HDSMultiMediaCallUserActionType) {
    HDSMultiMediaCallUserActionTypeApply,       /// 申请
    HDSMultiMediaCallUserActionTypeHangup,      /// 挂断
    HDSMultiMediaCallUserActionTypeMic,         /// 操作麦克风
    HDSMultiMediaCallUserActionTypeCamera,      /// 操作摄像头
    HDSMultiMediaCallUserActionTypeChangeCamera,/// 切换摄像头
};

@interface HDSMultiMediaCallBarConfiguration : NSObject

/// 展示类型
@property (nonatomic, assign) HDSMultiMediaCallBarType callType;
/// 滚动的最小Y值
@property (nonatomic, assign) CGFloat   minY;
/// 延迟收齐时常
@property (nonatomic, assign) CGFloat   delayDuration;
/// 用户操作事件类型
@property (nonatomic, assign) HDSMultiMediaCallUserActionType actionType;
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
