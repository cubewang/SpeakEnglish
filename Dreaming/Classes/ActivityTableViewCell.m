//
//  ActivityTableViewCell.m
//  Dreaming
//
//  Created by Cube on 11-5-5.
//  Copyright 2011 Dreaming Team. All rights reserved.
//

#import "ActivityTableViewCell.h"


@interface ActivityTableViewCell () {
}

@property (nonatomic, retain) IBOutlet UILabel *dateLabel;
@property (nonatomic, retain) IBOutlet UILabel *locationLabel;
@property (nonatomic, retain) IBOutlet UIImageView *locationImage;
@property (nonatomic, retain) IBOutlet UIImageView *messageUnreadImage;

@end


@implementation ActivityTableViewCell

@synthesize dateLabel;
@synthesize locationImage;
@synthesize locationLabel;
@synthesize messageUnreadImage;


- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    [super setBackgroundColor:backgroundColor];
    
    iconView.backgroundColor = [UIColor clearColor];
    activityLabel.backgroundColor = [UIColor clearColor];
}

- (void)setAvatarUrl:(NSString *)newUrl
{
    if ([newUrl length] == 0) {
        CGRect rc = activityLabel.frame;
        rc.origin.x -= 40;
        activityLabel.frame = rc;
        
        return;
    }
    
    [iconView setImageWithURL:[NSURL URLWithString:newUrl] 
             placeholderImage:[UIImage imageNamed:@"Avatar2.png"]];
}


- (void)setActivity:(ZStatus *)activity
{
    if (activity == nil)
        return;

    [self setAvatarUrl:activity.user.profileImageUrl];
    
    NSString *activityText = nil;
    
    if (activity.sourceFrom && [activity.sourceFrom isEqualToString:@"activity"]) {
        activityText = [NSString stringWithFormat:NSLocalizedString(@"%@关注了你", @""), activity.user.name];
    }
    else { //评论了你
        activityText = [NSString stringWithFormat:NSLocalizedString(@"%@回复了你", @""), activity.user.name];
    }
    
    activityLabel.text = activityText;
    
    self.dateLabel.text = [AudioCommentCell formatTime:activity.createdAt];
    
    NSString *distance = [AudioCommentCell getDistanceFromMe:activity.coordinates];
    if (distance == nil) {
        if (activity.user.location != nil) {
            self.locationLabel.text = activity.user.location;
            self.locationImage.hidden = NO;
        }
    }
    else
    {
        self.locationLabel.text = distance;
        self.locationImage.hidden = NO;
        
    }
    
    if (activity.haveRead)
        self.messageUnreadImage.hidden = YES;
    else
        self.messageUnreadImage.hidden = NO;
}

- (void)setBackgroundImage:(UIImage *)theImage
{
    UIImage *backgroundImage;
    
    if (theImage == nil) {
 
        NSString *backgroundImagePath = [[NSBundle mainBundle] pathForResource:@"ActivityTableViewCell" ofType:@"png"];
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


- (void)dealloc {
    
    [iconView release];
    [activityLabel release];
    
    self.dateLabel = nil;
    self.locationLabel = nil;
    self.locationImage = nil;
    self.messageUnreadImage = nil;

    [super dealloc];
}


@end
