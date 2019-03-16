//
//  CuWebViewController.m
//  FreeRDP
//
//  Created by conan on 2018/7/27.
//
//

#import "CuWebViewController.h"
#import "Bookmark.h"
#import "Toast+UIView.h"
#import <CommonCrypto/CommonDigest.h>
#import "FontAwesome/NSString+FontAwesome.h"
#import "UpdateApp/UpdateApp.h"
#import <SCLAlertView.h>

#import <notify.h>

#define NotificationLock CFSTR("com.apple.springboard.lockcomplete")
#define NotificationChange CFSTR("com.apple.springboard.lockstate")
#define NotificationPwdUI CFSTR("com.apple.springboard.hasBlankedScreen")


#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)
#define SCREEN_WIDTH  ([UIScreen mainScreen].bounds.size.width)
#define LOCALMD5      @"50eebf29fcc2c6e5d9f55e21e9ab56b0"

//WLOG_LEVEL=DEBUG  环境变量
@interface CuWebViewController () <MyFloatButtonDelegate>
{
    MyFloatButton * _myfloatbutton;  //悬浮按钮
}
@property(nonatomic,strong)NSTimer * mytimer; //计时器
@end

@implementation CuWebViewController
- (void)viewDidLoad {
    //检查一波版本
   // [[[UpdateApp alloc] init] checkVersionUpdata];
    [super viewDidLoad];
    innerNet=@"1"; //默认外网
    _isNotFirstLoad = NO; //解决页面刷新后或者新请求后出现桥断裂的情况
    [self isFirstLoad]; //判断程序是否是第一次安装启动，是的话则生成一个loginuuid
    BOOL md5check = [self MD5check];
    if(md5check)
    {
        [self loadLocalHTML:@"index" inDirectory:@"iplogin"];
    }

    [self initMyFloatButton];
    
    
    //注册观察者处理事件
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(openRdp) name:@"openRdp" object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver: self selector:@selector(stoppostMessageToservice:) name:@"stoppostMessageToservice" object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(postMessageToService:) name:@"postMessageToservice" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadLocalHTMLbyNotice:) name:@"loadLocalHTML" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setFlag:) name:@"setFlag" object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showParamErrorMessage) name:@"paramErrorMessage" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(openRdp) name:@"reloadRdp" object:nil];
    
    
    //使用darwin层的注册锁屏通知（应用在前台）
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, screenLockStateChanged, NotificationLock, NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, screenLockStateChanged, NotificationChange, NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
    
    //注册服务器断开连接的事件处理
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(disconnectByServer) name: @"disconnectByServer" object:nil];
    
    _connectInfo = [vminfo share];
    
    //初始化vminfo中的height和width
    CGRect rect = [[UIScreen mainScreen] bounds];
    CGSize size = rect.size;
    
    _connectInfo.width =(int) size.width *2;
    _connectInfo.height =(int) size.height *2;
}

- (void) disconnectByServer {
    dispatch_sync(dispatch_get_main_queue(), ^{
        SCLAlertView * alertView = [[SCLAlertView alloc] init];
        alertView.showAnimationType = SCLAlertViewShowAnimationFadeIn;
        [alertView showError:self title:@"ERROR" subTitle:@"服务器关闭了连接！" closeButtonTitle:@"确定" duration:0.0f];
    });
}

#pragma mark 网页加载

