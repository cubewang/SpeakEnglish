//
//  UpdateUserInfoViewController.m
//  Dreaming
//
//  Created by cg on 12-8-31.
//  Copyright (c) 2012年 Dreaming Team. All rights reserved.
//

#import "UpdateUserInfoViewController.h"
#import "UpdateUserDescriptionViewController.h"
#import "UIImageView+WebCache.h"
#import "PictureManager.h"
#import "MBProgressHUD.h"
#import "UserAccount.h"

@interface UpdateUserInfoViewController () {
    
}

@property (nonatomic, retain) ZUser *user;

@property (nonatomic, retain) UIPopoverController *popoverController;

- (void)back;
- (void)uploadAvatar;

@end

@implementation UpdateUserInfoViewController

@synthesize tableView;
@synthesize popoverController;
@synthesize user;

- (void)dealloc {
    
    [[RKClient sharedClient].requestQueue cancelRequestsWithDelegate:self];
    
    self.tableView = nil;
    self.popoverController = nil;
    self.user = nil;
    
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    //设置导航条文字
    UILabel* label = [ZAppDelegate createNavTitleView:NSLocalizedString(@"修改资料", @"")];
    self.navigationItem.titleView = label;
    [label release];
    
    UIButton *buttonLeft = [[UIButton alloc] initWithFrame:CGRectMake(5, 0, 44, 44)];
    [buttonLeft setImage:[UIImage imageNamed:@"back@2x"] forState:UIControlStateNormal];
    [buttonLeft addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *itemLeft = [[UIBarButtonItem alloc] initWithCustomView:buttonLeft]; 
    
    self.navigationItem.leftBarButtonItem = itemLeft;
    [itemLeft release];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.tableView reloadData];
    
     self.viewDeckController.enabled = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
     self.viewDeckController.enabled = YES;
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 4;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"UpdateUserInfoCell";
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
     
    if (indexPath.row == 0) {
        
        cell.imageView.layer.cornerRadius = 2.0;
        cell.imageView.layer.masksToBounds = YES;
        [cell.imageView setContentMode: UIViewContentModeScaleAspectFit];
        
        [cell.imageView setImageWithURL:[NSURL URLWithString:[UserAccount getProfileImageUrl]] 
                       placeholderImage:[UIImage imageNamed:@"Avatar1.png"]];

        cell.textLabel.text = NSLocalizedString(@"上传头像", @"");
        
    }
    else if (indexPath.row == 1) {
        
        NSString *name = [UserAccount getDisplayName] == nil ? @"" : [UserAccount getDisplayName];
        
        cell.textLabel.text = [NSString stringWithFormat:@"%@：%@",NSLocalizedString(@"昵称", @""),name];
    }
    else if (indexPath.row == 2) {
        
        NSString *description = [UserAccount getDescription] == nil ? @"" : [UserAccount getDescription];
        
        cell.textLabel.text = [NSString stringWithFormat:@"%@：%@",NSLocalizedString(@"介绍自己", @""),description];
    }
    else if (indexPath.row == 3) {
        
        NSString *location = [UserAccount getLocation] == nil ? @"" : [UserAccount getLocation];
        
        cell.textLabel.text = [NSString stringWithFormat:@"%@：%@",NSLocalizedString(@"所在地", @""),location];
    }
    
    UIView *accessoryTypeView = [[[UIView alloc] initWithFrame:cell.accessoryView.frame] autorelease];
    accessoryTypeView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"accessoryType_bg"]] autorelease];
    accessoryTypeView.backgroundColor = [UIColor clearColor];
    cell.accessoryView = accessoryTypeView;
    
    cell.backgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"settingCell_bg"]] autorelease];
    cell.selectedBackgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"followCell_bg_s"] ] autorelease];
    
    cell.textLabel.font = MANU_font;
    cell.textLabel.textColor = CELLTEXT_COLOR;
    
    
    return cell;
}

