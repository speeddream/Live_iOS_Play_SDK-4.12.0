//
//  HDSPrivacyView.h
//  CCClassRoom
//
//  Created by 刘强强 on 2022/9/7.
//  Copyright © 2022 cc. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, HDSCallBackActionType) {
    HDSCallBackActionType_OK = 1,
    HDSCallBackActionType_YINSI = 2,
    HDSCallBackActionType_FUWU = 3,
};

typedef void(^HDSCallBackAction)(HDSCallBackActionType actionType);

@interface HDSPrivacyView : UIView

+ (HDSPrivacyView *)showView:(NSString *)title contentText:(NSString *)contentText heighlighted:(NSString *)heighlighted heightlightedSecd:(NSString *)heightlightedSecd
                   superRect:(CGRect)rect callBack:(HDSCallBackAction)callBack;
- (void)remoeView;

@end

NS_ASSUME_NONNULL_END
