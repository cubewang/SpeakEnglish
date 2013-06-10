    //
//  UserLoginViewController.m
//  Dreaming
//
//  Created by cg on 11-7-5.
//  Copyright 2011 Dreaming Team. All rights reserved.
//

#import "UserLoginViewController.h"
#import "DreamingAPI.h"
#import "ZUser.h"
#import "ZOAuthUser.h"
#import "ZAppDelegate.h"
#import "UserAccount.h"
#import "MBProgressHUD.h"
#import "StringUtils.h"
#import "CUShareCenter.h"
#import "CUSinaShareClient.h"
#import "GlobalDef.h"

#define TENCENT_APP_ID      @"100239135"      //qq dev account

@interface UserLoginViewController () {
    
}

@property (nonatomic, retain) TencentOAuth *tencentOAuth;

@end

@implementation UserLoginViewController


@synthesize emailTextField, passwordTextField, registerButton;
@synthesize sinaButton,loginButton;
@synthesize loginImageView;
@synthesize orLabel;
@synthesize qqLabel;
@synthesize weiboLabel;
@synthesize tencentOAuth;
@synthesize qqButton;
@synthesize delegate;
@synthesize userName, password;

#pragma mark RKObjectLoaderDelegate methods
- (void)request:(RKRequest*)request didLoadResponse:(RKResponse*)response {
    
}

- (void)objectLoader:(RKObjectLoader *)objectLoader didLoadObject:(id)object {
    
    if ([object isKindOfClass:[ZUser class]]) {
        [self loadZUserObject:object];
    }
    else if ([object isKindOfClass:[ZOAuthUser class]])
    {
        [self loadZAuthuserObject:object];
    }    
}

- (void)loadZAuthuserObject:(id)object
{
    ZOAuthUser *userAuth = (ZOAuthUser *)object;
    userAuth.user.password = userAuth.password;
    
    [self commonLoginUser:userAuth.user];
}

- (void)loadZUserObject:(id)object
{
    ZUser* user = (ZUser *)object;
    
    if ([user.screenName length] == 0) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        [[ZAppDelegate sharedAppDelegate] showInformation:self.view info:NSLocalizedString(@"登录失败", @"") ];
        
        return;
    }
    
    user.password = self.password;
    
    [self commonLoginUser:user];
}

- (void)commonLoginUser:(ZUser *)user
{
    [UserAccount setUserInfo:user];
    
    [RKObjectManager sharedManager].client.username = [UserAccount getUserName];
    [RKObjectManager sharedManager].client.password = [UserAccount getUserPassword];
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [[ZAppDelegate sharedAppDelegate] showInformation:self.view info:NSLocalizedString(@"登录成功",@"")];
    
    if ([delegate respondsToSelector:@selector(userLoginViewControllerReturnResult)]) {
        
        [delegate userLoginViewControllerReturnResult];
    }
    
    [self back];
}

- (void)objectLoader:(RKObjectLoader*)objectLoader didFailWithError:(NSError*)error {
    
    if (objectLoader.response.statusCode == 401) {
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        [[ZAppDelegate sharedAppDelegate] showInformation:self.view info:NSLocalizedString(@"帐号或密码错误",@"")];
    }
    else {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [[ZAppDelegate sharedAppDelegate] showNetworkFailed:self.view];
    }
}

