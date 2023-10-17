//
//  HDSCallBarFunctionView.m
//  CCLiveCloud
//
//  Created by Richard Lee on 8/28/21.
//  Copyright © 2021 MacBook Pro. All rights reserved.
//

#import "HDSCallBarFunctionView.h"
#import "HDSCallBarFunctionModel.h"
#import "CCcommonDefine.h"

#define kBtnWH 35
#define kBtnY 5
#define kMargin 7.5

@interface HDSCallBarFunctionView ()

@property (nonatomic, strong) HDSCallBarFunctionModel   *model;

@property (nonatomic, copy) functionViewBtnClickClosure btnClickClosure;

@property (nonatomic, assign) BOOL      isAudioVideo;

@property (nonatomic, strong) UIButton  *micBtn;

@property (nonatomic, strong) UIButton  *pickUpBtn;

@property (nonatomic, strong) UIButton  *cameraBtn;

@property (nonatomic, strong) UIButton  *changeCameraBtn;

@end


@implementation HDSCallBarFunctionView

// MARK: - API
/// 初始化
/// @param frame 布局
/// @param model 配置项
/// @param closure 回调
- (instancetype)initWithFrame:(CGRect)frame model:(HDSCallBarFunctionModel *)model closure:(functionViewBtnClickClosure)closure {
    if (self = [super initWithFrame:frame]) {
        _model = model;
        _isAudioVideo = model.isAudioVideo;
        if (closure) {
            _btnClickClosure = closure;
        }
        [self customUI];
    }
    return self;
}

/// 更新连麦类型
/// @param model 配置项
- (void)updateCallBarTypeWithModel:(HDSCallBarFunctionModel *)model {
    _model = model;
    NSString *micName = _model.isAudioEnable == YES ? @"callBar_microphone_enable" : @"callBar_microphone_disable";
    [_micBtn setImage:[UIImage imageNamed:micName] forState:UIControlStateNormal];
    if (_isAudioVideo == model.isAudioVideo) {
        if (_isAudioVideo) {
            /// 摄像头
            NSString *cameraName = _model.isVideoEnable == YES ? @"callBar_camera_enable" : @"callBar_camera_disable";
            [_cameraBtn setImage:[UIImage imageNamed:cameraName] forState:UIControlStateNormal];
            
            /// 切换摄像头
            NSString *changeName = _model.isFrontCamera == YES ? @"callBar_called_change_camera" : @"callBar_called_change_camera";
            [_changeCameraBtn setImage:[UIImage imageNamed:changeName] forState:UIControlStateNormal];
        }
    }else {
        [self customUI];
        _isAudioVideo = model.isAudioVideo;
    }
}

// MAKR: - Custom Method

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    if (SCREEN_WIDTH > SCREEN_HEIGHT && _model.isAudioVideo) {
        [_micBtn setFrame:CGRectMake(10, 0, kBtnWH, kBtnWH)];
        if (_model.isAudioVideo) {
            CGFloat cameraY = CGRectGetMaxY(_micBtn.frame) + 12.5;
            [_cameraBtn setFrame:CGRectMake(10, cameraY, kBtnWH, kBtnWH)];
            CGFloat changeY = CGRectGetMaxY(_cameraBtn.frame) + 12.5;
            [_changeCameraBtn setFrame:CGRectMake(10, changeY, kBtnWH, kBtnWH)];
        }
        [_pickUpBtn setFrame:CGRectMake(0, 0, 0, 0)];
        _pickUpBtn.hidden = YES;
    }else {
        [_micBtn setFrame:CGRectMake(kMargin, kBtnY, kBtnWH, kBtnWH)];
        /// 收起按钮
        CGFloat pickX = CGRectGetMaxX(_micBtn.frame) + kMargin;
        CGFloat pickW = 20;
        if (_model.isAudioVideo) {
            CGFloat cameraX = CGRectGetMaxX(_micBtn.frame) + kMargin;
            [_cameraBtn setFrame:CGRectMake(cameraX, kBtnY, kBtnWH, kBtnWH)];
            CGFloat changeX = CGRectGetMaxX(_cameraBtn.frame) + kMargin;
            [_changeCameraBtn setFrame:CGRectMake(changeX, kBtnY, kBtnWH, kBtnWH)];
            pickX = CGRectGetMaxX(_changeCameraBtn.frame) + kMargin;
        }
        _pickUpBtn.hidden = NO;
        [_pickUpBtn setFrame: CGRectMake(pickX, kBtnY, pickW, kBtnWH)];
    }
}

