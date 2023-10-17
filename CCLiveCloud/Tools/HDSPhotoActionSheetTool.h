//
//  HDSPhotoActionSheetTool.h
//  CCLiveCloud
//
//  Created by richard lee on 3/14/23.
//  Copyright © 2023 MacBook Pro. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZLPhotoBrowser.h"

NS_ASSUME_NONNULL_BEGIN

@interface HDSPhotoActionSheetTool : NSObject

/// 最大选择个数    默认6
@property (nonatomic, assign) int maxSelectCount;
/// 是否允许选择Gif 默认NO
@property (nonatomic, assign) BOOL allowSelectGif;
/// 是否允许录制视频 默认NO
@property (nonatomic, assign) BOOL allowRecordVideo;
/// 是否使用系统相机 默认YES
@property (nonatomic, assign) BOOL useSystemCamera;
/// 是否允许编辑照片 默认NO
@property (nonatomic, assign) BOOL allowEditImage;
/// 是否允许选择视频 默认NO
@property (nonatomic, assign) BOOL allowSelectVideo;
/// 是否在选择图片后直接进入编辑界面 默认NO
@property (nonatomic, assign) BOOL editAfterSelectThumbnailImage;
/// 相册中是否允许展示实时照片 默认NO
@property (nonatomic, assign) BOOL showCaptureImageOnTakePhotoBtn;
/// 相册中是否允许允许拍照 默认NO
@property (nonatomic, assign) BOOL allowTakePhotoInLibrary;
/// 是否允许选择重复
@property (nonatomic, assign) BOOL allowsDuplicates;
/// 历史选中照片
@property (nonatomic, strong) NSMutableArray <PHAsset *>*lastSelectedAssetsArray;
/// Photo Action Sheet
@property (nonatomic, strong) ZLPhotoActionSheet *ac;

+ (instancetype)shared;

@end

NS_ASSUME_NONNULL_END
