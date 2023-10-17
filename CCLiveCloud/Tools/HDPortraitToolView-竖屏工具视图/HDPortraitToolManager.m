//
//  HDPortraitToolManager.m
//  CCLiveCloud
//
//  Created by Apple on 2021/3/15.
//  Copyright © 2021 MacBook Pro. All rights reserved.
//

#import "HDPortraitToolManager.h"
#import "HDPortraitToolModel.h"
#import "HDPortraitToolBaseView.h"
#import "CCSDK/PlayParameter.h"
#import "CCcommonDefine.h"

#define kLineList @"lineList"
#define kLineIndexNum @"indexNum"
#define kLine1 @"线路1"
#define kLine2 @"线路2"
#define kLine3 @"线路3"

#define kQualityList @"qualityList"
#define kCurrentQuality @"currentQuality"

@interface HDPortraitToolManager ()

@property (nonatomic, strong) UIView                    *boardView;
@property (nonatomic, assign) BOOL                      audioMode;
@property (nonatomic, assign) BOOL                      quality;
@property (nonatomic, assign) BOOL                      line;
@property (nonatomic, assign) BOOL                      rate;
@property (nonatomic, copy)   EventBlock                eventBlock;
@property (nonatomic, strong) HDPortraitToolBaseView    *toolView;
@property (nonatomic, strong) NSMutableDictionary       *metasDict;
@property (nonatomic, copy)   NSMutableArray            *selectedAudioModeArray;
@property (nonatomic, copy)   NSArray                   *qualityList;
@property (nonatomic, copy)   NSMutableArray            *selectedQualityArray;
@property (nonatomic, copy)   NSArray                   *lineList;
@property (nonatomic, copy)   NSMutableArray            *selectedLineArray;
@property (nonatomic, copy)   NSArray                   *rateList;
@property (nonatomic, copy)   NSMutableArray            *selectedRateArray;

@end

@implementation HDPortraitToolManager

- (instancetype)initWithBoardView:(UIView *)boardView
                        audioMode:(BOOL)audioMode
                          quality:(BOOL)quality
                             line:(BOOL)line
                             rate:(BOOL)rate
                       eventBlock:(EventBlock)eventBlock {
    self = [super init];
    if (self) {
        self.boardView = boardView;
        self.audioMode = audioMode;
        self.quality = quality;
        self.line = line;
        self.rate = rate;
        if (eventBlock) {
            _eventBlock = eventBlock;
        }
    }
    return self;
}

// MARK: - API
- (void)setToolViewHidden:(BOOL)isHidden {
    
    WS(ws)
    if (self.toolView == nil) {
        CGFloat y = SCREEN_HEIGHT;
        CGFloat h = SCREEN_HEIGHT / 2 + 100;
        
        self.toolView = [[HDPortraitToolBaseView alloc]initWithFrame:CGRectMake(0, y, SCREEN_WIDTH, h) hasAudioMode:self.audioMode qualityList:self.qualityList lineList:self.lineList rateList:self.rateList];
        [self.boardView addSubview:self.toolView];
        self.toolView.closeBlock = ^{
            [ws setToolViewHidden:YES];
        };
        self.toolView.updateBlock = ^(HDPortraitToolModel * _Nonnull model) {
            if (ws.eventBlock) {
                ws.eventBlock(model);
                /// 开启音频模式，需要隐藏清晰度
                if (model.type == HDPortraitToolTypeWithAudioMode) {
                    [ws.toolView setQualityViewHidden:model.isSelected];
                }
            }
        };
    }
    
    if (self.toolView == nil && isHidden == YES) return;
    CGFloat y = isHidden == YES ? SCREEN_HEIGHT : SCREEN_HEIGHT / 2 - 100;
    CGFloat h = SCREEN_HEIGHT / 2 + 100;
    CGRect newFrame = CGRectMake(0, y, SCREEN_WIDTH, h);
    if (isHidden == NO) {
        self.boardView.hidden = NO;
        if (self.selectedAudioModeArray.count > 0) {
            HDPortraitToolModel *model = [self.selectedAudioModeArray firstObject];
            self.toolView.selectedAudioModeModel = model;
            [self.toolView setQualityViewHidden:model.isSelected];
        }
        if (self.selectedLineArray.count > 0) {
            self.toolView.selectedLineModel = [self.selectedLineArray firstObject];
        }
        if (self.selectedQualityArray.count > 0) {
            self.toolView.selectedQualityModel = [self.selectedQualityArray firstObject];
        }
        if (self.selectedRateArray.count > 0) {
            self.toolView.selectedRateModel = [self.selectedRateArray firstObject];
        }
    }
    
    [UIView animateWithDuration:0.35 animations:^{
        ws.toolView.frame = newFrame;
    } completion:^(BOOL finished) {
        if (isHidden == YES) {
            ws.boardView.hidden = YES;
        }
    }];
}

