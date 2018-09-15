//
//  MyTableAlert.m
//  FreeRDP
//
//  Created by conan on 2018/1/16.
//
//

#import "MyTableAlert.h"

#define kTableAlertWidth      284.0f
#define kLateralInset         12.0f
#define kVerticalInset        8.0f
#define kMinAlertHeight       264.0f
#define kCancelButtonHeight   44.0f
#define kCancelButtonMargin   5.0f
#define kTitleLabelMargin     12.0

#pragma mark -尺寸
/***  当前屏幕宽度 */
#define kScreenWidth  [[UIScreen mainScreen] bounds].size.width
/***  当前屏幕高度 */
#define kScreenHeight  [[UIScreen mainScreen] bounds].size.height

@interface MyAlertView ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) UIView *alertBgView;
@property (nonatomic,strong) UILabel *titleLabel;
@property (nonatomic,strong) UIButton *cancelButton;

@property (nonatomic,strong) NSString *title;
@property (nonatomic,strong) NSString *cancelTitle;

@property (nonatomic,copy) TableAlertCompletionBlock completionBlock;
@property (nonatomic,copy) TableAlertRowSelectBlock selectBlock;
@property (nonatomic,copy) TableAlertNumberRowBlock alertNumberRowBlock;
@property (nonatomic,copy) TableAlertTableCellBlock alertTableCellBlock;

- (void)createBackGroundView;
- (void)animateIn;
- (void)animateOut;
- (void)dismissTableAlert;

@end


@implementation MyAlertView

#pragma mark - TableAlert Create Method

+(MyAlertView *)tableAlertWithTitle:(NSString *)title cancelButtonTitle:(NSString *)cancelTitle numberOfRows:(TableAlertNumberRowBlock)rowBlock andCell:(TableAlertTableCellBlock)cellsBlock{
    
    return [[self alloc] initTableAlertWithTitle:title cancelButtonTitle:cancelTitle numberOfRows:rowBlock andCell:cellsBlock];
}
#pragma mark - TableAlert Initialization

-(id)initTableAlertWithTitle:(NSString *)title cancelButtonTitle:(NSString *)cancelTitle numberOfRows:(TableAlertNumberRowBlock)rowBlock andCell:(TableAlertTableCellBlock)cellsBlock{
    // Throw exception if rowsBlock or cellsBlock is nil
    if (rowBlock == nil || cellsBlock == nil)
    {
        [[NSException exceptionWithName:@"rowsBlock and cellsBlock Error" reason:@"These blocks MUST NOT be nil" userInfo:nil] raise];
        return nil;
    }
    
    self = [super init];
    
    if (self)
    {
        _alertNumberRowBlock = rowBlock;
        _alertTableCellBlock = cellsBlock;
        _title = title;
        _cancelTitle = cancelTitle;
        _height = kMinAlertHeight;
    }
    
    return self;
    
}
#pragma mark - action

-(void)configureSelectionBlock:(TableAlertRowSelectBlock)selectionBlock andCompletionBlock:(TableAlertCompletionBlock)completionBlock{
    self.selectBlock = selectionBlock;
    self.completionBlock = completionBlock;
}

#pragma mark - private

