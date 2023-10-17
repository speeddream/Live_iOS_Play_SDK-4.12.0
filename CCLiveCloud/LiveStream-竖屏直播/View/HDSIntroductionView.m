//
//  HDSIntroductionView.m
//  CCLiveCloud
//
//  Created by richard lee on 1/9/23.
//  Copyright © 2023 MacBook Pro. All rights reserved.
//

#import "HDSIntroductionView.h"
#import <WebKit/WebKit.h>
#import "UIColor+RCColor.h"
#import "CCcommonDefine.h"
#import "UIImageView+Extension.h"
#import <Masonry/Masonry.h>

@interface HDSIntroductionView ()
/// 关闭按钮回调
@property (nonatomic, copy)  introductionCloseBtnTapBlock callBack;

@property (nonatomic, strong) UIButton *topBtn;
/// 白色背景视图
@property (nonatomic, strong) UIView *BGView;
/// 关闭按钮
@property (nonatomic, strong) UIButton *closeBtn;
/// 简介提示语
@property (nonatomic, strong) UILabel *mainTitle;
/// 第一条分割线
@property (nonatomic, strong) UILabel *snipLine;
/// scrollView
@property (nonatomic, strong) UIScrollView *scrollView;
/// 房间信息视图
@property (nonatomic, strong) UIView *infosView;
/// 房间icon
@property (nonatomic, strong) UIImageView *headerIcon;
/// 房间名称
@property (nonatomic, strong) UILabel *roomTitle;
/// 直播中IMGView
@property (nonatomic, strong) UIImageView *animIMGView;
/// 非直播状态IMGView
@property (nonatomic, strong) UIImageView *liveStatsIMGView;
/// 直播状态
@property (nonatomic, strong) UILabel *roomLiveStatus;
/// ｜ 分割线
@property (nonatomic, strong) UILabel *snipLine2;
/// 在线人数图标
@property (nonatomic, strong) UIImageView *userCountIMGView;
/// 在线人数
@property (nonatomic, strong) UILabel *userCountLabel;
/// 分割线3
@property (nonatomic, strong) UILabel *snipLine3;

@property (nonatomic, strong) UIImageView *introductionIMG;
/// webView
@property (nonatomic, strong) WKWebView *web;

@property (nonatomic, strong) UIImageView *noDataIMG;

@property (nonatomic, strong) UILabel *noDataLabel;

/// 房间icon
@property (nonatomic, copy)   NSString *roomIcon;
/// 房间在线人数
@property (nonatomic, copy)   NSString *roomOnlineUserCount;
/// 房间是否展示在线人数
@property (nonatomic, assign) BOOL showUserCount;
/// 动画数组
@property (nonatomic, strong) NSMutableArray *animArrays;

@end

@implementation HDSIntroductionView

// MARK: - API
/// 初始化
/// - Parameters:
///   - frame: 布局
///   - closure: 关闭按钮回调
- (instancetype)initWithFrame:(CGRect)frame closeBtnTapClosure:(introductionCloseBtnTapBlock)closure {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor colorWithHexString:@"#000000" alpha:0];
        if (closure) {
            _callBack = closure;
        }
        [self.animArrays removeAllObjects];
        for (int i = 1; i < 4; i++) {
            NSString *imageName = [NSString stringWithFormat:@"直播中_%d",i];
            UIImage *image = [UIImage imageNamed:imageName];
            [self.animArrays addObject:image];
        }
        [self configureUI];
        [self configureConstraints];
    }
    return self;
}

