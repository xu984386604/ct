//
//  UpdateApp+SB.h
//  FreeRDP
//
//  Created by conan on 2018/8/31.
//
//

#import "UpdateApp.h"
#define DO_NOT_NEED_UPDATE -1
#define NEED_FORCE_UPDATE 0
#define NEED_UPDATE 1
#define CURRENT_VERSION_IS_NEWER 2
#define CURRENT_VERSION_IS_OLDER 3
#define CURRENT_VERSION_IS_SAME 4

@interface UpdateApp (SB)
@property (nonatomic, copy) NSString *firstNum;
@property (nonatomic, copy) NSString *secondNum;
@property (nonatomic, copy) NSString *thridNum;
@property (nonatomic, copy) NSString *buildNum;

- (int)checkUpdateStatus:(NSString *) currentVersion lastForceUpdateVersion:(NSString *) oldVersion lastestVersion:(NSString *) lastestVersion;
@end
