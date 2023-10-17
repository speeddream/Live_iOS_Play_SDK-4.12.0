//
//  HDSAnswerCell.m
//  CCLiveCloud
//
//  Created by richard lee on 3/15/23.
//  Copyright © 2023 MacBook Pro. All rights reserved.
//

#import "HDSAnswerCell.h"
#import "Dialogue.h"
#import "UIColor+RCColor.h"
#import "UIImageView+Extension.h"
#import <Masonry/Masonry.h>

@interface HDSAnswerCell ()

@property (nonatomic, strong) UILabel *contentLabel;

@property (nonatomic, strong) UIImageView *imagesView;

@property (nonatomic, copy) btnsTappedClosure callBack;

@property (nonatomic, strong) NSMutableArray *imagesArray;

@property (nonatomic, strong) NSMutableArray *callBackImageArray;

@property (nonatomic, strong) UILabel *kLabel;

@end

@implementation HDSAnswerCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.contentView.backgroundColor = [UIColor colorWithHexString:@"#FFFFFF" alpha:1];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        ///格栅处理
        self.layer.shouldRasterize = YES;
        self.layer.rasterizationScale = [UIScreen mainScreen].scale;
        ///异步绘制
        self.layer.drawsAsynchronously = YES;
        
        [self configureUI];
        [self configureConstraints];
    }
    return self;
}

- (void)setDatasource:(Dialogue *)dialogue btnsTapBlock:(btnsTappedClosure)btnsTapClosure {
    
    __weak typeof(self) weakSelf = self;
    if (dialogue.isPrivate == YES) {
        for (UIView *oneView in self.contentView.subviews) {
            [oneView removeFromSuperview];
        }
        _kLabel = [[UILabel alloc]init];
        _kLabel.text = @"1";
        _kLabel.textColor = [UIColor whiteColor];
        [self.contentView addSubview:_kLabel];
        [_kLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.right.mas_equalTo(self.contentView);
            make.bottom.mas_equalTo(self.contentView);
            make.height.mas_equalTo(0.3);
        }];
        return;
    }
    [self.imagesArray removeAllObjects];
    [self.imagesArray addObjectsFromArray:dialogue.images];
    [self.callBackImageArray removeAllObjects];
    
    if (btnsTapClosure) {
        _callBack = btnsTapClosure;
    }
    
    NSString *userName = dialogue.username;
    if (dialogue.username.length > 7) {
        userName = [userName substringToIndex:7];
        userName = [userName stringByAppendingString:@"...: "];
    } else {
        userName = [userName stringByAppendingString:@": "];
    }
    NSString *contentStr = [NSString stringWithFormat:@"%@%@",userName,dialogue.msg];
    
    NSMutableAttributedString *textAttri = [[NSMutableAttributedString alloc] initWithString:contentStr];
    [textAttri addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"#12AD1A" alpha:1] range:NSMakeRange(0, userName.length)];
    [textAttri addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:12] range:NSMakeRange(0, userName.length)];
    [textAttri addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"#1E1F21" alpha:1] range:NSMakeRange(userName.length, dialogue.msg.length)];
    [textAttri addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14] range:NSMakeRange(userName.length, dialogue.msg.length)];
    NSMutableParagraphStyle *style1 = [[NSMutableParagraphStyle alloc] init];
    style1.minimumLineHeight = 20;
    style1.maximumLineHeight = 20;
    style1.alignment = NSTextAlignmentLeft;
    style1.lineBreakMode = NSLineBreakByCharWrapping;
    _contentLabel.attributedText = textAttri;
    
    if (self.imagesArray.count > 0) {
        if (self.imagesArray.count > 1) {
            [self initContainerView:self.imagesView images:self.imagesArray singleMaxLength:4];
            [_imagesView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(weakSelf.contentLabel.mas_bottom).offset(8);
                make.width.mas_equalTo(SCREEN_WIDTH-45-18);
            }];
        } else {
            NSDictionary *imageDict = [self.imagesArray firstObject];
            NSString *imageUrl = @"";
            if ([imageDict.allKeys containsObject:@"url"]) {
                imageUrl = imageDict[@"url"];
            }
            [self.callBackImageArray addObject:imageUrl];
            [_imagesView setBigImage:imageUrl];
            [_imagesView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(weakSelf.contentLabel.mas_bottom).offset(8);
                make.width.mas_equalTo(180);
                make.height.mas_equalTo(134);
            }];
            
            UIButton *oneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            oneBtn.tag = 1;
            [_imagesView addSubview:oneBtn];
            [oneBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.mas_equalTo(weakSelf.imagesView);
            }];
            [oneBtn addTarget:self action:@selector(btnsTapped:) forControlEvents:UIControlEventTouchUpInside];
        }
    } else {
        [_imagesView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(weakSelf.contentLabel.mas_bottom).offset(-0.5);
            make.width.mas_equalTo(0.1);
        }];
    }
}

