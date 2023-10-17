//
//  HDSQuestionCell.m
//  CCLiveCloud
//
//  Created by richard lee on 3/15/23.
//  Copyright © 2023 MacBook Pro. All rights reserved.
//

#import "HDSQuestionCell.h"
#import "Dialogue.h"
#import "UIColor+RCColor.h"
#import "UIImageView+WebCache.h"
#import "NSString+CCSwitchTime.h"
#import "UIImageView+Extension.h"
#import <Masonry/Masonry.h>

@interface HDSQuestionCell ()

@property (nonatomic, assign) BOOL moreAnswer;

@property (nonatomic, strong) UILabel *topLine;

@property (nonatomic, strong) UIImageView *headerView;

@property (nonatomic, strong) UILabel *nameLabel;

@property (nonatomic, strong) UILabel *timeLabel;

@property (nonatomic, strong) UILabel *contentLabel;

@property (nonatomic, strong) UIImageView *imagesView;

@property (nonatomic, strong) UILabel *dividerLine;

@property (nonatomic, copy) btnsTappedClosure callBack;

@property (nonatomic, strong) NSMutableArray *imagesArray;

@property (nonatomic, strong) NSMutableArray *callBackImageArray;

@property (nonatomic, strong) UILabel *kLabel;

@end

@implementation HDSQuestionCell

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

- (void)setDatasource:(Dialogue *)dialogue moreAnswer:(BOOL)moreAnswer btnsTapBlock:(btnsTappedClosure)btnsTapClosure {
    
    if (dialogue.isPublish == NO && ![dialogue.myViwerId isEqualToString:dialogue.fromuserid]) {
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
    
    _moreAnswer = moreAnswer;
    [self.imagesArray removeAllObjects];
    [self.imagesArray addObjectsFromArray:dialogue.images];
    [self.callBackImageArray removeAllObjects];
    
    if (btnsTapClosure) {
        _callBack = btnsTapClosure;
    }
    //设置头像视图
    NSURL *url = [NSURL URLWithString:dialogue.useravatar];
    [self.headerView sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"chatHead_student"]];
    
    BOOL fromSelf = [dialogue.fromuserid isEqualToString:dialogue.myViwerId];
    //设置昵称
    self.nameLabel.text = dialogue.username;
    if (fromSelf) {
        self.nameLabel.textColor = [UIColor colorWithHexString:@"#FF6633" alpha:1.0f];
    }else {
        self.nameLabel.textColor = [UIColor colorWithHexString:@"#79808B" alpha:1.0f];
    }
    
    // 应该展示的时间
    NSInteger realTime = 0;
    if ([dialogue.time integerValue] == -1 || dialogue.time.length == 0) {
        realTime = [[NSDate alloc] timeIntervalSince1970];
    } else {
        // 直播开始时间
        NSString *liveStartTime = GetFromUserDefaults(LIVE_STARTTIME);
        NSInteger startTime = [liveStartTime integerValue];
        // 直播开播时长
        NSInteger duration = [dialogue.time integerValue];
        realTime = (long)duration + (long)startTime;
    }
    self.timeLabel.text = [NSString timestampSwitchTime:realTime andFormatter:@"HH:mm"];

    NSMutableAttributedString *textAttri = [[NSMutableAttributedString alloc] initWithString:dialogue.msg];
    [textAttri addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"#1E1F21" alpha:1] range:NSMakeRange(0, textAttri.length)];
    NSMutableParagraphStyle *style1 = [[NSMutableParagraphStyle alloc] init];
    style1.minimumLineHeight = 20;
    style1.maximumLineHeight = 20;
    style1.alignment = NSTextAlignmentLeft;
    style1.lineBreakMode = NSLineBreakByCharWrapping;
    NSDictionary *dict1 = @{NSFontAttributeName:[UIFont systemFontOfSize:14],NSParagraphStyleAttributeName:style1};
    [textAttri addAttributes:dict1 range:NSMakeRange(0, textAttri.length)];
    _contentLabel.attributedText = textAttri;
    
    __weak typeof(self) weakSelf = self;
    if (self.imagesArray.count > 0) {
        if (self.imagesArray.count > 1) {
            [self initContainerView:self.imagesView images:self.imagesArray singleMaxLength:4];
            [_imagesView mas_updateConstraints:^(MASConstraintMaker *make) {
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
                make.width.mas_equalTo(180);
                make.height.mas_equalTo(134);
            }];
            
            UIButton *oneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            oneBtn.tag = 1;
            [_imagesView addSubview:oneBtn];
            __weak typeof(self) weakSelf = self;
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
    
    CGFloat dividerLineH = _moreAnswer == YES ? 1 : 0;
    [_dividerLine mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(dividerLineH);
    }];
}

