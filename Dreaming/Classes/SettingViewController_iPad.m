//
//  SettingViewController_iPad.m
//  EnglishFun
//
//  Created by curer on 12-1-4.
//  Copyright 2012 Dreaming Team. All rights reserved.
//

#import "SettingViewController_iPad.h"
#import "MainViewController.h"
#import "SDImageCache.h"

#import "UpdateUserInfoViewController.h"
#import "UserAccount.h"
#import "AccountsViewController.h"
#import "UserLoginViewController_iPad.h"


@implementation SettingViewController_iPad

@synthesize tableView;


- (void)dealloc {
    
    self.tableView = nil;
    
    [super dealloc];
}

- (IBAction)closeAction:(id)sender {
    
    [self dismissModalViewControllerAnimated:YES];
}


#pragma mark -
#pragma mark Initialization

/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/


#pragma mark -
#pragma mark View lifecycle


- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([self.navigationController.navigationBar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)]) {
       
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"settingBar_ipad.png"] forBarMetrics:UIBarMetricsDefault];
    }
    
    UIButton *buttonLeft = [[[UIButton alloc] initWithFrame:CGRectMake(5, 0, 44, 44)] autorelease];
    [buttonLeft setImage:[UIImage imageNamed:@"back@2x"] forState:UIControlStateNormal];
    [buttonLeft addTarget:self action:@selector(closeAction:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *itemLeft = [[[UIBarButtonItem alloc] initWithCustomView:buttonLeft] autorelease]; 
    
    self.navigationItem.leftBarButtonItem = itemLeft;

    //设置导航条文字
    UILabel* label = [[ZAppDelegate createNavTitleView:NSLocalizedString(@"设置", @"")] autorelease];
    self.navigationItem.titleView = label;
    
    CGRect rc = self.view.frame;
    
    self.tableView = [[[UITableView alloc] initWithFrame:rc 
                                                   style:UITableViewStyleGrouped] autorelease];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:tableView];
    
    // Configure the table view.
    self.view.backgroundColor = self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.userInteractionEnabled = YES;
    self.tableView.alpha = 1;
}
    

/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
*/
/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)sumCacheFileSize
{
    imagefileSizeInBytes = [StringUtils getFileSize:[[SDImageCache sharedImageCache] getDiskCachePath]];
    audiofileSizeInBytes = [StringUtils getFileSize:AUDIO_CACHE_FOLDER];
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 2;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == 0) {
        return 3;
    } 
    else if (section == 1) {
        return 5;
    }
    else {
        return 0;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            return 40;
        }
        return 89;
    }
    
    return 60;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) 
    {
        static NSString *CellIdentifier = @"SettingCell";
        
        UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
            cell.backgroundColor = [UIColor clearColor];
        }
        
        if (indexPath.row == 0) {
            cell.textLabel.text = NSLocalizedString(@"修改资料", @"");
            cell.imageView.image = [UIImage imageNamed:@"settingProfile"];
        }
        else if (indexPath.row == 1) {
            cell.textLabel.text = NSLocalizedString(@"清空缓存", @"");
            cell.detailTextLabel.font = English_font_smallest;
            cell.detailTextLabel.text = [NSString stringWithFormat:NSLocalizedString(@"音频%lld M，图片%lld M", @""), audiofileSizeInBytes / (1014 *1024), imagefileSizeInBytes / (1014 *1024)];
            cell.imageView.image = [UIImage imageNamed:@"settingShare"];
        }
        else if (indexPath.row == 2) {
            cell.textLabel.text = NSLocalizedString(@"意见反馈", @"");
            cell.imageView.image = [UIImage imageNamed:@"settingSuggestion"];
        }
        
        UIView *accessoryTypeView = [[[UIView alloc] initWithFrame:cell.accessoryView.frame] autorelease];
        accessoryTypeView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"accessoryType_bg"]] autorelease];
        accessoryTypeView.backgroundColor = [UIColor clearColor];
        cell.accessoryView = accessoryTypeView;
        
        cell.backgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"settingCell_bg"]] autorelease];
        cell.selectedBackgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"followCell_bg_s"] ] autorelease];
        cell.textLabel.font = MANU_font;
        cell.textLabel.textColor = CELLTEXT_COLOR;
        
        cell.textLabel.highlightedTextColor =  CELLTEXT_COLOR;
        
        return cell;
    }     
    else if (indexPath.section == 1) {
        
        UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil] autorelease];
        cell.detailTextLabel.backgroundColor = CELL_BACKGROUND;
        cell.textLabel.backgroundColor = CELL_BACKGROUND;
        
        if (indexPath.row == 0) {
            cell.backgroundColor = RGBCOLOR(240,240,240);
            cell.textLabel.text = NSLocalizedString(@"精彩推荐",@"");
            cell.userInteractionEnabled = NO;
        }
        else if (indexPath.row == 1) {
            [cell addSubview:[self getSuggestionView:@"english_daily_iPad" text:NSLocalizedString(@"推荐每日英语", @"")]];
        }
        else if (indexPath.row == 2) {
            [cell addSubview:[self getSuggestionView:@"6min_english_iPad" text:NSLocalizedString(@"推荐6分钟英语", @"")]];
        }
        else if (indexPath.row == 3) {
            [cell addSubview:[self getSuggestionView:@"oral_english_iPad" text:NSLocalizedString(@"推荐英语口语角", @"")]];
        }
        else if (indexPath.row == 4) {
            [cell addSubview:[self getSuggestionView:@"esl_english_iPad" text:NSLocalizedString(@"推荐ESL英语", @"")]];
        }
        
        return cell;
    }
    
    return nil;
}

