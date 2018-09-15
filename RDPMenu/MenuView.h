//
//  MenuView.h
//  悬浮按钮菜单
//
//  Created by conan on 2018/8/7.
//  Copyright © 2018年 conanyu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MenuButton.h"
@class MenuView ;
@protocol MenuViewDelegate <NSObject>

@end


@interface MenuView : UIView
@property (nonatomic, assign) CGPoint centerPoint;
@property (nonatomic, assign) id<MenuViewDelegate> delegate;


-(void)showMenuView;
-(void)dismiss;
@property (nonatomic, copy) void (^clickMenuButton)(NSInteger index);

+ (instancetype)standardMenuView;

@end
