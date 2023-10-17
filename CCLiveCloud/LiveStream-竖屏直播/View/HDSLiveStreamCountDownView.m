//
//  HDSLiveStreamCountDownView.m
//  CCLiveCloud
//
//  Created by richard lee on 12/19/22.
//  Copyright © 2022 MacBook Pro. All rights reserved.
//

#import "HDSLiveStreamCountDownView.h"
#import "UIColor+RCColor.h"
#import "UIView+Extension.h"
#import <Masonry/Masonry.h>

@interface HDSLiveStreamCountDownView ()

@property (nonatomic, strong) UIView *boardView;

@property (nonatomic, strong) UILabel *tipLabel;

@property (nonatomic, strong) UIView *dayView;
@property (nonatomic, strong) UIView *hourView;
@property (nonatomic, strong) UIView *minuteView;
@property (nonatomic, strong) UIView *secondView;

@property (nonatomic, strong) UILabel *dayLabel;
@property (nonatomic, strong) UILabel *hourLabel;
@property (nonatomic, strong) UILabel *minuteLabel;
@property (nonatomic, strong) UILabel *secondLabel;

@property (nonatomic, strong) UILabel *dayLine;
@property (nonatomic, strong) UILabel *hourLine;
@property (nonatomic, strong) UILabel *minuteLine;
@property (nonatomic, strong) UILabel *secondLine;

@property (nonatomic, strong) UILabel *dayText;
@property (nonatomic, strong) UILabel *hourText;
@property (nonatomic, strong) UILabel *minuteText;
@property (nonatomic, strong) UILabel *secondText;

@property (nonatomic, strong) UILabel *dayDivision;
@property (nonatomic, strong) UILabel *hourDivision;
@property (nonatomic, strong) UILabel *minuteDivision;

//@property (nonatomic, strong) UIImageView *bottomIMGView;

@property (nonatomic, strong) dispatch_source_t timer;

@property (nonatomic, strong) UILabel *bottomCountDown;

@end

@implementation HDSLiveStreamCountDownView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        __weak typeof(self) weakSelf = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf customUI];
            [weakSelf customConstraints];
        });
    }
    return self;
}

- (void)setPlayerBGHint:(NSString *)playerBGHint {
    if (playerBGHint.length == 0) {
        return;
    }
    _tipLabel.text = playerBGHint;
}

- (void)setCountDown:(NSString *)countDown type:(HDSLiveStreamCountDownViewType)type {
    NSInteger countD = [countDown integerValue];
    [self updateCountDown:countD];
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (type == HDSLiveStreamCountDownViewTypeCenter) {
            weakSelf.bottomCountDown.hidden = YES;
            weakSelf.boardView.hidden = NO;
            //weakSelf.bottomIMGView.hidden = NO;
        } else {
            weakSelf.bottomCountDown.hidden = NO;
            weakSelf.boardView.hidden = YES;
            //weakSelf.bottomIMGView.hidden = YES;
        }
    });
}


