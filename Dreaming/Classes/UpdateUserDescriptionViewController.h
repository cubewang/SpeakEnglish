//
//  UpdateUserDescriptionViewController.h
//  Dreaming
//
//  Created by cg on 12-9-4.
//  Copyright (c) 2012年 Dreaming Team. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UpdateUserDescriptionViewController : UIViewController <RKRequestDelegate>{
    
}

@property (nonatomic, retain) IBOutlet UITextField *descriptionText;
@property (nonatomic, retain) NSString *type;
@property (nonatomic, retain) NSString *originDescriptionText;

@end
