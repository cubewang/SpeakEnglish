//
//  UpdateUserInfoViewController.h
//  Dreaming
//
//  Created by cg on 12-8-31.
//  Copyright (c) 2012年 Dreaming Team. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "ZUser.h"

@interface UpdateUserInfoViewController : UIViewController <UITableViewDataSource, UITableViewDelegate,RKRequestDelegate,UIActionSheetDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,RKObjectLoaderDelegate>{
    
}

@property (nonatomic, retain) IBOutlet UITableView *tableView;

@end
