//
//  UpdateApp.h
//  FreeRDP
//
//  Created by conan on 2018/8/30.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface UpdateApp : NSObject <NSURLSessionDelegate>
- (void)checkVersionUpdata;
@end
