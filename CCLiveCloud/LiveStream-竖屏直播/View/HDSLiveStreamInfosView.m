//
//  HDSLiveStreamInfosView.m
//  CCLiveCloud
//
//  Created by Apple on 2022/12/15.
//  Copyright © 2022 MacBook Pro. All rights reserved.
//

#import "HDSLiveStreamInfosView.h"
#import "UIImageView+Extension.h"
#import "UIColor+RCColor.h"
#import "UIView+Extension.h"
#import <Masonry/Masonry.h>

@interface HDSLiveStreamInfosView ()

@property (nonatomic, strong) UIView *backgroundView;

@property (nonatomic, strong) UIImageView *headerIcon;

@property (nonatomic, strong) UILabel *mainTitle;

@property (nonatomic, strong) UIImageView *userCountIMGView;

@property (nonatomic, strong) UILabel *userCountLabel;

@property (nonatomic, strong) UIButton *customBtn;

@property (nonatomic, copy)   customBtnTapBlock callBackBlock;
@end

@implementation HDSLiveStreamInfosView

// MARK: - API
- (instancetype)initWithFrame:(CGRect)frame btnTapClosure:(nonnull customBtnTapBlock)closure {
    if (self = [super initWithFrame:frame]) {
        if (closure) {
            _callBackBlock = closure;
        }
        __weak typeof(self) weakSelf = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf configureUI];
            [weakSelf configureConstraints];
        });
    }
    return self;
}

/// 根据类型设置控件约束
/// @param type 类型
- (void)setType:(HDSLiveStreamInfosViewType)type {
    switch (type) {
        case HDSLiveStreamInfosViewType_NoUserCount: {
            [self updateConstraintsWithNoUserCount];
        } break;
            
        case HDSLiveStreamInfosViewType_NoHeaderIcon: {
            [self updateConstraintsWithNoHeaderIcon];
        } break;
            
        case HDSLiveStreamInfosViewType_NoHeaderIcon_NoUserCount: {
            [self updateConstraintsWithNoHeaderIconAndNoUserCount];
        } break;
            
        case HDSLiveStreamInfosViewType_Normal: {
            [self updateConstraintsWithNormal];
        }break;
            
        default:
            break;
    }
}

- (void)setHeaderIconWithUrl:(NSString *)url {
    [self.headerIcon setHeader:url];
}

- (void)setMainTitleWithName:(NSString *)name {
    if (name.length > 0) {
        self.mainTitle.text = name;
    }
}

- (void)setUserCountWithCount:(NSString *)count {
    if (count.length > 0) {
        self.userCountLabel.text = count;
    }
}

// MARK: - customUI
- (void)configureUI {
    
    _backgroundView = [[UIView alloc]init];
    _backgroundView.backgroundColor = [UIColor colorWithHexString:@"#000000" alpha:0.4];
    [self addSubview:_backgroundView];
    
    _headerIcon = [[UIImageView alloc]init];
    _headerIcon.backgroundColor = [UIColor colorWithHexString:@"#334455" alpha:1];
    _headerIcon.contentMode = UIViewContentModeScaleToFill;
    [_backgroundView addSubview:_headerIcon];
    
    _mainTitle = [[UILabel alloc]init];
    _mainTitle.textColor = [UIColor colorWithHexString:@"#FFFFFF" alpha:1];
    _mainTitle.font = [UIFont boldSystemFontOfSize:14];
    _mainTitle.textAlignment = NSTextAlignmentLeft;
    [_backgroundView addSubview:_mainTitle];
    
    _userCountIMGView = [[UIImageView alloc]init];
    [_userCountIMGView setImage:[UIImage imageNamed:@"人数"]];
    _userCountIMGView.contentMode = UIViewContentModeCenter;
    [_backgroundView addSubview:_userCountIMGView];
    
    _userCountLabel = [[UILabel alloc]init];
    _userCountLabel.textColor = [UIColor colorWithHexString:@"#FFFFFF" alpha:1];
    _userCountLabel.font = [UIFont systemFontOfSize:12];
    _userCountLabel.textAlignment = NSTextAlignmentLeft;
    [_backgroundView addSubview:_userCountLabel];
    
    _customBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_backgroundView addSubview:_customBtn];
    [_customBtn addTarget:self action:@selector(custonBtnTap) forControlEvents:UIControlEventTouchUpInside];
}

