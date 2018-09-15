//
//  ViewController.h
//  FreeRDP
//
//  Created by conan on 15/12/10.
//
//

#import <UIKit/UIKit.h>
#import "Bookmark.h"
#import "Reachability.h"

@interface ViewController : UIViewController

{
    NSMutableArray* _manual_bookmarks;
    NSMutableArray* _tsxconnect_bookmarks;
    NSMutableArray* _active_sessions;

}

-(IBAction)textFieldDoneEditing:(id)sender;


@end
