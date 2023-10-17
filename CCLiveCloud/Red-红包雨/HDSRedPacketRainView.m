//
//  HDSRedPacketRainView.m
//  CCLiveCloud
//
//  Created by 刘强强 on 2022/4/8.
//  Copyright © 2022 MacBook Pro. All rights reserved.
//

#import "HDSRedPacketRainView.h"
#import "HDSRedPacketRankView.h"
#import "HDSRedPacketRainConfiguration.h"
#import "HDSRedPacketView2.h"
#import "UIImage+animatedGIF.h"
#import "UIColor+RCColor.h"
#import "CCcommonDefine.h"
#import "UIView+Extension.h"
#import <Masonry/Masonry.h>

#define kDefaultHeight 812

@interface HDSRedPacketRainView ()<HDSRedPacketView2Delegate>

/// 配置信息
@property (nonatomic, strong) HDSRedPacketRainConfiguration          *configuration;
/// 点击红包回调
@property (nonatomic, copy)   TagRedPacketClosure          tagRedPacketClosure;
/// 结束红包雨回调
@property (nonatomic, copy)   EndRedPacketClosure          endRedPacketClosure;
/// 红包雨定时器
@property (nonatomic, strong) NSTimer                      *performanceTimer;
/// 红包需要在屏幕上显示的时间
@property (nonatomic, assign) NSTimeInterval               fallingTime;
/// 上次点击时间
@property (nonatomic, assign) NSInteger                    lastClickTime;
/// 红包宽度
@property (nonatomic, assign) CGFloat                      itemW;
/// 红包高度
@property (nonatomic, assign) CGFloat                      itemH;
/// 每个红包y值的偏移量
@property (nonatomic, assign) CGFloat                      itemOffset;
/// 上个通道的标签
@property (nonatomic, assign) int                          lastTag;
/// 红包显示图片
@property (nonatomic, copy)   NSString                     *redPacketImageName;
/// 打开动画数组
@property (nonatomic, strong) NSMutableArray               *openImageArray;
/// 原始红包数组
@property (nonatomic, strong) NSMutableArray               *redPacketSourceArray;
/// 已抢到红包数量描述
//@property(nonatomic, strong) UILabel                       *openCountTip;
///// 已抢到红包数量
//@property(nonatomic, strong) UIImageView                   *openCountImg;
//@property(nonatomic, strong) UIImageView                   *openCountXImg;
/// 已抢到红包数量
//@property(nonatomic, strong) UILabel                       *openCountLb;
/// 红包倒计时
@property(nonatomic, strong) UIImageView                   *topTimeBgImg;
/// 红包倒计时lb
@property(nonatomic, strong) UILabel                       *topTimeLb;
@property(nonatomic, strong) UILabel                       *topTimeCountLb;

/// 抢到的数量
@property(nonatomic, assign) NSInteger                     openRedCount;

@property (nonatomic, copy) NSArray *driftDownUrls;


@end

@implementation HDSRedPacketRainView

// MARK: - API
- (instancetype)initWithFrame:(CGRect)frame configuration:(HDSRedPacketRainConfiguration *)configuration tapRedPacketClosure:(TagRedPacketClosure)tagRedPacketClosure {
    if (self = [super initWithFrame:frame]) {
        self.configuration = configuration;
        self.tagRedPacketClosure = tagRedPacketClosure;
        self.fallingTime = configuration.fallingTime;
        self.itemW = configuration.itemW;
        self.itemH = configuration.itemH;
        self.redPacketImageName = configuration.redPacketImageName;
        self.driftDownUrls = configuration.driftDownUrls;
        self.itemOffset = configuration.itemH * 2 / 3 * (SCREEN_HEIGHT / kDefaultHeight);
        [self setupBaseUI];
        [self addOpenImages];
    }
    return self;
}

