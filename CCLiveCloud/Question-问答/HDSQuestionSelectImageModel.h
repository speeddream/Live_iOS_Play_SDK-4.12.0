//
//  HDSQuestionSelectImageModel.h
//  CCLiveCloud
//
//  Created by richard lee on 3/20/23.
//  Copyright © 2023 MacBook Pro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HDSQuestionSelectImageModel : NSObject

@property (nonatomic, strong) UIImage *image;

@property (nonatomic, assign) BOOL result;

@property (nonatomic, copy)   NSString * _Nullable message;

@property (nonatomic, assign) NSInteger older;

@end

NS_ASSUME_NONNULL_END
