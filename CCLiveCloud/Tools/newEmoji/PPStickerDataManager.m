//
//  PPStickerDataManager.m
//  PPStickerKeyboard
//
//  Created by Vernon on 2018/1/17.
//  Copyright © 2018年 Vernon. All rights reserved.
//

#import "PPStickerDataManager.h"
#import "PPSticker.h"
#import "PPUtil.h"

@interface PPStickerMatchingResult : NSObject
@property (nonatomic, assign) NSRange range;                    // 匹配到的表情包文本的range
@property (nonatomic, strong) UIImage *emojiImage;              // 如果能在本地找到emoji的图片，则此值不为空
@property (nonatomic, strong) NSString *showingDescription;     // 表情的实际文本(形如：[哈哈])，不为空
@end

@implementation PPStickerMatchingResult
@end

@interface PPStickerDataManager ()
@property (nonatomic, strong, readwrite) NSArray<PPSticker *> *allStickers;

@property(nonatomic,strong,readwrite) NSArray<PPSticker *> *stickersDefault;
@property(nonatomic,strong,readwrite) NSArray<PPSticker *> *stickersCustom;
@property(nonatomic,assign)BOOL isDefaultStickersInUse;
@end

@implementation PPStickerDataManager

+ (instancetype)sharedInstance
{
    static PPStickerDataManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[PPStickerDataManager alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init
{
    if (self = [super init]) {
        _isDefaultStickersInUse = YES;
        [self initStickers];
    }
    return self;
}

- (void)initStickers
{
    _isDefaultStickersInUse = YES;
    NSString *path = [NSBundle.mainBundle pathForResource:@"Emotions" ofType:@"plist"];
    if (!path) {
        return;
    }

    NSArray *array = [[NSArray alloc] initWithContentsOfFile:path];
    NSMutableArray<PPSticker *> *stickers = [[NSMutableArray alloc] init];
    for (NSDictionary *stickerDict in array) {
        PPSticker *sticker = [[PPSticker alloc] init];
        sticker.coverImageName = stickerDict[@"cover_pic"];
        NSArray *emojiArr = stickerDict[@"emoticons"];
        NSMutableArray<PPEmoji *> *emojis = [[NSMutableArray alloc] init];
        for (NSDictionary *emojiDict in emojiArr) {
            PPEmoji *emoji = [[PPEmoji alloc] init];
            emoji.imageName = emojiDict[@"image"];
            emoji.emojiDescription = emojiDict[@"text"];
            emoji.imageTag = emojiDict[@"imageTag"];
            [emojis addObject:emoji];
        }
        sticker.emojis = emojis;
        [stickers addObject:sticker];
    }
    self.allStickers = stickers;
    _stickersDefault = stickers;
}

#pragma mark - public method

- (void)replaceEmojiForAttributedString:(NSMutableAttributedString *)attributedString font:(UIFont *)font
{
    if (!attributedString || !attributedString.length || !font) {
        return;
    }

    NSArray<PPStickerMatchingResult *> *matchingResults = [self matchingEmojiForString:attributedString.string];

    if (matchingResults && matchingResults.count) {
        NSUInteger offset = 0;
        for (PPStickerMatchingResult *result in matchingResults) {
            if (result.emojiImage) {
                CGFloat emojiHeight = font.lineHeight;
                NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
                attachment.image = result.emojiImage;
                //attachment.bounds = CGRectMake(0, font.descender, emojiHeight, emojiHeight);
                attachment.lineLayoutPadding = 2;
                int space = 0;
                if (@available(iOS 15.0, *)) {
                  // code to run when on iOS 11+ and some_condition is true
                    space = 4;
                }
                attachment.bounds = CGRectMake(0, font.descender, emojiHeight + space, emojiHeight);
                NSMutableAttributedString *emojiAttributedString = [[NSMutableAttributedString alloc] initWithAttributedString:[NSAttributedString attributedStringWithAttachment:attachment]];
                [emojiAttributedString pp_setTextBackedString:[PPTextBackedString stringWithString:result.showingDescription] range:NSMakeRange(0, emojiAttributedString.length)];
                if (!emojiAttributedString) {
                    continue;
                }
                NSRange actualRange = NSMakeRange(result.range.location - offset, result.showingDescription.length);
                [attributedString replaceCharactersInRange:actualRange withAttributedString:emojiAttributedString];
                offset += result.showingDescription.length - emojiAttributedString.length;
            }
        }
    }
}

#pragma mark - private method

- (NSArray<PPStickerMatchingResult *> *)matchingEmojiForString:(NSString *)string
{
    if (!string.length) {
        return nil;
    }
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\[.+?\\]" options:0 error:NULL];
    NSArray<NSTextCheckingResult *> *results = [regex matchesInString:string options:0 range:NSMakeRange(0, string.length)];
    if (results && results.count) {
        NSMutableArray *emojiMatchingResults = [[NSMutableArray alloc] init];
        for (NSTextCheckingResult *result in results) {
            NSString *showingDescription = [string substringWithRange:result.range];
            NSString *emojiSubString = showingDescription;
            if([emojiSubString containsString:@"[em2_"]) {
                emojiSubString = [showingDescription substringFromIndex:1];       // 去掉[
                emojiSubString = [emojiSubString substringWithRange:NSMakeRange(0, emojiSubString.length - 1)];    // 去掉]
            }
//            PPEmoji *emoji = [self emojiWithEmojiDescription:emojiSubString];
            PPEmoji *emoji = [self emojiWithEmojiImageTag:emojiSubString];
            if (emoji) {
                PPStickerMatchingResult *emojiMatchingResult = [[PPStickerMatchingResult alloc] init];
                emojiMatchingResult.range = result.range;
                emojiMatchingResult.showingDescription = showingDescription;
                emojiMatchingResult.emojiImage = [Utility emojiFromEmojiName:emoji.imageName];
                [emojiMatchingResults addObject:emojiMatchingResult];
            }
        }
        return emojiMatchingResults;
    }
    return nil;
}

- (PPEmoji *)emojiWithEmojiDescription:(NSString *)emojiDescription
{
    for (PPSticker *sticker in self.allStickers) {
        for (PPEmoji *emoji in sticker.emojis) {
            if ([emoji.emojiDescription isEqualToString:emojiDescription]) {
                return emoji;
            }
        }
    }
    NSArray *sticks = _isDefaultStickersInUse ? _stickersCustom : _stickersDefault;
    for (PPSticker *sticker in sticks) {
        for (PPEmoji *emoji in sticker.emojis) {
            if ([emoji.emojiDescription isEqualToString:emojiDescription]) {
                return emoji;
            }
        }
    }
    return nil;
}
- (PPEmoji *)emojiWithEmojiImageName:(NSString *)imageName
{
    for (PPSticker *sticker in self.allStickers) {
        for (PPEmoji *emoji in sticker.emojis) {
            if ([emoji.imageName isEqualToString:imageName]) {
                return emoji;
            }
        }
    }
    NSArray *sticks = _isDefaultStickersInUse ? _stickersCustom : _stickersDefault;
    for (PPSticker *sticker in sticks) {
        for (PPEmoji *emoji in sticker.emojis) {
            if ([emoji.imageName isEqualToString:imageName]) {
                return emoji;
            }
        }
    }
    return nil;
}
- (PPEmoji *)emojiWithEmojiImageTag:(NSString *)imageName
{
    for (PPSticker *sticker in self.allStickers) {
        for (PPEmoji *emoji in sticker.emojis) {
            if ([emoji.imageTag isEqualToString:imageName]) {
                return emoji;
            }
        }
    }
    NSArray *sticks = _isDefaultStickersInUse ? _stickersCustom : _stickersDefault;
    for (PPSticker *sticker in sticks) {
        for (PPEmoji *emoji in sticker.emojis) {
            if ([emoji.imageTag isEqualToString:imageName]) {
                return emoji;
            }
        }
    }
    return [self emojiWithEmojiImageName:imageName];
}

- (void)reloadEmojisDefault {
    [self initStickers];
}

- (void)reloadEmojisCustom:(NSArray *)emojisInfo {
    _isDefaultStickersInUse = NO;

    NSArray *array = emojisInfo;
    NSMutableArray<PPSticker *> *stickers = [[NSMutableArray alloc] init];
    PPSticker *sticker = [[PPSticker alloc] init];
    sticker.coverImageName = @"custom_1";
    NSArray *emojiArr = array;
    NSMutableArray<PPEmoji *> *emojis = [[NSMutableArray alloc] init];
    for (NSDictionary *emojiDict in emojiArr) {
        PPEmoji *emoji = [[PPEmoji alloc] init];
        emoji.imageName = emojiDict[@"name"];
        emoji.emojiDescription = emojiDict[@"name"];
        emoji.imageTag = emojiDict[@"img"];

        [emojis addObject:emoji];
    }
    sticker.emojis = emojis;
    [stickers addObject:sticker];

    
    self.allStickers = stickers;
    _stickersCustom = stickers;
}
@end
