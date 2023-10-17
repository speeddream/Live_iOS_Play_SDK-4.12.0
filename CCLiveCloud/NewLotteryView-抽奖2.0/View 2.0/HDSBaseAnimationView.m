//
//  HDSBaseAnimationView.m
//  Example
//
//  Created by richard lee on 8/30/22.
//  Copyright © 2022 Jonathan Tribouharet. All rights reserved.
//

#import "HDSBaseAnimationView.h"
#import "HDSAnimationView.h"
#import "HDSBaseAnimationModel.h"
#import "HDSAnimationModel.h"
#import "HDSAnimationLotteryInfoView.h"
#import "HDSNoLotteryView.h"
#import "UIColor+RCColor.h"
#import "CCcommonDefine.h"

@interface HDSBaseAnimationView ()

@property (nonatomic, strong) UIImageView *lotteryIMG;
@property (nonatomic, strong) UIImageView *lotteryMachineIMG;
@property (nonatomic, strong) UIImageView *lotteryMachineRunLightIMG;
@property (nonatomic, strong) UIImageView *lotteryStatusIMG;
@property (nonatomic, strong) UIImageView *lotteryWindowIMG;
@property (nonatomic, strong) UIImageView *closeIMG;
@property (nonatomic, strong) UIButton    *closeBtn;
@property (nonatomic, strong) UIButton    *moreBtn;
@property (nonatomic, strong) UIButton    *moreBtn2;

@property (nonatomic, strong) HDSAnimationView            *aniView;
@property (nonatomic, strong) HDSAnimationLotteryInfoView *infoView;
@property (nonatomic, strong) HDSNoLotteryView            *noLotteryView;
@property (nonatomic, copy)   btnTapBlock                 btnTipBlock;
@property (nonatomic, strong) endAniBlock                 endAinBlock;

@end

@implementation HDSBaseAnimationView

//MARK: - API
- (instancetype)initWithFrame:(CGRect)frame closure:(nonnull btnTapBlock)closure endAniBlock:(nonnull endAniBlock)endAniClosure {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor colorWithHexString:@"#000000" alpha:0.4];
        if (closure) {
            _btnTipBlock = closure;
        }
        if (endAniClosure) {
            _endAinBlock = endAniClosure;
        }
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateFrame) name:@"newLotteryUpdateFrame" object:nil];
        [self configureBaseView];
    }
    return self;
}

- (void)setModel:(HDSBaseAnimationModel *)model {
    _model = model;
    if (_infoView) {
        _infoView.model = _model;
    }
}

- (void)setOriginDatas:(NSArray *)originDatas {
    _originDatas = originDatas;
    if (_aniView) {
        _aniView.models = originDatas;
    }
}

- (void)setLotteryUserDatas:(NSArray *)lotteryUserDatas {
    _lotteryUserDatas = lotteryUserDatas;
    if (_lotteryUserDatas.count == 0) {
        _aniView.models = lotteryUserDatas;
        return;
    }
    if (lotteryUserDatas.count > 5) {
        self.moreBtn.hidden = NO;
    }
    _aniView.models = lotteryUserDatas;
}

- (void)setLotteryUserCount:(NSInteger)lotteryUserCount {
    _lotteryUserCount = lotteryUserCount;
}

- (void)startAnimation {
    if (_aniView) {    
        [self.aniView startAnimation];
    }
}

- (void)stopAnimation {
    if (_aniView) {
        [_aniView stopAnimation];
    }
    self.lotteryStatusIMG.image = [UIImage imageNamed:@"开奖啦"];
}

- (void)updateFrame {
    if ([UIScreen mainScreen].bounds.size.width > [UIScreen mainScreen].bounds.size.height) {
        self.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
        self.hidden = YES;
    } else {
        self.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
        self.hidden = NO;
    }
}

