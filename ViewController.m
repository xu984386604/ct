//
//  ViewController.m
//  FreeRDP
//
//  Created by conan on 15/12/10.
//
//

#import "ViewController.h"
#import "Utils.h"
#import "RDPSessionViewController.h"
#import "Toast+UIView.h"
//#import "Reachability.h"
#import "GlobalDefaults.h"
#import "BlockAlertView.h"
#import "vminfo.h"
#import "MBProgressHUD/MBProgressHUD+CZ.h"
#import "EditViewController.h"
#import "NavigationController.h"
//#import "NavigationController.h"
//#import "Source/DZWebBrowser.h"

@interface ViewController ()<NSXMLParserDelegate>

@property (assign) IBOutlet UITextField *accountField;
@property (assign) IBOutlet UITextField *passwordField;
@property (assign) IBOutlet UIButton *loginBtn;
@property (assign) IBOutlet UISwitch *switchBtn;
@property(nonatomic,strong) NSMutableString *elementString;
@property (nonatomic,strong) vminfo *vmvm;
@property (nonatomic,copy) NSString *urlstr;

- (void)readManualBookmarksFromDataStore;
- (void) tranferRDPPrama:(vminfo *) vmvm;
- (void) connectToServer;

@end

@implementation ViewController

- (NSMutableString *)elementString
{
    if (_elementString == nil) {
        _elementString = [NSMutableString string];
    }
    return _elementString;
}
//每回pop会调用这个函数
- (void)viewDidAppear:(BOOL)animated {
    NSUserDefaults *IPDefualt = [NSUserDefaults standardUserDefaults];
    if([IPDefualt objectForKey:@"IP"] && [IPDefualt objectForKey:@"port"]){
        NSString *IP = [IPDefualt stringForKey:@"IP"];
        NSString *port = [IPDefualt stringForKey:@"port"];
//        NSLog(@"http://%@:%@/cloudap/openrdp/get_vm_info.php",IP,port);
    self.urlstr = [NSString stringWithFormat:@"http://%@:%@/cloudap/openrdp/get_vm_info.php",IP,port];
 //       NSLog(@"%@",_urlstr);
    }

}
    

- (void)viewDidLoad {
    [super viewDidLoad];
//    self.elementString = [NSMutableString string];

    // init reachability detection发现
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    NSLog(@"%@",NSHomeDirectory());
    // Do any additional setup after loading the view from its nib.
    UIBarButtonItem *settingButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit  target:self action:@selector(settingIP:)];
    self.navigationItem.rightBarButtonItem = settingButton;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)login {
//    NSLog(NSHomeDirectory());
//    [MBProgressHUD showMessage:@"正在登录中。。。"];
//    [self connectToServer];
//    [self readManualBookmarksFromDataStore];
//    NSString *pwd = [self base64Encode:self.passwordField.text];
//    NSString *cac028 = [self base64Encode:@"cac028"];
//   cac028 = [cac028 stringByAppendingString:pwd];
////    NSLog(cac028);
//    NSString *pwd2 = [self base64Encode:cac028];
    
//    NSLog(pwd2);
    
//    NSString *pwdss = [self base64Decode:pwd];
//    NSLog(pwdss);
//    [self testInner];
   [self readManualBookmarksFromDataStore];
//    [self testouter];


}
//将用户名密码传递给服务器，接收返回的xml数据
- (void) connectToServer
{
    NSString *username = self.accountField.text;
    NSString *pwd = [self base64Encode:self.passwordField.text];
    NSString *cac028 = [self base64Encode:@"cac028"];
    cac028 = [cac028 stringByAppendingString:pwd];
    NSString *password = [self base64Encode:cac028];
    NSLog(@"%@",password);
//    password =[NSString stringWithFormat:@"WTJGak1ESTQKTVRFeE1URXgK"];
//    NSString *password = self.passwordField.text;
    NSString *bodyStr;
//    NSString *urlstr = [NSString stringWithFormat:@"http://172.20.12.9/openrdp/get_vm_info.php"];
    NSLog(@"%@",self.urlstr);
    NSURL *url = [NSURL URLWithString:_urlstr];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:1 timeoutInterval:2.0f];
    request.HTTPMethod = @"POST";
    //外网连接需传入public_net 参数
    if (self.switchBtn.isOn) {
        NSString *public_net = [NSString stringWithFormat:@"on"];
        bodyStr = [NSString stringWithFormat:@"username=%@&password=%@&public_net=%@", username, password,public_net];
        NSLog(@"%@",bodyStr);
    }
    else {
        bodyStr = [NSString stringWithFormat:@"username=%@&password=%@", username, password];
        bodyStr = [bodyStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSLog(@"%@",bodyStr);
        
    }
    request.HTTPBody = [bodyStr dataUsingEncoding:NSUTF8StringEncoding];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        NSString *result  =[[ NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                NSLog(@"%@",result);
        NSXMLParser *parse = [[NSXMLParser alloc] initWithData:data];

        // 2. 设置代理
        parse.delegate = self;
        
        // 3. 解析器开始解析
        [parse parse];
        
    }];
    
    
    
}

