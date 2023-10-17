//
//  HDSMultiMediaCallBar.m
//  CCLiveCloud
//
//  Created by Richard Lee on 8/28/21.
//  Copyright © 2021 MacBook Pro. All rights reserved.
//

#import "HDSMultiMediaCallBar.h"
#import "HDSMultiMediaCallBarConfiguration.h"
#import "HDSMultiMediaCallBoardView.h"
#import "HDSCallBarMainButton.h"
#import "HDSCallBarTipView.h"
#import "HDSCallBarFunctionView.h"
#import "HDSCallBarFunctionModel.h"
#import "UIColor+RCColor.h"
#import "CCcommonDefine.h"
#import "UIView+Extension.h"

#define kSmallWidth 52.5

@interface HDSMultiMediaCallBar ()

@property (nonatomic, strong) HDSMultiMediaCallBarConfiguration *configuration;
/// 连麦类型
@property (nonatomic, assign) HDSMultiMediaCallBarType      callType;
/// 更新类型回调
@property (nonatomic, copy)   mediaCallClosure              callClosure;
/// 视图拖动中
@property (nonatomic, assign) BOOL                          isScroll;


@property (nonatomic, assign) BOOL                          isNeedUpdate;

/// 蒙板视图
@property (nonatomic, strong) HDSMultiMediaCallBoardView    *boardView;
/// 展开/收起
@property (nonatomic, assign) BOOL                          isOpen;
/// 最小Y值
@property (nonatomic, assign) CGFloat                       minY;
/// 延迟时长
@property (nonatomic, assign) CGFloat                       delayDuration;

/// 主按钮
@property (nonatomic, strong) HDSCallBarMainButton          *mainButton;
/// 未接通前提示视图
@property (nonatomic, strong) HDSCallBarTipView             *tipView;
/// 接通后功能视图
@property (nonatomic, strong) HDSCallBarFunctionView        *functionView;
/// 是否在邀请中
@property (nonatomic, assign) BOOL                          isInvitation;

@end

@implementation HDSMultiMediaCallBar

// MARK: - API
/// 初始化
/// @param frame 布局
/// @param configuration 配置项
/// @param closure 回调
- (instancetype)initWithFrame:(CGRect)frame
            callConfiguration:(nonnull HDSMultiMediaCallBarConfiguration *)configuration
                      closure:(nonnull mediaCallClosure)closure {
    if (self = [super initWithFrame:frame]) {
        _configuration = configuration;
        _callType = configuration.callType;
        _minY = configuration.minY;
        _delayDuration = configuration.delayDuration;
        if (_delayDuration < 1) {
            _delayDuration = 10;
        }
        _isOpen = YES;
        _isInvitation = NO;
        if (closure) {
            _callClosure = closure;
        }
        [self customUI];
        /// 拖拽手势
        UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognize:)];
        [self addGestureRecognizer:panGestureRecognizer];
        [self startPerformAction];
    }
    return self;
}

/// 更新连麦bar状态
/// @param configuration 配置项
- (void)updateMediaCallBarConfiguration:(HDSMultiMediaCallBarConfiguration *)configuration {
    //NSLog(@"🔴⚪️🟡 %s",__func__);
//    if (configuration.callType == _callType) return;
    // 取出当前状态下callBar宽度 更新宽度
    _isOpen = YES;
    // 非邀请状态
    _isInvitation = NO;
    if (configuration.callType == HDSMultiMediaCallBarTypeVideoInvitation ||
        configuration.callType == HDSMultiMediaCallBarTypeAudioInvitation) { /// 邀请上麦
        // 邀请中
        _isInvitation = YES;
        _functionView.hidden = YES;
        // 更新提示视图展示类型
        [_tipView updateCallBarTipViewWithType:configuration.callType];
        _tipView.hidden = NO;
        // 取消延时消息
        [self cancelPerformAction];
        
    }else if (configuration.callType == HDSMultiMediaCallBarTypeVideoCalled ||
              configuration.callType == HDSMultiMediaCallBarTypeAudioCalled) { /// 通话中
        
        _tipView.hidden = YES;
        HDSCallBarFunctionModel *model = [[HDSCallBarFunctionModel alloc]init];
        model.isAudioVideo = configuration.callType == HDSMultiMediaCallBarTypeAudioCalled ? NO : YES;
        model.isAudioEnable = configuration.isAudioEnable;
        model.isVideoEnable = configuration.isVideoEnable;
        model.isFrontCamera = configuration.isFrontCamera;
        // 更新功能视图展示类型
        [_functionView updateCallBarTypeWithModel:model];
        _functionView.hidden = NO;
        // 开始延时消息
//        if (SCREEN_WIDTH > SCREEN_HEIGHT) {
        if (SCREEN_WIDTH > SCREEN_HEIGHT && configuration.callType == HDSMultiMediaCallBarTypeVideoCalled) {
            [self cancelPerformAction];
        }else {
            [self startPerformAction];
        }
        
    }else { // 其他状态
        _functionView.hidden = YES;
        // 更新提示视图展示类型
        [_tipView updateCallBarTipViewWithType:configuration.callType];
        _tipView.hidden = NO;
        // 开始延时消息
        [self startPerformAction];
    }
    _callType = configuration.callType;
    CGFloat width = [self getCallBarWidthWithType:configuration.callType];
    //NSLog(@"🔴⚪️🟡 %s isopen:%ld width:%f  callType:%ld",__func__,(long)_isOpen,width,_callType);
    [UIView animateWithDuration:0.35 animations:^{
        [self setFrame:CGRectMake(SCREEN_WIDTH - width, self.y, width, self.height)];
//        //NSLog(@"🔴⚪️🟡 -setFrame updateMediaCallBarConfiguration : %@",NSStringFromCGRect(self.frame));
    }];
    // 根据状态切换主按钮类型
    [self switchMainBtnWithType:configuration.callType];
}

