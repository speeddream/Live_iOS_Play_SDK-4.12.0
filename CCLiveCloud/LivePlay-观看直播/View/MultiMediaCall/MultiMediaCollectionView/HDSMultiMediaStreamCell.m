//
//  HDSMultiMediaStreamCell.m
//  CCLiveCloud
//
//  Created by Richard Lee on 2021/8/29.
//  Copyright © 2021 MacBook Pro. All rights reserved.
//

#import "HDSMultiMediaStreamCell.h"
#import "HDSMultiMediaCallStreamModel.h"

@interface HDSMultiMediaStreamCell ()

@property (nonatomic, strong) HDSMultiMediaCallStreamModel  *model;

@property (nonatomic, assign) NSInteger                     row;

@property (nonatomic, strong) UIImageView                   *kImageView;

@property (nonatomic, strong) UIImageView                   *bottomView;

@property (nonatomic, strong) UILabel                       *nickName;

@property (nonatomic, strong) UIView                        *hds_remoteView;

@property (nonatomic, strong) UIView                        *stremV;
 
@end

@implementation HDSMultiMediaStreamCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self customUI];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
//    self.layer.cornerRadius = 0;
//    if (SCREEN_WIDTH > SCREEN_HEIGHT) {
//        self.layer.cornerRadius = 5;
//    }
//    self.layer.masksToBounds = YES;
}


// MARK: - API
/// 设置数据
/// @param model 数据
/// @param row 当前row
- (void)setupDataWithModel:(HDSMultiMediaCallStreamModel *)model row:(NSInteger)row {
    _model = model;
    _row = row;
    
//    for (CALayer *onelayer in self.stremV.layer.sublayers) {
//        [onelayer removeFromSuperlayer];
//    }
    for (UIView *oneView in self.stremV.subviews) {
        //NSLog(@"🟡🟡⚫️⚫️⚪️⚪️ -1-> %@",self.stremV.subviews);
        //NSLog(@"🟡🟡⚫️⚫️⚪️⚪️ -2-> %zd",oneView.tag);
        if (oneView.tag == 1000+row) {
            [oneView removeFromSuperview];
        }
    }
    
    if (model.isVideoEnable) {
        self.kImageView.hidden = YES;
        self.stremV.hidden = NO;
        model.streamView.frame = CGRectMake(0, 0, 124.5, 70);
        model.streamView.tag = 1000+row;
        [self.stremV addSubview:model.streamView];
    }else {
        self.kImageView.hidden = NO;
        self.stremV.hidden = YES;
        NSString *tipImageName = model.isVideoEnable == YES ? @"mediaCall_bg" : @"mediaCall_NoCamera";
        self.kImageView.image = [UIImage imageNamed:tipImageName];
    }
    NSString *nickName = [NSString stringWithFormat:@"%@%@",model.isMyself ? @"(我)" : @"",model.nickName];
    self.self.nickName.text = nickName;
    //NSLog(@"🟡⚫️⚪️ --> 2 stremView:%@ -->_streamView.sublayer.count:%zd --> name:%@ --> model.name = %@",self.hds_remoteView.layer,self.stremV.layer.sublayers.count,self.nickName.text,model.nickName);
}

// MARK: - Custom Method
- (void)customUI {
    
    self.stremV = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 124.5, 70)];
    [self.contentView addSubview:self.stremV];
    // kImageView
    NSString *tipImageName = @"mediaCall_bg";
    self.kImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 124.5, 70)];
    self.kImageView.hidden = YES;
    self.kImageView.image = [UIImage imageNamed:tipImageName];
    [self.contentView addSubview:self.kImageView];
    
    // bottomViw
    NSString *bottomImageName = @"mediaCall_bottom";
    self.bottomView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 50, 124.5, 20)];
    self.bottomView.image = [UIImage imageNamed:bottomImageName];
    [self.contentView addSubview:self.bottomView];
    
    // nickName
    self.nickName = [[UILabel alloc]initWithFrame:CGRectMake(2, 0, 120.5, 20)];
    self.nickName.textColor = [UIColor whiteColor];
    self.nickName.font = [UIFont systemFontOfSize:12];
    [self.bottomView addSubview:self.nickName];
}

@end
