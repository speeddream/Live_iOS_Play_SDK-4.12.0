//
//  HDSRedPacketHistoryView.m
//  CCLiveCloud
//
//  Created by 刘强强 on 2022/4/11.
//  Copyright © 2022 MacBook Pro. All rights reserved.
//

#import "HDSRedPacketHistoryView.h"
#import "HDSRedPacketHistoryCell.h"
#import "UIColor+RCColor.h"
#import <Masonry/Masonry.h>

@import HDSRedEnvelopeModule;
@import MJRefresh;

@interface HDSRedPacketHistoryView ()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic, strong) UIView *bgView;

@property(nonatomic, strong) UIView *topView;
@property(nonatomic, strong) UIImageView *iconImgView;
@property(nonatomic, strong) UILabel *userNameLb;
@property(nonatomic, strong) UIButton *closeBtn;
@property(nonatomic, strong) UILabel *totalMoneyTitleLb;
@property(nonatomic, strong) UILabel *totalMoneyLb;

@property(nonatomic, strong) UILabel *totalCountTitleLb;
@property(nonatomic, strong) UILabel *totalCountLb;

@property(nonatomic, strong) UIView *marginView;

@property(nonatomic, strong) UILabel *titleLb;
@property(nonatomic, strong) UIView *titleLine;

@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic, strong) HDSRedEnvelopeWinningUserListModel *modelList;
@property(nonatomic, strong) UIView *nodaView;
@property(nonatomic, strong) UIImageView *nodataImgView;
@property(nonatomic, strong) UILabel *nodataLb;
@end

@implementation HDSRedPacketHistoryView


- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubview];
    }
    return self;
}

- (void)setupSubview {
    self.backgroundColor = [UIColor colorWithHexString:@"#000000" alpha:0.5];
    [self addSubview:self.bgView];
    [self.bgView addSubview:self.topView];
    
    [self.topView addSubview:self.closeBtn];
    [self.topView addSubview:self.iconImgView];
    [self.topView addSubview:self.userNameLb];
    
    [self.topView addSubview:self.marginView];
    
    [self.topView addSubview:self.totalMoneyTitleLb];
    [self.topView addSubview:self.totalMoneyLb];
    
    [self.topView addSubview:self.totalCountTitleLb];
    [self.topView addSubview:self.totalCountLb];
    
    
    [self.bgView addSubview:self.titleLb];
    [self.bgView addSubview:self.titleLine];
    
    [self.bgView addSubview:self.tableView];
    
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@31);
        make.right.equalTo(@(-31));
        make.top.equalTo(@(75));
        make.bottom.equalTo(@(-84));
    }];
    
    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self.bgView);
        make.height.equalTo(@213);
    }];
    
    [self.closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.topView.mas_right).offset(-12);
        make.top.equalTo(@12);
        make.width.height.equalTo(@44);
    }];
    
    [self.iconImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@25);
        make.centerX.equalTo(self.topView.mas_centerX);
        make.width.height.equalTo(@60);
    }];
    
    [self.userNameLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.iconImgView.mas_bottom).offset(10);
        make.height.equalTo(@16);
        make.left.equalTo(@12);
        make.right.equalTo(@(-12));
    }];
    
    [self.marginView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.userNameLb.mas_bottom).offset(26);
        make.height.equalTo(@50);
        make.width.equalTo(@1);
        make.centerX.equalTo(self.topView.mas_centerX);
    }];
    
    [self.totalMoneyTitleLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.userNameLb.mas_bottom).offset(20);
        make.left.equalTo(self.topView);
        make.right.equalTo(self.marginView.mas_left);
    }];
    
    [self.totalMoneyLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.totalMoneyTitleLb.mas_bottom).offset(14);
        make.left.equalTo(self.topView);
        make.right.equalTo(self.marginView.mas_left);
    }];
    
    [self.totalCountTitleLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.totalMoneyTitleLb.mas_top);
        make.left.equalTo(self.marginView.mas_right);
        make.right.equalTo(@(0));
    }];
    
    [self.totalCountLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.totalCountTitleLb.mas_bottom).offset(14);
        make.left.equalTo(self.totalCountTitleLb.mas_left);
        make.right.equalTo(@(0));
    }];
    
    
    [self.titleLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.topView.mas_bottom).offset(20);
        make.height.equalTo(@15);
        make.left.equalTo(@12);
        make.width.equalTo(@60);
    }];
    
    [self.titleLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLb.mas_bottom).offset(13);
        make.height.equalTo(@1);
        make.left.right.equalTo(self.bgView);
    }];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLine.mas_bottom);
        make.left.right.bottom.equalTo(self.bgView);
    }];
    
    __weak typeof(self) weakSelf = self;
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        if ([weakSelf.delegate respondsToSelector:@selector(redPacketHistoryViewLoadRefresh)]) {
            [weakSelf.delegate redPacketHistoryViewLoadRefresh];
        }
    }];
    
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        if ([weakSelf.delegate respondsToSelector:@selector(redPacketHistoryViewLoadMore)]) {
            [weakSelf.delegate redPacketHistoryViewLoadMore];
        }
    }];
    
    [self.bgView addSubview:self.nodaView];
    [self.nodaView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLine.mas_bottom);
        make.left.right.bottom.equalTo(self.bgView);
    }];
    
    [self.nodaView addSubview:self.nodataImgView];
    [self.nodataImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.nodaView);
        make.top.equalTo(self.nodaView).offset(28);
        make.width.mas_equalTo(190);
        make.height.mas_equalTo(120);
    }];
    
    [self.nodaView addSubview:self.nodataLb];
    [self.nodataLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.nodataImgView.mas_bottom).offset(16);
        make.centerX.equalTo(self.nodaView);
    }];
    
}