- (void)setAudioModeSelected:(BOOL)isSelected {
    if (_audioMode == NO) return; /// 无音频模式
    [self updateAudioMode:isSelected];
}

- (void)setQualityMetaData:(NSDictionary *)metaData {

    if (![metaData isKindOfClass:[NSDictionary class]] || _quality == NO) {
        NSString *result = _quality == YES ? @"YES" : @"NO";
        
        return;
    }
    if ([metaData.allKeys containsObject:kQualityList]) {
        NSArray *qualityList = metaData[kQualityList];
        if (qualityList.count <= 0) {
            
            return;
        }
        NSMutableArray *tempQuality = [NSMutableArray array];
        for (int i = 0; i < qualityList.count; i++) {
            HDQualityModel *model = qualityList[i];
            HDPortraitToolModel *nModel = [[HDPortraitToolModel alloc]init];
            nModel.desc = model.desc;
            nModel.value = model.quality;
            nModel.isSelected = NO;
            nModel.type = HDPortraitToolTypeWithQuality;
            nModel.index = i;
            [tempQuality addObject:nModel];
        }
        self.qualityList = [tempQuality copy];
    }else {
        
        return;
    }
    if ([metaData.allKeys containsObject:kCurrentQuality]) {
        HDQualityModel *qualityModel = metaData[kCurrentQuality];
        int currentIndex = 0;
        for (int i = 0; i < self.qualityList.count; i++) {
            HDPortraitToolModel *toolModel = self.qualityList[i];
            if ([toolModel.value isEqualToString:qualityModel.quality]) {
                currentIndex = i;
            }
        }
        HDPortraitToolModel *model = [[HDPortraitToolModel alloc]init];
        model.isSelected = YES;
        model.index = currentIndex;
        model.value = qualityModel.quality;
        model.desc = qualityModel.desc;
        model.type = HDPortraitToolTypeWithQuality;
        [self updateQualityModel:model];
    }else {
        
        return;
    }
}

- (void)setLineMetaData:(NSDictionary *)metaData {
    
    if (![metaData isKindOfClass:[NSDictionary class]] || _line == NO) {
        NSString *result = _line == YES ? @"YES" : @"NO";
        
        return;
    }
    if ([metaData.allKeys containsObject:kLineList]) {
        NSArray *lineList = metaData[@"lineList"];
        if (lineList.count <= 0) {
            
            return;
        }
        NSArray *temp = [self getLineDespWithNum:lineList.count];
        NSMutableArray *templine = [NSMutableArray array];
        for (int i = 0; i < temp.count; i++) {
            HDPortraitToolModel *model = [[HDPortraitToolModel alloc]init];
            model.value = [[NSString alloc]initWithFormat:@"%d",i];
            model.index = i;
            model.isSelected = NO;
            model.desc = temp[i];
            model.type = HDPortraitToolTypeWithLine;
            [templine addObject:model];
        }
        self.lineList = [templine copy];
    }else {
        
        return;
    }
    int index = 0;
    if ([metaData.allKeys containsObject:kLineIndexNum]) {
        index = [metaData[kLineIndexNum] intValue];
    }else {
        
        return;
    }
    NSArray *temp = [self getLineDespWithNum:self.lineList.count];
    HDPortraitToolModel *model = [[HDPortraitToolModel alloc]init];
    model.value = [[NSString alloc]initWithFormat:@"%d",index];
    model.index = index;
    model.isSelected = YES;
    model.desc = temp[index];
    model.type = HDPortraitToolTypeWithLine;
    [self updateLineModel:model];
}

