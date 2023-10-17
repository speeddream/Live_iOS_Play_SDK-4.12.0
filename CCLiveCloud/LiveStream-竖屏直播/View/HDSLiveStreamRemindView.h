//
//  HDSLiveStreamRemindView.h
//  HDSTestDemo
//
//  Created by richard lee on 1/5/23.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^remindViewCheckBlock)(void);

@interface HDSLiveStreamRemindView : UIView

- (instancetype)initWithFrame:(CGRect)frame checkBlock:(remindViewCheckBlock)closure;

- (void)setDataSource:(NSString *)dataSource;

@end

NS_ASSUME_NONNULL_END