//加载cu网页 内外网判断完后会调用此函数加载
-(void)loadMyWebview
{
    NSString *cuurl=[NSString stringWithFormat:@"%@/cu",cuIp];
    NSURLRequest *myrequest=[NSURLRequest requestWithURL:[NSURL URLWithString:cuurl]];
    myWebView=[[UIWebView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    myWebView.delegate=self;
    [myWebView loadRequest:myrequest];
    [self.view addSubview:myWebView];
    [(UIScrollView *)[[myWebView subviews] objectAtIndex:0] setBounces:NO];
    //_isNotFirstLoad = YES;
}

//加载本地网页
-(void) loadLocalHTML:(NSString*) fileName  inDirectory:(NSString*) dirName{
    myWebView=[[UIWebView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    myWebView.delegate=self;
    myWebView.scrollView.bounces = NO;
    NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"html" inDirectory:dirName];
    filePath = [NSString stringWithFormat:@"%@?isAutoLogin=1", filePath]; //1代表应用第一次打开登录页面
    NSLog(@"local_filepath：%@",filePath);
    NSURL *url = [NSURL URLWithString:filePath];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [myWebView loadRequest:request];
    [self.view addSubview:myWebView];
    [(UIScrollView *)[[myWebView subviews] objectAtIndex:0] setBounces:NO];
}

//加载本地网页(notice)
-(void) loadLocalHTMLbyNotice:(NSNotification*) notification {
    NSString *filename = [[notification userInfo] objectForKey:@"filename"];
    NSString *dirName = [[notification userInfo] objectForKey:@"dirname"];
    NSString *filePath = [[NSBundle mainBundle] pathForResource:filename ofType:@"html" inDirectory:dirName];
    filePath = [NSString stringWithFormat:@"%@?isAutoLogin=0&canClearCookie=pwd", filePath]; //0代表注销跳回登录页面,canClearCookie，pwd代表清除密码，all代表清除所有的缓存
    NSLog(@"notice-filepath：%@",filePath);
    NSURL *url = [NSURL URLWithString:filePath];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [myWebView loadRequest:request];
    [(UIScrollView *)[[myWebView subviews] objectAtIndex:0] setBounces:NO];
}

#pragma mark openrdp
/*********************
    function:用来打开rdp
 ********************/
-(void)openRdp
{
    if ([vminfo share].cancelBtnSessionName) {
        NSLog(@"上一次取消打开的应用还没有关闭！请稍等！");
        return;
    }
    ComputerBookmark *bookmark = [[[ComputerBookmark alloc] initWithBaseDefaultParameters] autorelease];

    [[bookmark params] setValue:_connectInfo.remoteProgram  forKey:@"remote_program"];
    [[bookmark params] setValue:_connectInfo.vmusername forKey:@"username"];
    [[bookmark params] setValue:_connectInfo.vmpasswd forKey:@"password"];
    [[bookmark params] setValue:_connectInfo.vmip forKey:@"hostname"];
    [[bookmark params] setValue:_connectInfo.vmport forKey:@"port"];
    //根据gatewaycheck来确定是否网关检验
    if([_connectInfo.gatewaycheck isEqualToString:@"YES"])
    {
        [[bookmark params] setValue:@"YES" forKey:@"enable_tsg_settings"];
        [[bookmark params] setValue:_connectInfo.tsip forKey:@"tsg_hostname"];
        [[bookmark params] setValue:_connectInfo.tsport forKey:@"tsg_port"];
        [[bookmark params] setValue:_connectInfo.tsusername forKey:@"tsg_username"];
        [[bookmark params] setValue:_connectInfo.tspwd forKey:@"tsg_password"];
    }
    //打开的时docker类的应用，要向服务器发送消息
    if([_connectInfo.apptype isEqualToString:@"lca"])
    {
        [self sendMessageToDocker];
    }
    
    int width  = (int)_connectInfo.width;
    int height = (int)_connectInfo.height;
    if(height < width) {
        int temp = height;
        height = width;
        width = temp;
    }
    NSLog(@"设置的分辨率：width:%d  height:%d", width, height);
    //设置分辨率
   /* if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [[bookmark params] setInt:height * 2 forKey:@"width"];
        [[bookmark params] setInt:width * 2 forKey:@"height"];
        NSLog(@"IPHONE");
    } else {
        [[bookmark params] setInt:height forKey:@"width"];
        [[bookmark params] setInt:width forKey:@"height"];
    }*/
    [[bookmark params] setInt:height  forKey:@"width"];
    [[bookmark params] setInt:width  forKey:@"height"];
    
    RDPSession* session = [[[RDPSession alloc] initWithBookmark:bookmark] autorelease];
   // NSLog(@"rdp连接的session的名称：%@", session.sessionName);
    RDPSessionViewController* ctrl = [[[RDPSessionViewController alloc] initWithNibName:@"RDPSessionView" bundle:nil session:session] autorelease];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.navigationController pushViewController:ctrl animated:YES];
    });
    
    NSDictionary *jsonData = @{
                 @"appid": [vminfo share].appid,
                 @"vmuser": [vminfo share].vmusername,
                 @"userid": [vminfo share].uid,
                 @"vmip": [vminfo share].vmip
                 };
    
    NSAssert([vminfo share].RandomCode != nil, @"缺少一个随机数！");
    [[vminfo share].multiRdpRecoverInfo setObject:jsonData forKey:[vminfo share].RandomCode];
//    NSLog(@"存入multiRdpRecoverInfo的信息：%@", [[vminfo share].multiRdpRecoverInfo objectForKey:key]);
  //  [[NSNotificationCenter defaultCenter] postNotificationName:@"postMessageToservice" object:@"recoverMsg"];
}

