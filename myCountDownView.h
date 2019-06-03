//
//  myCountDownView.h
//  iFreeRDP
//
//  Created by conan on 2019/5/30.
//

#import <UIKit/UIKit.h>
//结束回调函数
typedef void(^CountDownCompleteBlock)(void);

@interface myCountDownView : UIView

- (instancetype)initWithFrame:(CGRect)frame totalTime:(NSInteger)time imageName:(NSString *)name completeBlock:(CountDownCompleteBlock)completeBlock;;
- (void)startCountDown;

@end
