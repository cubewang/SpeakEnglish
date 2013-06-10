//
//  LeftViewController.m
//  Dreaming
//
//  Created by cg on 12-8-17.
//  Copyright (c) 2012年 Dreaming Team. All rights reserved.
//

#import "LeftViewController.h"
#import "IIViewDeckController.h"
#import "SettingViewController.h"
#import "MainViewController.h"
#import "UserLoginViewController.h"
#import "ProfileViewController.h"
#import "FavoritesViewController.h"

#import "UIImageView+WebCache.h"
#import "ZUser.h"
#import "PictureManager.h"
#import "ZStatusTag.h"
#import "UIImageView+WebCache.h"
#import "UserAccount.h"


@interface LeftViewController () {

    UIImageView *avatarImageView;
    UILabel *nameLabel; 
}

@property (nonatomic, retain) UIView *userInfoView;
@property (nonatomic, retain) UIImageView *avatarImageView;
@property (nonatomic, retain) UILabel *nameLabel;


- (void)showMainViewController;
- (void)showSettingView;
- (void)setUserInfoView;
- (void)showUserInfoView;

@end

@implementation LeftViewController

@synthesize tableView;
@synthesize userInfoView;
@synthesize avatarImageView;
@synthesize nameLabel;


- (void)dealloc {
    
    self.tableView = nil;
    self.userInfoView = nil;
    self.avatarImageView = nil;
    self.nameLabel = nil;
    
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self refresh];
    
    self.view.layer.cornerRadius = 5;
    self.view.layer.masksToBounds = YES;
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.scrollsToTop = NO;
    
    [self setUserInfoView];
    
    //默认选中首页项
    [self rowDidSelected:1];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)refresh
{
    [self.avatarImageView setImageWithURL:[NSURL URLWithString:[UserAccount getProfileImageUrl]] 
                         placeholderImage:[UIImage imageNamed:@"Avatar1"]];
    
    NSString *username = [UserAccount getDisplayName];
    self.nameLabel.text = username == nil ? NSLocalizedString(@"点击设置昵称", @""):username;
}

#pragma mark -action 

- (BOOL)viewDeckControllerWillOpenLeftView:(IIViewDeckController*)viewDeckController animated:(BOOL)animated {
    
    [self refresh];
    
    return YES;
}

- (void)setUserInfoView {
    
    if (self.userInfoView == nil) {
        self.userInfoView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"TagCellBackground"]] autorelease];
        self.userInfoView.frame = CGRectMake(0, 0, 200, 58);
    
        UIButton *avatarButton = [[UIButton alloc] initWithFrame:CGRectMake(0,0,60,60)];
        [avatarButton addTarget:self action:@selector(showUserInfoView) forControlEvents:UIControlEventTouchUpInside];
    
        self.nameLabel = [[[UILabel alloc] initWithFrame:CGRectMake(65,5,150,55)] autorelease];
        self.nameLabel.textColor = MENU_TEXT_COLOR;
        self.nameLabel.font = MANU_font;
        self.nameLabel.backgroundColor = [UIColor clearColor];
        
        UIButton *nameLabelButton = [[UIButton alloc] initWithFrame:CGRectMake(60,0,140,60)];
        [nameLabelButton addTarget:self action:@selector(showUserInfoView)forControlEvents:UIControlEventTouchUpInside];
        
        if (self.avatarImageView == nil) {
            self.avatarImageView = [[[UIImageView alloc] initWithFrame:CGRectMake(8,8,44,44)] autorelease];
            self.avatarImageView.contentMode  = UIViewContentModeScaleAspectFit;
        }
        
        [self.userInfoView addSubview:self.nameLabel];
        [self.userInfoView addSubview:self.avatarImageView];
        [self.userInfoView addSubview:avatarButton];
        [self.userInfoView addSubview:nameLabelButton];
        
        self.userInfoView.userInteractionEnabled = YES;
        
        [avatarButton release];
        [nameLabelButton release];
    }
}

- (void)showMainViewController {
    
    MainViewController* mainController = [[ZAppDelegate sharedAppDelegate] mainViewController];
    [mainController setArticleTag:nil];
    self.viewDeckController.centerController = [[ZAppDelegate sharedAppDelegate] centerViewController];
    [self.viewDeckController toggleLeftView];
}

- (void)showSettingView {
   
    SettingViewController *vc = [[[SettingViewController alloc] init] autorelease];
    UINavigationController *navigationController = [[[UINavigationController alloc] initWithRootViewController:vc] autorelease];
    self.viewDeckController.centerController = navigationController;
    
    [self.viewDeckController toggleLeftView];
}

- (void)showFavoritesView {
    
    FavoritesViewController *favoritesViewController = [[[FavoritesViewController alloc] init] autorelease];
    
    UINavigationController *navigationController = [[[UINavigationController alloc] initWithRootViewController:favoritesViewController] autorelease];
    
    self.viewDeckController.centerController = navigationController;
    [self.viewDeckController toggleLeftView];
}

