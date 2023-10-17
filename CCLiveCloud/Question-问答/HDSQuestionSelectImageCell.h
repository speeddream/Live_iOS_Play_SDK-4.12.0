//
//  HDSQuestionSelectImageCell.h
//  CCLiveCloud
//
//  Created by richard lee on 3/10/23.
//  Copyright © 2023 MacBook Pro. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HDSQuestionSelectImageModel;
NS_ASSUME_NONNULL_BEGIN

typedef void(^tipsTappedClosure)(NSString *tipsString);
typedef void(^deleteTappedClosure)(void);

@interface HDSQuestionSelectImageCell : UICollectionViewCell

@property (nonatomic, assign) BOOL isUploading;

- (void)sourceData:(HDSQuestionSelectImageModel *)model tipsBtnTapped:(tipsTappedClosure)tipsBtnBlock deleteBtnTapped:(deleteTappedClosure)deleteBtnBlock;

@end

NS_ASSUME_NONNULL_END
