//
//  HDSQuestionSelectImageCell.m
//  CCLiveCloud
//
//  Created by richard lee on 3/10/23.
//  Copyright © 2023 MacBook Pro. All rights reserved.
//

#import "HDSQuestionSelectImageCell.h"
#import "HDSQuestionSelectImageModel.h"
#import <Masonry/Masonry.h>

@interface HDSQuestionSelectImageCell ()

@property (nonatomic, strong) NSDictionary *dict;

@property (nonatomic, copy) tipsTappedClosure tipsClosure;

@property (nonatomic, copy) deleteTappedClosure deleteClosure;

@property (nonatomic, strong) UIImageView *selectImage;

@property (nonatomic, strong) UIButton *deleteBtn;

@property (nonatomic, strong) UIButton *tipsBtn;

@property (nonatomic, strong) HDSQuestionSelectImageModel *selectImageModel;

@property (nonatomic, strong) UIImageView *loadingIMG;

@end

@implementation HDSQuestionSelectImageCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self configureUI];
        [self configureConstraints];
    }
    return self;
}

- (void)setIsUploading:(BOOL)isUploading {
    _isUploading = isUploading;
    _loadingIMG.hidden = !_isUploading;
    if (_isUploading) {
        _tipsBtn.hidden = YES;
    }
    self.contentView.userInteractionEnabled = !_isUploading;
    if (_isUploading) {
        [_loadingIMG startAnimating];
    } else {
        [_loadingIMG stopAnimating];
    }
}

- (void)sourceData:(HDSQuestionSelectImageModel *)model tipsBtnTapped:(tipsTappedClosure)tipsBtnBlock deleteBtnTapped:(deleteTappedClosure)deleteBtnBlock {
    
    if (tipsBtnBlock) {
        _tipsClosure = tipsBtnBlock;
    }
    if (deleteBtnBlock) {
        _deleteClosure = deleteBtnBlock;
    }
    
    _selectImageModel = model;
    [self configureData:_selectImageModel];
}

// MARK: - Custom Method
- (void)configureUI {
    _selectImage = [[UIImageView alloc]init];
    _selectImage.contentMode = UIViewContentModeScaleAspectFill;
    [self.contentView addSubview:_selectImage];
    _selectImage.layer.masksToBounds = YES;
    
    _deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_deleteBtn setImage:[UIImage imageNamed:@"问答_关闭"] forState:UIControlStateNormal];
    [self.contentView addSubview:_deleteBtn];
    [_deleteBtn addTarget:self action:@selector(deleteBtnTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    _tipsBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_tipsBtn setImage:[UIImage imageNamed:@"注意"] forState:UIControlStateNormal];
    [self.contentView addSubview:_tipsBtn];
    _tipsBtn.hidden = YES;
    [_tipsBtn addTarget:self action:@selector(tipsBtnTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    NSMutableArray *images = [NSMutableArray array];
    for (int i = 0; i < 8; i++) {
        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"loading%d",i+1]];
        [images addObject:image];
    }
    _loadingIMG = [[UIImageView alloc]init];
    _loadingIMG.contentMode = UIViewContentModeCenter;
    _loadingIMG.animationImages = images;
    _loadingIMG.animationRepeatCount = 0;
    _loadingIMG.animationDuration = 0.35;
    _loadingIMG.hidden = YES;
    [self.contentView addSubview:_loadingIMG];
}

- (void)configureConstraints {
    __weak typeof(self) weakSelf = self;
    [_selectImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(weakSelf.contentView);
    }];
    
    [_deleteBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.mas_equalTo(weakSelf.contentView);
        make.width.height.mas_equalTo(25);
    }];
    
    [_tipsBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.right.mas_equalTo(weakSelf.contentView);
        make.width.height.mas_equalTo(25);
    }];
    
    [_loadingIMG mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(weakSelf.contentView);
    }];
}

- (void)configureData:(HDSQuestionSelectImageModel *)model {
    self.selectImage.image = model.image;
    self.tipsBtn.hidden = model.result;
}

// MARK: - Button Tapped Action
- (void)deleteBtnTapped:(UIButton *)sender {
    if (_deleteClosure) {
        _deleteClosure();
    }
}

- (void)tipsBtnTapped:(UIButton *)sender {
    if (_tipsClosure) {
        _tipsClosure(_selectImageModel.message);
    }
}

@end
