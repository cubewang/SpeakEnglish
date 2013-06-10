//
//  AudioCommentCell.m
//  EnglishFun
//
//  Created by Cube on 12-10-22.
//  Copyright 2012 Dreaming Team. All rights reserved.
//

#import "AudioCommentCell.h"
#import "ZStatus.h"
#import "GlobalDef.h"
#import "StringUtils.h"
#import "UIImageView+WebCache.h"
#import <QuartzCore/QuartzCore.h>
#import <MediaPlayer/MPMoviePlayerController.h>
#import "StreamingPlayer.h"

#define AVATAR_WIDTH             32
#define AVATAR_HEIGHT      AVATAR_WIDTH


@interface AudioCommentCell () {
    
    MPMoviePlayerController *streamer;
    NSTimer *progressUpdateTimer;
    
    NSString *currentImageName;
}

@property (nonatomic, retain) IBOutlet UILabel *userNameLabel;

@property (nonatomic, retain) IBOutlet UILabel *durationLabel;

@property (nonatomic, retain) IBOutlet UILabel *dateLabel;

@property (nonatomic, retain) IBOutlet UILabel *locationLabel;
@property (nonatomic, retain) IBOutlet UIImageView *locationImage;

@property (nonatomic, retain) IBOutlet UIButton *playButton;

@property (nonatomic, retain) IBOutlet UISlider *progressSlider;

@property (nonatomic, retain) IBOutlet UIButton *deleteAndFavoriteButton;

@property (nonatomic, retain) IBOutlet UIImageView *userAvatarImageView;

@property (nonatomic, retain) IBOutlet UIImageView *replyingImageView1;
@property (nonatomic, retain) IBOutlet UIImageView *replyingImageView2;
@property (nonatomic, retain) IBOutlet UILabel *replyingLabel;

@property (nonatomic, retain) IBOutlet UILabel *replyToUserLabel;

@property (nonatomic, retain) NSString* urlStreaming;


- (IBAction)playButtonPressed:(id)sender;

- (void)spinButton;
- (void)updateProgress:(NSTimer *)aNotification;

@end


@implementation AudioCommentCell

//work around to fix stopping audio playing when view webviewcontroller closed
static AudioCommentCell *_audioPlayingCell;

@synthesize userNameLabel;

@synthesize durationLabel;

@synthesize dateLabel;

@synthesize locationLabel;
@synthesize locationImage;

@synthesize playButton;

@synthesize progressSlider;

@synthesize deleteAndFavoriteButton;
@synthesize favoriteCountLabel;

@synthesize userAvatarImageView;

@synthesize smileImageView;

@synthesize replyingImageView1;
@synthesize replyingImageView2;
@synthesize replyingLabel;

@synthesize replyToUserLabel;


@synthesize urlStreaming;


+ (void)stopAudioPlaying
{
    [_audioPlayingCell destroyStreamer];
}

+ (int)heightForCell:(ZStatus *)status replyToStatus:(ZStatus *)replyToStatus
{
    if (replyToStatus != nil)
        return 80;
    
    return 60;
}

