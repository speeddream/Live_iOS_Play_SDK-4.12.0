//
//  HDSStreamLiveAndQualityPublicCell.h
//  CCLiveCloud
//
//  Created by richard lee on 1/11/23.
//  Copyright © 2023 MacBook Pro. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HDSStreamLiveAndQualityPublicCell : UICollectionViewCell

/// 设置cell
/// - Parameters:
///   - title: 标题
///   - isSelected: 是否选中
- (void)setCellTitle:(NSString *)title isSelected:(BOOL)isSelected;

@end

NS_ASSUME_NONNULL_END
