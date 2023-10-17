//
//  HDSPickToolView.h
//  CCLiveCloud
//
//  Created by richard lee on 3/9/23.
//  Copyright © 2023 MacBook Pro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZLPhotoBrowser.h"
NS_ASSUME_NONNULL_BEGIN

typedef void(^kCallBack)(NSArray<UIImage *> * _Nullable images, NSArray<PHAsset *> * _Nonnull assets, BOOL isOriginal);

@interface HDSPickToolView : UIView

/// 初始化（允许选择同一张照片）
/// - Parameters:
///   - frame: 布局
///   - photoMaxCount: 最大图片个数
///   - closure: 回调
- (instancetype)initWithFrame:(CGRect)frame
                photoMaxCount:(int)photoMaxCount
                      closure:(kCallBack)closure;


/// 初始化（不允许选择同一张照片）
/// - Parameters:
///   - frame: 布局
///   - lastSelectAssets: 已选中图片
///   - closure: 回调
- (instancetype)initWithFrame:(CGRect)frame
             lastSelectAssets:(NSMutableArray <PHAsset *>*)lastSelectAssets
                      closure:(kCallBack)closure;

/// 展示
- (void)showPickToolView;

@end

NS_ASSUME_NONNULL_END