// MARK: - Custom Method
- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
//    //NSLog(@"🔴⚪️🟡 -setFrame setFrame: %@",NSStringFromCGRect(self.frame));
//    if (SCREEN_WIDTH > SCREEN_HEIGHT && (_callType == HDSMultiMediaCallBarTypeVideoCalled || _callType == HDSMultiMediaCallBarTypeAudioCalled)) {
    if (SCREEN_WIDTH > SCREEN_HEIGHT && _callType == HDSMultiMediaCallBarTypeVideoCalled) {
        _isNeedUpdate = YES;
        [_boardView setFrame:CGRectMake(0, 0, self.width, self.height)];
        UIRectCorner rectCorner = UIRectCornerTopLeft | UIRectCornerBottomLeft;
        CGFloat redius = 10;
        [_boardView setCornerRadius:redius addRectCorners:rectCorner];
        
        [_mainButton setFrame:CGRectMake(10, 10, 35, 35)];
        
        _functionView.hidden = NO;
        CGFloat funcY = CGRectGetMaxY(_mainButton.frame) + 12.5;
        [_functionView setFrame:CGRectMake(0, funcY, self.width, self.height - funcY)];
    }else {
    
        [_boardView setFrame:CGRectMake(0, 0, SCREEN_WIDTH, self.height)];
        UIRectCorner rectCorner = UIRectCornerTopLeft | UIRectCornerBottomLeft;
        CGFloat redius = self.bounds.size.height;
        [_boardView setCornerRadius:redius addRectCorners:rectCorner];
        [_mainButton setFrame:CGRectMake(5, 5, 35, 35)];

        _functionView.hidden = YES;
        _tipView.hidden = NO;
        CGFloat tipX = CGRectGetMaxX(_mainButton.frame);
        CGFloat tipW = _boardView.width - tipX;
        [_tipView setFrame:CGRectMake(tipX, 0, tipW, _boardView.height)];
        if (_callType == HDSMultiMediaCallBarTypeAudioCalled || _callType == HDSMultiMediaCallBarTypeVideoCalled) {
            if (!_isOpen) {
                _functionView.hidden = _isScroll ? YES : NO;
            }else {
                _functionView.hidden = NO;
            }
            _tipView.hidden = YES;
            CGFloat funcX = CGRectGetMaxX(_mainButton.frame);
            CGFloat funcY = 0;
            CGFloat funcW = _boardView.width - funcX;
            CGFloat funcH = _boardView.height;
            [_functionView setFrame:CGRectMake(funcX, funcY, funcW, funcH)];
        }
        if (_isNeedUpdate == YES) {
            _isNeedUpdate = NO;
            _tipView.hidden = YES;
            if (!_isOpen) {
                _functionView.hidden = _isScroll ? YES : NO;
            }else {
                _functionView.hidden = NO;
            }
            CGFloat funcX = CGRectGetMaxX(_mainButton.frame);
            CGFloat funcY = 0;
            CGFloat funcW = _boardView.width - funcX;
            CGFloat funcH = _boardView.height;
            [_functionView setFrame:CGRectMake(funcX, funcY, funcW, funcH)];
        }
    }
