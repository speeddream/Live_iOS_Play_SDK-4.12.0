//
//  HDPortraitToolQualityView.h
//  CCLiveCloud
//
//  Created by Apple on 2021/3/17.
//  Copyright © 2021 MacBook Pro. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class HDPortraitToolModel;

typedef void(^UpdateModelBlock)(HDPortraitToolModel *model);

@interface HDPortraitToolQualityView : UIView

@property (nonatomic, copy) UpdateModelBlock updateBlock;

@property (nonatomic, strong) HDPortraitToolModel *targetModel;

- (instancetype)initWithFrame:(CGRect)frame qualityDataArray:(NSArray *)qualityArray;

@end

NS_ASSUME_NONNULL_END
