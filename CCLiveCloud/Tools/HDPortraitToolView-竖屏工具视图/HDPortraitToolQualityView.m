//
//  HDPortraitToolQualityView.m
//  CCLiveCloud
//
//  Created by Apple on 2021/3/17.
//  Copyright © 2021 MacBook Pro. All rights reserved.
//

#import "HDPortraitToolQualityView.h"
#import "HDPortraitToolModel.h"
#import "HDPortraitToolDynamicView.h"
#import "UIColor+RCColor.h"
#import "CCcommonDefine.h"
#import "UIView+Extension.h"

#define MainTitle @"清晰度："
#define kSingleBtnH 30
#define kColumnMaxCount 3


@interface HDPortraitToolQualityView ()

@property (nonatomic, strong) UILabel                   *mainTitle;

@property (nonatomic, strong) HDPortraitToolDynamicView *contentView;

@property (nonatomic, strong) NSArray                   *qualityDataArray;

@end

@implementation HDPortraitToolQualityView

// MARK: - API
- (instancetype)initWithFrame:(CGRect)frame qualityDataArray:(nonnull NSArray *)qualityArray {
    self = [super initWithFrame:frame];
    if (self) {
        if (qualityArray.count > 0) {
            self.qualityDataArray = [qualityArray copy];
        }else {
            self.qualityDataArray = @[];
        }
        [self configureView];
    }
    return self;
}

- (void)setTargetModel:(HDPortraitToolModel *)targetModel {
    _targetModel = targetModel;
    _contentView.targetModel = targetModel;
}

// MARK: - CUSTOM METHOD
- (void)configureView {
    
    CGFloat mainTitleX = 24;
    CGFloat mainTitleY = 0;
    CGFloat mainTitleW = 75;
    CGFloat mainTitleH = 50;
    _mainTitle = [[UILabel alloc]initWithFrame:CGRectMake(mainTitleX, mainTitleY, mainTitleW, mainTitleH)];
    _mainTitle.font = [UIFont systemFontOfSize:15];
    _mainTitle.textColor = [UIColor colorWithHexString:@"#666666" alpha:1];
    _mainTitle.text = MainTitle;
    [self addSubview:_mainTitle];
    
    if (self.qualityDataArray.count == 0) return;
    _contentView = [[HDPortraitToolDynamicView alloc]init];
    [self addSubview:_contentView];
    CGFloat contentViewX = CGRectGetMaxX(self.mainTitle.frame) + 10;
    CGFloat contentViewH = [self heightForCount:self.qualityDataArray.count];
    CGFloat contentViewY = self.mainTitle.centerY - (kSingleBtnH / 2);
    CGFloat contentViewW = self.width - 120;
    _contentView.frame = CGRectMake(contentViewX, contentViewY, contentViewW, contentViewH);
    _contentView.dataArray = self.qualityDataArray;
    WS(ws)
    _contentView.updateDataBlock = ^(HDPortraitToolModel * _Nonnull model) {
//        if (ws.updateBlock) {
//            ws.updateBlock(model);
//        }
        [ws updateWithModel:model];
    };
    
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
    return height;
}

- (void)updateWithModel:(HDPortraitToolModel *)model {
    if (self.updateBlock) {
        self.updateBlock(model);
    }
}

@end
