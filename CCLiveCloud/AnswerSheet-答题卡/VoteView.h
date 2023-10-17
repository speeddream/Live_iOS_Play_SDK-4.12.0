//
//  VoteView.h
//  CCLiveCloud
//
//  Created by MacBook Pro on 2018/12/25.
//  Copyright © 2018 MacBook Pro. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^VoteBtnClickedSingle)(NSInteger index);//单选回调

typedef void(^VoteBtnClickedMultiple)(NSMutableArray *indexArray);//多选数组回调

typedef void(^VoteBtnClickedSingleNOSubmit)(NSInteger index);//单选不发布回调

typedef void(^VoteBtnClickedMultipleNOSubmit)(NSMutableArray *indexArray);//多选不发布回调

@interface VoteView : UIView

@property (nonatomic, copy)void(^cleanBlock)(BOOL result);//收起按钮回调

@property (nonatomic, copy)void(^closeBlock)(BOOL result);//关闭按钮回调
/**
 初始化方法

 @param count count
 @param single 是否是单选
 @param voteSingleBlock 单选回调
 @param voteMultipleBlock 多选回调
 @param singleNOSubmit 单选不发布回调
 @param multipleNOSubmit 多选不发布回调
 @param isScreenLandScape 是否是全屏
 @return self
 */
-(instancetype) initWithCount:(NSInteger)count
              singleSelection:(BOOL)single
              voteSingleBlock:(VoteBtnClickedSingle)voteSingleBlock
            voteMultipleBlock:(VoteBtnClickedMultiple)voteMultipleBlock
               singleNOSubmit:(VoteBtnClickedSingleNOSubmit)singleNOSubmit
             multipleNOSubmit:(VoteBtnClickedMultipleNOSubmit)multipleNOSubmit
            isScreenLandScape:(BOOL)isScreenLandScape;

- (void)show;

- (void)updateUIWithScreenLandScape:(BOOL)isScreenLandScape;

@end
