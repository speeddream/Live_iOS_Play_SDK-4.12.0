//
//  HDSAnimationManager.h
//  Example
//
//  Created by richard lee on 8/25/22.
//  Copyright © 2022 Jonathan Tribouharet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN
@class HDSBaseAnimationModel;
typedef void(^btnsTapClosure)(NSInteger tag);
typedef void(^endAnimationClosure)(void);

@interface HDSAnimationManager : NSObject

@property (nonatomic, strong) endAnimationClosure endAnimationClosure;

- (instancetype)initWithBoardView:(UIView *)boardView configure:(HDSBaseAnimationModel *)configure btnsTapClosure:(btnsTapClosure)tapClosure;

- (void)setNormalData:(NSArray *)normalDatas;

- (void)setHighLightData:(NSArray *)highLightDatas;

- (void)startAnimation;

- (void)stopAnimation;

- (void)killAll;

@end

NS_ASSUME_NONNULL_END
