//
//  HDPortraitToolBaseView.m
//  CCLiveCloud
//
//  Created by Apple on 2021/3/15.
//  Copyright © 2021 MacBook Pro. All rights reserved.
//

#import "HDPortraitToolBaseView.h"
#import "TopView.h"
#import "HDPortraitToolModel.h"
#import "HDPortraitToolAudioModeView.h"
#import "HDPortraitToolLineView.h"
#import "HDPortraitToolQualityView.h"
#import "HDPortraitToolRateView.h"
#import "UIColor+RCColor.h"
#import "CCcommonDefine.h"

#define kAudioData @"AudioData"
#define kLineData @"LineData"
#define kQualityData @"QualityData"
#define kRataData @"RateData"
#define kLine @"lines"

#define kSingleBtnH 30
#define kColumnMaxCount 3
#define kMargin 20

@interface HDPortraitToolBaseView ()

@property (nonatomic, strong) TopView                           *topView;

@property (nonatomic, strong) UIScrollView                      *bgView;

@property (nonatomic, strong) HDPortraitToolAudioModeView       *audioModeView;

@property (nonatomic, assign) BOOL                              hasAudioMode;

@property (nonatomic, strong) HDPortraitToolLineView            *lineView;

@property (nonatomic, copy)   NSArray                           *lineList;

@property (nonatomic, strong) HDPortraitToolQualityView         *qualityView;

@property (nonatomic, copy)   NSArray                           *qualityList;

@property (nonatomic, strong) HDPortraitToolRateView            *rateView;

@property (nonatomic, copy)   NSArray                           *rateList;

@end

@implementation HDPortraitToolBaseView

// MARK: - API
- (instancetype)initWithFrame:(CGRect)frame
                 hasAudioMode:(BOOL)hasAudioMode
                  qualityList:(NSArray *)qualityList
                     lineList:(NSArray *)lineList
                     rateList:(NSArray *)rateList {
    self = [super initWithFrame:frame];
    if (self) {
        self.hasAudioMode = hasAudioMode;
        if (qualityList.count == 0 || ![qualityList isKindOfClass:[NSArray class]]) {
            self.qualityList = @[];
        }else {
            self.qualityList = [qualityList copy];
        }
        if (lineList.count == 0 || ![lineList isKindOfClass:[NSArray class]]) {
            self.lineList = @[];
        }else {
            self.lineList = [lineList copy];
        }
        if (rateList.count == 0 || ![rateList isKindOfClass:[NSArray class]]) {
            self.rateList = @[];
        }else {
            self.rateList = [rateList copy];
        }
        self.backgroundColor = [UIColor colorWithHexString:@"#FFFFFF" alpha:1];
        [self configureView];
    }
    return self;
}

- (void)setSelectedAudioModeModel:(HDPortraitToolModel *)selectedAudioModeModel {
    _selectedAudioModeModel = selectedAudioModeModel;
    if (self.hasAudioMode) {
        self.audioModeView.targetModel = _selectedAudioModeModel;
    }
}

- (void)setSelectedLineModel:(HDPortraitToolModel *)selectedLineModel {
    _selectedLineModel = selectedLineModel;
    if (self.lineList.count > 0) {
        self.lineView.targetModel = _selectedLineModel;
    }
}

- (void)setSelectedQualityModel:(HDPortraitToolModel *)selectedQualityModel {
    _selectedQualityModel = selectedQualityModel;
    if (self.qualityList.count > 0) {
        self.qualityView.targetModel = _selectedQualityModel;
    }
}

- (void)setSelectedRateModel:(HDPortraitToolModel *)selectedRateModel {
    _selectedRateModel = selectedRateModel;
    if (self.rateList.count > 0) {
        self.rateView.targetModel = _selectedRateModel;
    }
}

- (void)setQualityViewHidden:(BOOL)hidden {
    
    if (self.qualityList.count == 0) return;
    WS(weakSelf)
    if (hidden == YES) {
        weakSelf.qualityView.hidden = YES;
    }
    [UIView animateWithDuration:0.35 animations:^{
        CGFloat qualityViewY = CGRectGetMaxY(weakSelf.lineView.frame);
        CGFloat qualityH = hidden == NO ? [weakSelf heightForCount:weakSelf.qualityList.count] : 0;
        weakSelf.qualityView.frame = CGRectMake(0, qualityViewY, SCREEN_WIDTH, qualityH);
        
        if (weakSelf.rateList.count == 0) return;
        CGFloat rateViewY = CGRectGetMaxY(weakSelf.qualityView.frame);
        CGFloat rateH = [weakSelf heightForCount:weakSelf.rateList.count];
        weakSelf.rateView.frame = CGRectMake(0, rateViewY, SCREEN_WIDTH, rateH);
        
    } completion:^(BOOL finished) {
        if (hidden == NO) {
            weakSelf.qualityView.hidden = NO;
        }
    }];
}

