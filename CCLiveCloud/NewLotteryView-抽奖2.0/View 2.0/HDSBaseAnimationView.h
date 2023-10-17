//
//  HDSBaseAnimationView.h
//  Example
//
//  Created by richard lee on 8/30/22.
//  Copyright © 2022 Jonathan Tribouharet. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class HDSBaseAnimationModel;
/**
 按钮点击回调
 tag == 0 关闭按钮
 tag == 1 更多按钮
 */
typedef void(^btnTapBlock)(NSInteger tag);

typedef void(^endAniBlock)(void);

@interface HDSBaseAnimationView : UIView

@property (nonatomic, strong) NSArray *originDatas;

@property (nonatomic, strong) NSArray *lotteryUserDatas;

@property (nonatomic, assign) NSInteger lotteryUserCount;

@property (nonatomic, strong) HDSBaseAnimationModel *model;

- (instancetype)initWithFrame:(CGRect)frame closure:(btnTapBlock)closure endAniBlock:(endAniBlock)endAniClosure;

- (void)startAnimation;

- (void)stopAnimation;

@end

NS_ASSUME_NONNULL_END
