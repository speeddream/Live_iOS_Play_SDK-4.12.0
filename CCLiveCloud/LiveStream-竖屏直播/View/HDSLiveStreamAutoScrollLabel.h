//
//  HDSLiveStreamAutoScrollLabel.h
//  CCLiveCloud
//
//  Created by richard lee on 12/19/22.
//  Copyright © 2022 MacBook Pro. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger,DirtionType) {
    DirtionTypeLeft, //left
    DirtionTypeRight //right
};

@interface HDSLiveStreamAutoScrollLabel : UIScrollView

//set Text
@property (nonatomic, copy) NSString *text;
// label and label gap
@property (nonatomic, assign) NSInteger labelBetweenGap;
//deafult 2 秒
@property (nonatomic, assign) NSInteger pauseTime;
//deafult DirtionTypeLeft
@property (nonatomic, assign) DirtionType dirtionType;
//set speed ,default 30
@property (nonatomic, assign) NSInteger speed;
//set Color
@property (nonatomic, strong) UIColor  *textColor;

- (void)rejustlabels;
@end

NS_ASSUME_NONNULL_END
