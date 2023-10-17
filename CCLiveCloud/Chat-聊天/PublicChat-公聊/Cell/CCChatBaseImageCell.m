//
//  CCChatBaseImageCell.m
//  CCLiveCloud
//
//  Created by Apple on 2020/6/4.
//  Copyright © 2020 MacBook Pro. All rights reserved.
//

#import "CCChatBaseImageCell.h"
#import "Utility.h"
#import "UIImage+animatedGIF.h"
#import <SDWebImage/UIButton+WebCache.h>
#import "CCChatViewDataSourceManager.h"
#import "UIColor+RCColor.h"
#import "CCcommonDefine.h"
#import "UIImageView+WebCache.h"
#import <Masonry/Masonry.h>

#define BGColor [UIColor colorWithHexString:@"#f5f5f5" alpha:1.0f]

@interface CCChatBaseImageCell ()

@property (nonatomic, strong) UIButton    *headBtn;//头像
@property (nonatomic, strong) UIImageView * imageid;//头像标识
@property (nonatomic, strong) UILabel     *contentLabel;//消息文本
@property (nonatomic, strong) UIButton    *bgBtn;//背景视图

@property (nonatomic, strong) NSOperationQueue *queue;
@property (nonatomic, strong) NSString    *userRole;//用户身份

@end

@implementation CCChatBaseImageCell

//初始化
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
//        self.backgroundColor = CCClearColor;
        self.backgroundColor = BGColor;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        for (id subView in self.contentView.subviews) {
            [subView removeFromSuperview];
        }
        [self setUpUI];
    }
    return self;
}
- (NSOperationQueue *)queue {
    if (!_queue) _queue = [[NSOperationQueue alloc] init];
    return _queue;
}
#pragma mark - 设置UI布局
-(void)setUpUI{
        
    //添加头像
    _headBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    //    _headBtn.backgroundColor = CCClearColor;
    _headBtn.backgroundColor = BGColor;
    _headBtn.layer.cornerRadius = 20;
    _headBtn.layer.masksToBounds = YES;
    [self addSubview:_headBtn];

    //添加头像标识
    _imageid= [[UIImageView alloc] init];
    [self addSubview:_imageid];

    //添加背景btn
    _bgBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self addSubview:_bgBtn];

    _contentLabel = [[UILabel alloc] init];
    _contentLabel.numberOfLines = 0;
    //    _contentLabel.backgroundColor = CCClearColor;
    _headBtn.backgroundColor = BGColor;
    _contentLabel.textColor = CCRGBColor(51,51,51);
    _contentLabel.textAlignment = NSTextAlignmentLeft;
    _contentLabel.userInteractionEnabled = NO;
    [_bgBtn addSubview:_contentLabel];

    _smallImageView = [[CCImageView alloc] init];
    [_bgBtn addSubview:_smallImageView];
}

#pragma mark - 为btn添加圆角
-(void)dealWithBtn:(UIButton *)bgBtn{
    UIImage *bgImage = nil;
    UIView * bgView = [[UIView alloc] init];
    bgView.backgroundColor = [UIColor whiteColor];
    bgView.frame = bgBtn.frame;
    //设置所需的圆角位置以及大小
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:bgView.bounds byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight | UIRectCornerTopRight cornerRadii:CGSizeMake(10, 10)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = bgView.bounds;
    maskLayer.path = maskPath.CGPath;
    bgView.layer.mask = maskLayer;
    bgImage = [self convertViewToImage:bgView];
    [bgBtn setBackgroundImage:bgImage forState:UIControlStateDisabled];
    [bgBtn setBackgroundImage:bgImage forState:UIControlStateNormal];
    bgBtn.userInteractionEnabled = YES;
}
//btn绘制方法
-(UIImage*)convertViewToImage:(UIView*)v{
    CGSize s = v.bounds.size;
    // 下面方法，第一个参数表示区域大小。第二个参数表示是否是非透明的。如果需要显示半透明效果，需要传NO，否则传YES。第三个参数就是屏幕密度了
    UIGraphicsBeginImageContextWithOptions(s, NO, [UIScreen mainScreen].scale);
    [v.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage*image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}
#pragma mark - 点击头像回调
-(void)headBtnClicked:(UIButton *)btn
{
    if ([self.userRole isEqualToString:@"student"]) {
        return;
    }
    if (_headBtnClick) {
        _headBtnClick(btn);
    }
}
#pragma mark - 加载图片cell
-(void)setImageModel:(CCPublicChatModel *)model
             isInput:(BOOL)input
           indexPath:(nonnull NSIndexPath *)indexPath{
    CGFloat height = 0;//计算气泡的高度
    CGFloat width = 0;//计算气泡的宽度
    //设置头像
    [self dealHeadBtnWithModel:model isInput:input indexPath:indexPath];
    
    //添加消息内容
    _contentLabel.attributedText = [self getTextAttri:model];
    
    height = model.textSize.height + 9 * 2;
    //判断本地是否有这张图片
    [self downloadImage:model.msg index:indexPath];
    height += model.imageSize.height;
    //----------------------------------------------------
    //计算气泡的宽度和高度
    width = model.textSize.width + 15 + 10;
    if (model.imageSize.width > width) {//计算宽度
        width = model.imageSize.width + 15 + 10;
    }
    if (width < 100) {
        width = 100;
    }
    if(height < 40) {//计算高度
        [_bgBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.headBtn.mas_right).offset(11);
            make.top.mas_equalTo(self.headBtn);
            make.size.mas_equalTo(CGSizeMake(width, 40));
        }];
    } else {
        height = model.textSize.height + 9 * 2 + model.imageSize.height;
        [_bgBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.headBtn.mas_right).offset(11);
            make.top.mas_equalTo(self.headBtn);
            make.size.mas_equalTo(CGSizeMake(width, height));
        }];
    };
    //重置文字内容的约束
    [_contentLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.bgBtn).offset(12.5);
        make.top.mas_equalTo(self.bgBtn).offset(5);
        make.size.mas_equalTo(CGSizeMake(model.textSize.width + 1, model.textSize.height + 1));
    }];
    //设置smallChatImage的约束
    [_smallImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.bgBtn).offset(12.5);
        make.top.mas_equalTo(self.contentLabel.mas_bottom).offset(5);
        make.size.mas_equalTo(model.imageSize);
    }];
    [self.bgBtn layoutIfNeeded];
    [self dealWithBtn:self.bgBtn];
}

