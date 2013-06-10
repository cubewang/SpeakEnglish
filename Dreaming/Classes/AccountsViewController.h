//
//  AccountsViewController.h
//  Dreaming
//
//  Created by cg on 12-3-15.
//  Copyright (c) 2012年 Dreaming Team. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AccountTableViewCell.h"
#import "CUShareCenter.h"
#import "CUShareClient.h"
#import "CUConfig.h"

@interface AccountsViewController : UIViewController
<CUShareClientDelegate>
{
    UITableView *tableView; 
}

@property (nonatomic, retain) IBOutlet UITableView *tableView;

- (void)back;

@end
