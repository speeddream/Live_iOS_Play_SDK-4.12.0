//
//  HDPlayerBaseQualityView.h
//  CCLiveCloud
//
//  Created by Apple on 2020/12/11.
//  Copyright © 2020 MacBook Pro. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class HDPlayerBaseModel;
/** 按钮点击事件回调 */
typedef void(^qualityBlock)(HDPlayerBaseModel *model);

@interface HDPlayerBaseQualityView : UIView
/** 清晰度回调 */
@property (nonatomic, copy) qualityBlock   qulityBlock;
/**
 *    @brief    显示清晰度
 *    @param    qualityArray            清晰度数组 (0-原画；200-流畅；300-标清)
 *    @param    selectedQuality    选中清晰度
 */
- (void)playerBaseQualityViewWithDataArray:(NSMutableArray *)qualityArray
                           selectedQuality:(NSString *)selectedQuality;

@end

NS_ASSUME_NONNULL_END
