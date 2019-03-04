//
//  JSCallOc.m
//  FreeRDP
//
//  Created by conan on 2018/7/27.
//
//

#import "JSCallOc.h"

@implementation JSCallOc

-(void)openIOSApp:(NSString*)data {
    [self AcceptTheDataFromJs:data];
}

/*****************************
 **parameter：json数据
 **function：解析并且保存json数据
 *****************************/
-(void)AcceptTheDataFromJs:(NSString *)data
{
    NSLog(@"准备打开应用,开始接收cu发送过来的rdp的连接信息！");
    NSData *str=[data dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err=nil;
    _dic = [NSJSONSerialization JSONObjectWithData:str options:NSJSONReadingMutableLeaves error:&err];
    NSAssert( _dic!= nil, @"接收到的json数据不能为空！");
    
    NSLog(@"收到的服务端发来的打开远程应用的连接信息：%@",_dic);
   
//    NSString *arguments = [_dic objectForKey:@"arguments"];
//    NSArray *argumentsArray = [arguments componentsSeparatedByString:@","];
    
    //解析json数据保存到vminfo中
    vminfo *myinfo = [vminfo share];
    myinfo.tsip=[_dic objectForKey:@"tsip"];
    myinfo.tsport=[_dic objectForKey:@"tsport"];
    myinfo.tspwd=[_dic objectForKey:@"tspwd"];
    myinfo.tsusername=[_dic objectForKey:@"tsusername"];
    myinfo.vmip=[_dic objectForKey:@"vmip"];
    myinfo.vmport=[_dic objectForKey:@"vmport"];
    myinfo.vmpasswd=[_dic objectForKey:@"vmpsswd"];
    myinfo.vmusername=[_dic objectForKey:@"vmusername"];
    NSString* remoteProgram= [_dic objectForKey:@"remoteProgram"];
    myinfo.appid = [_dic objectForKey:@"id"];    
     //docker应用处理
    NSString *apptype=[_dic objectForKey:@"appType"];
    myinfo.apptype = apptype;
    if([apptype isEqualToString:@"lca"])
    {
        myinfo.dockerId=[_dic objectForKey:@"docker_id"];
        myinfo.dockerIp=[_dic objectForKey:@"docker_ip"];
        myinfo.dockerVncPwd=[_dic objectForKey:@"docker_vncpwd"];
        myinfo.dockerPort=[_dic objectForKey:@"docker_port"];
        myinfo.appid=[_dic objectForKey:@"id"];
        NSString *str1=@"/password";
        remoteProgram=[NSString stringWithFormat:@"%@ %@ %@ %@:%@",remoteProgram,str1,myinfo.dockerVncPwd,myinfo.dockerIp,myinfo.dockerPort];
    }
    
    NSDictionary *arguments = [_dic objectForKey:@"arguments"];
    NSMutableDictionary *openerArguments;
    if (arguments) {
        openerArguments = [NSMutableDictionary dictionaryWithDictionary:arguments];
        
        if (![arguments objectForKey:@"is_document"]) {
            [openerArguments setValue:@"0" forKey:@"is_document"];
        } else {
            [openerArguments setValue:@"1" forKey:@"is_document"]; //将传的整型1改为字符串“1”，否则opener那边会出问题，垃圾opener
        }
    } else {
        openerArguments = [NSMutableDictionary dictionary];
        [openerArguments setValue:@"0" forKey:@"is_document"];
    }
    [openerArguments setValue:remoteProgram forKey:@"programpath"];
    [openerArguments setValue:@"15" forKey:@"timeout"];
    [openerArguments setValue:myinfo.vmpasswd forKey:@"vmpassword"];
    
    [openerArguments setValue:myinfo.RandomCode forKey:@"RandomCode"]; //打开应用，需要加上这个随机码，给agant用来建立命名管道
    
    //检查参数是否为空，如果为空则删除该条参数。垃圾opener无法处理参数为空的问题
    NSString *argumentValue;
    for (argumentValue in [openerArguments allKeys]) {
        if ([@"" isEqualToString:[openerArguments objectForKey:argumentValue]]) {
            [openerArguments removeObjectForKey:argumentValue];
        }
    }
    
    NSString *tmp1 = [CommonUtils dictionaryToJson:openerArguments];
    NSString *tmp2 = [tmp1 stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""]; //windows的斜杠字符转码
    
    myinfo.remoteProgram = [NSString  stringWithFormat:@"opener.exe %@", tmp2];
    NSLog(@"myinfo.remoteProgram:  %@", myinfo.remoteProgram);
    
    tmp1 = nil;
    tmp2 = nil;
    openerArguments = nil;
    remoteProgram = nil;
    argumentValue = nil;
    
    //接收的数据不为空则可以调用来打开RDP
    BOOL is_every_param_ok = YES;
    
    if(!myinfo.vmusername || !myinfo.vmpasswd || !myinfo.vmip || !myinfo.vmport )
    {
        is_every_param_ok = NO;
    }
    if([[vminfo share].gatewaycheck isEqualToString:@"YES"])
    {
        if(!myinfo.tsip || !myinfo.tspwd ||!myinfo.tsport || !myinfo.tsusername)
        {
            is_every_param_ok = NO;
        }
    }
    if([apptype isEqualToString:@"lca"])
    {
        if(!myinfo.dockerId || !myinfo.dockerIp || !myinfo.dockerPort
           ||!myinfo.dockerVncPwd || !myinfo.appid)
            
        {
            is_every_param_ok = NO;
        }
    }
    
    if(is_every_param_ok)
    {
        [self sendOpenRdpNotification];

    }else
    {
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"paramErrorMessage" object:nil];
    }
    
}