#pragma mark - 设置用户头像
-(void)dealHeadBtnWithModel:(CCPublicChatModel *)model
           isInput:(BOOL)input
         indexPath:(NSIndexPath *)indexPath{
    self.userRole = model.userrole;
    //设置头像
    BOOL fromSelf = [model.fromuserid isEqualToString:model.myViwerId];//判断是否是自己发的
    _headBtn.tag = indexPath.row;
    if((!fromSelf || fromSelf == NO) && input) {
        [_headBtn addTarget:self action:@selector(headBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    //判断用户是否有头像，如果有,用网络头像，如果没有,用本地头像
    NSString *headerUrl = @"";
    if(StrNotEmpty(model.useravatar) && [model.useravatar containsString:@"http"]) {
        headerUrl = model.useravatar;
    }else {
        headerUrl = model.headImgName;
    }
    [_headBtn sd_setBackgroundImageWithURL:[NSURL URLWithString:headerUrl] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"lottery_icon_nor"]];
//    if(StrNotEmpty(model.useravatar) && [model.useravatar containsString:@"http"]) {
//        [self.queue addOperationWithBlock: ^{
//               NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:model.useravatar]]; //得到图像数据
//               UIImage *image = [UIImage imageWithData:imgData];
//
//               //在主线程中更新UI
//               [[NSOperationQueue mainQueue] addOperationWithBlock: ^{
//                   //通过修改模型, 来修改数据
//                   [_headBtn setBackgroundImage:image forState:UIControlStateNormal];
//                   //刷新指定表格行
////                   [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
//               }];
//           }];
//    } else {
//        [_headBtn setBackgroundImage:[UIImage imageNamed:model.headImgName] forState:UIControlStateNormal];
//    }
    [_headBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self).offset(15);
        make.top.mas_equalTo(self).offset(15);
        make.size.mas_equalTo(CGSizeMake(40,40));
    }];
    if (_headBtn) {
        [_headBtn layoutIfNeeded];
    }
    //根据身份为头像设置身份标示
    _imageid.image = [UIImage imageNamed:model.headTag];
    [_imageid mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(_headBtn);
    }];
}
#pragma mark - 设置字体
-(NSAttributedString *)getTextAttri:(CCPublicChatModel *)model{
    BOOL fromSelf = [model.fromuserid isEqualToString:model.myViwerId];//判断是否是自己发的
    UIColor *textColor = [UIColor colorWithHexString:model.textColorHexing alpha:1.f];
    if(fromSelf) {
        textColor = [UIColor colorWithHexString:@"#ff6633" alpha:1.0f];
    }
    NSMutableArray * urlArr = [self subStr:model.msg];
    NSString * textAttr = [NSString stringWithFormat:@"%@:%@",model.username,model.msg];
    if (model.typeState == 2) {//如果是图片的话,过滤掉消息
        textAttr = [NSString stringWithFormat:@"%@:", model.username];
    }
    NSMutableAttributedString *textAttri = [Utility emotionStrWithString:textAttr y:-8];
    [textAttri addAttribute:NSForegroundColorAttributeName value:CCRGBColor(51, 51, 51) range:NSMakeRange(0, textAttri.length)];

    //找出特定字符在整个字符串中的位置
    //todo  用户名为特殊字符时，算不出redRange
    if (!model.username.length) {
        model.username = @"_";
    }
    NSRange redRange = NSMakeRange([[textAttri string] rangeOfString:model.username].location, [[textAttri string] rangeOfString:model.username].length+1);
//    NSLog(@"是哪里昵称长度%@",NSStringFromRange(redRange));
    //修改特定字符的颜色
    //userName时特定表情时会崩溃  redRange会显示不确定的大小
    if (redRange.location + redRange.length < textAttri.length) {//判断取值范围是否超出长度
        [textAttri addAttribute:NSForegroundColorAttributeName value:textColor range:redRange];
    }
    //url增加颜色
    if (model.typeState != 2) {//如果是图片的话,过滤掉消息
        
        for(NSValue *value in urlArr) {
            NSRange range=[value rangeValue];
            [textAttri addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:NSMakeRange(range.location+redRange.length, range.length)];
        }
    }
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.alignment = NSTextAlignmentLeft;
    style.minimumLineHeight = 18;
    style.maximumLineHeight = 30;
    style.lineBreakMode = NSLineBreakByCharWrapping;
    NSDictionary *dict = @{NSFontAttributeName:[UIFont systemFontOfSize:FontSize_28],NSParagraphStyleAttributeName:style};
    [textAttri addAttributes:dict range:NSMakeRange(0, textAttri.length)];
    return textAttri;
}
-(NSMutableArray*)subStr:(NSString *)string {
    NSError *error;
    //可以识别url的正则表达式
    NSString *regulaStr = @"((http[s]{0,1}|ftp)://[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)|(www.[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regulaStr options:NSRegularExpressionCaseInsensitive error:&error];
    NSArray *arrayOfAllMatches = [regex matchesInString:string options:0 range:NSMakeRange(0, [string length])];
    NSMutableArray *arr=[[NSMutableArray alloc]init];
    NSMutableArray *rangeArr=[[NSMutableArray alloc]init];
    for (NSTextCheckingResult *match in arrayOfAllMatches) {
        NSString* substringForMatch = [string substringWithRange:match.range];
        [arr addObject:substringForMatch];
    }
    NSString *subStr=string;
    for (NSString *str in arr) {
        [rangeArr addObject:[self rangesOfString:str inString:subStr]];
    }
    return rangeArr;
//    UIFont *font = [UIFont systemFontOfSize:FontSize_28];
//    NSMutableAttributedString *attributedText;
//    attributedText=[[NSMutableAttributedString alloc]initWithString:subStr attributes:@{NSFontAttributeName :font}];
//    for(NSValue *value in rangeArr) {
//        NSInteger index=[rangeArr indexOfObject:value];
//        NSRange range=[value rangeValue];
//        [attributedText addAttribute:NSLinkAttributeName value:[NSURL URLWithString:[arr objectAtIndex:index]] range:range];
//        [attributedText addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:range];
//
//    }
//    return attributedText;
}