#pragma mark - 代理方法，解析XML数据
//1.打开文档, 准备开始解析
- (void)parserDidStartDocument:(NSXMLParser *)parser
{
       // NSLog(@"1. 打开文档, 准备开始解析");
}

//2.开始节点
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
        NSLog(@"2.开始节点%@---%@", elementName, attributeDict);
    //如果开始节点是vminfo，创建vmvm对象
    if ([elementName isEqualToString:@"vminfo"]) {
        self.vmvm = [[vminfo alloc] init];

    }
    // 清空字符串的内容，因为马上要进入第3 个方法，要开始拼接当前的节点的内容
    [self.elementString setString:@""];
}

//3. 发现节点里面内容
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    
    [self.elementString appendString:string];
}

//4. 结束节点
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    // cocoa 的大招 KVC
    if ([elementName isEqualToString:@"object"] || [elementName isEqualToString:@"vminfo"] || [elementName isEqualToString:@"gateinfo"]) {
            NSLog(@"4. 结束节点 %@", elementName);
    } else {
        [self.vmvm setValue:self.elementString forKeyPath:elementName];
        if ([elementName isEqualToString:@"remoteProgram"]) {
            self.vmvm.remoteProgram = [self.vmvm.remoteProgram stringByAppendingString:[NSString stringWithFormat:@" %@ %@",self.accountField.text,self.passwordField.text]];
            NSLog(@"%@",self.vmvm.remoteProgram);
        }
    }
    
}


//5 结束文档
- (void)parserDidEndDocument:(NSXMLParser *)parser
{
    NSLog(@"结束了");
    //一定要注意把elementstring设置为nil，要不然下一次进入登陆view的时候，编译器会认为element不为空就不会进行懒加载，然而在elementstring在进入其他view时，所指的内存空间已将消失了，这将会出现试图给已经释放的对象赋值的内存错误，EXC_BAD_ACCESS；
    _elementString = nil;

    [MBProgressHUD hideHUD];
    //主线程更新UI
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.vmvm.vm isEqualToString:@"1"]) {
            [MBProgressHUD showSuccess:@"登陆成功，准备连接远程应用"];
                [self tranferRDPPrama:self.vmvm];
        }
        else {
            [MBProgressHUD showError:@"用户名或密码不正确，请重新输入"];
            [MBProgressHUD hideHUD];
        }
    });
 
}

