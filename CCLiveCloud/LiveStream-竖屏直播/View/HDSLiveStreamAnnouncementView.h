//
//  HDSLiveStreamAnnouncementView.h
//  CCLiveCloud
//
//  Created by richard lee on 12/19/22.
//  Copyright © 2022 MacBook Pro. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^buttonTap)(void);

@interface HDSLiveStreamAnnouncementView : UIView

- (instancetype)initWithFrame:(CGRect)frame tapAction:(buttonTap)tapAction;

- (void)setAnnouncementText:(NSString *)text;

@end

NS_ASSUME_NONNULL_END
