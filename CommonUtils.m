//
//  CommonUtils.m
//  FreeRDP
//
//  Created by conan on 2018/8/4.
//
//

#import "CommonUtils.h"
#import <netdb.h>
#import <arpa/inet.h>
#import "client/iOS/FontAwesome/NSString+FontAwesome.h"

@implementation CommonUtils

/*
 * @brief 把格式化的JSON格式的字符串转换成字典
 * @param jsonString JSON格式的字符串
 * @return 返回字典
 */

//json格式字符串转字典：
+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString {
    if (jsonString == nil) {
        return nil;
    }
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
    
    if(err) {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}

//字典转json格式字符串
+ (NSString*)dictionaryToJson:(NSDictionary *)dic {
    NSError *parseError = nil;
    NSLog(@"开始字典转json格式字符串");
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&parseError];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

//返回当前时间戳的字符串
+ (NSString *)cNowTimestamp {
    NSDate *newDate = [NSDate date];
    long int timeSp = (long)[newDate timeIntervalSince1970];
    NSString *tempTime = [NSString stringWithFormat:@"%ld",timeSp];
    return tempTime;
}

//来自于xxxxxx的时间提醒：yyyy年MM月dd日 HH小时mm分ss秒
+ (NSString *)  currentStandardFormatDate:(NSString *) info  {
    // 获取系统当前时间
    NSDate *date = [NSDate date];
    NSTimeInterval sec = [date timeIntervalSinceNow];
    NSDate *currentDate = [[NSDate alloc] initWithTimeIntervalSinceNow:sec];
    
    //设置时间输出格式：
    NSDateFormatter *df = [[NSDateFormatter alloc] init ];
    [df setDateFormat:@"yyyy年MM月dd日 HH小时mm分ss秒"];
    NSString *na = [df stringFromDate:currentDate];
    na = [NSString stringWithFormat:@"来自于%@的时间提醒：%@", info, na];
    NSLog(@"系统当前时间为：%@",na);
    return na;
}

//判断连接的服务器相对于本机为内网还是外网, -1代表错误，1代表外网，0代表内网
+ (int)isInnerIP:(NSString *)hostName
{
    //去除端口号
    NSRange range = [hostName rangeOfString:@":"];
    if (range.location != NSNotFound) {
        hostName = [hostName substringWithRange:NSMakeRange(0, range.location)];
    }
    BOOL bValid = false;
    bool _isInnerIp = false;
    //NSString to char*
    const char *webSite = [hostName cStringUsingEncoding:NSASCIIStringEncoding];
    if (webSite == NULL) {
        return -1;
    }
    // Get host entry info for given host
    struct hostent *remoteHostEnt = gethostbyname(webSite);
    if (remoteHostEnt == NULL) {
        return -1;
    }
    // Get address info from host entry
    struct in_addr *remoteInAddr = (struct in_addr *) remoteHostEnt->h_addr_list[0];
    if (remoteInAddr == NULL) {
        return -1;
    }
    // Convert numeric addr to ASCII string
    char *sRemoteInAddr = inet_ntoa(*remoteInAddr);
    if (sRemoteInAddr == NULL) {
        return -1;
    }
    NSLog(@"sRemoteInAddr:%s", sRemoteInAddr);
    unsigned int ipNum = str2intIP(sRemoteInAddr);
    
    unsigned int aBegin = str2intIP("10.0.0.0");
    unsigned int aEnd = str2intIP("10.255.255.255");
    unsigned int bBegin = str2intIP("172.16.0.0");
    unsigned int bEnd = str2intIP("172.31.255.255");
    unsigned int cBegin = str2intIP("192.168.0.0");
    unsigned int cEnd = str2intIP("192.168.255.255");
    NSLog(@"ipNum:%u", ipNum);
    _isInnerIp = IsInner(ipNum, aBegin, aEnd) || IsInner(ipNum, bBegin, bEnd) || IsInner(ipNum, cBegin, cEnd);
    if(_isInnerIp)  //( (a_ip>>24 == 0xa) || (a_ip>>16 == 0xc0a8) || (a_ip>>22 == 0x2b0) )
    {
        bValid = 0;//内网
    }else{
        bValid = 1;//外网
    }
    return bValid;
}
unsigned int str2intIP(char* strip) //return int ip
{
    unsigned int intIP;
    if(!(intIP = inet_addr(strip)))
    {
        perror("inet_addr failed./n");
        return -1;
    }
    return ntohl(intIP);
}

bool IsInner(unsigned int userIp, unsigned int begin, unsigned int end)
{
    return (userIp >= begin) && (userIp <= end);
}


#pragma mark - 将文字添加到图片的方法实现

+ (UIImage*)text:(NSString*)text addToView:(UIImage*)image textColor:(UIColor*) color textSize:(CGFloat) fontSize {
    //设置字体样式
    //UIFont *font = [UIFont fontWithName:@"Arial-BoldItalicMT" size:32];
    UIFont *font = [UIFont fontWithName:kFontAwesomeFamilyName size:fontSize];
    color = color ? color : [UIColor redColor];//默认为红色字体
    NSDictionary *dict = @{NSFontAttributeName:font,NSForegroundColorAttributeName:color};
    CGSize textSize = [text sizeWithAttributes:dict];
    //绘制上下文
    UIGraphicsBeginImageContext(image.size);
    [image drawInRect:CGRectMake(0,0, image.size.width, image.size.height)];

    int width = (image.size.width - textSize.width)/2;
    int height = (image.size.height- textSize.height)/2;
    CGRect re = {CGPointMake(width, height), textSize};

    //此方法必须写在上下文才生效
    [text drawInRect:re withAttributes:dict];
    UIImage *newImage =UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}


//图片上添加图片,用于给图片添加水印
+ (UIImage*)image:(UIImage*)image addToImage:(UIImage*)bigImage{
    CGFloat w = bigImage.size.width;
    CGFloat h = bigImage.size.height;
    
    //bitmap上下文使用的颜色空间
    CGColorSpaceRef colorSpace =CGColorSpaceCreateDeviceRGB();
    
    //绘制图形上下文
    CGContextRef ref = CGBitmapContextCreate(NULL, w, h,8,444* bigImage.size.width, colorSpace,kCGImageAlphaPremultipliedFirst);
    
    //给bigImage画图
    CGContextDrawImage(ref,CGRectMake(0,0, w, h), bigImage.CGImage);
    CGContextDrawImage(ref,CGRectMake(w -100,100, image.size.width, image.size.height), image.CGImage);
    
    //合成图片
    CGImageRef imageMasked = CGBitmapContextCreateImage(ref);
    
    //关闭图形上下文
    CGContextClosePath(ref);
    CGColorSpaceRelease(colorSpace);
    return [UIImage imageWithCGImage:imageMasked];
}


//图片上添加View/截屏生成图片
+ (UIImage*)convertImageFromeView:(UIView*)view {
    NSLog(@"%f", [UIScreen mainScreen].scale);
    
    //不加scale图片截屏会模糊
    UIGraphicsBeginImageContextWithOptions(view.frame.size,NO, [UIScreen mainScreen].scale);
    
    //绘制图形上下文
    CGContextRef ref = UIGraphicsGetCurrentContext();
    [view.layer renderInContext:ref];
    UIImage*image =UIGraphicsGetImageFromCurrentImageContext();
    
    //获取固定位置的图片(上面部分完成截屏功能,下面代码可不要)
    CGImageRef imageRef = CGImageCreateWithImageInRect(image.CGImage,CGRectMake(200,300,100,100));
    UIImage*img = [UIImage imageWithCGImage:imageRef];
    UIGraphicsEndImageContext();
    UIImageWriteToSavedPhotosAlbum(img,self,nil,nil);
    return img;
}


//改变图片的透明度
+ (UIImage*)imageByApplyingAlpha:(CGFloat) alpha image:(UIImage*) image {
    UIGraphicsBeginImageContextWithOptions(image.size,NO,0.0f);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGRect area = CGRectMake(0,0, image.size.width, image.size.height);
    CGContextScaleCTM(ctx,1, -1);
    CGContextTranslateCTM(ctx,0, -area.size.height);
    CGContextSetBlendMode(ctx,kCGBlendModeMultiply);
    CGContextSetAlpha(ctx, alpha);
    CGContextDrawImage(ctx, area, image.CGImage);
    UIImage* newImage =UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage; 
}


#pragma 网络连接相关

//向服务器发起请求，因是异步执行，故返回的数据不能立即得到，所以需要在回调函数里面进行处理，可以采用在参数里面加一个回调函数的参数传入
- (void) makeRequestToServer:(NSString*)urlString withDictionary:(NSDictionary*)dic byHttpMethod:(NSString*) method type:(NSString *) type{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:method];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    NSData *sendData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
    request.HTTPBody = sendData;
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    
    NSURLSessionDataTask *sessionData = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data,NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        NSLog(@"发送%@信息的请求返回状态码：%ld", type, (long)httpResponse.statusCode);
        if(data) {
            
        }
    }];
    [sessionData resume]; //如果request任务暂停了，则恢复
}


@end
