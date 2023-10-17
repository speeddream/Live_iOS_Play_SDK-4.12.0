//
//  HDSLiveStreamRemindCell.m
//  HDSTestDemo
//
//  Created by richard lee on 1/5/23.
//

#import "HDSLiveStreamRemindCell.h"
#import "UIColor+RCColor.h"
#import <Masonry/Masonry.h>

@interface HDSLiveStreamRemindCell ()

@property (nonatomic, strong) UIImageView *customBGView;
@property (nonatomic, strong) UIImageView *customIMGView;
@property (nonatomic, strong) UILabel *custonLabel;

@end

@implementation HDSLiveStreamRemindCell

// MARK: - API
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor colorWithHexString:@"#FFFFFF" alpha:0];
        [self customUI];
        [self customConstraints];

    }
    return self;
}

- (void)showRemindInfomation:(NSString *)infomation {
    self.custonLabel.text = infomation;
}

// MARK: - Custom Method
- (void)customUI {
    
    _customBGView = [[UIImageView alloc]init];
    _customBGView.image = [UIImage imageNamed:@"矩形"];
    [self.contentView addSubview:_customBGView];
    
    _customIMGView = [[UIImageView alloc]init];
    _customIMGView.contentMode = UIViewContentModeCenter;
    _customIMGView.image = [UIImage imageNamed:@"喇叭"];
    [_customBGView addSubview:_customIMGView];
    
    _custonLabel = [[UILabel alloc]init];
    _custonLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    _custonLabel.textColor = [UIColor colorWithHexString:@"#FFFFFF" alpha:1];
    _custonLabel.font = [UIFont systemFontOfSize:13];
    [_customBGView addSubview:_custonLabel];
    
}

- (void)customConstraints {
    __weak typeof(self) weakSelf = self;
    [_customBGView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf).offset(27);
        make.left.right.mas_equalTo(weakSelf);
        make.height.mas_equalTo(29);
    }];
    
    [_customIMGView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(4);
        make.centerY.mas_equalTo(weakSelf.customBGView);
        make.width.height.mas_equalTo(29);
    }];
    [_customIMGView layoutIfNeeded];
    
    [_custonLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.customIMGView.mas_right).offset(2);
        make.right.mas_equalTo(weakSelf.customBGView).offset(-5);
        make.centerY.mas_equalTo(weakSelf.customBGView);
        make.height.mas_equalTo(29);
    }];
    [_custonLabel layoutIfNeeded];
}

@end
