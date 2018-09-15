//
//  NavigationController.m
//  FreeRDP
//
//  Created by conan on 16/5/8.
//
//

#import "NavigationController.h"

@interface NavigationController ()

@end

@implementation NavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
/*
-(NSUInteger)supportedInterfaceOrientations{
  

        return UIInterfaceOrientationMaskLandscape;

//    return UIInterfaceOrientationMaskAll;
//    return UIInterfaceOrientationMaskLandscape;
}

- (BOOL)shouldAutorotate
{
    return YES;
}
*/
/*
 -(BOOL)shouldAutorotate {
         return [[self.viewControllers lastObject] shouldAutorotate];
     }

 -(NSUInteger)supportedInterfaceOrientations {
         return [[self.viewControllers lastObject] supportedInterfaceOrientations];
     }

 - (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
         return [[self.viewControllers lastObject] preferredInterfaceOrientationForPresentation];
     }
*/

-(BOOL)shouldAutorotate{
    return [self.topViewController shouldAutorotate];
}
//支持的方向
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return [self.topViewController supportedInterfaceOrientations];;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