// MARK: - Custom Method
- (void)configureUI {
    
    _topLine = [[UILabel alloc]init];
    _topLine.backgroundColor = [UIColor colorWithHexString:@"#E8E8E8" alpha:1];
    [self.contentView addSubview:_topLine];
    
    _headerView = [[UIImageView alloc]init];
    _headerView.contentMode = UIViewContentModeScaleAspectFill;
    [self.contentView addSubview:_headerView];
    
    _nameLabel = [[UILabel alloc]init];
    _nameLabel.textColor = [UIColor colorWithHexString:@"#79808B" alpha:1];
    _nameLabel.font = [UIFont systemFontOfSize:12];
    _nameLabel.textAlignment = NSTextAlignmentLeft;
    [self.contentView addSubview:_nameLabel];
    
    _timeLabel = [[UILabel alloc]init];
    _timeLabel.textColor = [UIColor colorWithHexString:@"79808B" alpha:1];
    _timeLabel.font = [UIFont systemFontOfSize:12];
    _timeLabel.textAlignment = NSTextAlignmentRight;
    [self.contentView addSubview:_timeLabel];
    
    _contentLabel = [[UILabel alloc]init];
    _contentLabel.textColor = [UIColor colorWithHexString:@"#1E1F21" alpha:1];
    _contentLabel.numberOfLines = 0;
    _contentLabel.font = [UIFont systemFontOfSize:14];
    [self.contentView addSubview:_contentLabel];
    
    _imagesView = [[UIImageView alloc]init];
    _imagesView.contentMode = UIViewContentModeScaleAspectFill;
    _imagesView.userInteractionEnabled = YES;
    [self.contentView addSubview:_imagesView];
    _imagesView.layer.masksToBounds = YES;
    
    _dividerLine = [[UILabel alloc]init];
    _dividerLine.backgroundColor = [UIColor colorWithHexString:@"#E8E8E8" alpha:1];
    [self.contentView addSubview:_dividerLine];
}

- (void)configureConstraints {
    
    __weak typeof(self) weakSelf = self;
    
    [_topLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(weakSelf.contentView);
        make.height.mas_equalTo(0.5);
    }];
    
    [_headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.contentView).offset(15);
        make.left.mas_equalTo(weakSelf.contentView).offset(10);
        make.width.height.mas_equalTo(25);
    }];
    _headerView.layer.cornerRadius = 12.5f;
    _headerView.layer.masksToBounds = YES;
    
    [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.contentView).offset(15);
        make.left.mas_equalTo(weakSelf.headerView.mas_right).offset(10);
    }];
    
    [_timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.contentView).offset(15);
        make.right.mas_equalTo(weakSelf.contentView).offset(-15.5);
    }];
    
    [_contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.nameLabel.mas_bottom).offset(8);
        make.left.mas_equalTo(weakSelf.headerView.mas_right).offset(10);
        make.right.mas_equalTo(weakSelf.contentView).offset(-15);
    }];
    
    [_imagesView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.contentLabel.mas_bottom).offset(8);
        make.left.mas_equalTo(weakSelf.headerView.mas_right).offset(10);
    }];
    
    [_dividerLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.imagesView.mas_bottom).offset(8);
        make.left.mas_equalTo(weakSelf.headerView.mas_right).offset(10);
        make.right.mas_equalTo(weakSelf.contentView).offset(-15);
        make.height.mas_equalTo(1);
        make.bottom.mas_equalTo(weakSelf.contentView);
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
                make.bottom.mas_equalTo(containerView).offset(-5);
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
