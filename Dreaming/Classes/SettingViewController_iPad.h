//
//  SettingViewController_iPad.h
//  EnglishFun
//
//  Created by curer on 12-1-4.
//  Copyright 2012 Dreaming Team. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <MessageUI/MessageUI.h>


@interface SettingViewController_iPad : UIViewController <UITableViewDataSource, UITableViewDelegate, MFMailComposeViewControllerDelegate, UIAlertViewDelegate, UIActionSheetDelegate> {
    
    UITableView *tableView;
    
    long long audiofileSizeInBytes;
    long long imagefileSizeInBytes;
}

@property (nonatomic, retain) UITableView *tableView;


@end



