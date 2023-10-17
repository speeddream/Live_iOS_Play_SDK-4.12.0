//
//  HDSMultiMediaBoardView.m
//  CCLiveCloud
//
//  Created by Richard Lee on 8/30/21.
//  Copyright © 2021 MacBook Pro. All rights reserved.
//

#import "HDSMultiMediaBoardView.h"
#import "HDSMultiMediaCallView.h"
#import "HDSMultiMediaCallStreamModel.h"
#import "HDSMultiLandscapeToolBar.h"
#import "HDSMultiBoardViewActionModel.h"
#import "UIColor+RCColor.h"
#import "CCcommonDefine.h"
#import <Masonry/Masonry.h>

@interface HDSMultiMediaBoardView ()

@property (nonatomic, strong) HDSMultiMediaCallView     *callView;

@property (nonatomic, strong) HDSMultiLandscapeToolBar  *landscapeToolBar;

@property (nonatomic, assign) BOOL                      isAudioVideo;

@property (nonatomic, copy) multiBoardViewClosure       btnClosure;

@end

@implementation HDSMultiMediaBoardView

/// 初始化
/// @param frame 布局
- (instancetype)initWithFrame:(CGRect)frame closure:(nonnull multiBoardViewClosure)btnActionClosure {
    if (self = [super initWithFrame:frame]) {
        self.isAudioVideo = YES;
        if (btnActionClosure) {
            _btnClosure = btnActionClosure;
        }
        self.backgroundColor = [UIColor colorWithHexString:@"#41464C" alpha:1];
        [self customUI];
    }
    return self;
}

// MARK: - API
/// 更新数据
/// @param dataArray 数据源
- (void)setDataSource:(NSArray *)dataArray isLandscape:(BOOL)isLandscape {
    NSMutableArray *tempArr = [NSMutableArray array];
    for (HDSMultiMediaCallStreamModel *model in dataArray) {
        if (model.isMyself) {
            [tempArr insertObject:model atIndex:0];
        }else {
            [tempArr addObject:model];
        }
    }
    [self.callView setDataSource:[tempArr copy] isLandscape:isLandscape];
    [self updateUIWithIsLandscape:isLandscape];
    
}

/// 移除流视图
/// @param stModel 流信息
/// @param isKillAll 是否移除所有
- (void)removeRemoteView:(HDSMultiMediaCallStreamModel * _Nullable)stModel isKillAll:(BOOL)isKillAll {
    [self.callView removeRemoteView:stModel isKillAll:isKillAll];
}

/// 设置横屏 toolBar
/// @param model 数据
- (void)setupLandscapeToolBarStatus:(HDSMultiBoardViewActionModel *)model {
    BOOL isLandscape = SCREEN_WIDTH > SCREEN_HEIGHT;
    [self updateUIWithIsLandscape:isLandscape];
    if (isLandscape) {
        [_landscapeToolBar updateToolBarBtnStatus:_isAudioVideo model:model];
    }
}

// MARK: - Custom Method
/// 自定义UI
- (void)customUI {
    
    _callView = [[HDSMultiMediaCallView alloc]initWithFrame:CGRectZero];
    [self addSubview:_callView];
    
    HDSMultiBoardViewActionModel *model = [[HDSMultiBoardViewActionModel alloc]init];
    model.isAudioEnable = YES;
    model.isVideoEnable = YES;
    model.isFrontCamera = YES;
    model.isHangup = NO;
    _landscapeToolBar = [[HDSMultiLandscapeToolBar alloc]initWithFrame:CGRectZero isAudioVideo:_isAudioVideo model:model closure:^(HDSMultiBoardViewActionModel * _Nonnull model) {
        if (_btnClosure) {
            _btnClosure(model);
        }
    }];
    [self addSubview:_landscapeToolBar];
    
    BOOL isLandscape = SCREEN_WIDTH > SCREEN_HEIGHT;
    if (isLandscape) {
        [_callView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.bottom.mas_equalTo(self);
            make.width.mas_equalTo(134.5);
        }];
        [_callView layoutIfNeeded];
        CGFloat height = _isAudioVideo == YES ? 197.5 : 102.5;
        [_landscapeToolBar mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.callView.mas_right).offset(5);
            make.centerY.mas_equalTo(self);
            make.width.mas_equalTo(55);
            make.height.mas_equalTo(height);
        }];
        [_landscapeToolBar layoutIfNeeded];
        _landscapeToolBar.hidden = YES;
    }else {
        [_callView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self);
        }];
        [_callView layoutIfNeeded];
        [_landscapeToolBar mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.right.mas_equalTo(self);
            make.width.height.mas_equalTo(0);
        }];
        [_landscapeToolBar layoutIfNeeded];
        _landscapeToolBar.hidden = YES;
    }
}

/// 更新UI
- (void)updateUIWithIsLandscape:(BOOL)isLandscape {
    if (isLandscape) {
        [_callView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.left.bottom.mas_equalTo(self);
            make.width.mas_equalTo(134.5);
        }];
        [_callView layoutIfNeeded];
        CGFloat height = _isAudioVideo == YES ? 197.5 : 102.5;
        [_landscapeToolBar mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.callView.mas_right);
            make.centerY.mas_equalTo(self);
            make.width.mas_equalTo(55);
            make.height.mas_equalTo(height);
        }];
        [_landscapeToolBar layoutIfNeeded];
        _landscapeToolBar.hidden = YES;
    }else {
        [_callView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self);
        }];
        [_callView layoutIfNeeded];
        [_landscapeToolBar mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.right.mas_equalTo(self);
            make.width.height.mas_equalTo(0);
        }];
        [_landscapeToolBar layoutIfNeeded];
        _landscapeToolBar.hidden = YES;
    }
}

@end
