//
//  HDRedPacketRainEngine.m
//  CCLiveCloud
//
//  Created by Richard Lee on 7/1/21.
//  Copyright © 2021 MacBook Pro. All rights reserved.
//

#import "HDRedPacketRainEngine.h"
#import "HDRedPacketRainView.h"
#import "HDRedPacketRankView.h"
#import "HDRedPacketRainConfiguration.h"
#import "CCcommonDefine.h"

#define kGoldColor CCRGBAColor(255, 194, 17, 1)
#define kRedPacketTip @"红包雨来袭"

@interface HDRedPacketRainEngine ()

/// 配置信息
@property (nonatomic, strong) HDRedPacketRainConfiguration       *configuration;
/// 点击红包回调
@property (nonatomic, copy)   TagRedPacketClosure       tagRedPacketClosure;
/// 结束红包雨回调
@property (nonatomic, copy)   EndRedPacketClosure       endRedPacketClosure;
/// 关闭按钮回调
@property (nonatomic, copy)   CloseRankClosure          closeRankClosure;

/// 定时器
@property (nonatomic, strong) NSTimer                   *timer;
/// 倒计时动画
@property (nonatomic, strong) UIImageView               *countdownImageView;
/// 倒计时动画显示时长
@property (nonatomic, assign) int                       countdownDuration;
/// 倒计时
@property (nonatomic, strong) UILabel                   *countdownLabel;
/// 倒计时 计数
@property (nonatomic, assign) int                       countdown;
/// 红包雨提示语
@property (nonatomic, strong) UILabel                   *redPacketTipLabel;

/// 倒计时动画数组
@property (nonatomic, strong) NSMutableArray            *countdownImageArray;
/// 红包雨视图
@property (nonatomic, strong) HDRedPacketRainView       *redPacketRainView;
/// 计数器
@property (nonatomic, assign) int                       counter;

/// 排行榜视图
@property (nonatomic, strong) HDRedPacketRankView       *rankView;

@end

static HDRedPacketRainEngine *_shared = nil;
@implementation HDRedPacketRainEngine

// MARK: - API
+ (instancetype)shared {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shared = [[HDRedPacketRainEngine alloc]init];
        _shared.counter = 0;
    });
    return _shared;
}

- (void)prepareRedPacketWithConfiguration:(HDRedPacketRainConfiguration *)configuration
                      tapRedPacketClosure:(TagRedPacketClosure)tagRedPacketClosure
                      endRedPacketClosure:(EndRedPacketClosure)endRedPacketClosure {
    self.configuration = configuration;
    self.tagRedPacketClosure = tagRedPacketClosure;
    self.endRedPacketClosure = endRedPacketClosure;
    /// 初始化红包雨视图
    [self setupRedPacketRainView];
    /// 需要显示倒计时动画
    if (configuration.isShowCountdownAnimation) {
        NSTimeInterval time = self.configuration.currentTime - self.configuration.startTime;
        if (time > 2000 && time <= 3000) {
            self.countdown = 1;
        }else if (time > 1000 && time <= 2000) {
            self.countdown = 2;
        }else if (time > 0 && time <= 1000) {
            self.countdown = 3;
        }else {
            self.countdown = 0;
        }
        self.countdownDuration = self.countdown;
        [self addCountdownImages];
    }
    if (self.rankView) {
        [self.rankView removeFromSuperview];
        self.rankView = nil;
    }
}

/// 开始红包雨
- (void)startRedPacketRain {
    
    if (self.rankView) {
        [self.rankView removeFromSuperview];
        self.rankView = nil;
    }
    [self startTimer];
}

/// 停止红包雨
- (void)stopRedRacketRain {
    
    if (self.redPacketRainView) {
        [self.redPacketRainView stopPerformance];
        [self stopTimer];
        if (self.endRedPacketClosure) {
            self.endRedPacketClosure();
        }
        if (self.redPacketRainView) {
            [self.redPacketRainView removeFromSuperview];
            self.redPacketRainView = nil;
        }
    }
}

