//
//  HDSQuestionAddImageItemCell.m
//  CCLiveCloud
//
//  Created by richard lee on 3/10/23.
//  Copyright © 2023 MacBook Pro. All rights reserved.
//

#import "HDSQuestionAddImageItemCell.h"
#import "UIColor+RCColor.h"
#import <Masonry/Masonry.h>

@interface HDSQuestionAddImageItemCell ()

@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation HDSQuestionAddImageItemCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self configureUI];
        [self configureConstraints];
    }
    return self;
}

- (void)setIsEdit:(BOOL)isEdit {
    _isEdit = isEdit;
    NSString *imageName = _isEdit == YES ? @"添加可用nor" : @"添加ban";
    _imageView.image = [UIImage imageNamed:imageName];
}

// MARK: - Custom Method
- (void)configureUI {
    
    self.contentView.backgroundColor = [UIColor colorWithHexString:@"#F5F5F5" alpha:1];
    
    _imageView = [[UIImageView alloc]init];
    _imageView.image = [UIImage imageNamed:@"添加可用nor"];
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.contentView addSubview:_imageView];
    _imageView.layer.masksToBounds = YES;
}

- (void)configureConstraints {
    __weak typeof(self) weakSelf = self;
    [_imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(weakSelf.contentView);
        make.width.height.mas_equalTo(30);
    }];
}

@end
