//
//  HDSToastTool.m
//  CCLiveCloud
//
//  Created by 刘强强 on 2022/3/31.
//  Copyright © 2022 MacBook Pro. All rights reserved.
//

#import "HDSToastTool.h"
#import "InformationShowView.h"
#import <Masonry/Masonry.h>

@interface HDSToastTool ()
@property(nonatomic, strong)InformationShowView *informationView;
@end

static HDSToastTool *_toatTool = nil;

@implementation HDSToastTool

+ (instancetype)shard {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _toatTool = [[HDSToastTool alloc] init];
    });
    return _toatTool;
}

- (void)showTipWithString:(NSString *)tipStr {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_informationView) {
            [_informationView removeFromSuperview];
            _informationView = nil;
        }
        _informationView = [[InformationShowView alloc]initWithLabel:tipStr];
        
        [UIApplication.sharedApplication.keyWindow addSubview:_informationView];
        [_informationView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
        }];
        [NSTimer scheduledTimerWithTimeInterval:.9f target:self selector:@selector(removeInformationView) userInfo:nil repeats:NO];
    });
}

- (void)removeInformationView {
    if (_informationView) {
        [_informationView removeFromSuperview];
        _informationView = nil;
    }
}

@end