- (void)setupBaseUI {
    self.backgroundColor = [UIColor colorWithHexString:@"#000000" alpha:0.5];
    [self addSubview:self.topTimeBgImg];
    [self.topTimeBgImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(self).offset(31);
        make.height.width.mas_equalTo(180);
    }];
    
    [self.topTimeBgImg addSubview:self.topTimeLb];
    [self.topTimeLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.topTimeBgImg).offset(-10);
        make.centerX.equalTo(self.topTimeBgImg);
    }];
    
    [self.topTimeBgImg addSubview:self.topTimeCountLb];
    [self.topTimeCountLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.topTimeLb.mas_bottom).offset(10);
        make.centerX.equalTo(self.topTimeBgImg);
    }];
    
//    [self addSubview:self.openCountImg];
//    [self.openCountImg mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(self).offset(14);
//        make.bottom.equalTo(self).offset(-10);
//        make.width.mas_equalTo(28.5);
//        make.height.mas_equalTo(36);
//    }];
//
//    [self addSubview:self.openCountXImg];
//    [self.openCountXImg mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(self.openCountImg.mas_right).offset(7.5);
//        make.centerY.equalTo(self.openCountImg);
//        make.width.height.mas_equalTo(12);
//    }];
    
//    [self addSubview:self.openCountLb];
//    [self.openCountLb mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(self.openCountXImg.mas_right).offset(5);
//        make.centerY.equalTo(self.openCountImg);
//    }];
    
//    [self addSubview:self.openCountTip];
//    [self.openCountTip mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(self).offset(22);
//        make.bottom.equalTo(self.openCountImg.mas_top).offset(-9);
//    }];
}

/// 开始红包雨
- (void)startPerformance {
    [self stopPerformance];
    _performanceTimer = [NSTimer scheduledTimerWithTimeInterval:(0.01/3.0) target:self selector:@selector(timerFunc) userInfo:nil repeats:YES];
}

/// 停止红包雨
- (void)stopPerformance {
    if([_performanceTimer isValid]) {
        [_performanceTimer invalidate];
        _performanceTimer = nil;
    }
}

// MARK: - CustomMethod
- (void)timerFunc {
    [self updateBtnFrame];
}

- (void)updateTime:(NSInteger)timeCount {
    
    self.topTimeCountLb.text = [NSString stringWithFormat:@"%@",[self getTimeStr:timeCount]];
}

- (NSString *)getTimeStr:(NSInteger)timeCount {
    NSInteger min = timeCount / 60;
    NSInteger seconds = timeCount % 60;
    
    return [NSString stringWithFormat:@"%.2ld:%.2ld",min, seconds];
}

/// 添加打开动画
- (void)addOpenImages {
    [self.openImageArray removeAllObjects];
    for (int i = 0; i < 12; i++) {
        NSString *fileName = [NSString stringWithFormat:@"%@_%i",@"打开", i];
        UIImage *image = [self loadImage:fileName bundle:@"RedPacketBundle" subBundle:@"Resources"];
        [self.openImageArray addObject:image];
    }
    [self initRedPacket];
}

/// 初始化红包
- (void)initRedPacket {
    
    for (int j = 0; j < 12; j++) {
        
        HDSRedPacketView2 *redPacket = [[HDSRedPacketView2 alloc] initWithFrame:CGRectMake([self getRandomX], -(self.itemOffset * j + self.itemH), self.itemW, self.itemH)];
        redPacket.delegate = self;
        redPacket.userInteractionEnabled = YES;
        if (self.driftDownUrls.count > 0) {
            int count = (int)self.driftDownUrls.count-1;
            int index = [self getRandomNumber:0 to:count];
            NSString *url = [self.driftDownUrls objectAtIndex:index];
            [redPacket setUrl:url];
        } else {
            redPacket.image = [UIImage imageNamed:self.redPacketImageName];
        }
        // 1. 创建动画
        CAKeyframeAnimation *keyAnima = [CAKeyframeAnimation animation];
        // 2. 摇动动画
        keyAnima.keyPath = @"transform.rotation";
        
        keyAnima.values = @[@(-M_PI_4 / 90.0 * 15),@(M_PI_4 / 90.0 * 15),@(-M_PI_4 / 90.0 * 15)];
        // 3. 执行完之后不删除动画
        keyAnima.removedOnCompletion = NO;
        // 4. 执行完之后保存最新的状态
        keyAnima.fillMode = kCAFillModeForwards;
        // 5. 动画执行时间
        keyAnima.duration = 0.35;
        // 6. 动画重复次数
        keyAnima.repeatCount = MAXFLOAT;
        [redPacket.layer addAnimation:keyAnima forKey:@"groupAnimation"];
        
        [self addSubview:redPacket];
        
        [self.redPacketSourceArray addObject:redPacket];
    }
}