- (void)roomInfo:(NSDictionary *)dic {
    NSString *desc = @"暂无简介";
    NSString *roomName = @"直播间名称";
    // 房间名
    if ([dic.allKeys containsObject:@"name"]) {
        roomName = dic[@"name"];
        if (roomName.length == 0) {
            if ([dic.allKeys containsObject:@"baseRecordInfo"]) {
                NSDictionary *baseRecordInfo = dic[@"baseRecordInfo"];
                if ([baseRecordInfo.allKeys containsObject:@"title"]) {
                    roomName = baseRecordInfo[@"title"];
                }
            }
        }
    }
    // 简介
    if ([dic.allKeys containsObject:@"desc"]) {
        desc = dic[@"desc"];
        if (desc.length == 0) {
            if ([dic.allKeys containsObject:@"baseRecordInfo"]) {
                NSDictionary *baseRecordInfo = dic[@"baseRecordInfo"];
                if ([baseRecordInfo.allKeys containsObject:@"description"]) {
                    desc = baseRecordInfo[@"description"];
                }
            }
        }
    }
    
    // 是否展示房间人数
    if ([dic.allKeys containsObject:@"showUserCount"]) {
        self.showUserCount = [dic[@"showUserCount"] boolValue];
        _userCountLabel.hidden = !_showUserCount;
        _userCountIMGView.hidden = !_showUserCount;
        _snipLine2.hidden = !_showUserCount;
        [self updateRoomInfos];
    }
    
    [self setRoomTitleWithName:roomName];
    if (desc.length == 0) {
        desc = @"暂无简介";
        self.noDataIMG.hidden = NO;
        self.noDataLabel.hidden = NO;
        self.web.hidden = YES;
        return;
    }
    self.noDataIMG.hidden = YES;
    self.noDataLabel.hidden = YES;
    self.web.hidden = NO;
    NSString *headerString = @"<header><meta name='viewport' content='width=device-width, user-scalable=no'><style>img{max-width:100% !important; height:auto!important;}</style></header>";
    [_web loadHTMLString:[headerString stringByAppendingString:desc] baseURL:nil];
}

/// 设置房间icon
/// - Parameter url: 头像地址
- (void)setHomeIconWithUrl:(NSString *)url {
    self.roomIcon = url;
    if (url.length == 0) {
        return;
    }
    if (_infosView) {
        [self updateRoomInfos];
        [self.headerIcon setHeader:url];
    }
}

/// 设置房间标题
/// - Parameter name: 标题
- (void)setRoomTitleWithName:(NSString *)name {
    if (_infosView) {
        _roomTitle.text = name;
        [self updateRoomInfos];
    }
}

/// 设置房间人数
/// - Parameter count: 人数
- (void)setRoomOnlineUserCountWithCount:(NSString *)count {
    self.roomOnlineUserCount = count;
    if (_infosView) {
        [self updateRoomInfos];
        _userCountLabel.text = count;
    }
}

/// 更新房间直播状态
/// - Parameter state: 是否已开播
- (void)roomLiveStatus:(BOOL)state {
    if (state) {
        _roomLiveStatus.text = @"直播中";
        _roomLiveStatus.textColor = [UIColor colorWithHexString:@"#FF842F" alpha:1];
        _animIMGView.hidden = NO;
        _liveStatsIMGView.hidden = YES;
        
        _animIMGView.animationImages = self.animArrays;
        _animIMGView.animationRepeatCount = 0;
        _animIMGView.animationDuration = 0.35;
        [_animIMGView startAnimating];
    } else {
        
        _liveStatsIMGView.hidden = NO;
        _animIMGView.hidden = YES;
        _roomLiveStatus.textColor = [UIColor colorWithHexString:@"#999999" alpha:1];
        _roomLiveStatus.text = @"已结束";
    }
}

