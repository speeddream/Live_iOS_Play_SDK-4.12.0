//
//  HDPortraitToolDynamicView.m
//  CCLiveCloud
//
//  Created by Apple on 2021/3/16.
//  Copyright © 2021 MacBook Pro. All rights reserved.
//

#import "HDPortraitToolDynamicView.h"
#import "HDPortraitToolModel.h"
#import "HDCoustomButtom.h"
#import "UIColor+RCColor.h"

#define kColumnMaxCount 3
#define kSingleBtnW 75
#define kSingleBtnH 30
#define kBtnFlag    9000


@implementation HDPortraitToolDynamicView

- (void)setTargetModel:(HDPortraitToolModel *)targetModel {
    _targetModel = targetModel;
    for (int i = 0; i < self.dataArray.count; i++) {
        HDCoustomButtom *btn = [self viewWithTag:i + kBtnFlag];
        NSInteger index = _targetModel.index + kBtnFlag;
        if (btn.tag == index) {
            btn.isSelected = YES;
        }else {
            btn.isSelected = NO;
        }
    }
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithHexString:@"#FFFFFF" alpha:1];
    }
    return self;
}

- (void)setDataArray:(NSArray *)dataArray {
    _dataArray = dataArray;
    if (dataArray.count <= 0) return;
    if (self.subviews.count > 0) {
        for (UIView *subView in self.subviews) {
            [subView removeFromSuperview];
        }
    }
    for (int i = 0; i< dataArray.count; i++) {
        CGFloat row = i % kColumnMaxCount;    //行
        CGFloat column = i / kColumnMaxCount; //列
        HDPortraitToolModel *model = dataArray[i];
        CGRect frame = CGRectMake(kSingleBtnW * row, kSingleBtnH * column, kSingleBtnW, kSingleBtnH);
        HDCoustomButtom *button = [[HDCoustomButtom alloc]initWithFrame:frame textAlignment:HDButtonTextAlignmentLeft];
        button.tag = i + kBtnFlag;
        button.btnTitleLabel.text = model.desc.length > 0 ? model.desc : @"原画";
        button.titleFont = [UIFont systemFontOfSize:15];
        button.titleColor = [UIColor colorWithHexString:@"#333333" alpha:1];
        button.selectedTitleColor = [UIColor colorWithHexString:@"#FF842F" alpha:1];
        button.isSelected = NO;
        [button addTarget:self action:@selector(btnsClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:button];
    }
}

- (void)btnsClick:(UIButton *)sender {
    for (int i = 0; i < self.dataArray.count; i++) {
        HDCoustomButtom *btn = [self viewWithTag:i + kBtnFlag];
        btn.isSelected = btn.tag != sender.tag ? NO :YES;
    }
    NSInteger index = sender.tag - kBtnFlag;
    if (index < 0) {
        NSLog(@"%s :data error",__func__);
        return;
    }
    HDPortraitToolModel *model = self.dataArray[index];
    model.isSelected = YES;
    if (self.updateDataBlock) {
        self.updateDataBlock(model);
    }
}

@end
