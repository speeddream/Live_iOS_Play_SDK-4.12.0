//
//  HDCoustomButtom.h
//  CCLiveCloud
//
//  Created by Richard Lee on 3/31/21.
//  Copyright © 2021 MacBook Pro. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, HDButtonTextAlignment) {
    HDButtonTextAlignmentLeft,
    HDButtonTextAlignmentCenter,
    HDButtonTextAlignmentRight,
};

@interface HDCoustomButtom : UIButton

@property (nonatomic, strong) UILabel               *btnTitleLabel;

@property (nonatomic, strong) UIFont                *titleFont;

@property (nonatomic, strong) UIColor               *titleColor;

@property (nonatomic, strong) UIColor               *selectedTitleColor;

@property (nonatomic, assign) HDButtonTextAlignment textAlignment;

@property (nonatomic, assign) BOOL                  isSelected;

- (instancetype)initWithFrame:(CGRect)frame textAlignment:(HDButtonTextAlignment)textAlignment;

@end

NS_ASSUME_NONNULL_END
