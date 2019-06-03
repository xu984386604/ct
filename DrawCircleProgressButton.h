//
//  DrawCircleProgressButton.h
//  iFreeRDP
//
//  Created by conan on 2019/5/30.
//

#import <UIKit/UIKit.h>

typedef void(^DrawCircleProgressBlock)(void);

@interface DrawCircleProgressButton : UIButton
@property(nonatomic,strong)UIColor *trackColor;
@property(nonatomic,strong)UIColor *progressColor;
@property(nonatomic,strong)UIColor *fillColor;
@property(nonatomic,assign)CGFloat lineWidth;
@property(nonatomic,assign)CGFloat animationDuration;


- (void)startAnimationDuration:(CGFloat)duration withBlock:(DrawCircleProgressBlock) block;
@end