// MARK: - Custom Method
- (void)customUI {
    
    // 0.背景
    _boardView = [[UIView alloc]init];
    [self addSubview:_boardView];
    
    // 1.提示语
    _tipLabel = [[UILabel alloc]init];
    _tipLabel.text = @"距开播";
    _tipLabel.textColor = [UIColor colorWithHexString:@"#FFFFFF" alpha:0.85];
    _tipLabel.font = [UIFont systemFontOfSize:13];
    _tipLabel.textAlignment = NSTextAlignmentCenter;
    [_boardView addSubview:_tipLabel];
    // 2.天视图
    _dayView = [[UIView alloc]init];
    _dayView.backgroundColor = [UIColor colorWithHexString:@"#141519" alpha:1];
    [_boardView addSubview:_dayView];
    // 2.1 天
    _dayLabel = [[UILabel alloc]init];
    _dayLabel.textColor = [UIColor colorWithHexString:@"#FFFFFF" alpha:1];
    _dayLabel.font = [UIFont boldSystemFontOfSize:15];
    _dayLabel.textAlignment = NSTextAlignmentCenter;
    [_dayView addSubview:_dayLabel];
    // 2.2 分割线
    _dayLine = [[UILabel alloc]init];
    _dayLine.backgroundColor = [UIColor colorWithHexString:@"#FFFFFF" alpha:1];
    _dayLine.layer.opacity = 0.1;
    [_dayView addSubview:_dayLine];
    // 2.3 文字
    _dayText = [[UILabel alloc]init];
    _dayText.text = @"DAY";
    _dayText.textColor = [UIColor colorWithHexString:@"#FFFFFF" alpha:0.45];
    _dayText.textAlignment = NSTextAlignmentCenter;
    _dayText.font = [UIFont systemFontOfSize:9];
    [_dayView addSubview:_dayText];
    
    _dayDivision = [[UILabel alloc]init];
    _dayDivision.text = @":";
    _dayDivision.textColor = [UIColor colorWithHexString:@"#141519" alpha:1];
    _dayDivision.font = [UIFont boldSystemFontOfSize:16];
    _dayDivision.textAlignment = NSTextAlignmentCenter;
    [_boardView addSubview:_dayDivision];
    
    // 3.小时视图
    _hourView = [[UIView alloc]init];
    _hourView.backgroundColor = [UIColor colorWithHexString:@"#141519" alpha:1];
    [_boardView addSubview:_hourView];
    // 3.1 小时
    _hourLabel = [[UILabel alloc]init];
    _hourLabel.textColor = [UIColor colorWithHexString:@"#FFFFFF" alpha:1];
    _hourLabel.font = [UIFont boldSystemFontOfSize:15];
    _hourLabel.textAlignment = NSTextAlignmentCenter;
    [_hourView addSubview:_hourLabel];
    // 3.2 分割线
    _hourLine = [[UILabel alloc]init];
    _hourLine.backgroundColor = [UIColor colorWithHexString:@"#FFFFFF" alpha:1];
    _hourLine.layer.opacity = 0.1;
    [_hourView addSubview:_hourLine];
    // 3.3 文字
    _hourText = [[UILabel alloc]init];
    _hourText.text = @"HOUR";
    _hourText.textColor = [UIColor colorWithHexString:@"#FFFFFF" alpha:0.45];
    _hourText.textAlignment = NSTextAlignmentCenter;
    _hourText.font = [UIFont systemFontOfSize:9];
    [_hourView addSubview:_hourText];
    
    _hourDivision = [[UILabel alloc]init];
    _hourDivision.text = @":";
    _hourDivision.textColor = [UIColor colorWithHexString:@"#141519" alpha:1];
    _hourDivision.font = [UIFont boldSystemFontOfSize:16];
    _hourDivision.textAlignment = NSTextAlignmentCenter;
    [_boardView addSubview:_hourDivision];
    
    // 4.分钟视图
    _minuteView = [[UIView alloc]init];
    _minuteView.backgroundColor = [UIColor colorWithHexString:@"#141519" alpha:1];
    [_boardView addSubview:_minuteView];
    // 4.1 分钟
    _minuteLabel = [[UILabel alloc]init];
    _minuteLabel.textColor = [UIColor colorWithHexString:@"#FFFFFF" alpha:1];
    _minuteLabel.font = [UIFont boldSystemFontOfSize:15];
    _minuteLabel.textAlignment = NSTextAlignmentCenter;
    [_minuteView addSubview:_minuteLabel];
    // 4.2 分割线
    _minuteLine = [[UILabel alloc]init];
    _minuteLine.backgroundColor = [UIColor colorWithHexString:@"#FFFFFF" alpha:1];
    _minuteLine.layer.opacity = 0.1;
    [_minuteView addSubview:_minuteLine];
    // 4.3 文字
    _minuteText = [[UILabel alloc]init];
    _minuteText.text = @"MIN";
    _minuteText.textColor = [UIColor colorWithHexString:@"#FFFFFF" alpha:0.45];
    _minuteText.textAlignment = NSTextAlignmentCenter;
    _minuteText.font = [UIFont systemFontOfSize:9];
    [_minuteView addSubview:_minuteText];
    
    _minuteDivision = [[UILabel alloc]init];
    _minuteDivision.text = @":";
    _minuteDivision.textColor = [UIColor colorWithHexString:@"#141519" alpha:1];
    _minuteDivision.font = [UIFont boldSystemFontOfSize:16];
    _minuteDivision.textAlignment = NSTextAlignmentCenter;
    [_boardView addSubview:_minuteDivision];
    
    // 5.秒视图
    _secondView = [[UIView alloc]init];
    _secondView.backgroundColor = [UIColor colorWithHexString:@"#141519" alpha:1];
    [_boardView addSubview:_secondView];
    // 5.1 小时
    _secondLabel = [[UILabel alloc]init];
    _secondLabel.textColor = [UIColor colorWithHexString:@"#FFFFFF" alpha:1];
    _secondLabel.font = [UIFont boldSystemFontOfSize:15];
    _secondLabel.textAlignment = NSTextAlignmentCenter;
    [_secondView addSubview:_secondLabel];
    // 5.2 分割线
    _secondLine = [[UILabel alloc]init];
    _secondLine.backgroundColor = [UIColor colorWithHexString:@"#FFFFFF" alpha:1];
    _secondLine.layer.opacity = 0.1;
    [_secondView addSubview:_secondLine];
    // 5.3 文字
    _secondText = [[UILabel alloc]init];
    _secondText.text = @"SEC";
    _secondText.textColor = [UIColor colorWithHexString:@"#FFFFFF" alpha:0.45];
    _secondText.textAlignment = NSTextAlignmentCenter;
    _secondText.font = [UIFont systemFontOfSize:9];
    [_secondView addSubview:_secondText];
    
    _bottomCountDown = [[UILabel alloc]init];
    _bottomCountDown.textColor = [UIColor colorWithHexString:@"#FFFFFF" alpha:1];
    _bottomCountDown.backgroundColor = [UIColor colorWithHexString:@"#222222" alpha:0.8];
    _bottomCountDown.font = [UIFont systemFontOfSize:13];
    _bottomCountDown.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_bottomCountDown];
    