/// 当前房间直播状态
/// - Parameter state: 0.正在直播 1.未开始直播
- (void)currentRoomLiveStatus:(NSInteger)state {
    if (state == 0) {
        // 直播中
        _roomLiveStatus.text = @"直播中";
        _roomLiveStatus.textColor = [UIColor colorWithHexString:@"#FF842F" alpha:1];
        _animIMGView.hidden = NO;
        _liveStatsIMGView.hidden = YES;
        
        _animIMGView.animationImages = self.animArrays;
        _animIMGView.animationRepeatCount = 0;
        _animIMGView.animationDuration = 0.35;
        [_animIMGView startAnimating];
    } else {
        // 直播未开始
        _liveStatsIMGView.hidden = NO;
        _animIMGView.hidden = YES;
        _roomLiveStatus.textColor = [UIColor colorWithHexString:@"#999999" alpha:1];
        _roomLiveStatus.text = @"待直播";
    }
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
    _mainTitle.text = @"简介";
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
    
    _infosView = [[UIView alloc]init];
    [_scrollView addSubview:_infosView];
    
    _headerIcon = [[UIImageView alloc]init];
    _headerIcon.backgroundColor = [UIColor colorWithHexString:@"#334455" alpha:1];
    _headerIcon.contentMode = UIViewContentModeScaleAspectFit;
    [_infosView addSubview:_headerIcon];
    
    _roomTitle = [[UILabel alloc]init];
    _roomTitle.textColor = [UIColor colorWithHexString:@"#333333" alpha:1];
    _roomTitle.font = [UIFont boldSystemFontOfSize:16];
    _roomTitle.textAlignment = NSTextAlignmentLeft;
    [_infosView addSubview:_roomTitle];
    
    _animIMGView = [[UIImageView alloc]init];
    _animIMGView.contentMode = UIViewContentModeCenter;
    [_infosView addSubview:_animIMGView];
    
    _liveStatsIMGView = [[UIImageView alloc]init];
    _liveStatsIMGView.contentMode = UIViewContentModeCenter;
    _liveStatsIMGView.image = [UIImage imageNamed:@"待直播"];
    [_infosView addSubview:_liveStatsIMGView];
    
    _roomLiveStatus = [[UILabel alloc]init];
    _roomLiveStatus.text = @"待直播";
    _roomLiveStatus.textColor = [UIColor colorWithHexString:@"#999999" alpha:1];
    _roomLiveStatus.font = [UIFont boldSystemFontOfSize:12];
    _roomLiveStatus.textAlignment = NSTextAlignmentCenter;
    [_infosView addSubview:_roomLiveStatus];
    
    _snipLine2 = [[UILabel alloc]init];
    _snipLine2.backgroundColor = [UIColor colorWithHexString:@"#000000" alpha:0.2];
    [_infosView addSubview:_snipLine2];
    
    _userCountIMGView = [[UIImageView alloc]init];
    [_userCountIMGView setImage:[UIImage imageNamed:@"人数_灰色"]];
    _userCountIMGView.contentMode = UIViewContentModeCenter;
    [_infosView addSubview:_userCountIMGView];
    
    _userCountLabel = [[UILabel alloc]init];
    _userCountLabel.textColor = [UIColor colorWithHexString:@"#999999" alpha:1];
    _userCountLabel.font = [UIFont systemFontOfSize:12];
    _userCountLabel.textAlignment = NSTextAlignmentLeft;
    [_infosView addSubview:_userCountLabel];
    
    _snipLine3 = [[UILabel alloc]init];
    _snipLine3.backgroundColor = [UIColor colorWithHexString:@"#E8E9EB" alpha:1];
    [_infosView addSubview:_snipLine3];
    
    _introductionIMG = [[UIImageView alloc]init];
    _introductionIMG.image = [UIImage imageNamed:@"简介头部"];
    _introductionIMG.contentMode = UIViewContentModeCenter;
    [_scrollView addSubview:_introductionIMG];
    
    _noDataIMG = [[UIImageView alloc]init];
    _noDataIMG.image = [UIImage imageNamed:@"暂无简介"];
    [_scrollView addSubview:_noDataIMG];
    
    _noDataLabel = [[UILabel alloc]init];
    _noDataLabel.text = @"暂无简介";
    _noDataLabel.font = [UIFont systemFontOfSize:15];
    _noDataLabel.textColor = [UIColor colorWithHexString:@"#999999" alpha:1];
    _noDataLabel.textAlignment = NSTextAlignmentCenter;
    [_scrollView addSubview:_noDataLabel];
    
    WKWebView *web = [[WKWebView alloc] init];
    web.backgroundColor = [UIColor whiteColor];
    web.scrollView.showsHorizontalScrollIndicator = NO;
    web.scrollView.showsVerticalScrollIndicator = NO;
    web.scrollView.bouncesZoom = NO;
    web.opaque = NO;
    [_scrollView addSubview:web];
    _web = web;
    
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
        make.top.mas_equalTo(weakSelf).offset(SCREEN_HEIGHT - 516);
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
    
    [_infosView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.scrollView);
        make.left.mas_equalTo(weakSelf.scrollView);
        make.width.mas_equalTo(SCREEN_WIDTH);
        make.height.mas_equalTo(65);
    }];
    
    [_headerIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.infosView).offset(15);
        make.left.mas_equalTo(weakSelf.infosView).offset(15);
        make.width.mas_equalTo(35);
        make.height.mas_equalTo(35);
    }];
    
    [_roomTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.infosView).offset(13);
        make.left.mas_equalTo(weakSelf.headerIcon.mas_right).offset(10);
        make.right.mas_equalTo(weakSelf.infosView).offset(-15);
        make.height.mas_equalTo(20);
    }];
    
    [_animIMGView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.headerIcon.mas_right).offset(10);
        make.bottom.mas_equalTo(weakSelf.infosView).offset(-13);
        make.width.height.mas_equalTo(15);
    }];
    
    [_liveStatsIMGView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.headerIcon.mas_right).offset(10);
        make.bottom.mas_equalTo(weakSelf.infosView).offset(-13);
        make.width.height.mas_equalTo(15);
    }];
    
    [_roomLiveStatus mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.animIMGView.mas_right);
        make.centerY.mas_equalTo(weakSelf.animIMGView.mas_centerY);
        make.width.mas_equalTo(40);
    }];
    
    [_snipLine2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.roomLiveStatus.mas_right).offset(6);
        make.centerY.mas_equalTo(weakSelf.animIMGView.mas_centerY);
        make.width.mas_equalTo(1);
        make.height.mas_equalTo(12);
    }];
    
    [_userCountIMGView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.snipLine2.mas_right).offset(6);
        make.centerY.mas_equalTo(weakSelf.animIMGView.mas_centerY);
        make.width.mas_equalTo(11);
        make.height.mas_equalTo(12);
    }];
    
    [_userCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.userCountIMGView.mas_right).offset(2);
        make.right.mas_equalTo(weakSelf.infosView).offset(-5);
        make.centerY.mas_equalTo(weakSelf.userCountIMGView.mas_centerY);
        make.height.mas_equalTo(12);
    }];
    
    [_snipLine3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(weakSelf.infosView);
        make.height.mas_equalTo(0.5);
    }];
    
    [_introductionIMG mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.snipLine3.mas_top).offset(12.5);
        make.centerX.mas_equalTo(weakSelf.scrollView);
        make.width.mas_equalTo(SCREEN_WIDTH);
        make.height.mas_equalTo(15);
    }];
    
    [_noDataIMG mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(weakSelf.scrollView);
        make.top.mas_equalTo(weakSelf.introductionIMG.mas_bottom).offset(20);
        make.width.mas_equalTo(260);
        make.height.mas_equalTo(141.5);
    }];
    
    [_noDataLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.noDataIMG.mas_bottom).offset(20);
        make.centerX.mas_equalTo(weakSelf.scrollView);
    }];
    
    [_web mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.BGView).offset(7.5);
        make.right.mas_equalTo(weakSelf.BGView).offset(-7.5);
        make.top.mas_equalTo(weakSelf.introductionIMG.mas_bottom).offset(7.5);
        make.bottom.mas_equalTo(weakSelf.BGView);
        make.width.mas_equalTo(SCREEN_WIDTH-10);
    }];
}


