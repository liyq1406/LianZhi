//
//  AppDelegate.m
//  LianZhiTeacher
//
//  Created by jslsxu on 14/12/16.
//  Copyright (c) 2014年 jslsxu. All rights reserved.
//

#import "AppDelegate.h"
#import "NewEditionPreview.h"
#import <AudioToolbox/AudioToolbox.h>
#import "HomeViewController.h"
#import "WelcomeView.h"
#import "TeacherDefine.h"
#import "MessageDetailVC.h"
#import "PasswordModificationVC.h"
#include "BaseInfoModifyVC.h"
static SystemSoundID shake_sound_male_id = 0;
@interface AppDelegate ()<WelComeViewDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [self.window setBackgroundColor:[UIColor whiteColor]];
    [self.window makeKeyAndVisible];
    [[TaskUploadManager sharedInstance] start];
    [self setupCommonHandler];
    [self registerSound];           //注册声音
    [self setupCommonAppearance];
    [self registerRemoteNotification];
    self.rootNavigation = [[TNBaseNavigationController alloc] initWithRootViewController:nil];
    [self.window setRootViewController:self.rootNavigation];
    if(![[UserCenter sharedInstance] hasLogin])
        [LoginVC presentLoginVCAnimation:NO completion:^(BOOL loginSuccess, BOOL loginCancel) {
            if(loginSuccess)
            {
                [self loginSuccess];
            }
        }];
    else
    {
        HomeViewController *homeVC = [[HomeViewController alloc] init];
        self.rootNavigation = [[TNBaseNavigationController alloc] initWithRootViewController:homeVC];
        [self.window setRootViewController:self.rootNavigation];
        self.homeVC = homeVC;
        [self showNewEditionPreview];
    }
    
    NSDictionary *notificationInfo = [launchOptions objectForKey:@"UIApplicationLaunchOptionsRemoteNotificationKey"];
    if(notificationInfo)
        [self handleNotification:notificationInfo];
    [WelcomeView showWelcome];
    [self startReachability];
    return YES;
}

- (void)setupCommonHandler
{
    static BOOL showLogout = NO;
    [[HttpRequestEngine sharedInstance] setBaseUrl:kRootRequestUrl];
    [[HttpRequestEngine sharedInstance] setCommonParamsBlk:^(NSMutableDictionary *commonParams){
        if([commonParams valueForKey:@"school_id"] == nil)
            [commonParams setValue:[UserCenter sharedInstance].curSchool.schoolID forKey:@"school_id"];
        [commonParams setValue:[UserCenter sharedInstance].userData.accessToken forKey:@"verify"];
        [commonParams setValue:[UserCenter sharedInstance].deviceToken forKey:@"device_token"];
        [commonParams setValue:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"] forKey:@"version"];
        [commonParams setValue:@"1" forKey:@"platform"];
    }];
    if([UserCenter sharedInstance].hasLogin)
        [[HttpRequestEngine sharedInstance] setCommonCacheRoot:[NSString stringWithFormat:@"school_id_%@",[UserCenter sharedInstance].curSchool.schoolID]];
    [[HttpRequestEngine sharedInstance] setCommonHandleBlk:^BOOL(TNDataWrapper *responseWrapper){
        NSInteger errCode = [responseWrapper getIntegerForKey:@"err_code"];
        NSString *errMsg = [responseWrapper getStringForKey:@"err_msg"];
        if(errCode == 9003 || errCode == 9004 || errCode == 9005)//重新登录
        {
            if(errCode == 9004)
                errMsg = @"本账号已在其他地点登陆，如不是您本人操作，可能个人信息已泄露，请修改密码或联系客服";
            else if(errCode == 9005)
                errMsg = @"重要关联发生变化，请重新登录";
            if([[UserCenter sharedInstance] hasLogin] && !showLogout)
            {
                showLogout = YES;
                TNButtonItem *item = [TNButtonItem itemWithTitle:@"立刻重新登录" action:^{
                    [ApplicationDelegate logout];
                    showLogout = NO;
                }];
                TNAlertView *alertView = [[TNAlertView alloc] initWithTitle:errMsg buttonItems:@[item]];
                [alertView show];
            }
            return NO;
        }
        else if(errCode == 9009)
        {
            TNButtonItem *item = [TNButtonItem itemWithTitle:@"立即更新" action:^{
                [ApplicationDelegate logout];
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:kTeacherClientAppStoreUrl]];
            }];
            TNAlertView *alertView = [[TNAlertView alloc] initWithTitle:errMsg buttonItems:@[item]];
            [alertView show];
            return NO;
        }
        [[UserCenter sharedInstance].statusManager parseData:[responseWrapper getDataWrapperForKey:@"status"]];
        return YES;
    }];
}

- (void)setupCommonAppearance
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    [[UINavigationBar appearance] setBarTintColor:kCommonTeacherTintColor];
//    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageWithColor:kCommonTeacherTintColor size:CGSizeMake(10, 10)] forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor],NSFontAttributeName:[UIFont boldSystemFontOfSize:18]}];
}

- (void)showNewEditionPreview
{
    //重大版本才加
//    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
//    NSDictionary *infoDictionary = [NSBundle mainBundle].infoDictionary;
//    NSString *version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
//    BOOL newEditionPreviewShown = [userDefaults boolForKey:version];
//    if(!newEditionPreviewShown)
//    {
//        newEditionPreviewShown = YES;
//        [userDefaults setBool:newEditionPreviewShown forKey:version];
//        [userDefaults synchronize];
//        NewEditionPreview *preview = [[NewEditionPreview alloc] initWithFrame:[UIScreen mainScreen].bounds];
//        [preview show];
//    }
}