//为远程连接参数赋值
- (void) tranferRDPPrama:(vminfo *) vmvm {
    ComputerBookmark *bookmark = [[[ComputerBookmark alloc] initWithBaseDefaultParameters] autorelease];

    //内网参数
    [[bookmark params] setValue:self.vmvm.vmip forKey:@"hostname"];
    [[bookmark params] setValue:self.vmvm.vmusername forKey:@"username"];
    [[bookmark params] setValue:self.vmvm.vmpasswd forKey:@"password"];
    [[bookmark params] setValue:self.vmvm.vmport forKey:@"port"];
        [[bookmark params] setValue:self.vmvm.remoteProgram forKey:@"remote_program"];
    //外网相关参数设置
    if ([vmvm.gate isEqualToString:@"1"]) {
            [[bookmark params] setBool:YES forKey:@"enable_tsg_settings"];
    }
//    [[bookmark params] setValue:@"121.49.107.5" forKey:@"tsg_hostname"];
    [[bookmark params] setValue:self.vmvm.gatehost forKey:@"tsg_hostname"];
//    NSLog(self.vmvm.gatehost);
    [[bookmark params] setValue:self.vmvm.gateusername forKey:@"tsg_username"];
    [[bookmark params] setValue:self.vmvm.gatepasswd forKey:@"tsg_password"];
    [[bookmark params] setValue:self.vmvm.gateport forKey:@"tsg_port"];
    CGRect rect = [[UIScreen mainScreen] bounds];
    CGSize size = rect.size;
    int width =(int) size.width;
    int height =(int) size.height;
    [[bookmark params] setInt:height*2 forKey:@"width"];
    [[bookmark params] setInt:width*2 forKey:@"height"];
    NSLog(@"%@",[bookmark params]);
    
    RDPSession* session = [[[RDPSession alloc] initWithBookmark:bookmark] autorelease];
    NSLog(@"%@",session);
    //隐藏登录遮罩层
    [MBProgressHUD hideHUD];
    UIViewController* ctrl = [[[RDPSessionViewController alloc] initWithNibName:@"RDPSessionView" bundle:nil session:session] autorelease];
    
    NavigationController *ZS = [[NavigationController alloc] initWithRootViewController:ctrl];
    [self presentViewController:ZS animated:YES completion:NULL];
    
    //    [ctrl setHidesBottomBarWhenPushed:YES];
    
    //    [[self navigationController] pushViewController:ctrl animated:YES];
    [_active_sessions addObject:session];
    
    
}

//测试外网所用函数；
- (void)readManualBookmarksFromDataStore {
    
    ComputerBookmark *bookmark = [[[ComputerBookmark alloc] initWithBaseDefaultParameters] autorelease];
   // [[bookmark params] setValue:@"192.168.1.35" forKey:@"hostname"];
    [[bookmark params] setValue:@"172.20.156.78" forKey:@"hostname"];
         //[[bookmark params] setValue:@"请点击右侧星号图标设置主机(host)ip或域名及登陆帐户信息(credentials)等" forKey:@"hostname"];
     //[[bookmark params] setValue:@"C:\\Program Files (x86)\\CloudTerm\\ct\\ctlogin.exe testzs 111111" forKey:@"remote_program"];
   [[bookmark params] setValue:@"C:\\Program Files (x86)\\Microsoft Office\\root\\Office16\\excel.exe" forKey:@"remote_program"];
    
    [[bookmark params] setValue:@"administrator" forKey:@"username"];
    [[bookmark params] setValue:@"abc.123" forKey:@"password"];
    
  /*  [[bookmark params] setBool:YES forKey:@"enable_tsg_settings"];
//    [[bookmark params] setValue:@"188" forKey:@"tsg_port"];
    //tsg_hostname  tsg_username tsg_password
    [[bookmark params] setValue:@"222.186.209.130" forKey:@"tsg_hostname"];
    [[bookmark params] setValue:@"hellodog" forKey:@"tsg_username"];
    [[bookmark params] setValue:@"ABC.123" forKey:@"tsg_password"];*/
    
    CGRect rect = [[UIScreen mainScreen] bounds];
    CGSize size = rect.size;
    int width =(int) size.width;
    int height =(int) size.height;
    [[bookmark params] setInt:height*2 forKey:@"width"];
    [[bookmark params] setInt:width*2 forKey:@"height"];
    
    
    NSLog(@"%@",[bookmark params]);
    
    RDPSession* session = [[[RDPSession alloc] initWithBookmark:bookmark] autorelease];
    NSLog(@"%@",session);
    //ComputerBookmark* bookmark = nil;
    UIViewController* ctrl = [[[RDPSessionViewController alloc] initWithNibName:@"RDPSessionView" bundle:nil session:session] autorelease];
    
    NavigationController *ZS = [[NavigationController alloc] initWithRootViewController:ctrl];
    [self presentViewController:ZS animated:YES completion:NULL];
    
    //    [ctrl setHidesBottomBarWhenPushed:YES];
    
    //    [[self navigationController] pushViewController:ctrl animated:YES];
    [_active_sessions addObject:session];

}


