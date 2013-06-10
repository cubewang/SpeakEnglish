//
//  RTTableViewCell.m
//  Dreaming
//
//  Created by Cube on 11-5-5.
//  Copyright 2011 Dreaming Team. All rights reserved.
//

#import "RTTableViewCell.h"
#import "UIImageView+WebCache.h"
#import <QuartzCore/QuartzCore.h>

#import "StringUtils.h"
#import "GlobalDef.h"

@implementation RTTableViewCell


static UIImage* defaultAvatarImage;
static UIImage* defaultCoverImage;
static UIImage* defaultBackgroundImage;
static UIImage* defaultTagBgImage;

@synthesize favoriteCountLabel = _favoriteCountLabel;
@synthesize commentCountLabel = _commentCountLabel;

@synthesize descriptionLabel = _descriptionLabel;
@synthesize providerLabel = _providerLabel;
@synthesize publishDateLabel = _publishDateLabel;

@synthesize avatarImageView = _avatarImageView;
@synthesize coverImageView = _coverImageView;

@synthesize videoButton = _videoButton;
@synthesize audioButton = _audioButton;

@synthesize tagButton = _tagButton;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString*)identifier {
	if (self = [super initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:identifier]) {
	}
	
	return self;
}


- (void)setDataSource:(id)data
{
    if (data == nil) 
        return;
    
    ZStatus *status = data;
    [self setBackgroundImage:nil];
    [self setDescription:status.text];
    [self setProvider:status.user.name];
    
    [self setFavoriteCount:[NSString stringWithFormat:@"(%d)", status.favoritesCount]];
    [self setCommentCount:[NSString stringWithFormat:@"(%d)", status.commentsCount]];
    
    [self setPublishDate:[StringUtils intervalSinceTime:status.createdAt andTime:[NSDate date]]];
}


+ (UIImage*)getDefaultCoverImage {
    
    if (defaultCoverImage == nil) {
        defaultCoverImage = [[UIImage imageNamed:@"DefaultCover.png"] retain];
    }
    
    return defaultCoverImage;
}

+ (UIImage*)getDefaultAvatarImage {
    
    if (defaultAvatarImage == nil) {
        defaultAvatarImage = [[UIImage imageNamed:@"Avatar1.png"] retain];
    }
    
    return defaultAvatarImage;
}

+ (UIImage*)getDefaultBackgroundImage {
    
    if (defaultBackgroundImage == nil) {
        NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"cell_background@2x" ofType:@"png"];
        
        if ([UIImage instancesRespondToSelector:@selector(resizableImageWithCapInsets:resizingMode:)]) {
            defaultBackgroundImage = [[UIImage imageWithContentsOfFile:imagePath] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 100, 100) resizingMode:UIImageResizingModeTile];
            
            [defaultBackgroundImage retain];
        }
        else {
            defaultBackgroundImage = [[UIImage imageWithContentsOfFile:imagePath]
                                      stretchableImageWithLeftCapWidth:0.0 topCapHeight:50.0];
            
            [defaultBackgroundImage retain];
        }
    }
    
    return defaultBackgroundImage;
}


+ (UIImage*)getDefaultTagBgImage {
    
    if (defaultTagBgImage == nil) {
        defaultTagBgImage = [[UIImage imageNamed:@"tagBg.png"] retain];
    }
    
    return defaultTagBgImage;
}

- (void)setCoverImageUrl:(NSString *)url tagId:(NSInteger)tagId target:(id)target action:(SEL)selector
{
    if (!_coverImageView) {
        _coverImageView = [[UIImageView alloc] init];
        
        [self.contentView addSubview:_coverImageView];
        
        [_coverImageView release];
    }
    
    [_coverImageView setImageWithURL:[NSURL URLWithString:url] 
                    placeholderImage:[RTTableViewCell getDefaultCoverImage]];
}

