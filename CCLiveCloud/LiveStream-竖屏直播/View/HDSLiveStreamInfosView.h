//
//  HDSLiveStreamInfosView.h
//  CCLiveCloud
//
//  Created by Apple on 2022/12/15.
//  Copyright © 2022 MacBook Pro. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, HDSLiveStreamInfosViewType) {
    HDSLiveStreamInfosViewType_Normal,                      // 默认全部包含
    HDSLiveStreamInfosViewType_NoHeaderIcon,                // 无头像
    HDSLiveStreamInfosViewType_NoHeaderIcon_NoUserCount,    // 无头像&无在线人数
    HDSLiveStreamInfosViewType_NoUserCount,                 // 无在线人数
};

typedef void (^customBtnTapBlock)(void);

@interface HDSLiveStreamInfosView : UIView

@property (nonatomic, assign) HDSLiveStreamInfosViewType type;

- (instancetype)initWithFrame:(CGRect)frame btnTapClosure:(customBtnTapBlock)closure;

- (void)setHeaderIconWithUrl:(NSString *)url;

- (void)setMainTitleWithName:(NSString *)name;

- (void)setUserCountWithCount:(NSString *)count;

@end

NS_ASSUME_NONNULL_END
