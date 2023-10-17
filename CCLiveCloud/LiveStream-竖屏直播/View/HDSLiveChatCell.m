//
//  HDSLiveChatCell.m
//  CCLiveCloud
//
//  Created by Apple on 2022/5/10.
//  Copyright © 2022 MacBook Pro. All rights reserved.
//

#import "HDSLiveChatCell.h"
#import "HDSChatDataModel.h"
#import "Utility.h"
#import "UIColor+RCColor.h"
#import "CCcommonDefine.h"
#import <YYText/YYText.h>
#import <YYImage/YYImage.h>
#import <Masonry/Masonry.h>

@interface HDSLiveChatCell ()

@property (nonatomic, strong) UILabel                   *roleType;

@property (nonatomic, strong) UILabel                   *userName;

@property (nonatomic, strong) YYLabel                   *content;

@property (nonatomic, strong) NSString                  *URL;

@property (nonatomic, strong) NSArray                   *urlArr;

@end

@implementation HDSLiveChatCell

// MARK: - API
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = UIColor.clearColor;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self customUI];
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
}

- (void)setModel:(HDSChatDataModel *)model {
    _model = model;
    
    _userName.frame = CGRectMake(0, 0, model.nameWidth, 18);
    NSString *userNameStr = model.userName;
    if (userNameStr.length > 8) {
        userNameStr = [userNameStr substringToIndex:7];
        userNameStr = [NSString stringWithFormat:@"%@...",userNameStr];
    }

    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:@""];
    
    if ([model.roleType isEqualToString:@"讲师"]) {
        // 设置角色
        _roleType.text = model.roleType;
        _roleType.backgroundColor = [UIColor colorWithHexString:@"#FF842F" alpha:0.8];
        // 添加富文本
        NSAttributedString *topAttr = [NSAttributedString yy_attachmentStringWithContent:_roleType contentMode:UIViewContentModeScaleAspectFit attachmentSize:CGSizeMake(_roleType.frame.size.width + 4, _roleType.frame.size.height) alignToFont:_content.font alignment:YYTextVerticalAlignmentCenter];
        [attrStr insertAttributedString:topAttr atIndex:0];
        // 设置昵称
        _userName.text = [NSString stringWithFormat:@"%@:",userNameStr];
        _userName.textColor = [UIColor colorWithHexString:@"#FF842F" alpha:1];
        
        NSAttributedString *nameAttr = [NSAttributedString yy_attachmentStringWithContent:_userName contentMode:UIViewContentModeScaleAspectFit attachmentSize:CGSizeMake(_userName.frame.size.width + 4, _userName.frame.size.height) alignToFont:_content.font alignment:YYTextVerticalAlignmentCenter];
        [attrStr insertAttributedString:nameAttr atIndex:1];
        
    } else if ([model.roleType isEqualToString:@"助教"]) {
        // 设置角色
        _roleType.text = model.roleType;
        _roleType.backgroundColor = [UIColor colorWithHexString:@"#0088FE" alpha:0.8];
        // 设置昵称
        _userName.text = [NSString stringWithFormat:@"%@:",userNameStr];
        _userName.textColor = [UIColor colorWithHexString:@"#0AC7FF" alpha:1];
        
        // 添加富文本
        NSAttributedString *topAttr = [NSAttributedString yy_attachmentStringWithContent:_roleType contentMode:UIViewContentModeScaleAspectFit attachmentSize:CGSizeMake(_roleType.frame.size.width + 4, _roleType.frame.size.height) alignToFont:_content.font alignment:YYTextVerticalAlignmentCenter];
        [attrStr insertAttributedString:topAttr atIndex:0];
        
        NSAttributedString *nameAttr = [NSAttributedString yy_attachmentStringWithContent:_userName contentMode:UIViewContentModeScaleAspectFit attachmentSize:CGSizeMake(_userName.frame.size.width+4, _userName.frame.size.height) alignToFont:_content.font alignment:YYTextVerticalAlignmentCenter];
        [attrStr insertAttributedString:nameAttr atIndex:1];
                
    } else if ([model.roleType isEqualToString:@"主持"]) {
        
        // 设置角色
        _roleType.text = model.roleType;
        _roleType.backgroundColor = [UIColor colorWithHexString:@"#1BBD79" alpha:0.8];
        
        // 设置昵称
        _userName.text = [NSString stringWithFormat:@"%@:",userNameStr];
        _userName.textColor = [UIColor colorWithHexString:@"#1BBD79" alpha:1];
        
        // 添加富文本
        NSAttributedString *topAttr = [NSAttributedString yy_attachmentStringWithContent:_roleType contentMode:UIViewContentModeScaleAspectFit attachmentSize:CGSizeMake(_roleType.frame.size.width + 4, _roleType.frame.size.height) alignToFont:_content.font alignment:YYTextVerticalAlignmentCenter];
        [attrStr insertAttributedString:topAttr atIndex:0];
        
        NSAttributedString *nameAttr = [NSAttributedString yy_attachmentStringWithContent:_userName contentMode:UIViewContentModeScaleAspectFit attachmentSize:CGSizeMake(_userName.frame.size.width+4, _userName.frame.size.height) alignToFont:_content.font alignment:YYTextVerticalAlignmentCenter];
        [attrStr insertAttributedString:nameAttr atIndex:1];
        
    } else if ([model.roleType isEqualToString:@"广播"]) {
        
        NSString *boardCast = [NSString stringWithFormat:@"系统消息:%@",model.msg];
        [attrStr appendAttributedString:[self getTextAttri:boardCast textColor:[UIColor colorWithHexString:@"#FF842F" alpha:1] font:[UIFont systemFontOfSize:13]]];
        _content.attributedText = attrStr;
        return;
        
    } else {
        
        if (model.isMyself) {
            _userName.text = [NSString stringWithFormat:@"%@(我):",userNameStr];
        } else {
            _userName.text = [NSString stringWithFormat:@"%@:",userNameStr];
        }
        _userName.textColor = [UIColor colorWithHexString:@"#FFDD99" alpha:1];
        NSAttributedString *nameAttr = [NSAttributedString yy_attachmentStringWithContent:_userName contentMode:UIViewContentModeScaleAspectFit attachmentSize:CGSizeMake(_userName.frame.size.width+4, _userName.frame.size.height) alignToFont:_content.font alignment:YYTextVerticalAlignmentCenter];
        [attrStr insertAttributedString:nameAttr atIndex:0];
    }
    
    // 处理聊天中的URL
    __weak typeof(self) weakSelf = self;
    if([self isURL:model.msg]) {
        self.URL = model.msg;
        NSMutableAttributedString *one = [[NSMutableAttributedString alloc] initWithString:self.URL];
        one.yy_font = [UIFont systemFontOfSize:14];
        [one yy_setTextHighlightRange:one.yy_rangeOfAll
                                color:[UIColor colorWithRed:0.093 green:0.492 blue:1.000 alpha:1.000]
                      backgroundColor:UIColor.clearColor
                            tapAction:^(UIView *containerView, NSAttributedString *text, NSRange range, CGRect rect) {
            NSLog(@"点击URL");
            [weakSelf labelTouchUpInside];
        }];
        
        [attrStr appendAttributedString:one];
        _content.attributedText = attrStr;
        return;
    } else {
        self.urlArr = [self getURLFromStr:model.msg];
        if (self.urlArr.count > 0) {
            self.URL = self.urlArr[0];
            NSMutableAttributedString *one = [[NSMutableAttributedString alloc] initWithString:model.msg];
            one.yy_color = [UIColor colorWithHexString:@"#FFFFFF" alpha:1];
            one.yy_font = [UIFont systemFontOfSize:14];
            NSRange range = [model.msg rangeOfString:self.URL];
            [one yy_setTextHighlightRange:range
                                    color:[UIColor colorWithRed:0.093 green:0.492 blue:1.000 alpha:1.000]
                          backgroundColor:UIColor.clearColor
                                tapAction:^(UIView *containerView, NSAttributedString *text, NSRange range, CGRect rect) {
                NSLog(@"点击URL");
                [weakSelf labelTouchUpInside];
            }];
            
            [attrStr appendAttributedString:one];
            _content.attributedText = attrStr;
            return;
        }
    }
    
    [attrStr appendAttributedString:[self getTextAttri:model.msg textColor:[UIColor colorWithHexString:@"#FFFFFF" alpha:1] font:[UIFont systemFontOfSize:14]]];
    attrStr.yy_lineSpacing = 2;
    _content.attributedText = attrStr;
}

