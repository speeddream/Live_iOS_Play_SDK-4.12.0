//
//  HDSMultiLandscapeToolBar.m
//  CCLiveCloud
//
//  Created by Richard Lee on 8/31/21.
//  Copyright © 2021 MacBook Pro. All rights reserved.
//

#import "HDSMultiLandscapeToolBar.h"
#import "HDSMultiBoardViewActionModel.h"
#import "UIColor+RCColor.h"
#import <Masonry/Masonry.h>

@interface HDSMultiLandscapeToolBar ()

@property (nonatomic, assign) BOOL      isAudioVideo;

@property (nonatomic, strong) UIButton  *hangupBtn;

@property (nonatomic, strong) UIButton  *micBtn;

@property (nonatomic, strong) UIButton  *cameraBtn;

@property (nonatomic, strong) UIButton  *changCameraBtn;

@property (nonatomic, copy) landscapeToolBarBtnClickClosure btnClickClosure;

@property (nonatomic, strong) HDSMultiBoardViewActionModel   *model;

@end

@implementation HDSMultiLandscapeToolBar

- (instancetype)initWithFrame:(CGRect)frame isAudioVideo:(BOOL)isAudioVideo model:(HDSMultiBoardViewActionModel *)model closure:(landscapeToolBarBtnClickClosure)closure {
    if (self = [super initWithFrame:frame]) {
        _isAudioVideo = isAudioVideo;
        _model = model;
        self.backgroundColor = [UIColor colorWithHexString:@"#2E3037" alpha:1];
        self.layer.opacity = 0.9;
        if (closure) {
            _btnClickClosure = closure;
        }
        [self customUI];
    }
    return self;
}

- (void)updateToolBarBtnStatus:(BOOL)isAudioVideo model:(HDSMultiBoardViewActionModel *)model {
    _isAudioVideo = isAudioVideo;
    _model = model;
    [self micBtnImageWithEnable:_model.isAudioEnable];
    [self cameraBtnImageWithEnable:_model.isVideoEnable];
    [self changeCameraBtnImageWithEnable:_model.isFrontCamera];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    UIRectCorner rectCorner = UIRectCornerTopLeft | UIRectCornerBottomLeft;
    [self setCornerRadius:10 addRectCorners:rectCorner];
}

- (void)customUI {
    
    _hangupBtn = [[UIButton alloc]init];
    _hangupBtn.tag = 1;
    [_hangupBtn setImage:[UIImage imageNamed:@"callBar_hangup"] forState:UIControlStateNormal];
    [_hangupBtn addTarget:self action:@selector(btnsClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_hangupBtn];
    [_hangupBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self).mas_equalTo(10);
        make.centerX.mas_equalTo(self);
        make.width.height.mas_equalTo(35);
    }];
    
    _micBtn = [[UIButton alloc]init];
    _micBtn.tag = 2;
    [self micBtnImageWithEnable:_model.isAudioEnable];
    [_micBtn addTarget:self action:@selector(btnsClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_micBtn];
    [_micBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_hangupBtn.mas_bottom).mas_equalTo(12.5);
        make.centerX.mas_equalTo(self);
        make.width.height.mas_equalTo(35);
    }];
    
    CGFloat btnWH = 0;
    CGFloat topMarign = 0;
    if (_isAudioVideo) {
        btnWH = 35;
        topMarign = 12.5;
    }
    
    _cameraBtn = [[UIButton alloc]init];
    _cameraBtn.tag = 3;
    [self cameraBtnImageWithEnable:_model.isVideoEnable];
    [_cameraBtn addTarget:self action:@selector(btnsClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_cameraBtn];
    [_cameraBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_micBtn.mas_bottom).mas_equalTo(topMarign);
        make.centerX.mas_equalTo(self);
        make.width.height.mas_equalTo(btnWH);
    }];
    
    _changCameraBtn = [[UIButton alloc]init];
    _changCameraBtn.tag = 4;
    [self changeCameraBtnImageWithEnable:_model.isFrontCamera];
    [_changCameraBtn addTarget:self action:@selector(btnsClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_changCameraBtn];
    [_changCameraBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_cameraBtn.mas_bottom).mas_equalTo(topMarign);
        make.centerX.mas_equalTo(self);
        make.width.height.mas_equalTo(btnWH);
    }];
}

/// 按钮点击事件
/// @param sender 按钮
- (void)btnsClick:(UIButton *)sender {
    
    HDSMultiBoardViewActionModel *kModel = [[HDSMultiBoardViewActionModel alloc]init];
    if (sender.tag == 1) {
        _model.isHangup = YES;
        kModel.isHangup = _model.isHangup;
    }
    if (sender.tag == 2) {
        kModel.isAudioEnable = !_model.isAudioEnable;
        [self micBtnImageWithEnable:kModel.isAudioEnable];
        _model.isAudioEnable = kModel.isAudioEnable;
    }
    if (sender.tag == 3) {
        kModel.isVideoEnable = !_model.isVideoEnable;
        [self cameraBtnImageWithEnable:kModel.isVideoEnable];
        _model.isVideoEnable = kModel.isVideoEnable;
    }
    if (sender.tag == 4) {
        kModel.isFrontCamera = !_model.isFrontCamera;
        [self changeCameraBtnImageWithEnable:kModel.isFrontCamera];
        _model.isFrontCamera = kModel.isFrontCamera;
    }
    if (_btnClickClosure) {
        _btnClickClosure(kModel);
    }
}

- (void)micBtnImageWithEnable:(BOOL)isEnable {
    NSString *micName = isEnable == YES ? @"callBar_microphone_enable" : @"callBar_microphone_disable";
    [_micBtn setImage:[UIImage imageNamed:micName] forState:UIControlStateNormal];
}

- (void)cameraBtnImageWithEnable:(BOOL)isEnable {
    NSString *cameraName = isEnable == YES ? @"callBar_camera_enable" : @"callBar_camera_disable";
    [_cameraBtn setImage:[UIImage imageNamed:cameraName] forState:UIControlStateNormal];
}

- (void)changeCameraBtnImageWithEnable:(BOOL)isEnable {
    NSString *changeName = isEnable == YES ? @"callBar_called_change_camera" : @"callBar_called_change_camera";
    [_changCameraBtn setImage:[UIImage imageNamed:changeName] forState:UIControlStateNormal];
}

/// 给view设置圆角
/// @param value 圆角大小
/// @param rectCorner 圆角位置
- (void)setCornerRadius:(CGFloat)value addRectCorners:(UIRectCorner)rectCorner {
    [self layoutIfNeeded];//这句代码很重要，不能忘了
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:rectCorner cornerRadii:CGSizeMake(value, value)];
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.frame = self.bounds;
    shapeLayer.path = path.CGPath;
    self.layer.mask = shapeLayer;
}




@end