//    _bottomIMGView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"横屏大"]];
//    _bottomIMGView.contentMode = UIViewContentModeCenter;
//    [self addSubview:_bottomIMGView];
    
}

- (void)customConstraints {
    
    __weak typeof(self) weakSelf = self;
    [_boardView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(weakSelf);
    }];
    [_boardView layoutIfNeeded];
    
    [_tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.boardView).offset(73.5);
        make.centerX.mas_equalTo(weakSelf.boardView);
    }];
    
    // 1. :
    [_hourDivision mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.tipLabel.mas_bottom).offset(24);
        make.centerX.mas_equalTo(weakSelf.boardView);
    }];
    // 2. 时背景
    [_hourView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(weakSelf.hourDivision.mas_left).offset(-8);
        make.centerY.mas_equalTo(weakSelf.hourDivision.mas_centerY);
        make.width.mas_equalTo(38);
        make.height.mas_equalTo(39.5);
    }];
    [_hourView setCornerRadius:2 addRectCorners:UIRectCornerAllCorners];
    // 2.1 展示文字
    [_hourLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.hourView).offset(5);
        make.centerX.mas_equalTo(weakSelf.hourView);
    }];
    // 2.2 HOUR
    [_hourText mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(weakSelf.hourView).offset(-2.5);
        make.centerX.mas_equalTo(weakSelf.hourView);
    }];
    // 2.3 分割线
    [_hourLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(weakSelf.hourText.mas_top).offset(-1);
        make.left.mas_equalTo(weakSelf.hourView).offset(7);
        make.right.mas_equalTo(weakSelf.hourView).offset(-7);
        make.height.mas_equalTo(0.5);
    }];
    // 3. 分背景
    [_minuteView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.hourDivision.mas_right).offset(8);
        make.centerY.mas_equalTo(weakSelf.hourDivision.mas_centerY);
        make.width.mas_equalTo(38);
        make.height.mas_equalTo(39.5);
    }];
    [_minuteView setCornerRadius:2 addRectCorners:UIRectCornerAllCorners];
    // 3.1 展示文字
    [_minuteLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.minuteView).offset(5);
        make.centerX.mas_equalTo(weakSelf.minuteView);
    }];
    // 3.2 MIN
    [_minuteText mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(weakSelf.minuteView).offset(-2.5);
        make.centerX.mas_equalTo(weakSelf.minuteView);
    }];
    // 3.3 分割线
    [_minuteLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(weakSelf.minuteText.mas_top).offset(-1);
        make.left.mas_equalTo(weakSelf.minuteView).offset(7);
        make.right.mas_equalTo(weakSelf.minuteView).offset(-7);
        make.height.mas_equalTo(0.5);
    }];
    // 4. ：
    [_dayDivision mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(weakSelf.hourView.mas_left).offset(-8);
        make.centerY.mas_equalTo(weakSelf.hourView.mas_centerY);
    }];
    // 5. 天背景
    [_dayView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(weakSelf.dayDivision.mas_left).offset(-8);
        make.centerY.mas_equalTo(weakSelf.dayDivision.mas_centerY);
        make.width.mas_equalTo(38);
        make.height.mas_equalTo(39.5);
    }];
    [_dayView setCornerRadius:2 addRectCorners:UIRectCornerAllCorners];
    // 5.1 展示文字
    [_dayLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.dayView).offset(5);
        make.centerX.mas_equalTo(weakSelf.dayView);
    }];
    // 5.2 DAY
    [_dayText mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(weakSelf.dayView).offset(-2.5);
        make.centerX.mas_equalTo(weakSelf.dayView);
    }];
    // 5.3 分割线
    [_dayLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(weakSelf.dayText.mas_top).offset(-1);
        make.left.mas_equalTo(weakSelf.dayView).offset(7);
        make.right.mas_equalTo(weakSelf.dayView).offset(-7);
        make.height.mas_equalTo(0.5);
    }];
    // 6. :
    [_minuteDivision mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.minuteView.mas_right).offset(8);
        make.centerY.mas_equalTo(weakSelf.minuteView.mas_centerY);
    }];
    // 7. 秒背景
    [_secondView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.minuteDivision.mas_right).offset(8);
        make.centerY.mas_equalTo(weakSelf.minuteDivision.mas_centerY);
        make.width.mas_equalTo(38);
        make.height.mas_equalTo(39.5);
    }];
    [_secondView setCornerRadius:2 addRectCorners:UIRectCornerAllCorners];
    // 7.1 展示文字
    [_secondLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.secondView).offset(5);
        make.centerX.mas_equalTo(weakSelf.secondView);
    }];
    // 7.2 DAY
    [_secondText mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(weakSelf.secondView).offset(-2.5);
        make.centerX.mas_equalTo(weakSelf.secondView);
    }];
    // 7.3 分割线
    [_secondLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(weakSelf.secondText.mas_top).offset(-1);
        make.left.mas_equalTo(weakSelf.secondView).offset(7);
        make.right.mas_equalTo(weakSelf.secondView).offset(-7);
        make.height.mas_equalTo(0.5);
    }];
    
    [_bottomCountDown mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf).offset(12);
        make.bottom.mas_equalTo(weakSelf).offset(-12);
        make.width.mas_equalTo(207);
        make.height.mas_equalTo(30);
    }];
    [_bottomCountDown layoutIfNeeded];
    [_bottomCountDown setCornerRadius:15 addRectCorners:UIRectCornerAllCorners];
    
