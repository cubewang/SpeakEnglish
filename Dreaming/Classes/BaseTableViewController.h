//
//  BaseTableViewController.h
//  Dreaming
//
//  Abstract: 基础列表视图控制器，提供基本的单元格风格的表格视图
//
//  Created by Cube on 11-5-4.
//  Copyright 2011 Dreaming Team. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RTTableViewCell.h"
#import "EGORefreshTableHeaderView.h"

#import "DreamingAPI.h"


@protocol BaseTableViewControllerDelegate <NSObject>

/** 
 * Called when tell BaseTableViewController the table data was dirty. 
 */
- (void)setTableNeedRefreshed:(BOOL)needRefreshed;

@end



#define SECTION_LENGTH 20 //TableView每次Load的Item数目

@interface BaseTableViewController : UIViewController <RKObjectLoaderDelegate, EGORefreshTableHeaderDelegate, UITableViewDelegate, UITableViewDataSource, BaseTableViewControllerDelegate>
{
    NSMutableArray *statusItems; // 文章列表
    NSMutableArray *statusItemsCached; 
    int statusCountBeforeLoading; //分段请求前的文章数，用于记录是否请求完所有服务器的文章
    
    BOOL _needRefreshed;
    
    UITableView *_baseTableView;
    
    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _reloading;
}

// Reset and reparse
- (void)refresh;

// Properties
@property (nonatomic, retain) NSMutableArray *statusItems;

@property (nonatomic, retain) UITableView* baseTableView;

@property (nonatomic, retain) NSDate *lastUpdateDate;

@property (nonatomic, retain) EGORefreshTableHeaderView *refreshHeaderView;

- (void)reloadTableViewDataSource;
- (void)doneLoadingTableViewData;

- (void)enforceRefresh;

@end
