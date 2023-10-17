//
//  HDSLiveStreamOtherTopChatCell.m
//  CCLiveCloud
//
//  Created by richard lee on 1/30/23.
//  Copyright © 2023 MacBook Pro. All rights reserved.
//

#import "HDSLiveStreamOtherTopChatCell.h"
#import "Utility.h"
#import "HDSLiveTopChatModel+BaseModel.h"
#import "UIColor+RCColor.h"
#import "CCcommonDefine.h"
#import <YYText/YYText.h>
#import <YYImage/YYImage.h>
#import "UIImageView+Extension.h"
#import <Masonry/Masonry.h>

@interface HDSLiveStreamOtherTopChatCell ()

@property (nonatomic, strong) UIImageView *topIMGView;

@property (nonatomic, strong) UIImageView *headerIMGView;

@property (nonatomic, strong) UILabel *roleNameLabel;

@property (nonatomic, strong) UILabel *numberLabel;

@property (nonatomic, strong) YYTextView *content;

@property (nonatomic, strong) YYLabel *contentLabel;

@property (nonatomic, strong) UIView *openView;

@property (nonatomic, strong) UILabel *openLabel;

//@property (nonatomic, strong) UIImageView *openIMGView;

@property (nonatomic, strong) UIButton *opentBtn;

@end

@implementation HDSLiveStreamOtherTopChatCell

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

- (void)setTotalNum:(CGFloat)totalNum {
    _totalNum = totalNum;
}

- (void)setIndexPath:(NSIndexPath *)indexPath {
    _indexPath = indexPath;
}

- (void)setCallBack:(btnTapBlock)callBack {
    _callBack = callBack;
}

- (void)setModel:(HDSLiveTopChatModel *)model {
    _model = model;
    if (_model.isOpen) {
        [self closeContentViewFunc];
    } else {
        [self openContentViewFunc];
    }
    [_headerIMGView setHeader:_model.fromViewerAvatar];
    _roleNameLabel.text = model.fromViewerName;
    CGFloat collectionViewW = SCREEN_WIDTH - 60;
    CGFloat contentW = [self getTextHeight:model.content maxWidth:collectionViewW];
    
    self.openView.hidden = YES;
    if (contentW > 27.0) {
        self.openView.hidden = NO;
    }
    
    _numberLabel.text = [NSString stringWithFormat:@"%ld/%ld",(long)_indexPath.row + 1,(long)_totalNum + 1];
    _contentLabel.attributedText = [self getTextAttri:model.content textColor:[UIColor colorWithHexString:@"#000000" alpha:1] font:[UIFont systemFontOfSize:14]];
    _content.attributedText = [self getTextAttri:model.content textColor:[UIColor colorWithHexString:@"#000000" alpha:1] font:[UIFont systemFontOfSize:14]];
}

