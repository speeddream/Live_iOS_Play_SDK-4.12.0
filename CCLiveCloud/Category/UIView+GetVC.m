//
//  UIView+GetVC.m
//  CCLiveCloud
//
//  Created by 何龙 on 2018/12/12.
//  Copyright © 2018 MacBook Pro. All rights reserved.
//

#import "UIView+GetVC.h"

@implementation UIView (GetVC)
//TODO
-(UIViewController *)getViewController{
    //获取当前view的superView对应的控制器
    UIResponder *next = [self nextResponder];
    do {
        if ([next isKindOfClass:[UIViewController class]]) {
            if (![next isKindOfClass:[UINavigationController class]]) {
                return (UIViewController *)next;//避免找到NavigationVC
            }
        }
        next = [next nextResponder];
    } while (next != nil);
    return [[UIViewController alloc] init];
}

//需要获取到显示在最上面的viewController
- (UIViewController *)theTopviewControler{
    //获取根控制器
    UIViewController *rootVC = [[UIApplication sharedApplication].delegate window].rootViewController;
    
    UIViewController *parent = rootVC;
    //遍历 如果是presentViewController
    while ((parent = rootVC.presentedViewController) != nil ) {
        rootVC = parent;
    }
   
    while ([rootVC isKindOfClass:[UINavigationController class]]) {
        rootVC = [(UINavigationController *)rootVC topViewController];
    }
    return rootVC;
}

@end
