//
//  HDSStreamBoardView.m
//  CCLiveCloud
//
//  Created by richard lee on 4/27/22.
//  Copyright © 2022 MacBook Pro. All rights reserved.
//

#import "HDSStreamBoardView.h"
#import "HDSLiveStreamControlView.h"
#import "UIColor+RCColor.h"
#import <Masonry/Masonry.h>

@interface HDSStreamBoardView ()

@property (nonatomic, copy)  closeBtnClosure closeClosure;

@end

@implementation HDSStreamBoardView

// MARK: - API
- (instancetype)initWithFrame:(CGRect)frame closeBtnAction:(nonnull closeBtnClosure)closure {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithHexString:@"#1F1F2A" alpha:1];
        if (closure) {
            _closeClosure = closure;
        }
        [self configureUI];
        [self configureConstraints];
    }
    return self;
}

- (void)setViewerId:(NSString *)viewerId {
    _viewerId = viewerId;
    if (_ctrlView) {
        _ctrlView.viewerId = _viewerId;
    }
}

- (void)setLiveStoreSwitch:(NSInteger)liveStoreSwitch {
    if (_ctrlView) {
        _ctrlView.liveStoreSwitch = liveStoreSwitch;
    }
}

/// 房间信息
/// - Parameter dict: 房间信息
- (void)roomInfo:(NSDictionary *)dic {    
    if (_ctrlView) {
        [_ctrlView roomInfo:dic];
    }
}

/// 设置房间icon
/// - Parameter url: 头像地址
- (void)setHomeIconWithUrl:(NSString *)url {
    if (_ctrlView) {
        [_ctrlView setHomeIconWithUrl:url];
    }
}

/// 房间历史公告
/// - Parameter announcement: 公告信息
- (void)setHomeHistoryAnnouncement:(NSString *)announcement {
    if (_ctrlView) {
        [_ctrlView setHomeHistoryAnnouncement:announcement];
    }
}

/// 接收到新的公告信息
/// - Parameter dict: 公告信息
- (void)receiveNewAnnouncement:(NSDictionary *)dict {
    if (_ctrlView) {
        [_ctrlView receiveNewAnnouncement:dict];
    }
}

/// 设置房间人数
/// - Parameter count: 人数
- (void)setRoomOnlineUserCountWithCount:(NSString *)count {
    if (_ctrlView) {
        [_ctrlView setRoomOnlineUserCountWithCount:count];
    }
}

/// 设置用户进入房间提醒
/// - Parameter model: 用户数据
- (void)setUserRemindWithModel:(RemindModel *)model {
    if (_ctrlView) {
        [_ctrlView setUserRemindWithModel:model];
    }
}

/// 收到单条聊天消息
/// - Parameter chatMsgs: 聊天消息
- (void)receivedNewChatMsgs:(NSArray *)chatMsgs {
    if (_ctrlView) {
        [_ctrlView receivedNewChatMsgs:chatMsgs];
    }
}

/// 删除单个广播
/// - Parameter dict: 广播信息
- (void)deleteSingleBoardcast:(NSDictionary *)dict {
    if (_ctrlView) {
        [_ctrlView deleteSingleBoardcast:dict];
    }
}

/// 聊天管理
/// @param    manageDic
/// status    聊天消息的状态 0 显示 1 不显示
/// chatIds   聊天消息的id列列表
- (void)chatLogManage:(NSDictionary *)manageDic {
    if (_ctrlView) {
        [_ctrlView chatLogManage:manageDic];
    }
}

/// 删除单个聊天
/// - Parameter dict: 聊天数据
- (void)deleteSingleChat:(NSDictionary *)dict {
    if (_ctrlView) {
        [_ctrlView deleteSingleChat:dict];
    }
}

/// 更新房间直播状态
/// - Parameter state: 是否已开播
- (void)roomLiveStatus:(BOOL)state {
    self.ctrlView.streamView.hidden = !state;
    if (_ctrlView) {
        [_ctrlView roomLiveStatus:state];
    }
}

/// 当前房间直播状态
/// - Parameter state: 0.正在直播 1.未开始直播
- (void)currentRoomLiveStatus:(NSInteger)state {
    self.ctrlView.streamView.hidden = state == 0 ? NO : YES;
    if (_ctrlView) {
        [_ctrlView currentRoomLiveStatus:state];
    }
}

/// 房间线路
- (void)HDReceivedVideoAudioLines:(NSDictionary *)dict {
    if (_ctrlView) {
        [_ctrlView HDReceivedVideoAudioLines:dict];
    }
}

/// 房间清晰度
- (void)HDReceivedVideoQuality:(NSDictionary *)dict {
    if (_ctrlView) {
        [_ctrlView HDReceivedVideoQuality:dict];
    }
}

// MARK: - 聊天置顶
/// 房间历史置顶聊天记录
/// @param model 置顶聊天model
- (void)onHistoryTopChatRecords:(HDSHistoryTopChatModel *)model {
    if (_ctrlView) {
        [_ctrlView onHistoryTopChatRecords:model];
    }
}

/// 收到聊天置顶新消息
/// @param model 聊天置顶model
- (void)receivedNewTopChat:(HDSLiveTopChatModel *)model {
    if (_ctrlView) {
        [_ctrlView receivedNewTopChat:model];
    }
}

/// 收到批量删除聊天置顶消息
/// @param model 聊天置顶model
- (void)receivedDeleteTopChat:(HDSDeleteTopChatModel *)model {
    if (_ctrlView) {
        [_ctrlView receivedDeleteTopChat:model];
    }
}

- (void)setScreenCaptureSwitch:(BOOL)screenCaptureSwitch {
    _screenCaptureSwitch = screenCaptureSwitch;
    _ctrlView.screenCaptureSwitch = _screenCaptureSwitch;
}

// MARK: - Custom Method
- (void)configureUI {
    
    __weak typeof(self) weakSelf = self;
    // 流视图
//    _streamView = [[UIView alloc]init];
//    _streamView.backgroundColor = [UIColor colorWithHexString:@"#1F1F2A" alpha:1];
//    _streamView.hidden = YES;
//    [self addSubview:_streamView];
    // 控制视图
    _ctrlView = [[HDSLiveStreamControlView alloc]initWithFrame:CGRectZero closeBtnAction:^{
        if (weakSelf.closeClosure) {
            weakSelf.closeClosure();
        }
    }];
    [self addSubview:_ctrlView];
    // 聊天回调
    _ctrlView.sendChatMessage = ^(NSString * _Nonnull msg) {
        if (weakSelf.sendChatMessage) {
            weakSelf.sendChatMessage(msg);
        }
    };
    // 静音回调
    _ctrlView.muteStreamVoice = ^(BOOL result) {
        if (weakSelf.muteStreamVoice) {
            weakSelf.muteStreamVoice(result);
        }
    };
    // 切换线路回调
    _ctrlView.changeLineBlock = ^(NSInteger index) {
        if (weakSelf.changeLineBlock) {
            weakSelf.changeLineBlock(index);
        }
    };
    // 切换清晰度回调
    _ctrlView.changeQualityBlock = ^(NSString * _Nonnull quality) {
        if (weakSelf.changeQualityBlock) {
            weakSelf.changeQualityBlock(quality);
        }
    };
}

- (void)configureConstraints {
    
    __weak typeof(self) weakSelf = self;    
    // 控制视图
    [_ctrlView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(weakSelf);
    }];
}

// MARK: - delloc
- (void)dealloc {
 
}

@end
