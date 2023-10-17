//
//  HDPortraitToolManager.h
//  CCLiveCloud
//
//  Created by Apple on 2021/3/15.
//  Copyright © 2021 MacBook Pro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class HDPortraitToolModel;

/** 事件回调 */
typedef void(^EventBlock)(HDPortraitToolModel *model);

@interface HDPortraitToolManager : NSObject
/**
 *    @brief    初始化竖屏工具管理者
 *    @param    boardView       底部视图
 *    @param    audioMode       音频模式开关
 *    @param    quality         清晰度开关
 *    @param    line            线路开关
 *    @param    rate            倍速开关
 *    @param    eventBlock      事件回调
 */
- (instancetype)initWithBoardView:(UIView *)boardView
                        audioMode:(BOOL)audioMode
                          quality:(BOOL)quality
                             line:(BOOL)line
                             rate:(BOOL)rate
                       eventBlock:(EventBlock)eventBlock;

/**
 *    @brief    音频模式
 *    @param    isSelected   音频模式 YES  非音频模式 NO
 */
- (void)setAudioModeSelected:(BOOL)isSelected;
/**
 *    @brief    清晰度数据
 *    @param    metaData        清晰度源数据
 */
- (void)setQualityMetaData:(NSDictionary *)metaData;
/**
 *    @brief    线路数据
 *    @param    metaData        线路源数据
 */
- (void)setLineMetaData:(NSDictionary *)metaData;
/**
 *    @brief    倍速数据
 *    @param    metaData        倍速源数据
 */
- (void)setRateMetaData:(NSDictionary *)metaData;
/**
 *    @brief    展示 隐藏 ToolView
 *    @param    isHidden    显示 YES 隐藏 NO
 */
- (void)setToolViewHidden:(BOOL)isHidden;
@end

NS_ASSUME_NONNULL_END
