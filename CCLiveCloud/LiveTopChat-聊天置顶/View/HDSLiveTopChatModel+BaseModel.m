//
//  HDSLiveTopChatModel+BaseModel.m
//  CCLiveCloud
//
//  Created by richard lee on 1/30/23.
//  Copyright © 2023 MacBook Pro. All rights reserved.
//

#import "HDSLiveTopChatModel+BaseModel.h"
#import <objc/runtime.h>

static const void *kBaseModel = @"kBaseModel";

@implementation HDSLiveTopChatModel (BaseModel)

- (BOOL)isOpen {
    return [objc_getAssociatedObject(self, &kBaseModel) boolValue];
}

- (void)setIsOpen:(BOOL)isOpen {
    objc_setAssociatedObject(self, &kBaseModel, @(isOpen), OBJC_ASSOCIATION_ASSIGN);
}



@end