/// 展示排行榜
/// @param model 排行榜
/// @param closeRankClosure 关闭按钮回调
- (void)showRedPacketRainRank:(HDSRedPacketRankModel *)model closeRankClosure:(nonnull CloseRankClosure)closeRankClosure {
    
    if (self.rankView) {
        [self.rankView removeFromSuperview];
        self.rankView = nil;
    }
    self.closeRankClosure = closeRankClosure;
    BOOL isLandSep = SCREEN_WIDTH > SCREEN_HEIGHT ? YES : NO;
    CGFloat rankViewW = 313;
    CGFloat rankViewX = (SCREEN_WIDTH - rankViewW) / 2;
    CGFloat rankViewY = isLandSep == YES ? 35 : (SCREEN_HEIGHT - 459) / 2;
    CGFloat rankViewH = isLandSep == YES ? SCREEN_HEIGHT - 75 : 459;
    
    CGRect frame = CGRectMake(rankViewX, rankViewY, rankViewW, rankViewH);
    self.rankView = [[HDRedPacketRankView alloc] initWithFrame:frame
                                                 configuration:model
                                              closeRankClosure:^{
        if (self.closeRankClosure) {
            self.closeRankClosure();
        }
    }];
    
    [self.configuration.boardView addSubview:self.rankView];
}

// MARK: - CustomMethod
- (void)startTimer {
    [self stopTimer];
    
    if (self.configuration.isShowCountdownAnimation == YES) {
    
        [self setupCountdownAnimation];
    }
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(timerFunc) userInfo:nil repeats:YES];
}

- (void)stopTimer {
    
    if ([self.timer isValid]) {
        [self.timer invalidate];
        self.timer = nil;
        self.counter = 0;
    }
}

- (void)timerFunc {
    self.counter++;
    
    if (self.configuration.isShowCountdownAnimation == YES) {
        /// 倒计时
        if (self.countdownLabel && self.countdown > 0) {
            self.countdown--;
            self.countdownLabel.text = [[NSString alloc]initWithFormat:@"%d",self.countdown];
        }else {
            self.countdownLabel.hidden = YES;
        }
        /// 倒计时结束开始红包雨
        if (self.counter == self.countdownDuration) {
            
            /// 重制倒计时功能
            [self resetCountdownFunc];
            self.redPacketRainView.hidden = NO;
            [self.redPacketRainView startPerformance];
        /// 红包雨时间结束
        }else if (self.counter == self.configuration.duration + self.countdownDuration ) {
            
            [self stopRedRacketRain];
        }
    }else {
        /// 开始红包雨
        if (self.counter == 1) {
            
            self.redPacketRainView.hidden = NO;
            [self.redPacketRainView startPerformance];
        /// 红包雨结束
        }else if (self.counter == self.configuration.duration) {
            
            [self stopRedRacketRain];
        }
    }
}

/// 添加打开动画
- (void)addCountdownImages {
    
    [self.countdownImageArray removeAllObjects];
    for (int i = 0; i < 10; i++) {
        NSString *fileName = [NSString stringWithFormat:@"%@_%i",@"red_packet_anim", i];
        UIImage *image = [self loadImage:fileName bundle:@"RedPacketBundle" subBundle:@"Resources"];
        [self.countdownImageArray addObject:image];
    }
}

/// 重制倒计时功能
- (void)resetCountdownFunc {
    if (self.countdownImageView) {
        [self.countdownImageView removeFromSuperview];
        self.countdownImageView = nil;
    }
    if (self.countdownLabel) {
        [self.countdownLabel removeFromSuperview];
        self.countdownLabel = nil;
    }
    if (self.redPacketTipLabel) {
        [self.redPacketTipLabel removeFromSuperview];
        self.redPacketTipLabel = nil;
    }
}