/*****************************
 
 **parameter：无
 **function：向消息中心发送“openRdp”的消息，cuWebVC中用于处理该事件
 
 *****************************/
-(void)sendOpenRdpNotification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"openRdp" object:nil];
}

/*******
 **parameter：json数据
 **function：解析json数据中的uid，向服务器发送心跳
*******/
-(void)AcceptUidAndKeepHeartBeat:(NSString *)data
{
    //解析保存uid
    NSData *str=[data dataUsingEncoding:NSUTF8StringEncoding];
    NSError * err;
    NSDictionary *mydic=[NSJSONSerialization JSONObjectWithData:str options:NSJSONReadingMutableLeaves error:&err];
    
    NSAssert(mydic!=nil, @"数据为空，解析uid失败!");
    
    NSString *operation=[mydic objectForKey:@"operation"];
    
    if([operation isEqualToString:@"setIp"])
    {

        NSString * url = [mydic objectForKey:@"url"];
        [vminfo share].cuIp = [NSString stringWithFormat:@"http://%@/", url];
        //默认处理这种格式的字符串“http://google.com/”(可以带端口号)
        NSMutableString *mUrl = [NSMutableString stringWithString:url];
        if ([mUrl containsString:@"http://"]) {
            [mUrl deleteCharactersInRange:[mUrl rangeOfString:@"http://"]];
        }
        if ([mUrl containsString:@"https://"]) {
            [mUrl deleteCharactersInRange:[mUrl rangeOfString:@"https://"]];
        }
        if ([mUrl containsString:@"/"]) {
            [mUrl deleteCharactersInRange:[mUrl rangeOfString:@"/"]];
        }
        
        int isInnerIP = [CommonUtils isInnerIP:mUrl];
        //-1代表错误，1代表外网，0代表内网
        if(isInnerIP == -1) {
            NSLog(@"无法判断内外网！凉凉..........");
        } else if(isInnerIP == 0) {
            [vminfo share].gatewaycheck = @"NO";
            NSLog(@"是内网！");
        } else if(isInnerIP == 1) {
            [vminfo share].gatewaycheck = @"YES";
            NSLog(@"是外网！");
        }
        
    }
    if([operation isEqualToString:@"setUserId"])
    {
        //解析出了uid，通过vminfo共享数据
        NSString *uid=[mydic objectForKey:@"userID"];
        [vminfo share].uid=uid;
    }

    
    
    //发送通知，向服务器发送消息
    //[[NSNotificationCenter defaultCenter] postNotificationName:@"postMessageToservice" object:@"loginMsg"];

}
//注销的时候
-(void)StopHeartBeat:(id)num
{
     //[[NSNotificationCenter defaultCenter] postNotificationName:@"stoppostMessageToservice" object:@"loginMsg"];
    //注销后返回到iplogin界面
    NSDictionary *dic = @{@"filename":@"index",
                          @"dirname":@"iplogin"
                          };
    [[NSNotificationCenter defaultCenter] postNotificationName:@"loadLocalHTML" object:nil userInfo:dic];
}

//获取cu地址
-(void) getCUAddress:(NSString *)ipUrl {
    NSData *str=[ipUrl dataUsingEncoding:NSUTF8StringEncoding];
    NSError * err;
    NSDictionary *mydic=[NSJSONSerialization JSONObjectWithData:str options:NSJSONReadingMutableLeaves error:&err];
    NSString *url=[mydic objectForKey:@"url"];
    [vminfo share].cuIp = [NSString stringWithFormat:@"http://%@/", url];
    NSLog(@"收到的ipurl:%@", url);

    //默认处理这种格式的字符串“http://google.com/”(可以带端口号)
    NSMutableString *mUrl = [NSMutableString stringWithString:url];
    if ([mUrl containsString:@"http://"]) {
        [mUrl deleteCharactersInRange:[mUrl rangeOfString:@"http://"]];
    }
    if ([mUrl containsString:@"https://"]) {
        [mUrl deleteCharactersInRange:[mUrl rangeOfString:@"https://"]];
    }
    if ([mUrl containsString:@"/"]) {
        [mUrl deleteCharactersInRange:[mUrl rangeOfString:@"/"]];
    }
    
    int isInnerIP = [CommonUtils isInnerIP:mUrl];
    //-1代表错误，1代表外网，0代表内网
    if(isInnerIP == -1) {
        NSLog(@"无法判断内外网！凉凉..........");
    } else if(isInnerIP == 0) {
        [vminfo share].gatewaycheck = @"NO";
        NSLog(@"是内网！");
    } else if(isInnerIP == 1) {
        [vminfo share].gatewaycheck = @"YES";
        NSLog(@"是外网！");
    }
}

-(void)appEnterBackground:(id)num
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"appEnterbackGround" object:nil];
}

@end
