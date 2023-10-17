//
//  HDPlayerBaseToolView.m
//  CCLiveCloud
//
//  Created by Apple on 2020/12/9.
//  Copyright © 2020 MacBook Pro. All rights reserved.
//

#import "HDPlayerBaseToolView.h"
#import "HDPlayerBaseLineView.h"
#import "HDPlayerBaseRateView.h"
#import "HDPlayerBaseQualityView.h"
#import "HDPlayerBaseModel.h"
#import "HDPlayerBaseBarrageView.h"
#import "UIColor+RCColor.h"
#import "CCcommonDefine.h"
#import "UIView+Extension.h"

@interface HDPlayerBaseToolView ()
/** 显示类型 */
@property (nonatomic, assign) HDPlayerBaseToolViewType      type;
/** 线路 */
@property (nonatomic, strong) HDPlayerBaseLineView          *lineView;
/** 倍速 */
@property (nonatomic, strong) HDPlayerBaseRateView          *rateView;
/** 清晰度 */
@property (nonatomic, strong) HDPlayerBaseQualityView       *qualityView;
/** 数据源 */
@property (nonatomic, strong) NSMutableArray                *dataArray;
/** 当前选项 */
@property (nonatomic, strong) HDPlayerBaseModel             *model;

@property (nonatomic, assign) BOOL                          isAudio;

@property (nonatomic, strong) HDPlayerBaseBarrageView       *barrageView;

@end

@implementation HDPlayerBaseToolView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        /** 背景色 */
        self.backgroundColor = [UIColor colorWithHexString:@"#0A0A0A" alpha:0.7];
    }
    return self;
}

// MARK: - API
/**
 *    @brief    根据类型展示内容
 *    @param    type   显示类型
 *    @param    infos  显示数据数组
 *    @param    model  当前选择数据
 */
- (void)showInformationWithType:(HDPlayerBaseToolViewType)type infos:(nonnull NSArray *)infos defaultData:(nonnull HDPlayerBaseModel *)model {
    self.type = type;
    if ([model isKindOfClass:[NSNull class]] || model == nil) {
        self.model.value = @"0";
        self.model.index = 0;
    }else {    
        self.model = model;
    }
    
    if (model.func == HDPlayerBaseAudioLine) {
        self.isAudio = YES;
    }else {
        self.isAudio = NO;
    }
    
    [self.dataArray removeAllObjects];
    [self.dataArray addObjectsFromArray:infos];
    
    [self updateCustomView];
}

// MARK: - CustomMethod
- (void)updateCustomView
{
    WS(ws)
    switch (_type) {
        case HDPlayerBaseToolViewTypeLine:{
            if (!_lineView) {
                _lineView = [[HDPlayerBaseLineView alloc]initWithFrame:CGRectMake(0, 0, self.width, self.height)];
                [self addSubview:_lineView];
            }
            _lineView.hidden = NO;
            _rateView.hidden = YES;
            _qualityView.hidden = YES;
            _barrageView.hidden = YES;
            [_lineView playerBaseLineViewWithDataArray:self.dataArray selectedLineIndex:_model.value isAudio:self.isAudio];
            self.lineView.lineBlock = ^(HDPlayerBaseModel * _Nonnull model) {
                if (ws.baseToolBlock) {
                    ws.baseToolBlock(model);
                }
            };
            self.lineView.switchAudio = ^(BOOL result) {
                if (ws.switchAudio) {
                    ws.switchAudio(result);
                }
            };
        }break;
        
        case HDPlayerBaseToolViewTypeRate:{
            if (!_rateView) {
                _rateView = [[HDPlayerBaseRateView alloc]initWithFrame:CGRectMake(0, 0, self.width, self.height)];
                [self addSubview:_rateView];
            }
            _rateView.hidden = NO;
            _lineView.hidden = YES;
            _qualityView.hidden = YES;
            _barrageView.hidden = YES;
            [_rateView playerBaseRateViewWithDataArray:self.dataArray selectedRate:_model.value];
            self.rateView.rateBlock  = ^(HDPlayerBaseModel * _Nonnull model) {
                if (ws.baseToolBlock) {
                    ws.baseToolBlock(model);
                }
            };
        }break;
            
        case HDPlayerBaseToolViewTypeQuality:{
            if (!_qualityView) {
                _qualityView = [[HDPlayerBaseQualityView alloc]initWithFrame:CGRectMake(0, 0, self.width, self.height)];
                [self addSubview:_qualityView];
            }
            _qualityView.hidden = NO;
            _lineView.hidden = YES;
            _rateView.hidden = YES;
            _barrageView.hidden = YES;
            [_qualityView playerBaseQualityViewWithDataArray:self.dataArray selectedQuality:_model.value];
            self.qualityView.qulityBlock = ^(HDPlayerBaseModel * _Nonnull model) {
                if (ws.baseToolBlock) {
                    ws.baseToolBlock(model);
                }
            };
        }break;
            
        case HDPlayerBaseToolViewTypeBarrage: {
            
            HDPlayerBaseBarrageViewStyle style = self.model.index == 0 ? HDPlayerBaseBarrageViewStyleFullScreen : HDPlayerBaseBarrageViewStyleHalfScreen;
            
            if (!_barrageView) {
                _barrageView = [[HDPlayerBaseBarrageView alloc]initWithFrame:CGRectMake(0, 0, self.width, self.height) barrageStyle:HDPlayerBaseBarrageViewStyleFullScreen];
                [self addSubview:_barrageView];
            }
            _barrageView.barrageViewBlock = ^(HDPlayerBaseModel * _Nonnull model) {
                if (ws.baseToolBlock) {
                    ws.baseToolBlock(model);
                }
            };
            [_barrageView setBarrageStyle:style];
            _barrageView.hidden = NO;
            _qualityView.hidden = YES;
            _lineView.hidden = YES;
            _rateView.hidden = YES;
        }break;
        default:
            break;
    }
}

// MARK: - LAZY
- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

@end
