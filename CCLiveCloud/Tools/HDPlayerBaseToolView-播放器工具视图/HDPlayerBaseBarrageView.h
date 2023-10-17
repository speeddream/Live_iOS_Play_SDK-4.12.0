//
//  HDPlayerBaseBarrageView.h
//  CCLiveCloud
//
//  Created by Apple on 2021/4/6.
//  Copyright © 2021 MacBook Pro. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class HDPlayerBaseModel;

typedef NS_ENUM(NSUInteger, HDPlayerBaseBarrageViewStyle) {
    HDPlayerBaseBarrageViewStyleFullScreen,
    HDPlayerBaseBarrageViewStyleHalfScreen,
};

typedef void(^barrageViewBlock)(HDPlayerBaseModel *model);

@interface HDPlayerBaseBarrageView : UIView

@property (nonatomic, copy) barrageViewBlock    barrageViewBlock;

- (instancetype)initWithFrame:(CGRect)frame barrageStyle:(HDPlayerBaseBarrageViewStyle)barrageStyle;

- (void)setBarrageStyle:(HDPlayerBaseBarrageViewStyle)style;

@end

NS_ASSUME_NONNULL_END
