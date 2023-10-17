//
//  HDSLiveBottomBar.m
//  CCLiveCloud
//
//  Created by richard lee on 4/28/22.
//  Copyright © 2022 MacBook Pro. All rights reserved.
//

#import "HDSLiveBottomBar.h"
#import "UIColor+RCColor.h"
#import "CCcommonDefine.h"
#import "UIView+Extension.h"
#import <Masonry/Masonry.h>

@interface HDSLiveBottomBar ()

@property (nonatomic, strong) UIView *boardBGView;

@property (nonatomic, strong) UILabel *chatLabel;

@property (nonatomic, strong) UIImageView *emojiIV;

@property (nonatomic, strong) UIButton *chatBtn;

@property (nonatomic, strong) UIButton *emojiBtn;

@property (nonatomic, strong) UIButton *moreBtn;

@property (nonatomic, strong) UIButton *otherBtn;

@property (nonatomic, assign) NSTimeInterval moreBtnTapTimeInterval;

@property (nonatomic, assign) NSTimeInterval liveStoreBtnTapTimeInterval;

@end

@implementation HDSLiveBottomBar

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = UIColor.clearColor;
        [self configureUI];
        [self configureConstraints];
    }
    return self;
}

- (void)setLiveStoreSwitch:(NSInteger)liveStoreSwitch {
    _liveStoreSwitch = liveStoreSwitch;
    _otherBtn.hidden = !_liveStoreSwitch;
    if (_isChatSwitch == NO) return;
    [self updateBottomBarConstrintsWithLiveStore];
}

- (void)setIsChatSwitch:(BOOL)isChatSwitch {
    _isChatSwitch = isChatSwitch;
    _boardBGView.hidden = NO;
    if (_isChatSwitch == NO) {
        _boardBGView.hidden = YES;
    }
}

// MARK: - Custom Method
- (void)configureUI {
    
    _boardBGView = [[UIView alloc]init];
    _boardBGView.backgroundColor = [UIColor colorWithHexString:@"#000000" alpha:0.4];
    [self addSubview:_boardBGView];
    
    _chatLabel = [[UILabel alloc]init];
    _chatLabel.textColor = [UIColor colorWithHexString:@"#F7F7F7" alpha:0.85];
    _chatLabel.font = [UIFont systemFontOfSize:13];
    _chatLabel.text = @" 赶快发言吧...";
    [_boardBGView addSubview:_chatLabel];
    
    _emojiIV = [[UIImageView alloc]init];
    _emojiIV.image = [UIImage imageNamed:@"表情可用"];
    _emojiIV.contentMode = UIViewContentModeCenter;
    [_boardBGView addSubview:_emojiIV];
    
    _chatBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_chatBtn addTarget:self action:@selector(chatBtnTap:) forControlEvents:UIControlEventTouchUpInside];
    [_boardBGView addSubview:_chatBtn];
    
    _emojiBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_emojiBtn addTarget:self action:@selector(emojiBtnTap:) forControlEvents:UIControlEventTouchUpInside];
    [_boardBGView addSubview:_emojiBtn];
    
    _moreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_moreBtn setImage:[UIImage imageNamed:@"更多大"] forState:UIControlStateNormal];
    [_moreBtn addTarget:self action:@selector(moreBtnTap:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_moreBtn];
    
    _otherBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_otherBtn setImage:[UIImage imageNamed:@"直播带货"] forState:UIControlStateNormal];
    [_otherBtn addTarget:self action:@selector(otherBtnTap:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_otherBtn];
    
}

- (void)configureConstraints {
    __weak typeof(self) weakSelf = self;
    CGFloat BGViewW = SCREEN_WIDTH / 375 * 250;
    [_boardBGView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf).offset(7);
        make.left.mas_equalTo(weakSelf).offset(15);
        make.width.mas_equalTo(BGViewW);
        make.height.mas_equalTo(35);
    }];
    _boardBGView.layer.cornerRadius = 17.5;
    _boardBGView.layer.masksToBounds = YES;
    
    [_chatLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.boardBGView).offset(10);
        make.centerY.mas_equalTo(weakSelf.boardBGView);
        make.right.mas_equalTo(weakSelf.boardBGView).offset(-35);
        make.height.mas_equalTo(30);
    }];
    
    [_emojiIV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(weakSelf.boardBGView).offset(-6.5);
        make.centerY.mas_equalTo(weakSelf.boardBGView);
        make.width.height.mas_equalTo(22);
    }];
    _emojiIV.layer.cornerRadius = _emojiIV.height / 2;
    _emojiIV.layer.masksToBounds = YES;
    
    [_chatBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(weakSelf.chatLabel);
    }];
    
    [_emojiBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(weakSelf.emojiIV);
    }];
    
    [_moreBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(weakSelf).offset(-15);
        make.top.mas_equalTo(weakSelf).offset(7);
        make.width.height.mas_equalTo(36);
    }];
    
    [_otherBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(weakSelf.moreBtn.mas_left).offset(-12);
        make.centerY.mas_equalTo(weakSelf.moreBtn.mas_centerY);
        make.width.height.mas_equalTo(36);
    }];
}

- (void)updateBottomBarConstrintsWithLiveStore {
    /*
     |-10-聊天-12-直播带货-12-更多-15-|
     |-10-聊天-12-更多-15-|
     */
    CGFloat boardBGViewW = _liveStoreSwitch == YES ? SCREEN_WIDTH - 15 - 35 - 12 - 35 - 12 - 10 : SCREEN_WIDTH - 15 - 35 - 12 - 10;
    [_boardBGView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(boardBGViewW);
    }];
}

// MARK: - TapEvent
- (void)chatBtnTap:(UIButton *)sender {
    NSLog(@"%s",__func__);
    if (self.chatBtnTapClosure) {
        self.chatBtnTapClosure();
    }
}

- (void)emojiBtnTap:(UIButton *)sender {
    NSLog(@"%s",__func__);
    if (self.emojiBtnTapClosure) {
        self.emojiBtnTapClosure();
    }
}

- (void)moreBtnTap:(UIButton *)sender {
    NSLog(@"%s",__func__);
    NSTimeInterval nowTimeInterval = [[NSDate date] timeIntervalSince1970];
    if (nowTimeInterval - self.moreBtnTapTimeInterval < 1) {
        return;
    }
    self.moreBtnTapTimeInterval = nowTimeInterval;
    if (self.moreBtnTapClosure) {
        self.moreBtnTapClosure();
    }
}

- (void)otherBtnTap:(UIButton *)sender {
    NSLog(@"%s",__func__);
    NSTimeInterval nowTimeInterval = [[NSDate date] timeIntervalSince1970];
    if (nowTimeInterval - self.liveStoreBtnTapTimeInterval < 1) {
        return;
    }
    self.liveStoreBtnTapTimeInterval = nowTimeInterval;
    if (self.otherBtnTapClosure) {
        self.otherBtnTapClosure();
    }
}

@end
