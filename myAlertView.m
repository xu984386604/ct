//
//  myAlertView.m

//
//  Created by Ysan on 13-9-2.
//  Copyright (c) 2013年 a. All rights reserved.
//

#import "myAlertView.h"
#import "RDPSession.h"
#import "RDPSessionView.h"
#import "RDPSessionViewController.h"
@interface myAlertView ()

@end

@implementation myAlertView
@synthesize mysession;

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"警告" message:@"网速不给力，是否继续接入云端？" delegate:self cancelButtonTitle:@"继续" otherButtonTitles:@"退出", nil];
    [alert show];
    
    [self performSelector:@selector(dismissAlert:) withObject:alert afterDelay:7.0];

}

-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        NSLog(@"ok");
        [mysession disconnect];        
    }
    else {
        NSLog(@"go on...");
       
    }
}
- (void)dismissAlert:(UIAlertView*)alert {
    if ( alert.visible ) {
        [alert dismissWithClickedButtonIndex:alert.cancelButtonIndex animated:YES];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