/// 更新红包视图
- (void)updateBtnFrame {
    if (self.redPacketSourceArray.count == 0) return;
    @autoreleasepool {
        dispatch_async(dispatch_get_main_queue(), ^{
            for (int i = 0; i < self.redPacketSourceArray.count; i++) {
                HDSRedPacketView2 *redPacket = self.redPacketSourceArray[i];
                CGFloat y = redPacket.frame.origin.y + ((self.configuration.boardView.frame.size.height + self.itemH + 60) / self.fallingTime / 300);
                redPacket.frame = CGRectMake(redPacket.frame.origin.x, y, redPacket.size.width, redPacket.size.height);
                if (redPacket.frame.origin.y > self.configuration.boardView.size.height + 50) {
                    redPacket.frame = CGRectMake([self getRandomX], -(redPacket.frame.origin.y - self.configuration.boardView.frame.size.height + self.itemOffset), self.itemW, self.itemH);
                    if (redPacket.hidden == YES) {
                        redPacket.hidden = NO;
                    }
                }
            }
        });
    }
}

// MARK: - 点击红包
/// 点击视图代理
/// @param touchView 点击的红包
- (void)hdsViewDidTouch:(HDSRedPacketView2 *)touchView {
    @autoreleasepool {
        if (self.tagRedPacketClosure) {
            
            self.tagRedPacketClosure(0);
//            [self updateRedPacketRainViewOpenCount];
        }
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:touchView.frame];
        imageView.image = [UIImage imageNamed:@"+1"];
        [UIView animateWithDuration:0.35 animations:^{
            imageView.transform = CGAffineTransformMakeScale(1.1, 1.1);
        }];
        [self addSubview:imageView];
        [imageView startAnimating];
        touchView.hidden = YES;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self hiddenSelectRedPacket:imageView];
        });
    }
}

//- (void)updateRedPacketRainViewOpenCount {
//    self.openRedCount ++;
//    self.openCountLb.text = [NSString stringWithFormat:@"%ld",self.openRedCount];
//}

/// 隐藏选中的红包
/// @param imageView 红包视图
- (void)hiddenSelectRedPacket:(UIImageView *)imageView {
    @autoreleasepool {
        [imageView removeFromSuperview];
        imageView = nil;
    }
}

// MARK: - tools
/// 获取随机的位置
- (CGRect )getFrame {
    return CGRectMake([self getRandomX], -(self.itemH + 10), self.itemW, self.itemH);
}

/// 获取随机的X值
- (float)getRandomX {
    [self getRandomInt:1 to:10];
    float originX = [self getRandomX2WithTag:self.lastTag];
    return originX;
}

/// 取出X值
/// @param tag 通道序号
- (float)getRandomX2WithTag:(int)tag {
    float originX = 0;
    float w = (float)self.frame.size.width - self.itemW;
    float fromX = 0;
    float to = w / 9;
    if (tag == 1) {

    }else if (tag == 2) {
        fromX = w/9;
        to = w/9*2;
    }else if (tag == 3) {
        fromX = w/9*2;
        to= w/9*3;
    }else if (tag == 4) {
        fromX = w/9*3;
        to= w/9*4;
    }else if (tag == 5) {
        fromX = w/9*4;
        to= w/9*5;
    }else if (tag == 6) {
        fromX = w/9*5;
        to = w/9*6;
    }else if (tag == 7) {
        fromX = w/9*6;
        to = w/9*7;
    }else if (tag == 8) {
        fromX = w/9*7;
        to = w/9*8;
    }else {
        fromX = w/9*8;
        to = w;
    }
    originX = [self getRandomFloat:fromX to: to];
    return originX;
}

/// 获取随机数
- (int)getRandomNumber:(int)from to:(int)to {
    return (int)(from + (arc4random() % (to - from + 1)));
}

