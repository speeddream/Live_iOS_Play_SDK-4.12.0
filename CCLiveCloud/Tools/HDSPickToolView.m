//
//  HDSPickToolView.m
//  CCLiveCloud
//
//  Created by richard lee on 3/9/23.
//  Copyright © 2023 MacBook Pro. All rights reserved.
//

#import "HDSPickToolView.h"
#import "CCAlertView.h"
#import "UIView+GetVC.h"
#import <Photos/Photos.h>
#import "HDSPhotoActionSheetTool.h"
#import "UIColor+RCColor.h"
#import "CCcommonDefine.h"
#import "UIView+Extension.h"
#import <Masonry/Masonry.h>

@interface HDSPickToolView ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate>

@property (nonatomic, copy) kCallBack kCallBack;

@property (nonatomic, strong) UIView *boardView;
@property (nonatomic, strong) UIButton *boardBtn;

@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UIView *baseView;

@property (nonatomic, strong) UILabel *cameraLabel;
@property (nonatomic, strong) UIButton *cameraBtn;

@property (nonatomic, strong) UILabel *photoLibraryLabel;
@property (nonatomic, strong) UIButton *photoLibraryBtn;

@property (nonatomic, strong) UILabel *cancelLabel;
@property (nonatomic, strong) UIButton *cancelBtn;

@property (nonatomic, strong) UIView *bottomView;

@property (nonatomic, strong) CCAlertView *alertView;
@property (nonatomic, strong) NSMutableArray <UIImage *>*lastSelectedPhotosArray;
@property (nonatomic, strong) NSMutableArray <PHAsset *>*lastSelectedAssetsArray;
@property (nonatomic, assign) int photoMaxCount;
/// 图片是否允许重复
@property (nonatomic, assign) BOOL isAllowsDuplicates;

@end

@implementation HDSPickToolView

/// 初始化（允许选择同一张照片）
/// - Parameters:
///   - frame: 布局
///   - photoMaxCount: 最大图片个数
///   - closure: 回调
- (instancetype)initWithFrame:(CGRect)frame
                photoMaxCount:(int)photoMaxCount
                      closure:(kCallBack)closure {
    if (self = [super initWithFrame:frame]) {
        if (closure) {
            _kCallBack = closure;
        }
        self.photoMaxCount = photoMaxCount;
        self.isAllowsDuplicates = YES;
        [self configureUI];
        [self configureConstraints];
    }
    return self;
}

/// 初始化（不允许选择同一张照片）
/// - Parameters:
///   - frame: 布局
///   - lastSelectAssets: 已选中图片
///   - closure: 回调
- (instancetype)initWithFrame:(CGRect)frame
             lastSelectAssets:(NSMutableArray <PHAsset *>*)lastSelectAssets
                      closure:(kCallBack)closure {
    if (self = [super initWithFrame:frame]) {
        if (closure) {
            _kCallBack = closure;
        }
        self.isAllowsDuplicates = NO;
        [self configureUI];
        [self configureConstraints];
        if (lastSelectAssets.count > 0) {
            self.lastSelectedAssetsArray = lastSelectAssets.mutableCopy;
        }
    }
    return self;
}

- (void)showPickToolView {
    [self showToolView];
}

