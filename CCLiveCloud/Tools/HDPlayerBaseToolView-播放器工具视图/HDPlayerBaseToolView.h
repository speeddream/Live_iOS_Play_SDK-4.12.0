//
//  HDPlayerBaseToolView.h
//  CCLiveCloud
//
//  Created by Apple on 2020/12/9.
//  Copyright © 2020 MacBook Pro. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class HDPlayerBaseModel;

typedef NS_ENUM(NSUInteger, HDPlayerBaseToolViewType) {
    HDPlayerBaseToolViewTypeLine,       //线路
    HDPlayerBaseToolViewTypeRate,       //倍速
    HDPlayerBaseToolViewTypeQuality,    //清晰度
    HDPlayerBaseToolViewTypeBarrage,    //弹幕
};
typedef void(^baseToolBlock)(HDPlayerBaseModel *model);

typedef void(^switchAudio)(BOOL);

@interface HDPlayerBaseToolView : UIView

@property (nonatomic, copy)   baseToolBlock           baseToolBlock;

@property (nonatomic, copy)   switchAudio             switchAudio;
/**
 *    @brief    根据类型展示内容
 *    @param    type   显示类型
 *    @param    infos  显示数据数组
 *    @param    model  当前选择数据
 */
- (void)showInformationWithType:(HDPlayerBaseToolViewType)type infos:(NSArray *)infos defaultData:(HDPlayerBaseModel *)model;

@end

NS_ASSUME_NONNULL_END