#pragma mark TableViewdelegate 

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UpdateUserDescriptionViewController *vc = [[UpdateUserDescriptionViewController alloc] init];
    
    if (indexPath.row == 0) {
        [self uploadAvatar];
    }
    else if (indexPath.row == 1) {
        
        vc.originDescriptionText = [UserAccount getDisplayName];
        vc.type = NSLocalizedString(@"昵称", @"");
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if (indexPath.row == 2) {
       
        vc.originDescriptionText = [UserAccount getDescription];
        vc.type = NSLocalizedString(@"介绍自己", @"");
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if (indexPath.row == 3) {
        
        vc.originDescriptionText = [UserAccount getLocation];
        vc.type = NSLocalizedString(@"所在地", @"");
        [self.navigationController pushViewController:vc animated:YES];
    }
    
    [vc release];
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
}
    

#pragma mark RKObjectLoaderDelegate methods

- (void)request:(RKRequest*)request didLoadResponse:(RKResponse*)response {

}

- (void)objectLoader:(RKObjectLoader*)objectLoader didLoadObjects:(NSArray*)objects {
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    if ([objects count] == 0) {
        
        [[ZAppDelegate sharedAppDelegate] showInformation:self.view info:NSLocalizedString(@"修改失败",@"")];
        
        return;
    }
    
    [[ZAppDelegate sharedAppDelegate] showInformation:self.view info:NSLocalizedString(@"修改成功",@"")];
    
    self.user = [objects objectAtIndex:0];
    
    [UserAccount setUserInfo:self.user];
    
    [self.tableView reloadData];
}

- (void)objectLoader:(RKObjectLoader*)objectLoader didFailWithError:(NSError*)error { 
   
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [[ZAppDelegate sharedAppDelegate] showNetworkFailed:self.view];
}

- (void)request:(RKRequest *)request didFailLoadWithError:(NSError *)error {
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [[ZAppDelegate sharedAppDelegate] showNetworkFailed:self.view];
}


#pragma mark action 

- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)uploadAvatar {
    
    UIActionSheet *actionSheet = nil;
    
    if (![UIImagePickerController isSourceTypeAvailable:
          UIImagePickerControllerSourceTypeCamera]) 
    {
        actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString (@"选择你的头像",@"")
                                                  delegate:self
                                         cancelButtonTitle:NSLocalizedString (@"取消",@"")
                                    destructiveButtonTitle:nil
                                         otherButtonTitles:NSLocalizedString (@"图库",@""),nil
                       ];
        actionSheet.tag = 1;//表示没有摄像头
    }
    else {
        actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString (@"选择你的头像",@"")
                                                  delegate:self
                                         cancelButtonTitle:NSLocalizedString (@"取消",@"")
                                    destructiveButtonTitle:nil
                                         otherButtonTitles:NSLocalizedString (@"图库",@""),NSLocalizedString (@"拍照",@""), nil
                       ];
    }
    
    [actionSheet showInView:self.view];
    [actionSheet release];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        UIImagePickerController *picker = [[[UIImagePickerController alloc] init] autorelease];
        picker.delegate = self;
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        picker.allowsEditing = YES;
        picker.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            self.popoverController = [[[UIPopoverController alloc] initWithContentViewController:picker] autorelease];
            [self.popoverController presentPopoverFromRect:self.navigationItem.titleView.frame 
                                                    inView:self.view 
                                  permittedArrowDirections:UIPopoverArrowDirectionUp 
                                                  animated:YES];
        }
        else
        {
            [self presentModalViewController:picker animated:YES];
        }
    }
    else if (buttonIndex == 1 && actionSheet.tag == 0) {
        UIImagePickerController *picker = [[[UIImagePickerController alloc] init] autorelease];
        picker.delegate = self;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.allowsEditing = YES;
        picker.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            self.popoverController = [[[UIPopoverController alloc] initWithContentViewController:picker] autorelease];
            [self.popoverController presentPopoverFromRect:self.navigationItem.titleView.frame
                                                    inView:self.view 
                                  permittedArrowDirections:UIPopoverArrowDirectionUp 
                                                  animated:YES];
        }
        else
        {
            [self presentModalViewController:picker animated:YES];
        }
    }
}

+ (NSString *)GetUUID 
{
    CFUUIDRef theUUID = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, theUUID);
    CFRelease(theUUID);
    return [(NSString *)string autorelease];
}

+ (NSString *)getImagePathInDocument {
    NSString *localFilePath = [DOCUMENT_FOLDER stringByAppendingPathComponent:@"Image"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:localFilePath]) {
        NSError *error;
        [[NSFileManager defaultManager] createDirectoryAtPath:localFilePath withIntermediateDirectories:NO attributes:nil error:&error];
    }
    
    return localFilePath;
}

- (void)imagePickerController:(UIImagePickerController *)picker 
didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    
    UIImage* thumbImage = [PictureManager scaleAndRotateImage:image andMaxLen:200];
    
    NSData *imageData = UIImageJPEGRepresentation(thumbImage, 0.4);
    
    NSString *fileName = [NSString stringWithFormat:@"%@", [UpdateUserInfoViewController GetUUID]];
    NSString *filePath = [[UpdateUserInfoViewController getImagePathInDocument] stringByAppendingPathComponent:fileName];
    
    BOOL bRes = [imageData writeToFile:filePath atomically:YES];
    
    if (bRes) {
        
        [DreamingAPI updateProfileImage:filePath
                            delegate:self];
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }
    [picker dismissModalViewControllerAnimated:YES];
}

@end
