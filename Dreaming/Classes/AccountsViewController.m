//
//  AccountsViewController.m
//  Dreaming
//
//  Created by cg on 12-3-15.
//  Copyright (c) 2012年 Dreaming Team. All rights reserved.
//

#import "AccountsViewController.h"
#import "CUSinaShareClient.h"
#import "CURenrenShareClient.h"
#import "CUShareCenter.h"
#import "CUTencentShareClient.h"

@implementation AccountsViewController

@synthesize tableView;
 
- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

-(void) dealloc {
    
    self.tableView = nil;
    
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.rowHeight = 45; 
    
    //设置导航条文字
    UILabel* label = [ZAppDelegate createNavTitleView:@"共享平台设置"];
    self.navigationItem.titleView = label;
    [label release];
    
    UIButton *buttonLeft = [[UIButton alloc] initWithFrame:CGRectMake(5, 0, 44, 44)];
    [buttonLeft setImage:[UIImage imageNamed:@"back@2x"] forState:UIControlStateNormal];
    [buttonLeft addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *itemLeft = [[UIBarButtonItem alloc] initWithCustomView:buttonLeft]; 
    
    self.navigationItem.leftBarButtonItem = itemLeft;
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    [[[CUShareCenter sharedInstanceWithType:SINACLIENT] shareClient] removeDelegate:self];
    [[[CUShareCenter sharedInstanceWithType:RENRENCLIENT] shareClient] removeDelegate:self];
    [[[CUShareCenter sharedInstanceWithType:TTWEIBOCLIENT] shareClient] removeDelegate:self];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.tableView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:YES];
    
    [[[CUShareCenter sharedInstanceWithType:SINACLIENT] shareClient] addDelegate:self];
    [[[CUShareCenter sharedInstanceWithType:RENRENCLIENT] shareClient] addDelegate:self];
    [[[CUShareCenter sharedInstanceWithType:TTWEIBOCLIENT] shareClient] addDelegate:self];
    
    [self.tableView reloadData];
}

#pragma mark UIAction

- (void)back {
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)atableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"AccountTableViewCell";
    
    AccountTableViewCell *accountCell = (AccountTableViewCell *)[atableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (accountCell == nil) {
        NSArray *nibs = [[NSBundle mainBundle] loadNibNamed:CellIdentifier
                                                      owner:nil 
                                                    options:nil];
        
        for (id item in nibs) {
            if ([item isKindOfClass:[UITableViewCell class]]) {
                accountCell = item;
                break;
            }
        }
    }
    
    accountCell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (indexPath.row == SINACLIENT) {
        [accountCell setIcon:[UIImage imageNamed:@"sina.png"]];
        [accountCell setLabelName:@"绑定新浪微博"];
        NSString *str = [[CUShareCenter sharedInstanceWithType:SINACLIENT] isBind] ? @"取消绑定":@"绑定" ;
        [accountCell setButtonTitile:str];
    }
    else if (indexPath.row == RENRENCLIENT)
    {
        [accountCell setIcon:[UIImage imageNamed:@"renren.png"]];
        [accountCell setLabelName:@"绑定人人网"];
        NSString *str = [[CUShareCenter sharedInstanceWithType:RENRENCLIENT] isBind] ? @"取消绑定":@"绑定" ;
        [accountCell setButtonTitile:str];
    }
    else if (indexPath.row == TTWEIBOCLIENT)
    {
        [accountCell setIcon:[UIImage imageNamed:@"tencent.png"]];
        [accountCell setLabelName:@"绑定腾讯微博"];
        NSString *str = [[CUShareCenter sharedInstanceWithType:TTWEIBOCLIENT] isBind] ? @"取消绑定":@"绑定" ;
        [accountCell setButtonTitile:str];
    }
    
    [accountCell.button addTarget:self action:@selector(bindButtonClicked:) 
                 forControlEvents:UIControlEventTouchUpInside];
    accountCell.button.tag = indexPath.row;
    
    accountCell.backgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"boundCell_bg"]] autorelease];
    
    return accountCell;
}


#pragma mark Table view delegate

-(IBAction)bindButtonClicked:(id)sender {
    
    UIButton *btn = (UIButton *)sender;
    
    BOOL bBind = [[CUShareCenter sharedInstanceWithType:btn.tag] isBind];
    if (bBind) {
        [[CUShareCenter sharedInstanceWithType:btn.tag] unBind];
        
        bBind = [[CUShareCenter sharedInstanceWithType:btn.tag] isBind];
        
        NSString *text = !bBind ? @"取消成功":@"取消失败";
        
        if ([text length]) {
            [[ZAppDelegate sharedAppDelegate] showInformation:self.view info:text];
        }
    }
    else {
        [[CUShareCenter sharedInstanceWithType:btn.tag] Bind:self];
    }
    
    [self.tableView reloadData];
}

#pragma mark CUShareClientDelegate

- (void)CUAuthSucceed:(CUShareClient *)client
{
}

- (void)CUAuthFailed:(CUShareClient *)client withError:(NSError *)error
{
   [[ZAppDelegate sharedAppDelegate] showInformation:self.view info:@"绑定失败"];
}

@end
