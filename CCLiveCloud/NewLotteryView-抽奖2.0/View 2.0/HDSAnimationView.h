//
//  HDSAnimationView.h
//  Example
//
//  Created by richard lee on 8/23/22.
//  Copyright © 2022 Jonathan Tribouharet. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class HDSAnimationModel;

typedef void (^animationEndClosure)(void);

@interface HDSAnimationView : UIView

@property (nonatomic, strong) NSArray <HDSAnimationModel *>*models;

@property (nonatomic, copy)   animationEndClosure animationEndClosure;

- (void)startAnimation;

- (void)stopAnimation;

@end

NS_ASSUME_NONNULL_END
