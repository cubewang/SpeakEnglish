//
//  MainViewController_iPad.m
//  Dreaming
//
//  Created by Cube on 12-12-30.
//  Copyright (c) 2012年 Dreaming Team. All rights reserved.
//

#import "MainViewController_iPad.h"
#import "UserLoginViewController_iPad.h"
#import "ProfileViewController.h"
#import "SettingViewController_iPad.h"

@interface MainViewController_iPad ()

@property (nonatomic, retain) IBOutlet UITableView *categoryTableView;

@property (nonatomic, retain) UIView *userInfoView;
@property (nonatomic, retain) UIImageView *avatarImageView;
@property (nonatomic, retain) UILabel *nameLabel;

@end


@implementation MainViewController_iPad

@synthesize categoryTableView;

@synthesize userInfoView;
@synthesize avatarImageView;
@synthesize nameLabel;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    CGRect baseTableViewRect = self.baseTableView.frame;
    baseTableViewRect.origin.x = 200;
    baseTableViewRect.size.width -= 200;
    baseTableViewRect.size.height += 44;
    self.baseTableView.frame = baseTableViewRect;
    
    self.categoryTableView.scrollsToTop = NO;
    self.categoryTableView.scrollEnabled = NO;
    
    [self.view addSubview:self.categoryTableView];
    
    [self setUserInfoView];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self refreshAvatarAndName];
}

- (void)dealloc {
    [super dealloc];
    
    self.categoryTableView = nil;
    
    self.userInfoView = nil;
    self.avatarImageView = nil;
    self.nameLabel = nil;
}

- (BOOL)getArticleList:(NSInteger)maxId length:(NSInteger)length useCacheFirst:(BOOL)useCacheFirst
{
    if ([self.settedTag isEqualToString:NSLocalizedString(@"我的喜爱", @"")])
    {
        [DreamingAPI getFavorites:maxId length:length delegate:self useCacheFirst:useCacheFirst];
    }
    else
    {
        [self setGuideline:NO];
        
        return [super getArticleList:maxId length:length useCacheFirst:useCacheFirst];
    }
}

- (void)objectLoader:(RKObjectLoader*)objectLoader didLoadObjects:(NSArray*)objects {
    
    NSString *string = [objectLoader.URL absoluteString];
    
    [super objectLoader:objectLoader didLoadObjects:objects];
    
    if ([string hasPrefix:[NSString stringWithFormat:@"%@%@",MAIN_PATH,FAVORITE_LIST]])
    {
        [self reloadNotifications];
    }
}

- (void)objectLoader:(RKObjectLoader*)objectLoader didFailWithError:(NSError*)error {
    
    NSString *string = [objectLoader.URL absoluteString];
    
    if ([string hasPrefix:[NSString stringWithFormat:@"%@%@",MAIN_PATH,FAVORITE_LIST]] &&
        [UserAccount getUserId] == nil)
    {
        
        [self doneLoadingTableViewData];
        [self.baseTableView reloadData];
        
        [[ZAppDelegate sharedAppDelegate] showInformation:self.view info:NSLocalizedString(@"你需要登录才能查看你的喜爱",@"")];
        
        return;
    }
    
    [super objectLoader:objectLoader didFailWithError:error];
}

- (void)reloadNotifications {
    
    if ([self.statusItems count] > 0) {
        [self setGuideline:NO];
    }
    else {
        [self setGuideline:YES];
    }
}

- (void)setGuideline:(BOOL)useGuideline {
    if (useGuideline) {
        
        UIImageView *imageView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"favorites_empty_iPad"]] autorelease];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        self.baseTableView.tableHeaderView = imageView;
    }
    else {
        self.baseTableView.tableHeaderView = nil;
    }
}

- (void)setUserInfoView {
    
    if (self.userInfoView == nil) {
        self.userInfoView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"TagCellBackground"]] autorelease];
        self.userInfoView.frame = CGRectMake(0, 0, 200, 67);
        
        UIButton *avatarButton = [[[UIButton alloc] initWithFrame:CGRectMake(0,0,60,67)] autorelease];
        [avatarButton addTarget:self action:@selector(showUserInfoView) forControlEvents:UIControlEventTouchUpInside];
        
        self.nameLabel = [[[UILabel alloc] initWithFrame:CGRectMake(65,5,150,55)] autorelease];
        self.nameLabel.textColor = MENU_TEXT_COLOR;
        self.nameLabel.font = MANU_font;
        self.nameLabel.backgroundColor = [UIColor clearColor];
        
        UIButton *nameLabelButton = [[[UIButton alloc] initWithFrame:CGRectMake(60,0,140,67)] autorelease];
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
    }
    
    [self refreshAvatarAndName];
}

- (void)refreshAvatarAndName
{
    [self.avatarImageView setImageWithURL:[NSURL URLWithString:[UserAccount getProfileImageUrl]] 
                         placeholderImage:[UIImage imageNamed:@"Avatar1"]];
    
    NSString *username = [UserAccount getDisplayName];
    self.nameLabel.text = username == nil ? NSLocalizedString(@"点击设置昵称", @""):username;
}

