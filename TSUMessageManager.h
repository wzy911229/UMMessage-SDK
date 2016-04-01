//
//  TSUMessageManager.h
//  galaxy
//
//  Created by zhiyu on 16/3/29.
//  Copyright © 2016年 terminus. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface TSUMessageManager : NSObject<UIAlertViewDelegate>

+ (instancetype)shareInstance;
/**
 * 在应用启动时注册
 */
+ (void)startWithLaunchOptions:(NSDictionary *)launchOptions;
/**
 *  注册deveiceToken
 */
+ (void)registerDeviceToken:(NSData *)deviceToken;
/**
 *  接受消息，并应用在前台时，处理弹出默认提示框
 */
+ (void)didReceiveRemoteNotificationWithAutoAlertView:(NSDictionary *)userInfo;
/**
 *  关闭接收消息通知
 */
+ (void)unregisterRemoteNotifications;

/**
 *  使用友盟提供的默认提示框显示推送信息,default is YES
 */
+ (void)setAutoAlertView:(BOOL)shouldShow;

/**
 *  接受消息，并应用在前台时，使用自定义的alertview弹出框显示信息
 */
+ (void)didReceiveRemoteNotificationWithCustomAlertView:(NSDictionary *)userInfo;

@end
