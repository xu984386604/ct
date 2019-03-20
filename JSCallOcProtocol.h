//
//  JSCallOcProtocol.h
//  FreeRDP
//
//  Created by conan on 2018/7/27.
//
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>

@protocol JSCallOcProtocol <JSExport>
JSExportAs(pageReload, -(void)pageReload:(id)num); //参数没有用,不加参数会出现语法错误
JSExportAs(openApp, -(void)AcceptTheDataFromJs:(NSString*)data);
JSExportAs(logOff, -(void)StopHeartBeat:(id)num);
JSExportAs(exit, -(void)appEnterBackground:(id)num);   //参数没有用
JSExportAs(executeByTerminal, -(void)AcceptUidAndKeepHeartBeat:(NSString *)data);
//JSExportAs(setCUAddress, -(void)getCUAddress:(NSString *)ipUrl);
//JSExportAs(openIpConfig, -(void)openIpConfig:(NSString *)data);
JSExportAs(openIOSApp, -(void)openIOSApp:(NSString*)data);
@end
