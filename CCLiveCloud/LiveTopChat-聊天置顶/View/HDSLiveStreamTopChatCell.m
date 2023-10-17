//
//  HDSLiveStreamTopChatCell.m
//  CCLiveCloud
//
//  Created by richard lee on 1/11/23.
//  Copyright © 2023 MacBook Pro. All rights reserved.
//

#import "HDSLiveStreamTopChatCell.h"
#import "Utility.h"
#import "HDSLiveTopChatModel+BaseModel.h"
#import "UIColor+RCColor.h"
#import "CCcommonDefine.h"
#import <YYText/YYText.h>
#import <YYImage/YYImage.h>
#import <Masonry/Masonry.h>

@interface HDSLiveStreamTopChatCell ()

@property (nonatomic, strong) UIView *topBGView;

@property (nonatomic, strong) UIImageView *topFlagIMGView;

@property (nonatomic, strong) UILabel *roleTypeLabel;

@property (nonatomic, strong) UILabel *roleNameLabel;

@property (nonatomic, strong) YYTextView *content;

@property (nonatomic, strong) YYLabel *contentLabel;

@property (nonatomic, strong) UIView *openView;

@property (nonatomic, strong) UILabel *openLabel;

@property (nonatomic, strong) UIImageView *openIMGView;

@property (nonatomic, strong) UIButton *opentBtn;

@end

@implementation HDSLiveStreamTopChatCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self configureUI];
        [self configureConstraints];
        self.contentView.userInteractionEnabled = YES;
    }
    return self;
}

- (void)setCustomEmojiDict:(NSDictionary *)customEmojiDict {
    _customEmojiDict = customEmojiDict;
    NSMutableDictionary *mapper = [NSMutableDictionary new];
    for (int i = 1; i <= 20 ;i++) {
        NSString *key = [NSString stringWithFormat:@"[em2_%02d]",i];
        NSString *value = [NSString stringWithFormat:@"%03d",i];
        mapper[key] = [self imageWithName:value];
    }
    [mapper addEntriesFromDictionary:_customEmojiDict];
    
    // 自定义表情
    YYTextSimpleEmoticonParser *parser = [YYTextSimpleEmoticonParser new];
    parser.emoticonMapper = mapper;
    _content.textParser = parser;
    _contentLabel.textParser = parser;
}

- (void)setViewerId:(NSString *)viewerId {
    _viewerId = viewerId;
}

- (void)setModel:(HDSLiveTopChatModel *)model {
    _model = model;
    if (_model.isOpen) {
        [self closeContentViewFunc];
    } else {
        [self openContentViewFunc];
    }
    _roleTypeLabel.hidden = NO;
    if ([model.fromViewerId isEqualToString:_viewerId]) {
        _roleNameLabel.text = [NSString stringWithFormat:@"%@(我):",model.fromViewerName];
    } else {
        _roleNameLabel.text = [NSString stringWithFormat:@"%@:",model.fromViewerName];
    }
    CGFloat collectionViewW = 244 * SCREEN_WIDTH / 375;
    CGFloat contentW = [self getTextHeight:model.content maxWidth:collectionViewW];
    
    self.openView.hidden = YES;
    if (contentW > 27.0) {
        self.openView.hidden = NO;
    }
    CGFloat roleTypeW = 36 * SCREEN_WIDTH / 375;
    if (model.fromViewerRole == 1) {
        _roleTypeLabel.text = @"讲师";
        _roleTypeLabel.backgroundColor = [UIColor colorWithHexString:@"#FF842F" alpha:1];
        _roleNameLabel.textColor = [UIColor colorWithHexString:@"#FF842F" alpha:1];
    } else if (model.fromViewerRole == 2) {
        _roleTypeLabel.text = @"助教";
        _roleTypeLabel.backgroundColor = [UIColor colorWithHexString:@"#0088FE" alpha:1];
        _roleNameLabel.textColor = [UIColor colorWithHexString:@"#FF842F" alpha:1];
    } else if (model.fromViewerRole == 3) {
        _roleTypeLabel.text = @"主持";
        _roleTypeLabel.backgroundColor = [UIColor colorWithHexString:@"#1BBD79" alpha:1];
        _roleNameLabel.textColor = [UIColor colorWithHexString:@"#1BBD79" alpha:1];
    } else if (model.fromViewerRole == 4) {
        _roleTypeLabel.hidden = YES;
        _roleNameLabel.textColor = [UIColor colorWithHexString:@"#FFDD99" alpha:1];
        roleTypeW = 0;
    }
    __weak typeof(self) weakSelf = self;
    [_roleNameLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.topFlagIMGView.mas_right).offset(roleTypeW + 10);
    }];
    [_roleNameLabel layoutIfNeeded];
    
    _contentLabel.attributedText = [self getTextAttri:model.content textColor:[UIColor colorWithHexString:@"F7F7F7" alpha:1] font:[UIFont systemFontOfSize:14]];
    _content.attributedText = [self getTextAttri:model.content textColor:[UIColor colorWithHexString:@"F7F7F7" alpha:1] font:[UIFont systemFontOfSize:14]];
}