#pragma mark initJsContext
/******************
   function: 初始化js的环境变量
   ********: webview改变的时候会context会失效,context只能获取到当前webview的环境变量
 ******************/
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [self initJSContext:webView];
}

-(void) initJSContext:(UIWebView *)webView{
    context=[webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    JSCallOc *app=[[JSCallOc alloc] init];
    context[@"app"]=app;
}

#pragma mark 设置第一次启动标志
//判断程序是否是第一次安装启动
//生成唯一的uuid
-(void) isFirstLoad
{
    BOOL tmp=[[NSUserDefaults standardUserDefaults] boolForKey:@"firstLaunch"];
    if(!tmp)
    {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"firstLaunch"];
        NSString *str = [[NSUUID UUID] UUIDString];
        [[NSUserDefaults standardUserDefaults] setValue:str forKey:@"oneloginuuid"];
        NSLog(@"生成uuid");
    }
    else{
        NSLog(@"不是第一次启动");
    }
}


#pragma mark heartbeat
-(void)postMessageToService: (NSNotification*) notification
{
//    NSString* obj = (NSString*)[notification object];//获取到传递的对象
    
//    if ([obj isEqualToString:@"loginMsg"]) {
//        [self sendMessage: @"loginMsg"];
//        //每个120s发送一次
//        if (!_mytimer) {
//            _mytimer = [NSTimer scheduledTimerWithTimeInterval:120.0 target:self selector:@selector(sendTimerMessage:) userInfo:@{@"smsType":@"loginMsg"} repeats:YES];
//        }
//    }
//    if ([obj isEqualToString:@"recoverMsg"]) {
//        [self sendMessage: @"recoverMsg"];
//        //每个300s发送一次
//        if (![vminfo share].recoverTimer) {
//            [vminfo share].recoverTimer = [NSTimer scheduledTimerWithTimeInterval:300.0 target:self selector:@selector(sendTimerMessage:) userInfo:@{@"smsType":@"recoverMsg"} repeats:YES];
//        }
//    }
}

//停止向cu发送消息
-(void)stoppostMessageToservice:(NSNotification*) notification
{
//    NSString* smsType = (NSString*)[notification object];//获取到传递的对象
//    if ([smsType  isEqual: @"recoverMsg"]) {
//        [[vminfo share].recoverTimer invalidate];
//        [vminfo share].recoverTimer  = nil;
//    }
    //if ([smsType  isEqual: @"loginMsg"]) {
    //    [_mytimer invalidate];
    //    _mytimer = nil;
    //}
//    NSLog(@"停止发送%@信息!", smsType);
}

//NStimer的回调方法只能是不带参数的方法或者是带参数但是参数本身只能是NStimer的方法,有多个rdp应用时才适用
-(void)sendTimerMessage:(NSTimer*) timer{
    NSString *smsType = [timer.userInfo objectForKey:@"smsType"];
    [self sendMessage:smsType];
}

//往cu发送信息
-(void)sendMessage:(NSString*) smsType
{
    NSString *ip=[vminfo share].cuIp;
    NSString *handleUrl = [NSString stringWithFormat:@"%@", ip];
    NSMutableDictionary *jsonData = [NSMutableDictionary dictionary];
    //NSURL *url=[NSURL URLWithString:handleUrl];
    //NSMutableURLRequest *myrequest=[NSMutableURLRequest requestWithURL:url];
    
    NSString *mytimestr = [[NSUserDefaults standardUserDefaults] objectForKey:@"oneloginuuid"];
    NSLog(@"oneloginuuid:%@", mytimestr);
    
    if ([smsType  isEqual: @"loginMsg"]) {
        handleUrl = [handleUrl stringByAppendingString:@"cu/index.php/Home/Client/updateLoginStatus"];
        [jsonData setObject:mytimestr forKey:@"key"];
        [jsonData setObject:@"IOS" forKey:@"type"];
        [jsonData setObject:[vminfo share].uid forKey:@"userid"];
        NSLog(@"准备发送loginMsg信息");
    }
    
    if([smsType  isEqual: @"recoverMsg"]) {
        handleUrl = [handleUrl stringByAppendingString:@"cu/index.php/Home/Client/UpdateAppUseStatus"];
        jsonData = [vminfo share].multiRdpRecoverInfo;
        NSLog(@"准备发送recoverMsg信息");
    }
    
    NSLog(@"发起请求的url：%@", handleUrl);
    [self makeRequestToServer:handleUrl withDictionary:jsonData byHttpMethod:@"POST" msgType:smsType];
}

