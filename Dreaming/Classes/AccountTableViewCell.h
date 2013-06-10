//
//  AccountTableViewCell.h
//  Dreaming
//
//  Created by cg on 12-3-15.
//  Copyright (c) 2012年 Dreaming Team. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface AccountTableViewCell : UITableViewCell {
    
    IBOutlet UIImageView *iconView;
    IBOutlet UILabel *nameLabel;
    IBOutlet UIButton *button;
  
}

@property (nonatomic, readonly) UIImageView *iconView;
@property (nonatomic, readonly) UILabel *nameLabel;
@property (nonatomic, readonly) UIButton *button;

- (void)setIcon:(UIImage *)newIcon;
- (void)setLabelName:(NSString *)newName;
- (void)setButtonTitile:(NSString *)newButtonTitle;

@end
