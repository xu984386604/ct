//
//  myNavigationViewController.m
//  FreeRDP
//
//  Created by conan on 2018/9/11.
//
//

#import "myNavigationViewController.h"
#import "RDPSessionViewController.h"


@interface myNavigationViewController ()

@end

@implementation myNavigationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setNavigationBarHidden:YES animated:nil];
    
    //退出到后台
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(myAppEnterBackground:) name:@"appEnterbackGround" object:nil];
    
    

    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)shouldAutorotate
{
    return  YES;
}
-(UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    if([self.topViewController isKindOfClass:[RDPSessionViewController class]])
    {
        return UIInterfaceOrientationMaskLandscape;
    }else
    {
        return UIInterfaceOrientationMaskAll;
    }
}


#pragma mark 进入后台
-(void)myAppEnterBackground:(id)num{
    [UIView beginAnimations:@"exitApplication" context:nil];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationTransition:UIViewAnimationTransitionCurlUp forView:self.view.window cache:NO];
    [UIView setAnimationDidStopSelector:@selector(animationFinished:finished:contex:)];
    self.view.window.bounds = CGRectMake(0, 0, 0, 0);
    [UIView commitAnimations];
}


-(void)animationFinished:(NSString *)animationID finished:(NSNumber *)finished contex:(void *)context{
    if([animationID compare:@"exitApplication"] == 0)
    {
        exit(0);
    }
}





/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super dealloc];
}
@end
