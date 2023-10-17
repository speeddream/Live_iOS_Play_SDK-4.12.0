//
//  HDSMultiMediaStreamCell.h
//  CCLiveCloud
//
//  Created by Richard Lee on 2021/8/29.
//  Copyright © 2021 MacBook Pro. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class HDSMultiMediaCallStreamModel;

@interface HDSMultiMediaStreamCell : UICollectionViewCell

/// 设置数据
/// @param model 数据
/// @param row 当前row
- (void)setupDataWithModel:(HDSMultiMediaCallStreamModel *)model row:(NSInteger)row;

@end

NS_ASSUME_NONNULL_END