- (void)showUserInfoView {
   
    if ([UserAccount getUserId]) {
        
        ProfileViewController *profileViewController = [[[ProfileViewController alloc] init] autorelease];
        [self presentModalViewController:profileViewController animated:YES];
    }
    else {
        
        UserLoginViewController *userLoginVC = [[[UserLoginViewController alloc] init]autorelease];
        [self presentModalViewController:userLoginVC animated:YES];
    }
}

#pragma mark -
#pragma mark Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 9;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 58.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    return nil;
}

- (void)rowDidSelected:(NSInteger)row
{
    NSIndexPath *indexPathHome = [NSIndexPath indexPathForRow:row inSection:0];
    [self.tableView selectRowAtIndexPath:indexPathHome animated:NO scrollPosition:UITableViewScrollPositionBottom];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"SettingCell";
    
    UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    
    UIImageView *accessoryTypeView = [[[UIImageView alloc] initWithFrame:CGRectMake(160, 22, 16, 16)] autorelease];
    accessoryTypeView.image = [UIImage imageNamed:@"accessoryType_bg"];
    accessoryTypeView.backgroundColor = [UIColor clearColor];
    
    cell.backgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"TagCellBackground"]] autorelease];
    cell.selectedBackgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"TagCellBackground_s"] ] autorelease];
    
    cell.textLabel.textColor = MENU_TEXT_COLOR;
    cell.textLabel.font = MANU_font;
    cell.textLabel.backgroundColor = [UIColor clearColor];
    
    if (indexPath.section == 0 ) {
        
        UIImageView *imageView = [[[UIImageView alloc] initWithFrame:CGRectMake(15, 18, 22, 22)] autorelease];
        imageView.backgroundColor = [UIColor clearColor];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        
        UILabel *label = [[[UILabel alloc] initWithFrame:CGRectMake(15, 2, 160, 55)] autorelease];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = MENU_TEXT_COLOR;
        label.font = MANU_font;
        
        if (indexPath.row == 0) {
            [cell addSubview:self.userInfoView];
        }
        else if (indexPath.row == 1) {
            label.text = NSLocalizedString(@"首页", @"");
            label.frame = CGRectMake(50, 2, 160, 55);
            [cell addSubview:label];
            
            imageView.image = [UIImage imageNamed:@"home"];
            [cell addSubview:imageView];
            
            [cell addSubview:accessoryTypeView];
        }
        else if (indexPath.row == 2) {
            label.text = @"USA";
            [cell addSubview:label];
            
            [cell addSubview:accessoryTypeView];
        }
        else if (indexPath.row == 3) {
            label.text = @"In the News";
            [cell addSubview:label];
            
            [cell addSubview:accessoryTypeView];
        }
        else if (indexPath.row == 4) {
            label.text = @"Entertainment";
            [cell addSubview:label];
            
            [cell addSubview:accessoryTypeView];
        }
        else if (indexPath.row == 5) {
            label.text = @"Words' Stories";
            [cell addSubview:label];
            
            [cell addSubview:accessoryTypeView];
        }
        else if (indexPath.row == 6) {
            label.text = @"Science and Tech";
            [cell addSubview:label];
            
            [cell addSubview:accessoryTypeView];
        }
        else if (indexPath.row == 7) {
            label.text = NSLocalizedString(@"我的喜爱", @"");
            label.frame = CGRectMake(50, 2, 160, 55);
            [cell addSubview:label];
            
            cell.textLabel.textAlignment = UITextAlignmentCenter;
            imageView.image = [UIImage imageNamed:@"my_favorites"];
            [cell addSubview:imageView];
            
            [cell addSubview:accessoryTypeView];
        }
        else if (indexPath.row == 8) {
            label.text = NSLocalizedString(@"设置", @"");
            label.frame = CGRectMake(50, 2, 160, 55);
            [cell addSubview:label];
            
            cell.textLabel.textAlignment = UITextAlignmentCenter;
            imageView.image = [UIImage imageNamed:@"setting"];
            [cell addSubview:imageView];
            
            [cell addSubview:accessoryTypeView];
        }
    }

    return cell;
}

#pragma mark delegate 

- (void)tableView:(UITableView *)atableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 1) 
    {
        [self showMainViewController];
    }
    else if (indexPath.row == 7)
    {
        [self showFavoritesView];
    }
    else if (indexPath.row == 8)
    {
        [self showSettingView];
    }
    else if (indexPath.row > 1 && indexPath.row < 7)
    {
        MainViewController* mainController = [[ZAppDelegate sharedAppDelegate] mainViewController];
        
        NSString *tag = indexPath.row == 2 ? @"USA" :
        indexPath.row == 3 ? @"In the News" :
        indexPath.row == 4 ? @"Entertainment" :
        indexPath.row == 5 ? @"Words and Their Stories" :
        indexPath.row == 6 ? @"Science and Technology" : @"";
        
        [mainController setArticleTag:tag];
        
        self.viewDeckController.centerController = [[ZAppDelegate sharedAppDelegate] centerViewController];
        [self.viewDeckController toggleLeftView];
    }
}

@end
