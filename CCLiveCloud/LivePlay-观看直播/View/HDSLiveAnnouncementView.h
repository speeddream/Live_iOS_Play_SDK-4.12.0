//
//  HDSLiveAnnouncementView.h
//  CCLiveCloud
//
//  Created by richard lee on 1/29/23.
//  Copyright © 2023 MacBook Pro. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^buttonTap)(NSInteger buttonTag);

@interface HDSLiveAnnouncementView : UIView

@property (nonatomic, strong) NSString *historyAnnouncementString;

- (instancetype)initWithFrame:(CGRect)frame closure:(buttonTap)closure;

@end

NS_ASSUME_NONNULL_END