- (void)setAudioUrl:(NSString *)url tagId:(NSInteger)tagId target:(id)target action:(SEL)selector
{
    if ([url length] == 0)
        return;
    
    if (!_audioButton) {
        _audioButton = [[UIButton alloc] init];
        [_audioButton setImage:[UIImage imageNamed:@"audio_button@2x.png"] forState:UIControlStateNormal];
        
        if (target != nil && selector != nil)
            [_audioButton addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
        
        [self.contentView addSubview:_audioButton];
    }
    
    _audioButton.tag = tagId;
}

- (void)setVideoUrl:(NSString *)url tagId:(NSInteger)tagId target:(id)target action:(SEL)selector
{
    if ([url length] == 0)
        return;
    
    if (!_videoButton) {
        _videoButton = [[UIButton alloc] init];
        
        if ([[UIDevice currentDevice] userInterfaceIdiom ] == UIUserInterfaceIdiomPhone) {
            [self.videoButton setImage:[UIImage imageNamed:@"video_button@2x.png"] forState:UIControlStateNormal];
        }
        else
        {
            [self.videoButton setImage:[UIImage imageNamed:@"video_button_iPad.png"] forState:UIControlStateNormal];
        }
        
        if (target != nil && selector != nil)
            [_videoButton addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
        
        [self.contentView addSubview:_videoButton];
    }
    
    _videoButton.tag = tagId;
}

- (void)setDescription:(NSString *)newDescription
{
    if (!_descriptionLabel) {
		_descriptionLabel = [[UILabel alloc] init];
        _descriptionLabel.font = English_font_des;
		_descriptionLabel.textColor = ZBSTYLE_tableSubTextColor;
		_descriptionLabel.highlightedTextColor = ZBSTYLE_highlightedTextColor;
		_descriptionLabel.textAlignment = UITextAlignmentLeft;
		_descriptionLabel.contentMode = UIViewContentModeTop;
		_descriptionLabel.lineBreakMode = UILineBreakModeTailTruncation;
		_descriptionLabel.numberOfLines = 0;
		
		[self.contentView addSubview:_descriptionLabel];
	}
    
    _descriptionLabel.text = newDescription ? newDescription : @"";
}


- (void)setFavoriteCount:(NSString *)newCount
{
    if (!_favoriteImageView) {
        _favoriteImageView = [[UIImageView alloc] init];
        
        [_favoriteImageView setImage:[UIImage imageNamed:@"favorite_on_timeline"]];
        
        [self.contentView addSubview:_favoriteImageView];
    }
    
    if (!_favoriteCountLabel) {
        _favoriteCountLabel = [[UILabel alloc] init];
        _favoriteCountLabel.font = ZBSTYLE_font;
        _favoriteCountLabel.textColor = ZBSTYLE_secondaryColor;
        _favoriteCountLabel.highlightedTextColor = ZBSTYLE_highlightedTextColor;
        _favoriteCountLabel.textAlignment = UITextAlignmentLeft;
        _favoriteCountLabel.contentMode = UIViewContentModeTop;
        _favoriteCountLabel.lineBreakMode = UILineBreakModeTailTruncation;
        _favoriteCountLabel.numberOfLines = 1;
        
        [self.contentView addSubview:_favoriteCountLabel];
    }
    
    NSString *favoriteCount = @"";
    
    if ([newCount length] > 0) {
        favoriteCount = newCount;
    }
    
    _favoriteCountLabel.text = favoriteCount;
}

- (void)setCommentCount:(NSString *)newCount
{
    if (!_commentImageView) {
        _commentImageView = [[UIImageView alloc] init];
        
        [_commentImageView setImage:[UIImage imageNamed:@"comment_timeline"]];
        
        [self.contentView addSubview:_commentImageView];
    }
    
    if (!_commentCountLabel) {
        _commentCountLabel = [[UILabel alloc] init];
        _commentCountLabel.font = ZBSTYLE_font;
        _commentCountLabel.textColor = ZBSTYLE_secondaryColor;
        _commentCountLabel.highlightedTextColor = ZBSTYLE_highlightedTextColor;
        _commentCountLabel.textAlignment = UITextAlignmentLeft;
        _commentCountLabel.contentMode = UIViewContentModeTop;
        _commentCountLabel.lineBreakMode = UILineBreakModeTailTruncation;
        _commentCountLabel.numberOfLines = 1;
        
        [self.contentView addSubview:_commentCountLabel];
    }
    
    NSString *commentCount = @"";
    
    if ([newCount length] > 0) {
        commentCount = newCount;
    }
    
    _commentCountLabel.text = commentCount;
}

- (void)setPublishDate:(NSString *)newDate
{
    if (!_publishDateLabel) {
        _publishDateLabel = [[UILabel alloc] init];
        _publishDateLabel.font = English_font_smallest;
        _publishDateLabel.textColor = ZBSTYLE_secondaryColor;
        _publishDateLabel.highlightedTextColor = ZBSTYLE_highlightedTextColor;
        _publishDateLabel.textAlignment = UITextAlignmentLeft;
        _publishDateLabel.contentMode = UIViewContentModeTop;
        _publishDateLabel.lineBreakMode = UILineBreakModeTailTruncation;
        _publishDateLabel.numberOfLines = 1;
        
        [self.contentView addSubview:_publishDateLabel];
    }
    
    NSString *createTime = @"";
    
    //去掉日期后面的时间
    if ([newDate length] > 0) {
        NSRange range = [newDate rangeOfString:@" "];
        if (range.location != NSNotFound && ![newDate hasSuffix:@"ago"] && ![createTime hasSuffix:@"now"]) {
            range.length = range.location;
            range.location = 0;
            
            createTime = [newDate substringWithRange:range];
            _publishDateLabel.text = createTime;
        }
        else {
            _publishDateLabel.text = newDate;
        }
    }
    else {
        _publishDateLabel.text = @"";
    }
}

- (void)setProvider:(NSString *)newProvider
{
    if (!_providerLabel) {
        _providerLabel = [[UILabel alloc] init];
        _providerLabel.font = ZBSTYLE_font;
        _providerLabel.textColor = [UIColor blackColor];
        _providerLabel.highlightedTextColor = ZBSTYLE_highlightedTextColor;
        _providerLabel.textAlignment = UITextAlignmentLeft;
        _providerLabel.contentMode = UIViewContentModeTop;
        _providerLabel.lineBreakMode = UILineBreakModeTailTruncation;
        _providerLabel.numberOfLines = 1;
        
        [self.contentView addSubview:_providerLabel];
    }
    
    NSString *provider = [newProvider length] > 0 ? newProvider : @"";
    
    _providerLabel.text = provider;
}


- (void)setComment:(NSInteger)tagId target:(id)target action:(SEL)selector
{
}


- (void)setAvatarImageUrl:(NSString*)url tagId:(NSInteger)tagId target:(id)target action:(SEL)selector
{    
    if (!_avatarImageView) {
        _avatarImageView = [[UIImageView alloc] init];
        _avatarImageView.contentMode = UIViewContentModeScaleAspectFit;
        
        [self.contentView addSubview:_avatarImageView];
        
        CALayer *layer = [_avatarImageView layer];
        [layer setMasksToBounds:YES];
        [layer setCornerRadius:2];
    }

    [_avatarImageView setImageWithURL:[NSURL URLWithString:url]
                     placeholderImage:[RTTableViewCell getDefaultAvatarImage]];
}

- (void)setArticleTags:(NSArray*)tags target:(id)target action:(SEL)selector
{
    if ([tags count] == 0)
    {
        RELEASE_SAFELY(_tagButton);
        return;
    }
    
    if (!_tagButton) {
        _tagButton = [[UIButton alloc] init];
        
        _tagButton.titleLabel.font = ZBSTYLE_font_smaller;
        [_tagButton setTitleColor:ZBSTYLE_secondaryColor forState:UIControlStateNormal];
        //[_tagButton setBackgroundImage:[UIImage imageNamed:@"tag_bg"] forState:UIControlStateNormal];
        
        if (target != nil && selector != nil)
            [_tagButton addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
        
        [self.contentView addSubview:_tagButton];
    }
    
    [_tagButton setTitle:[tags objectAtIndex:0] forState:UIControlStateNormal];
}


- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    [super setBackgroundColor:backgroundColor];
    
    _favoriteCountLabel.backgroundColor = [UIColor clearColor];
    _commentCountLabel.backgroundColor = [UIColor clearColor];
    _publishDateLabel.backgroundColor = [UIColor clearColor];
    _providerLabel.backgroundColor = [UIColor clearColor];
    _descriptionLabel.backgroundColor = [UIColor clearColor];
}


- (void)setBackgroundImage:(UIImage *)theImage
{
    UIImage *backgroundImage;
    
    if (theImage == nil) {

        backgroundImage = [RTTableViewCell getDefaultBackgroundImage];
    }
    else {
        backgroundImage = theImage;
    }
    
    if (self.backgroundView == nil) {
        self.backgroundView = [[[UIImageView alloc] initWithImage:backgroundImage] autorelease];
        self.backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.backgroundView.frame = self.bounds;
    }
}


+ (CGFloat)rowHeightForObject:(id)object {

    if (object == nil)
        return 0.0;
    
    CGFloat top = kTableCellMargin + AVATAR_HEIGHT;
    
    ZStatus *status = object;
    
    CGFloat coverImageHeight = COVER_IMAGE_HEIGHT + kTableCellMargin;
    
    top += coverImageHeight;
    
    UIFont* descriptionFont = English_font_des;

    //子标题
    CGSize subtitleLabelSize = [@"Hello World" sizeWithFont:descriptionFont
                                          constrainedToSize:CGSizeMake(CELL_CONTENT_WIDTH, CGFLOAT_MAX)
                                              lineBreakMode:UILineBreakModeTailTruncation];
    
    CGSize descriptionLabelSize = {0};
    if ([status.text length] > 0)
    {
        descriptionLabelSize = [status.text sizeWithFont:descriptionFont
                                               constrainedToSize:CGSizeMake(CELL_CONTENT_WIDTH - 2*kTableCellMargin, CGFLOAT_MAX)
                                                   lineBreakMode:UILineBreakModeWordWrap];
        
        if (descriptionLabelSize.height > 15*subtitleLabelSize.height) //文章简介不能超过15行
            descriptionLabelSize.height = 15*subtitleLabelSize.height;
    }
    
    top += descriptionLabelSize.height + kTableCellMargin + 2*kTableCellSpacing;
    top += CELL_BUTTON_WIDTH + kTableCellMargin;
    
    return top;
}

#pragma mark -
#pragma mark UIView

- (void)prepareForReuse {
    [super prepareForReuse];
    
    _providerLabel.text = nil;
    _publishDateLabel.text = nil;
    
    [_coverImageView cancelCurrentImageLoad];
    [_avatarImageView cancelCurrentImageLoad];
    
    _coverImageView.image = nil;
    _avatarImageView.image = nil;
    
    [_tagButton removeFromSuperview];
    [_audioButton removeFromSuperview];
    [_videoButton removeFromSuperview];
    
    RELEASE_SAFELY(_tagButton);
    RELEASE_SAFELY(_audioButton);
    RELEASE_SAFELY(_videoButton);
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    UIFont* descriptionFont = English_font_des;
    
    //取得subtitle的高度
    CGSize subtitleLabelSize = [@"2011-09-13 " sizeWithFont:descriptionFont
                                          constrainedToSize:CGSizeMake(CELL_CONTENT_WIDTH, CGFLOAT_MAX)
                                              lineBreakMode:UILineBreakModeTailTruncation];
    
    //当前View的x坐标
    CGFloat left = kTableCellMargin;
    //当前View的y坐标
    CGFloat top = kTableCellMargin;
    
    //设置_avatarImageView的坐标
    _avatarImageView.frame = CGRectMake(left, top, AVATAR_WIDTH, AVATAR_WIDTH);
    
    left += (kTableCellMargin + AVATAR_WIDTH);
    
    //设置_providerLabel的坐标
    _providerLabel.frame = CGRectMake(left, 
                                      kTableCellSpacing, 
                                      CELL_CONTENT_WIDTH/2, 
                                      subtitleLabelSize.height);
    
    //设置_publishDateLabel的坐标 
    _publishDateLabel.frame = CGRectMake(left, kTableCellSpacing + subtitleLabelSize.height + 4, 65, 12);
    
    //y坐标下移
    top += AVATAR_HEIGHT + kTableCellMargin;
    
    left = (CELL_CONTENT_WIDTH - COVER_IMAGE_WIDTH) / 2;

    _coverImageView.contentMode = UIViewContentModeScaleAspectFill;
    [_coverImageView setClipsToBounds:YES];
    _coverImageView.frame = CGRectMake(kTableCellMargin, 
                                   top, 
                                   COVER_IMAGE_WIDTH, 
                                   COVER_IMAGE_HEIGHT);
    
    //设置_videoButton的坐标
    _videoButton.frame = CGRectMake(kTableCellMargin, 
                                     top, 
                                     COVER_IMAGE_WIDTH, 
                                     COVER_IMAGE_HEIGHT);

    top += COVER_IMAGE_HEIGHT + kTableCellMargin;
    
    if (_audioButton != nil) {
        
        _audioButton.frame = CGRectMake(COVER_IMAGE_WIDTH - 68 + 10,
                                   top - 58 - kTableCellMargin,
                                   68, 
                                   58);
        
    }
    
    //取得_descriptionLabe的宽度和高度
    CGSize descriptionLabelSize = [_descriptionLabel.text sizeWithFont:descriptionFont
                                          constrainedToSize:CGSizeMake(CELL_CONTENT_WIDTH - 2*kTableCellMargin, CGFLOAT_MAX)
                                              lineBreakMode:UILineBreakModeWordWrap];
    if (descriptionLabelSize.height > 15*subtitleLabelSize.height) {
        descriptionLabelSize.height = 15*subtitleLabelSize.height;
    }
    
    //设置_descriptionLabe的坐标
    _descriptionLabel.frame = CGRectMake(kTableCellMargin, top, CELL_CONTENT_WIDTH - 2*kTableCellMargin, descriptionLabelSize.height);
    
    if (descriptionLabelSize.height > 0) {
        top += descriptionLabelSize.height;
    }
    
    //设置_favoriteCountLabel坐标
    _favoriteCountLabel.frame = CGRectMake(CELL_CONTENT_WIDTH - 98,
                                       top + 2*kTableCellSpacing,
                                       40,
                                       subtitleLabelSize.height);
    
    //设置_favoriteImageView的坐标
    _favoriteImageView.frame = CGRectMake(CELL_CONTENT_WIDTH - 100 - CELL_BUTTON_WIDTH,
                                          top + 2*kTableCellSpacing,
                                          CELL_BUTTON_WIDTH,
                                          CELL_BUTTON_WIDTH);
    
    //设置_commentCountLabel的坐标
    _commentCountLabel.frame = CGRectMake(CELL_CONTENT_WIDTH - 38,
                                          top + 2*kTableCellSpacing,
                                          40,
                                          subtitleLabelSize.height);
    
    //设置_commentImageView的坐标
    _commentImageView.frame = CGRectMake(CELL_CONTENT_WIDTH - 40 - CELL_BUTTON_WIDTH,
                                         top + 2*kTableCellSpacing,
                                         CELL_BUTTON_WIDTH,
                                         CELL_BUTTON_WIDTH);
    
    //取得tagLabelSize的宽度和高度
    CGSize tagButtonSize = [[_tagButton titleForState:UIControlStateNormal] 
                                  sizeWithFont:ZBSTYLE_font
                                  constrainedToSize:CGSizeMake(CELL_CONTENT_WIDTH, CGFLOAT_MAX)
                                  lineBreakMode:UILineBreakModeWordWrap];
    
    left = 2*kTableCellMargin;
    
    //设置_tagButton的坐标
    _tagButton.frame = CGRectMake(left,
                                  top + 6,
                                  tagButtonSize.width > 200 ? 200 : tagButtonSize.width,
                                  tagButtonSize.height + 2*kTableCellMargin);
}


- (void)dealloc {
    
    RELEASE_SAFELY(_favoriteCountLabel);
    RELEASE_SAFELY(_commentCountLabel);
    RELEASE_SAFELY(_favoriteImageView);
    RELEASE_SAFELY(_commentImageView);
    
    RELEASE_SAFELY(_descriptionLabel);
    RELEASE_SAFELY(_providerLabel);
    RELEASE_SAFELY(_publishDateLabel);
    
    RELEASE_SAFELY(_avatarImageView);
    RELEASE_SAFELY(_coverImageView);
    
    RELEASE_SAFELY(_videoButton);
    RELEASE_SAFELY(_audioButton);
    
    RELEASE_SAFELY(_tagButton);
    
    [super dealloc];
}

@end