- (UIView*)getSuggestionView:(NSString*)imageName text:(NSString*)text
{
    UIImageView *suggestionView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
    suggestionView.frame = CGRectMake(30, 0, 480, 89);
    
//    UITextView *recommendText = [[[UITextView alloc] initWithFrame:CGRectMake(120, 15, 300, 100)] autorelease];
//    
//    recommendText.textAlignment = UITextAlignmentLeft;
//    recommendText.backgroundColor = [UIColor clearColor];
//    recommendText.textColor = [UIColor blackColor];
//    recommendText.font = [UIFont systemFontOfSize:15.0];
//    
//    recommendText.text = text;
//    
//    [suggestionView addSubview:recommendText];
//    
    return [suggestionView autorelease];
}

#pragma mark -
#pragma mark Table view delegate


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if (indexPath.section == 0) {
        
        if (indexPath.row == 0) {
            
            if ([UserAccount getUserId]) {
                
                UpdateUserInfoViewController *userinformationVC = [[[UpdateUserInfoViewController alloc] init] autorelease];
                
                [self.navigationController pushViewController:userinformationVC animated:YES];
            }
            else {
                UserLoginViewController_iPad *userLoginVC = [[[UserLoginViewController_iPad alloc] init]autorelease];
                [self presentModalViewController:userLoginVC animated:YES];
                
            }
        }
        else if (indexPath.row == 1) {
            
            UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"确认清除本地音频和图片缓存吗？", @"")
                                                               delegate:self
                                                      cancelButtonTitle:NSLocalizedString(@"取消", @"")
                                                 destructiveButtonTitle:NSLocalizedString(@"清除本地缓存", @"")
                                                      otherButtonTitles:nil];
            
            [sheet showInView:self.view];
            [sheet release];
        }
        else if (indexPath.row == 2) {
            [self showEmail];
        }
    }
    else {
        //goto appstore
       
        if (indexPath.row == 1) {
           
            NSString *buyString = NSLocalizedString(@"english daily url", @"");
            
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:buyString]];
        }
        else if (indexPath.row == 2) {
            
            NSString *buyString = NSLocalizedString(@"oral english url", @"");
            
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:buyString]];
        }
        else if (indexPath.row == 3) {
            
            NSString *buyString = NSLocalizedString(@"6 minute url", @"");
            
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:buyString]];
        }
        else if (indexPath.row == 4) {
            
            NSString *buyString = NSLocalizedString(@"esl url",@"");
            
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:buyString]];
        }
    }
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        hud.labelText = NSLocalizedString(@"请稍候...",@"");
        
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            
            [[SDImageCache sharedImageCache] cleanDisk];
            
            [[NSFileManager defaultManager] removeItemAtPath:AUDIO_CACHE_FOLDER error:nil];
            
            imagefileSizeInBytes = audiofileSizeInBytes = 0;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
                
                [self.tableView reloadData];
            });
        });
    }
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}

