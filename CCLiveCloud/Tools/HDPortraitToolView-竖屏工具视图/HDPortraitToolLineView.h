//
//  HDPortraitToolLineView.h
//  CCLiveCloud
//
//  Created by Apple on 2021/3/16.
//  Copyright © 2021 MacBook Pro. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class HDPortraitToolModel;

typedef void(^UpdateModelBlock)(HDPortraitToolModel *model);

@interface HDPortraitToolLineView : UIView

@property (nonatomic, copy) UpdateModelBlock updateBlock;

@property (nonatomic, strong) HDPortraitToolModel *targetModel;

- (instancetype)initWithFrame:(CGRect)frame lineDataArray:(NSArray *)lineDataArray;
@end

NS_ASSUME_NONNULL_END
