//
//  UserRegisterViewController_iPad.h
//  DreamingNews
//
//  Created by cg on 12-11-1.
//  Copyright (c) 2012年 Dreaming Team. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@protocol UserRegisterViewController_iPadResultDelegate <NSObject>
@optional
- (void)registerViewControllerReturnResult:(BOOL)bRegistered;
@end

@interface UserRegisterViewController_iPad: UIViewController <UITextFieldDelegate, RKObjectLoaderDelegate,
UITextFieldDelegate> 
{
    id resultDelegate;
}


@property (nonatomic, retain) IBOutlet UITextField *emailTextField;
@property (nonatomic, retain) IBOutlet UITextField *passwordTextField;
@property (nonatomic, retain) IBOutlet UITextField *confrimPasswordTextField;

@property (nonatomic, retain) IBOutlet UIButton *registerButton;

@property (nonatomic, retain) NSString *userName;
@property (nonatomic, retain) NSString *password;

@property (nonatomic, assign) id resultDelegate;

- (IBAction)closeAction:(id)sender;
- (IBAction)registerUserAction:(id)sender;
- (void)back;

@end
