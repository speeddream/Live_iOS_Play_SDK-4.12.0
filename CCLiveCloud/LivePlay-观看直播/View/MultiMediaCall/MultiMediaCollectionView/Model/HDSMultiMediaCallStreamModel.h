//
//  HDSMultiMediaCallStreamModel.h
//  CCLiveCloud
//
//  Created by Richard Lee on 2021/8/29.
//  Copyright © 2021 MacBook Pro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, kNeedUpateType) {
    kNeedUpateTypeAudio,
    kNeedUpateTypeVideo,
};

@interface HDSMultiMediaCallStreamModel : NSObject
/// 需要更新的类型
@property (nonatomic, assign) kNeedUpateType type;
/// 摄像头是否可用
@property (nonatomic, assign) BOOL      isVideoEnable;
/// 麦克风是否可用
@property (nonatomic, assign) BOOL      isAudioEnable;
/// 昵称
@property (nonatomic, copy) NSString    *nickName;
/// userId
@property (nonatomic, copy) NSString    *userId;
/// 流视图
@property (nonatomic, strong) UIView    *streamView;
/// 是否是自己
@property (nonatomic, assign) BOOL      isMyself;

@end

NS_ASSUME_NONNULL_END
