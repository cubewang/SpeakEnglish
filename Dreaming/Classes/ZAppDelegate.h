//
//  ZAppDelegate.h
//  Dreaming
//
//  Created by Cube Wang on 12-8-14.
//  Copyright (c) 2012年 Dreaming Team. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <TencentOpenAPI/TencentOAuth.h>

#import "MBProgressHUD.h"
#import "VoteView.h"

#import "IIViewDeckController.h"
#import "MainViewController.h"
#import "LeftViewController.h"
#import "RightViewController.h"

#define kLastUpdateDate  @"lastUpdateDate"

@interface ZAppDelegate : UIResponder <UIApplicationDelegate> {
    
    MBProgressHUD *HUD;
}

@property (strong, nonatomic) UIWindow *window;

@property (retain, nonatomic) MainViewController *mainViewController;
@property (retain, nonatomic) UINavigationController *centerViewController;
@property (retain, nonatomic) IIViewDeckController* deckController;

@property (nonatomic, retain) MBProgressHUD *HUD;

@property (nonatomic, assign) UIBackgroundTaskIdentifier oldTaskId;

@property (nonatomic, assign) id<AutoRefreshingDelegate> autoRefreshingDelegate;

@property (nonatomic, retain) CLLocation *userLocation;


+ (ZAppDelegate *)sharedAppDelegate;
- (void)showNetworkFailed:(UIView *)view;
- (void)showInformation:(UIView *)view info:(NSString *)info;

- (void)showProgress:(UIView *)view info:(NSString *)info;
- (void)setProgress:(UIView *)view progress:(float)progress info:(NSString *)info;


+ (UILabel*)createNavTitleView:(NSString *)title;


@end
