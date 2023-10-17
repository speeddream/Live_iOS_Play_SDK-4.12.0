//
//  CCChatInputView.m
//  CCLiveCloud
//
//  Created by Chenfy on 2023/3/9.
//  Copyright © 2023 MacBook Pro. All rights reserved.
//

#import "CCChatInputView.h"
#import <Masonry/Masonry.h>

@interface CCChatInputView ()
@property(nonatomic,strong)UIButton *normal;
@property(nonatomic,strong)UIButton *custom;
@property(nonatomic,strong)UIButton *resign;

@end
@implementation CCChatInputView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)init {
    if(self = [super init]) {
        self.layer.backgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1].CGColor;
        self.layer.shadowColor = [UIColor colorWithRed:221/255.0 green:221/255.0 blue:221/255.0 alpha:1].CGColor;
        self.layer.shadowOffset = CGSizeMake(0,1);
        self.layer.shadowOpacity = 1;
        self.layer.shadowRadius = 0;

        self.layer.borderWidth = 0.5;
        self.layer.borderColor = UIColor.lightGrayColor.CGColor;
    }
    return self;
}


- (void)addButtonEmojiNormal:(UIButton *)sender {
    _normal = sender;
    [self addSubview:sender];
    [sender mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self).offset(12);
        make.top.mas_equalTo(self).offset(5);
        make.bottom.mas_equalTo(self).offset(-5);
        make.width.mas_equalTo(48);
    }];
}
- (void)addButtonEmojiCustom:(UIButton *)sender {
    _custom = sender;
    [self addSubview:sender];
    [sender mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.width.height.mas_equalTo(self.normal);
        make.left.mas_equalTo(self.normal.mas_right).offset(6);
    }];
}
- (void)addButtonEmojiKeyBoardResign:(UIButton *)sender {
    _resign = sender;
    [self addSubview:sender];
    [sender mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.width.height.mas_equalTo(self.normal);
        make.right.mas_equalTo(self).offset(-12);
    }];
}

@end