/// 生成随机整数
- (void)getRandomInt:(int)from to:(int)to {
    int tag = (int)(from + (arc4random() % (to - from)));
    if (tag == self.lastTag || abs(tag - self.lastTag) < 3) {
        [self getRandomInt:from to:to];
    }else {
        self.lastTag = tag;
    }
}
/// 生成随机浮点数
- (float)getRandomFloat:(float)from to:(float)to {
    float diff = to - from;
    CGFloat finalX = (((float) arc4random() / UINT_MAX) * diff) + from;
    return finalX;
}

/// 加载本地图片资源
- (UIImage *)loadImage:(NSString *)imgName bundle:(NSString *)bundle subBundle:(NSString *)subbundle {
    NSString * path = [[NSBundle mainBundle]pathForResource:bundle ofType:@"bundle"];
    NSString *secondP = [path stringByAppendingPathComponent:subbundle];
    NSString *imgNameFile = [secondP stringByAppendingPathComponent:imgName];
    UIImage *image = [UIImage imageWithContentsOfFile:imgNameFile];
    return image;
}

/// 获取当前时间
- (NSInteger)getTime {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];
    [formatter setTimeZone:timeZone];
    NSDate *datenow = [NSDate date];
    NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)([datenow timeIntervalSince1970]*1000) ];
    return [timeSp integerValue];
}

// MARK: - LAZY
- (NSMutableArray *)openImageArray {
    if (!_openImageArray) {
        _openImageArray = [NSMutableArray array];
    }
    return _openImageArray;
}

- (NSMutableArray *)redPacketSourceArray {
    if (!_redPacketSourceArray) {
        _redPacketSourceArray = [NSMutableArray array];
    }
    return _redPacketSourceArray;
}

//- (UIImageView *)openCountImg {
//    if (!_openCountImg) {
//        _openCountImg = [[UIImageView alloc] init];
//        _openCountImg.image = [UIImage imageNamed:@"红包"];
//    }
//    return _openCountImg;
//}
//
//- (UIImageView *)openCountXImg {
//    if (!_openCountXImg) {
//        _openCountXImg = [[UIImageView alloc] init];
//        _openCountXImg.image = [UIImage imageNamed:@"×"];
//    }
//    return _openCountXImg;
//}

//- (UILabel *)openCountLb {
//    if (!_openCountLb) {
//        _openCountLb = [[UILabel alloc] init];
//        _openCountLb.textColor = [UIColor colorWithHexString:@"#FFDC53" alpha:1];
//        _openCountLb.font = [UIFont systemFontOfSize:21];
//        _openCountLb.text = @"0";
//    }
//    return _openCountLb;
//}

- (UIImageView *)topTimeBgImg {
    if (!_topTimeBgImg) {
        _topTimeBgImg = [[UIImageView alloc] init];
        _topTimeBgImg.image = [UIImage imageNamed:@"椭圆形"];
    }
    return _topTimeBgImg;
}

- (UILabel *)topTimeLb {
    if (!_topTimeLb) {
        _topTimeLb = [[UILabel alloc] init];
        _topTimeLb.textColor = [UIColor colorWithHexString:@"#FFDC53" alpha:1];
        _topTimeLb.text = @"剩余时间";
        _topTimeLb.font = [UIFont systemFontOfSize:16];
        _topTimeLb.textAlignment = NSTextAlignmentCenter;
    }
    return _topTimeLb;
}

- (UILabel *)topTimeCountLb {
    if (!_topTimeCountLb) {
        _topTimeCountLb = [[UILabel alloc] init];
        _topTimeCountLb.textColor = [UIColor colorWithHexString:@"#FFDC53" alpha:1];
        _topTimeCountLb.font = [UIFont systemFontOfSize:27];
        _topTimeCountLb.textAlignment = NSTextAlignmentCenter;
    }
    return _topTimeCountLb;
}

//- (UILabel *)openCountTip {
//    if (!_openCountTip) {
//        _openCountTip = [[UILabel alloc] init];
//        _openCountTip.textColor = [UIColor colorWithHexString:@"#FFFFFF" alpha:1];
//        _openCountTip.font = [UIFont systemFontOfSize:16];
//    }
//    return _openCountTip;
//}

@end