- (void)awakeFromNib
{
    // Initialization code.
    self.userNameLabel.font = English_font_small;
    
    self.durationLabel.font = English_font_smallest;
    
    self.durationLabel.textColor = ZBSTYLE_tableSubTextColor;
    
    [self.progressSlider setThumbImage:[UIImage imageNamed:@"thumb_image_mini.png"] forState:UIControlStateNormal];
    [self.progressSlider setMinimumTrackImage:[UIImage imageNamed:@"min_track_image_mini.png"] forState:UIControlStateNormal];
    [self.progressSlider setMaximumTrackImage:[UIImage imageNamed:@"max_track_image_mini.png"] forState:UIControlStateNormal];
    
    [self.playButton addTarget:self action:@selector(playButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
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

- (void)setStatusView:(ZStatus *)status
{
    self.userNameLabel.text = status.user.name;
    
    if ([status.user.name isEqualToString:@"cubewang"]) {
        self.userNameLabel.textColor = OFFICIAL_COLOR;
    }
    else {
        self.userNameLabel.textColor = ZBSTYLE_textColor;
    }
    
    [self.userAvatarImageView setImageWithURL:[NSURL URLWithString:status.user.profileImageUrl]
                             placeholderImage:[UIImage imageNamed:@"Avatar1.png"]];
    
    if (status.favoritesCount < 2) {
        self.smileImageView.image = nil;
    }
    else if (status.favoritesCount > 1 && status.favoritesCount < 4) {
        self.smileImageView.image = [UIImage imageNamed:@"smile_1.png"]; //2及个以上
    }
    else if (status.favoritesCount > 3 && status.favoritesCount < 8) {
        self.smileImageView.image = [UIImage imageNamed:@"smile_2.png"]; //4及个以上
    }
    else if (status.favoritesCount > 7 && status.favoritesCount < 16) {
        self.smileImageView.image = [UIImage imageNamed:@"smile_3.png"]; //8个及以上
    }
    else if (status.favoritesCount > 15 && status.favoritesCount < 32) {
        self.smileImageView.image = [UIImage imageNamed:@"smile_4.png"]; //16个及以上
    }
    else if (status.favoritesCount > 31) {
        self.smileImageView.image = [UIImage imageNamed:@"smile_5.png"]; //32个及以上
    }
    
    self.dateLabel.text = [AudioCommentCell formatTime:status.createdAt];
    
    NSString *distance = [AudioCommentCell getDistanceFromMe:status.coordinates];
    if (distance == nil) {
        if (status.user.location != nil) {
            self.locationLabel.text = status.user.location;
            self.locationImage.hidden = NO;
        }
    }
    else
    {
        self.locationLabel.text = distance;
        self.locationImage.hidden = NO;
    }
    
    self.urlStreaming = [ZStatus getAudioUrl:status];
    
    if ([[UserAccount getUserId] isEqualToString:[NSString stringWithFormat:@"%d",status.user.userID]])
    {
        if (status.favoritesCount >= 4)
        {
            [self.deleteAndFavoriteButton setImage:[UIImage imageNamed:@"share_score@2x.png"] forState:UIControlStateNormal];
        }
        else
        {
            [self.deleteAndFavoriteButton setImage:[UIImage imageNamed:@"delete_button@2x.png"] forState:UIControlStateNormal];
        }
    }
    else
    {
        if ([UserAccount getUserId] == nil)
        {
            [self.deleteAndFavoriteButton setImage:[UIImage imageNamed:@"thumbs_up_off"] forState:UIControlStateNormal];
        }
        else
        {
            NSString *imageName = status.isFavorited ? @"thumbs_up_on" : @"thumbs_up_off";
            [self.deleteAndFavoriteButton setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
        }
    }
    
    self.favoriteCountLabel.text = [NSString stringWithFormat:@"%d", status.favoritesCount];
}

- (void)setReplyToStatusView:(ZStatus *)replyToStatus
{
    if (replyToStatus == nil)
    {
        self.replyToUserLabel.text = nil;
        return;
    }
    
    self.replyToUserLabel.text = [NSString stringWithFormat:NSLocalizedString(@"回复：%@", @""),
                                  replyToStatus.user.name ? replyToStatus.user.name :
                                  replyToStatus.user.screenName ? replyToStatus.user.screenName : NSLocalizedString(@"（原评论已删除）", @"")];
}

- (void)setDataSource:(ZStatus *)status replyToStatus:(ZStatus *)replyToStatus
{
    [self setBackgroundImage:nil];
    
    [self setStatusView:status];
    
    [self setReplyToStatusView:replyToStatus];
}

+ (NSString *)formatTime:(NSDate *)createdAt
{
    NSString *createTime = [StringUtils intervalSinceTime:createdAt andTime:[NSDate date]];
    
    //去掉日期后面的时间
    if ([createTime length] > 0) {
        NSRange range = [createTime rangeOfString:@" "];
        if (range.location != NSNotFound && ![createTime hasSuffix:@"ago"] && ![createTime hasSuffix:@"now"]) {
            range.length = range.location;
            range.location = 0;
            
            return [createTime substringWithRange:range];
        }
        else {
            return createTime;
        }
    }
    else {
        return @"";
    }
}

+ (NSString *)getDistanceFromMe:(NSArray *)coordinates
{
    if ([coordinates count] != 2) {
        return nil;
    }
    
    if ([ZAppDelegate sharedAppDelegate].userLocation == nil)
        return nil;
    
    double targetLatitude = [[coordinates objectAtIndex:0] floatValue];
    double targetLongitude = [[coordinates objectAtIndex:1] floatValue];
    
    CLLocation *targetLocation = [[CLLocation alloc] initWithLatitude:targetLatitude
                                                            longitude:targetLongitude];
    
    CLLocationDistance distance = [[ZAppDelegate sharedAppDelegate].userLocation distanceFromLocation:targetLocation];
    
    //超过50千米不再显示距离，显示地址
    if (distance > 50000) {
        return nil;
    }
    
    NSString *distanceString;
    
    if (distance > 10000)
    {
        int distanceInt = distance/1000;
        distanceString = [NSString stringWithFormat:NSLocalizedString(@"%d千米", @""), distanceInt];
    }
    else {
        distanceString = [NSString stringWithFormat:NSLocalizedString(@"%d米", @""), (int)distance];
    }
    
    return distanceString;
}

- (void)setBackgroundImage:(UIImage *)theImage
{
}

- (void)setCommentDelegate:(NSInteger)tagId target:(id)target action:(SEL)selector
{
    self.deleteAndFavoriteButton.tag = tagId;
    
    if (target != nil && selector != nil)
        [self.deleteAndFavoriteButton addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
}

- (void)startPlaying
{
    [self createStreamer];
    [self setButtonImageNamed:@"streaming_mini.png"];
    [streamer play];
}

- (IBAction)playButtonPressed:(id)sender
{
    //播放器当前没有播放任何音频
    if (streamer == nil || streamer.playbackState == MPMoviePlaybackStateStopped)
    {
        [self startPlaying];
    }
    else if (streamer.playbackState == MPMoviePlaybackStatePaused)
    {
        [streamer play];
    }
    else
    {
        NSString *url = self.urlStreaming;
        
        //开始播放另一个音频
        if (![url isEqualToString:[streamer.contentURL absoluteString]]) {
            
            [self startPlaying];
        }
        else
        {
            [streamer pause];
        }
    }
}


//
// createStreamer
//
// Creates or recreates the streamer object.
//
- (void)createStreamer
{
    if ([self.urlStreaming length] == 0) {
        return;
    }
    
    [self destroyStreamer];
    
    NSString *url = self.urlStreaming;
    
    streamer = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL URLWithString:url]];
    
    progressUpdateTimer =
    [NSTimer
     scheduledTimerWithTimeInterval:0.1
     target:self
     selector:@selector(updateProgress:)
     userInfo:nil
     repeats:YES];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(playbackStateChanged:)
     name:MPMoviePlayerPlaybackStateDidChangeNotification
     object:streamer];
    
    [[NSNotificationCenter defaultCenter] 
     addObserver:self 
     selector:@selector(playbackDidFinish:)
     name:MPMoviePlayerPlaybackDidFinishNotification
     object:streamer];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(loadStateChanged:)
     name:MPMoviePlayerLoadStateDidChangeNotification
     object:streamer];
}

//
// destroyStreamer
//
// Removes the streamer, the UI update timer and the change notification
//
- (void)destroyStreamer
{
    if (streamer)
    {
        [[NSNotificationCenter defaultCenter]
         removeObserver:self
         name:MPMoviePlayerPlaybackStateDidChangeNotification
         object:streamer];
        
        [[NSNotificationCenter defaultCenter]
         removeObserver:self
         name:MPMoviePlayerPlaybackDidFinishNotification
         object:streamer];
        
        [[NSNotificationCenter defaultCenter]
         removeObserver:self
         name:MPMoviePlayerLoadStateDidChangeNotification
         object:streamer];
        
        [progressUpdateTimer invalidate];
        progressUpdateTimer = nil;
        
        [streamer stop];
        [streamer release];
        streamer = nil;
        
        if (_audioPlayingCell == self) {
            _audioPlayingCell = nil;
        }
        
        [self setButtonImageNamed:@"play_mini.png"];
        [self.progressSlider setValue:0 animated:YES];
    }
}

//
// spinButton
//
// Shows the spin button when the audio is loading. This is largely irrelevant
// now that the audio is loaded from a local file.
//
- (void)spinButton
{
    UIButton *button = playButton;
    
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    CGRect frame = [button frame];
    button.layer.anchorPoint = CGPointMake(0.5, 0.5);
    button.layer.position = CGPointMake(frame.origin.x + 0.5 * frame.size.width, frame.origin.y + 0.5 * frame.size.height);
    [CATransaction commit];
    
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanFalse forKey:kCATransactionDisableActions];
    [CATransaction setValue:[NSNumber numberWithFloat:2.0] forKey:kCATransactionAnimationDuration];
    
    CABasicAnimation *animation;
    animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    animation.fromValue = [NSNumber numberWithFloat:0.0];
    animation.toValue = [NSNumber numberWithFloat:2 * M_PI];
    animation.timingFunction = [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionLinear];
    animation.delegate = self;
    [button.layer addAnimation:animation forKey:@"rotationAnimation"];
    
    [CATransaction commit];
}

