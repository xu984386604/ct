//
//  MenuView.m
//  悬浮按钮菜单
//
//  Created by conan on 2018/8/7.
//  Copyright © 2018年 conanyu. All rights reserved.
//

#import "MenuView.h"
#import "vminfo.h"

#define KWindow [[UIApplication sharedApplication] keyWindow]

#define kWidth  [[UIApplication sharedApplication] keyWindow].bounds.size.width
#define kHeight [[UIApplication sharedApplication] keyWindow].bounds.size.height

#define bgwidth 300
#define bgheight 70
#define floatbtnH  46

@interface MenuView()
{

    MenuButton * button1;
    MenuButton * button2;
    MenuButton * button3;
    MenuButton * button4;
    MenuButton * button5;
    UIView     * bgview;
    
}
@end

static MenuView *instanceMenuView;

@implementation MenuView
- (instancetype)init{
    if (self = [super init]) {
    }
    return self;
}

-(void)showMenuView
{
    CGPoint point1 = CGPointMake(30, 35);
    CGPoint point2 = CGPointMake(90, 35);
    CGPoint point3 = CGPointMake(150, 35);
    CGPoint point4 = CGPointMake(210, 35);
    CGPoint point5 = CGPointMake(270, 35);
    //确定 bgview 的位置
    [self locateBgview];
    
    button1=[MenuButton buttonWithTitle:@"键盘" imageTitle:@"keyboard.png" center:point1];
    button1.tag = 1;
    [button1 addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    button2 = [MenuButton buttonWithTitle:@"鼠标" imageTitle:@"mouse.png" center:point2];
    button2.tag = 2;
     [button2 addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    button3 = [MenuButton buttonWithTitle:@"挂载" imageTitle:@"load_netdisk.png" center:point3];
    button3.tag = 3;
     [button3 addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    button4 = [MenuButton buttonWithTitle:@"卸载" imageTitle:@"unload_netdisk.png" center:point4];
    button4.tag = 4;
     [button4 addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    button5 = [MenuButton buttonWithTitle:@"断开" imageTitle:@"close.png" center:point5];
    button5.tag = 5;
    [button5 addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    
   
    [bgview addSubview:button2];
    [bgview addSubview:button3];
    [bgview addSubview:button1];
    [bgview addSubview:button4];
    [bgview addSubview:button5];
    
    bgview.alpha=1;
    bgview.backgroundColor=[UIColor colorWithRed:
                            34/256.0 green:34/256.0 blue:34/256.0 alpha:0.8];
    [[bgview layer] setCornerRadius:8];
    [[bgview layer] setMasksToBounds:YES];
    [KWindow addSubview:bgview];

    
    
    
}


-(void)locateBgview
{
    CGPoint mypoint=[vminfo share].mypoint;
    float myx=0;
    float myy=0;

    //判断位置 设置bgview的初始位置
    //先判断是在左边还是右边
    if ( mypoint.x - kWidth/2 < 0.f )
    {
        myx = 20 ;        //在左边
    }else{
        
        myx = kWidth - 20 -bgwidth;   //在右边
    }
    
    if ( mypoint.y - 20 -bgheight - 10 < floatbtnH/2 )
    {
        myy = mypoint.y + floatbtnH/2 + 10; //在下边
    }else{
        
        myy = mypoint.y - 10 - floatbtnH/2 -bgheight ; //在上边
    }
    
    bgview = [[UIView alloc] initWithFrame:
              CGRectMake(myx, myy, bgwidth, bgheight)];

}

-(void)dismiss
{

    [UIView animateWithDuration:0.2 animations:^{
        bgview.alpha=0;
    } completion:^(BOOL finished)
    {
      
        [bgview removeFromSuperview];
        [button1 removeFromSuperview];
        [button2 removeFromSuperview];
        [button3 removeFromSuperview];
        [button4 removeFromSuperview];
        [button5 removeFromSuperview];
    }];

}


-(void)buttonAction:(UIButton *)sender
{
    /*
     * menu 消失 发送tag,调用block函数
     */
    if(self.clickMenuButton)
        self.clickMenuButton(sender.tag);
}

+ (instancetype)standardMenuView{
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        instanceMenuView = [[self alloc] init];
    });
    return instanceMenuView;
}



@end
