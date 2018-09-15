//
//  MyFloatButton.h
//  悬浮按钮菜单
//
//  Created by conan on 2018/8/7.
//  Copyright © 2018年 conanyu. All rights reserved.
//


#import <UIKit/UIKit.h>


#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)
#define SCREEN_WIDTH  ([UIScreen mainScreen].bounds.size.width)
@class MyFloatButton;
@protocol MyFloatButtonDelegate <NSObject>

@required

- (void)floatTapAction:(MyFloatButton *)sender;

@end

@interface MyFloatButton : UIView<UIGestureRecognizerDelegate>
@property (nonatomic, assign) id<MyFloatButtonDelegate> delegate;
@property (nonatomic, strong) UIImageView *bannerIV;//浮标的imageview
@property (nonatomic, assign) BOOL isMoving;//是否可移动


-(void)setLimitRange:(CGFloat)myHeight andWidth:(CGFloat)myWidth;
@end
