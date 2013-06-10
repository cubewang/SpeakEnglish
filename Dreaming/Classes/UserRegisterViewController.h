//
//  UserRegisterViewController.h
//
//  Created by cg on 11-6-30.
//  Copyright 2011 Dreaming Team. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@protocol registerViewControllerReturnResultDelegate <NSObject>
@optional
- (void)registerViewControllerReturnResult:(BOOL)bRegistered;
@end

@interface UserRegisterViewController: UIViewController <UITextFieldDelegate, RKObjectLoaderDelegate,
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
