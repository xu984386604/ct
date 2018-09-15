//
//  UpdateApp+SB.m
//  FreeRDP
//
//  Created by conan on 2018/8/31.
//
//

#import "UpdateApp+SB.h"
#import <objc/runtime.h>

static void *firstNumKey = &firstNumKey;
static void *secondNumKey = &secondNumKey;
static void *thridNumKey = &thridNumKey;
static void *buildNumKey = &buildNumKey;

@implementation UpdateApp (SB)

- (void) setFirstNum:(NSString *) num{
    objc_setAssociatedObject(self, &firstNumKey, num, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *) firstNum {
    return objc_getAssociatedObject(self, &firstNumKey);
}

- (void) setSecondNum:(NSString *) num{
    objc_setAssociatedObject(self, &secondNumKey, num, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *) secondNum {
    return objc_getAssociatedObject(self, &secondNumKey);
}
- (void) setThridNum:(NSString *) num{
    objc_setAssociatedObject(self, &thridNumKey, num, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *) thridNum {
    return objc_getAssociatedObject(self, &thridNumKey);
}
- (void) setBuildNum:(NSString *) num{
    objc_setAssociatedObject(self, &buildNumKey, num, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *) buildNum {
    return objc_getAssociatedObject(self, &buildNumKey);
}

- (int) getIntFirstNum {
    NSString *str = (NSString *) [self firstNum];
    return [str intValue];
}
- (int) getIntSecondNum {
    NSString *str = (NSString *) [self secondNum];
    return [str intValue];
}
- (int) getIntThridNum {
    NSString *str = (NSString *) [self thridNum];
    return [str intValue];
}
- (int) getIntBuildNum {
    NSString *str = (NSString *) [self buildNum];
    return [str intValue];
}

#pragma 其它的处理方法（针对目前的版本命名情况），也可以通过上面的getter和setter方法进行自定义的面向对象的版本的处理
//返回int类型的版本号的数组
- (NSArray *) convertToIntArray:(NSString *) str {
    NSArray *arry = [str componentsSeparatedByString:@"."];
    [self  setFirstNum:arry[0]];
    [self  setSecondNum:arry[1]];
    [self  setThridNum:arry[2]];
    [self  setBuildNum:arry[3]];
    arry = nil;[NSNumber numberWithInteger:[self getIntFirstNum]];
    arry = [NSArray arrayWithObjects:[NSNumber numberWithInteger:[self getIntFirstNum]], [NSNumber numberWithInteger:[self getIntSecondNum]],[NSNumber numberWithInteger:[self getIntThridNum]], [NSNumber numberWithInteger:[self getIntBuildNum]], nil];
    return arry;
}

- (int) compareVersion:(NSString *) first WithCurrentVersion:(NSString *) second {
    if ([second compare:first] == NSOrderedSame) {
        return CURRENT_VERSION_IS_SAME;
    }
    
    NSArray *arry1 = [self convertToIntArray:first]; //服务器app版本
    NSArray *arry2 = [self convertToIntArray:second]; //本机app的版本
    bool flag = false; //true代表服务器的版本要比本机的版本新
    //NSOrderedAscending = -1L, NSOrderedSame, NSOrderedDescending
    
    if ([arry1[0] compare:arry2[0]] == NSOrderedDescending) { //主版本号
        flag = true;
    } else if([arry1[0] compare:arry2[0]] == NSOrderedSame) {
        if ([arry1[1] compare:arry2[1]] == NSOrderedDescending) { //子版本号
            flag = true;
        } else if([arry1[1] compare:arry2[1]] == NSOrderedSame) {
            if ([arry1[2] compare:arry2[2]] == NSOrderedDescending) { //次版本号
                flag = true;
            } else if([arry1[2] compare:arry2[2]] == NSOrderedSame) {
                if ([arry1[3] compare:arry2[3]] == NSOrderedDescending) { //build号
                    flag = true;
                }
            }
        }
    }
    
    return flag ? CURRENT_VERSION_IS_OLDER : CURRENT_VERSION_IS_NEWER;
}

//直接检测是否需要强制更新还是可以不更新
- (int)checkUpdateStatus:(NSString *) currentVersion lastForceUpdateVersion:(NSString *) oldVersion lastestVersion:(NSString *) lastestVersion {
    int a = [self compareVersion:oldVersion WithCurrentVersion:currentVersion];
    if (a == CURRENT_VERSION_IS_OLDER) {
        return NEED_FORCE_UPDATE;
    }
    a = [self compareVersion:lastestVersion WithCurrentVersion:currentVersion];
    if (a == CURRENT_VERSION_IS_OLDER) {
        return NEED_UPDATE;
    }
    return DO_NOT_NEED_UPDATE;
}
@end
