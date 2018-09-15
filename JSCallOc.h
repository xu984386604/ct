//
//  JSCallOc.h
//  FreeRDP
//
//  Created by conan on 2018/7/27.
//
//

#import <Foundation/Foundation.h>
#import "JSCallOcProtocol.h"
#import "vminfo.h"
#import "CommonUtils.h"

@interface JSCallOc : NSObject<JSCallOcProtocol>
{
    int count;
}
@property(nonatomic,strong)NSMutableDictionary *dic; //私有变量

-(void)AcceptTheDataFromJs:(NSString *)data; //接收json数据解析并且保存到vminfo中
-(void)AcceptUidAndKeepHeartBeat:(NSString *)data;
-(void)StopHeartBeat:(id)num;
-(void)getCUAddress:(NSString *)ipUrl;
//-(void)openIpConfig:(NSString *)data;
-(void)appEnterBackground:(id)num;  //程序退出
@end
