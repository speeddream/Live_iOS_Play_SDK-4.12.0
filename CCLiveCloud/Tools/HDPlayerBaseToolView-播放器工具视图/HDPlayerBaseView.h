//
//  HDPlayerBaseView.h
//  CCLiveCloud
//
//  Created by Apple on 2021/2/24.
//  Copyright © 2021 MacBook Pro. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^touchBegin)(NSString *string);

@interface HDPlayerBaseView : UIView

@property (nonatomic, copy) touchBegin touchBegin;

@end

NS_ASSUME_NONNULL_END