// MARK: - Custom Method
- (void)configureUI {
    _boardView = [[UIView alloc]init];
    [self addSubview:_boardView];
    
    _boardBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_boardView addSubview:_boardBtn];
    [_boardBtn addTarget:self action:@selector(boardBtnTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    _containerView = [[UIView alloc]init];
    [self addSubview:_containerView];
    
    _baseView = [[UIView alloc]init];
    _baseView.backgroundColor = [UIColor colorWithHexString:@"#F7F7F7" alpha:1];
    [_containerView addSubview:_baseView];
    
    _cameraLabel = [[UILabel alloc]init];
    _cameraLabel.text = @"拍摄";
    _cameraLabel.textAlignment = NSTextAlignmentCenter;
    _cameraLabel.userInteractionEnabled = YES;
    _cameraLabel.backgroundColor = [UIColor colorWithHexString:@"#FFFFFF" alpha:1];
    _cameraLabel.textColor = [UIColor colorWithHexString:@"#333333" alpha:1];
    _cameraLabel.font = [UIFont systemFontOfSize:14];
    [_containerView addSubview:_cameraLabel];
    
    _cameraBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_cameraLabel addSubview:_cameraBtn];
    [_cameraBtn addTarget:self action:@selector(cameraBtnTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    _photoLibraryLabel = [[UILabel alloc]init];
    _photoLibraryLabel.text = @"从相册选择";
    _photoLibraryLabel.userInteractionEnabled = YES;
    _photoLibraryLabel.textAlignment = NSTextAlignmentCenter;
    _photoLibraryLabel.backgroundColor = [UIColor colorWithHexString:@"#FFFFFF" alpha:1];
    _photoLibraryLabel.textColor = [UIColor colorWithHexString:@"#333333" alpha:1];
    _photoLibraryLabel.font = [UIFont systemFontOfSize:14];
    [_containerView addSubview:_photoLibraryLabel];
    
    _photoLibraryBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_photoLibraryLabel addSubview:_photoLibraryBtn];
    [_photoLibraryBtn addTarget:self action:@selector(photoLibraryBtnTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    _cancelLabel = [[UILabel alloc]init];
    _cancelLabel.text = @"取消";
    _cancelLabel.textAlignment = NSTextAlignmentCenter;
    _cancelLabel.userInteractionEnabled = YES;
    _cancelLabel.backgroundColor = [UIColor colorWithHexString:@"#FFFFFF" alpha:1];
    _cancelLabel.textColor = [UIColor colorWithHexString:@"#333333" alpha:1];
    _cancelLabel.font = [UIFont systemFontOfSize:14];
    [_containerView addSubview:_cancelLabel];
    
    _cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_cancelLabel addSubview:_cancelBtn];
    [_cancelBtn addTarget:self action:@selector(cancelBtnTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    _bottomView = [[UIView alloc]init];
    _bottomView.backgroundColor = [UIColor colorWithHexString:@"#FFFFFF" alpha:1];
    [_containerView addSubview:_bottomView];
}

- (void)configureConstraints {
    __weak typeof(self) weakSelf = self;
    [_boardView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(weakSelf);
    }];
    
    [_boardBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(weakSelf.boardView);
    }];
    
    [_containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf).offset(SCREEN_HEIGHT);
        make.left.right.mas_equalTo(weakSelf);
        make.height.mas_equalTo(141+TabbarSafeBottomMargin);
    }];
    
    [_baseView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.containerView).offset(20);
        make.left.bottom.right.mas_equalTo(weakSelf.containerView);
    }];
    
    [_cameraLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(weakSelf.containerView);
        make.height.mas_equalTo(45);
    }];
    
    [_cameraBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(weakSelf.cameraLabel);
    }];
    
    [_photoLibraryLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.cameraLabel.mas_bottom).offset(1);
        make.left.right.mas_equalTo(weakSelf.containerView);
        make.height.mas_equalTo(45);
    }];
    
    [_photoLibraryBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(weakSelf.photoLibraryLabel);
    }];
    
    [_cancelLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.photoLibraryLabel.mas_bottom).offset(8);
        make.left.right.mas_equalTo(weakSelf.containerView);
        make.height.mas_equalTo(45);
    }];
    
    [_cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(weakSelf.cancelLabel);
    }];
    
    [_bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.cancelLabel.mas_bottom);
        make.left.right.mas_equalTo(weakSelf.containerView);
        make.height.mas_equalTo(TabbarSafeBottomMargin);
    }];
    
    [_cancelLabel layoutIfNeeded];
    [_cameraLabel setCornerRadius:20 addRectCorners:UIRectCornerTopLeft | UIRectCornerTopRight];
}