// MARK: - Custom Method
- (void)customUI {
    
    _backView = [[UIView alloc]initWithFrame:CGRectZero];
    _backView.backgroundColor = [UIColor colorWithHexString:@"#000000" alpha:0.4];
    [self.contentView addSubview:_backView];
    
    __weak typeof(self) weakSelf = self;
    [_backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.contentView).offset(2);
        make.left.mas_equalTo(weakSelf.contentView).offset(5);
        make.bottom.mas_equalTo(weakSelf.contentView).offset(-2);
        make.right.mas_lessThanOrEqualTo(-5);
    }];
    _backView.layer.cornerRadius = 14;
    _backView.layer.masksToBounds = YES;
    
    NSMutableDictionary *mapper = [NSMutableDictionary new];
    for (int i = 1; i <= 20 ;i++) {
        NSString *key = [NSString stringWithFormat:@"[em2_%02d]",i];
        NSString *value = [NSString stringWithFormat:@"%03d",i];
        mapper[key] = [self imageWithName:value];
    }
    
    // 自定义表情
    YYTextSimpleEmoticonParser *parser = [YYTextSimpleEmoticonParser new];
    parser.emoticonMapper = mapper;
    
    _content = [[YYLabel alloc]init];
    _content.textAlignment = NSTextAlignmentLeft;
    _content.font = [UIFont systemFontOfSize:14];
    _content.textColor = UIColor.whiteColor;
    _content.textParser = parser;
    _content.lineBreakMode = NSLineBreakByCharWrapping;
    _content.displaysAsynchronously = YES; /// enable async display
    _content.textVerticalAlignment = YYTextVerticalAlignmentTop;
    _content.preferredMaxLayoutWidth = SCREEN_WIDTH - 70;
    _content.numberOfLines = 0;
    [self.backView addSubview:_content];
    
    [_content mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.backView).offset(5);
        make.left.mas_equalTo(weakSelf.backView).offset(10);
        make.bottom.mas_equalTo(weakSelf.backView).offset(-5);
        make.right.mas_equalTo(weakSelf.backView).offset(-10);
    }];
    
    _roleType = [[UILabel alloc]init];
    _roleType.textColor = UIColor.whiteColor;
    _roleType.textAlignment = NSTextAlignmentCenter;
    _roleType.font = [UIFont systemFontOfSize:12];
    _roleType.frame = CGRectMake(0, 0, 36, 17);
    _roleType.layer.cornerRadius = 8.5;
    _roleType.layer.masksToBounds = YES;
    
    _userName = [[UILabel alloc]init];
    _userName.textAlignment = NSTextAlignmentLeft;
    _userName.textColor = [UIColor colorWithHexString:@"#FFDD99" alpha:1];
    _userName.font = [UIFont systemFontOfSize:14];
    _userName.numberOfLines = 1;
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
    style.lineBreakMode = NSLineBreakByCharWrapping;
    NSDictionary *dict = @{NSFontAttributeName:font,NSParagraphStyleAttributeName:style};
    [textAttri addAttributes:dict range:NSMakeRange(0, textAttri.length)];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 2; // 设置行间距
    paragraphStyle.alignment = NSTextAlignmentJustified;
    [textAttri addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, textAttri.length)];
    return textAttri;
}

-(void)labelTouchUpInside {
    if ([self isURL:self.URL] == YES) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.URL] options:nil completionHandler:^(BOOL success) {
            
        }];
    }
}

- (BOOL)isURL:(NSString *)url {
    if ([[url lowercaseString] hasPrefix:@"http"] == YES || [[url lowercaseString] hasPrefix:@"https"] == YES) {
        return YES;
    } else {
        return NO;
    }
}

- (NSArray*)getURLFromStr:(NSString *)string { NSError *error; //可以识别url的正则表达式
    NSString *regulaStr = @"((http[s]{0,1}|ftp)://[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)|(www.[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regulaStr options:NSRegularExpressionCaseInsensitive error:&error];
    NSArray *arrayOfAllMatches = [regex matchesInString:string options:0 range:NSMakeRange(0, [string length])];
    //NSString *subStr;
    NSMutableArray *arr=[[NSMutableArray alloc] init];
    for (NSTextCheckingResult *match in arrayOfAllMatches){ NSString* substringForMatch;
        substringForMatch = [string substringWithRange:match.range];
        [arr addObject:substringForMatch];
    }
    return arr;
}

@end