- (void)showUserInfoView {
    
    if ([UserAccount getUserId]) {
        
        ProfileViewController *profileViewController = [[[ProfileViewController alloc] init] autorelease];
        [self presentModalViewController:profileViewController animated:YES];
    }
    else {
        
        UserLoginViewController_iPad *userLoginVC = [[[UserLoginViewController_iPad alloc] init]autorelease];
        [self presentModalViewController:userLoginVC animated:YES];
    }
}

- (void)showSetting {
    
    SettingViewController_iPad *viewController = [[[SettingViewController_iPad alloc] 
                                                   initWithNibName:@"SettingView_iPad"
                                                   bundle:nil] autorelease];
    
    UINavigationController *navigationController = [[[UINavigationController alloc] 
                                                     initWithRootViewController:viewController] autorelease];
    
    navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    
    [self presentModalViewController:navigationController animated:YES];
}


#pragma mark -
#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == self.baseTableView) {
        
        return [super numberOfSectionsInTableView:tableView];
    }
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.baseTableView) {
        
        return [super tableView:tableView numberOfRowsInSection:section];
    }
    
    return 9;
}

- (NSString *)tableView:(UITableView *)aTableView titleForHeaderInSection:(NSInteger)section
{
    if (aTableView == self.baseTableView) {
        
        return nil;
    }
    
    return nil;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    if (tableView == self.baseTableView) {
        
        return [super tableView:tableView heightForRowAtIndexPath:indexPath];
    }
    
    return 67.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.baseTableView) {
        
        return [super tableView:tableView cellForRowAtIndexPath:indexPath];
    }
    
    static NSString *CellIdentifier = @"SettingCell";
    
    UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    
    UIImageView *accessoryTypeView = [[[UIImageView alloc] initWithFrame:CGRectMake(160, 27, 16, 16)] autorelease];
    accessoryTypeView.image = [UIImage imageNamed:@"accessoryType_bg"];
    accessoryTypeView.backgroundColor = [UIColor clearColor];
    
    cell.backgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"TagCellBackground"]] autorelease];
    cell.selectedBackgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"TagCellBackground_s"] ] autorelease];
    
    cell.textLabel.textColor = MENU_TEXT_COLOR;
    cell.textLabel.font = MANU_font;
    cell.textLabel.backgroundColor = [UIColor clearColor];
    
    if (indexPath.section == 0 ) {
        
        UIImageView *imageView = [[[UIImageView alloc] initWithFrame:CGRectMake(15, 22, 22, 22)] autorelease];
        imageView.backgroundColor = [UIColor clearColor];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        
        UILabel *label = [[[UILabel alloc] initWithFrame:CGRectMake(15, 6, 160, 55)] autorelease];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = MENU_TEXT_COLOR;
        label.font = MANU_font;
        
        if (indexPath.row == 0) {
            [cell addSubview:self.userInfoView]; 
        }
        else if (indexPath.row == 1) {
            label.text = NSLocalizedString(@"首页", @"");
            label.frame = CGRectMake(50, 6, 160, 55);
            [cell addSubview:label];
            
            imageView.image = [UIImage imageNamed:@"home"];
            [cell addSubview:imageView];
            
            [cell addSubview:accessoryTypeView];
            
            //默认选中首页项
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:0];    
            [tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionBottom];
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
            label.frame = CGRectMake(50, 6, 160, 55);
            [cell addSubview:label];
            
            cell.textLabel.textAlignment = UITextAlignmentCenter;
            imageView.image = [UIImage imageNamed:@"my_favorites"];
            [cell addSubview:imageView];
            
            [cell addSubview:accessoryTypeView];
        }
        else if (indexPath.row == 8) {
            label.text = NSLocalizedString(@"设置", @"");
            label.frame = CGRectMake(50, 6, 160, 55);
            [cell addSubview:label];
            
            cell.textLabel.textAlignment = UITextAlignmentCenter;
            imageView.image = [UIImage imageNamed:@"setting"];
            [cell addSubview:imageView];
            
            [cell addSubview:accessoryTypeView];
            
            UIButton *settingButton = [[[UIButton alloc] initWithFrame:CGRectMake(0,0,200,67)] autorelease];
            [settingButton addTarget:self action:@selector(showSetting) forControlEvents:UIControlEventTouchUpInside];
            
            [cell addSubview:settingButton];
        }
    }
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (tableView == self.baseTableView) {
        
        return [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    }
    
    if (indexPath.row == 1) {
        
        [self setArticleTag:nil];
    }
    else if (indexPath.row == 7) {
        [self setArticleTag:NSLocalizedString(@"我的喜爱", @"")];
    }
    else if (indexPath.row == 8) {
    }
    else {

        NSString *tag = indexPath.row == 2 ? @"USA" :
        indexPath.row == 3 ? @"In the News" :
        indexPath.row == 4 ? @"Entertainment" :
        indexPath.row == 5 ? @"Words and Their Stories" :
        indexPath.row == 6 ? @"Science and Technology" : @"";
        
        [self setArticleTag:tag];
    }
}

@end