- (void)configureData {
    
}

- (void)showToolView {
    __weak typeof(self) weakSelf = self;
    self.containerView.transform = CGAffineTransformIdentity;
    self.boardView.transform = CGAffineTransformIdentity;
    self.boardView.backgroundColor = [UIColor colorWithHexString:@"#000000" alpha:0];
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        weakSelf.containerView.transform = CGAffineTransformMakeTranslation(0, -(141+TabbarSafeBottomMargin));
        weakSelf.boardView.backgroundColor = [UIColor colorWithHexString:@"#000000" alpha:0.4];
    } completion:^(BOOL finished) {
    
    }];
}

- (void)hiddenToolView {
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        weakSelf.boardView.backgroundColor = [UIColor colorWithHexString:@"#000000" alpha:0];
        weakSelf.containerView.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        [weakSelf removeFromSuperview];
    }];
}

// MARK: - Button Tapped Action
- (void)boardBtnTapped:(UIButton *)sender {
    NSLog(@"%s",__func__);
    [self hiddenToolView];
}

- (void)cameraBtnTapped:(UIButton *)sender {
    NSLog(@"%s",__func__);
    [self checkCameraAutorize];
    [self hiddenToolView];
}

- (void)photoLibraryBtnTapped:(UIButton *)sender {
    NSLog(@"%s",__func__);
    [self hiddenToolView];
    [self checkPhotoLibraryAuthorize];
}

- (void)cancelBtnTapped:(UIButton *)sender {
    NSLog(@"%s",__func__);
    [self hiddenToolView];
}

// MARK: - Camera
/// 检查相机权限
- (void)checkCameraAutorize {
    
    AVAuthorizationStatus videoAuthStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    switch (videoAuthStatus) {
        case AVAuthorizationStatusNotDetermined: {
            // 第一次提示用户授权
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                if (granted == YES) {
                    
                    [self openCamera];
                } else {
                    
                    [self authorizationAlertViewTitle:@"无法获取相机权限，请前往设置打开"];
                }
            }];
        } break;
            
        case AVAuthorizationStatusAuthorized: {
            
            [self openCamera];
        } break;
            
        case AVAuthorizationStatusRestricted: {
            
            [self authorizationAlertViewTitle:@"无法获取相机权限，请前往设置打开"];
        } break;
            
        case AVAuthorizationStatusDenied: {
            
            [self authorizationAlertViewTitle:@"无法获取相机权限，请前往设置打开"];
        } break;
            
        default:
            break;
    }
}

- (void)openCamera {

    BOOL isRearCamera = [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear];
    BOOL isFrontCamera = [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront];
    if (!isRearCamera && !isFrontCamera) {
        
        return;
    }
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        UIViewController *vc = [self theTopviewControler];
        if (vc == nil) {
            return;
        }
        ZLCustomCamera *camera = [[ZLCustomCamera alloc] init];
        camera.allowRecordVideo = NO; // 不允许录制视频
        camera.doneBlock = ^(UIImage *image, NSURL *videoUrl) {
            [weakSelf saveImage:image videoUrl:videoUrl];
        };
        [vc presentViewController:camera animated:YES completion:^{
            // 发送通知调整segment
            [[NSNotificationCenter defaultCenter] postNotificationName:@"kBackQuestionSegment" object:nil];
        }];
    });
}

- (void)saveImage:(UIImage *)image videoUrl:(NSURL *)videoUrl {
    ZLProgressHUD *hud = [[ZLProgressHUD alloc] init];
    [hud show];
    @zl_weakify(self);
    if (image) {
        [ZLPhotoManager saveImageToAblum:image completion:^(BOOL suc, PHAsset *asset) {
            @zl_strongify(self);
            if (suc) {
                if (self.kCallBack) {
                    self.kCallBack(@[image], @[asset], YES);
                }
            } else {
                ZLLoggerDebug(@"图片保存失败");
            }
            [hud hide];
        }];
    }
}