- (void)request:(RKRequest *)request didFailLoadWithError:(NSError *)error {
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [[ZAppDelegate sharedAppDelegate] showNetworkFailed:self.view];
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

- (void)back {
    
    [(LeftViewController *)[ZAppDelegate sharedAppDelegate].deckController.leftController refresh];
    
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)sinaButtonAction:(id)sender {
    [[CUShareCenter sharedInstanceWithType:SINACLIENT] Bind:self];
}

- (IBAction)qqButtonAction:(id)sender
{
    self.tencentOAuth = [[TencentOAuth alloc] initWithAppId:TENCENT_APP_ID
                                                andDelegate:self];
    
    [self.tencentOAuth authorize:[NSArray arrayWithObjects:
                                  @"get_info", @"get_simple_userinfo",
                                  nil] inSafari:NO];
}

- (void)_login
{
    self.userName = emailTextField.text;
    self.password = passwordTextField.text;
    
    [DreamingAPI login:self.userName andPassword:self.password delegate:self];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

//用户登录
- (IBAction)login:(id)sender
{
    
    if ([emailTextField.text length] == 0) {
        
        [[ZAppDelegate sharedAppDelegate] showInformation:self.view info:NSLocalizedString(@"请输入帐号",@"")];
        
        return ;
    }
    
    if ([passwordTextField.text length] == 0) {
        
        [[ZAppDelegate sharedAppDelegate] showInformation:self.view info:NSLocalizedString(@"请输入密码",@"")];
        
        return ;
    }
    
    //验证密码长度，密码有可能为空
    if ((passwordTextField.text.length > 0 && passwordTextField.text.length < PASSWORD_MIN_LENGTH) || passwordTextField.text.length > PASSWORD_MAX_LENGTH) {
        
        UIAlertView *alertView = [[UIAlertView alloc] 
                                  initWithTitle:NSLocalizedString (@"提示",@"")
                                  message:[NSString stringWithFormat:NSLocalizedString (@"密码长度需要在%d～%d之间",@""), PASSWORD_MIN_LENGTH, PASSWORD_MAX_LENGTH]                                  
                                  delegate:nil 
                                  cancelButtonTitle:NSLocalizedString (@"确定",@"")
                                  otherButtonTitles:nil];
        [alertView show];
        [alertView release];
        
        return;
    }
    
    [passwordTextField resignFirstResponder];
    [emailTextField resignFirstResponder];
    
    [self _login];
}

- (IBAction)registerUser:(id)sender {
    
    UserRegisterViewController *viewController = [[UserRegisterViewController alloc] init];
    viewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    viewController.resultDelegate = self;
    
    [self presentModalViewController:viewController animated:YES];
    
    [viewController release];
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
    //判断密码是否太长
    if (textField == passwordTextField && textField.text.length >= PASSWORD_MAX_LENGTH && range.length == 0) {
        return NO;
    }
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	if (textField == emailTextField) {
		[textField resignFirstResponder];
		[passwordTextField becomeFirstResponder];
	} 
	else if (textField == passwordTextField) 
    {
		[textField resignFirstResponder];
        [self login:nil];
	}
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    
    [passwordTextField resignFirstResponder];
    [emailTextField resignFirstResponder];
}

- (void)registerViewControllerReturnResult:(BOOL)bRegistered {
    
    if (bRegistered) {
        
        if ([delegate respondsToSelector:@selector(userLoginViewControllerReturnResult)]) {
            
            [delegate userLoginViewControllerReturnResult];
        }
    }
    
    [self dismissModalViewControllerAnimated:NO];
}


- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(keyboardWillShow:) 
                                                 name:UIKeyboardWillShowNotification 
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(keyboardWillHide:) 
                                                 name:UIKeyboardWillHideNotification 
                                               object:nil];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:UIKeyboardWillShowNotification 
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:UIKeyboardWillHideNotification 
                                                  object:nil];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[[CUShareCenter sharedInstanceWithType:SINACLIENT] shareClient] addDelegate:self];
    
    self.tencentOAuth = [[[TencentOAuth alloc] initWithAppId:TENCENT_APP_ID andDelegate:self] autorelease];
    self.tencentOAuth.redirectURI = @"www.qq.com";
    
    [self.loginButton setTitle:NSLocalizedString(@"登录", @"") forState:UIControlStateNormal];
    [self.registerButton setTitle:NSLocalizedString(@"注册", @"") forState:UIControlStateNormal];
    self.emailTextField.placeholder = NSLocalizedString(@"用户名", @"");
    self.passwordTextField.placeholder = NSLocalizedString(@"密码", @"");
    self.orLabel.text = NSLocalizedString(@"或者", @"");
    self.qqLabel.text = NSLocalizedString(@"QQ帐号登录", @"");
    self.weiboLabel.text = NSLocalizedString(@"新浪微博登录", @"");
    
    [self setTopBar];
    
    self.passwordTextField.secureTextEntry = YES;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    //[super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.emailTextField = nil;
    self.passwordTextField = nil;
}

#pragma mark -
#pragma mark CUShareClientDelegate

- (void)CUAuthSucceed:(CUShareClient *)client
{
    if ([client isKindOfClass:[CUSinaShareClient class]]) {
        
        CUSinaShareClient *sinaClient = (CUSinaShareClient *)client;
        
        NSString *token = sinaClient.requestToken;
        
        [DreamingAPI bind:token openId:nil platformType:@"sina" delegate:self];
    }
}

#pragma mark - TencentSessionDelegate

- (void)tencentDidLogin {
    
    NSString *openId = self.tencentOAuth.openId;
    NSString *token = self.tencentOAuth.accessToken;
    
    [DreamingAPI bind:token openId:openId platformType:@"qq" delegate:self];
}

- (void)tencentDidNotLogin:(BOOL)cancelled
{
    if (cancelled){
        NSLog(@"用户取消登录");
    }
    else {
        NSLog(@"登录失败");
    }
}

#pragma mark- keyboard

