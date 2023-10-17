//
//  HDPortraitToolBaseView.h
//  CCLiveCloud
//
//  Created by Apple on 2021/3/15.
//  Copyright © 2021 MacBook Pro. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class HDPortraitToolModel;

/** 显示状态变更block */
typedef void(^CloseBtnEventBlock)(void);
/** 更新数据block */
typedef void(^UpdateModelBlock)(HDPortraitToolModel *model);

@interface HDPortraitToolBaseView : UIView

@property (nonatomic, copy) HDPortraitToolModel *selectedAudioModeModel;

@property (nonatomic, copy) HDPortraitToolModel *selectedQualityModel;

@property (nonatomic, copy) HDPortraitToolModel *selectedLineModel;

@property (nonatomic, copy) HDPortraitToolModel *selectedRateModel;

@property (nonatomic, copy) CloseBtnEventBlock  closeBlock;

@property (nonatomic, copy) UpdateModelBlock    updateBlock;

- (instancetype)initWithFrame:(CGRect)frame
                 hasAudioMode:(BOOL)hasAudioMode
                  qualityList:(NSArray *)qualityList
                     lineList:(NSArray *)lineList
                     rateList:(NSArray *)rateList;

- (void)setQualityViewHidden:(BOOL)hidden;

@end

NS_ASSUME_NONNULL_END