- (void)showEmail
{
    // This sample can run on devices running iPhone OS 2.0 or later  
    // The MFMailComposeViewController class is only available in iPhone OS 3.0 or later. 
    // So, we must verify the existence of the above class and provide a workaround for devices running 
    // earlier versions of the iPhone OS. 
    // We display an email composition interface if MFMailComposeViewController exists and the device can send emails.
    // We launch the Mail application on the device, otherwise.
    
    Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
    if (mailClass != nil)
    {
        // We must always check whether the current device is configured for sending emails
        if ([mailClass canSendMail])
        {
            [self displayComposerSheet];
        }
        else
        {
            [self launchMailAppOnDevice];
        }
    }
    else
    {
        [self launchMailAppOnDevice];
    }
}

// Displays an email composition interface inside the application. Populates all the Mail fields. 
- (void)displayComposerSheet 
{
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    picker.mailComposeDelegate = self;
    picker.navigationItem.titleView.backgroundColor = [UIColor redColor];
    
    NSArray *toRecipients = [NSArray arrayWithObject:@"zhubukeji@gmail.com"]; 
    
    [picker setToRecipients:toRecipients];
    [picker setSubject:NSLocalizedString(@"意见反馈", @"")];
    
    [picker setMessageBody:nil isHTML:YES];
    
    [self presentModalViewController:picker animated:YES];
    
    [picker release];
}

// Dismisses the email composition interface when users tap Cancel or Send. Proceeds to update the message field with the result of the operation.
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error 
{    
    NSString *message = nil;
    // Notifies users about errors associated with the interface
    switch (result)
    {
        case MFMailComposeResultCancelled:
            //message = @"邮件取消";
            break;
        case MFMailComposeResultSaved:
            //message = @"邮件保存";
            break;
        case MFMailComposeResultSent:
            message = NSLocalizedString(@"邮件已经发送", @"");
            break;
        case MFMailComposeResultFailed:
            message = NSLocalizedString(@"邮件发送失败", @"");
            break;
        default:
            message = NSLocalizedString(@"邮件发送失败", @"");
            break;
    }
    
    if (message) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"提示", @"")
                                                        message:message 
                                                       delegate:nil 
                                              cancelButtonTitle:NSLocalizedString(@"知道了", @"")
                                              otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
    
    [self dismissModalViewControllerAnimated:YES];
}

// Launches the Mail application on the device.
- (void)launchMailAppOnDevice
{
    [[ZAppDelegate sharedAppDelegate] showInformation:self.view 
                                                 info:NSLocalizedString(@"没有找到邮箱", @"")]; 
    
    /* NSString *recipients = @"mailto:first@example.com?cc=second@example.com,third@example.com&subject=Hello from California!";
     NSString *body = @"&body=It is raining in sunny California!";
     
     NSString *email = [NSString stringWithFormat:@"%@%@", recipients, body];
     email = [email stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]; 
     
     [[UIApplication sharedApplication] openURL:[NSURL URLWithString:email]]; */
}

#pragma mark UIAlertViewDeleate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 0) {
        return;
    }
    else if (buttonIndex == 1) 
    {
        [DreamingAPI loginOut];
        
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"lastUpdateMessageId"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"lastUpdateStatusId"];
        
        [[ZAppDelegate sharedAppDelegate] showInformation:self.view info:NSLocalizedString(@"登出成功", @"")];
        
        self.viewDeckController.centerController = [[ZAppDelegate sharedAppDelegate] centerViewController];
    }
}


@end
