//
//  HDSInteractionManagerConfig.h
//  CCLiveCloud
//
//  Created by richard lee on 3/16/22.
//  Copyright © 2022 MacBook Pro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
@class HDSLiveStreamControlView;
NS_ASSUME_NONNULL_BEGIN

@interface HDSInteractionManagerConfig : NSObject
/// 用户ID
@property (nonatomic, copy)     NSString *userId;
/// 用户登录ID
@property (nonatomic, copy)     NSString *appid;
/// SDKVersion
@property (nonatomic, copy)     NSString *sdkVersion;
/// 用户名
@property (nonatomic, copy)     NSString *userName;
/// 房间ID
@property (nonatomic, copy)     NSString *roomId;
/// token
@property (nonatomic, copy)     NSString *token;
/// 房间名称
@property (nonatomic, copy)     NSString *roomName;
/// 房间描述
@property (nonatomic, copy)     NSString *roomDesc;
/// 房间连接
@property (nonatomic, copy)     NSString *roomUrl;
/// 房间连接 短连接
@property (nonatomic, copy)     NSString *sortUrl;
/// liveStartTime
@property (nonatomic, copy)     NSString *liveStartTime;
/// 根控制器
@property (nonatomic, weak)     UIViewController *rootVC;
/// 正在进行的互动 1:抽奖 2:打卡 3:随堂测 4:问卷 5:红包雨 6：互动组件红包 7:投票
@property(nonatomic, strong) NSArray *interactionArr;

/// 点赞配置项  0:关闭 1:直播间配置 2:全局配置
@property (nonatomic, assign)   NSInteger likeConfig;
/// 礼物功能配置 0:关闭 1:直播间配置 2:全局配置
@property (nonatomic, assign)   NSInteger giftConfig;
/// 礼物特效配置 0:关闭 1:左侧特效 2：全局特效
@property (nonatomic, assign)   NSInteger giftSpecialEffects;
/// 投票功能配置 0:关闭 1:直播间配置 2:全局配置
@property (nonatomic, assign)   NSInteger voteConfig;
/// 红包雨功能配置 0:关闭 1:直播间配置 2:全局配置
@property (nonatomic, assign)   NSInteger redConfig;
/// 邀请卡功能配置 0:关闭 1:直播间配置 2:全局配置
@property (nonatomic, assign)   NSInteger cardConfig;
/// 问卷功能配置 0:关闭 1:直播间配置 2:全局配置
@property (nonatomic, assign)   NSInteger questionnaireConfig;
/// 直播带货功能配置 0:关闭 1:直播间配置 2:全局配置
@property (nonatomic, assign)   NSInteger liveStoreConfig;
/// 问卷模式推送方式: 0:手动推送  1:进入直播时  2:直播结束时
@property (nonatomic, assign) NSInteger  sendMode;
/// 问卷活动编码
@property (nonatomic, copy) NSString     * _Nullable activityCode;
/// 问卷表单编码
@property (nonatomic, copy) NSString     * _Nullable formCode;
/// 父视图
@property (nonatomic, strong) HDSLiveStreamControlView *boardView;
@end

NS_ASSUME_NONNULL_END
