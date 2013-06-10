//
//  ActivityTableViewCell.h
//  Dreaming
//
//  Created by Cube on 11-5-5.
//  Copyright 2011 Dreaming Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "AudioCommentCell.h"


@interface ActivityTableViewCell : UITableViewCell 
{
    IBOutlet UIImageView *iconView;
    IBOutlet UILabel *activityLabel;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor;
- (void)setAvatarUrl:(NSString *)newUrl;
- (void)setActivity:(ZStatus *)newActivity;
- (void)setBackgroundImage:(UIImage *)theImage;

@end
