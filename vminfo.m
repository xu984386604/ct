//
//  vminfo.m
//  FreeRDP
//
//  Created by conan on 16/1/8.
//
//

#import "vminfo.h"

static vminfo *myvminfo = nil;
@implementation vminfo

+(instancetype)allocWithZone:(struct _NSZone *)zone
{
    //不能保证myvminfo不会被释放，所以不能使用dispatch_once_t创建单例
    @synchronized (self) {
        if(myvminfo == nil)
        {
            myvminfo = [super allocWithZone:zone];
        }
    }
    
//    static dispatch_once_t predicate;
//    dispatch_once(&predicate,^{
//        myvminfo = [super allocWithZone:zone];
//    });
    
    return myvminfo;
}

+(instancetype) share {
    myvminfo = [[self alloc] init];
//    static dispatch_once_t once_token;
//    dispatch_once(&once_token,^{
//        myvminfo = [[self alloc] init];
//    });
    
    if (myvminfo.RandomCode == nil) {
        NSString *key = [NSString stringWithFormat:@"ios%u", arc4random_uniform(10000)];
        myvminfo.RandomCode = key;
        [key release];
        key = nil;
    }
    
    if (!myvminfo.lastUrl && myvminfo.cuIp) {
        myvminfo.lastUrl = [NSString stringWithFormat:@"%@/cu",myvminfo.cuIp];
        NSLog(@"lastUrl赋值一次！");
    }
    
    if (myvminfo.multiRdpRecoverInfo == nil) {
        myvminfo.multiRdpRecoverInfo = [NSMutableDictionary dictionary];
    }
    return myvminfo;
}

+ (id)copyWithZone:(struct _NSZone *)zone {
    return myvminfo ? myvminfo : [[self alloc] init];
}


//获取存活的rdp远程应用的恢复连接的信息
+(void) filterRecoverRdpinfoDic {
//    NSLog(@"开始一次检查存活的rdp：");
//    if ([myvminfo.multiRdpRecoverInfo count] == 0 && myvminfo.checkTimer) {
//        [myvminfo.checkTimer invalidate];
//        myvminfo.checkTimer = nil;
//    }
//
//    NSEnumerator *keys =  [myvminfo.multiRdpSession keyEnumerator];
//    for (NSObject *key in keys) {
//        NSLog(@"%@", key);
//        NSLog(@"%@", [myvminfo.multiRdpSession objectForKey:key]);
////        TSXConnectionClosed = 0,
////        TSXConnectionConnecting = 1,
////        TSXConnectionConnected = 2,
////        TSXConnectionDisconnected = 3
//        RDPSession* session = [myvminfo.multiRdpSession objectForKey:key];
//        if ([session isClosed] == 0 || [session isClosed] == 3) {
//            [myvminfo.multiRdpSession removeObjectForKey:key]; //删除已经关闭了的rdp的session信息
//        }
//    }
//    NSMutableDictionary *newDic = [NSMutableDictionary dictionary];
//    NSEnumerator *newKeys =  [myvminfo.multiRdpSession keyEnumerator]; //新的有效sessions
//
//    for (NSObject<NSCopying> *key in newKeys) {
//        NSDictionary *object = [myvminfo.multiRdpRecoverInfo objectForKey:key];
//        [newDic setObject:object forKey:key];
//    }
//    myvminfo.multiRdpRecoverInfo = newDic;
//    if ([myvminfo.multiRdpRecoverInfo count] == 0) {
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"stoppostMessageToservice" object:@"recoverMsg"];
//    } else {
//        if (!myvminfo.checkTimer) {
//            myvminfo.checkTimer = [[NSTimer alloc] initWithFireDate:[NSDate dateWithTimeInterval:0 sinceDate:[NSDate date]] interval:10.0 target:self selector:@selector(filterRecoverRdpinfoDic) userInfo:nil repeats:YES];
//            [[NSRunLoop mainRunLoop] addTimer:myvminfo.checkTimer forMode:NSDefaultRunLoopMode];
//        }
//    }
}


@end
