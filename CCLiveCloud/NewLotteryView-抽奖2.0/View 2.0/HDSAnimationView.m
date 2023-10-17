//
//  HDSAnimationView.m
//  Example
//
//  Created by richard lee on 8/23/22.
//  Copyright © 2022 Jonathan Tribouharet. All rights reserved.
//

#import "HDSAnimationView.h"
#import "HDSAnimationModel.h"
#import "UIColor+RCColor.h"
#import "UIImageView+Extension.h"

@interface HDSAnimationView ()

@property (assign, nonatomic) CFTimeInterval duration;
@property (assign, nonatomic) CFTimeInterval durationOffset;
@property (assign, nonatomic) NSUInteger density;
@property (assign, nonatomic) NSUInteger minLength;

@property (nonatomic, strong) NSMutableArray *originDatas;

@property (nonatomic, strong) NSMutableArray *scrollLayers;

@property (nonatomic, strong) NSMutableArray *scrollLabels;

@property (nonatomic, strong) NSMutableArray *scrollImages;

@property (nonatomic, strong) NSMutableArray *scrollCustomViews;

@property (nonatomic, strong) NSTimer *aniTimer;

@end

@implementation HDSAnimationView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)setModels:(NSArray<HDSAnimationModel *> *)models {
    self->_models = models;
    [self prepareAminations];
}

- (void)startAnimation {
    [self prepareAminations];
    [self createAnimations];
}


- (void)stopAnimation {
    [self createAnimations2];
}

- (void)killAll {
    for (CALayer *oneLayer in _scrollLayers) {
        [oneLayer removeFromSuperlayer];
    }
    [_originDatas removeAllObjects];
    [_scrollLayers removeAllObjects];
    [_scrollCustomViews removeAllObjects];
    [_scrollLabels removeAllObjects];
    [_scrollImages removeAllObjects];
}

// MARK: - Custom Method
- (void)commonInit {
    self.duration = 2;
    self.durationOffset = .2;
}

- (void)prepareAminations {
    
    for (CALayer *oneLayer in self.scrollLayers) {
        [oneLayer removeFromSuperlayer];
    }

    [self.originDatas removeAllObjects];
    [self.originDatas addObjectsFromArray:_models];
    
    [self.scrollLayers removeAllObjects];
    [self.scrollCustomViews removeAllObjects];
    [self.scrollLabels removeAllObjects];
    [self.scrollImages removeAllObjects];
    
    [self createScrollLayers];
}

- (void)createScrollLayers {
    CGFloat oneViewW = roundf(CGRectGetWidth(self.frame) / 5);
    CGFloat oneViewH = CGRectGetHeight(self.frame);
    for (int i = 0; i < self.originDatas.count; i++) {
        CAScrollLayer *layer = [CAScrollLayer layer];
        layer.frame = CGRectMake(roundf(i * oneViewW), 0, oneViewW, oneViewH);
        [self.scrollLayers addObject:layer];
        [self.layer addSublayer:layer];
        NSArray *baseArray = self.originDatas[i];
        [self createContentForLayer:layer baseDatas:baseArray];
    }
}

- (void)createContentForLayer:(CAScrollLayer *)scrollLayer baseDatas:(NSArray *)resultArray {
    CGFloat oneViewY = 0;
    for (int i = 0; i < resultArray.count; i++) {
        
        HDSAnimationModel *oneModel = resultArray[i];
        
        UIView *oneView = [[UIView alloc]initWithFrame:CGRectMake(0, oneViewY, CGRectGetWidth(scrollLayer.frame), CGRectGetHeight(scrollLayer.frame))];
        if ([oneModel.userIconUrl hasPrefix:@"img_"] || [oneModel.userIconUrl isEqualToString:@"查看全部"]) {
            UIImageView *oneIMG = [self createImage:oneModel.userIconUrl];
            oneIMG.frame = CGRectMake(4.5, 17.5, 45, 45);
            [oneView.layer addSublayer:oneIMG.layer];
            [self.scrollImages addObject:oneIMG];
        } else {
            UIImageView *oneIMG = [self createNetworkImage:oneModel.userIconUrl];
            oneIMG.frame = CGRectMake(4.5, 17.5, 45, 45);
            [oneView.layer addSublayer:oneIMG.layer];
            [self.scrollImages addObject:oneIMG];
        }
        
        UILabel *oneLabel = [self createLabel:oneModel.userName];
        oneLabel.frame = CGRectMake(4.5, 65, 45, 14);
        [oneView.layer addSublayer:oneLabel.layer];
        [self.scrollLabels addObject:oneLabel];
        
        [scrollLayer addSublayer:oneView.layer];
        [self.scrollCustomViews addObject:oneView];
        NSLog(@"== > frame:%@",NSStringFromCGRect(oneView.frame));
        
        oneViewY = CGRectGetMaxY(oneView.frame);
    }
}