- (void)updateConstraintsWithNoHeaderIcon {
    
    
    
    __weak typeof(self) weakSelf = self;
    
    _headerIcon.hidden = YES;
    _userCountIMGView.hidden = NO;
    _userCountLabel.hidden = NO;
    
    [_headerIcon mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.infosView).offset(15);
        make.left.mas_equalTo(weakSelf.infosView).offset(15);
        make.width.mas_equalTo(0);
        make.height.mas_equalTo(35);
    }];
    [_headerIcon layoutIfNeeded];
    
    [_roomTitle mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.infosView).offset(13);
        make.left.mas_equalTo(weakSelf.infosView).offset(15);
        make.right.mas_equalTo(weakSelf.infosView).offset(-15);
        make.height.mas_equalTo(20);
    }];
    
    [_animIMGView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.infosView).offset(15);
        make.bottom.mas_equalTo(weakSelf.infosView).offset(-13);
        make.width.height.mas_equalTo(15);
    }];
    
    [_liveStatsIMGView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.infosView).offset(15);
        make.bottom.mas_equalTo(weakSelf.infosView).offset(-13);
        make.width.height.mas_equalTo(15);
    }];
}

- (void)updateConstraintsWithNoUserCount {
    
    
    _headerIcon.hidden = NO;
    _userCountIMGView.hidden = YES;
    _userCountLabel.hidden = YES;
    
    __weak typeof(self) weakSelf = self;
    [_headerIcon mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.infosView).offset(15);
        make.left.mas_equalTo(weakSelf.infosView).offset(15);
        make.width.mas_equalTo(35);
        make.height.mas_equalTo(35);
    }];
    [_headerIcon layoutIfNeeded];
    
    [_roomTitle mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.infosView).offset(13);
        make.left.mas_equalTo(weakSelf.headerIcon.mas_right).offset(10);
        make.right.mas_equalTo(weakSelf.infosView).offset(-15);
        make.height.mas_equalTo(20);
    }];
    
    [_animIMGView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.headerIcon.mas_right).offset(10);
        make.bottom.mas_equalTo(weakSelf.infosView).offset(-13);
        make.width.height.mas_equalTo(15);
    }];
    
    [_liveStatsIMGView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.headerIcon.mas_right).offset(10);
        make.bottom.mas_equalTo(weakSelf.infosView).offset(-13);
        make.width.height.mas_equalTo(15);
    }];
}

