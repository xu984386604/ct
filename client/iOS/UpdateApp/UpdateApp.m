//
//  UpdateApp.m
//  FreeRDP
//
//  Created by conan on 2018/8/30.
//
//

#import "UpdateApp.h"
#import "UpdateApp+SB.h"

@implementation UpdateApp

//检查更新
- (void)checkVersionUpdata {
    NSString *urlStr = @"http://172.20.100.11/cu/index.php/Home/Client/getVersion";
    //NSDictionary *dic = @{@"type":@"IOS"};
    [self makeRequestToServer:urlStr byHttpMethod:@"POST"];
}

//发送json数据，也接收json数据
- (void) makeRequestToServer:(NSString*)urlString  byHttpMethod:(NSString*) method {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:method];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    NSString *strData = @"type=IOS";
    NSData *sendData = [strData dataUsingEncoding:NSUTF8StringEncoding];
    request.HTTPBody = sendData;

    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    
    NSURLSessionDataTask *sessionData = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data,NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        NSLog(@"发送信息的请求返回状态码：%ld", (long)httpResponse.statusCode);
        if(data) {
            //{"data":{"versionid":"3.9.2-1011","oldversionid":"3.8.5-1011"},"platform":"Windows","code":800}
            NSError *error;
            id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
            NSDictionary *appInfo = (NSDictionary*)jsonObject;
            NSArray *platform = [appInfo objectForKey:@"platform"];
            if (![platform isEqual:@"IOS"]) {
                NSLog(@"平台信息错误：%@", platform);
                return;
            }
            NSDictionary *infoContent = [appInfo objectForKey:@"data"];
            //线上最新版本
            NSString * lastestVersion = [infoContent objectForKey:@"versionid"];
            //上次强制更新的版本
            NSString * oldVersion = [infoContent objectForKey:@"oldversionid"];
            // 获取app当前版本
            NSString *currentVersion = [self currentVersion];
            
            
            int updateStatusFlag = [self checkUpdateStatus:currentVersion lastForceUpdateVersion:oldVersion lastestVersion:lastestVersion];
            NSString *updateStr = @"";
            if (updateStatusFlag == NEED_FORCE_UPDATE) {//需要强制更新
                NSLog(@"需要强制更新！");
                updateStr = @"你的应用版本过低，请到appstore更新后再使用！";
                [self creatAlterView:updateStr forceUpdate:true];
            } else if(updateStatusFlag == NEED_UPDATE) {//可以不强制更新，但是有新的版本
                NSLog(@"可以不需要更新，但是有新的版本！");
                updateStr = @"有新的版本，请及时到appstore更新！";
                [self creatAlterView:updateStr forceUpdate:false];
            } else {
                NSLog(@"已经是最新版本！");
            }
        }
    }];
    [sessionData resume]; //如果request任务暂停了，则恢复
}

// 弹框提示
- (void)creatAlterView:(NSString *)msg forceUpdate:(Boolean) needForceUpdate {
    UIAlertController *alertText = [UIAlertController alertControllerWithTitle:@"友情提醒" message:msg preferredStyle:UIAlertControllerStyleAlert];
    [alertText addAction:[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        if (needForceUpdate) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"appEnterbackGround" object:nil];
        }
    }]];
    [alertText addAction:[UIAlertAction actionWithTitle:@"退出" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"appEnterbackGround" object:nil];
    }]];
    
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    dispatch_async(dispatch_get_main_queue(), ^{
        [rootViewController presentViewController:alertText animated:YES completion:nil];
    });
}

//获取应用的配置文件里的版本号
- (NSString *) currentVersion
{
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    return app_Version;
}

@end
