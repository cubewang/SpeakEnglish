//
//  AccountTableViewCell.m
//  Dreaming
//
//  Created by cg on 12-3-15.
//  Copyright (c) 2012年 Dreaming Team. All rights reserved.
//

#import "AccountTableViewCell.h"

@implementation AccountTableViewCell

@synthesize iconView;
@synthesize nameLabel;
@synthesize button;

- (void)dealloc {
    
    [iconView release];
    [nameLabel release];
    [button release];
    
    [super dealloc];
}

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    [super setBackgroundColor:backgroundColor];
    
    iconView.backgroundColor = [UIColor clearColor];
    nameLabel.backgroundColor = [UIColor clearColor];
}
 
- (void)setIcon:(UIImage *)newIcon
{
    iconView.image = newIcon;
}

- (void)setButtonTitile:(NSString *)newButtonTitle {
    
    [button setTitle:newButtonTitle forState:UIControlStateNormal];
}

- (void)setLabelName:(NSString *)newName
{
    nameLabel.text = newName;
}

- (void)setBackgroundImage:(UIImage *)theImage
{
    UIImage *backgroundImage;
    
    if (theImage == nil) {
        
        NSString *backgroundImagePath = [[NSBundle mainBundle] pathForResource:@"cell_background@2x" ofType:@"png"];
        backgroundImage = [[UIImage imageWithContentsOfFile:backgroundImagePath] 
                           stretchableImageWithLeftCapWidth:0.0 topCapHeight:1.0];
    } 
    else {
        backgroundImage = theImage;
    }
    
    self.backgroundView = [[[UIImageView alloc] initWithImage:backgroundImage] autorelease];
    self.backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.backgroundView.frame = self.bounds;
}
 
@end