//Code from Brett Schumann
- (void)keyboardWillShow:(NSNotification *)note {
    
    if (bKeyBoardShow) {
        return;
    }
    
    // get keyboard size and loctaion
    CGRect keyboardBounds;
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    keyboardRect = keyboardBounds;
    
    // animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
    CGRect viewFrame = self.loginImageView.frame;
    viewFrame.origin.y -= (keyboardBounds.size.height /3 ) * 2;
    self.loginImageView.frame = viewFrame;
    
    CGRect emailviewFrame = self.emailTextField.frame;
    emailviewFrame.origin.y -= (keyboardBounds.size.height /3 ) * 2;
    self.emailTextField.frame = emailviewFrame;
    
    CGRect passwordviewFrame = self.passwordTextField.frame;
    passwordviewFrame.origin.y -= (keyboardBounds.size.height /3 ) * 2;
    self.passwordTextField.frame = passwordviewFrame;
    
    CGRect loginButtonFrame = self.loginButton.frame;
    loginButtonFrame.origin.y -= (keyboardBounds.size.height /3 ) * 2;
    self.loginButton.frame = loginButtonFrame;
    
    CGRect registerButtonFrame = self.registerButton.frame;
    registerButtonFrame.origin.y -= (keyboardBounds.size.height /3 ) * 2;
    self.registerButton.frame = registerButtonFrame;
    
    CGRect sinaButtonFrame = self.sinaButton.frame;
    sinaButtonFrame.origin.y -= (keyboardBounds.size.height /3 ) * 2;
    self.sinaButton.frame = sinaButtonFrame;
    
    CGRect orLabelFrame = self.orLabel.frame;
    orLabelFrame.origin.y -= (keyboardBounds.size.height /3 ) * 2;
    self.orLabel.frame = orLabelFrame;
    
    CGRect qqLabelFrame = self.qqLabel.frame;
    qqLabelFrame.origin.y -= (keyboardBounds.size.height /3 ) * 2;
    self.qqLabel.frame = qqLabelFrame;
    
    CGRect weiboLabelFrame = self.weiboLabel.frame;
    weiboLabelFrame.origin.y -= (keyboardBounds.size.height /3 ) * 2;
    self.weiboLabel.frame = weiboLabelFrame;
    
    CGRect qqButtonFrame = self.qqButton.frame;
    qqButtonFrame.origin.y -= (keyboardBounds.size.height /3 ) * 2;
    self.qqButton.frame = qqButtonFrame;
    
    // commit animations
    [UIView commitAnimations];
    
    bKeyBoardShow = YES;
}

- (void)keyboardWillHide:(NSNotification *)note{
    
    self.sinaButton.hidden = NO;
    
    if (!bKeyBoardShow) {
        return;
    }
    
    bKeyBoardShow = NO;
    
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
    CGRect viewFrame = self.loginImageView.frame;
    viewFrame.origin.y += (keyboardRect.size.height / 3 ) * 2;
    self.loginImageView.frame = viewFrame;
    
    CGRect emailviewFrame = self.emailTextField.frame;
    emailviewFrame.origin.y += (keyboardRect.size.height / 3 ) * 2;
    self.emailTextField.frame = emailviewFrame;
    
    CGRect passwordviewFrame = self.passwordTextField.frame;
    passwordviewFrame.origin.y  += (keyboardRect.size.height / 3 ) * 2;
    self.passwordTextField.frame = passwordviewFrame;
    
    CGRect loginButtonFrame = self.loginButton.frame;
    loginButtonFrame.origin.y += (keyboardRect.size.height / 3 ) * 2;
    self.loginButton.frame = loginButtonFrame;
    
    CGRect registerButtonFrame = self.registerButton.frame;
    registerButtonFrame.origin.y += (keyboardRect.size.height /3 ) * 2;
    self.registerButton.frame = registerButtonFrame;
    
    CGRect sinaButtonFrame = self.sinaButton.frame;
    sinaButtonFrame.origin.y += (keyboardRect.size.height / 3 ) * 2;
    self.sinaButton.frame = sinaButtonFrame;
    
    CGRect orLabelFrame = self.orLabel.frame;
    orLabelFrame.origin.y += (keyboardRect.size.height / 3 ) * 2;
    self.orLabel.frame = orLabelFrame;
    
    CGRect qqLabelFrame = self.qqLabel.frame;
    qqLabelFrame.origin.y += (keyboardRect.size.height / 3 ) * 2;
    self.qqLabel.frame = qqLabelFrame;
    
    CGRect weiboLabelFrame = self.weiboLabel.frame;
    weiboLabelFrame.origin.y += (keyboardRect.size.height / 3 ) * 2;
    self.weiboLabel.frame = weiboLabelFrame;
    
    CGRect qqButtonFrame = self.qqButton.frame;
    qqButtonFrame.origin.y += (keyboardRect.size.height / 3 ) * 2;
    self.qqButton.frame = qqButtonFrame;
    
    // commit animations
    [UIView commitAnimations];
} 

- (void)dealloc {
    
    [[RKClient sharedClient].requestQueue cancelRequestsWithDelegate:self];
    
    [[[CUShareCenter sharedInstanceWithType:SINACLIENT] shareClient] removeDelegate:self];
    
    [emailTextField release];
    [passwordTextField release];
    [registerButton release];
    
    self.sinaButton = nil;
    self.qqButton = nil;
    self.loginButton = nil;
    self.loginImageView = nil;
    self.orLabel = nil;
    self.qqLabel = nil;
    self.weiboLabel = nil;
    self.delegate = nil;
    self.userName = nil;
    self.password = nil;
    
    self.tencentOAuth = nil;
    
    [super dealloc];
}


@end