- (void)configureConstraints {
    
    __weak typeof(self) weakSelf = self;
    [_backgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(weakSelf);
    }];
    [_backgroundView layoutIfNeeded];
    [_backgroundView setCornerRadius:23.5 addRectCorners:UIRectCornerAllCorners];
    
    [_headerIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.mas_equalTo(weakSelf.backgroundView).offset(6);
        make.width.height.mas_equalTo(35);
    }];
    [_headerIcon layoutIfNeeded];
    [_headerIcon setCornerRadius:17.5 addRectCorners:UIRectCornerAllCorners];
    
    [_mainTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.backgroundView).offset(6);
        make.left.mas_equalTo(weakSelf.headerIcon.mas_right).offset(8);
        make.right.mas_equalTo(weakSelf.backgroundView).offset(-8);
        make.height.mas_equalTo(20);
    }];
    
    [_userCountIMGView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.mainTitle.mas_bottom).offset(3);
        make.left.mas_equalTo(weakSelf.mainTitle.mas_left);
        make.width.mas_equalTo(11);
        make.height.mas_equalTo(12);
    }];
    
    [_userCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.userCountIMGView.mas_right).offset(3);
        make.right.mas_equalTo(weakSelf.backgroundView).offset(-5);
        make.centerY.mas_equalTo(weakSelf.userCountIMGView.mas_centerY);
        make.height.mas_equalTo(12);
    }];
    
    [_customBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(weakSelf.backgroundView);
    }];
}

- (void)updateConstraintsWithNormal {
    
    __weak typeof(self) weakSelf = self;
    [_headerIcon mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.left.mas_equalTo(weakSelf.backgroundView).offset(6);
        make.width.height.mas_equalTo(35);
    }];
    [_headerIcon layoutIfNeeded];
    [_headerIcon setCornerRadius:17.5 addRectCorners:UIRectCornerAllCorners];
    
    [_mainTitle mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.backgroundView).offset(6);
        make.left.mas_equalTo(weakSelf.headerIcon.mas_right).offset(8);
        make.right.mas_equalTo(weakSelf.backgroundView).offset(-8);
        make.height.mas_equalTo(20);
    }];
    
    [_userCountIMGView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.mainTitle.mas_bottom).offset(3);
        make.left.mas_equalTo(weakSelf.mainTitle.mas_left);
        make.width.mas_equalTo(11);
        make.height.mas_equalTo(12);
    }];
    
    [_userCountLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.userCountIMGView.mas_right).offset(3);
        make.right.mas_equalTo(weakSelf.backgroundView).offset(-5);
        make.centerY.mas_equalTo(weakSelf.userCountIMGView.mas_centerY);
        make.height.mas_equalTo(12);
    }];
}

- (void)updateConstraintsWithNoUserCount {
    
    __weak typeof(self) weakSelf = self;
    [_headerIcon mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.left.mas_equalTo(weakSelf.backgroundView).offset(6);
        make.width.height.mas_equalTo(35);
    }];
    [_headerIcon layoutIfNeeded];
    [_headerIcon setCornerRadius:17.5 addRectCorners:UIRectCornerAllCorners];
    
    
    [_mainTitle mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.headerIcon.mas_right).offset(8);
        make.right.mas_equalTo(weakSelf.backgroundView).offset(-8);
        make.centerY.mas_equalTo(weakSelf.backgroundView);
        make.height.mas_equalTo(20);
    }];
    [_mainTitle layoutIfNeeded];
    
    [_userCountIMGView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(0);
    }];
    [_userCountIMGView layoutIfNeeded];
    
    [_userCountLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(0);
    }];
    [_userCountLabel layoutIfNeeded];
}

- (void)updateConstraintsWithNoHeaderIcon {
    __weak typeof(self) weakSelf = self;
    [_headerIcon mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(0);
    }];
    [_headerIcon layoutIfNeeded];
    
    [_mainTitle mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.backgroundView).offset(6);
        make.left.mas_equalTo(weakSelf.backgroundView).offset(16);
        make.right.mas_equalTo(weakSelf.backgroundView).offset(-8);
        make.height.mas_equalTo(20);
    }];
    [_mainTitle layoutIfNeeded];
    
    [_userCountIMGView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.mainTitle.mas_bottom).offset(3);
        make.left.mas_equalTo(weakSelf.mainTitle.mas_left);
        make.width.mas_equalTo(11);
        make.height.mas_equalTo(12);
    }];
    
    [_userCountLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.userCountIMGView.mas_right).offset(3);
        make.right.mas_equalTo(weakSelf.backgroundView).offset(-5);
        make.centerY.mas_equalTo(weakSelf.userCountIMGView.mas_centerY);
        make.height.mas_equalTo(12);
    }];
}

- (void)updateConstraintsWithNoHeaderIconAndNoUserCount {
    __weak typeof(self) weakSelf = self;
    [_headerIcon mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(0);
    }];
    [_headerIcon layoutIfNeeded];
    
    [_mainTitle mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.backgroundView).offset(16);
        make.centerY.mas_equalTo(weakSelf.backgroundView);
        make.right.mas_equalTo(weakSelf.backgroundView).offset(-8);
        make.height.mas_equalTo(20);
    }];
    [_mainTitle layoutIfNeeded];
    
    [_userCountIMGView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(0);
    }];
    [_userCountIMGView layoutIfNeeded];
    
    [_userCountLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(0);
    }];
    [_userCountLabel layoutIfNeeded];
}

- (void)custonBtnTap {
    if (_callBackBlock) {
        _callBackBlock();
    }
}

@end