- (void)customUI {
    /// 麦克风
    NSString *micName = _model.isAudioEnable == YES ? @"callBar_microphone_enable" : @"callBar_microphone_disable";
    if (_micBtn) {
        [_micBtn removeFromSuperview];
        _micBtn = nil;
    }
    _micBtn = [[UIButton alloc]initWithFrame:CGRectMake(kMargin, kBtnY, kBtnWH, kBtnWH)];
    _micBtn.tag = 1;
    [_micBtn setImage:[UIImage imageNamed:micName] forState:UIControlStateNormal];
    [self addSubview:_micBtn];
    [_micBtn addTarget:self action:@selector(btnsClick:) forControlEvents:UIControlEventTouchUpInside];
    
    /// 收起按钮
    CGFloat pickX = CGRectGetMaxX(_micBtn.frame) + kMargin;
    CGFloat pickW = 20;
    if (_model.isAudioVideo) {
        /// 摄像头
        NSString *cameraName = _model.isVideoEnable == YES ? @"callBar_camera_enable" : @"callBar_camera_disable";
        CGFloat cameraX = CGRectGetMaxX(_micBtn.frame) + kMargin;
        if (_cameraBtn) {
            [_cameraBtn removeFromSuperview];
            _cameraBtn = nil;
        }
        _cameraBtn = [[UIButton alloc]initWithFrame:CGRectMake(cameraX, kBtnY, kBtnWH, kBtnWH)];
        _cameraBtn.tag = 2;
        [_cameraBtn setImage:[UIImage imageNamed:cameraName] forState:UIControlStateNormal];
        [self addSubview:_cameraBtn];
        [_cameraBtn addTarget:self action:@selector(btnsClick:) forControlEvents:UIControlEventTouchUpInside];
        
        /// 切换摄像头
        NSString *changeName = _model.isFrontCamera == YES ? @"callBar_called_change_camera" : @"callBar_called_change_camera";
        CGFloat changeX = CGRectGetMaxX(_cameraBtn.frame) + kMargin;
        if (_changeCameraBtn) {
            [_changeCameraBtn removeFromSuperview];
            _changeCameraBtn = nil;
        }
        _changeCameraBtn = [[UIButton alloc]initWithFrame:CGRectMake(changeX, kBtnY, kBtnWH, kBtnWH)];
        _changeCameraBtn.tag = 3;
        [_changeCameraBtn setImage:[UIImage imageNamed:changeName] forState:UIControlStateNormal];
        [self addSubview:_changeCameraBtn];
        [_changeCameraBtn addTarget:self action:@selector(btnsClick:) forControlEvents:UIControlEventTouchUpInside];
        
        pickX = CGRectGetMaxX(_changeCameraBtn.frame) + kMargin;
    }else {    
        if (_cameraBtn) {
            [_cameraBtn removeFromSuperview];
            _cameraBtn = nil;
        }
        if (_changeCameraBtn) {
            [_changeCameraBtn removeFromSuperview];
            _changeCameraBtn = nil;
        }
    }
    if (_pickUpBtn) {
        [_pickUpBtn removeFromSuperview];
        _pickUpBtn = nil;
    }
    _pickUpBtn = [[UIButton alloc]initWithFrame:CGRectMake(pickX, kBtnY, pickW, kBtnWH)];
    _pickUpBtn.tag = 4;
    [_pickUpBtn setImage:[UIImage imageNamed:@"callBar_called_right"] forState:UIControlStateNormal];
    [self addSubview:_pickUpBtn];
    [_pickUpBtn addTarget:self action:@selector(btnsClick:) forControlEvents:UIControlEventTouchUpInside];
    
}

- (void)btnsClick:(UIButton *)sender {
    //NSLog(@"🔴⚪️🟡 %s  senderTag:%ld",__func__,(long)sender.tag);
    if (sender.tag == 1) {
        _model.isAudioEnable = !_model.isAudioEnable;
    }else if (sender.tag == 2) {
        _model.isVideoEnable = !_model.isVideoEnable;
    }else if (sender.tag == 3) {
        if (_model.isVideoEnable) {
            _model.isFrontCamera = !_model.isFrontCamera;
        }
    }
    [self updateCallBarTypeWithModel:_model];
    if (_btnClickClosure) {
        _btnClickClosure(sender.tag,_model);
    }
}

@end