- (void)createAnimations {
    NSLog(@"== >---> createAnimations");
    CFTimeInterval duration = self.duration - (5 * self.durationOffset);
    CFTimeInterval offset = 0;
    for (int i = 0; i < self.scrollLayers.count; i++) {
        CALayer *scrollLayer = self.scrollLayers[i];
        CGFloat maxY = [[scrollLayer.sublayers lastObject] frame].origin.y;
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"sublayerTransform.translation.y"];
        animation.duration = duration + offset;
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
        animation.repeatCount = 10000000000;
        animation.fromValue = @0;
        animation.toValue = [NSNumber numberWithFloat:-maxY];
        [scrollLayer addAnimation:animation forKey:@"HDSScrollAnimatedView"];
        offset += self.durationOffset;
    }
}

- (void)createAnimations2 {
    
    NSLog(@"== >---> createAnimations2");
    CFTimeInterval duration = self.duration - (5 * self.durationOffset);
    CFTimeInterval offset = 0;
    for (int i = 0; i < self.scrollLayers.count; i++) {
        CALayer *scrollLayer = self.scrollLayers[i];
        CGFloat maxY = [[scrollLayer.sublayers lastObject] frame].origin.y;
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"sublayerTransform.translation.y"];
        animation.duration = duration + offset;
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
        animation.repeatCount = 5;
        animation.fromValue = @0;
        animation.toValue = [NSNumber numberWithFloat:-maxY];
        [scrollLayer addAnimation:animation forKey:@"HDSScrollAnimatedView"];
        offset += self.durationOffset;
    }
    [self startTimerWithDuration:9];
}



-(void)pauseLayer:(CALayer*)layer {
   CFTimeInterval pausedTime = [layer convertTime:CACurrentMediaTime() fromLayer:nil];
   layer.speed = 0.0;
   layer.timeOffset = pausedTime;
}


- (void)startTimerWithDuration:(NSTimeInterval)duration {
    if ([_aniTimer isValid]) {
        [_aniTimer invalidate];
        _aniTimer = nil;
    }
    __weak typeof(self) weakSelf = self;
    _aniTimer = [NSTimer scheduledTimerWithTimeInterval:duration repeats:NO block:^(NSTimer * _Nonnull timer) {
        NSLog(@"== >---> 动画结束");
        if (weakSelf.animationEndClosure) {
            weakSelf.animationEndClosure();
        }
    }];
}

//MARK: - Tool
- (UIImageView *)createImage:(NSString *)oneImageName {
    UIImageView *oneIMGV = [[UIImageView alloc]init];
    oneIMGV.image = [UIImage imageNamed:oneImageName];
    oneIMGV.layer.cornerRadius = 22.5;
    oneIMGV.layer.masksToBounds = YES;
    oneIMGV.layer.borderColor = [UIColor colorWithHexString:@"#CD6322" alpha:1].CGColor;
    oneIMGV.layer.borderWidth = 0.5;
    return oneIMGV;
}

- (UIImageView *)createNetworkImage:(NSString *)oneImageName {
    UIImageView *oneIMGV = [[UIImageView alloc]init];
    [oneIMGV setHeader:oneImageName];
    oneIMGV.layer.cornerRadius = 22.5;
    oneIMGV.layer.masksToBounds = YES;
    oneIMGV.layer.borderColor = [UIColor colorWithHexString:@"#CD6322" alpha:1].CGColor;
    oneIMGV.layer.borderWidth = 0.5;
    return oneIMGV;
}

- (UILabel *)createLabel:(NSString *)inputText {
    UILabel *label = [[UILabel alloc]init];
    label.textColor = [UIColor colorWithHexString:@"#CD6322" alpha:1];
    label.font = [UIFont systemFontOfSize:12];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = inputText;
    return label;
}

//MARK: - LAZY
- (NSMutableArray *)originDatas {
    if (!_originDatas) {
        _originDatas = [NSMutableArray array];
    }
    return _originDatas;
}

- (NSMutableArray *)scrollLayers {
    if (!_scrollLayers) {
        _scrollLayers = [NSMutableArray array];
    }
    return _scrollLayers;
}

- (NSMutableArray *)scrollLabels {
    if (!_scrollLabels) {
        _scrollLabels = [NSMutableArray array];
    }
    return _scrollLabels;
}

- (NSMutableArray *)scrollImages {
    if (!_scrollImages) {
        _scrollImages = [NSMutableArray array];
    }
    return _scrollImages;
}

- (NSMutableArray *)scrollCustomViews {
    if (!_scrollCustomViews) {
        _scrollCustomViews = [NSMutableArray array];
    }
    return _scrollCustomViews;
}

- (void)dealloc {
    
}

@end
