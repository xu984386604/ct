//
//  MyTableAlert.h
//  FreeRDP
//
//  Created by conan on 2018/1/16.
//
//

#import <UIKit/UIKit.h>

@class MyAlertView;

///----------------------
/// @block Definition for table view management
///----------------------

typedef NSInteger (^TableAlertNumberRowBlock)(NSInteger row);
typedef UITableViewCell* (^TableAlertTableCellBlock)( MyAlertView*tableAlert, NSIndexPath *indexPath);
typedef void (^TableAlertRowSelectBlock)(NSIndexPath *indexPath);
typedef void (^TableAlertCompletionBlock)(void);



@interface MyAlertView : UIView

@property (nonatomic,assign) CGFloat height;

@property (nonatomic,strong) UITableView *tableView;


/**
 * Creates and returns an `Alert` object.
 */
+(MyAlertView *)tableAlertWithTitle:(NSString *)title cancelButtonTitle:(NSString *)cancelTitle numberOfRows:(TableAlertNumberRowBlock)rowBlock andCell:(TableAlertTableCellBlock)cellsBlock;

/**
 * Initialization method; rowBlock and cellBlock Must Not be nil.
 */
-(id)initTableAlertWithTitle:(NSString *)title cancelButtonTitle:(NSString *)cancelTitle numberOfRows:(TableAlertNumberRowBlock)rowBlock andCell:(TableAlertTableCellBlock)cellsBlock;

///---------------------
/// @name Method
///---------------------

// Allows you to perform custom actions when a row is selected or the cancel button is pressed
-(void)configureSelectionBlock:(TableAlertRowSelectBlock)selectionBlock andCompletionBlock:(TableAlertCompletionBlock)completionBlock;

// Show the alert
-(void)show;


@end
