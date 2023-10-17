//
//  HDPlayerBaseLineView.m
//  CCLiveCloud
//
//  Created by Apple on 2020/12/11.
//  Copyright © 2020 MacBook Pro. All rights reserved.
//

#import "HDPlayerBaseLineView.h"
#import "HDSwitch.h"
#import "HDPlayerBaseModel.h"
#import "UIColor+RCColor.h"
#import "CCcommonDefine.h"
#import <Masonry/Masonry.h>

#define kSelectedColor @"#F89E0F"
#define kDefaultColor @"#FFFFFF"

@interface HDPlayerBaseLineView ()
/** 是否是音频线路 */
@property (nonatomic, assign) BOOL              isAudio;

@property (nonatomic, assign) NSInteger         selectedIndex;

@property (nonatomic, strong) NSMutableArray    *dataArray;

@property (nonatomic, assign) NSInteger         selectedQualityIndex;

@property (nonatomic, strong) UIView            *headerView;

@property (nonatomic, strong) UILabel           *audioTipLabel;

@property (nonatomic, strong) HDSwitch          *audioSwitch;

@property (nonatomic, strong) UILabel           *lineTipLabel;

@property (nonatomic, strong) UIView            *bodyView;

@property (nonatomic, strong) UIButton          *primaryLineBtn;

@property (nonatomic, strong) UIButton          *subLineOneBtn;

@property (nonatomic, strong) UIButton          *subLineTwoBtn;

@end

@implementation HDPlayerBaseLineView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}
- (void)setupUI {
    WS(ws)
    _headerView = [[UIView alloc]init];
    [self addSubview:_headerView];
    [_headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(ws).offset(30);
        make.left.right.mas_equalTo(ws);
        make.height.mas_equalTo(50);
    }];
    _headerView.hidden = YES;
    _audioTipLabel = [[UILabel alloc]init];
    _audioTipLabel.text = PLAY_MODE_AUDIO;
    _audioTipLabel.textColor = [UIColor colorWithHexString:kDefaultColor alpha:1];
    _audioTipLabel.font = [UIFont systemFontOfSize:14];
    [self.headerView addSubview:_audioTipLabel];
    [_audioTipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(ws.headerView).offset(20);
        make.left.mas_equalTo(ws.headerView).offset(25);
    }];
    
    _audioSwitch = [[HDSwitch alloc]initWithFrame:CGRectMake(0, 0, 40, 17)];
    [_audioSwitch setTintColor:[UIColor colorWithHexString:@"#666666" alpha:1]]; //关闭背景色
    [_audioSwitch setOnTintColor:[UIColor colorWithHexString:kSelectedColor alpha:1]]; //开启背景色
    [_audioSwitch setThumbTintColor:[UIColor colorWithHexString:kDefaultColor alpha:1]]; //按钮颜色
    [_audioSwitch addTarget:self action:@selector(audioSwitch:) forControlEvents:UIControlEventValueChanged];
    [self.headerView addSubview:_audioSwitch];
    [_audioSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(ws.audioTipLabel.mas_right).offset(10);
        make.centerY.mas_equalTo(ws.audioTipLabel);
        make.width.mas_equalTo(40);
        make.height.mas_equalTo(17);
    }];
    
    _bodyView = [[UIView alloc]init];
    [self addSubview:_bodyView];
    [_bodyView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(ws).offset(80);
        make.left.right.mas_equalTo(ws);
        make.bottom.mas_equalTo(ws).offset(-30);
    }];
    
    _lineTipLabel = [[UILabel alloc]init];
    _lineTipLabel.text = PLAY_MODE_CHANGE_LINE;
    _lineTipLabel.textColor = [UIColor colorWithHexString:kDefaultColor alpha:1];
    _lineTipLabel.font = [UIFont systemFontOfSize:14];
    [self.bodyView addSubview:_lineTipLabel];
    [_lineTipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(ws.bodyView).offset(28.5);
        make.left.mas_equalTo(ws.bodyView).offset(25);
    }];
        
    _primaryLineBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_primaryLineBtn setTitle:PLAY_MODE_LINE1 forState:UIControlStateNormal];
    [_primaryLineBtn setTitleColor:[UIColor colorWithHexString:kDefaultColor alpha:1] forState:UIControlStateNormal];
    _primaryLineBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    [_primaryLineBtn addTarget:self action:@selector(primaryLineBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.bodyView addSubview:_primaryLineBtn];
    _primaryLineBtn.hidden = YES;
    
    _subLineOneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_subLineOneBtn setTitle:PLAY_MODE_LINE2 forState:UIControlStateNormal];
    [_subLineOneBtn setTitleColor:[UIColor colorWithHexString:kDefaultColor alpha:1] forState:UIControlStateNormal];
    _subLineOneBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    [_subLineOneBtn addTarget:self action:@selector(subLineOneBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.bodyView addSubview:_subLineOneBtn];
    _subLineOneBtn.hidden = YES;
    
    NSMutableArray *btnArr = [NSMutableArray array];
    [btnArr addObject:_primaryLineBtn];
    [btnArr addObject:_subLineOneBtn];
    
    [btnArr mas_distributeViewsAlongAxis:MASAxisTypeHorizontal withFixedSpacing:30 leadSpacing:5 tailSpacing:5];
    [btnArr mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(@68.5);
        make.height.mas_equalTo(@40);
    }];
    
    _subLineTwoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_subLineTwoBtn setTitle:PLAY_MODE_LINE3 forState:UIControlStateNormal];
    [_subLineTwoBtn setTitleColor:[UIColor colorWithHexString:kDefaultColor alpha:1] forState:UIControlStateNormal];
    _subLineTwoBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    [_subLineTwoBtn addTarget:self action:@selector(subLineTwoBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.bodyView addSubview:_subLineTwoBtn];
    [_subLineTwoBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(ws.primaryLineBtn.mas_bottom);
        make.left.mas_equalTo(ws.primaryLineBtn);
        make.width.height.mas_equalTo(ws.primaryLineBtn);
    }];
    _subLineTwoBtn.hidden = YES;
    
    [self setNeedsLayout];
}
/**
 *    @brief    显示线路
 *    @param    lineArray               线路数组
 *    @param    selectedLineIndex       选中下标
 *    @param    isAudio                 是否是音频线路
 */
