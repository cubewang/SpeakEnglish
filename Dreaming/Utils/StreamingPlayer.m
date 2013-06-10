//
//  StreamingPlayer.m
//  Dreaming
//
//  Created by Cube Wang on 12-8-23.
//  Copyright (c) 2012年 Dreaming Team. All rights reserved.
//

#import "StreamingPlayer.h"

#import <QuartzCore/CoreAnimation.h>
#import <MediaPlayer/MPMoviePlayerController.h>
#import <CFNetwork/CFNetwork.h>


@interface StreamingPlayer() {
    IBOutlet UIButton *button;
    IBOutlet UISlider *progressSlider;
    
    NSString *urlStreaming;
    NSString *currentImageName;
    
    MPMoviePlayerController *streamer;
    NSTimer *progressUpdateTimer;
}

@property (nonatomic, retain) IBOutlet UIButton *downloadButton;

@property (nonatomic, retain) UISlider *progressSlider;
@property (nonatomic, retain) NSString* urlStreaming;

@property (nonatomic, retain) VisualDownloader* audioDownloader;


- (void)spinButton;
- (void)updateProgress:(NSTimer *)aNotification;

- (IBAction)sliderMoved:(UISlider *)aSlider;

- (IBAction)downloadButtonPressed:(id)sender;

@end


@implementation StreamingPlayer


@synthesize downloadButton;
@synthesize progressSlider;
@synthesize urlStreaming;
@synthesize audioDownloader;

@synthesize stateChangedDelegate;



- (BOOL)isAudioPlaying
{
    if (streamer != nil) {
        return !(streamer.playbackState == MPMoviePlaybackStatePaused || streamer.playbackState == MPMoviePlaybackStateStopped);
    }
    
    return NO;
}

- (void)stopPlaying
{
    [self destroyStreamer];
}

- (void)pausePlaying
{
    [streamer pause];
}

- (void)startOrPauseAudioPlaying
{
    [self buttonPressed:nil];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        NSArray *nibs = [[NSBundle mainBundle] loadNibNamed:@"StreamingPlayer"
                                                      owner:self options:nil];
        
        [self addSubview:[nibs objectAtIndex:0]];
        
        [self setButtonImageNamed:@"play.png"];
        [progressSlider setThumbImage:[UIImage imageNamed:@"thumb_image.png"] forState:UIControlStateNormal];
        [progressSlider setMinimumTrackImage:[UIImage imageNamed:@"min_track_image.png"] forState:UIControlStateNormal];
        [progressSlider setMaximumTrackImage:[UIImage imageNamed:@"max_track_image.png"] forState:UIControlStateNormal];
    }
    return self;
}

