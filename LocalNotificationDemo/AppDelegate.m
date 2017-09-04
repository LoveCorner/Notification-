//
//  AppDelegate.m
//  LocalNotificationDemo
//
//  Created by bjike on 2017/9/4.
//  Copyright © 2017年 来自任性傲娇的女王. All rights reserved.
//

#import "AppDelegate.h"
#import <UserNotifications/UserNotifications.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    return YES;
}
-(void)common{
    //取消所有的本地通知
    
    if ([[UIDevice currentDevice].systemVersion floatValue]>=10.0) {
        [[UNUserNotificationCenter currentNotificationCenter] removeAllDeliveredNotifications];
        //注册通知
        UNUserNotificationCenter * center = [UNUserNotificationCenter currentNotificationCenter];
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionAlert | UNAuthorizationOptionSound |UNAuthorizationOptionBadge) completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if (granted) {
                //允许通知
                [self registerNotification:12 andMinute:0 andAlertBody:@"亲，吃饭时间到了" andIdentifier:@"NoficationAM"];
    
            }else{
                NSLog(@"用户禁止通知");
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"通知" message:@"如果你点了不允许，以后请到设置里面打开app通知权限" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
                [alert addAction:cancelAction];
                [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
            }
        }];
        
        
    }else{
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
        [self registerLocalNotificationInOldWay:@"12:00" andAlertBody:@"亲，吃饭时间到了"];
    }
    
}
-(void)registerLocalNotificationInOldWay:(NSString *)alertTime andAlertBody:(NSString *)alertBody{
    
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    // 设置触发通知的时间
    NSDateFormatter *df = [NSDateFormatter new];
    //设置时间格式，此处我只设置了小时和分钟，按需求可更改
    [df setDateFormat:@"HH:mm"];
    //设置时区
    [df setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    NSDate * date = [df dateFromString:alertTime];
    notification.fireDate = date;
    //时区
    notification.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    //通知内容
    notification.alertBody =  alertBody;
    //APP右上角上显示的消息未读数
    notification.applicationIconBadgeNumber = 1;
    // 通知被触发时播放的声音
    notification.soundName = UILocalNotificationDefaultSoundName;
    // 通知参数
    NSDictionary *userDict = [NSDictionary dictionaryWithObject:alertBody forKey:@"key"];
    notification.userInfo = userDict;
    
    // ios8后，需要添加这个注册，才能得到授权
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        UIUserNotificationType type =  UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound;
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:type
                                                                                 categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    }
    // 通知重复提示的单位，可以是天、周、月，此处设置每天
    notification.repeatInterval = NSCalendarUnitDay;
    
    // 执行通知注册
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
}
-(void)registerNotification:(NSInteger )hour andMinute:(NSInteger)minute andAlertBody:(NSString *)alertBody andIdentifier:(NSString *)iden{
    
    // 使用 UNUserNotificationCenter 来管理通知
    UNUserNotificationCenter* center = [UNUserNotificationCenter currentNotificationCenter];
    //需创建一个包含待通知内容的 UNMutableNotificationContent 对象，注意不是 UNNotificationContent ,此对象为不可变对象。
    UNMutableNotificationContent* content = [[UNMutableNotificationContent alloc] init];
    //通知的标题
    content.title = [NSString localizedUserNotificationStringForKey:@"app通知" arguments:nil];
    //通知的内容
    content.body = [NSString localizedUserNotificationStringForKey:alertBody arguments:nil];
    //APP右上角的消息数
    content.badge = [NSNumber numberWithInteger:1];
    //通知声音（这里使用系统声音）
    content.sound = [UNNotificationSound defaultSound];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    //设置时区（时区一定要设置对）
    components.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    //这里我只设置小时和分钟，按需求自己设置
    components.hour = hour;
    components.minute = minute;
    UNCalendarNotificationTrigger *trigger = [UNCalendarNotificationTrigger triggerWithDateMatchingComponents:components repeats:YES];
    
    // 在 alertTime 后推送本地推送
    UNNotificationRequest* request = [UNNotificationRequest requestWithIdentifier:iden
                                                                          content:content trigger:trigger];
    
    //添加推送成功后的处理！
    [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"app通知" message:@"亲，已通知您" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
                [alert addAction:cancelAction];
                [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
    }];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}

//进入后台时通知
- (void)applicationDidEnterBackground:(UIApplication *)application {
    [self common];

}
//app在前台才会提示
-(void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"app通知" message:@"亲，记得吃饭哦！" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:cancelAction];
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}

//前台通知
- (void)applicationDidBecomeActive:(UIApplication *)application {
    [self common];
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
