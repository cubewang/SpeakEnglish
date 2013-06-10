//
//  RightViewController.h
//
//
//  Created by Marcel Dierkes on 04.12.11.
//  Copyright (c) 2011 Dreaming Team. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "ActivityTableViewCell.h"


@interface RightViewController : UIViewController <RKObjectLoaderDelegate>
{
    NSMutableArray *_statusItems;
    NSMutableArray *_statusItemsCached;
}

@property (nonatomic, retain) NSMutableArray *statusItems;
@property (nonatomic, retain) NSMutableArray *statusItemsCached;

@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) ActivityTableViewCell *tableViewCell;
@property (nonatomic, retain) UINib *tableViewCellNib; 


- (void)refresh;

@end