- (void)setIndexPath:(NSIndexPath *)indexPath {
    _indexPath = indexPath;
}

// MARK: - Custom Method

- (void)configureUI {
    _topBGView = [[UIView alloc]init];
    [self.contentView addSubview:_topBGView];
    
    _topFlagIMGView = [[UIImageView alloc]init];
    _topFlagIMGView.image = [UIImage imageNamed:@"top"];
    _topFlagIMGView.contentMode = UIViewContentModeScaleAspectFit;
    [_topBGView addSubview:_topFlagIMGView];
    
    _roleTypeLabel = [[UILabel alloc]init];
    _roleTypeLabel.textColor = [UIColor colorWithHexString:@"#F7F7F7" alpha:1];
    _roleTypeLabel.font = [UIFont systemFontOfSize:12];
    _roleTypeLabel.textAlignment = NSTextAlignmentCenter;
    _roleTypeLabel.backgroundColor = [UIColor colorWithHexString:@"#0088FE" alpha:1];
    [_topBGView addSubview:_roleTypeLabel];
    
    _roleNameLabel = [[UILabel alloc]init];
    _roleNameLabel.textColor = [UIColor colorWithHexString:@"#0AC7FF" alpha:1];
    _roleNameLabel.font = [UIFont systemFontOfSize:14];
    _roleNameLabel.textAlignment = NSTextAlignmentLeft;
    [_topBGView addSubview:_roleNameLabel];
    
    NSMutableDictionary *mapper = [NSMutableDictionary new];
    for (int i = 1; i <= 20 ;i++) {
        NSString *key = [NSString stringWithFormat:@"[em2_%02d]",i];
        NSString *value = [NSString stringWithFormat:@"%03d",i];
        mapper[key] = [self imageWithName:value];
    }
    
    // 自定义表情
    YYTextSimpleEmoticonParser *parser = [YYTextSimpleEmoticonParser new];
    parser.emoticonMapper = mapper;
    
    _content = [[YYTextView alloc]initWithFrame:CGRectZero];
    _content.textColor = [UIColor colorWithHexString:@"#F7F7F7" alpha:1];
    _content.textParser = parser;
    _content.scrollEnabled = NO;
    _content.editable = NO;
    _content.allowsCopyAttributedString = NO;
    [self.contentView addSubview:_content];
    _content.hidden = YES;
    
    _contentLabel = [[YYLabel alloc]init];
    _contentLabel.textColor = [UIColor colorWithHexString:@"#F7F7F7" alpha:1];
    _contentLabel.textParser = parser;
    _contentLabel.numberOfLines = 1;
    _contentLabel.displaysAsynchronously = YES;
    _contentLabel.textVerticalAlignment = YYTextVerticalAlignmentCenter;
    [self.contentView addSubview:_contentLabel];
    
    _openView = [[UIView alloc]init];
    [self.contentView addSubview:_openView];
    _openView.hidden = YES;
    
    _openLabel = [[UILabel alloc]init];
    _openLabel.text = @"展开";
    _openLabel.textColor = [UIColor colorWithHexString:@"#FF842F" alpha:1];
    _openLabel.font = [UIFont systemFontOfSize:11];
    _openLabel.textAlignment = NSTextAlignmentCenter;
    [_openView addSubview:_openLabel];
    
    _openIMGView = [[UIImageView alloc]init];
    _openIMGView.image = [UIImage imageNamed:@"展开"];
    _openIMGView.contentMode = UIViewContentModeScaleAspectFit;
    [_openView addSubview:_openIMGView];
    
    _opentBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _opentBtn.selected = NO;
    [_openView addSubview:_opentBtn];
    [_opentBtn addTarget:self action:@selector(openBtnClick:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)configureConstraints {
    __weak typeof(self) weakSelf = self;
    CGFloat topBGViewH = 33 * SCREEN_WIDTH / 375;
    [_topBGView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(weakSelf.contentView);
        make.height.mas_equalTo(topBGViewH);
    }];
    
    CGFloat IMGW = 25 * SCREEN_WIDTH / 375;
    CGFloat IMGH = 15 * SCREEN_WIDTH / 375;
    [_topFlagIMGView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.topBGView).offset(10);
        make.top.mas_equalTo(weakSelf.topBGView).offset(9);
        make.width.mas_equalTo(IMGW);
        make.height.mas_equalTo(IMGH);
    }];
    
    CGFloat roleTypeW = 36 * SCREEN_WIDTH / 375;
    CGFloat roleTypeH = 17 * SCREEN_WIDTH / 375;
    [_roleTypeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.topFlagIMGView.mas_right).offset(5);
        make.centerY.mas_equalTo(weakSelf.topFlagIMGView.mas_centerY);
        make.width.mas_equalTo(roleTypeW);
        make.height.mas_equalTo(roleTypeH);
    }];
    _roleTypeLabel.layer.cornerRadius = roleTypeH / 2;
    _roleTypeLabel.layer.masksToBounds = YES;
    
    [_roleNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.topFlagIMGView.mas_right).offset(roleTypeW + 10);
        make.centerY.mas_equalTo(weakSelf.topFlagIMGView.mas_centerY);
        make.right.mas_lessThanOrEqualTo(weakSelf.topBGView).offset(-10);
        make.height.mas_equalTo(17);
    }];
    
    [_content mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.topBGView.mas_bottom).offset(-6);
        make.left.mas_equalTo(weakSelf.contentView).offset(6.2);
        make.right.mas_equalTo(weakSelf.contentView).offset(-5);
        make.bottom.mas_equalTo(weakSelf.contentView).offset(-25);
    }];
    
    [_contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.topBGView.mas_bottom);
        make.left.mas_equalTo(weakSelf.contentView).offset(10);
        make.right.mas_equalTo(weakSelf.contentView).offset(-5);
        make.height.mas_equalTo(20);
    }];
    
    CGFloat openViewW = 50 * SCREEN_WIDTH / 375;
    CGFloat openViewH = 17 * SCREEN_WIDTH / 375;
    [_openView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.contentView).offset(5);
        make.bottom.mas_equalTo(weakSelf.contentView).offset(-5);
        make.width.mas_equalTo(openViewW);
        make.height.mas_equalTo(openViewH);
    }];
    
    CGFloat openLabelW = 28 * SCREEN_WIDTH / 375;
    CGFloat openLabelH = 14 * SCREEN_WIDTH / 375;
    [_openLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.openView);
        make.centerY.mas_equalTo(weakSelf.openView);
        make.width.mas_equalTo(openLabelW);
        make.height.mas_equalTo(openLabelH);
    }];
    
    CGFloat openIMGW = 12 * SCREEN_WIDTH / 375;
    CGFloat openIMGH = 12 * SCREEN_WIDTH / 375;
    [_openIMGView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.openLabel.mas_right).offset(2);
        make.centerY.mas_equalTo(weakSelf.openView);
        make.width.mas_equalTo(openIMGW);
        make.height.mas_equalTo(openIMGH);
    }];
    
    [_opentBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(weakSelf.openView);
    }];
}

