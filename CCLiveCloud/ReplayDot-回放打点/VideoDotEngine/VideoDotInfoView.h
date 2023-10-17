//
//  DotInfoView.h
//  swiftIJK
//
//  Created by david on 2021/3/1.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef void(^PlayTapClosure)(void);

@interface VideoDotInfoView : UIView
- (instancetype)initWithFrame:(CGRect)frame
   arrowPointOffset:(CGFloat)arrowPointOffSet
               text:(NSString *)text
       playBTNImage:(UIImage *)playBTNImg
               playTapClosure:(PlayTapClosure)closure;
@end

NS_ASSUME_NONNULL_END