//
// animationDidStop:finished:
//
// Restarts the spin animation on the button when it ends. Again, this is
// largely irrelevant now that the audio is loaded from a local file.
//
// Parameters:
//    theAnimation - the animation that rotated the button.
//    finished - is the animation finised?
//
- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)finished
{
    if (finished)
    {
        [self spinButton];
    }
}

//
// playbackStateChanged:
//
// Invoked when the streamer
// reports that its playback status has changed.
//
- (void)playbackStateChanged:(NSNotification *)aNotification
{
    if (streamer.playbackState == MPMoviePlaybackStatePlaying)
    {
        [self setButtonImageNamed:@"pause_mini.png"];
        
        _audioPlayingCell = self;
    }
    else if (streamer.playbackState == MPMoviePlaybackStatePaused ||
             streamer.playbackState == MPMoviePlaybackStateStopped)
    {
        [self setButtonImageNamed:@"play_mini.png"];
    }
    else {
        _audioPlayingCell = self;
    }
}

- (void)playbackDidFinish:(NSNotification *)aNotification
{
    [self destroyStreamer];
    [self setButtonImageNamed:@"play_mini.png"];
    
    if (_audioPlayingCell == self) {
        _audioPlayingCell = nil;
    }
}

- (void)loadStateChanged:(NSNotification *)aNotification
{
    if (streamer.loadState == MPMovieLoadStateStalled) {
        [self setButtonImageNamed:@"streaming_mini.png"];
    }
}