/// 设置倒计时动画
- (void)setupCountdownAnimation {
    /// 重制
    [self resetCountdownFunc];
    
    CGFloat boardW = self.configuration.boardView.frame.size.width;
    CGFloat boardH = self.configuration.boardView.frame.size.height;
    CGFloat w = 182;
    CGFloat h = w;
    CGFloat x = (boardW - w) / 2;
    CGFloat y = (boardH - h) / 2;
    self.countdownImageView = [[UIImageView alloc]initWithFrame:CGRectMake(x, y, w, h)];
    self.countdownImageView.animationImages = [self.countdownImageArray copy];
    self.countdownImageView.animationRepeatCount = 0;
    self.countdownImageView.animationDuration = 1;
    [self.countdownImageView startAnimating];
    [self.configuration.boardView addSubview:self.countdownImageView];
    
    CGFloat labelH = 50;
    CGFloat labelW = 200;
    CGFloat labelX = (self.configuration.boardView.frame.size.width - labelW) / 2;
    CGFloat labelY = y - labelH - 10;
    self.countdownLabel = [[UILabel alloc]initWithFrame:CGRectMake(labelX, labelY, labelW, labelH)];
    self.countdownLabel.text = [[NSString alloc]initWithFormat:@"%d",self.countdown];
    self.countdownLabel.textColor = kGoldColor;
    self.countdownLabel.textAlignment = NSTextAlignmentCenter;
    self.countdownLabel.font = [UIFont boldSystemFontOfSize:60];
    [self.configuration.boardView addSubview:self.countdownLabel];

    CGFloat tipW = 200;
    CGFloat tipH = 25;
    CGFloat tipX = (self.configuration.boardView.frame.size.width - tipW) / 2;
    CGFloat tipY = CGRectGetMaxY(self.countdownImageView.frame) + 5;
    self.redPacketTipLabel = [[UILabel alloc]initWithFrame:CGRectMake(tipX, tipY, tipW, tipH)];
    self.redPacketTipLabel.text = kRedPacketTip;
    self.redPacketTipLabel.textColor = kGoldColor;
    self.redPacketTipLabel.textAlignment = NSTextAlignmentCenter;
    self.redPacketTipLabel.font = [UIFont boldSystemFontOfSize:18];
    [self.configuration.boardView addSubview:self.redPacketTipLabel];
}

/// 设置红包雨视图
- (void)setupRedPacketRainView {
    
    /// 停止定时器
    [self stopTimer];
    if (self.redPacketRainView) {
        [self.redPacketRainView removeFromSuperview];
        self.redPacketRainView = nil;
    }
    self.redPacketRainView = [[HDRedPacketRainView alloc]initWithFrame:self.configuration.boardView.frame
                                                         configuration:self.configuration
                                                   tapRedPacketClosure:^(int index) {
        if (self.tagRedPacketClosure) {
            self.tagRedPacketClosure(index);
        }
    }];
    self.redPacketRainView.hidden = YES;
    [self.configuration.boardView addSubview:self.redPacketRainView];
}

// MARK: - Lazy
- (NSMutableArray *)countdownImageArray {
    if (!_countdownImageArray) {
        _countdownImageArray = [NSMutableArray array];
    }
    return _countdownImageArray;
}

/// 加载本地图片资源
- (UIImage *)loadImage:(NSString *)imgName bundle:(NSString *)bundle subBundle:(NSString *)subbundle {
    NSString * path = [[NSBundle mainBundle]pathForResource:bundle ofType:@"bundle"];
    NSString *secondP = [path stringByAppendingPathComponent:subbundle];
    NSString *imgNameFile = [secondP stringByAppendingPathComponent:imgName];
    UIImage *image = [UIImage imageWithContentsOfFile:imgNameFile];
    return image;
}

- (void)dealloc {
    
    [self stopTimer];
}
@end
