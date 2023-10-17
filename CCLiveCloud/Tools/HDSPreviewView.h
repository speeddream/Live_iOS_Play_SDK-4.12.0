//
//  HDSPreviewView.h
//  CCLiveCloud
//
//  Created by richard lee on 3/14/23.
//  Copyright © 2023 MacBook Pro. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^deleteImageCallback)(NSArray <UIImage *>*deleteImages);
typedef void(^dissmissCallBack)(void);

@interface HDSPreviewView : UIView
    
/// 初始化
/// - Parameters:
///   - frame: 布局
///   - currentIndex 当前位置
///   - dataSource: 数据源
///   - dismissClosure: dissmiss 回调
- (instancetype)initWithFrame:(CGRect)frame
                 currentIndex:(int)currentIndex
                   dataSource:(NSArray <UIImage *>*)dataSource
               dismissClosure:(dissmissCallBack)dismissClosure;

/// 初始化(网络图片)
/// - Parameters:
///   - frame: 布局
///   - currentIndex 当前位置
///   - dataSource: 数据源
///   - dismissClosure: dissmiss 回调
- (instancetype)initWithFrame:(CGRect)frame
                 currentIndex:(int)currentIndex
         networkIMGdataSource:(NSArray <NSString *>*)dataSource
               dismissClosure:(dissmissCallBack)dismissClosure;


/// 初始化（支持删除）
/// - Parameters:
///   - frame: 布局
///   - currentIndex 当前位置
///   - dataSource: 数据源
///   - deleteClosure: 删除回调
///   - dismissClosure: dissmiss 回调
- (instancetype)initWithFrame:(CGRect)frame
                 currentIndex:(int)currentIndex
                   dataSource:(NSArray <UIImage *>*)dataSource
                deleteClosure:(deleteImageCallback)deleteClosure
               dismissClosure:(dissmissCallBack)dismissClosure;

@end

@interface HDSPreviewCell : UICollectionViewCell

@property (nonatomic, strong) UIImage *image;

@property (nonatomic, copy) NSString *imageUrl;

@end

NS_ASSUME_NONNULL_END
