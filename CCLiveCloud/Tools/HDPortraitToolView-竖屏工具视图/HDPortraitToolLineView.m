//
//  HDPortraitToolLineView.m
//  CCLiveCloud
//
//  Created by Apple on 2021/3/16.
//  Copyright © 2021 MacBook Pro. All rights reserved.
//

#import "HDPortraitToolLineView.h"
#import "HDPortraitToolModel.h"
#import "HDPortraitToolDynamicView.h"
#import "UIColor+RCColor.h"
#import "CCcommonDefine.h"
#import "UIView+Extension.h"

#define MainTitle @"线路切换："
#define kSelectedColor @"#FF842F"
#define kDefaultColor @"#333333"

#define kSingleBtnH 30
#define kColumnMaxCount 3

@interface HDPortraitToolLineView ()

@property (nonatomic, strong) UILabel                   *mainTitle;

@property (nonatomic, strong) HDPortraitToolDynamicView *contentView;

@property (nonatomic, copy)   NSArray                   *lineDataArray;

@end

@implementation HDPortraitToolLineView

//MARK: - API
- (instancetype)initWithFrame:(CGRect)frame lineDataArray:(nonnull NSArray *)lineDataArray {
    self = [super initWithFrame:frame];
    if (self) {
        if (lineDataArray.count > 0) {
            self.lineDataArray = [lineDataArray copy];
        }else {
            self.lineDataArray = @[];
        }
        [self configureView];
    }
    return self;
}

- (void)setTargetModel:(HDPortraitToolModel *)targetModel {
    _targetModel = targetModel;
    if (self.lineDataArray.count == 0) return;
    _contentView.targetModel = targetModel;
}

//MARK: - CUSTOM METHOD
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
 
    if (self.lineDataArray.count == 0) return;
    _contentView = [[HDPortraitToolDynamicView alloc]init];
    [self addSubview:_contentView];
    CGFloat contentViewX = CGRectGetMaxX(_mainTitle.frame) + 10;
    CGFloat contentViewH = [self heightForCount:self.lineDataArray.count];
    CGFloat contentViewY = _mainTitle.centerY - (kSingleBtnH / 2);
    CGFloat contentViewW = self.width - 120;
    _contentView.frame = CGRectMake(contentViewX, contentViewY, contentViewW, contentViewH);
    _contentView.dataArray = self.lineDataArray;
    WS(ws)
    _contentView.updateDataBlock = ^(HDPortraitToolModel * _Nonnull model) {
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