//测试外网所用函数；
- (void)testouter {
    
//    CGSize size = CGSizeZero;
//    if ([[self delegate] respondsToSelector:@selector(sizeForFitScreenForSession:)])
//        size = [[self delegate] sizeForFitScreenForSession:self];
//    
    
    ComputerBookmark *bookmark = [[[ComputerBookmark alloc] initWithBaseDefaultParameters] autorelease];
    [[bookmark params] setValue:@"172.20.125.102" forKey:@"hostname"];
    [[bookmark params] setValue:@"C:\\Program Files (x86)\\CloudTerm\\ct\\ctlogin.exe admin 111111" forKey:@"remote_program"];
    
    [[bookmark params] setValue:@"administrator" forKey:@"username"];
    [[bookmark params] setValue:@"abc.123" forKey:@"password"];
    
    [[bookmark params] setBool:YES forKey:@"enable_tsg_settings"];
    [[bookmark params] setValue:@"443" forKey:@"tsg_port"];

    //tsg_hostname  tsg_username tsg_password
    [[bookmark params] setValue:@"121.49.107.5" forKey:@"tsg_hostname"];
    [[bookmark params] setValue:@"hellodog" forKey:@"tsg_username"];
    [[bookmark params] setValue:@"ABC.123" forKey:@"tsg_password"];

    [[bookmark params] setInt:0 forKey:@"screen_resolution_type"];
    
    [[bookmark params] setInt:32 forKey:@"colors"];
    [[bookmark params] setBool:YES forKey:@"perf_remotefx"];
    [[bookmark params] setBool:YES forKey:@"perf_font_smoothing"];
    [[bookmark params] setBool:YES forKey:@"perf_desktop_composition"];
    [[bookmark params] setBool:YES forKey:@"perf_window_dragging"];
    [[bookmark params] setBool:YES forKey:@"perf_menu_animation"];
    CGRect rect = [[UIScreen mainScreen] bounds];
    CGSize size = rect.size;
    int width =(int) size.width;
    int height =(int) size.height;
    [[bookmark params] setInt:height*2 forKey:@"width"];
    [[bookmark params] setInt:width*2 forKey:@"height"];
    
    NSLog(@"%d %d ",width,height);
//    NSLog(@"%@",[bookmark params]);
    
    RDPSession* session = [[[RDPSession alloc] initWithBookmark:bookmark] autorelease];
    NSLog(@"%@",session);

    //ComputerBookmark* bookmark = nil;
    UIViewController* ctrl = [[[RDPSessionViewController alloc] initWithNibName:@"RDPSessionView" bundle:nil session:session] autorelease];
    
    NavigationController *ZS = [[NavigationController alloc] initWithRootViewController:ctrl];
    [self presentViewController:ZS animated:YES completion:NULL];
    
//        [ctrl setHidesBottomBarWhenPushed:YES];
    
//    [[self navigationController] pushViewController:ctrl animated:YES];
//    [ctrl setHidesBottomBarWhenPushed:YES];
//    [[self navigationController] pushViewController:ctrl animated:YES];
    NSLog(@"aaaa");
//    [_active_sessions addObject:session];
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/



/*
- (void)dealloc
{

    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [_manual_bookmarks release];
    [_tsxconnect_bookmarks release];
    
    [super dealloc];
}
*/
//base64加密
- (NSString *)base64Encode:(NSString *)str {
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    
    return [data base64EncodedStringWithOptions:0];
}
//base64解密
- (NSString *)base64Decode:(NSString *)str {
    NSData *data = [[NSData alloc] initWithBase64EncodedString:str options:0];
    
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}
//push到设置界面
-(void)settingIP:(id)sender
{
    EditViewController *setView = [[EditViewController alloc] initWithNibName:@"EditViewController" bundle:nil];
    setView.title =@"设置";
    [[self navigationController] pushViewController:setView animated:YES];
    
    
}
//转屏
-(BOOL)shouldAutorotate{
    return YES;
}
//支持的方向竖屏
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}


//键盘响应
-(IBAction)textFieldDoneEditing:(id)sender
{
    [sender resignFirstResponder];
}

@end