// MARK: - Photo Library
/// 检查相册权限
- (void)checkPhotoLibraryAuthorize {
    PHAuthorizationStatus photoAuthStatus = [PHPhotoLibrary authorizationStatus];
    switch (photoAuthStatus) {
        case PHAuthorizationStatusNotDetermined: {
            //第一次提示用户授权
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                if (status == PHAuthorizationStatusAuthorized) {
                    
                    [self openPhotoLibrary];
                } else {
                    
                    [self authorizationAlertViewTitle:@"无法获取相册权限，请前往设置打开"];
                }
            }];
        } break;
            
        case PHAuthorizationStatusAuthorized: {
            
            [self openPhotoLibrary];
        } break;
            
        case PHAuthorizationStatusRestricted: {
            
            [self authorizationAlertViewTitle:@"无法获取相册权限，请前往设置打开"];
        } break;
            
        case PHAuthorizationStatusDenied: {
            
            [self authorizationAlertViewTitle:@"无法获取相册权限，请前往设置打开"];
        } break;
            
        default:
            break;
    }
}

- (void)openPhotoLibrary {
    
    int maxCount = 6;
    if (_isAllowsDuplicates) { // 是否允许重复
        maxCount = _photoMaxCount;
    } else {
        if (_lastSelectedPhotosArray.count > 0) {
            maxCount = maxCount - (int)self.lastSelectedPhotosArray.count;
        }
        maxCount = maxCount < 0 ? 0 : maxCount;
        maxCount = maxCount > 6 ? 6 : maxCount;
    }
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        HDSPhotoActionSheetTool *acTool = [HDSPhotoActionSheetTool shared];
        acTool.maxSelectCount = maxCount;
        acTool.allowsDuplicates = _isAllowsDuplicates;
        UIViewController *vc = [weakSelf theTopviewControler];
        if (vc == nil) {
            return;
        }
        acTool.lastSelectedAssetsArray = weakSelf.isAllowsDuplicates == NO ? weakSelf.lastSelectedAssetsArray : nil;
        /// 展示相册
        [acTool.ac showPhotoLibraryWithSender:vc];
        /// 选择图片回调
        acTool.ac.selectImageBlock = ^(NSArray<UIImage *> * _Nullable images, NSArray<PHAsset *> * _Nonnull assets, BOOL isOriginal) {
            // 发送通知调整segment
            [[NSNotificationCenter defaultCenter] postNotificationName:@"kBackQuestionSegment" object:nil];
            if (weakSelf.kCallBack) {
                weakSelf.kCallBack(images, assets, isOriginal);
            }
        };
        /// 取消按钮回调
        acTool.ac.cancleBlock = ^{
            // 发送通知调整segment
            [[NSNotificationCenter defaultCenter] postNotificationName:@"kBackQuestionSegment" object:nil];
        };
    });
}

// MARK: - 授权弹窗
- (void)authorizationAlertViewTitle:(NSString *)title {
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (weakSelf.alertView) {
            [weakSelf.alertView removeFromSuperview];
            weakSelf.alertView = nil;
        }
        weakSelf.alertView = [[CCAlertView alloc] initWithAlertTitle:title sureAction:@"设置" cancelAction:@"取消" sureBlock:^{
            [weakSelf getSystemSettingAuthorization];
        }];
        [APPDelegate.window addSubview:weakSelf.alertView];
    });
}

// MARK: - 获取系统授权设置
- (void)getSystemSettingAuthorization {
    //提示跳转相册授权设置
    dispatch_async(dispatch_get_main_queue(), ^{    
        NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        [[UIApplication sharedApplication] openURL:url];
    });
}

- (void)dealloc {
    NSLog(@"----> %s",__func__);
}

@end
