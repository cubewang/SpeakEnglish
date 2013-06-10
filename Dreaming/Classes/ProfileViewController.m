//
//  ProfileViewController.m
//  Dreaming
//
//  Created by cg on 12-10-11.
//  Copyright (c) 2012年 Dreaming Team. All rights reserved.
//

#import "ProfileViewController.h"
#import "GlobalDef.h"
#import "UIImageView+WebCache.h"
#import "UserAccount.h"
#import "DreamingAPI.h"
#import "PictureManager.h"
#import "MBProgressHUD.h"
#import "ZAppDelegate.h"
#import "ZUser.h"

@interface ProfileViewController () {
    
}

@property (nonatomic, retain) ZUser *user;

- (IBAction)back:(id)sender;

@end

@implementation ProfileViewController

@synthesize avatarImageView;
@synthesize nameLabel;
@synthesize user;
@synthesize avatarBackgroundImageView;
@synthesize logoutButton;

- (void)dealloc {

    self.avatarImageView = nil;
    self.nameLabel = nil;
    self.user = nil;
    self.avatarBackgroundImageView = nil;
    self.logoutButton = nil;
    
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    UIImageView *topBar = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 46)] autorelease];
    [topBar setImage:[UIImage imageNamed:@"NavBar_ios5@2x"]];
    [self.view addSubview:topBar];
    
    UIButton *topBarLeftButton = [[[UIButton alloc] initWithFrame:CGRectMake(6, 3, 44, 44)] autorelease];
    [topBarLeftButton setBackgroundImage:[UIImage imageNamed:@"back@2x"] forState:UIControlStateNormal];
    [topBarLeftButton addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:topBarLeftButton];
    
    NSString *avatarPath = [UserAccount getProfileImageUrl];

    NSURL *avatarUrl = [NSURL URLWithString:avatarPath];
    
    [self.avatarImageView  setImageWithURL:avatarUrl placeholderImage:nil];
    
    if ([UserAccount getDisplayName]) {
        
        self.nameLabel.text = [UserAccount getDisplayName];
       
    }
    else {
        self.nameLabel.text = NSLocalizedString(@"点击设置昵称", @"");
    }
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)  {
        
        CGRect avatarBackgroundImageViewFrame = self.avatarBackgroundImageView.frame;
        avatarBackgroundImageViewFrame.origin.y = 100;
        avatarBackgroundImageViewFrame.size.width = 89;
        avatarBackgroundImageViewFrame.size.height = 89;
        avatarBackgroundImageViewFrame.origin.x = (SCREEN_WIDTH-avatarBackgroundImageViewFrame.size.width)/2; 
        
        self.avatarBackgroundImageView.frame = avatarBackgroundImageViewFrame;
        
        self.avatarImageView.frame = avatarBackgroundImageViewFrame;
        
        CGRect nameLabelFrame = self.nameLabel.frame;
        nameLabelFrame.origin.x = (SCREEN_WIDTH-nameLabelFrame.size.width)/2;
        nameLabelFrame.origin.y = 200;
        
        self.nameLabel.frame = nameLabelFrame;
        
        CGRect logoutButtonFrame = self.logoutButton.frame;
        logoutButtonFrame.origin.x = (SCREEN_WIDTH-logoutButtonFrame.size.width)/2;
        logoutButtonFrame.origin.y = 300;
        self.logoutButton.frame = logoutButtonFrame;
    }
    
    [self.logoutButton setTitle:NSLocalizedString(@"退出登录", @"") forState:UIControlStateNormal];
    [self.logoutButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark Action

- (IBAction)back:(id)sender {
    
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)logOut:(id)sender {
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"提示",@"")  
                                                        message:NSLocalizedString(@"确定退出？",@"") 
                                                       delegate:self 
                                              cancelButtonTitle:NSLocalizedString(@"取消",@"") 
                                              otherButtonTitles:NSLocalizedString(@"确定",@""), nil];
    
    [alertView show];
    [alertView release];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex == 1) {
        
        [DreamingAPI loginOut];
        
        [(LeftViewController *)[ZAppDelegate sharedAppDelegate].deckController.leftController refresh];
        
        [self back:nil];
    }
}

- (IBAction)uploadAvatar:(id)sender {
    
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
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        picker.allowsEditing = YES;
        picker.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        
        [self presentModalViewController:picker animated:YES];
        
        [picker release];
    }
    else if (buttonIndex == 1 && actionSheet.tag == 0) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.allowsEditing = YES;
        picker.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        [self presentModalViewController:picker animated:YES];
        
        [picker release];
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
    
    NSString *fileName = [NSString stringWithFormat:@"%@", [[self class] GetUUID]];
    NSString *filePath = [[[self class] getImagePathInDocument] stringByAppendingPathComponent:fileName];
    
    BOOL bRes = [imageData writeToFile:filePath atomically:YES];
    
    if (bRes) {
        
        [DreamingAPI updateProfileImage:filePath
                            delegate:self];
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }
    [picker dismissModalViewControllerAnimated:YES];
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
    
    [self.avatarImageView  setImageWithURL:[NSURL URLWithString:[UserAccount getProfileImageUrl]] placeholderImage:nil];
}

- (void)objectLoader:(RKObjectLoader*)objectLoader didFailWithError:(NSError*)error {
  
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [[ZAppDelegate sharedAppDelegate] showNetworkFailed:self.view];
}

- (void)request:(RKRequest *)request didFailLoadWithError:(NSError *)error {
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [[ZAppDelegate sharedAppDelegate] showNetworkFailed:self.view];
}

@end