- (void)closeContentViewFunc {
    _openLabel.text = @"收起";
    _openIMGView.image = [UIImage imageNamed:@"收起"];
    _content.hidden = NO;
    _content.scrollEnabled = YES;
    _contentLabel.hidden = YES;
}

- (void)openContentViewFunc {
    _openLabel.text = @"展开";
    _openIMGView.image = [UIImage imageNamed:@"展开"];
    _content.hidden = YES;
    _contentLabel.hidden = NO;
    _content.scrollEnabled = NO;
}

- (void)openBtnClick:(UIButton *)sender {
    _model.isOpen = !_model.isOpen;
    if (_callBack) {
        _callBack(_model,_model.isOpen,_indexPath);
    }
}

- (CGFloat)getTextHeight:(NSString *)text maxWidth:(CGFloat)maxWidth {
    CGFloat textW = 0;
    NSMutableAttributedString *textAttri = [Utility emotionStrWithString:text y:-8];
    [textAttri addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"#FFFFFF" alpha:1] range:NSMakeRange(0, textAttri.length)];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.alignment = NSTextAlignmentLeft;
    style.minimumLineHeight = 0;
    style.maximumLineHeight = 0;
    style.lineBreakMode = NSLineBreakByCharWrapping;
    NSDictionary *dict = @{NSFontAttributeName:[UIFont systemFontOfSize:14],NSParagraphStyleAttributeName:style};
    [textAttri addAttributes:dict range:NSMakeRange(0, textAttri.length)];
    
    CGSize textSize = [textAttri boundingRectWithSize:CGSizeMake(maxWidth, CGFLOAT_MAX)
                                              options:NSStringDrawingUsesLineFragmentOrigin
                                              context:nil].size;
    textSize.height = ceilf(textSize.height);
    textW = textSize.height;
    return textW;
}