//向服务器发起请求，因是异步执行，故返回的数据不能立即得到，所以需要在回调函数里面进行处理，可以采用在参数里面加一个回调函数的参数传入
-(void) makeRequestToServer:(NSString*)urlString withDictionary:(NSDictionary*)dic byHttpMethod:(NSString*) method msgType:(NSString*)smsType {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:method];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    NSData *sendData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
    request.HTTPBody = sendData;
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    
    NSURLSessionDataTask *sessionData = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data,NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSLog(@"发送%@信息成功！", smsType);
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"发送信息的请求返回状态码：%ld", (long)httpResponse.statusCode);
        if(data) {
            if ([smsType  isEqual: @"loginMsg"]) {
                NSDictionary *dic=[NSJSONSerialization JSONObjectWithData:data options:NSJSONWritingPrettyPrinted error:nil];
                NSNumber *mycode=[dic objectForKey:@"code"];
                //如果返回值是800(成功)
                if ([mycode isEqualToNumber:[NSNumber numberWithLong:800]]) {
                    NSLog(@"登陆信息正确");
                }
                else if([mycode isEqualToNumber:[NSNumber numberWithLong:814]])
                {
                    [self callJsLogoff];
                }
            } else if([smsType  isEqual: @"recoverMsg"]) {
                NSDictionary *dic=[NSJSONSerialization JSONObjectWithData:data options:NSJSONWritingPrettyPrinted error:nil];
                NSDictionary *myDic = [dic objectForKey:@"code"];
                NSNumber *mycode = [myDic objectForKey:@"code"];
                if ([mycode isEqualToNumber:[NSNumber numberWithLong:800]]) {
                    NSLog(@"恢复应用信息服务器确认正确！");
                } else if([mycode isEqualToNumber:[NSNumber numberWithLong:907]]) {
                    NSLog(@"恢复应用信息服务器确认数据库出问题！");
                } else if([mycode isEqualToNumber:[NSNumber numberWithLong:941]]) {
                    NSLog(@"恢复应用信息服务器确认redis出问题！");
                } else if([mycode isEqualToNumber:[NSNumber numberWithLong:1206]]) {
                    NSLog(@"恢复应用信息服务器确认更新应用使用记录的state字段失败出问题！");
                } else {
                    NSLog(@"恢复应用信息服务器出现不可预料的问题!");
                }
                NSLog(@"收到的恢复rdp的返回信息：%@", str);
            }
        }
    }];
    [sessionData resume]; //如果request任务暂停了，则恢复
    [session finishTasksAndInvalidate];
}

//登陆超时处理的函数
-(void)callJsLogoff
{
    NSString *textJS=@"window.client.exit(true);";
    [context evaluateScript:textJS];
    [_mytimer invalidate];
    [_mytimer release];
    _mytimer = nil;
}

#pragma mark sendMessageToDocker

//将docker的信息封装，发送给服务器
-(void)sendMessageToDocker
{
    NSString *Reset_vm_User=[NSString stringWithFormat:@"%@cu/index.php/Home/Client/sendMessageToDockerManager",_connectInfo.cuIp];
    NSDictionary *json = @{
                         @"action":@"update",
                         @"dockerid":_connectInfo.dockerId,
                         @"ip":_connectInfo.dockerIp,
                         @"userid":_connectInfo.uid,
                         @"appid":_connectInfo.appid
                         };
    [[[CommonUtils alloc] init] makeRequestToServer:Reset_vm_User withDictionary:json byHttpMethod:@"POST" type:@"sendMessageToDocker函数"];
}

