//
//  myCountDownView.m
//  iFreeRDP
//
//  Created by conan on 2019/5/30.
//

#import "myCountDownView.h"
#import "DrawCircleProgressButton.h"

@interface myCountDownView()
@property(nonatomic,strong)DrawCircleProgressButton *DCPButton;
@property(nonatomic,strong)UIImageView *backgroundImageView;
@property(nonatomic,assign)NSInteger totalTime;
@property(nonatomic,copy)NSString *imageName;
@property(copy,nonatomic) CountDownCompleteBlock completeBlock;

@end

@implementation myCountDownView
- (instancetype)initWithFrame:(CGRect)frame totalTime:(NSInteger)time imageName:(NSString *)name completeBlock:(CountDownCompleteBlock)completeBlock;{
    self = [super initWithFrame:frame];
    if(self) {
        self.totalTime = time;
        self.backgroundColor = [UIColor clearColor];
        self.imageName = name;
        [self addSubview:self.backgroundImageView];
        [self addSubview:self.DCPButton];
        self.completeBlock = completeBlock;
    }
    return self;
}
- (DrawCircleProgressButton*)DCPButton {
    if(!_DCPButton) {
        _DCPButton = [[DrawCircleProgressButton alloc] initWithFrame:CGRectMake(self.frame.size.width-55, 30, 40, 40)];
        _DCPButton.lineWidth = 2;
        [_DCPButton setTitle:[NSString stringWithFormat:@"%@s",@(self.totalTime).stringValue] forState:UIControlStateNormal];
        [_DCPButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _DCPButton.titleLabel.font = [UIFont systemFontOfSize:14];
    }
    return _DCPButton;
}
- (UIImageView*)backgroundImageView {
    if(!_backgroundImageView) {
        _backgroundImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _backgroundImageView.image = [UIImage imageNamed:self.imageName];
        _backgroundImageView.contentMode = UIViewContentModeScaleToFill;
    }
    return _backgroundImageView;
}
- (void)startCountDown {
    [self.DCPButton startAnimationDuration:self.totalTime withBlock:nil];
    [self startTime];
}
- (void)startTime {
    __weak typeof(self)bself = self;
    __block NSInteger timeout = _totalTime;
    dispatch_queue_t queue = dispatch_queue_create(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(_timer, dispatch_walltime(NULL, 0), 1.0 * NSEC_PER_SEC, 0);
    dispatch_source_set_event_handler(_timer, ^{
        if(timeout <=0) {
            dispatch_source_cancel(_timer);
            dispatch_async(dispatch_get_main_queue(), ^{
                bself.DCPButton.hidden = YES;
                [bself removeProgress];
                if(bself.completeBlock)
                    bself.completeBlock();
                    
            });
        }else {
            NSInteger seconds = timeout % 60;
            dispatch_async(dispatch_get_main_queue(), ^{
                [bself.DCPButton setTitle:[NSString stringWithFormat:@"%@s",@(seconds).stringValue] forState:UIControlStateNormal];
            });
            timeout--;
        }
        
    });
    dispatch_resume(_timer);
}
- (void)removeProgress {
    self.backgroundImageView.transform = CGAffineTransformMakeScale(1, 1);
    self.backgroundImageView.alpha = 1;
     typeof(self) weakself = self;
    [UIView animateWithDuration:0.7 animations:^{
        weakself.backgroundImageView.alpha = 0.05;
        weakself.backgroundImageView.transform = CGAffineTransformMakeScale(5, 5);
    } completion:^(BOOL finished) {
        [weakself removeFromSuperview];
    }];
    
}
@end
