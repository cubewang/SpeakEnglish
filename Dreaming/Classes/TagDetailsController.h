//
//  TagDetailsController.h
//  Dreaming
//
//  Abstract: 标签详细视图控制器
//
//  Created by Cube on 11-10-8.
//  Copyright 2011 Dreaming Team. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseTableViewController.h"


@interface TagDetailsController : BaseTableViewController {

    NSString *articleTag;
}

@property (nonatomic, copy) NSString *articleTag;


@end
