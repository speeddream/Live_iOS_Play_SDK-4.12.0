//
//  HDPlayerBaseLineView.h
//  CCLiveCloud
//
//  Created by Apple on 2020/12/11.
//  Copyright © 2020 MacBook Pro. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class HDPlayerBaseModel;
/** 按钮点击事件回调 */
typedef void(^lineBlock)(HDPlayerBaseModel *model);

typedef void(^switchAudioBtn)(BOOL);

@interface HDPlayerBaseLineView : UIView

/** 清晰度回调 */
@property (nonatomic, copy) lineBlock   lineBlock;

/** 清晰度回调 */
@property (nonatomic, copy) switchAudioBtn   switchAudio;
/**
 *    @brief    显示线路
 *    @param    lineArray               线路数组
 *    @param    selectedLineIndex       选中线路
 *    @param    isAudio                 是否是音频线路
 */
- (void)playerBaseLineViewWithDataArray:(NSMutableArray *)lineArray
                      selectedLineIndex:(NSString *)selectedLineIndex
                                isAudio:(BOOL)isAudio;

@end

NS_ASSUME_NONNULL_END