- (void)showHistory:(HDSRedEnvelopeWinningUserListModel *)model isFirst:(BOOL)isFirst {
    if (isFirst) {
        self.nodaView.hidden = model.records.count > 0;
        self.modelList = model;
        [self updataTopView];
    } else {
        self.nodaView.hidden = YES;
        [self.modelList.records addObjectsFromArray:model.records];
    }
    [self.tableView.mj_header endRefreshing];
    if (model.records.count < 50 && isFirst) {
        [self.tableView.mj_footer endRefreshingWithNoMoreData];
        self.tableView.mj_footer.hidden = isFirst;
    } else {
        [self.tableView.mj_footer endRefreshing];
    }
    [self.tableView reloadData];
}

- (void)updataTopView {
    HDSRedEnvelopeWinningUserListRecordModel *record = self.modelList.records.firstObject;
    if (record.redKind == 2) {
        self.totalMoneyTitleLb.text = @"学分";
        self.totalMoneyLb.text = [NSString stringWithFormat:@"%.2f",self.modelList.totalPrice];
    } else {
        self.totalMoneyTitleLb.text = @"金额（元）";
        self.totalMoneyLb.text = [NSString stringWithFormat:@"%.2f",self.modelList.totalPrice / 100.0];
    }
    self.iconImgView.image = [UIImage imageNamed:@"默认头像"];
    self.userNameLb.text = self.modelList.userName;
    self.totalCountLb.text = [NSString stringWithFormat:@"%ld",self.modelList.total];
}

- (void)closeBtnAction {
    if ([self.delegate respondsToSelector:@selector(redPacketHistoryViewClose)]) {
        [self.delegate redPacketHistoryViewClose];
    }
}

