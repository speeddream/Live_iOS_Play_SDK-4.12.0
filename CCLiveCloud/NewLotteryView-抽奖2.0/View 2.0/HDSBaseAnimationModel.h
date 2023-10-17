//
//  HDSBaseAnimationModel.h
//  HDSExample
//
//  Created by richard lee on 9/1/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HDSBaseAnimationModel : NSObject
/// 奖品名称
@property (nonatomic, copy)   NSString *prizeName;
/// 奖品个数
@property (nonatomic, assign) NSInteger prizeNum;
/// 参与在线人数
@property (nonatomic, assign) NSInteger onlineNumber;

@end

NS_ASSUME_NONNULL_END
