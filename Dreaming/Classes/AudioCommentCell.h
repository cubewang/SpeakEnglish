//
//  AudioCommentCell.h
//  EnglishFun
//
//  Created by Cube on 12-10-22.
//  Copyright 2012 Dreaming Team. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZStatus;

@interface AudioCommentCell : UITableViewCell {
}

@property (nonatomic, retain) IBOutlet UILabel *favoriteCountLabel;
@property (nonatomic, retain) IBOutlet UIImageView *smileImageView;

+ (void)stopAudioPlaying;
+ (int)heightForCell:(ZStatus *)status replyToStatus:(ZStatus *)replyToStatus;
- (void)setDataSource:(ZStatus *)status replyToStatus:(ZStatus *)replyToStatus;
- (void)setCommentDelegate:(NSInteger)tagId target:(id)target action:(SEL)selector;

- (void)changeReplyingState:(NSString *)replyingStateText hidden:(BOOL)hidden;


@end