- (void)playerBaseLineViewWithDataArray:(NSMutableArray *)lineArray
                      selectedLineIndex:(NSString *)selectedLineIndex
                                isAudio:(BOOL)isAudio {
    
    NSDictionary *lineDict = [lineArray firstObject];
    if ([[lineDict allKeys] containsObject:@"hasAudio"]) {
        BOOL hasAudio = [lineDict[@"hasAudio"] boolValue];
        _headerView.hidden = hasAudio == NO ? YES : NO;
        if (hasAudio == YES) {
            self.isAudio = isAudio;
            [self.audioSwitch setOn:isAudio == YES ? YES : NO];
        }
    }
    if (selectedLineIndex.length == 0) {
        self.selectedIndex = 0;
    }else {
        self.selectedIndex = [selectedLineIndex integerValue];
    }
    [self updateLineBtnWithLineDict:lineDict];
}

- (void)updateLineBtnWithLineDict:(NSDictionary *)lineDict {
    NSArray *lineArray = lineDict[@"lines"];
    if (lineArray.count == 0 || lineArray.count > 3) return;
    NSString *primary = [NSString stringWithFormat:@"%@",lineArray[0]];
    if (primary.length > 0) {
        [self.primaryLineBtn setTitle:primary forState:UIControlStateNormal];
    }
    self.primaryLineBtn.hidden = NO;
    if (lineArray.count == 3) {
        NSString *one = [NSString stringWithFormat:@"%@",lineArray[1]];
        if (one.length > 0) {
            [self.subLineOneBtn setTitle:one forState:UIControlStateNormal];
        }
        self.subLineOneBtn.hidden = NO;
        NSString *two = [NSString stringWithFormat:@"%@",lineArray[2]];
        if (two.length > 0) {
            [self.subLineTwoBtn setTitle:two forState:UIControlStateNormal];
        }
        self.subLineTwoBtn.hidden = NO;
    }else if(lineArray.count == 2) {
        NSString *one = [NSString stringWithFormat:@"%@",lineArray[1]];
        if (one.length > 0) {
            [self.subLineOneBtn setTitle:one forState:UIControlStateNormal];
        }
        self.subLineOneBtn.hidden = NO;
    }
}

- (void)setSelectedIndex:(NSInteger)selectedIndex {
    _selectedIndex = selectedIndex;
    NSString *primaryColor = _selectedIndex == 0 ? kSelectedColor : kDefaultColor;
    [_primaryLineBtn setTitleColor:[UIColor colorWithHexString:primaryColor alpha:1] forState:UIControlStateNormal];
    NSString *subOneColor = _selectedIndex == 1 ? kSelectedColor : kDefaultColor;
    [_subLineOneBtn setTitleColor:[UIColor colorWithHexString:subOneColor alpha:1] forState:UIControlStateNormal];
    NSString *subTwoColor = _selectedIndex == 2 ? kSelectedColor : kDefaultColor;
    [_subLineTwoBtn setTitleColor:[UIColor colorWithHexString:subTwoColor alpha:1] forState:UIControlStateNormal];
}

- (void)audioSwitch:(HDSwitch *)sender {
    if (sender.isOn == YES) {
        self.isAudio = YES;
    }else{
        self.isAudio = NO;
    }
    if (self.switchAudio) {
        self.switchAudio(self.isAudio);
    }
    [self beginCallBack];
}

- (void)primaryLineBtnClick:(UIButton *)sender {
    self.selectedIndex = 0;
    [self beginCallBack];
}

- (void)subLineOneBtnClick:(UIButton *)sender {
    self.selectedIndex = 1;
    [self beginCallBack];
}

- (void)subLineTwoBtnClick:(UIButton *)sender {
    self.selectedIndex = 2;
    [self beginCallBack];
}

- (void)beginCallBack
{
    HDPlayerBaseModel *model = [[HDPlayerBaseModel alloc]init];
    model.func = self.isAudio == YES ? HDPlayerBaseAudioLine : HDPlayerBaseVideoLine;
    model.value = [[NSString alloc]initWithFormat:@"%zd",_selectedIndex];
    model.index = _selectedIndex;
    if (self.lineBlock) {
        self.lineBlock(model);
    }
}

@end
