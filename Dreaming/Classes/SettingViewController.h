//
//  SettingViewController.h
//  EnglishFun
//
//  Created by curer on 12-1-4.
//  Copyright 2012 Dreaming Team. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "MainViewController.h"
#import <MessageUI/MessageUI.h>


@interface SettingViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, MFMailComposeViewControllerDelegate, UIAlertViewDelegate, UIActionSheetDelegate> {
    
    UITableView *tableView;
    
    long long audiofileSizeInBytes;
    long long imagefileSizeInBytes;
}

@property (nonatomic, retain) IBOutlet UITableView *tableView;

- (void)showLeft;
- (void)showEmail;
- (void)setNavigationBar;

@end