//MARK: - CustomMethods
- (void)configureBaseView {
    // 背景彩带
    CGFloat lotteryIMGW = 375;
    CGFloat lotteryIMGX = [self getCustomViewLeftConstrint:lotteryIMGW];
    CGFloat lotteryIMGY = 100;
    CGFloat lotteryIMGH = 480;
    UIImageView *lotteryIMG = [self createImageView:@"漂浮彩带"];
    lotteryIMG.frame = CGRectMake(lotteryIMGX, lotteryIMGY, lotteryIMGW, lotteryIMGH);
    [self.layer addSublayer:lotteryIMG.layer];
    self.lotteryIMG = lotteryIMG;
    // 机器
    CGFloat machineIMGW = 342;
    CGFloat machineIMGX = [self getCustomViewLeftConstrint:machineIMGW];
    CGFloat machineIMGY = 25;
    CGFloat machineIMGH = 458;
    UIImageView *lotteryMachineIMG = [self createImageView:@"机器"];
    lotteryMachineIMG.frame = CGRectMake(machineIMGX, machineIMGY, machineIMGW, machineIMGH);
    [lotteryIMG.layer addSublayer:lotteryMachineIMG.layer];
    self.lotteryMachineIMG = lotteryMachineIMG;

    CGFloat superW = self.frame.size.width;
    if (superW > self.frame.size.height) {
        superW = self.frame.size.height;
    }
    
    // 关闭
    CGFloat closeIMGWH = 20;
    CGFloat closeIMGWX = superW - closeIMGWH - 20;
    CGFloat closeIMGWY = 25;
    UIImageView *closeIMG = [self createImageView:@"关闭"];
    closeIMG.frame = CGRectMake(closeIMGWX, closeIMGWY, closeIMGWH, closeIMGWH);
    [lotteryIMG.layer addSublayer:closeIMG.layer];
    self.closeIMG = closeIMG;
    // 关闭按钮
    CGFloat closeBtnWH = 40;
    CGFloat closeBtnX = superW - closeIMGWH - 20;
    CGFloat closeBtnY = lotteryIMGY + machineIMGY - 10;
    self.closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.closeBtn.frame = CGRectMake(closeBtnX, closeBtnY, closeBtnWH, closeBtnWH);
    [self addSubview:self.closeBtn];
    [self bringSubviewToFront:self.closeBtn];
    [self.closeBtn addTarget:self action:@selector(closeBtnTap:) forControlEvents:UIControlEventTouchUpInside];
    // 跑马灯
    CGFloat yellowLightIMGW = 330;
    CGFloat yellowLightIMGX = [self getCustomViewLeftConstrint:yellowLightIMGW];
    CGFloat yellowLightIMGY = 27 + machineIMGY;
    CGFloat yellowLightIMGH = 94;
    UIImage *yellowImage = [UIImage imageNamed:@"黄灯"];
    UIImage *whiteImage = [UIImage imageNamed:@"白灯"];
    UIImageView *lotteryMachineRunLightIMG = [self createAnimationImageView:@[yellowImage,whiteImage]];
    lotteryMachineRunLightIMG.frame = CGRectMake(yellowLightIMGX, yellowLightIMGY, yellowLightIMGW, yellowLightIMGH);
    [lotteryIMG.layer addSublayer:lotteryMachineRunLightIMG.layer];
    self.lotteryMachineRunLightIMG = lotteryMachineRunLightIMG;
    // 抽奖状态
    CGFloat lotteryStatusIMGW = 226;
    CGFloat lotteryStatusIMGX = [self getCustomViewLeftConstrint:lotteryStatusIMGW];
    CGFloat lotteryStatusIMGY = 44 + machineIMGY;
    CGFloat lotteryStatusIMGH = 60;
    UIImageView *lotteryStatusIMG = [self createImageView:@"抽奖中"];
    lotteryStatusIMG.frame = CGRectMake(lotteryStatusIMGX, lotteryStatusIMGY, lotteryStatusIMGW, lotteryStatusIMGH);
    [lotteryIMG.layer addSublayer:lotteryStatusIMG.layer];
    self.lotteryStatusIMG = lotteryStatusIMG;
    // 抽奖窗口
    CGFloat lotteryWindowIMGW = 296;
    CGFloat lotteryWindowIMGX = [self getCustomViewLeftConstrint:lotteryWindowIMGW];
    CGFloat lotteryWindowIMGY = 139 + machineIMGY;
    CGFloat lotteryWindowIMGH = 110;
    UIImageView *lotteryWindowIMG = [self createImageView:@"窗口"];
    lotteryWindowIMG.frame = CGRectMake(lotteryWindowIMGX, lotteryWindowIMGY, lotteryWindowIMGW, lotteryWindowIMGH);
    [lotteryIMG.layer addSublayer:lotteryWindowIMG.layer];
    self.lotteryWindowIMG = lotteryWindowIMG;
    // 抽奖视图
    CGFloat lotteryAniViewW = 270;
    CGFloat lotteryAniViewX = [self getCustomViewLeftConstrint:lotteryAniViewW];
    CGFloat lotteryAniViewY = 146 + machineIMGY;
    CGFloat lotteryAniViewH = 95;
    self.aniView = [[HDSAnimationView alloc]initWithFrame:CGRectMake(lotteryAniViewX, lotteryAniViewY, lotteryAniViewW, lotteryAniViewH)];
    [lotteryIMG.layer addSublayer:self.aniView.layer];
    self.aniView.layer.cornerRadius = 2;
    self.aniView.layer.masksToBounds = YES;
    __weak typeof(self) weakSelf = self;
    self.aniView.animationEndClosure = ^{
        if (weakSelf.lotteryUserCount == 0) {
            weakSelf.noLotteryView.hidden = NO;
        } else {
            weakSelf.noLotteryView.hidden = YES;
        }
        if (weakSelf.lotteryUserCount > 5) {
            weakSelf.moreBtn.hidden = NO;
        } else {
            weakSelf.moreBtn.hidden = YES;
        }
        if (weakSelf.endAinBlock) {
            weakSelf.endAinBlock();
        }
        weakSelf.moreBtn2.hidden = NO;
    };
    // 无人中奖视图
    self.noLotteryView = [[HDSNoLotteryView alloc]initWithFrame:CGRectMake(lotteryAniViewX, lotteryAniViewY, lotteryAniViewW, lotteryAniViewH)];
    [lotteryIMG.layer addSublayer:self.noLotteryView.layer];
    self.noLotteryView.layer.cornerRadius = 2;
    self.noLotteryView.layer.masksToBounds = YES;
    self.noLotteryView.hidden = YES;
    
    // 奖品信息
    CGFloat infoViewW = 260;
    CGFloat infoViewX = [self getCustomViewLeftConstrint:infoViewW];
    CGFloat infoViewY = 337;
    CGFloat infoViewH = 120;
    self.infoView = [[HDSAnimationLotteryInfoView alloc]initWithFrame:CGRectMake(infoViewX, infoViewY, infoViewW, infoViewH)];
    [lotteryIMG.layer addSublayer:self.infoView.layer];
    // 更多按钮
    CGFloat moreBtnW = 55;
    CGFloat moreBtnH = 95;
    CGFloat moreBtnX = superW - moreBtnW - 51;
    CGFloat moreBtnY = lotteryAniViewY + 100;
    self.moreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.moreBtn.backgroundColor = [UIColor colorWithHexString:@"#FFE2BD" alpha:1];
    self.moreBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [self.moreBtn setImage:[UIImage imageNamed:@"查看全部"] forState:UIControlStateNormal];
    [self.moreBtn setTitle:@"查看全部" forState:UIControlStateNormal];
    [self.moreBtn setTitleColor:[UIColor colorWithHexString:@"#CD6322" alpha:1] forState:UIControlStateNormal];
    self.moreBtn.hidden = YES;
    self.moreBtn.frame = CGRectMake(moreBtnX, moreBtnY, moreBtnW, moreBtnH);
    [self addSubview:self.moreBtn];
    [self bringSubviewToFront:self.moreBtn];
    [self.moreBtn addTarget:self action:@selector(moreBtnTap:) forControlEvents:UIControlEventTouchUpInside];
    CGSize buttonSize = self.moreBtn.frame.size;
    CGSize imageSize = self.moreBtn.imageView.frame.size;
    CGSize titleSize = self.moreBtn.titleLabel.frame.size;
    /// 图片的向上偏移titleLabel的高度（如果觉得图片和文字挨的太近，可以增加向上的值）【负值】，0，0，图片右边偏移偏移按钮的宽减去图片的宽然后除以2【正值】
    [self.moreBtn setImageEdgeInsets:UIEdgeInsetsMake(-(titleSize.height), 5, 0, (buttonSize.width - imageSize.width) / 2)];
    /// 文字的向上偏移图片的高度【正值】，向左偏移图片的宽带【负值】，0，0
    [self.moreBtn setTitleEdgeInsets:UIEdgeInsetsMake((imageSize.height)+5 ,-(imageSize.width), 0,0)];
    
    // 查看更多按钮
    CGFloat moreBtn2W = 238;
    CGFloat moreBtn2X = [self getCustomViewLeftConstrint:moreBtn2W];
    CGFloat moreBtn2Y = CGRectGetMaxY(self.lotteryIMG.frame) + 5;
    CGFloat moreBtn2H = 60;
    self.moreBtn2 = [self createMoreBtn2];
    self.moreBtn2.frame = CGRectMake(moreBtn2X, moreBtn2Y, moreBtn2W, moreBtn2H);
    self.moreBtn2.hidden = YES;
    [self addSubview:self.moreBtn2];
}

