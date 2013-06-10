//
//  UserRegisterViewController_iPad.m
//
//  Created by cg on 11-6-30.
//  Copyright 2011 Dreaming Team. All rights reserved.
//

#import "UserRegisterViewController_iPad.h"
#import "MBProgressHUD.h"
#import "DreamingAPI.h"
#import "ZUser.h"
#import "ZAppDelegate.h"
#import "UserAccount.h"
#import "MainViewController.h"
#import "StringUtils.h"
#import "GlobalDef.h"

@implementation UserRegisterViewController_iPad

@synthesize resultDelegate;

@synthesize confrimPasswordTextField;
@synthesize passwordTextField;
@synthesize emailTextField;
@synthesize registerButton;

@synthesize userName, password;

- (void)dealloc {
    
    [[RKClient sharedClient].requestQueue cancelRequestsWithDelegate:self];
    
    self.confrimPasswordTextField = nil;
    self.passwordTextField = nil;
    self.emailTextField = nil;
    
    self.registerButton = nil;
    
    self.userName = nil;
    self.password = nil;
    
    [super dealloc];
}

#pragma mark RKObjectLoaderDelegate methods
- (void)request:(RKRequest*)request didLoadResponse:(RKResponse*)response {
    
}

- (void)objectLoader:(RKObjectLoader *)objectLoader didLoadObject:(id)object {
    
    ZUser* user = (ZUser *)object;
    
    if ([user.screenName length] == 0) {
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [[ZAppDelegate sharedAppDelegate] showInformation:self.view info:NSLocalizedString(@"注册失败",@"")];
        
        return;
    }
    
    user.password = self.password;
    
    [UserAccount setUserInfo:user];
    
    [RKObjectManager sharedManager].client.username = user.screenName;
    [RKObjectManager sharedManager].client.password = user.password;
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [[ZAppDelegate sharedAppDelegate] showInformation:self.view info:NSLocalizedString(@"注册成功",@"")];
    
    [self dismissModalViewControllerAnimated:NO];
    
    if ([resultDelegate respondsToSelector:@selector(registerViewControllerReturnResult:)]) {
        
        [resultDelegate registerViewControllerReturnResult:YES];
    }
}

- (void)objectLoader:(RKObjectLoader*)objectLoader didFailWithError:(NSError*)error {
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [[ZAppDelegate sharedAppDelegate] showInformation:self.view info:NSLocalizedString(@"注册失败",@"")];
}

- (void)request:(RKRequest *)request didFailLoadWithError:(NSError *)error {
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [[ZAppDelegate sharedAppDelegate] showNetworkFailed:self.view];
}

- (IBAction)closeAction:(id)sender
{
    BOOL bAnimation = sender != nil;
    
    if ([self respondsToSelector:@selector(presentingViewController)]) {
        
        if (self.presentedViewController) {
            [[self presentedViewController] dismissModalViewControllerAnimated:bAnimation];
        }
        else {
            [self dismissModalViewControllerAnimated:bAnimation];
        }
    }
    else {
        [[self parentViewController] dismissModalViewControllerAnimated:bAnimation];
    }  
}


- (IBAction)registerUserAction:(id)sender
{
    if (![self.passwordTextField.text isEqualToString:self.confrimPasswordTextField.text]) {
        [[ZAppDelegate sharedAppDelegate] showInformation:self.view info:NSLocalizedString(@"两次输入的密码不一致",@"")];
        
        return;
    }
    
    if ([self.passwordTextField.text length] == 0 || [self.emailTextField.text length] == 0) {
        [[ZAppDelegate sharedAppDelegate] showInformation:self.view info:NSLocalizedString(@"帐号或密码不能为空",@"")];
        
        return;
    }
    
    [[RKClient sharedClient].requestCache invalidateAll];
    [UserAccount clearUserInfo];
    
    self.userName = emailTextField.text;
    self.password = passwordTextField.text;
    
    [DreamingAPI registerUser:self.userName andPassword:self.password delegate:self];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

/* ###################
 
 UITextFieldDelegate回调
 
 ###################
 */
//判断邮箱输入长度
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    
    //判断邮箱是否太长
    if (textField == emailTextField && textField.text.length >= EMAIL_MAX_LENGTH && range.length == 0) {
        return NO;
    }
    
    //验证密码长度，密码有可能为空
    if ((passwordTextField.text.length > 0 && passwordTextField.text.length < PASSWORD_MIN_LENGTH) || passwordTextField.text.length > PASSWORD_MAX_LENGTH) {
        
        NSString *message = [NSString stringWithFormat:NSLocalizedString(@"密码长度需要在%d～%d之间",@""), PASSWORD_MIN_LENGTH, PASSWORD_MAX_LENGTH];                                  
        [[ZAppDelegate sharedAppDelegate] showInformation:self.view info:message];
    }
    
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    [passwordTextField resignFirstResponder];
    [emailTextField resignFirstResponder];
    [confrimPasswordTextField resignFirstResponder];
}


- (void)back {
    
    [self dismissModalViewControllerAnimated:YES];
}

- (void)setTopBar {
    
    UIImageView *topBar = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 46)] autorelease];
    [topBar setImage:[UIImage imageNamed:@"NavBar_ios5@2x"]];
    
    [self.view addSubview:topBar];
    
    UIButton *topBarLeftButton = [[[UIButton alloc] initWithFrame:CGRectMake(5, 0, 44, 44)] autorelease];
    [topBarLeftButton setBackgroundImage:[UIImage imageNamed:@"back@2x"] forState:UIControlStateNormal];
    [topBarLeftButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:topBarLeftButton];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [emailTextField becomeFirstResponder];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view = [[[NSBundle mainBundle] loadNibNamed:@"UserRegisterView_iPad" owner:self options:nil] lastObject];
    
    self.passwordTextField.secureTextEntry = YES;
    self.confrimPasswordTextField.secureTextEntry = YES;
    self.emailTextField.placeholder = NSLocalizedString(@"请输入帐号", @"");
    self.passwordTextField.placeholder = NSLocalizedString(@"请输入密码", @"");
    self.confrimPasswordTextField.placeholder = NSLocalizedString(@"确认密码", @"");
    [self.registerButton setTitle:NSLocalizedString(@"注册", @"") forState:UIControlStateNormal];
    
    [self setTopBar];
}

/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations.
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	if (textField == emailTextField) {
		[textField resignFirstResponder];
		[passwordTextField becomeFirstResponder];
	} 
	else if (textField == passwordTextField) {
		[textField resignFirstResponder];
		[confrimPasswordTextField becomeFirstResponder];
	}
	else if (textField == confrimPasswordTextField) {
		[textField resignFirstResponder];
	}
	return YES;
}

@end