- (UIImage *)imageWithName:(NSString *)name {
//    NSBundle *bundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"EmoticonQQ" ofType:@"bundle"]];
//    //NSString *path = [bundle pathForScaledResource:name ofType:@"gif"];
//    NSData *data = [NSData dataWithContentsOfFile:path];
    UIImage *image2 = [UIImage imageNamed:name];
    NSData *data = UIImagePNGRepresentation(image2);
    YYImage *image = [YYImage imageWithData:data scale:2];
    image.preloadAllAnimatedImageFrames = YES;
    return image;
}

- (NSAttributedString *)getTextAttri:(NSString *)msg textColor:(UIColor *)textColor font:(UIFont *)font {
    NSString * textAttr = [NSString stringWithFormat:@"%@",msg];
    NSMutableAttributedString *textAttri = [[NSMutableAttributedString alloc]initWithString:textAttr];
    [textAttri addAttribute:NSForegroundColorAttributeName value:textColor range:NSMakeRange(0, textAttri.length)];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.alignment = NSTextAlignmentLeft;
    style.minimumLineHeight = 0;
    style.maximumLineHeight = 0;
    style.lineBreakMode = NSLineBreakByWordWrapping;
    NSDictionary *dict = @{NSFontAttributeName:font,NSParagraphStyleAttributeName:style};
    [textAttri addAttributes:dict range:NSMakeRange(0, textAttri.length)];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 2; // 设置行间距
    [textAttri addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, textAttri.length)];
    return textAttri;
}

@end
