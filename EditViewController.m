//
//  EditViewController.m
//  FreeRDP
//
//  Created by conan on 16/5/13.
//
//

#import "EditViewController.h"

@interface EditViewController ()

@property (assign) IBOutlet UITextField *IPTextField;
@property (assign) IBOutlet UITextField *PortTextField;




@end

@implementation EditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(backToLogin:)];
    self.navigationItem.leftBarButtonItem = backButton;
    
    NSUserDefaults *IPDefualt = [NSUserDefaults standardUserDefaults];
    if([IPDefualt objectForKey:@"IP"] && [IPDefualt objectForKey:@"port"]){
        NSString *IP = [IPDefualt stringForKey:@"IP"];
        NSString *port = [IPDefualt stringForKey:@"port"];
        self.IPTextField.text = IP;
        self.PortTextField.text = port;
    }
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)backToLogin:(id)selector {
    NSString *IP = [[NSString alloc] initWithFormat:@"%@",self.IPTextField.text];
    NSString *port = [[NSString alloc] initWithFormat:@"%@",self.PortTextField.text];
    NSLog(@"%@:%@",IP,port);
    
    NSUserDefaults *setDefualt = [NSUserDefaults standardUserDefaults];
    [setDefualt setObject:IP forKey:@"IP"];
    [setDefualt setObject:port forKey:@"port"];
    [[self navigationController] popViewControllerAnimated:YES];
    
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
-(IBAction)textFieldDoneEditing:(id)sender
{
    [sender resignFirstResponder];
}

@end