- (void)loginSuccess
{
//    HomeViewController *homeVC = [[HomeViewController alloc] init];
//    self.rootNavigation = [[TNBaseNavigationController alloc] initWithRootViewController:homeVC];
//    self.homeVC = homeVC;
//    if([UserCenter sharedInstance].userData.firstLogin)
//    {
//        RelatedInfoVC *relatedInfoVC = [[RelatedInfoVC alloc] init];
//        [self.rootNavigation pushViewController:relatedInfoVC animated:NO];
//    }
//    [self.window setRootViewController:self.rootNavigation];
//    [self showNewEditionPreview];
    
    void (^callback)() = ^(){
         [[HttpRequestEngine sharedInstance] setCommonCacheRoot:[NSString stringWithFormat:@"school_id_%@",[UserCenter sharedInstance].curSchool.schoolID]];
        HomeViewController *homeVC = [[HomeViewController alloc] init];
        self.homeVC = homeVC;
        self.rootNavigation = [[TNBaseNavigationController alloc] initWithRootViewController:homeVC];
        if([UserCenter sharedInstance].userData.firstLogin)
        {
            RelatedInfoVC *relatedInfoVC = [[RelatedInfoVC alloc] init];
            [self.rootNavigation pushViewController:relatedInfoVC animated:NO];
        }
        if(![UserCenter sharedInstance].userData.confirmed)
        {
            BaseInfoModifyVC *baseInfoVC = [[BaseInfoModifyVC alloc] init];
            [self.rootNavigation pushViewController:baseInfoVC animated:NO];
        }
        [self.window setRootViewController:self.rootNavigation];
        [self.window makeKeyAndVisible];
        [self showNewEditionPreview];
    };
    
    if([UserCenter sharedInstance].userData.firstLogin)
    {
        PasswordModificationVC *passWordModificationVC = [[PasswordModificationVC alloc] init];
        [passWordModificationVC setCallback:callback];
        self.rootNavigation = [[TNBaseNavigationController alloc] initWithRootViewController:passWordModificationVC];
        [self.window setRootViewController:self.rootNavigation];
    }
    else
    {
        callback();
    }
}

- (void)logout
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[TaskUploadManager sharedInstance] cleanTask];
    });
    self.rootNavigation = [[TNBaseNavigationController alloc] initWithRootViewController:nil];
    [self.window setRootViewController:self.rootNavigation];
    [[UserCenter sharedInstance] logout];
    [LoginVC presentLoginVCAnimation:NO completion:^(BOOL loginSuccess, BOOL loginCancel) {
        if(loginSuccess)
        {
            [self loginSuccess];
        }
    }];
}

- (void)registerRemoteNotification
{
    UIApplication *application = [UIApplication sharedApplication];
    if ([application respondsToSelector:@selector(registerForRemoteNotifications)]) {
        UIUserNotificationType types = (UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert);
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:types categories:nil]];
        [application registerForRemoteNotifications];
    }
    else {
        [application registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge
                                                         | UIRemoteNotificationTypeSound
                                                         | UIRemoteNotificationTypeAlert)];
    }
}

- (void)handleNotification:(NSDictionary *)userInfo
{
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    NSDictionary *action = [userInfo objectForKey:@"action"];
    if(action && [action isKindOfClass:[NSDictionary class]])
    {
        NSString *schoolID = [action objectForKey:@"school_id"];
        if([schoolID length] > 0)
        {
            BOOL contains = NO;
            for (SchoolInfo *school in [UserCenter sharedInstance].userData.schools) {
                if([school.schoolID isEqualToString:schoolID])
                    contains = YES;
            }

            if(contains)
            {
                // 根据app状态来处理
                UIApplicationState appState = [[UIApplication sharedApplication] applicationState];
                if (appState == UIApplicationStateInactive) // 后台切换到前台
                {
                    [self.homeVC selectAtIndex:0];
                    [self.homeVC.messageVC refreshData];
                }
                 else if (appState == UIApplicationStateActive) // 程序在前台
                 {
                     [self.homeVC.messageVC refreshData];
                 }
            }
        }
    }
    
}


- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSString* token = [[deviceToken description] stringByTrimmingCharactersInSet:
                       [NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    [UserCenter sharedInstance].deviceToken = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [self handleNotification:userInfo];
}

- (void)registerSound
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Noti" ofType:@"wav"];
    if (path) {
        //注册声音到系统
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:path],&shake_sound_male_id);
    }
}

- (void)playSound
{
    AudioServicesPlaySystemSound(shake_sound_male_id);   //播放注册的声音，（此句代码，可以在本类中的任意位置调用，不限于本方法中）
}

- (void)welcomeViewDidFinished
{
    
}


#pragma mark - Reachability
- (void)startReachability
{
    self.hostReach = [Reachability reachabilityWithHostName:@"www.apple.com"];//可以以多种形式初始化
    [self.hostReach startNotifier];  //开始监听,会启动一个run loop
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [[HttpRequestEngine sharedInstance] makeRequestFromUrl:@"user/check_status" method:REQUEST_GET type:REQUEST_REFRESH withParams:nil observer:self completion:^(AFHTTPRequestOperation *operation, TNDataWrapper *responseObject) {
        
    } fail:^(NSString *errMsg) {
        
    }];
     [self.homeVC.messageVC refreshData];
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