// 获取自定义居中视图X值
- (CGFloat)getCustomViewLeftConstrint:(CGFloat)customWidth {
    CGFloat superW = self.frame.size.width;
    if (superW > self.frame.size.height) {
        superW = self.frame.size.height;
    }
    CGFloat originX = (superW - customWidth) / 2;
    return originX;
}

// 创建IMGView
- (UIImageView *)createImageView:(NSString *)imageName {
    UIImageView *oneImgView = [[UIImageView alloc]init];
    oneImgView.image = [UIImage imageNamed:imageName];
    return oneImgView;
}

// 创建动画IMGView
- (UIImageView *)createAnimationImageView:(NSArray <UIImage *>*)images {
    UIImageView *oneImageView = [[UIImageView alloc]init];
    oneImageView.animationImages = images;
    oneImageView.animationRepeatCount = 0;
    oneImageView.animationDuration = 0.35;
    [oneImageView startAnimating];
    return oneImageView;
}

//
- (UIButton *)createMoreBtn2 {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.titleLabel.font = [UIFont systemFontOfSize:16];
    [btn setTitle:@"查看中奖结果" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor colorWithHexString:@"#D41F00" alpha:1] forState:UIControlStateNormal];
    [btn setBackgroundImage:[UIImage imageNamed:@"查看更多_bg"] forState:UIControlStateNormal];
    /// 文字的向上偏移图片的高度【正值】，向左偏移图片的宽带【负值】，0，0
    [btn setTitleEdgeInsets:UIEdgeInsetsMake( -10, 0, 0, 0)];
    [btn addTarget:self action:@selector(moreBtnTap:) forControlEvents:UIControlEventTouchUpInside];
    return btn;
}

//MARK: - Selected
- (void)closeBtnTap:(UIButton *)sender {
    
    if (_btnTipBlock) {
        _btnTipBlock(0);
    }
}

- (void)moreBtnTap:(UIButton *)sender {
    
    if (_btnTipBlock) {
        _btnTipBlock(1);
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"newLotteryUpdateFrame" object:nil];
}

@end