#pragma UITableViewDelegate,UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.modelList.records.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    HDSRedPacketHistoryCell *cell  = [tableView dequeueReusableCellWithIdentifier:@"HDSRedPacketHistoryCellID"];
    if (!cell) {
        cell = [[HDSRedPacketHistoryCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"HDSRedPacketHistoryCellID"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.model = self.modelList.records[indexPath.row];
    return cell;
}


#pragma 懒加载
- (UIView *)bgView {
    if (!_bgView) {
        _bgView = [[UIView alloc] init];
        _bgView.layer.cornerRadius = 8;
        _bgView.layer.masksToBounds = YES;
        _bgView.backgroundColor = [UIColor colorWithHexString:@"#FFFFFF" alpha:1.0];
    }
    return _bgView;
}

- (UIView *)topView {
    if (!_topView) {
        _topView = [[UIView alloc] init];
        _topView.backgroundColor = [UIColor colorWithHexString:@"#F25642" alpha:1];
    }
    return _topView;
}

- (UIImageView *)iconImgView {
    if (!_iconImgView) {
        _iconImgView = [[UIImageView alloc] init];
        _iconImgView.contentMode = UIViewContentModeScaleAspectFit;
        _iconImgView.layer.cornerRadius = 30;
        _iconImgView.layer.masksToBounds = YES;
    }
    return _iconImgView;
}

- (UILabel *)userNameLb {
    if (!_userNameLb) {
        _userNameLb = [[UILabel alloc] init];
        _userNameLb.textColor = [UIColor colorWithHexString:@"#FDE3B2" alpha:1];
        _userNameLb.textAlignment = NSTextAlignmentCenter;
        _userNameLb.font = [UIFont systemFontOfSize:16];
    }
    return _userNameLb;
}

- (UIButton *)closeBtn {
    if (!_closeBtn) {
        _closeBtn = [[UIButton alloc] init];
        [_closeBtn setImage:[UIImage imageNamed:@"redPacket_close"] forState:UIControlStateNormal];
        [_closeBtn addTarget:self action:@selector(closeBtnAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeBtn;
}

- (UILabel *)totalMoneyTitleLb {
    if (!_totalMoneyTitleLb) {
        _totalMoneyTitleLb = [[UILabel alloc] init];
        _totalMoneyTitleLb.font = [UIFont systemFontOfSize:16];
        _totalMoneyTitleLb.textColor = [UIColor colorWithHexString:@"#FDE3B2" alpha:1];
        _totalMoneyTitleLb.textAlignment = NSTextAlignmentCenter;
        _totalMoneyTitleLb.text = @"金额（元）";
    }
    return _totalMoneyTitleLb;
}

- (UILabel *)totalMoneyLb {
    if (!_totalMoneyLb) {
        _totalMoneyLb = [[UILabel alloc] init];
        _totalMoneyLb.font = [UIFont systemFontOfSize:32];
        _totalMoneyLb.textColor = [UIColor colorWithHexString:@"#FDE3B2" alpha:1];
        _totalMoneyLb.textAlignment = NSTextAlignmentCenter;
        [_totalMoneyLb sizeToFit];
    }
    return _totalMoneyLb;
}

- (UILabel *)totalCountTitleLb {
    if (!_totalCountTitleLb) {
        _totalCountTitleLb = [[UILabel alloc] init];
        _totalCountTitleLb.font = [UIFont systemFontOfSize:16];
        _totalCountTitleLb.textColor = [UIColor colorWithHexString:@"#FDE3B2" alpha:1];
        _totalCountTitleLb.textAlignment = NSTextAlignmentCenter;
        _totalCountTitleLb.text = @"数量（个）";
    }
    return _totalCountTitleLb;
}

- (UILabel *)totalCountLb {
    if (!_totalCountLb) {
        _totalCountLb = [[UILabel alloc] init];
        _totalCountLb.font = [UIFont systemFontOfSize:32];
        _totalCountLb.textColor = [UIColor colorWithHexString:@"#FDE3B2" alpha:1];
        _totalCountLb.textAlignment = NSTextAlignmentCenter;
    }
    return _totalCountLb;
}

- (UIView *)marginView {
    if (!_marginView) {
        _marginView = [[UIView alloc] init];
        _marginView.backgroundColor = [UIColor colorWithHexString:@"#FDE3B2" alpha:1];
    }
    return _marginView;
}

- (UILabel *)titleLb {
    if (!_titleLb) {
        _titleLb = [[UILabel alloc] init];
        _titleLb.text = @"领取记录";
        _titleLb.textColor = [UIColor colorWithHexString:@"#B1B1B1" alpha:1];
        _titleLb.font = [UIFont systemFontOfSize:14];
    }
    return _titleLb;
}

- (UIView *)titleLine {
    if (!_titleLine) {
        _titleLine = [[UIView alloc] init];
        _titleLine.backgroundColor = [UIColor colorWithHexString:@"#EAEAEA" alpha:1];
    }
    return _titleLine;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.estimatedRowHeight = 70;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
    }
    return _tableView;
}

- (UIView *)nodaView {
    if (!_nodaView) {
        _nodaView = [[UIView alloc] init];
        _nodaView.backgroundColor = [UIColor colorWithHexString:@"#FFFFFF" alpha:1];
        _nodaView.hidden = YES;
    }
    return _nodaView;
}

- (UIImageView *)nodataImgView {
    if (!_nodataImgView) {
        _nodataImgView = [[UIImageView alloc] init];
        _nodataImgView.image = [UIImage imageNamed:@"无内容备份"];
        _nodataImgView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _nodataImgView;
}

- (UILabel *)nodataLb {
    if (!_nodataLb) {
        _nodataLb = [[UILabel alloc] init];
        _nodataLb.textColor = [UIColor colorWithHexString:@"#999999" alpha:1];
        _nodataLb.text = @"当前暂无领取记录哦~";
        _nodataLb.font = [UIFont systemFontOfSize:13];
        _nodataLb.textAlignment = NSTextAlignmentCenter;
    }
    return _nodataLb;
}

@end
