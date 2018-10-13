//
//  MyFloatButton.m
//  悬浮按钮菜单
//
//  Created by conan on 2018/8/7.
//  Copyright © 2018年 conanyu. All rights reserved.
//

#import "MyFloatButton.h"
#import "vminfo.h"

#define SCALESIZE 5
#define __async_main__ dispatch_async(dispatch_get_main_queue()

typedef NS_ENUM (NSUInteger, LocationTag)
{
    kLocationTag_top = 1,
    kLocationTag_left,
    kLocationTag_bottom,
    kLocationTag_right
};



@implementation MyFloatButton

float _nLogoWidth;//浮标的宽度
float _nLogoHeight;//浮标的高度

LocationTag _locationTag;
float _w; //有效活动宽度
float _h; //有效活动高度

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _nLogoWidth = frame.size.width;
        _nLogoHeight = frame.size.height;
        self.isMoving = YES;
        self.backgroundColor = [UIColor clearColor];
        self.bannerIV = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, _nLogoWidth, _nLogoHeight)];
        //此处表示正常情况下父视图的有效范围, 其他尺寸自行更改
        _w = SCREEN_WIDTH;
        _h = SCREEN_HEIGHT-49;
        _bannerIV.image = [UIImage imageNamed:@"catolog2.png"];
        _bannerIV.layer.cornerRadius = 23.f;
        _bannerIV.layer.masksToBounds = YES;
        _bannerIV.backgroundColor = [UIColor blackColor];
        _bannerIV.userInteractionEnabled = YES;
        _bannerIV.alpha = 0.8;
        [self addSubview:_bannerIV];
        self.contentMode = UIViewContentModeScaleAspectFill;
        _locationTag = kLocationTag_right;
        _nLogoWidth = frame.size.width;
        _nLogoHeight = frame.size.height;
        self.userInteractionEnabled = YES;
        UITapGestureRecognizer *publishTap= [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction)];
        publishTap.delegate = self;
        [_bannerIV addGestureRecognizer:publishTap];
    }
    return self;
}
- (void) tapAction{
    
    [self.delegate floatTapAction:nil];
    
}
#pragma mark - UIResponder

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
   
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{

    [self setCenter:[vminfo share].mypoint];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (!_isMoving) {
        return;
    }
    [self computeOfLocation:^
     {
         
     }];
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (!_isMoving) {
        return;
    }
    UITouch *touch = [touches anyObject];
    CGPoint movedPT = [touch locationInView:[self superview]];
    
    if (
        movedPT.x - self.frame.size.width/2 < 0.f
        ||
        movedPT.x + self.frame.size.width/2 > _w
        ||
        movedPT.y - self.frame.size.height/2 < 0.f
        ||
          movedPT.y + self.frame.size.height/2 > _h
        )
    {
        return;
    }
    [self setCenter:movedPT];
    
}
- (void)computeOfLocation:(void(^)())complete
{
    
    float x = self.center.x;
    float y = self.center.y;
    CGPoint m = CGPointZero;
    m.x = x;
    m.y = y;
    //取两边靠近--------------------------
    if (x < _w/2)
    {
        _locationTag = kLocationTag_left;
    }else
    {
        _locationTag = kLocationTag_right;
    }
    switch (_locationTag)
    {
        case kLocationTag_top:
            m.y = 0 + _bannerIV.frame.size.width/2;
            break;
        case kLocationTag_left:
            m.x = 0 + _bannerIV.frame.size.height/2+12;
            break;
        case kLocationTag_bottom:
            m.y = _h - _bannerIV.frame.size.height/2;
            break;
        case kLocationTag_right:
            m.x = _w - _bannerIV.frame.size.width/2-12;
            break;
    }
    
    //这个是在旋转是微调浮标出界时
    if (m.x > _w - _bannerIV.frame.size.width/2)
        m.x = _w - _bannerIV.frame.size.width/2;
    if (m.y > _h - _bannerIV.frame.size.height/2)
        m.y = _h - _bannerIV.frame.size.height/2;
    if (m.y < 60)
        m.y = 60;
    
    
    
    [UIView animateWithDuration:0.1 animations:^
     {
         [self setCenter:m];
         [vminfo share].mypoint=m;
     } completion:^(BOOL finished)
     {
         complete();
     }];
}

//设置限制的区域
-(void)setLimitRange:(CGFloat)myHeight andWidth:(CGFloat)myWidth
{
    _w = myWidth;
    _h = myHeight-49;
}

@end
