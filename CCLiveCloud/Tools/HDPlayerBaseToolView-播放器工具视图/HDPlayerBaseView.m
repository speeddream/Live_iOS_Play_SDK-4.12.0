//
//  HDPlayerBaseView.m
//  CCLiveCloud
//
//  Created by Apple on 2021/2/24.
//  Copyright © 2021 MacBook Pro. All rights reserved.
//

#import "HDPlayerBaseView.h"
#import "UIColor+RCColor.h"
#import "CCcommonDefine.h"

@interface HDPlayerBaseView ()

@property (nonatomic, strong) UIButton *bgButton;

@end

@implementation HDPlayerBaseView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithHexString:@"#000000" alpha:0.1];
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    _bgButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _bgButton.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    [_bgButton addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_bgButton];
}

- (void)btnClick {
    if (self.touchBegin) {
        self.touchBegin(@"");
    }
}
@end
