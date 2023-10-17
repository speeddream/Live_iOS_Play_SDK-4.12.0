//
//  HDPortraitToolDynamicView.h
//  CCLiveCloud
//
//  Created by Apple on 2021/3/16.
//  Copyright © 2021 MacBook Pro. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class HDPortraitToolModel;

typedef void(^updateDataBlock)(HDPortraitToolModel *model);

@interface HDPortraitToolDynamicView : UIView

@property (nonatomic, copy) NSArray         *dataArray;

@property (nonatomic, copy) HDPortraitToolModel *targetModel;

@property (nonatomic, copy) updateDataBlock updateDataBlock;

@end

NS_ASSUME_NONNULL_END
