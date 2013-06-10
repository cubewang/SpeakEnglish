//
//  LeftViewController.h
//  EnglishFun
//
//  Created by Cube on 12-08-16.
//  Copyright 2012 Dreaming Team. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "DreamingAPI.h"
#import "GlobalDef.h"


@class LeftViewCell;

@interface LeftViewController : UIViewController
<UITableViewDelegate,UITableViewDataSource,UIActionSheetDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate> {

}

@property (nonatomic, retain) IBOutlet UITableView *tableView;


- (void)refresh;

@end
