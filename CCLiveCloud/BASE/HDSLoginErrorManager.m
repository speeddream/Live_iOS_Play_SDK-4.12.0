//
//  HDSLoginErrorManager.m
//  CCLiveCloud
//
//  Created by richard lee on 6/19/23.
//  Copyright © 2023 MacBook Pro. All rights reserved.
//

#import "HDSLoginErrorManager.h"

@implementation HDSLoginErrorManager

+ (NSString *)loginErrorCode:(NSUInteger)code message:(NSString *)message {
    switch (code) {
        case 10000000:
           return @"请求参数不正确，请检查后重试。";
           break;
        case 20270008:
           return @"您的Token不存在，请重新登录。";
           break;
        case 10000001:
           return @"系统出现异常，请稍后再试。";
           break;
        case 20200002:
           return @"您的账户已过期，请联系客服处理。";
           break;
        case 10000034:
           return @"您还未登录，请先登录后再试。";
           break;
        case 10000005:
           return @"该回放不存在或已被删除，请检查后重试。";
           break;
        case 10000007:
           return @"该直播不存在或已被删除，请检查后重试。";
           break;
        case 10000006:
           return @"该直播间不存在或已被删除，请检查后重试";
           break;
        case 20290005:
           return @"请求参数错误，请检查后重试。";
           break;
        case 20270000:
           return @"api登录调用失败，请检查网络连接后重试。";
           break;
        case 20270011:
           return @"api登录调用超时：api登录调用超时，请检查网络连接后重试。";
           break;
        case 20270003:
            return @"登录失败，请联系管理员添加你至白名单";
            break;
        case 20270002:
           return @"名称或密码错误，请检查后重试。";
           break;
        case 20270001:
           return @"请求参数不正确，请检查后重试。";
           break;
        case 20270004:
           return @"该视频不属于当前账户，请联系客服。";
           break;
        case 20270005:
           return @"该视频不可用，请联系客服。";
           break;
        case 20270006:
           return @"获取播放地址失败，请检查网络连接后重试。";
           break;
        case 20270010:
           return @"获取打点信息失败，请联系客服。";
           break;
        case 20270007:
           return @"该播放地址不存在或已被删除，请联系客服。";
           break;
        case 20290009:
           return @"不合法的产品线，请联系客服。";
           break;
        case 20270012:
           return @"手机号验证失败，请检查输入后重试。";
           break;
        case 20270013:
           return @"登记观看失败，请联系客服。";
           break;
        case 20270014:
           return @"手机号验证失败，请检查输入后重试。";
           break;
        case 20270015:
           return @"发送短信失败，请稍后再试。";
           break;
        case 20270016:
           return @"该直播间未开启直播转回放功能，请联系客服。";
           break;
        case 20270017:
           return @"回放直播间与登录直播间不符，请联系客服。";
           break;
        case 20270018:
           return @"批量获取视频信息失败，请联系客服。";
           break;
        case 20270019:
           return @"视频信息错误，请联系客服。";
           break;
        case 20270020:
           return @"该极速回放视频没有内容，请联系客服。";
           break;
        case 20290015:
           return @"企微绑定已失效，请重新绑定。";
           break;
        case 20290016:
           return @"非法的企微绑定关系，请重新绑定。";
           break;
        case 20290017:
           return @"该企微用户未在当前直播间下被授权，请联系管理员授权";
           break;
        case 20290001:
            return message;
           break;
        default:
            return [NSString stringWithFormat:@"code:%zd message:%@",(long)code,message];
            break;
    }
    return message;
}

@end
