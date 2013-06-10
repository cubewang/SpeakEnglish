//
//  ZAppDelegate.m
//  Dreaming
//
//  Created by Cube Wang on 12-8-14.
//  Copyright (c) 2012年 Dreaming Team. All rights reserved.
//

#import "ZAppDelegate.h"

#import "MainViewController.h"
#import "MainViewController_iPad.h"
#import "UserAccount.h"
#import "MobClick.h"
#import <AVFoundation/AVAudioSession.h>


#define UMENG_APPKEY  @"51b555a856240b6ef3028a8f"


@implementation ZAppDelegate

@synthesize window = _window;

@synthesize mainViewController;
@synthesize centerViewController;
@synthesize deckController;

@synthesize HUD;
@synthesize oldTaskId;
@synthesize autoRefreshingDelegate;

@synthesize userLocation;


- (void)dealloc
{
    self.mainViewController = nil;
    self.centerViewController = nil;
    self.deckController = nil;
    self.HUD = nil;
    self.userLocation = nil;
    
    self.window = nil;
    
    [super dealloc];
}

void uncaughtExceptionHandler(NSException *exception) {
    NSLog(@"CRASH: %@", exception);
    NSLog(@"Stack Trace: %@", [exception callStackSymbols]);
    // Internal error reporting
}

- (void)setupMainView_iPhone
{
    UIImage *gradientImage44 = [UIImage imageNamed:@"NavBar_ios5.png"];
    
    [[UINavigationBar appearance] setTintColor:[UIColor grayColor]];
    [[UINavigationBar appearance] setBackgroundImage:gradientImage44 forBarMetrics:UIBarMetricsDefault];
    
    [[UINavigationBar appearance] setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0], 
      UITextAttributeTextColor, 
      [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0], 
      UITextAttributeTextShadowColor, 
      [NSValue valueWithUIOffset:UIOffsetMake(0, 0)], 
      UITextAttributeTextShadowOffset, 
      [UIFont fontWithName:@"Georgia-Bold" size:0.0], 
      UITextAttributeFont, nil]];
    
    self.mainViewController = [[[MainViewController alloc] init] autorelease];
    self.autoRefreshingDelegate = self.mainViewController;
    
    // Left & Right
    LeftViewController *leftController = [[[LeftViewController alloc] init] autorelease];
    RightViewController * rightController = [[[RightViewController alloc] init] autorelease];
    
    self.centerViewController = [[[UINavigationController alloc] initWithRootViewController:self.mainViewController] autorelease];
    
    self.deckController =  [[[IIViewDeckController alloc] initWithCenterViewController:self.centerViewController
                                                                    leftViewController:leftController
                                                                   rightViewController:rightController] autorelease];
    
    self.deckController.centerhiddenInteractivity = IIViewDeckCenterHiddenNotUserInteractiveWithTapToClose;
    
    self.deckController.leftLedge = LEFT_LEDGE_SIZE;
    self.deckController.rightLedge = RIGHT_LEDGE_SIZE;
    
    self.window.rootViewController = self.deckController;
}

- (void)setupMainView_iPad
{
    MainViewController_iPad *viewController = [[[MainViewController_iPad alloc] initWithNibName:@"MainView_iPad" bundle:nil] autorelease];
    
    self.mainViewController = viewController;
    self.autoRefreshingDelegate = self.mainViewController;
    
    self.window.rootViewController = [[[UINavigationController alloc] initWithRootViewController:viewController] autorelease];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
    
    [application setStatusBarStyle:UIStatusBarStyleBlackOpaque];
    
    [MobClick startWithAppkey:UMENG_APPKEY reportPolicy:REALTIME channelId:nil];
    
    [DreamingAPI initObjectMapping];
    
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [self setupMainView_iPhone];
    }
    else {
        [self setupMainView_iPad];
    }
    
    [self.window makeKeyAndVisible];
    
    [self setupVoteView];
    
    [self setupBackgroundAudioPlaying];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    [self setupBackgroundTask];
}

- (void)setupBackgroundTask
{
    UIBackgroundTaskIdentifier newTaskId = UIBackgroundTaskInvalid;
    
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    
    newTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:NULL];
    
    if (newTaskId != UIBackgroundTaskInvalid && newTaskId != oldTaskId) {
        [[UIApplication sharedApplication] endBackgroundTask:oldTaskId];
    }
    
    self.oldTaskId = newTaskId;
}

