//
//  TextCommentCell.m
//  EnglishFun
//
//  Created by curer on 12-1-9.
//  Copyright 2012 Dreaming Team. All rights reserved.
//

#import "TextCommentCell.h"
#import "ZStatus.h"
#import "GlobalDef.h"
#import "StringUtils.h"
#import "UIImageView+WebCache.h"
#import <QuartzCore/QuartzCore.h>


@implementation TextCommentCell

@synthesize userNameLabel;
@synthesize commentLabel;
@synthesize dateLabel;
@synthesize userAvatarImageView;

@synthesize replyingImageView1;
@synthesize replyingImageView2;
@synthesize replyingLabel;

@synthesize deleteAndFavoriteButton;
@synthesize favoriteCountLabel;


+ (int)heightForCell:(ZStatus *)status
{    
    CGSize s = [status.text sizeWithFont:English_font_small 
                           constrainedToSize:CGSizeMake(SCREEN_WIDTH - AVATAR_HEIGHT - kTableCellSmallMargin * 3, MAXFLOAT)
                               lineBreakMode:UILineBreakModeWordWrap];
    
    return s.height + 60;
}

- (void)awakeFromNib
{
    // Initialization code.
    userNameLabel.font = English_font_small;
    [userNameLabel setBackgroundColor:[UIColor clearColor]];
    
    [dateLabel setBackgroundColor:[UIColor clearColor]];
    
    commentLabel.font = English_font_small;
    commentLabel.numberOfLines = 0;
    [commentLabel setBackgroundColor:[UIColor clearColor]];
    commentLabel.textColor = ZBSTYLE_tableSubTextColor;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
    }
    return self;
}

- (void)changeReplyingState:(NSString *)replyingStateText hidden:(BOOL)hidden
{
    self.replyingImageView1.hidden = hidden;
    self.replyingImageView2.hidden = hidden;
    self.replyingLabel.hidden = hidden;
    self.replyingLabel.text = replyingStateText;
}

- (void)setDataSource:(ZStatus *)status;
{
    userNameLabel.text = status.user.name;
    
    if ([status.user.name isEqualToString:@"cubewang"]) {
        userNameLabel.textColor = OFFICIAL_COLOR;
    }
    else {
        userNameLabel.textColor = ZBSTYLE_textColor;
    }
    
    [userAvatarImageView setImageWithURL:[NSURL URLWithString:status.user.profileImageUrl]
                        placeholderImage:[UIImage imageNamed:@"Avatar1.png"]];
    
    NSString *createTime = [StringUtils intervalSinceTime:status.createdAt andTime:[NSDate date]];
    
    //去掉日期后面的时间
    if ([createTime length] > 0) {
        NSRange range = [createTime rangeOfString:@" "];
        if (range.location != NSNotFound && ![createTime hasSuffix:@"ago"] && ![createTime hasSuffix:@"now"]) {
            range.length = range.location;
            range.location = 0;
            
            createTime = [createTime substringWithRange:range];
            dateLabel.text = createTime;
        }
        else {
            dateLabel.text = createTime;
        }
    }
    else {
        dateLabel.text = @"";
    }

    commentLabel.text = status.text;
    
    if ([[UserAccount getUserId] isEqualToString:[NSString stringWithFormat:@"%d",status.user.userID]])
    {
        [self.deleteAndFavoriteButton setImage:[UIImage imageNamed:@"delete_button@2x.png"] forState:UIControlStateNormal];
    }
    else {
        NSString *imageName = status.isFavorited ? @"thumbs_up_on" : @"thumbs_up_off";
        [self.deleteAndFavoriteButton setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    }
    
    self.favoriteCountLabel.text = [NSString stringWithFormat:@"%d", status.favoritesCount];
}

- (void)setCommentDelegate:(NSInteger)tagId target:(id)target action:(SEL)selector
{
    self.deleteAndFavoriteButton.tag = tagId;
    
    if (target != nil && selector != nil)
        [self.deleteAndFavoriteButton addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state.
}

- (void)dealloc {
    [userNameLabel release];
    [commentLabel release];
    [dateLabel release];
    [userAvatarImageView release];
    
    self.replyingImageView1 = nil;
    self.replyingImageView2 = nil;
    self.replyingLabel = nil;
    
    self.deleteAndFavoriteButton = nil;
    self.favoriteCountLabel = nil;
    
    [super dealloc];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    userNameLabel.text = nil;
    commentLabel.text = nil;
    dateLabel.text = nil;
    userAvatarImageView.image = nil;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom ] == UIUserInterfaceIdiomPad) {
        
        CGRect favoriteButtonRect = self.deleteAndFavoriteButton.frame;
        CGRect favoriteLabelRect = self.favoriteCountLabel.frame;
        
        favoriteButtonRect.origin.x = 274;
        favoriteLabelRect.origin.x = 306;
        
        self.deleteAndFavoriteButton.frame = favoriteButtonRect;
        self.favoriteCountLabel.frame = favoriteLabelRect;
    }
    
    CGRect avatarRect = self.userAvatarImageView.frame;
    CGRect nameRect = self.userNameLabel.frame;
    
    CGSize s = [commentLabel.text sizeWithFont:English_font_small 
                             constrainedToSize:CGSizeMake(SCREEN_WIDTH - nameRect.origin.x - 2*kTableCellSmallMargin, MAXFLOAT)
                                 lineBreakMode:UILineBreakModeWordWrap];
    
    CGRect
    commentRect = CGRectMake(nameRect.origin.x, 
                             avatarRect.origin.y + avatarRect.size.height + kTableCellSmallMargin, 
                             s.width,
                             s.height);
    
    commentLabel.frame = commentRect;
    
    CGRect cellRect = self.frame;
    cellRect.size.height = commentRect.size.height + 60;
    self.frame = cellRect;
    
    CGRect replyingImageViewRect = self.replyingImageView1.frame;
    replyingImageViewRect.size.height = self.frame.size.height;
    self.replyingImageView1.frame = replyingImageViewRect;
}

@end
