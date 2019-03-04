//
//  vminfo.m
//  FreeRDP
//
//  Created by conan on 16/1/8.
//
//

#import "vminfo.h"

static vminfo *myvminfo;
@implementation vminfo

+(instancetype)allocWithZone:(struct _NSZone *)zone
{
    @synchronized (self) {
        if(myvminfo == nil)
        {
            myvminfo=[super allocWithZone:zone];
        }
    }
    
    return myvminfo;
}

+(instancetype) share{
    vminfo *info = [[self alloc] init];
    if (info.RandomCode == nil) {
//    [[NSDate date] timeIntervalSince1970]
        NSString *key = [NSString stringWithFormat:@"ios%u", arc4random_uniform(10000)];
        info.RandomCode = key;
        [key release];
        key = nil;
    }
    
    if (info.multiRdpRecoverInfo == nil) {
        info.multiRdpRecoverInfo = [NSMutableDictionary dictionary];
    }
    return info;
}

//获取存活的rdp远程应用的恢复连接的信息
+(void) filterRecoverRdpinfoDic {
    NSLog(@"开始一次检查存活的rdp：");
    if ([myvminfo.multiRdpRecoverInfo count] == 0 && myvminfo.checkTimer) {
        [myvminfo.checkTimer invalidate];
        myvminfo.checkTimer = nil;
    }
    
    NSEnumerator *keys =  [myvminfo.multiRdpSession keyEnumerator];
    for (NSObject *key in keys) {
        NSLog(@"%@", key);
        NSLog(@"%@", [myvminfo.multiRdpSession objectForKey:key]);
//        TSXConnectionClosed = 0,
//        TSXConnectionConnecting = 1,
//        TSXConnectionConnected = 2,
//        TSXConnectionDisconnected = 3
        RDPSession* session = [myvminfo.multiRdpSession objectForKey:key];
        if ([session isClosed] == 0 || [session isClosed] == 3) {
            [myvminfo.multiRdpSession removeObjectForKey:key]; //删除已经关闭了的rdp的session信息
        }
    }
    NSMutableDictionary *newDic = [NSMutableDictionary dictionary];
    NSEnumerator *newKeys =  [myvminfo.multiRdpSession keyEnumerator]; //新的有效sessions
    
    for (NSObject<NSCopying> *key in newKeys) {
        NSDictionary *object = [myvminfo.multiRdpRecoverInfo objectForKey:key];
        [newDic setObject:object forKey:key];
    }
    myvminfo.multiRdpRecoverInfo = newDic;
    if ([myvminfo.multiRdpRecoverInfo count] == 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"stoppostMessageToservice" object:@"recoverMsg"];
    } else {
        if (!myvminfo.checkTimer) {           
            myvminfo.checkTimer = [[NSTimer alloc] initWithFireDate:[NSDate dateWithTimeInterval:0 sinceDate:[NSDate date]] interval:10.0 target:self selector:@selector(filterRecoverRdpinfoDic) userInfo:nil repeats:YES];
            [[NSRunLoop mainRunLoop] addTimer:myvminfo.checkTimer forMode:NSDefaultRunLoopMode];
        }
    }
}


@end
