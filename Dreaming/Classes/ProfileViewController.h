//
//  ProfileViewController.h
//  Dreaming
//
//  Created by cg on 12-10-11.
//  Copyright (c) 2012年 Dreaming Team. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RestKit/RestKit.h>

@interface ProfileViewController : UIViewController<UIAlertViewDelegate,RKObjectLoaderDelegate,UIActionSheetDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate> {
    
}

@property (nonatomic, retain) IBOutlet UIImageView *avatarImageView;
@property (nonatomic, retain) IBOutlet UILabel *nameLabel;
@property (nonatomic, retain) IBOutlet UIImageView *avatarBackgroundImageView;
@property (nonatomic, retain) IBOutlet UIButton *logoutButton;

- (IBAction)logOut:(id)sender;
- (IBAction)uploadAvatar:(id)sender;

@end
