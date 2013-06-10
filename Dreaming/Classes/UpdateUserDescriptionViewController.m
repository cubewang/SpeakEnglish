//
//  UpdateUserDescriptionViewController.m
//  Dreaming
//
//  Created by cg on 12-9-4.
//  Copyright (c) 2012年 Dreaming Team. All rights reserved.
//

#import "UpdateUserDescriptionViewController.h"
#import "ZUser.h"
#import "MBProgressHUD.h"
#import "UserAccount.h"

@interface UpdateUserDescriptionViewController (){
    
}

@property (nonatomic, retain) ZUser *user;

- (void)back;
- (void)save;

@end

@implementation UpdateUserDescriptionViewController

@synthesize descriptionText;
@synthesize user;
@synthesize type;
@synthesize originDescriptionText;

- (void) dealloc {
    
    self.descriptionText = nil;
    self.user = nil;
    self.originDescriptionText = nil;
    
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    UIButton *buttonLeft = [[UIButton alloc] initWithFrame:CGRectMake(5, 0, 44, 44)];
    [buttonLeft setImage:[UIImage imageNamed:@"back@2x"] forState:UIControlStateNormal];
    [buttonLeft addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *itemLeft = [[UIBarButtonItem alloc] initWithCustomView:buttonLeft]; 
    
    self.navigationItem.leftBarButtonItem = itemLeft;
    
    [itemLeft release];
    
    UIButton *buttonRight = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 52, 30)];

    [buttonRight setBackgroundImage:[UIImage imageNamed:@"saveButton_bg"] forState:UIControlStateNormal];
    [buttonRight addTarget:self action:@selector(save) forControlEvents:UIControlEventTouchUpInside];
    buttonRight.titleLabel.font = [UIFont systemFontOfSize:16];
    [buttonRight setTitle:NSLocalizedString(@"保存",@"") forState:UIControlStateNormal];
    [buttonRight setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    UIBarButtonItem *itemRight = [[UIBarButtonItem alloc] initWithCustomView:buttonRight]; 
    
    self.navigationItem.rightBarButtonItem = itemRight;
    
    [itemRight release];
    
    self.user = [[[ZUser alloc] init] autorelease];
    
    self.descriptionText.text = self.originDescriptionText;
    [descriptionText becomeFirstResponder];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.viewDeckController.enabled = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    self.viewDeckController.enabled = YES;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)back {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)save {
    
    [self.descriptionText resignFirstResponder];
    
    if ([self.descriptionText.text length] == 0) {
        return;
    }
    
    if ([type isEqualToString:NSLocalizedString(@"昵称", @"")]) {
        [DreamingAPI updateProfile:self.descriptionText.text
                        blogUrl:nil
                       location:nil
                    description:nil
                       delegate:self];
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }
    else if ([type isEqualToString:NSLocalizedString(@"介绍自己", @"")]) {
        [DreamingAPI updateProfile:nil
                        blogUrl:nil
                       location:nil
                    description:self.descriptionText.text
                       delegate:self];
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }
    else if ([type isEqualToString:NSLocalizedString(@"所在地", @"")]) {
        [DreamingAPI updateProfile:nil
                        blogUrl:nil
                       location:self.descriptionText.text
                    description:nil
                       delegate:self];
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }
}

#pragma mark RKRequestDelegate
- (void)request:(RKRequest *)request didReceiveResponse:(RKResponse *)response {
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    [[ZAppDelegate sharedAppDelegate] showInformation:self.view info:NSLocalizedString(@"修改成功",@"")];
    
    if ([type isEqualToString:NSLocalizedString(@"昵称", @"")]) {
         self.user.name = self.descriptionText.text;
    }
    else if ([type isEqualToString:NSLocalizedString(@"介绍自己", @"")]) {
        self.user.description = self.descriptionText.text;
    }
    else if ([type isEqualToString:NSLocalizedString(@"所在地", @"")]) {
        self.user.location = self.descriptionText.text;
    }
    [UserAccount setUserInfo:self.user];
    
    [self back];
}

- (void)request:(RKRequest *)request didFailLoadWithError:(NSError *)error{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [[ZAppDelegate sharedAppDelegate] showNetworkFailed:self.view];
}

@end
