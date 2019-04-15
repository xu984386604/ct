//
//  vminfo.h
//  FreeRDP
//  用来存储共享的数据
//  Created by conan on 16/1/8.
//
//

#import <Foundation/Foundation.h>
#import "client/iOS/Models/RDPSession.h"

@interface vminfo : NSObject

@property (nonatomic, copy) NSString *commonAppId;
//用户信息
@property (nonatomic, copy) NSString *vm;
@property (nonatomic, copy) NSString *vmip;
@property (nonatomic, copy) NSNumber *vmport;
@property (nonatomic, copy) NSString *vmusername;
@property (nonatomic, copy) NSString *vmpasswd;
@property (nonatomic, copy) NSString *remoteProgram;

//网关信息
@property (nonatomic, copy) NSString *gate;
@property (nonatomic, copy) NSString *gatehost;
@property (nonatomic, copy) NSNumber *gateport;
@property (nonatomic, copy) NSString *gateusername;
@property (nonatomic, copy) NSString *gatepasswd;
@property (nonatomic, copy)  NSString *gatewaycheck;


@property (nonatomic, copy) NSString *tsport;
@property (nonatomic, copy) NSString *tsusername;
@property (nonatomic, copy) NSString *tsip;
@property (nonatomic, copy) NSString *tspwd;

//ct用户的id
@property (nonatomic, copy)  NSString *uid;

//应用类型
@property (nonatomic, copy) NSString * apptype;
//docker类应用的信息
@property (nonatomic, copy) NSString * dockerIp;
@property (nonatomic, copy) NSString * dockerId;
@property (nonatomic, copy) NSString * dockerVncPwd;
@property (nonatomic, copy) NSString * dockerPort;
@property (nonatomic, copy) NSString * appid;

//设置屏幕的width和height
@property(nonatomic,assign) NSInteger height;
@property(nonatomic,assign) NSInteger width;


@property (nonatomic, copy) NSString *cuIp;

@property (nonatomic, assign) CGPoint mypoint;
@property (nonatomic, strong) NSTimer *recoverTimer; //恢复连接信息的定时发送器
@property (nonatomic, strong) NSTimer *checkTimer; //检查存活的远程应用（session）的定时器,存在多个rdp远程应用时会用到

@property (atomic, strong) NSMutableDictionary *multiRdpRecoverInfo; //保存多个远程应用的恢复信息
@property (atomic, strong) NSMutableDictionary *multiRdpSession; //保存多个远程应用session

@property (atomic, copy) NSString *cancelBtnSessionName; //取消按钮断开的那个应用的名字

@property (nonatomic, copy) NSString *RandomCode; //挂网盘和卸载网盘用到的一个相同的随机数

@property (nonatomic, strong) NSMutableDictionary *moreOpenerInfo;  //当remoteProgram过长时，则放到这个参数进行存储

@property (nonatomic, copy) NSString *lastUrl;

//@property (readonly) NSCondition* uiRequestCompleted;

+ (instancetype) share;
+ (void) filterRecoverRdpinfoDic;
@end
