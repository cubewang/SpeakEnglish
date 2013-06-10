//
//  FavoritesViewController.m
//  Dreaming
//
//  Created by Cube on 13-3-5.
//  Copyright 2013 Dreaming. All rights reserved.
//

#import "FavoritesViewController.h"


@implementation FavoritesViewController


#pragma mark -
#pragma mark View lifecycle

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    self.viewDeckController.enabled = NO;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    self.viewDeckController.enabled = YES;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    //设置导航条文字
    UILabel* label = [ZAppDelegate createNavTitleView:@"我的喜爱"];
    self.navigationItem.titleView = label;
    [label release];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        
        UIButton *buttonLeft = [[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 51, 30)] autorelease];
        [buttonLeft setImage:[UIImage imageNamed:@"ButtonMenu"] forState:UIControlStateNormal];
        [buttonLeft addTarget:self action:@selector(showLeft) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *itemLeft = [[[UIBarButtonItem alloc] initWithCustomView:buttonLeft] autorelease];
        
        self.navigationItem.leftBarButtonItem = itemLeft;
    }
    
    [self setGuideline:YES];
}

- (void)showLeft
{
    [self.viewDeckController toggleLeftView];
}

- (BOOL)getArticleList:(NSInteger)maxId length:(NSInteger)length useCacheFirst:(BOOL)useCacheFirst
{
    [DreamingAPI getFavorites:maxId length:length delegate:self useCacheFirst:useCacheFirst];
    
    return YES;
}

- (void)objectLoader:(RKObjectLoader*)objectLoader didLoadObjects:(NSArray*)objects {
    
    [super objectLoader:objectLoader didLoadObjects:objects];
    
    [self reloadNotifications];
}

- (void)reloadNotifications {
    
    if ([self.statusItems count] > 0) {
        [self setGuideline:NO];
    }
    else {
        [self setGuideline:YES];
    }
}

- (void)objectLoader:(RKObjectLoader*)objectLoader didFailWithError:(NSError*)error {
    
    if ([UserAccount getUserId] == nil) {
        
        [self doneLoadingTableViewData];
        [self.baseTableView reloadData];
        
        [[ZAppDelegate sharedAppDelegate] showInformation:self.view info:NSLocalizedString(@"你需要登录才能查看你的喜爱",@"")];
        
        return;
    }
    
    [super objectLoader:objectLoader didFailWithError:error];
}

- (void)close
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setGuideline:(BOOL)useGuideline {
    if (useGuideline) {
        
        UIImageView *imageView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"favorites_empty@2x"]] autorelease];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        self.baseTableView.tableHeaderView = imageView;
    }
    else {
        self.baseTableView.tableHeaderView = nil;
    }
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    //[super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
    
    [super dealloc];
}


@end