-(void)createBackGroundView{
    
    self.frame = [[UIScreen mainScreen] bounds];
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.0];
    self.opaque = NO;
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:self];
    
    [UIView animateWithDuration:0.2 animations:^{
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.45];
    }];
}
-(void)show{
    
    [self createBackGroundView];
    
    self.alertBgView = [[UIView alloc] initWithFrame:CGRectZero];
    [self addSubview:self.alertBgView];
    
    UIImageView *alertBgImageView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"MLTableAlertBackground"] stretchableImageWithLeftCapWidth:15 topCapHeight:30]];
    alertBgImageView.layer.cornerRadius = 5.0;
    alertBgImageView.layer.masksToBounds = YES;
    alertBgImageView.frame = CGRectMake(0.0, 0.0, kTableAlertWidth, self.height);
    [self.alertBgView addSubview:alertBgImageView];
    
    // alert title creation
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.titleLabel.backgroundColor = [UIColor clearColor];
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.shadowColor = [[UIColor blackColor] colorWithAlphaComponent:0.45];
    self.titleLabel.shadowOffset = CGSizeMake(0, -1);
    self.titleLabel.font = [UIFont boldSystemFontOfSize:18.0];
    self.titleLabel.frame = CGRectMake(kLateralInset, 15, kTableAlertWidth - kLateralInset * 2, 22);
    self.titleLabel.text = self.title;
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.alertBgView addSubview:self.titleLabel];
    
    // table view creation
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.frame = CGRectMake(kLateralInset, self.titleLabel.frame.origin.y + self.titleLabel.frame.size.height + kTitleLabelMargin, kTableAlertWidth - kLateralInset * 2, (self.height - kVerticalInset * 2) - self.titleLabel.frame.origin.y - self.titleLabel.frame.size.height - kTitleLabelMargin - kCancelButtonMargin - kCancelButtonHeight);
    self.tableView.layer.cornerRadius = 6.0;
    self.tableView.layer.masksToBounds = YES;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundView = [[UIView alloc] init];
    
    [self.alertBgView addSubview:self.tableView];
    
    // cancel button creation
    self.cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.cancelButton.frame = CGRectMake(kLateralInset, self.tableView.frame.origin.y + self.tableView.frame.size.height + kCancelButtonMargin, kTableAlertWidth - kLateralInset * 2, kCancelButtonHeight);
    [self.cancelButton setTitle:self.cancelTitle forState:UIControlStateNormal];
    [self.cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [self.cancelButton setBackgroundImage:[[UIImage imageNamed:@"MLTableAlertCancelButton"] stretchableImageWithLeftCapWidth:5 topCapHeight:0] forState:UIControlStateNormal];
    
    self.cancelButton.opaque = NO;
    self.cancelButton.layer.cornerRadius = 5.0;
    [self.cancelButton addTarget:self action:@selector(dismissTableAlert) forControlEvents:UIControlEventTouchUpInside];
    [self.alertBgView addSubview:self.cancelButton];
    
    // setting alert and alert background image frames
    self.alertBgView.frame = CGRectMake((self.frame.size.width - kTableAlertWidth) / 2, (self.frame.size.height - self.height) / 2, kTableAlertWidth, self.height - kVerticalInset * 2);
    
    // the alert will be the first responder so any other controls,
    // like the keyboard, will be dismissed before the alert
    [self becomeFirstResponder];
    
    // show the alert with animation
    [self animateIn];
    
}

-(void)dismissTableAlert
{
    [self animateOut];
    
    if (self.completionBlock) {
        self.completionBlock();
    }
    
}

-(void)animateIn
{
    CGRect rect = self.alertBgView.bounds;
    
    CASpringAnimation * ani = [CASpringAnimation animationWithKeyPath:@"bounds"];
    ani.mass = 5.0;
    //质量，影响图层运动时的弹簧惯性，质量越大，弹簧拉伸和压缩的幅度越大
    ani.stiffness = 1500;
    //刚度系数(劲度系数/弹性系数)，刚度系数越大，形变产生的力就越大，运动越快
    ani.damping = 100.0;
    //阻尼系数，阻止弹簧伸缩的系数，阻尼系数越大，停止越快
    ani.initialVelocity = 5.f;
    //初始速率，动画视图的初始速度大小;速率为正数时，速度方向与运动方向一致，速率为负数时，速度方向与运动方向相反
    ani.duration = ani.settlingDuration;
    
    ani.fromValue = [NSValue valueWithCGRect:CGRectMake(rect.origin.x, -kScreenHeight, rect.size.width,rect.size.height)];
    ani.toValue = [NSValue valueWithCGRect:self.alertBgView.bounds];
    ani.removedOnCompletion = NO;
    ani.fillMode = kCAFillModeForwards;
    ani.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [self.alertBgView.layer addAnimation:ani forKey:@"inAni"];
    
}
-(void)animateOut
{
    
    CGRect rect = CGRectMake((self.frame.size.width - kTableAlertWidth) / 2, kScreenHeight, kTableAlertWidth, self.height - kVerticalInset * 2);
    
    [UIView animateWithDuration:0.4 animations:^{
        self.alertBgView.frame = rect;
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.0];
    } completion:^(BOOL finished) {
        self.alertBgView = nil;
        self.titleLabel = nil;
        self.cancelButton = nil;
        [self removeFromSuperview];
    }];
}

// Allows the alert to be first responder
-(BOOL)canBecomeFirstResponder
{
    return YES;
}

// Alert height setter
-(void)setHeight:(CGFloat)height
{
    if (height > kMinAlertHeight)
        _height = height;
    else
        _height = kMinAlertHeight;
}

#pragma mark - UITableViewDataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // TODO: Allow multiple sections
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // according to the numberOfRows block code
    return self.alertNumberRowBlock(section);
}

//设置rowHeight
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // according to the cells block code
    return self.alertTableCellBlock(self, indexPath);
}

#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if ([cell.textLabel.text isEqualToString:@""]) {
        return;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (self.selectBlock){
        self.selectBlock(indexPath);
    }
    
    [self dismissTableAlert];
    
}

@end
