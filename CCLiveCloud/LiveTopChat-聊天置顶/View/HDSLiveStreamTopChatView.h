//
//  HDSLiveStreamTopChatView.h
//  CCLiveCloud
//
//  Created by richard lee on 1/11/23.
//  Copyright © 2023 MacBook Pro. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, HDSLiveStreamTopChatLayoutStyle) {
    HDSLiveStreamTopChatLayoutStyleLeftRight, //左右样式
    HDSLiveStreamTopChatLayoutStyleTopBottom, //上下样式
};

typedef void(^btnTapEventBlock)(BOOL isOpen);

@interface HDSLiveStreamTopChatView : UIView

@property (nonatomic, copy) NSString *viewerId;

/// 初始化
/// - Parameters:
///   - frame: 布局
///   - layoutStyle: 滚动样式
- (instancetype)initWithFrame:(CGRect)frame layoutStyle:(HDSLiveStreamTopChatLayoutStyle)layoutStyle closure:(btnTapEventBlock)closure;

/// 添加新的数据
/// - Parameter items: 数据数组
- (void)addItems:(NSArray *)items;

/// 根据itemID删除对应的item
/// - Parameter itemIdArray: itemId数组
- (void)deleteItemIdFromArray:(NSArray *)itemIdArray;

@end

NS_ASSUME_NONNULL_END
