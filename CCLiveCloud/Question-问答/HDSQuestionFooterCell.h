//
//  HDSQuestionFooterCell.h
//  CCLiveCloud
//
//  Created by richard lee on 3/16/23.
//  Copyright © 2023 MacBook Pro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^buttonTappedBlock)(BOOL isOpen, NSInteger section);

@interface HDSQuestionFooterCell : UITableViewCell

- (void)setDataOpen:(BOOL)open otherCount:(int)otherCount section:(NSInteger)section closure:(buttonTappedBlock)closure;

@end

NS_ASSUME_NONNULL_END