#pragma mark -
#pragma mark 支付宝相关方法
-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSURL *reqUrl = request.URL;
    NSString* urlStr = [reqUrl.absoluteString stringByRemovingPercentEncoding];
    NSLog(@"访问的url地址是:%@", urlStr);
    
    if ([urlStr hasPrefix:@"http://"] || [urlStr hasPrefix:@"https://"]) {
        NSURLRequest *checkRequest = request;
        if ([urlStr containsString:@"owncloud"]) {
            NSString *replacedString = [NSString stringWithFormat:@"?%@", [reqUrl query]];
            if (replacedString) {
                NSString *urlString = [urlStr stringByReplacingOccurrencesOfString:replacedString withString:@""];
                NSURL *checkUrl = [NSURL URLWithString:urlString];
                checkRequest = [NSURLRequest requestWithURL:checkUrl];
                NSLog(@"checkUrl:%@", urlString);
            }
        }

        NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:checkRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            NSHTTPURLResponse *tmpresponse = (NSHTTPURLResponse*)response;
            NSLog(@"statusCode:%ld", (long)tmpresponse.statusCode);
            long statusCode = (long)tmpresponse.statusCode;

            if(statusCode >= 400) {
                NSLog(@"返回的网络状态码不对，返回上一个页面!");
                if ([webView canGoBack]) {
                    [webView goBack];
                } else {
                    [webView stopLoading];
                }
            } else if(statusCode == 0) {
                [webView stopLoading];
                UIWindow *window = [UIApplication sharedApplication].keyWindow;
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [window makeToast:NSLocalizedString(@"请检查网络！正在跳回登录界面！", @"please check your network! Jump to login page！") duration:2.0 position:@"center"];
                });
                NSString *filePath = [[NSBundle mainBundle] pathForResource:@"index"  ofType:@"html" inDirectory:@"iplogin"];
                filePath = [NSString stringWithFormat:@"%@?isAutoLogin=0", filePath]; //1代表应用第一次打开登录页面
                NSURL *url = [NSURL URLWithString:filePath];
                NSURLRequest *request = [NSURLRequest requestWithURL:url];
                [webView loadRequest:request];
            }
        }];
        [dataTask resume];
    }

    //支付宝进入支付环节经历的网址跳转的8个步骤
    //1. https://openapi.alipay.com/gateway.do?charset=UTF-8
    //2. https://unitradeprod.alipay.com/appAssign.htm?alipay_exterface_invoke_assign_target=invoke_f92939685a8a14b982d324a9bc1f6e1e&alipay_exterface_invoke_assign_sign=e_al9k8_jk4r7_pxonth_t0_be_j_m_hvjci_o_gcq_i7_s_e_npm_a_v6er_s47h_vd_t7_iw%3D%3D
    //3. https://unitradeprod.alipay.com/appAssign.htm?alipay_exterface_invoke_assign_target=invoke_f92939685a8a14b982d324a9bc1f6e1e&alipay_exterface_invoke_assign_sign=e_al9k8_jk4r7_pxonth_t0_be_j_m_hvjci_o_gcq_i7_s_e_npm_a_v6er_s47h_vd_t7_iw%3D%3D
    //4. https://excashier.alipay.com/standard/auth.htm?payOrderId=c9d7941465ae41509c643f532e64bfb5.60
    //5. about:blank
    //6. about:blank
    //7. alipays://platformapi/startApp?appId=10000007&sourceId=excashierQrcodePay&actionType=route&qrcode=https%3A%2F%2Fqr.alipay.com%2Fupx00279er7br22tzsny6051
    //8. about:blank
    
    if ([vminfo share].cuIp && [urlStr containsString:[vminfo share].cuIp]) {
        [self removeAlipayFloatButton];
    }
    
    //判断是否是阿里支付的url
    if ([urlStr hasPrefix:@"alipays://"] || [urlStr hasPrefix:@"alipay://"]) {
        [self loadAlipayFloatButton];
        //支付宝是否已经安装
        BOOL isExist = [[UIApplication sharedApplication] canOpenURL:reqUrl];
        if (!isExist) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"未检测到支付宝客户端，请安装后重试!" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                //跳转itune下载支付宝App
                NSString* urlStr = @"https://itunes.apple.com/cn/app/zhi-fu-bao-qian-bao-yu-e-bao/id333206289?mt=8";
                NSURL *downloadUrl = [NSURL URLWithString:urlStr];
                [[UIApplication sharedApplication] openURL:downloadUrl options:[NSDictionary dictionary] completionHandler:^(BOOL success) {
                    NSLog(@"成功打开打开app store!");
                }];
            }]; // end of UIAlertController
            [alert addAction:action];
            //放到主线程中
            dispatch_async(dispatch_get_main_queue(), ^{
                [self presentViewController:alert animated:YES completion:^{
                }];
            }); //end of dispatch_async
            _isNotFirstLoad = YES;
        }//end of if
    } else if(![urlStr containsString:@"alipay"] && ![urlStr isEqualToString:@"about:blank"]) {
        if (_isNotFirstLoad) {
            [myWebView removeFromSuperview];
            myWebView = [[UIWebView alloc] initWithFrame:[UIScreen mainScreen].bounds];;
            [self.view addSubview:myWebView];
            myWebView.delegate = self;
            myWebView.scrollView.bounces = NO;
            [myWebView loadRequest:request];
            //reset the firstload flag to load the new request
            [(UIScrollView *)[[myWebView subviews] objectAtIndex:0] setBounces:NO];
            _isNotFirstLoad = NO;
            return NO;
        }
        _isNotFirstLoad = YES;
    }
    return YES;
}

