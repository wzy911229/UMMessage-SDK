//
//  TSUMessageManager.m
//  galaxy
//
//  Created by zhiyu on 16/3/29.
//  Copyright © 2016年 terminus. All rights reserved.
//

#import "TSUMessageManager.h"
#import "UMessage.h"
#import "TSRootViewController.h"

#define UMSYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define _IPHONE80_ 80000

static NSString * const UMessageAppKey = @"56f89d4f67e58ea8cf000ea0";

@interface TSUMessageManager ()
@property(strong,nonatomic) NSDictionary * userInfo;
@end
@implementation TSUMessageManager



+ (instancetype)shareInstance
{
    static TSUMessageManager *_instance;
    static dispatch_once_t _once_t;
    dispatch_once(&_once_t, ^{
        if (!_instance) {
            _instance = [[TSUMessageManager alloc] init];
        }
    });
    return _instance;
}


+ (void)startWithLaunchOptions:(NSDictionary *)launchOptions
{
    [UMessage startWithAppkey:UMessageAppKey launchOptions:launchOptions];
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= _IPHONE80_
    
    if(UMSYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0"))
    {
        //register remoteNotification types （iOS 8.0及其以上版本）
        UIMutableUserNotificationAction *action1 = [[UIMutableUserNotificationAction alloc] init];
        action1.identifier = @"action1_identifier";
        action1.title = @"Accept";
        action1.activationMode = UIUserNotificationActivationModeForeground;//当点击的时候启动程序
        
        UIMutableUserNotificationAction *action2 = [[UIMutableUserNotificationAction alloc] init];  //第二按钮
        action2.identifier = @"action2_identifier";
        action2.title = @"Reject";
        action2.activationMode = UIUserNotificationActivationModeBackground;//当点击的时候不启动程序，在后台处理
        action2.authenticationRequired = YES;//需要解锁才能处理，如果action.activationMode = UIUserNotificationActivationModeForeground;则这个属性被忽略；
        action2.destructive = YES;
        
        UIMutableUserNotificationCategory *categorys = [[UIMutableUserNotificationCategory alloc] init];
        categorys.identifier = @"category1";//这组动作的唯一标示
        [categorys setActions:@[action1,action2] forContext:(UIUserNotificationActionContextDefault)];
        
        UIUserNotificationSettings *userSettings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge|UIUserNotificationTypeSound|UIUserNotificationTypeAlert
                                                                                     categories:[NSSet setWithObject:categorys]];
        [UMessage registerRemoteNotificationAndUserNotificationSettings:userSettings];
        
    } else{
        //register remoteNotification types (iOS 8.0以下)
        [UMessage registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge
         |UIRemoteNotificationTypeSound
         |UIRemoteNotificationTypeAlert];
    }
#else
    
    //register remoteNotification types (iOS 8.0以下)
    [UMessage registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge
     |UIRemoteNotificationTypeSound
     |UIRemoteNotificationTypeAlert];
    
#endif
    

    [UMessage setLogEnabled:YES];

}

+ (void)registerDeviceToken:(NSData *)deviceToken {
    [UMessage registerDeviceToken:deviceToken];
 
}

+ (void)unregisterRemoteNotifications {
    
    [UMessage unregisterForRemoteNotifications];
}

+ (void)didReceiveRemoteNotificationWithAutoAlertView:(NSDictionary *)userInfo {
    
    [UMessage didReceiveRemoteNotification:userInfo];
   [TSUMessageManager shareInstance].userInfo = userInfo;
    if (userInfo[@"url"]) {
        UINavigationController *nav = (UINavigationController*)[UIApplication sharedApplication].keyWindow.rootViewController;
        TSRootViewController *rootVc = nav.childViewControllers[0];
        [rootVc loadUrl:userInfo[@"url"]];
        
    }
    
}

+ (void)setAutoAlertView:(BOOL)shouldShow {
    [UMessage setAutoAlert:shouldShow];
 
}

+ (void)didReceiveRemoteNotificationWithCustomAlertView:(NSDictionary *)userInfo {
    [TSUMessageManager shareInstance].userInfo = userInfo;
    [UMessage didReceiveRemoteNotification:userInfo];
    // 应用当前处于前台时，需要手动处理
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [UMessage setAutoAlert:NO];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"系统消息"
                                                                message:userInfo[@"aps"][@"alert"]
                                                               delegate:[TSUMessageManager shareInstance]
                                                      cancelButtonTitle:@"取消"
                                                      otherButtonTitles:@"确定", nil];
            [alertView show];
        });
    }
    return;
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [UMessage sendClickReportForRemoteNotification:[TSUMessageManager shareInstance].userInfo];
         NSString *urlStr = self.userInfo[@"url"];
        if (urlStr) {
            UINavigationController *nav = (UINavigationController*)[UIApplication sharedApplication].keyWindow.rootViewController;
            TSRootViewController *rootVc = nav.childViewControllers[0];
            [rootVc loadUrl:urlStr];
            
        }
    }  
    return;  
}
@end
