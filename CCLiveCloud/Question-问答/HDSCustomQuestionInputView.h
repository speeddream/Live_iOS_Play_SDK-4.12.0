//
//  HDSCustomQuestionInputView.h
//  HDTABC
//
//  Created by richard lee on 3/6/23.
//

#import <UIKit/UIKit.h>
#import "HDSCustomTextView.h"
NS_ASSUME_NONNULL_BEGIN
typedef void(^kBtnsTappedBlock)(int tag);
typedef void(^kUpdateInputViewHeight)(CGFloat height);
typedef void(^kCallBackMessage)(NSString *message);

@protocol HDSCustomQuestionInputViewDelegate <NSObject>

- (void)onTipsCallBack:(NSString *)tipString;

@end


@interface HDSCustomQuestionInputView : UIView

/// 是否可编辑
@property (nonatomic, assign) BOOL isEdit;
/// 是否允许添加图片
@property (nonatomic, assign) BOOL allowAddImage;
/// 清空
@property (nonatomic, assign) BOOL isClean;
/// 已添加全部
@property (nonatomic, assign) BOOL isAllAdded;
/// 输入框
@property (nonatomic, strong) HDSCustomTextView *textView;

/// 代理
@property (nonatomic, weak) id<HDSCustomQuestionInputViewDelegate>delegate;

/// 初始化输入视图
/// - Parameters:
///   - frame: 布局
///   - btnsTappedClosure: 按钮点击回调
///   - heightChangeClosure 高度改变回调
///   - callBackMessageClosure 回调输入信息回调
- (instancetype)initWithFrame:(CGRect)frame
            btnsTappedClosure:(kBtnsTappedBlock)btnsTappedClosure
        updateInputViewHeight:(kUpdateInputViewHeight)heightChangeClosure
              callBackMessage:(kCallBackMessage)callBackMessageClosure;

@end

NS_ASSUME_NONNULL_END
