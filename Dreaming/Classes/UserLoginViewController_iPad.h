//
//  UserLoginViewController_iPad.h
//  Dreaming
//
//  Created by cg on 12-11-1.
//  Copyright (c) 2012年 Dreaming Team. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TencentOpenAPI/TencentOAuth.h>
#import <RestKit/RestKit.h>

@protocol UserLoginViewController_iPadDelegate <NSObject>
@optional
- (void)userLoginViewControllerReturnResult;
@end

@interface UserLoginViewController_iPad : UIViewController <UITextFieldDelegate,RKObjectLoaderDelegate, TencentSessionDelegate> {
    
    CGRect keyboardRect;
    BOOL bKeyBoardShow;
}

@property (nonatomic, retain) IBOutlet UITextField *emailTextField;
@property (nonatomic, retain) IBOutlet UITextField *passwordTextField;

@property (nonatomic, retain) IBOutlet UIButton *registerButton;
@property (nonatomic, retain) IBOutlet UIButton *loginButton;
@property (nonatomic, retain) IBOutlet UIButton *sinaButton;
@property (nonatomic, retain) IBOutlet UIImageView *loginImageView;
@property (nonatomic, retain) IBOutlet UILabel *orLabel;
@property (nonatomic, retain) IBOutlet UILabel *qqLabel;
@property (nonatomic, retain) IBOutlet UILabel *weiboLabel;
@property (nonatomic, retain) IBOutlet UIButton *qqButton;
@property (nonatomic, retain) id delegate;

@property (nonatomic, retain) NSString *userName;
@property (nonatomic, retain) NSString *password;

- (IBAction)login:(id)sender;
- (IBAction)registerUser:(id)sender;
- (IBAction)sinaButtonAction:(id)sender;
- (IBAction)qqButtonAction:(id)sender;
- (void)back;

@end
