//
//  VideoDotEngine.h
//  swiftIJK
//
//  Created by david on 2021/3/1.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "VideoDotInfo.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^SeekClosure)(int time);

typedef void(^IsShowClosure)(BOOL isShow);

@interface VideoDotEngine : NSObject

/**
 dots:              dot info VideoDotInfo array
 seekBTNImage:      info view play button image
 starX:             your slider frame origin x
 endX:              your slider frame origin x + slider' width
 axisY:             your slider center y
 totalTime:         video total time seconds
 seekClosure:       info view play button closure
 */

- (instancetype)initWithDots:(NSArray *)info
          seekBTNImg:(UIImage *)img
           boardView:(UIView *)board
              startX:(CGFloat)startX
                endX:(CGFloat)endX
               axisY:(CGFloat)axixY
           totalTime:(int)totalTime
         seekClosure:(SeekClosure)seekClosure
       isShowClosure:(IsShowClosure)isShowClosure;

- (void)configureDots;               //: add dots to boardview

- (void)hideAll:(BOOL)hidden;        //: hide or show all dot


@end

NS_ASSUME_NONNULL_END