- (void)setupBackgroundAudioPlaying
{
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setActive:YES error:nil];
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    NSDate *lastUpdateDate = [[NSUserDefaults standardUserDefaults] objectForKey:kLastUpdateDate];
    NSTimeInterval sec = [[NSDate date] timeIntervalSinceDate:lastUpdateDate];
    
    //1个小时后自动刷新
    if (sec > 60*60) {
        
        [self performSelector:@selector(delayRefreshAction:)
                   withObject:nil
                   afterDelay:1];
    }
}

- (void)delayRefreshAction:(id)sender
{
    if (![self.autoRefreshingDelegate respondsToSelector:@selector(loadArticlesNow:)])
        return;
    
    [self.autoRefreshingDelegate loadArticlesNow:NO];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    return [TencentOAuth HandleOpenURL:url];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    return [TencentOAuth HandleOpenURL:url];
}

+ (ZAppDelegate *)sharedAppDelegate
{
    return (ZAppDelegate *) [UIApplication sharedApplication].delegate;
}

- (void)showNetworkFailed:(UIView *)view {
    
    [self showInformation:view info:NSLocalizedString(@"网络连接失败，请检查网络", @"")];
}

- (void)showInformation:(UIView *)view info:(NSString *)info {
    if (HUD) {
        [HUD removeFromSuperview];
        RELEASE_SAFELY(HUD);
    }
    
    if (view == nil) {
        view = [[ZAppDelegate sharedAppDelegate] window];
    }
    
    if (HUD == nil) {
        HUD = [[MBProgressHUD alloc] initWithView:view];
        HUD.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error.png"]] autorelease];
        
        HUD.mode = MBProgressHUDModeCustomView;
        
        if ([info length] > 12) {
            HUD.detailsLabelText = info;
            HUD.detailsLabelFont = [UIFont systemFontOfSize:16];
        }
        else {
            HUD.labelText = info;
            HUD.labelFont = [UIFont systemFontOfSize:18];
        }
    }
    
    if ([view isKindOfClass:[UIWindow class]]) {
        [view addSubview:HUD];    
    }
    else {
        [view.window addSubview:HUD];
    }
    
    [HUD show:YES];
    [HUD hide:YES afterDelay:1.0];
}

- (void)showProgress:(UIView *)view info:(NSString *)info {
    
    if (HUD) {
        [HUD removeFromSuperview];
        RELEASE_SAFELY(HUD);
    }
    
    HUD = [[MBProgressHUD showHUDAddedTo:view ? view : [[ZAppDelegate sharedAppDelegate] window] animated:YES] retain];
    HUD.mode = MBProgressHUDModeAnnularDeterminate;
    HUD.labelText = info;
}

- (void)setProgress:(UIView *)view progress:(float)progress info:(NSString *)info {
    
    if (HUD == nil)
        return;
    
    HUD.progress = progress;
    HUD.labelText = info;
    
    if (progress >= 1.0) {
        [HUD hide:YES afterDelay:1.0];
    }
}


+ (UILabel*)createNavTitleView:(NSString *)title {
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.backgroundColor = [UIColor clearColor];
    label.text = title;
    label.font = [UIFont boldSystemFontOfSize:20.0f];
    label.textAlignment = UITextAlignmentCenter;
    label.textColor = [[UIDevice currentDevice] userInterfaceIdiom ] == UIUserInterfaceIdiomPhone ? [UIColor blackColor] : [UIColor whiteColor];
    [label sizeToFit];
    
    return label;
}

#pragma mark voteViewDelegate

- (void)setupVoteView {
    
    //第一次打开软件超过50秒，我们设置标志位以便下一次打开软件时显示评分页面
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"showVoteViewTag"]) 
    {
        if (![[NSUserDefaults standardUserDefaults] boolForKey:@"voteHaveShownTag"]) 
        {
            [self performSelector:@selector(showVoteView) withObject:nil afterDelay:2];
        } 
    }
    else 
    {
        [self performSelector:@selector(setShowVoteViewTag) withObject:nil afterDelay:50];
    }
}


- (void)setShowVoteViewTag {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"showVoteViewTag"];
}

- (void)showVoteView {
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"voteHaveShownTag"];
    
    VoteView *voteView =[[VoteView alloc]initWithCancelbutton:@""
                                                  OtherButton:@"" 
                                                     Delegate:self
                                                    SuperView:self.window];
    
    [voteView setAlertBackgroundImage:@"vote_bg.png"];
    [voteView alertShow];
    [voteView release];        
}

- (void)voteViewButtonDidClick:(id)customAlertView atIndex:(NSInteger)index {
    
    if (index == 0) {
        return;
    }
    
    if (index == 1) {
        
        NSString *buyString = NSLocalizedString(@"rate url", @"");
        NSURL *url = [NSURL URLWithString:buyString];
        [[UIApplication sharedApplication] openURL:url];
    }
}

@end
