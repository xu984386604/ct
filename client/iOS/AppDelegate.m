/*
 App delegate
 
 Copyright 2013 Thincast Technologies GmbH, Author: Martin Fleisz
 
 This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. 
 If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
 */

#import "AppDelegate.h"

#import "AboutController.h"
#import "HelpController.h"
#import "BookmarkListController.h"
#import "AppSettingsController.h"
#import "MainTabBarController.h"
#import "Utils.h"
#import "ViewController.h"
#import "NavigationController.h"
#import  "CuWebViewController.h"
#import "myNavigationViewController.h"
#import "Toast+UIView.h"

#import <Reachability.h>


@interface AppDelegate()
{
    //timer是用于后台任务的执行
    NSTimer *timer;
}
@property (nonatomic,strong) Reachability *reach;
@end

@implementation AppDelegate


@synthesize window = _window, tabBarController = _tabBarController;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Set default values for most NSUserDefaults 设置默认
    [[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Defaults" ofType:@"plist"]]];
    
    // init global settings 初始化
    SetSwapMouseButtonsFlag([[NSUserDefaults standardUserDefaults] boolForKey:@"ui.swap_mouse_buttons"]);
    SetInvertScrollingFlag([[NSUserDefaults standardUserDefaults] boolForKey:@"ui.invert_scrolling"]);
//    ViewController *vc = [[[ViewController alloc] initWithNibName:@"ViewController" bundle:nil] autorelease];
//    vc.title = @"cos客户端";
//添加网络变化监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];

    self.reach =[Reachability reachabilityWithHostName:@"www.apple.com"];
    [self.reach startNotifier];

    
    
    
    
    
    CuWebViewController *myCuVC=[[CuWebViewController alloc] init];
    
        myNavigationViewController *mynav = [[myNavigationViewController alloc] initWithRootViewController:myCuVC];
    
    _window.rootViewController = mynav;
    [_window makeKeyAndVisible];
    
    
    return YES;
}
//网络变化的函数
-(void)reachabilityChanged:(NSNotification *)notification
{
    Reachability *reach = [notification object];
    NetworkStatus status = [reach currentReachabilityStatus];
    if(status == NotReachable)
    {
        [self.window makeToast:@"无网络,请检查网络连接" duration:3.0 position:@"center"];
    }

}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)cacSBStartBackgroundTask{
    timer = [NSTimer scheduledTimerWithTimeInterval:300.0f target:self selector:@selector(sendMessage) userInfo:nil repeats:YES];
}



- (void)applicationDidEnterBackground:(UIApplication *)application
{
    
    //开启一个后台任务
    if ([vminfo share].cuIp && [vminfo share].multiRdpRecoverInfo.count > 0) {
        taskId = [application beginBackgroundTaskWithExpirationHandler:^{
            //结束指定的任务
            [application endBackgroundTask:taskId];
            taskId = UIBackgroundTaskInvalid;
        }];
        [self cacSBStartBackgroundTask];
        NSLog(@"进入后台！");
    }
}

-(void)sendMessage {
    if ([vminfo share].multiRdpSession.count == 0) {
        [timer invalidate];
        timer = nil;
        NSLog(@"%sAppDelegate:停止发送recoverMsg信息！", __func__);
        return;
    }
    NSString *ip=[vminfo share].cuIp;
    NSString *handleUrl = [NSString stringWithFormat:@"%@", ip];
    NSMutableDictionary *jsonData = [NSMutableDictionary dictionary];
    NSURL *url=[NSURL URLWithString:handleUrl];
    NSMutableURLRequest *myrequest=[NSMutableURLRequest requestWithURL:url];
    myrequest.HTTPMethod=@"POST";
    [myrequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    handleUrl = [handleUrl stringByAppendingString:@"cu/index.php/Home/Client/UpdateAppUseStatus"];
    jsonData = [vminfo share].multiRdpRecoverInfo;
    NSLog(@"AppDelegate:发起请求的url：%@", handleUrl);
    NSLog(@"AppDelegate:准备发送recoverMsg信息");
    
    NSData *sendData = [NSJSONSerialization dataWithJSONObject:jsonData options:NSJSONWritingPrettyPrinted error:nil];
    myrequest.HTTPBody = sendData;
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    NSURLSessionDataTask *data = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data,NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSLog(@"AppDelegate:发送recoverMsg信息成功！");
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"AppDelegate:发送recoverMsg信息的请求返回状态码：%ld", (long)httpResponse.statusCode);
        if(data !=nil) {
            NSLog(@"AppDelegate:收到的恢复rdp的返回信息：%@", str);
        }
    }];
    [data resume]; //如果request任务暂停了，则恢复
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    //进入前台后将发送的心跳的后台计时器失效，之后cuwebcontroller的runloop的心跳信息的timer会马上执行最近一次的任务
    if (timer) {
        [timer invalidate];
        timer = nil;
        NSLog(@"%sAppDelegate:停止发送recoverMsg信息！", __func__);
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:
     */
   // [self closeOpenRdp];
}



-(void)closeOpenRdp
{
    NSString *cuip=[vminfo share].cuIp;
    NSString *Reset_vm_User=[NSString stringWithFormat:@"%@cu/index.php/Home/Client/SendMessageToAgent",cuip];
    
    NSURL *url=[NSURL URLWithString:Reset_vm_User];
    NSMutableURLRequest *myrequest=[NSMutableURLRequest requestWithURL:url];
    myrequest.HTTPMethod=@"POST";
    [myrequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSDictionary *json=@{
                         @"vmusername":[vminfo share].vmusername,
                         @"ip":[vminfo share].vmip,
                         @"type":@"logoff"
                         };
    
    NSData *data=[NSJSONSerialization dataWithJSONObject:json options:NSJSONWritingPrettyPrinted error:nil];
    myrequest.HTTPBody=data;
    
    NSData *recvData=[NSURLConnection sendSynchronousRequest:myrequest returningResponse:nil error:nil];
    if(recvData !=nil)
    {
        
        NSError *err;
        NSMutableDictionary *dic=[NSJSONSerialization JSONObjectWithData:recvData options:NSJSONWritingPrettyPrinted error:&err];
        if(err)
        {
            NSLog(@"关闭rdp解析返回数据失败");
        }//if
        else{
            NSNumber *mycode=[dic objectForKey:@"code"];
            //mycode的值是800表示正确关闭
            NSLog(@"%@",mycode);
        }//else
    }//if
}

- (void)dealloc
{
    [self.reach stopNotifier];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_window release];
    [super dealloc];
}

@end
