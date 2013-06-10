//
//  TagDetailsController.m
//  Dreaming
//
//  Created by Cube on 11-5-6.
//  Copyright 2011 Dreaming. All rights reserved.
//

#import "TagDetailsController.h"


@implementation TagDetailsController

@synthesize articleTag;


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
    
    if (articleTag)
    {
        //设置导航条文字
        UILabel* label = [ZAppDelegate createNavTitleView:articleTag];
        self.navigationItem.titleView = label;
        [label release];
    }
    
    UIButton *buttonLeft = [[UIButton alloc] initWithFrame:CGRectMake(5, 0, 44, 44)];
    [buttonLeft setImage:[UIImage imageNamed:@"back@2x"] forState:UIControlStateNormal];
    [buttonLeft addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *itemLeft = [[UIBarButtonItem alloc] initWithCustomView:buttonLeft]; 
    
    self.navigationItem.leftBarButtonItem = itemLeft;
    [itemLeft release];
}

- (BOOL)showTagDetails:(NSString*)tag {
    
    return ![articleTag isEqualToString:tag];
}

- (BOOL)getArticleList:(NSInteger)maxId length:(NSInteger)length useCacheFirst:(BOOL)useCacheFirst
{
    if (articleTag == nil) {
        return NO;
    }
    
    [DreamingAPI getTimeline:self.articleTag maxId:maxId length:length delegate:self useCacheFirst:NO];
    
    return YES;
}

- (void)close
{
    [self.navigationController popViewControllerAnimated:YES];
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
    
    self.articleTag = nil;
    
    [super dealloc];
}


@end

