//
//  RTTableViewCell.h
//  Dreaming
//
//  Abstract: 富文本单元格样式
//
//  Created by Cube on 11-5-5.
//  Copyright 2011 Dreaming Team. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZStatus.h"
#import "StreamingPlayer.h"


#define COVER_IMAGE_HEIGHT ([[UIDevice currentDevice] userInterfaceIdiom ] == UIUserInterfaceIdiomPhone ? 186 : 300)

#define COVER_IMAGE_WIDTH ([[UIDevice currentDevice] userInterfaceIdiom ] == UIUserInterfaceIdiomPhone ? 300 : 548)

#define PLAYER_HEIGHT           40
#define PLAYER_WIDTH            320

#define AVATAR_WIDTH             32
#define AVATAR_HEIGHT      AVATAR_WIDTH

#define SUBTITLE_HEIGHT         44

#define CELL_BUTTON_WIDTH       20

#define TAG_WIDTH               80
#define TAG_HEIGHT              TAG_WIDTH

#define CELL_CONTENT_WIDTH   ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone ? SCREEN_WIDTH : ARTICLE_AREA_WIDTH_IPAD)


@interface RTTableViewCell : UITableViewCell 
{
    UILabel *_favoriteCountLabel;
    UILabel *_commentCountLabel;
    
    UILabel *_descriptionLabel;
    UILabel *_providerLabel;
    UILabel *_publishDateLabel;
    
    UIImageView* _avatarImageView;
    UIImageView* _coverImageView;
    
    UIButton *_videoButton;
    UIButton *_audioButton;
		
    UIImageView *_favoriteImageView;
    UIImageView *_commentImageView;
    
    UIButton *_tagButton; //主标签，即系统标签
}

@property (nonatomic, readonly) UILabel *favoriteCountLabel;
@property (nonatomic, readonly) UILabel *commentCountLabel;

@property (nonatomic, readonly) UILabel *descriptionLabel;
@property (nonatomic, readonly) UILabel *providerLabel;
@property (nonatomic, readonly) UILabel *publishDateLabel;

@property (nonatomic, readonly) UIImageView *avatarImageView;
@property (nonatomic, readonly) UIImageView *coverImageView;

@property (nonatomic, readonly) UIButton *videoButton;
@property (nonatomic, readonly) UIButton *audioButton;

@property (nonatomic, readonly) UIImageView *commentImageView;

@property (nonatomic, readonly) UIButton *tagButton;


- (void)setDataSource:(id)data;
- (void)setCoverImageUrl:(NSString *)url tagId:(NSInteger)tagId target:(id)target action:(SEL)selector;
- (void)setAvatarImageUrl:(NSString*)url tagId:(NSInteger)tagId target:(id)target action:(SEL)selector;
- (void)setComment:(NSInteger)tagId target:(id)target action:(SEL)selector;
- (void)setVideoUrl:(NSString *)url tagId:(NSInteger)tagId target:(id)target action:(SEL)selector;
- (void)setAudioUrl:(NSString *)url tagId:(NSInteger)tagId target:(id)target action:(SEL)selector;

- (void)setArticleTags:(NSArray*)tags target:(id)target action:(SEL)selector;


+ (CGFloat)rowHeightForObject:(id)object;


+ (UIImage*)getDefaultCoverImage;

@end
