//
//  HDSPhotoActionSheetTool.m
//  CCLiveCloud
//
//  Created by richard lee on 3/14/23.
//  Copyright © 2023 MacBook Pro. All rights reserved.
//

#import "HDSPhotoActionSheetTool.h"
#import "UIColor+RCColor.h"

static HDSPhotoActionSheetTool *_shared = nil;

@implementation HDSPhotoActionSheetTool

+ (instancetype)shared {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shared = [[HDSPhotoActionSheetTool alloc]init];
        _shared.ac = [[ZLPhotoActionSheet alloc]init];
        _shared.ac.configuration.allowSelectGif = NO;   // 不允许选择Gif
        _shared.ac.configuration.allowRecordVideo = NO; // 不允许录制视频
        _shared.ac.configuration.useSystemCamera = YES; // 使用系统相机
        _shared.ac.configuration.allowEditImage = NO;   // 不允许编辑照片
        _shared.ac.configuration.allowSelectVideo = NO; // 不允许选择照片
        _shared.ac.configuration.maxSelectCount = 6;    // 最大选择个数
        _shared.ac.configuration.editAfterSelectThumbnailImage = NO;  //是否在选择图片后直接进入编辑界面
        _shared.ac.configuration.showCaptureImageOnTakePhotoBtn = NO; //相册中不允许展示实时照片
        _shared.ac.configuration.allowTakePhotoInLibrary = NO; //相册中不允许拍照
        _shared.ac.configuration.navBarColor = [UIColor colorWithHexString:@"373B3E" alpha:1];
        _shared.ac.arrSelectedAssets = nil;
    });
    return _shared;
}

- (void)setMaxSelectCount:(int)maxSelectCount {
    _maxSelectCount = maxSelectCount;
    if (_maxSelectCount == 0) return;
    _shared.ac.configuration.maxSelectCount = _maxSelectCount;
}

- (void)setAllowSelectGif:(BOOL)allowSelectGif {
    _allowSelectGif = allowSelectGif;
    _shared.ac.configuration.allowSelectGif = _allowSelectGif;
}

- (void)setAllowRecordVideo:(BOOL)allowRecordVideo {
    _allowRecordVideo = allowRecordVideo;
    _shared.ac.configuration.allowRecordVideo = _allowRecordVideo;
}

- (void)setUseSystemCamera:(BOOL)useSystemCamera {
    _useSystemCamera = useSystemCamera;
    _shared.ac.configuration.useSystemCamera = _useSystemCamera;
}

- (void)setAllowEditImage:(BOOL)allowEditImage {
    _allowEditImage = allowEditImage;
    _shared.ac.configuration.allowEditImage = _allowEditImage;
}

- (void)setAllowSelectVideo:(BOOL)allowSelectVideo {
    _allowSelectVideo = allowSelectVideo;
    _shared.ac.configuration.allowSelectVideo = _allowSelectVideo;
}

- (void)setEditAfterSelectThumbnailImage:(BOOL)editAfterSelectThumbnailImage {
    _editAfterSelectThumbnailImage = editAfterSelectThumbnailImage;
    _shared.ac.configuration.editAfterSelectThumbnailImage = _editAfterSelectThumbnailImage;
}

- (void)setShowCaptureImageOnTakePhotoBtn:(BOOL)showCaptureImageOnTakePhotoBtn {
    _showCaptureImageOnTakePhotoBtn = showCaptureImageOnTakePhotoBtn;
    _shared.ac.configuration.showCaptureImageOnTakePhotoBtn = _showCaptureImageOnTakePhotoBtn;
}

- (void)setAllowTakePhotoInLibrary:(BOOL)allowTakePhotoInLibrary {
    _allowTakePhotoInLibrary = allowTakePhotoInLibrary;
    _shared.ac.configuration.allowTakePhotoInLibrary = _allowTakePhotoInLibrary;
}

- (void)setAllowsDuplicates:(BOOL)allowsDuplicates {
    _allowsDuplicates = allowsDuplicates;
}

- (void)setLastSelectedAssetsArray:(NSMutableArray<PHAsset *> *)lastSelectedAssetsArray {
    _lastSelectedAssetsArray = lastSelectedAssetsArray;
    if (_allowsDuplicates == NO) {
        _shared.ac.arrSelectedAssets = _lastSelectedAssetsArray;
    }
}

@end