//
// updateProgress:
//
// Invoked when the streamer
// reports that its playback progress has changed.
//
- (void)updateProgress:(NSTimer *)updatedTimer
{
    if (streamer.duration > 0.1)
    {
        double progress = streamer.currentPlaybackTime;
        double duration = streamer.duration;

        if (duration > 0)
        {
            UILabel *label = durationLabel;
            UISlider *slider = progressSlider;
            
            [label setText:[NSString stringWithFormat:@"%.f\"",duration]];
            
            [slider setValue:100 * progress / duration];
        }
    }
}

//
// setButtonImageNamed:
//
// Used to change the image on the playbutton. This method exists for
// the purpose of inter-thread invocation because
// the observeValueForKeyPath:ofObject:change:context: method is invoked
// from secondary threads and UI updates are only permitted on the main thread.
//
// Parameters:
//    imageNamed - the name of the image to set on the play button.
//
- (void)setButtonImageNamed:(NSString *)imageName
{
    if (!imageName)
    {
        imageName = @"play_mini";
    }
    
    UIButton *button = playButton;
    
    [currentImageName autorelease];
    currentImageName = [imageName retain];
    
    UIImage *image = [UIImage imageNamed:imageName];
    
    [button.layer removeAllAnimations];
    [button setImage:image forState:0];
    
    if ([imageName isEqual:@"streaming_mini.png"])
    {
        [self spinButton];
    }
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state.
}

- (void)dealloc {
    self.userNameLabel = nil;
    
    self.durationLabel = nil;
    
    self.dateLabel = nil;
    
    self.locationLabel = nil;
    self.locationImage = nil;
    
    self.playButton = nil;
    
    self.progressSlider = nil;
    
    self.deleteAndFavoriteButton = nil;
    self.favoriteCountLabel = nil;
    
    self.userAvatarImageView = nil;
    
    self.smileImageView = nil;
    
    self.replyingImageView1 = nil;
    self.replyingImageView2 = nil;
    self.replyingLabel = nil;
    
    self.replyToUserLabel = nil;
    
    [self destroyStreamer];
    if (progressUpdateTimer)
    {
        [progressUpdateTimer invalidate];
        progressUpdateTimer = nil;
    }
    
    [super dealloc];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    self.userNameLabel.text = nil;
    self.durationLabel.text = nil;
    self.dateLabel.text = nil;
    self.userAvatarImageView.image = nil;
    
    self.locationImage.hidden = YES;
    self.locationLabel.text = nil;
    
    self.replyToUserLabel.text = nil;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect progressRect = progressSlider.frame;
    progressRect.size.width = SCREEN_WIDTH;
    self.progressSlider.frame = progressRect;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom ] == UIUserInterfaceIdiomPad) {
        
        CGRect favoriteButtonRect = self.deleteAndFavoriteButton.frame;
        CGRect favoriteLabelRect = self.favoriteCountLabel.frame;
        
        favoriteButtonRect.origin.x = 274;
        favoriteLabelRect.origin.x = 306;
        
        self.deleteAndFavoriteButton.frame = favoriteButtonRect;
        self.favoriteCountLabel.frame = favoriteLabelRect;
    }
    
    CGRect replyingImageViewRect = self.replyingImageView1.frame;
    replyingImageViewRect.size.height = self.frame.size.height;
    self.replyingImageView1.frame = replyingImageViewRect;
}


@end
