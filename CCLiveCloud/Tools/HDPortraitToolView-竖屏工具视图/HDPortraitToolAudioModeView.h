//
//  HDPortraitToolAudioModeView.h
//  CCLiveCloud
//
//  Created by Apple on 2021/3/15.
//  Copyright © 2021 MacBook Pro. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class HDPortraitToolModel;

typedef void(^UpdateModelBlock)(HDPortraitToolModel *model);

@interface HDPortraitToolAudioModeView : UIView

@property (nonatomic, copy) UpdateModelBlock updateBlock;

@property (nonatomic, strong) HDPortraitToolModel *targetModel;

- (instancetype)initWithFrame:(CGRect)frame hasAudioMode:(BOOL)hasAudioMode;

@end

NS_ASSUME_NONNULL_END
