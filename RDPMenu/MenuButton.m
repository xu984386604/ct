//
//  MenuButton.m
//  悬浮按钮菜单
//
//  Created by conan on 2018/8/7.
//  Copyright © 2018年 conanyu. All rights reserved.
//

#import "MenuButton.h"

#define  imageH 46
#define  imageW 46

@implementation MenuButton


-(CGRect) titleRectForContentRect:(CGRect)contentRect
{
    CGFloat titleY = imageH - 7 ;
    CGFloat titleW = imageW;
    CGFloat titleH = 15;
    return CGRectMake(7, titleY, titleW, titleH);
}
-(CGRect) imageRectForContentRect:(CGRect)contentRect
{
    
    return CGRectMake(7, -5, imageW, imageW);
}


- (void)setTitle:(NSString *)title forState:(UIControlState)state{
    [super setTitle:title forState:state];
//    self.titleLabel.font = [UIFont systemFontOfSize:15];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.font=[UIFont fontWithName:@"Helvetica-Bold" size:15];
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
}
- (void)setImage:(UIImage *)image forState:(UIControlState)state{
    [super setImage:image forState:state];
}

-(instancetype) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return self;
}

//鼠标按钮的实例化
+(instancetype)buttonWithTitle:(NSString *)title imageTitle:(NSString *)imageTitle center:(CGPoint)point
{
    CGRect frame = CGRectMake(0, 0, 60, 60);
    MenuButton *menu4=[[MenuButton alloc] initWithFrame:frame];
    menu4.center = point;
    [menu4 setTitle:title forState:UIControlStateNormal];
    [menu4 setImage:[UIImage imageNamed:imageTitle] forState:UIControlStateNormal];
    return menu4;
}






@end
