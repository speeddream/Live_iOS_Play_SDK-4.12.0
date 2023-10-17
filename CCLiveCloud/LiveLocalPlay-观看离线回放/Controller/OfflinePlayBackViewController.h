//
//  OfflinePlayBackViewController.h
//  CCOffline
//
//  Created by 何龙 on 2019/5/14.
//  Copyright © 2019 MacBook Pro. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface OfflinePlayBackViewController : UIViewController
/** 文件名 */
@property (nonatomic, copy)NSString *fileName;

/// 4.12.0 new 屏幕开关 YES 开启防录屏 NO 关闭防录屏
@property (nonatomic, assign) BOOL screenCaptureSwitch;

-(instancetype)initWithDestination:(NSString *)destination;
/*
 修改备注:1.聊天数据没有myViewerId这个字段
 2.图标元素缺失
 */
@end

NS_ASSUME_NONNULL_END
