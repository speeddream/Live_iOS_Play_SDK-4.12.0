//
//  CCChatInputView.h
//  CCLiveCloud
//
//  Created by Chenfy on 2023/3/9.
//  Copyright © 2023 MacBook Pro. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CCChatInputView : UIView

- (void)addButtonEmojiNormal:(UIButton *)sender;
- (void)addButtonEmojiCustom:(UIButton *)sender;
- (void)addButtonEmojiKeyBoardResign:(UIButton *)sender;

@end

NS_ASSUME_NONNULL_END