//暂时未使用
- (void)loadWithUrlStr:(NSString*)urlStr
{
    if (urlStr.length > 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSURLRequest *webRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]
                cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:30];
            [myWebView loadRequest:webRequest];
        });
    }
}

//悬浮按钮的点击事件
- (void)floatTapAction:(MyFloatButton *)sender{
    [[self view] makeToast:NSLocalizedString(@"马上返回cu界面", @"come back to cu interface") duration:2.0 position:@"center"];  //ToastDurationShort
    NSString *cuurl=[NSString stringWithFormat:@"%@cu/",[vminfo share].cuIp];
    NSLog(@"cuurl:%@", cuurl);
    NSURLRequest *myrequest=[NSURLRequest requestWithURL:[NSURL URLWithString:cuurl]];
    [self performSelector:@selector(loadCuPage:) withObject:myrequest afterDelay:1.0f];
    
    //_isNotFirstLoad = YES;
}
//支付宝返回cu界面
-(void) loadCuPage:(NSURLRequest*) myrequest {
    [UIView animateWithDuration:1.0f animations:^{
        [myWebView removeFromSuperview];
        myWebView = nil;
        [myWebView autorelease];
        myWebView = [[UIWebView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        [self.view addSubview:myWebView];
        myWebView.delegate = self;
        [myWebView loadRequest:myrequest];
    }];
}

//加载支付宝支付的浮动按钮
- (void) loadAlipayFloatButton {
    _myfloatbutton.hidden=NO;
    [self.view addSubview:_myfloatbutton];
}

-(void)initMyFloatButton
{
    if(!_myfloatbutton) {
        _myfloatbutton=[[MyFloatButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 60, SCREEN_HEIGHT-176, 46, 46)];
        [vminfo share].mypoint = CGPointMake(SCREEN_WIDTH - 60, SCREEN_HEIGHT - 176);
        _myfloatbutton.alpha=0.5;
        _myfloatbutton.delegate=self;
        
        UIColor *fontIconColor = [UIColor colorWithRed:210/255.0 green:210/255.0 blue:210/255.0 alpha:0.8];
        NSString *fontIcon = [NSString fontAwesomeIconStringForEnum:FAIconArrowLeft];
        UIImage *menuPicWithAlpha = [CommonUtils imageByApplyingAlpha:0.8 image:[UIImage imageNamed:@"menu.png"]];
        
        _myfloatbutton.bannerIV.image= [CommonUtils text:fontIcon addToView:menuPicWithAlpha textColor:fontIconColor textSize:38];
        _myfloatbutton.hidden=YES;
    }
}
//移除支付宝支付的浮动按钮
- (void) removeAlipayFloatButton {
    if(_myfloatbutton) {
        _myfloatbutton.hidden = YES;
        [self.view willRemoveSubview:_myfloatbutton];
    }
}

#pragma mark 屏幕旋转
-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    CGAffineTransform transform;
    transform = CGAffineTransformRotate(myWebView.transform, M_PI/2.0);
    [UIView beginAnimations:@"roate" context:nil];
    [UIView setAnimationDuration:0.4];
    [UIView setAnimationDelegate:self];
    [UIView animateWithDuration:0.4 animations:^{
        myWebView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    }];
    
    if(_myfloatbutton)
    {
        CGPoint m = [vminfo share].mypoint;
        CGFloat myheight = [UIScreen mainScreen].bounds.size.height;
        CGFloat mywidth = [UIScreen mainScreen].bounds.size.width;
        [_myfloatbutton setLimitRange:myheight andWidth:mywidth];
        float x = m.x;
        float y = m.y;
        
        CGPoint m2 = CGPointZero;
        
        if( x < SCREEN_WIDTH / 2)  //left
        {
            m2.x = 37 ;
        }
        else     //right
        {
            m2.x = mywidth - 37;
        }
        
        if( y > myheight)  //超过了
        {
            m2.y = myheight - 37;
        }
        else
        {
            m2.y = y;
        }
        
        
        [UIView animateWithDuration:0.4 animations:^{

            [_myfloatbutton setCenter:m2];
            [vminfo share].mypoint = m2;
        }];
    }
    
    [UIView commitAnimations];
}


#pragma mark MD5校验
-(NSString *)fileMD5:(NSString *)indexPath{
    NSFileHandle *handle = [NSFileHandle fileHandleForReadingAtPath:indexPath];
    if ( handle == nil ) {
        return @"ERROR GETTING FILE MD5";
    }
    CC_MD5_CTX md5;
    CC_MD5_Init(&md5);
    BOOL done = NO;
    while (!done) {
        NSData * fileData = [handle readDataOfLength:256];
        CC_MD5_Update(&md5, [fileData bytes], [fileData length]);
        if( [fileData length] == 0 ) done = YES;
    }
    
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5_Final(digest, &md5);
    
    NSString * s =[NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                   digest[0],digest[1],
                   digest[2],digest[3],
                   digest[4],digest[5],
                   digest[6],digest[7],
                   digest[8],digest[9],
                   digest[10],digest[11],
                   digest[12],digest[13],
                   digest[14],digest[15]];
    return s;
}

-(BOOL)MD5check
{
    
    NSString *filepath= [[NSBundle mainBundle] pathForResource:@"index" ofType:@"html" inDirectory:@"iplogin"];
    NSString *resultMD5=[self fileMD5:filepath];
    NSLog(@"resultMD5:%@", resultMD5);
    if ([resultMD5 isEqualToString:LOCALMD5]) {
        return YES;
    } else {
        [self showMD5CheckAlert]; //错误提示
        return NO;
    }
}
//md5校验 错误提示信息
-(void)showMD5CheckAlert
{
    
    SCLAlertViewBuilder *builder = [SCLAlertViewBuilder new]
    .addButtonWithActionBlock(@"退出", ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"appEnterbackGround" object:nil];
    });
    SCLAlertViewShowBuilder *showBuilder = [SCLAlertViewShowBuilder new]
    .style(SCLAlertViewStyleError)
    .title(@"错误")
    .subTitle(@"本地文件被篡改，无法打开")
    .duration(0);
    [showBuilder showAlertView:builder.alertView onViewController:self];
    
}

