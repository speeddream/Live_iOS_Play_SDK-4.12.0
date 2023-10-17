//
//  DotInfoView.m
//  swiftIJK
//
//  Created by david on 2021/3/1.
//

#import "VideoDotInfoView.h"
#import "UIColor+RCColor.h"

CGFloat const playButtonWidth = 28.0;
CGFloat const padding = 2.0;
CGFloat const arrowGap = 2.0;
CGFloat const arrowHeight = 10.0;
CGFloat const arrowUpSideLength = 12.0;
int const labelFontSize = 12;

@interface VideoDotInfoView()

@property(nonatomic, assign) CGFloat           arrowPointOffset;  //: arrow down point offset by view centerX
@property(nonatomic, copy) NSString            *text;
@property(nonatomic, strong) UIImage           *playBTNImg;
@property(nonatomic, copy) PlayTapClosure      playTapClosure;

@end

@implementation VideoDotInfoView

- (instancetype)initWithFrame:(CGRect)frame
             arrowPointOffset:(CGFloat)arrowPointOffSet
                         text:(NSString *)text
                 playBTNImage:(UIImage *)playBTNImg
               playTapClosure:(PlayTapClosure)closure {
    self = [super initWithFrame:frame];
    if (self) {
        _arrowPointOffset = arrowPointOffSet;
        _text = text;
        _playBTNImg = playBTNImg;
        _playTapClosure = closure;
        self.backgroundColor = UIColor.clearColor;
    }
    return  self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
//    NSLog(@"%f", _arrowPointOffset);
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(padding, padding, rect.size.width - padding * 2, rect.size.height - arrowHeight - arrowGap) cornerRadius:5];
    [[UIColor colorWithHexString:@"#666666" alpha:0.5] setStroke];
    [path stroke];
    [[UIColor colorWithHexString:@"#2C2D2E" alpha:0.9] setFill];
    [path fill];

    CGFloat arrowPointX = rect.size.width / 2 + _arrowPointOffset;
    [path moveToPoint:CGPointMake(arrowPointX, rect.size.height - arrowGap)];
    [path addLineToPoint:CGPointMake(arrowPointX - arrowUpSideLength / 2, rect.size.height - arrowHeight)];
    [path addLineToPoint:CGPointMake(arrowPointX + arrowUpSideLength / 2, rect.size.height - arrowHeight)];
    [path addLineToPoint:CGPointMake(arrowPointX, rect.size.height - arrowGap)];
    [[UIColor colorWithHexString:@"#2C2D2E" alpha:0.9] setFill];
    [path fill];
    
    [self configureView];
}

- (void)configureView {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(padding * 4, padding * 2, self.frame.size.width - 32 - padding * 8, self.frame.size.height - padding * 4 - arrowHeight)];
    label.text = _text;
    label.numberOfLines = 0;
    label.textColor = [UIColor whiteColor];
    label.lineBreakMode = NSLineBreakByCharWrapping;
    label.font = [UIFont systemFontOfSize:labelFontSize];
    [self addSubview:label];

    UIButton *playButton = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width - 32 - 5, 0, playButtonWidth, playButtonWidth)];
    playButton.center = CGPointMake(playButton.center.x, (self.frame.size.height - arrowHeight) / 2);
    [playButton setImage:_playBTNImg forState:UIControlStateNormal];
    playButton.layer.cornerRadius = playButtonWidth / 2;
    [playButton addTarget:self action:@selector(playTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:playButton];

}

- (void)playTapped:(UIButton *)sender {
    self.playTapClosure();
}

@end