- (void)updateConstraintsWithNoUserCount_NoHeaderIcon {
    
    
    
    __weak typeof(self) weakSelf = self;
    _headerIcon.hidden = YES;
    _userCountIMGView.hidden = YES;
    _userCountLabel.hidden = YES;
    
    [_headerIcon mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.infosView).offset(15);
        make.left.mas_equalTo(weakSelf.infosView).offset(15);
        make.width.mas_equalTo(0);
        make.height.mas_equalTo(0);
    }];
    [_headerIcon layoutIfNeeded];
    
    [_roomTitle mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.infosView).offset(13);
        make.left.mas_equalTo(weakSelf.infosView).offset(15);
        make.right.mas_equalTo(weakSelf.infosView).offset(-15);
        make.height.mas_equalTo(20);
    }];
    
    [_animIMGView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.infosView).offset(14);
        make.bottom.mas_equalTo(weakSelf.infosView).offset(-13);
        make.width.height.mas_equalTo(15);
    }];
    
    [_liveStatsIMGView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.infosView).offset(14);
        make.bottom.mas_equalTo(weakSelf.infosView).offset(-13);
        make.width.height.mas_equalTo(15);
    }];
}

- (void)updateConstraintsWithNormal {
    
    
    
    __weak typeof(self) weakSelf = self;
    _headerIcon.hidden = NO;
    _userCountIMGView.hidden = NO;
    _userCountLabel.hidden = NO;
    
    [_headerIcon mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.infosView).offset(15);
        make.left.mas_equalTo(weakSelf.infosView).offset(15);
        make.width.mas_equalTo(35);
        make.height.mas_equalTo(35);
    }];
    [_headerIcon layoutIfNeeded];
    
    [_roomTitle mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.infosView).offset(13);
        make.left.mas_equalTo(weakSelf.headerIcon.mas_right).offset(10);
        make.right.mas_equalTo(weakSelf.infosView).offset(-15);
        make.height.mas_equalTo(20);
    }];
    
    [_animIMGView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.headerIcon.mas_right).offset(10);
        make.bottom.mas_equalTo(weakSelf.infosView).offset(-13);
        make.width.height.mas_equalTo(15);
    }];
    
    [_liveStatsIMGView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.headerIcon.mas_right).offset(10);
        make.bottom.mas_equalTo(weakSelf.infosView).offset(-13);
        make.width.height.mas_equalTo(15);
    }];
}

- (void)updateRoomInfos {
    if (self.roomIcon.length == 0 && self.roomOnlineUserCount.length > 0) {
        if (self.showUserCount == YES) {
            [self updateConstraintsWithNoHeaderIcon];
        } else {
            [self updateConstraintsWithNoUserCount_NoHeaderIcon];
        }
    } else if (self.roomIcon.length > 0 && (self.roomOnlineUserCount.length == 0 || self.showUserCount == NO)) {
        [self updateConstraintsWithNoUserCount];
    } else if (self.roomIcon.length == 0 && (self.roomOnlineUserCount.length == 0 || self.showUserCount == NO)) {
        [self updateConstraintsWithNoUserCount_NoHeaderIcon];
    } else {
        if (self.showUserCount == YES) {
            [self updateConstraintsWithNormal];
        } else {
            [self updateConstraintsWithNoUserCount];
        }
    }
}

/**
 过滤html

 @param html 需要过滤的html
 @return 过滤过的html
 */
-(NSString *)filterHTML:(NSString *)html
{
    NSScanner * scanner = [NSScanner scannerWithString:html];
    NSString * text = nil;
    while([scanner isAtEnd]==NO)
    {
        //找到标签的起始位置
        [scanner scanUpToString:@"<" intoString:nil];
        //找到标签的结束位置
        [scanner scanUpToString:@">" intoString:&text];
        //替换字符
        html = [html stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@>",text] withString:@""];
    }
    return html;
}

// MARK: - TapEvent
- (void)closeBtnTapAction:(UIButton *)sender {
    if (_callBack) {
        _callBack();
    }
}

- (void)topBtnTapped {
    if (_callBack) {
        _callBack();
    }
}
// MARK: - LAZY
- (NSMutableArray *)animArrays {
    if (!_animArrays) {
        _animArrays = [NSMutableArray array];
    }
    return _animArrays;
}
@end
