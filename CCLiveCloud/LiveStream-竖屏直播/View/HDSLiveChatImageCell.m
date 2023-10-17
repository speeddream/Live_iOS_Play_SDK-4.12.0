//
//  HDSLiveChatImageCell.m
//  CCLiveCloud
//
//  Created by richard lee on 1/8/23.
//  Copyright © 2023 MacBook Pro. All rights reserved.
//

#import "HDSLiveChatImageCell.h"
#import "HDSChatDataModel.h"
#import "CCImageView.h"
#import "CCChatViewDataSourceManager.h"
#import "UIColor+RCColor.h"
#import "UIImageView+WebCache.h"
#import <Masonry/Masonry.h>

@interface HDSLiveChatImageCell ()

@property (nonatomic, strong) UIView *BGView;

@property (nonatomic, strong) UILabel *roleType;

@property (nonatomic, strong) UILabel *userName;

@end

@implementation HDSLiveChatImageCell

// MARK: - API
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor colorWithHexString:@"#FFFFFF" alpha:0];
        [self configureUI];
        [self configureConstraints];
    }
    return self;
}

- (void)setImageModel:(HDSChatDataModel *)model isInput:(BOOL)input indexPath:(NSIndexPath *)indexPath {
    if ([model.msg hasPrefix:@"[img_"] && [model.msg hasSuffix:@"]"]) {
        NSString *url = [model.msg stringByReplacingOccurrencesOfString:@"[img_" withString:@""];
        // Todo: 2023.2.27 ? 需要做为空校验
        NSRange range = [url rangeOfString:@"?"];
        url = [url substringToIndex:range.location];
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *userNameStr = model.userName;
            if (userNameStr.length > 8) {
                userNameStr = [userNameStr substringToIndex:7];
                userNameStr = [NSString stringWithFormat:@"%@...",userNameStr];
            }
            weakSelf.roleType.text = model.roleType;
            weakSelf.userName.text = [NSString stringWithFormat:@"%@:",userNameStr];
            if ([model.roleType isEqualToString:@"讲师"]) {
                weakSelf.roleType.backgroundColor = [UIColor colorWithHexString:@"#FF842F" alpha:0.8];
                weakSelf.userName.textColor = [UIColor colorWithHexString:@"#FF842F" alpha:1];
            } else if ([model.roleType isEqualToString:@"助教"]) {
                weakSelf.roleType.backgroundColor = [UIColor colorWithHexString:@"#0088FE" alpha:0.8];
                weakSelf.userName.textColor = [UIColor colorWithHexString:@"#0AC7FF" alpha:1];
            }
    
            [weakSelf.smallImageView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(model.imageSize);
            }];
            [weakSelf.smallImageView layoutIfNeeded];
            
            [weakSelf.smallImageView sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"暂无图片"] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {

            }];
        });
    }
}

// MARK: - Custom Method

- (void)configureUI {
    _BGView = [[UIView alloc]init];
    _BGView.backgroundColor = [UIColor colorWithHexString:@"#000000" alpha:0.4];
    [self.contentView addSubview:_BGView];
    
    _roleType = [[UILabel alloc]init];
    _roleType.textColor = [UIColor colorWithHexString:@"#FFFFFF" alpha:1];
    _roleType.textAlignment = NSTextAlignmentCenter;
    _roleType.font = [UIFont systemFontOfSize:12];
    [_BGView addSubview:_roleType];
    
    _userName = [[UILabel alloc]init];
    _userName.textAlignment = NSTextAlignmentLeft;
    _userName.textColor = [UIColor colorWithHexString:@"#FFDD99" alpha:1];
    _userName.font = [UIFont systemFontOfSize:14];
    _userName.numberOfLines = 1;
    [_BGView addSubview:_userName];
    
    _smallImageView = [[CCImageView alloc]init];
    _smallImageView.image = [UIImage imageNamed:@"暂无图片"];
    _smallImageView.contentMode = UIViewContentModeScaleAspectFit;
    [_BGView addSubview:_smallImageView];
}

- (void)configureConstraints {
    
    __weak typeof(self) weakSelf = self;
    [_BGView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.contentView).offset(2);
        make.left.mas_equalTo(weakSelf.contentView).offset(5);
        make.bottom.mas_equalTo(weakSelf.contentView).offset(-2);
        make.right.mas_lessThanOrEqualTo(weakSelf.contentView).offset(-5);
    }];
    _BGView.layer.cornerRadius = 12;
    _BGView.layer.masksToBounds = YES;
    
    [_roleType mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.BGView).offset(5);
        make.left.mas_equalTo(weakSelf.BGView).offset(10);
        make.width.mas_equalTo(36);
        make.height.mas_equalTo(17);
    }];
    _roleType.layer.cornerRadius = 8.5;
    _roleType.layer.masksToBounds = YES;
    
    [_userName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.roleType.mas_top);
        make.left.mas_equalTo(weakSelf.roleType.mas_right).offset(4);
        make.right.mas_lessThanOrEqualTo(weakSelf.BGView).offset(-5);
        make.height.mas_equalTo(17);
    }];
    
    [_smallImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.roleType.mas_bottom).offset(5);
        make.left.mas_equalTo(weakSelf.roleType.mas_left);
        make.bottom.mas_lessThanOrEqualTo(weakSelf.BGView).offset(-5);
        make.right.mas_lessThanOrEqualTo(weakSelf.BGView).offset(-10);
        make.size.mas_equalTo(CGSizeMake(120, 90));
    }];
}

- (CGSize)getCGSizeWithImage:(UIImage *)image {
    CGSize imageSize = image.size;
    //先判断图片的宽度和高度哪一个大
    if (image.size.width > image.size.height) {
        //以宽度为准，设置最大宽度
        if (imageSize.width > 219) {
            imageSize.height = 219 / imageSize.width * imageSize.height;
            imageSize.width = 219;
        }
    }else{
        //以高度为准，设置最大高度
        if (imageSize.height >= 219) {
            imageSize.width = 219 / imageSize.height * imageSize.width;
            imageSize.height = 219;
        }
    }
    return imageSize;
}


@end