// MARK: - Custom Method
- (void)configureUI {
    
    _contentLabel = [[UILabel alloc]init];
    _contentLabel.font = [UIFont systemFontOfSize:12];
    _contentLabel.numberOfLines = 0;
    [self.contentView addSubview:_contentLabel];
    
    _imagesView = [[UIImageView alloc]init];
    _imagesView.contentMode = UIViewContentModeScaleAspectFill;
    _imagesView.userInteractionEnabled = YES;
    [self.contentView addSubview:_imagesView];
    _imagesView.layer.masksToBounds = YES;
}

- (void)configureConstraints {
    
    __weak typeof(self) weakSelf = self;
    [_contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.contentView).offset(5);
        make.left.mas_equalTo(weakSelf.contentView).offset(45);
        make.right.mas_equalTo(weakSelf.contentView).offset(-15);
    }];
    
    [_imagesView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.contentLabel.mas_bottom).offset(8);
        make.left.mas_equalTo(weakSelf.contentView).offset(45);
        make.bottom.mas_equalTo(weakSelf.contentView).offset(-7);
    }];
}

- (void)initContainerView:(UIView *)containerView images:(NSArray *)images singleMaxLength:(int)maxLength {
    if (maxLength == 0 || images.count == 0) return;
    if (containerView == nil || containerView.superview == nil) return;
    CGFloat oneIMGVMargin = 4;
    CGFloat oneIMGVWH = 75;
    UIImageView *lastIMGV;
    __block int currentRow = 0;
    for (int i = 0; i < images.count; i++) {
        NSDictionary *imageDict = images[i];
        NSString *imageUrl = @"";
        if ([imageDict.allKeys containsObject:@"url"]) {
            imageUrl = imageDict[@"url"];
        }
        UIImageView *oneIMGV = [[UIImageView alloc]init];
        oneIMGV.contentMode = UIViewContentModeScaleAspectFill;
        oneIMGV.layer.masksToBounds = YES;
        oneIMGV.userInteractionEnabled = YES;
        [oneIMGV setBigImage:imageUrl];
        [containerView addSubview:oneIMGV];
        [self.callBackImageArray addObject:imageUrl];
        [oneIMGV mas_makeConstraints:^(MASConstraintMaker *make) {
            if (i / maxLength == 0) {
                make.top.mas_equalTo(containerView).offset(oneIMGVMargin);
            } else {
                int row = i / maxLength;
                if (row == currentRow) {
                    make.top.mas_equalTo(lastIMGV.mas_top);
                } else {
                    make.top.mas_equalTo(lastIMGV.mas_bottom).offset(oneIMGVMargin);
                    currentRow = row;
                }
            }
            if (i % maxLength == 0) {
                make.left.mas_equalTo(containerView);
            } else {
                make.left.mas_equalTo(lastIMGV.mas_right).offset(oneIMGVMargin);
            }
            if (i == images.count - 1) {
                make.bottom.mas_equalTo(containerView);
            }
            make.width.height.mas_equalTo(oneIMGVWH);
        }];
        
        UIButton *oneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        oneBtn.tag = i;
        [oneBtn addTarget:self action:@selector(btnsTapped:) forControlEvents:UIControlEventTouchUpInside];
        [oneIMGV addSubview:oneBtn];
        [oneBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(oneIMGV);
        }];
        
        lastIMGV = oneIMGV;
    }
    [containerView layoutIfNeeded];
}

- (void)btnsTapped:(UIButton *)sender {
    if (_callBack) {
        _callBack((int)sender.tag,self.callBackImageArray);
    }
}

// MARK: - LAZY
- (NSMutableArray *)imagesArray {
    if (!_imagesArray) {
        _imagesArray = [NSMutableArray array];
    }
    return _imagesArray;
}

- (NSMutableArray *)callBackImageArray {
    if (!_callBackImageArray) {
        _callBackImageArray = [NSMutableArray array];
    }
    return _callBackImageArray;
}

@end