// MARK: - Custom Method
- (void)configureUI {
    
    _topIMGView = [[UIImageView alloc]init];
    _topIMGView.image = [UIImage imageNamed:@"top_2"];
    [self.contentView addSubview:_topIMGView];
    
    _headerIMGView = [[UIImageView alloc]init];
    [self.contentView addSubview:_headerIMGView];
    
    _roleNameLabel = [[UILabel alloc]init];
    _roleNameLabel.textColor = [UIColor colorWithHexString:@"#FF842F" alpha:1];
    _roleNameLabel.font = [UIFont systemFontOfSize:14];
    [self.contentView addSubview:_roleNameLabel];
    
    _numberLabel = [[UILabel alloc]init];
    _numberLabel.textColor = [UIColor colorWithHexString:@"#000000" alpha:1];
    _numberLabel.font = [UIFont systemFontOfSize:14];
    _numberLabel.textAlignment = NSTextAlignmentRight;
    [self.contentView addSubview:_numberLabel];
    _numberLabel.layer.opacity = 0.45;
    
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
    _content.textColor = [UIColor colorWithHexString:@"#000000" alpha:1];
    _content.textParser = parser;
    _content.scrollEnabled = NO;
    _content.editable = NO;
    _content.allowsCopyAttributedString = NO;
    [self.contentView addSubview:_content];
    _content.layer.opacity = 0.9;
    _content.hidden = YES;
    
    _contentLabel = [[YYLabel alloc]init];
    _contentLabel.textColor = [UIColor colorWithHexString:@"#000000" alpha:1];
    _contentLabel.textParser = parser;
    _contentLabel.numberOfLines = 1;
    _contentLabel.displaysAsynchronously = YES;
    _contentLabel.textVerticalAlignment = YYTextVerticalAlignmentCenter;
    [self.contentView addSubview:_contentLabel];
    _contentLabel.layer.opacity = 0.9;
    
    _openView = [[UIView alloc]init];
    [self.contentView addSubview:_openView];
    _openView.hidden = YES;
    
    _openLabel = [[UILabel alloc]init];
    _openLabel.text = @"展开";
    _openLabel.textColor = [UIColor colorWithHexString:@"#FF842F" alpha:1];
    _openLabel.font = [UIFont systemFontOfSize:11];
    _openLabel.textAlignment = NSTextAlignmentCenter;
    [_openView addSubview:_openLabel];
    
//    _openIMGView = [[UIImageView alloc]init];
//    _openIMGView.image = [UIImage imageNamed:@"展开"];
//    _openIMGView.contentMode = UIViewContentModeScaleAspectFit;
//    [_openView addSubview:_openIMGView];
    
    _opentBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _opentBtn.selected = NO;
    [_openView addSubview:_opentBtn];
    [_opentBtn addTarget:self action:@selector(openBtnClick:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)configureConstraints {
    
    __weak typeof(self) weakSelf = self;
    [_topIMGView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.contentView).offset(14.5);
        make.left.mas_equalTo(weakSelf.contentView).offset(5);
        make.width.mas_equalTo(25);
        make.height.mas_equalTo(15);
    }];
    
    [_headerIMGView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.topIMGView.mas_right).offset(5);
        make.centerY.mas_equalTo(weakSelf.topIMGView.mas_centerY);
        make.width.height.mas_equalTo(20);
    }];
    _headerIMGView.layer.cornerRadius = 10.f;
    _headerIMGView.layer.masksToBounds = YES;
    
    [_roleNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.headerIMGView.mas_right).offset(5);
        make.centerY.mas_equalTo(weakSelf.topIMGView.mas_centerY);
        make.right.mas_lessThanOrEqualTo(weakSelf.numberLabel.mas_left).offset(-5);
    }];
    
    [_numberLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(weakSelf.contentView).offset(-5);
        make.centerY.mas_equalTo(weakSelf.roleNameLabel.mas_centerY);
        make.width.mas_equalTo(30);
        make.height.mas_equalTo(17);
    }];
    
    [_contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.headerIMGView.mas_bottom).offset(8);
        make.left.mas_equalTo(weakSelf.contentView).offset(5);
        make.right.mas_equalTo(weakSelf.contentView).offset(-5);
    }];
    
    [_content mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.headerIMGView.mas_bottom).offset(-3);
        make.left.mas_equalTo(weakSelf.contentView).offset(3.1);
        make.right.mas_equalTo(weakSelf.contentView).offset(-5);
        make.bottom.mas_equalTo(weakSelf.contentView).offset(-30);
    }];
    
    CGFloat openViewW = 50 * SCREEN_WIDTH / 375;
    CGFloat openViewH = 17 * SCREEN_WIDTH / 375;
    [_openView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.contentView).offset(5);
        make.bottom.mas_equalTo(weakSelf.contentView).offset(-3);
        make.width.mas_equalTo(openViewW);
        make.height.mas_equalTo(openViewH);
    }];
    
    CGFloat openLabelW = 28 * SCREEN_WIDTH / 375;
    CGFloat openLabelH = 14 * SCREEN_WIDTH / 375;
    [_openLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.openView).offset(5);
        make.centerY.mas_equalTo(weakSelf.openView);
        make.width.mas_equalTo(openLabelW);
        make.height.mas_equalTo(openLabelH);
    }];
    
//    CGFloat openIMGW = 12 * SCREEN_WIDTH / 375;
//    CGFloat openIMGH = 12 * SCREEN_WIDTH / 375;
//    [_openIMGView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.mas_equalTo(weakSelf.openLabel.mas_right).offset(2);
//        make.centerY.mas_equalTo(weakSelf.openView);
//        make.width.mas_equalTo(openIMGW);
//        make.height.mas_equalTo(openIMGH);
//    }];
    
    [_opentBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(weakSelf.openView);
    }];
}

- (void)closeContentViewFunc {
    _openLabel.text = @"收起";
    _content.hidden = NO;
    _content.scrollEnabled = YES;
    _contentLabel.hidden = YES;
}

- (void)openContentViewFunc {
    _openLabel.text = @"展开";
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