//    [self switchMainBtnWithType:_callType];
}

/// 自定义UI
- (void)customUI {
    //NSLog(@"🔴⚪️🟡 %s",__func__);
    /// 蒙板视图
    _boardView = [[HDSMultiMediaCallBoardView alloc]initWithFrame:CGRectMake(0, 0, self.width, self.height)];
    _boardView.backgroundColor = [UIColor colorWithHexString:@"#2E3037" alpha:1];
    _boardView.layer.opacity = 0.9f;
    UIRectCorner rectCorner = UIRectCornerTopLeft | UIRectCornerBottomLeft;
    CGFloat redius = self.bounds.size.height;
    [_boardView setCornerRadius:redius addRectCorners:rectCorner];
    [self addSubview:_boardView];
    
    /// 主按钮
    _mainButton = [[HDSCallBarMainButton alloc]initWithFrame:CGRectMake(5, 5, 35, 35)];
    [_mainButton addTarget:self action:@selector(mainTtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [_boardView addSubview:_mainButton];
    
    /// 提示视图
    CGFloat tipX = CGRectGetMaxX(_mainButton.frame);
    CGFloat tipW = _boardView.width - tipX;
    _tipView = [[HDSCallBarTipView alloc]initWithFrame:CGRectMake(tipX, 0, tipW, _boardView.height) type:_callType closure:^{
        //NSLog(@"🔴⚪️🟡 邀请挂断");
        HDSMultiMediaCallBarConfiguration *config = [[HDSMultiMediaCallBarConfiguration alloc]init];
        config.callType = _callType;
        config.actionType = HDSMultiMediaCallUserActionTypeHangup;
        [self callBackWithType:config];
    }];
    [_boardView addSubview:_tipView];
    
    // 功能视图
    CGFloat funcX = CGRectGetMaxX(_mainButton.frame);
    CGFloat funcY = 0;
    CGFloat funcW = _boardView.width - funcX;
    CGFloat funcH = _boardView.height;
    HDSCallBarFunctionModel *model = [[HDSCallBarFunctionModel alloc]init];
    model.isAudioVideo = _configuration.isAudioVideo;
    model.isAudioEnable = YES;
    model.isVideoEnable = YES;
    model.isFrontCamera = YES;
    _functionView = [[HDSCallBarFunctionView alloc]initWithFrame:CGRectMake(funcX, funcY, funcW, funcH) model:model closure:^(NSInteger tag, HDSCallBarFunctionModel * _Nonnull model) {
        if (tag == 4) {
            _isOpen = NO;
            [self cancelPerformAction];
            [self callBarOpen:_isOpen];
        }else {
            HDSMultiMediaCallBarConfiguration *config = [[HDSMultiMediaCallBarConfiguration alloc]init];
            config.callType = _callType;
            if (tag == 1) {
                config.actionType = HDSMultiMediaCallUserActionTypeMic;
                config.isAudioEnable = model.isAudioEnable;
            }else if (tag == 2) {
                config.actionType = HDSMultiMediaCallUserActionTypeCamera;
                config.isVideoEnable = model.isVideoEnable;
            }else {
                config.actionType = HDSMultiMediaCallUserActionTypeChangeCamera;
                config.isFrontCamera = model.isFrontCamera;
            }
            [self callBackWithType:config];
            [self startPerformAction];
        }
    }];
    [_boardView addSubview:_functionView];
    _functionView.hidden = YES;
}

/// 取消延时事件
- (void)cancelPerformAction {
    /// 取消上次
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(delayFunction) object:nil];
}

/// 开始延迟事件
- (void)startPerformAction {
    if (![self isNeedStartPerformAction]) return;
    if (_isInvitation) return;
    //NSLog(@"🔴⚪️🟡 %s",__func__);
    [self cancelPerformAction];
    [self performSelector:@selector(delayFunction) withObject:nil afterDelay:_delayDuration];
}

/// 延迟事件
- (void)delayFunction {
    if (_isScroll) return;
    //NSLog(@"🔴⚪️🟡 %s",__func__);
    _isOpen = NO;
    [self callBarOpen:_isOpen];
}

/// 按钮点击事件回掉
/// @param model 数据
- (void)callBackWithType:(HDSMultiMediaCallBarConfiguration *)model {
    if (_callClosure) {
        _callClosure(model);
    }
}

/// callBar 是否打开
/// @param isOpen 打开/收起
- (void)callBarOpen:(BOOL)isOpen {
    //NSLog(@"🔴⚪️🟡 %s",__func__);
    [UIView animateWithDuration:0.35 animations:^{
        if (isOpen) {
            CGFloat width = [self getCallBarWidthWithType:_callType];
            self.frame = CGRectMake(SCREEN_WIDTH - width, self.y, width, self.height);
        }else {
            self.frame = CGRectMake(SCREEN_WIDTH - kSmallWidth, self.y, kSmallWidth, self.height);
        }
    } completion:^(BOOL finished) {
        /// 切换主按钮类型
        [self switchMainBtnWithType:_callType];
        if (isOpen) {
            /// 通话中
            if (_callType == HDSMultiMediaCallBarTypeVideoCalled ||
                _callType == HDSMultiMediaCallBarTypeAudioCalled) {
                _tipView.hidden = YES;
                if (_functionView.hidden) {
                    _functionView.hidden = NO;
                }
            }else {
                _tipView.hidden = NO;
                if (!_functionView.hidden) {
                    _functionView.hidden = YES;
                }
            }
            if (!_isInvitation) {
                [self startPerformAction];
            }
        }else {
            if (!_tipView.hidden && !_isInvitation) {
                _tipView.hidden = YES;
            }
            if (!_functionView.hidden) {
                _functionView.hidden = YES;
            }
        }
    }];
}

// MARK: - MainButton
/// 主按钮点击事件
/// @param sender 按钮
- (void)mainTtnClick:(UIButton *)sender {
    if (_isScroll) return;
    //NSLog(@"🔴⚪️🟡 %s",__func__);
    if (!_isOpen) { // 收起时展开
        _isOpen = YES;
        [self callBarOpen:_isOpen];
    }else {
        // 展开状态下点击事件回调
        /**
         *  //todo 展开状态下点击事件回调
         *  1.申请     是否允许申请，网络状态
         *  2.取消申请
         *  3.挂断     提示确认要挂断
         */
        HDSMultiMediaCallBarConfiguration *config = [[HDSMultiMediaCallBarConfiguration alloc]init];
        config.callType = _callType;
        if (_callType == HDSMultiMediaCallBarTypeVideoApply ||
            _callType == HDSMultiMediaCallBarTypeAudioApply ||
            _callType == HDSMultiMediaCallBarTypeVideoInvitation ||
            _callType == HDSMultiMediaCallBarTypeAudioInvitation) {
            config.actionType = HDSMultiMediaCallUserActionTypeApply;
        }else {
            config.actionType = HDSMultiMediaCallUserActionTypeHangup;
        }
        [self callBackWithType:config];
        [self startPerformAction];
    }
}

/// 切换主按钮状态
/// @param type 按钮状态
- (void)switchMainBtnWithType:(HDSMultiMediaCallBarType)type {
    /// 申请状态
    if (type == HDSMultiMediaCallBarTypeVideoApply || type == HDSMultiMediaCallBarTypeAudioApply || type == HDSMultiMediaCallBarTypeVideoInvitation || type == HDSMultiMediaCallBarTypeAudioInvitation) {
        [_mainButton updateCallType:HDSCallBarMainButtonTypeApply];
//        //NSLog(@"🔴⚪️🟡 申请");
    }else {
        if (_isOpen) {
            [_mainButton updateCallType:HDSCallBarMainButtonTypeHangup];
//            //NSLog(@"🔴⚪️🟡 挂断 1");
        }else {
            if ((type == HDSMultiMediaCallBarTypeAudioCalled || type == HDSMultiMediaCallBarTypeVideoCalled) && !_isNeedUpdate) {
                [_mainButton updateCallType:HDSCallBarMainButtonTypeConnected];
//                //NSLog(@"🔴⚪️🟡 连麦中收起");
            }else {
                [_mainButton updateCallType:HDSCallBarMainButtonTypeHangup];
//                //NSLog(@"🔴⚪️🟡 挂断 2");
            }
        }
    }
}

/// 主按钮类型转换
/// @param callType callBar类型
- (HDSCallBarMainButtonType)getMainBtnType:(HDSMultiMediaCallBarType)callType {
    HDSCallBarMainButtonType type = HDSCallBarMainButtonTypeApply;
    switch (callType) {
        case HDSMultiMediaCallBarTypeVideoApply:
            type = HDSCallBarMainButtonTypeApply;
            break;
        case HDSMultiMediaCallBarTypeAudioApply:
            type = HDSCallBarMainButtonTypeApply;
            break;
        case HDSMultiMediaCallBarTypeVideoCalling:
            type = HDSCallBarMainButtonTypeHangup;
            break;
        case HDSMultiMediaCallBarTypeAudioCalling:
            type = HDSCallBarMainButtonTypeHangup;
            break;
        case HDSMultiMediaCallBarTypeVideoInvitation:
            type = HDSCallBarMainButtonTypeApply;
            break;
        case HDSMultiMediaCallBarTypeAudioInvitation:
            type = HDSCallBarMainButtonTypeApply;
            break;
        case HDSMultiMediaCallBarTypeVideoConnecting:
            type = HDSCallBarMainButtonTypeHangup;
            break;
        case HDSMultiMediaCallBarTypeAudioConnecting:
            type = HDSCallBarMainButtonTypeHangup;
            break;
        case HDSMultiMediaCallBarTypeVideoCalled:
            type = HDSCallBarMainButtonTypeHangup;
            break;
        case HDSMultiMediaCallBarTypeAudioCalled:
            type = HDSCallBarMainButtonTypeHangup;
            break;
        default:
            break;
    }
    return type;
}

// MARK: - call Bar 拖动手势
/// 拖动手势
/// @param panGesture 手势信息
- (void)panGestureRecognize:(UIPanGestureRecognizer *)panGesture {
    
    if ([self isNeedStartPerformAction] == NO) {
        _isScroll = NO;
        return;
    } //横屏连麦成功不支持拖动
    
    CGFloat width = [self getCallBarWidthWithType:_callType];
    if (!_isOpen) {
        width = kSmallWidth;
    }
    switch (panGesture.state) {
        case UIGestureRecognizerStateBegan: {
            //NSLog(@"🔴⚪️🟡 began");
            _isScroll = YES;
            if (_isOpen) {
                [self startPerformAction];
            }
        } break;
            
        case UIGestureRecognizerStateChanged: {
            
            CGPoint point = [panGesture locationInView:APPDelegate.window];
            /// 拖动Y值
            CGFloat y = point.y;
            if (SCREEN_HEIGHT > SCREEN_WIDTH) { /// 竖屏
                y = point.y < _minY ? _minY : point.y;
            }
            y = y > SCREEN_HEIGHT - self.height - TabbarSafeBottomMargin ? SCREEN_HEIGHT - self.height  - TabbarSafeBottomMargin : y;
            [self setFrame:CGRectMake(SCREEN_WIDTH - width, y, width, self.height)];
//            //NSLog(@"🔴⚪️🟡 -setFrame Pan setFrame: %@",NSStringFromCGRect(self.frame));
            
        } break;
            
        case UIGestureRecognizerStateEnded: {
            //NSLog(@"🔴⚪️🟡 Ended");
            _isScroll = NO;
        } break;
            
        default:
            break;
    }
}

/// 获取 callBar 对应宽度
/// @param type 类型
- (CGFloat)getCallBarWidthWithType:(HDSMultiMediaCallBarType)type {
    CGFloat width = 144;
    switch (type) {
        case HDSMultiMediaCallBarTypeVideoInvitation:
            width = 170;
            break;
        case HDSMultiMediaCallBarTypeAudioInvitation:
            width = 170;
            break;
        case HDSMultiMediaCallBarTypeVideoCalled: {
            width = 197.5;
            if (_isNeedUpdate) {
                width = 55;
            }
        }
            break;
        case HDSMultiMediaCallBarTypeAudioCalled: {
            width = 112.5;
            if (_isNeedUpdate) {
                width = 55;
            }
        }
            break;
        case HDSMultiMediaCallBarTypeUnknow:
            width = 0;
            break;
        default:
            break;
    }
    return width;
}

- (BOOL)isNeedStartPerformAction {
//    if ((_callType == HDSMultiMediaCallBarTypeAudioCalled || _callType == HDSMultiMediaCallBarTypeVideoCalled) && SCREEN_WIDTH > SCREEN_HEIGHT) {
    if (_callType == HDSMultiMediaCallBarTypeVideoCalled && SCREEN_WIDTH > SCREEN_HEIGHT) {
        return NO;
    }else {
        return YES;
    }
}

@end
