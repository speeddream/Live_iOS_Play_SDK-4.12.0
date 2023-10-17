//
//  HDSQuestionFooterView.m
//  CCLiveCloud
//
//  Created by richard lee on 3/16/23.
//  Copyright © 2023 MacBook Pro. All rights reserved.
//

#import "HDSQuestionFooterCell.h"
#import "UIColor+RCColor.h"
#import <Masonry/Masonry.h>

@interface HDSQuestionFooterCell ()

@property (nonatomic, strong) UIView *boardView;

@property (nonatomic, strong) UILabel *tipLabel;

@property (nonatomic, strong) UIImageView *iconIMG;

@property (nonatomic, strong) UIButton *kButton;

@property (nonatomic, assign) BOOL isOpen;

@property (nonatomic, assign) int otherCount;

@property (nonatomic, copy) buttonTappedBlock callBack;

@property (nonatomic, assign) NSInteger section;

@end

@implementation HDSQuestionFooterCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.contentView.backgroundColor = [UIColor colorWithHexString:@"#FFFFFF" alpha:1];
        [self configureUI];
        [self configureConstraints];
    }
    return self;
}

- (void)setDataOpen:(BOOL)open otherCount:(int)otherCount section:(NSInteger)section closure:(buttonTappedBlock)closure {
    __weak typeof(self) weakSelf = self;
    if (otherCount == 0) {
        [_boardView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(0);
            make.bottom.mas_equalTo(weakSelf.contentView).offset(0.1);
        }];
        return;
    } else {
        [_boardView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(21);
            make.bottom.mas_equalTo(weakSelf.contentView).offset(-8);
        }];
    }
    if (closure) {
        _callBack = closure;
    }
    self.isOpen = open;
    self.section = section;
    self.otherCount = otherCount;

    NSString *imageName = _isOpen == YES ? @"问答_收起" : @"问答_展开";
    _iconIMG.image = [UIImage imageNamed:imageName];

    if (_isOpen == YES) {
        _iconIMG.image = [UIImage imageNamed:@"问答_收起"];
        _tipLabel.text = @"收起回复";
    } else {
        _iconIMG.image = [UIImage imageNamed:@"问答_展开"];
        _tipLabel.text = [NSString stringWithFormat:@"展开其他%ld条回复",(long)_otherCount];
    }
    
    _kButton.selected = _isOpen;
}

- (void)configureUI {
    _boardView = [[UIView alloc]init];
    _boardView.userInteractionEnabled = YES;
    _boardView.backgroundColor = [UIColor colorWithHexString:@"#F5F5F5" alpha:1];
    [self.contentView addSubview:_boardView];
    
    _iconIMG = [[UIImageView alloc]init];
    _iconIMG.contentMode = UIViewContentModeCenter;
    [_boardView addSubview:_iconIMG];
    
    _tipLabel = [[UILabel alloc]init];
    _tipLabel.font = [UIFont systemFontOfSize:12];
    _tipLabel.textColor = [UIColor colorWithHexString:@"#666666" alpha:1];
    _tipLabel.textAlignment = NSTextAlignmentLeft;
    [_boardView addSubview:_tipLabel];
    
    _kButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_boardView addSubview:_kButton];
    [_kButton addTarget:self action:@selector(kButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)configureConstraints {
    __weak typeof(self) weakSelf = self;
    [_boardView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.contentView).offset(2);
        make.left.mas_equalTo(weakSelf.contentView).offset(45);
        make.height.mas_equalTo(21);
        make.bottom.mas_equalTo(weakSelf.contentView).offset(-8);
    }];
    _boardView.layer.cornerRadius = 2.f;
    _boardView.layer.masksToBounds = YES;
    
    [_iconIMG mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(weakSelf.boardView).offset(-8);
        make.centerY.mas_equalTo(weakSelf.boardView);
        make.width.mas_equalTo(8);
        make.height.mas_equalTo(8);
    }];
    
    [_tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.boardView).offset(8);
        make.centerY.mas_equalTo(weakSelf.boardView);
        make.right.mas_equalTo(weakSelf.boardView).offset(-18);
    }];
    
    [_kButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(weakSelf.boardView);
    }];
}

- (void)kButtonTapped:(UIButton *)sender {
    _kButton.selected = !sender.selected;
    if (_callBack) {
        _callBack(_kButton.selected,_section);
    }
}

@end
