//
//  RLLikeConfiguration.h
//  ExampleDemo
//
//  Created by richard lee on 2/17/22.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RLLikeConfiguration : NSObject

// 点赞按钮图片
@property (nonatomic, strong) UIImage               *likeBtnImage;
// 点赞图片数组
@property (nonatomic, strong) NSArray<UIImage *>    *likeImages;

// 点赞时间间隔（0 < x <= 1s）
@property (nonatomic, assign) CGFloat               likeTimeInterval;
// 点赞动画持续时间
@property (nonatomic, assign) CGFloat               likeDuration;

// 点赞飘动最小高度 (300 <= x)
@property (nonatomic, assign) CGFloat               showMinHeight;
// 点赞飘动最大高度
@property (nonatomic, assign) CGFloat               showMaxHeight;

@end

NS_ASSUME_NONNULL_END