//    CGFloat bottomIMGH = SCREEN_WIDTH / 375 * 67;
//    [_bottomIMGView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.right.bottom.mas_equalTo(weakSelf);
//        make.height.mas_equalTo(bottomIMGH);
//    }];
}

- (void)updateCountDown:(NSTimeInterval)secondsCountDown {
    __weak __typeof(self) weakSelf = self;
    if (_timer == nil) {
        __block NSInteger timeout = secondsCountDown; // 倒计时时间
        if (timeout!=0) {
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
            dispatch_source_set_timer(_timer, dispatch_walltime(NULL, 0), 1.0*NSEC_PER_SEC,  0); //每秒执行
            dispatch_source_set_event_handler(_timer, ^{
                if(timeout <= 0){ //  当倒计时结束时做需要的操作: 关闭 活动到期不能提交
                    dispatch_source_cancel(weakSelf.timer);
                    weakSelf.timer = nil;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        weakSelf.dayLabel.text = @"00";
                        weakSelf.hourLabel.text = @"00";
                        weakSelf.minuteLabel.text = @"00";
                        weakSelf.secondLabel.text = @"00";
                        weakSelf.bottomCountDown.text = [NSString stringWithFormat:@" 距开播 00 天 00 时 00 分 00 秒"];
                    });
                } else { // 倒计时重新计算 时/分/秒
                    NSInteger days = (int)(timeout/(3600*24));
                    NSInteger hours = (int)((timeout-days*24*3600)/3600);
                    NSInteger minute = (int)(timeout-days*24*3600-hours*3600)/60;
                    NSInteger second = timeout - days*24*3600 - hours*3600 - minute*60;
                    NSString *strTime = [NSString stringWithFormat:@" 距开播 %02ld 天 %02ld 时 %02ld 分 %02ld 秒 ", days ,hours, minute, second];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        weakSelf.dayLabel.text = [NSString stringWithFormat:@"%02ld",days];
                        weakSelf.hourLabel.text = [NSString stringWithFormat:@"%02ld",hours];
                        weakSelf.minuteLabel.text = [NSString stringWithFormat:@"%02ld",minute];
                        weakSelf.secondLabel.text = [NSString stringWithFormat:@"%02ld",second];
                        weakSelf.bottomCountDown.text = strTime;
                        [weakSelf.bottomCountDown sizeToFit];
                    });
                    timeout--; // 递减 倒计时-1(总时间以秒来计算)
                }
            });
            dispatch_resume(_timer);
        }
    }
}



@end
