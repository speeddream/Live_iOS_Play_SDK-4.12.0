//
//  HDSQuestionCell.h
//  CCLiveCloud
//
//  Created by richard lee on 3/15/23.
//  Copyright © 2023 MacBook Pro. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Dialogue;
NS_ASSUME_NONNULL_BEGIN

typedef void(^btnsTappedClosure)(int index, NSArray *images);

@interface HDSQuestionCell : UITableViewCell

- (void)setDatasource:(Dialogue *)dialogue moreAnswer:(BOOL)moreAnswer btnsTapBlock:(btnsTappedClosure)btnsTapClosure;

@end

NS_ASSUME_NONNULL_END