//传入的参数错误，提示错误信息
-(void)showParamErrorMessage
{
    SCLAlertViewBuilder *builder = [SCLAlertViewBuilder new]
    .addButtonWithActionBlock(@"确定", ^{});
    SCLAlertViewShowBuilder *showBuilder = [SCLAlertViewShowBuilder new]
    .style(SCLAlertViewStyleError)
    .title(@"错误")
    .subTitle(@"参数错误，无法打开")
    .duration(0);
    [showBuilder showAlertView:builder.alertView onViewController:self];
}


#pragma mark -
#pragma mark 屏幕方向相关

static void screenLockStateChanged(CFNotificationCenterRef center,void * observer,CFStringRef name,const void *object,CFDictionaryRef userInfo) {
    NSString* lockstate = (__bridge NSString*)name;
    //换了一种方式使用了苹果的私有api（setOrientation:），在appstore上架可能会被拒
    if ([lockstate isEqualToString:(__bridge  NSString*)NotificationLock]) {
        if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
            SEL selector = NSSelectorFromString(@"setOrientation:");
            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
            [invocation setSelector:selector];
            [invocation setTarget:[UIDevice currentDevice]];
            int val = UIInterfaceOrientationPortrait;
            [invocation setArgument:&val atIndex:2];
            [invocation invoke];
        }
//        NSLog(@"locked.");
    }
//    else {
//        NSLog(@"lock state changed.");
//    }
}


#pragma mark - dealloc
-(void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, screenLockStateChanged, NotificationChange, NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
    CFNotificationCenterRemoveEveryObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL);
    
    _myfloatbutton = nil;
    _mytimer = nil;
    
    context = nil;
    cuIp = nil;
    innerCuUrl = nil;
    myWebView = nil;
    innerNet = nil;
    _connectInfo = nil;
    
    [super dealloc];
}
@end
