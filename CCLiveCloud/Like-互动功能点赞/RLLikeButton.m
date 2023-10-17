//
//  RLLikeButton.m
//  ExampleDemo
//
//  Created by richard lee on 2/17/22.
//

#import "RLLikeButton.h"
#import "RLLikeConfiguration.h"

@interface RLLikeButton ()
// 配置项
@property (nonatomic, strong) RLLikeConfiguration   *likeConfig;
// 点击回调
@property (nonatomic, copy)   touchAction           touchAction;
// 定时器
@property (nonatomic, strong) NSTimer               *timer;

@property (nonatomic, assign) int                   touchCount;

@property (nonatomic, assign) BOOL                  showAnimationing;

@end

@implementation RLLikeButton

- (instancetype)initWithFrame:(CGRect)frame
                configuration:(RLLikeConfiguration *)configuration
                      closure:(touchAction)closure {
    
    self = [super initWithFrame:frame];
    if (self) {
        _likeConfig = configuration;
        if (closure) {
            _touchAction = closure;
        }
        _showAnimationing = NO;
        _touchCount = 1;
        [self setImage:_likeConfig.likeBtnImage forState:UIControlStateNormal];
        [self setImage:_likeConfig.likeBtnImage forState:UIControlStateHighlighted];
        
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTouchAction)];
        singleTap.numberOfTapsRequired = 1;
        [self addGestureRecognizer:singleTap];
    }
    return self;
}

- (BOOL)getIsAnimation {
    return _showAnimationing;
}

- (void)singleAnimation {
    [self createLikeItems];
}

- (void)startGroupAnimation {
    [self startTimer];
}

- (void)stopGroupAnimation {
    [self stopTimer];
}

//MARK: - Custom Method
// 开始定时器
- (void)startTimer {
    [self stopTimer];
    _showAnimationing = YES;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:_likeConfig.likeTimeInterval
                                         target:self
                                       selector:@selector(createLikeItems)
                                       userInfo:nil
                                        repeats:YES];
}

// 停止定时器
- (void)stopTimer {
    _showAnimationing = NO;
    if ([_timer isValid]) {
        [_timer invalidate];
        _timer = nil;
    }
}

- (void)singleTouchAction {
    if (self.touchAction) {
        self.touchAction(_touchCount);
    }
    [self createLikeItems];
}

- (void)longPressAction:(UILongPressGestureRecognizer *)ges {
    if (ges.state == UIGestureRecognizerStateBegan) {
        
        [self startTimer];
    }else if (ges.state == UIGestureRecognizerStateEnded) {
        
        [self stopTimer];
    }else if (ges.state == UIGestureRecognizerStateChanged) {
        
    }
}

// 创建点赞视图
- (void)createLikeItems {
    
    // 1.取出图片下标
    int index = (int)round([self randomFloatBetween:0 and:_likeConfig.likeImages.count - 1]);
    UIImage *oneImage;
    if (index < _likeConfig.likeImages.count) {
        oneImage = [_likeConfig.likeImages objectAtIndex:index];
    }
    // 2.设置图片属性
    CGFloat size = [self randomFloatBetween:18 and:24];
    UIImageView *likeImage = [[UIImageView alloc]init];
    likeImage.image = oneImage;
    likeImage.frame = CGRectMake(self.frame.origin.x + self.frame.size.width / 2, self.frame.origin.y - 5, size, size);
    [self.superview addSubview:likeImage];
    
    // 3.设置点赞轨迹
    UIBezierPath *zigzagPath = [[UIBezierPath alloc] init];
    CGFloat oX = likeImage.frame.origin.x;
    CGFloat oY = likeImage.frame.origin.y;
    CGFloat eX = oX;
    CGFloat eY = oY - [self randomFloatBetween:_likeConfig.showMinHeight and:_likeConfig.showMaxHeight];
    CGFloat t = [self randomFloatBetween:20 and:150];
    CGPoint cp1 = CGPointMake(oX - t, ((oY + eY) / 2));
    CGPoint cp2 = CGPointMake(oX + t, cp1.y);
    
    // 4.随机切换控制点，随意向右或向左摆动
    NSInteger r = arc4random() % 2;
    if (r == 1) {
        CGPoint temp = cp1;
        cp1 = cp2;
        cp2 = temp;
    }
    
    // 5.1 moveToPoint方法设置直线的起点
    [zigzagPath moveToPoint:CGPointMake(oX, oY)];
    // 5.2 添加终点和控制点
    [zigzagPath addCurveToPoint:CGPointMake(eX, eY) controlPoint1:cp1 controlPoint2:cp2];
    
    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
        [UIView transitionWithView:likeImage
                          duration:0.1f
                           options:UIViewAnimationOptionCurveLinear
                        animations:^{
            
        } completion:^(BOOL finished) {
            [likeImage removeFromSuperview];
        }];
    }];
    
    CAKeyframeAnimation *pathAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    pathAnimation.duration = self.likeConfig.likeDuration;
    pathAnimation.path = zigzagPath.CGPath;
    // 结合removedOnCompletion
    pathAnimation.fillMode = kCAFillModeForwards;
    pathAnimation.removedOnCompletion = NO;
    
    [likeImage.layer addAnimation:pathAnimation forKey:@"movingAnimation"];
    
    [UIView animateWithDuration:2 animations:^{
        likeImage.transform = CGAffineTransformMakeScale(1.3, 1.3);
        likeImage.alpha = 0;
    }];
    
    [CATransaction commit];
}

- (float)randomFloatBetween:(float)smallNumber and:(float)bigNumber {
    float diff = bigNumber - smallNumber;
    return (((float) (arc4random() % ((unsigned)RAND_MAX + 1)) / RAND_MAX) * diff) + smallNumber;
}

- (void)dealloc {
    
}

@end