// MARK: - COUSTOM METHOD
- (void)configureView {
    WS(weakSelf)
    _topView = [[TopView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 40) Title:@"更多" titleStyle:TopViewTitleLabelStyleLeft closeBlock:^{
        [weakSelf hidden];
    }];
    [self addSubview:_topView];
    
    _bgView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 40, SCREEN_WIDTH, self.frame.size.height)];
    _bgView.bounces = NO;
    _bgView.showsVerticalScrollIndicator = NO;
    _bgView.showsHorizontalScrollIndicator = NO;
    [self addSubview:_bgView];
    
    CGFloat topMargin = kMargin;
    CGFloat audioModeH = self.hasAudioMode == YES ? 50 : 0;
    _audioModeView = [[HDPortraitToolAudioModeView alloc]initWithFrame:CGRectMake(0, topMargin, SCREEN_WIDTH, audioModeH) hasAudioMode:self.hasAudioMode];
    [_bgView addSubview:_audioModeView];
    [_audioModeView setHidden:self.hasAudioMode == YES ? NO :YES];
    self.audioModeView.updateBlock = ^(HDPortraitToolModel * _Nonnull model) {
        if (weakSelf.updateBlock) {
            weakSelf.updateBlock(model);
        }
    };
    
    CGFloat lineViewY = CGRectGetMaxY(_audioModeView.frame);
    CGFloat lineViewH = self.lineList.count > 0 ? [self heightForCount:self.lineList.count] : 0;
    _lineView = [[HDPortraitToolLineView alloc]initWithFrame:CGRectMake(0, lineViewY, SCREEN_WIDTH, lineViewH) lineDataArray:self.lineList];
    [_bgView addSubview:_lineView];
    [_lineView setHidden:self.lineList.count > 0 ? NO : YES];
    self.lineView.updateBlock = ^(HDPortraitToolModel * _Nonnull model) {
        if (weakSelf.updateBlock) {
            weakSelf.updateBlock(model);
        }
    };
    
    CGFloat qualityViewY = CGRectGetMaxY(_lineView.frame);
    CGFloat qualityH = self.qualityList.count > 0 ? [self heightForCount:self.qualityList.count] : 0;
    _qualityView = [[HDPortraitToolQualityView alloc]initWithFrame:CGRectMake(0, qualityViewY, SCREEN_WIDTH, qualityH) qualityDataArray:self.qualityList];
    [_bgView addSubview:_qualityView];
    [_qualityView setHidden:self.qualityList.count > 0 ? NO : YES];
    self.qualityView.updateBlock = ^(HDPortraitToolModel * _Nonnull model) {
        if (weakSelf.updateBlock) {
            weakSelf.updateBlock(model);
        }
    };
    
    CGFloat rateViewY = CGRectGetMaxY(_qualityView.frame);
    CGFloat rateH = self.rateList.count > 0 ? [self heightForCount:self.rateList.count] : 0;
    _rateView = [[HDPortraitToolRateView alloc]initWithFrame:CGRectMake(0, rateViewY, SCREEN_WIDTH, rateH) rateDataArray:self.rateList];
    [_bgView addSubview:_rateView];
    [_rateView setHidden:self.rateList.count > 0 ? NO : YES];
    self.rateView.updateBlock = ^(HDPortraitToolModel * _Nonnull model) {
        if (weakSelf.updateBlock) {
            weakSelf.updateBlock(model);
        }
    };
    
    CGFloat bottomMargin = kMargin;
    CGFloat maxHeight = topMargin + audioModeH + lineViewH + qualityH + rateH + bottomMargin;
    self.bgView.contentSize = CGSizeMake(SCREEN_WIDTH, maxHeight);
    //NSLog(@"------%f",maxHeight);
}

- (void)hidden {
    if (self.closeBlock) {
        self.closeBlock();
    }
}

- (CGFloat)heightForCount:(NSInteger)count {
    CGFloat height = kSingleBtnH;
    if (count > kColumnMaxCount) {
        CGFloat mod = count % kColumnMaxCount;
        CGFloat row = count / kColumnMaxCount;
        if (mod > 0) {
            row++;
        }
        height = row * kSingleBtnH;
    }
    /// 20 上下间距
    return height + kMargin;
}

@end