//获取查找字符串在母串中的NSRange

- (NSValue *)rangesOfString:(NSString *)searchString inString:(NSString *)str {
    NSRange searchRange = NSMakeRange(0, [str length]);
    NSRange range;
    if ((range = [str rangeOfString:searchString options:0 range:searchRange]).location != NSNotFound) {
        searchRange = NSMakeRange(NSMaxRange(range), [str length] - NSMaxRange(range));
        
    }
    return [NSValue valueWithRange:range];
}
#pragma mark - 设置图片相关设置
//返回一个处理过的图片大小
-(CGSize)getCGSizeWithImage:(UIImage *)image{
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
#pragma mark - 缓存图片
- (void)downloadImage:(NSString *)URL index:(NSIndexPath *)indexPath{
    WS(ws)
    [_smallImageView sd_setImageWithURL:[NSURL URLWithString:URL] placeholderImage:[UIImage imageNamed:@"picture_loading"] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        //判断是否已下载，if down return
        BOOL exist = [[CCChatViewDataSourceManager sharedManager] existImageWithUrl:URL];
        if (exist) {
            return;
        }
        if (error) {
            //加载失败,显示图片加载失败
            UIImage *errorImage = [UIImage imageNamed:@"picture_load_fail"];
            ws.smallImageView.image = errorImage;
            //缓存图片信息
            [[CCChatViewDataSourceManager sharedManager] updateCellHeightWithIndexPath:indexPath imageSize:errorImage.size];
        }else{
            //缓存图片信息
            [[CCChatViewDataSourceManager sharedManager] updateCellHeightWithIndexPath:indexPath imageSize:image.size];
        }
    }];
}

@end