- (IBAction)downloadButtonPressed:(id)sender
{
    if ([self.urlStreaming length] == 0)
        return;
    
    NSString* localFilePath = [VisualDownloader generateLocalAudioFilePath:self.urlStreaming];
    
    if ([localFilePath length] == 0) {
        return;
    }
    
    self.audioDownloader = [[[VisualDownloader alloc] init] autorelease];
    audioDownloader.title = NSLocalizedString(@"正在下载", @"");
    audioDownloader.fileURL = [NSURL URLWithString:[self.urlStreaming stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    audioDownloader.fileName = localFilePath;
    audioDownloader.delegate = self;
    [audioDownloader start];
}


- (void)setAudioUrl:(NSString *)url
{
    if ([url length] > 0) {
        self.urlStreaming = url;
        
        NSString* localFilePath = [VisualDownloader generateLocalAudioFilePath:url];
        
        //判断本地是否已存在文件
        if([[NSFileManager defaultManager] fileExistsAtPath:localFilePath])
        {
            [self.downloadButton setImage:[UIImage imageNamed:@"downloaded@2x.png"] forState:0];
            self.downloadButton.enabled = NO;
        }
    }
}

- (void)streamerPlay
{
    [streamer play];
    [self.stateChangedDelegate streamingPlayerStateDidChange:YES];
}

- (void)startPlaying
{
    [self createStreamer];
    [self setButtonImageNamed:@"streaming.png"];
    [self streamerPlay];
}

- (IBAction)buttonPressed:(id)sender
{
    //播放器当前没有播放任何音频
    if (streamer == nil || streamer.playbackState == MPMoviePlaybackStateStopped)
    {
        [self startPlaying];
    }
    else if (streamer.playbackState == MPMoviePlaybackStatePaused)
    {
        [self streamerPlay];
    }
    else
    {
        NSString* localFilePath = [VisualDownloader generateLocalAudioFilePath:self.urlStreaming];

        //开始播放另一个音频
        if ([self.urlStreaming isEqualToString:[streamer.contentURL absoluteString]] ||
            [[streamer.contentURL absoluteString] hasSuffix:localFilePath]) {
            
            [streamer pause];
        }
        else
        {
            [self startPlaying];
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
    if ([urlStreaming length] == 0) {
        return;
    }
    
    [self destroyStreamer];
    
    NSString* localFilePath = [VisualDownloader generateLocalAudioFilePath:urlStreaming];
    
    //判断本地是否已存在文件
    if([[NSFileManager defaultManager] fileExistsAtPath:localFilePath])
    {
        streamer = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL fileURLWithPath:localFilePath]];
    }
    else
    {
        streamer = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL URLWithString:urlStreaming]];
    }
    
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
// sliderMoved:
//
// Invoked when the user moves the slider
//
// Parameters:
//    aSlider - the slider (assumed to be the progress slider)
//
- (IBAction)sliderMoved:(UISlider *)aSlider
{
    //播放器当前没有播放任何音频
    if (streamer == nil)
    {
        [self startPlaying];
    }
    
    if (streamer.duration > 0)
    {
        double newSeekTime = (aSlider.value / 100.0) * streamer.duration;
        
        streamer.currentPlaybackTime = newSeekTime;
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
        [self setButtonImageNamed:@"pause.png"];
    }
    else if (streamer.playbackState == MPMoviePlaybackStatePaused ||
             streamer.playbackState == MPMoviePlaybackStateStopped)
    {
        [self setButtonImageNamed:@"play.png"];
        
        [self.stateChangedDelegate streamingPlayerStateDidChange:NO];
    }
}

- (void)playbackDidFinish:(NSNotification *)aNotification
{
    [self setButtonImageNamed:@"play.png"];
    [self.progressSlider setValue:0 animated:YES];
    [self.stateChangedDelegate streamingPlayerStateDidChange:NO];
    
    [self destroyStreamer];
}

- (void)loadStateChanged:(NSNotification *)aNotification
{
    if (streamer.loadState == MPMovieLoadStateStalled) {
        [self setButtonImageNamed:@"streaming.png"];
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
            [progressSlider setEnabled:YES];
            [progressSlider setValue:100 * progress / duration];
        }
        else
        {
            [progressSlider setEnabled:NO];
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
        imageName = @"play";
    }
    
    [currentImageName autorelease];
    currentImageName = [imageName retain];
    
    UIImage *image = [UIImage imageNamed:imageName];
    
    [button.layer removeAllAnimations];
    [button setImage:image forState:0];
    
    if ([imageName isEqual:@"streaming.png"])
    {
        [self spinButton];
    }
}

#pragma mark Visual Downloader

- (void) visualDownloaderDidCancel
{
}

- (void) visualDownloaderDidFail:(NSString *)reason
{
}

- (void)visualDownloaderDidFinish:(NSString *)fileName 
                         download:(VisualDownloader *)aDownloader
{
    [self.downloadButton setImage:[UIImage imageNamed:@"downloaded@2x.png"] forState:0];
    self.downloadButton.enabled = NO;
}

//
// dealloc
//
// Releases instance memory.
//
- (void)dealloc
{
    [self destroyStreamer];
    if (progressUpdateTimer)
    {
        [progressUpdateTimer invalidate];
        progressUpdateTimer = nil;
    }
    
    self.downloadButton = nil;
    self.progressSlider = nil;
    self.urlStreaming = nil;
    
    self.audioDownloader = nil;
    
    [super dealloc];
}

@end
