//
//  HDSAnnouncementView.m
//  CCLiveCloud
//
//  Created by richard lee on 1/9/23.
//  Copyright © 2023 MacBook Pro. All rights reserved.
//

#import "HDSAnnouncementView.h"
#import "UIColor+RCColor.h"
#import "CCcommonDefine.h"
#import <Masonry/Masonry.h>

@interface HDSAnnouncementView ()

@property (nonatomic, copy) closeBtnTapBlock closeBtnTapBlock;

@property (nonatomic, strong) UIButton *topBtn;

@property (nonatomic, strong) UIView *BGView;

@property (nonatomic, strong) UIButton *closeBtn;

@property (nonatomic, strong) UILabel *mainTitle;

@property (nonatomic, strong) UILabel *snipLine;

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) UILabel *announcementLabel;

@property (nonatomic, copy)   NSString *announcementText;

@end

@implementation HDSAnnouncementView

// MARK: - API
/// 初始化公告
/// - Parameter str: 公告信息
- (instancetype)initWithAnnouncementStr:(NSString *)str  closeBtnTapClosure:(nonnull closeBtnTapBlock)closure {
    if (self = [super init]) {
        
        if (closure) {
            _closeBtnTapBlock = closure;
        }
        
        self.backgroundColor = [UIColor colorWithHexString:@"#000000" alpha:0];
        if (str.length == 0) {
            str = @"暂无公告";
        }
        _announcementText = str;
        [self configureUI];
        [self configureConstraints];
    }
    return self;
}

/// 更新公告
/// - Parameter str: 公告信息
- (void)updateViews:(NSString *)str {
    if (str.length == 0) {
        str = @"暂无公告";
    }
    _announcementLabel.text = str;
}

// MARK: - Custom Method

- (void)configureUI {
    
    _topView = [[UIView alloc]init];
    [self addSubview:_topView];
    
    _topBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self addSubview:_topBtn];
    [_topBtn addTarget:self action:@selector(topBtnTapped) forControlEvents:UIControlEventTouchUpInside];
    
    _BGView = [[UIView alloc]init];
    _BGView.backgroundColor = [UIColor colorWithHexString:@"#FFFFFF" alpha:1];
    [self addSubview:_BGView];
    
    _closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_closeBtn setImage:[UIImage imageNamed:@"popup_close"] forState:UIControlStateNormal];
    [_BGView addSubview:_closeBtn];
    [_closeBtn addTarget:self action:@selector(closeBtnTapAction:) forControlEvents:UIControlEventTouchUpInside];
    
    _mainTitle = [[UILabel alloc]init];
    _mainTitle.text = @"公告";
    _mainTitle.textColor = [UIColor colorWithHexString:@"#333333" alpha:1];
    _mainTitle.font = [UIFont systemFontOfSize:15];
    _mainTitle.textAlignment = NSTextAlignmentCenter;
    [_BGView addSubview:_mainTitle];
    
    _snipLine = [[UILabel alloc]init];
    _snipLine.backgroundColor = [UIColor colorWithHexString:@"#E8E9EB" alpha:1];
    [_BGView addSubview:_snipLine];
    
    _scrollView = [[UIScrollView alloc]init];
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    [_BGView addSubview:_scrollView];

    _announcementLabel = [[UILabel alloc]init];
    _announcementLabel.textColor = [UIColor colorWithHexString:@"#333333" alpha:1];
    _announcementLabel.font = [UIFont systemFontOfSize:14];
    _announcementLabel.numberOfLines = 0;
    _announcementLabel.lineBreakMode = NSLineBreakByCharWrapping;
    _announcementLabel.text = _announcementText;
    [_scrollView addSubview:_announcementLabel];
}

- (void)configureConstraints {
    __weak typeof(self) weakSelf = self;
    
    [_topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(weakSelf);
        make.bottom.mas_equalTo(weakSelf.BGView.mas_top);
    }];
    
    [_topBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(weakSelf);
    }];
    
    [_BGView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf).offset(SCREEN_HEIGHT - 406);
        make.left.bottom.right.mas_equalTo(weakSelf);
    }];
    
    [_closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.BGView).offset(6);
        make.right.mas_equalTo(weakSelf.BGView).offset(-15);
        make.width.mas_equalTo(30);
        make.height.mas_equalTo(30);
    }];
    
    [_mainTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(weakSelf.BGView);
        make.top.mas_equalTo(weakSelf.BGView).offset(6);
        make.width.mas_equalTo(60);
        make.height.mas_equalTo(30);
    }];
    
    [_snipLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.closeBtn.mas_bottom).offset(6);
        make.left.right.mas_equalTo(weakSelf.BGView);
        make.height.mas_equalTo(0.5);
    }];
    
    [_scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.snipLine.mas_bottom);
        make.left.bottom.right.mas_equalTo(weakSelf.BGView);
    }];
    
    [_announcementLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.scrollView).offset(10);
        make.left.mas_equalTo(weakSelf.scrollView).offset(15);
        make.bottom.mas_equalTo(weakSelf.scrollView).offset(-10);
        make.right.mas_equalTo(weakSelf.scrollView).offset(-15);
        make.width.mas_equalTo(SCREEN_WIDTH-30);
    }];
    [_announcementLabel layoutIfNeeded];
}

// MARK: - TapEvent
- (void)closeBtnTapAction:(UIButton *)sender {
    if (_closeBtnTapBlock) {
        _closeBtnTapBlock();
    }
}

- (void)topBtnTapped {
    if (_closeBtnTapBlock) {
        _closeBtnTapBlock();
    }
}
@end
