//
//  HDTextField.h
//  CCLiveCloud
//
//  Created by Apple on 2020/11/13.
//  Copyright © 2020 MacBook Pro. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HDTextField : UITextField
/** 左边的icon,不传则不显示 */
@property(nonatomic,copy)NSString *leftIconNameStr;
/** 左边的icon高亮 */
@property(nonatomic,copy)NSString *leftHighlightedIconNameStr;
/** 控制当在编辑时，是否高亮文本框的Border,默认是YES */
@property(nonatomic,assign)BOOL isChangeBorder;
/** 默认边框颜色 */
@property(nonatomic,copy)UIColor *defaultBorderColor;
/** 默认边框宽度 */
@property(nonatomic,assign)CGFloat defaultBorderWidth;
/** 编辑时边框颜色 */
@property(nonatomic,copy)UIColor *selectBorderColor;
/** 占位文本的颜色 */
@property(nonatomic,copy)UIColor *placeholderColor;
/** 最多输入长度 */
@property(nonatomic,assign)int maxTextLength;
@end

NS_ASSUME_NONNULL_END
