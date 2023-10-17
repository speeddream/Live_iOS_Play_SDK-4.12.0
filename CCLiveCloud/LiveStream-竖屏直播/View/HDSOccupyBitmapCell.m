//
//  HDSOccupyBitmapCell.m
//  CCLiveCloud
//
//  Created by richard lee on 1/10/23.
//  Copyright © 2023 MacBook Pro. All rights reserved.
//

#import "HDSOccupyBitmapCell.h"
#import "UIColor+RCColor.h"
#import <Masonry/Masonry.h>

@interface HDSOccupyBitmapCell ()

@property (nonatomic, strong) UIView *tempView;
@end

@implementation HDSOccupyBitmapCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor colorWithHexString:@"#000000" alpha:0];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self configureUI];
    }
    return self;
}

- (void)configureUI {
    _tempView = [[UIView alloc]init];
    [self.contentView addSubview:_tempView];
    [_tempView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(self);
        make.height.mas_equalTo(213/5);
    }];
}

@end
