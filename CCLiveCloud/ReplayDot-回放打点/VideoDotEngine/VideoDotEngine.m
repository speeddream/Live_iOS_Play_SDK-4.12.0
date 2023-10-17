//
//  VideoDotEngine.m
//  swiftIJK
//
//  Created by david on 2021/3/1.
//

#import "VideoDotEngine.h"
#import "VideoDotInfo.h"
#import "VideoDotInfoView.h"

CGFloat const InfoViewMaxWidth = 187.0;
CGFloat const DotRadius = 10.0;

@interface VideoDotEngine()

@property (nonatomic, strong) NSArray   *infoAry;
@property (nonatomic, strong) UIImage   *seekBTNImg;
@property (nonatomic, weak)   UIView    *boardView;
@property (nonatomic, assign) CGFloat   startX;
@property (nonatomic, assign) CGFloat   endX;
@property (nonatomic, assign) CGFloat   axisY;
@property (nonatomic, assign) int       totalTime;
@property (nonatomic, strong) UIView    *showingView;
@property (nonatomic, assign) CGFloat   totalWidth;
@property (nonatomic, copy)SeekClosure seekClosure;
@property (nonatomic, copy)IsShowClosure isShowClosure;
@property (nonatomic, strong) NSTimer   *timer;
@property (nonatomic, strong) NSMutableSet *dotSet;
@end

@implementation VideoDotEngine

- (instancetype)initWithDots:(NSArray *)info seekBTNImg:(UIImage *)img boardView:(UIView *)board startX:(CGFloat)startX endX:(CGFloat)endX axisY:(CGFloat)axixY totalTime:(int)totalTime seekClosure:(SeekClosure)seekClosure isShowClosure:(IsShowClosure)isShowClosure {
    self = [super init];
    if (self) {
        self.infoAry = info;
        self.seekBTNImg = img;
        self.boardView = board;
        self.startX = startX;
        self.endX = endX;
        self.axisY = axixY;
        self.totalTime = totalTime;
        _totalWidth = _endX - _startX;
        _seekClosure = seekClosure;
        _isShowClosure = isShowClosure;
        _dotSet = [[NSMutableSet alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [self killTimer];
    [self clearShowingView];
}

- (void)configureDots {
    [self appendDotButtons];
}

- (void)hideAll:(BOOL)hidden {
    if (hidden == YES) {
        [self killTimer];
        [self clearShowingView];
    }
    for (UIButton *dot in _dotSet) {
        dot.hidden = hidden;
    }
}

- (void)appendDotButtons {
    if (_dotSet.count > 0) return;
    for (VideoDotInfo *info in self.infoAry) {
        [_boardView addSubview:[self prepareTagButton:info]];
    }
}

- (UIButton *)prepareTagButton:(VideoDotInfo *)info {
    UIImage *image = [UIImage imageNamed:@"replay_dot"];
    CGFloat x = [self getDotCenterXInBoard:info.time];
    CGFloat y = _axisY;
    UIButton *dot = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, DotRadius * 2, DotRadius * 2)];
    dot.tag = info.time;
    [dot addTarget:self action:@selector(dotTapped:) forControlEvents:UIControlEventTouchUpInside];
    dot.layer.cornerRadius = 10;
    dot.center = CGPointMake(x, y);
    dot.backgroundColor = [UIColor clearColor];
    dot.tintColor = [UIColor whiteColor];
    [dot setImage:image forState:UIControlStateNormal];
    [dot setImage:image forState:UIControlStateHighlighted];
    [dot setImageEdgeInsets:UIEdgeInsetsMake(3, 3, 3, 3)];
    [_dotSet addObject:dot];
    return dot;
}

- (CGFloat)getDotCenterXInBoard:(int)time {
    NSString *a = [NSString stringWithFormat:@"%f", _startX];
    NSString *b = [NSString stringWithFormat:@"%d", time];
    NSString *c = [NSString stringWithFormat:@"%d", _totalTime];
    NSString *d = [NSString stringWithFormat:@"%f", _totalWidth];
    return (CGFloat)([a floatValue] + [b floatValue] / [c floatValue] * [d floatValue]);
}

- (void)dotTapped:(UIButton *)sender {
    [self showDotLabel:sender];
    [self resetTimer];
}

- (void)showDotLabel:(UIButton *)dotButton {
    [self clearShowingView];
    VideoDotInfo *info = [self getInfoByTime:(int)dotButton.tag];
    NSString *text = info.desc;
    CGFloat w = [self getLabelWidth:text];
    w += 65;
    CGFloat h = [self getLabelHeight:text];
    if (h < 50) {
        h = 50;
    }
    
    CGSize infoSize = CGSizeZero;
    if (w < InfoViewMaxWidth) {
        infoSize = CGSizeMake(w, 50);
    } else {
        infoSize = CGSizeMake(187, h);
    }

    CGFloat tivCenterX = dotButton.center.x;
    CGFloat tivleadingX = tivCenterX - infoSize.width / 2;
    if (tivleadingX <= _startX) {
        tivCenterX += _startX - tivleadingX - DotRadius;
    }
    
    CGFloat tivTraillingX = tivCenterX + infoSize.width / 2;
    if (tivTraillingX >= _endX) {
        tivCenterX += _endX - tivTraillingX + DotRadius;
    }
    
    CGFloat tivCenterY = dotButton.center.y - h / 2 - DotRadius;
    __weak __typeof(self) weakSelf = self;
    VideoDotInfoView *tiv = [[VideoDotInfoView alloc] initWithFrame:CGRectMake(0, 0, infoSize.width, infoSize.height + 10) arrowPointOffset:dotButton.center.x - tivCenterX text:text playBTNImage:_seekBTNImg playTapClosure:^(void) {
        NSLog(@"info view play tapped.");
        weakSelf.seekClosure((int)dotButton.tag);
        [weakSelf clearShowingView];
        [weakSelf killTimer];
    }];
    tiv.center = CGPointMake(tivCenterX, tivCenterY);
    [_boardView addSubview:tiv];
    _showingView = tiv;
    if (self.isShowClosure) {
        self.isShowClosure(YES);
    }
}

- (VideoDotInfo *)getInfoByTime:(int)time {
    NSPredicate *pd = [NSPredicate predicateWithFormat:@"time == %i", time];
    return [_infoAry filteredArrayUsingPredicate:pd][0];
}

- (void)clearShowingView {
    [_showingView removeFromSuperview];
    _showingView = nil;
    if (self.isShowClosure) {
        self.isShowClosure(NO);
    }
}

- (void)resetTimer {
    [self killTimer];
    __weak __typeof(self) weakSelf = self;
    _timer = [NSTimer scheduledTimerWithTimeInterval:5 repeats:NO block:^(NSTimer * _Nonnull timer) {
        [weakSelf clearShowingView];
        [weakSelf.timer invalidate];
    }];
}

- (void)killTimer {
    [_timer invalidate];
    self.timer = nil;
}

- (CGFloat)getLabelWidth:(NSString *)str {
    CGRect rect = [str boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, 10) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:12]} context:nil];
    return rect.size.width + (CGFloat)30;
}

- (CGFloat)getLabelHeight:(NSString *)str {
    CGRect rect = [str boundingRectWithSize:CGSizeMake(187 - 35 - 10, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:12]} context:nil];
    return rect.size.height + (CGFloat)10;
}


@end
