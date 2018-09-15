//
//  CuWebViewController.h
//  FreeRDP
//
//  Created by conan on 2018/7/27.
//
//

#import <UIKit/UIKit.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import "JSCallOc.h"
#import "vminfo.h"
#import "RDPSessionViewController.h"
#import "CommonUtils.h"
#import <Foundation/Foundation.h>
#import "MyFloatButton.h"

@interface CuWebViewController : UIViewController<UIWebViewDelegate, NSURLSessionDelegate>
{
@private
    JSContext * context;     //js的
    NSString * cuIp;       //CU的地址
    NSString * innerCuUrl;  //内网地址
    UIWebView * myWebView;  //加载网页的view
    NSString * innerNet;    //内外网的标志位 1：外网， 0：内网
}

@property(nonatomic,strong) vminfo *connectInfo;
@property(nonatomic, assign) BOOL isNotFirstLoad; //解决webviwer刷新后或者发生url重定向后js和objc桥断裂后不可简单修复的问题
@end