- (void)setRateMetaData:(NSDictionary *)metaData {
    if (![metaData isKindOfClass:[NSDictionary class]] || _rate == NO) {
        NSString *result = _rate == YES ? @"YES" : @"NO";
        
        return;
    }
    if ([metaData.allKeys containsObject:@"rateList"]) {
        NSArray *rateList = metaData[@"rateList"];
        NSString *currentRate = @"1x";
        if ([metaData.allKeys containsObject:@"currentRate"]) {
            currentRate = metaData[@"currentRate"];
        }
        NSMutableArray *tempRate = [NSMutableArray array];
        for (int i = 0; i < rateList.count; i++) {
            HDPortraitToolModel *model = [[HDPortraitToolModel alloc]init];
            model.type = HDPortraitToolTypeWithRate;
            model.value = rateList[i];
            model.index = i;
            model.desc = rateList[i];
            model.isSelected = NO;
            if ([model.value isEqualToString:currentRate]) {
                model.isSelected = YES;
                [self updateRateModel:model];
            }
            [tempRate addObject:model];
        }
        self.rateList = [tempRate copy];
    }
}

// MARK: - CUSTOM METHOD
- (void)updateAudioMode:(BOOL)audioMode {
    HDPortraitToolModel *model = [[HDPortraitToolModel alloc]init];
    model.type = HDPortraitToolTypeWithAudioMode;
    model.isSelected = audioMode;
    model.index = 0;
    model.desc = @"";
    model.value = @"";
    if (self.selectedAudioModeArray.count > 0) {
        [self.selectedAudioModeArray replaceObjectAtIndex:0 withObject:model];
    }else {
        [self.selectedAudioModeArray removeAllObjects];
        [self.selectedAudioModeArray addObject:model];
    }
}

- (void)updateQualityModel:(HDPortraitToolModel *)model {
    HDPortraitToolModel *nModel = [[HDPortraitToolModel alloc]init];
    nModel.type = HDPortraitToolTypeWithQuality;
    nModel.isSelected = YES;
    nModel.index = model.index;
    nModel.desc = model.desc;
    nModel.value = model.value;
    if (self.selectedQualityArray.count > 0) {
        [self.selectedQualityArray replaceObjectAtIndex:0 withObject:nModel];
    }else {
        [self.selectedQualityArray removeAllObjects];
        [self.selectedQualityArray addObject:nModel];
    }
}

- (void)updateLineModel:(HDPortraitToolModel *)model {
    HDPortraitToolModel *nModel = [[HDPortraitToolModel alloc]init];
    nModel.type = model.type;
    nModel.isSelected = model.isSelected;
    nModel.index = model.index;
    nModel.desc = model.desc;
    nModel.value = model.value;
    if (self.selectedLineArray.count > 0) {
        [self.selectedLineArray replaceObjectAtIndex:0 withObject:nModel];
    }else {
        [self.selectedLineArray removeAllObjects];
        [self.selectedLineArray addObject:nModel];
    }
}

- (NSArray *)getLineDespWithNum:(NSInteger)num {
    NSArray *array = @[];
    switch (num) {
        case 1:
            array = @[kLine1];
            break;
        case 2:
            array = @[kLine1,kLine2];
            break;
        case 3:
            array = @[kLine1,kLine2,kLine3];
            break;

        default:
            break;
    }
    return array;
}

- (void)updateRateModel:(HDPortraitToolModel *)model {
    HDPortraitToolModel *nModel = [[HDPortraitToolModel alloc]init];
    nModel.type = model.type;
    nModel.isSelected = model.isSelected;
    nModel.index = model.index;
    nModel.desc = model.desc;
    nModel.value = model.value;
    if (self.selectedRateArray.count > 0) {
        [self.selectedRateArray replaceObjectAtIndex:0 withObject:nModel];
    }else {
        [self.selectedRateArray removeAllObjects];
        [self.selectedRateArray addObject:nModel];
    }
}

// MARK: - LAZY
- (NSMutableArray *)selectedAudioModeArray {
    if (!_selectedAudioModeArray) {
        _selectedAudioModeArray = [NSMutableArray array];
    }
    return _selectedAudioModeArray;
}

- (NSMutableArray *)selectedQualityArray {
    if (!_selectedQualityArray) {
        _selectedQualityArray = [NSMutableArray array];
    }
    return _selectedQualityArray;
}

- (NSMutableArray *)selectedLineArray {
    if (!_selectedLineArray) {
        _selectedLineArray = [NSMutableArray array];
    }
    return _selectedLineArray;
}

- (NSMutableArray *)selectedRateArray {
    if (!_selectedRateArray) {
        _selectedRateArray = [NSMutableArray array];
    }
    return _selectedRateArray;
}

@end
