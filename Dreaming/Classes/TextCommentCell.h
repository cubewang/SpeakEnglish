//
//  TextCommentCell.h
//  EnglishFun
//
//  Created by curer on 12-1-9.
//  Copyright 2012 Dreaming Team. All rights reserved.
//

#import <UIKit/UIKit.h>

#define AVATAR_WIDTH             32
#define AVATAR_HEIGHT      AVATAR_WIDTH

@class ZStatus;

@interface TextCommentCell : UITableViewCell {
    IBOutlet UILabel *userNameLabel;
    IBOutlet UILabel *commentLabel;
    IBOutlet UILabel *dateLabel;
    
    IBOutlet UIImageView *userAvatarImageView;
    
    IBOutlet UIButton *deleteAndFavoriteButton;
    IBOutlet UILabel *favoriteCountLabel;
}

@property (nonatomic, retain) UILabel *userNameLabel;
@property (nonatomic, retain) UILabel *commentLabel;
@property (nonatomic, retain) UILabel *dateLabel;

@property (nonatomic, retain) UIImageView *userAvatarImageView;

@property (nonatomic, retain) IBOutlet UIImageView *replyingImageView1;
@property (nonatomic, retain) IBOutlet UIImageView *replyingImageView2;
@property (nonatomic, retain) IBOutlet UILabel *replyingLabel;

@property (nonatomic, retain) UIButton *deleteAndFavoriteButton;
@property (nonatomic, retain) UILabel *favoriteCountLabel;


+ (int)heightForCell:(ZStatus *)comment;
- (void)setDataSource:(ZStatus *)comment;
- (void)setCommentDelegate:(NSInteger)tagId target:(id)target action:(SEL)selector;

- (void)changeReplyingState:(NSString *)replyingStateText hidden:(BOOL)hidden;

@end
