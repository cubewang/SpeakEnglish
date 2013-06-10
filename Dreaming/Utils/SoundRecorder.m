//
//  SoundRecorder.m
//  DreamingNews
//
//  Created by cg on 12-10-19.
//  Copyright (c) 2012年 Dreaming Team. All rights reserved.
//

#import "SoundRecorder.h"
#import "ZAppDelegate.h"
#import "lame.h"
#import <AudioToolbox/AudioServices.h>


static  SoundRecorder *shareInstance = nil;

@interface SoundRecorder ()  {
    
    BOOL isRecordValid;
    
    UIButton *playButton;
    UIButton *deleteButton;
    UIButton *postButton;
    
    UIImageView *imageViewAnimation;
    
    UIImageView *playAudioAnimation;
}

@property (nonatomic, retain) MBProgressHUD *HUD;
@property (nonatomic, retain) AVAudioRecorder *recorder;
@property (nonatomic, retain) NSURL *recordedFile;
@property (nonatomic, retain) NSString *convertPath;
@property (nonatomic, retain) AVAudioPlayer *player;
@property (nonatomic, retain) NSTimer *levelTimer;
@property (nonatomic, retain) NSTimer *playAudioTimer;

- (void)startRecord;
- (void)deleteRecord;
- (NSDictionary *)recordingSettings;
- (void)playSound;
- (void)postButtonClick;
- (void)levelTimerCallback:(NSTimer *)timer;
- (void)isAudioPlaying;

@end

@implementation SoundRecorder

@synthesize HUD;
@synthesize recorder;
@synthesize recordedFile;
@synthesize convertPath;
@synthesize player;
@synthesize delegate;
@synthesize levelTimer;
@synthesize playAudioTimer;

+ (SoundRecorder *)shareInstance
{
    @synchronized(self) {
        if (shareInstance == nil) {
            shareInstance = [[SoundRecorder alloc] init];
        }
    }
    
    return shareInstance;
}

+ (NSString *) stringWithUUID
{
    CFUUIDRef uuidObj = CFUUIDCreate(kCFAllocatorDefault);
    CFStringRef strRef = CFUUIDCreateString(kCFAllocatorDefault, uuidObj);
    NSString* uuidString = [NSString stringWithString:(__bridge NSString*)strRef];
    CFRelease(strRef);
    CFRelease(uuidObj);
    return uuidString;
}

- (NSDictionary *)recordingSettings
{    
    return [NSDictionary   dictionaryWithObjectsAndKeys:  
            [NSNumber numberWithInt:AVAudioQualityHigh],  
            AVEncoderAudioQualityKey,  
            [NSNumber numberWithInt:160],   
            AVEncoderBitRateKey,  
            [NSNumber numberWithInt:2],  
            AVNumberOfChannelsKey,  
            [NSNumber numberWithFloat:44100.0],   
            AVSampleRateKey, 
            [NSNumber numberWithInt: kAudioFormatLinearPCM],
            AVFormatIDKey,
            nil];  
}

- (void)dealloc {
    
    self.HUD = nil;
    self.recorder = nil;
    self.recordedFile = nil;
    self.convertPath = nil;
    self.player = nil;
    self.delegate = nil;
    self.playAudioTimer = nil;
    
    [imageViewAnimation release];
    self.levelTimer = nil;
    
    [super dealloc];
}

#pragma mark - SetSoundRecordView
- (void)startSoundRecord:(UIView *)view {
    
    [self startRecord];
    
    if (HUD) {
        [HUD removeFromSuperview];
        [HUD release];
        HUD = nil;
    }
    
    if (view == nil) {
        view = [[ZAppDelegate sharedAppDelegate] window];
    }
    
    if (HUD == nil) {
        HUD = [[MBProgressHUD alloc] initWithView:view];
        
        CGRect frame=CGRectMake(0, 0, 82,80);  
        imageViewAnimation = [[UIImageView alloc] initWithFrame:frame]; 
        [imageViewAnimation setImage:[UIImage imageNamed:@"sound_record1@2x"]];
        imageViewAnimation.contentMode = UIViewContentModeScaleAspectFit;      
        
        HUD.customView = imageViewAnimation;

        // Set custom view mode
        HUD.mode = MBProgressHUDModeCustomView;
    }
    
    if ([view isKindOfClass:[UIWindow class]]) {
        [view addSubview:HUD];    
    }
    else {
        [view.window addSubview:HUD];
    }
    
    [HUD show:YES];
}

- (void)soundRecordFailed:(UIView *)view {
  
    [self.recorder stop];
    
    if (HUD) {
        [HUD removeFromSuperview];
        [HUD release];
        HUD = nil;
    }
    
    if (view == nil) {
        view = [[ZAppDelegate sharedAppDelegate] window];
    }
    
    if (HUD == nil) {
        HUD = [[MBProgressHUD alloc] initWithView:view];
        
        UIImageView *soundRecordFailed = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 80, 80)]autorelease];//initWithImage:[UIImage imageNamed:@"sound_record_Failed@2x.png"]] autorelease];
        [soundRecordFailed setImage:[UIImage imageNamed:@"sound_record_Failed.png"]];
        
        HUD.customView = soundRecordFailed;
        
        UILabel *noticeLabel = [[[UILabel alloc] initWithFrame:CGRectMake(10, 45, 70, 40)] autorelease];
        noticeLabel.numberOfLines = 2;
        noticeLabel.backgroundColor = [UIColor clearColor];
        noticeLabel.font = [UIFont systemFontOfSize:11];
        noticeLabel.textColor = [UIColor whiteColor];
        noticeLabel.text = NSLocalizedString(@"太快了,   请长按发评论", @""); 
        
        [HUD.customView addSubview:noticeLabel];
        // Set custom view mode
        HUD.mode = MBProgressHUDModeCustomView;
    }
    
    if ([view isKindOfClass:[UIWindow class]]) {
        [view addSubview:HUD];    
    }
    else {
        [view.window addSubview:HUD];
    }
    
    [HUD show:YES];
    
    [HUD hide:YES afterDelay:1.5];

}

- (void)stopSoundRecordView:(UIView *)view {
    
    [self.levelTimer invalidate];
    
    NSString *str = [NSString stringWithFormat:@"%f",recorder.currentTime];
    int times = [str intValue];
    
    [self.recorder stop];
    [[AVAudioSession sharedInstance] setActive: NO error: nil];
    
    if (times >= 2) {
        
        NSError *playerError;
        
        self.player = [[[AVAudioPlayer alloc] initWithContentsOfURL:self.recordedFile error:&playerError] autorelease];
        
        if (player == nil) 
        {
            NSLog(@"Error creating player: %@", [playerError description]);
        }
        
        if (HUD) {
            [HUD removeFromSuperview];
            [HUD release];
            HUD = nil;
        }
        
        if (view == nil) {
            view = [[ZAppDelegate sharedAppDelegate] window];
        }
        
        if (HUD == nil) {
            
            HUD = [[MBProgressHUD alloc] initWithView:view];
            HUD.customView =[[UIView alloc] initWithFrame:CGRectMake(0, 0, 160, 120)];
            HUD.opacity = 0.4;
            
            playButton = [[[UIButton alloc] initWithFrame:CGRectMake(65, 10, 40, 40)] autorelease];
            [playButton addTarget:self action:@selector(playSound) forControlEvents:UIControlEventTouchUpInside];
            [playButton setImage:[UIImage imageNamed:@"play_soundRecord@2x"] forState:UIControlStateNormal];
            playButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
            [HUD.customView addSubview:playButton];
            
            playAudioAnimation = [[[UIImageView alloc] initWithFrame:CGRectMake(53, 60, 59, 5)] autorelease];
            playAudioAnimation.backgroundColor = [UIColor clearColor];
            playAudioAnimation.animationImages=[NSArray arrayWithObjects:
                                     [UIImage imageNamed:@"audio_play1@2x"],
                                     [UIImage imageNamed:@"audio_play2@2x"],
                                     [UIImage imageNamed:@"audio_play3@2x"],
                                     [UIImage imageNamed:@"audio_play4@2x"],nil ];
            
            playAudioAnimation.animationDuration = 3;
            playAudioAnimation.animationRepeatCount = 0;
            
            [HUD.customView addSubview:playAudioAnimation];
            
            deleteButton = [[UIButton alloc] initWithFrame:CGRectMake(-10, 80, 84, 40)];
            [deleteButton setBackgroundImage:[UIImage imageNamed:@"delete_soundRecord@2x"] forState:UIControlStateNormal];
            [deleteButton setTitle:NSLocalizedString(@"丢弃", @"") forState:UIControlStateNormal];
            deleteButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
            [HUD.customView addSubview:deleteButton];
            [deleteButton addTarget:self action:@selector(deleteRecord) forControlEvents:UIControlEventTouchUpInside];
            
            postButton = [[UIButton alloc]initWithFrame:CGRectMake(90, 80, 84, 40)];
            [postButton setBackgroundImage:[UIImage imageNamed:@"post_soundRecord@2x"] forState:UIControlStateNormal];
            [postButton setTitle:NSLocalizedString(@"发布", @"") forState:UIControlStateNormal];
            [postButton addTarget:self action:@selector(postButtonClick) forControlEvents:UIControlEventTouchUpInside];
            postButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
            [HUD.customView addSubview:postButton];
            // Set custom view mode
            HUD.mode = MBProgressHUDModeCustomView;
        }
        
        if ([view isKindOfClass:[UIWindow class]]) {
            [view addSubview:HUD];    
        }
        else {
            [view.window addSubview:HUD];
        }
        
        [HUD show:YES];
        
        
        isRecordValid = YES;
        
    }
    else {
        
        [self.HUD hide:NO]; 
        
        [self deleteRecord];
        
        if ([delegate respondsToSelector:@selector(showSoundRecordFailed)]) {
            
            [delegate showSoundRecordFailed];
        }
        
        isRecordValid = NO;
    }
}

#pragma mark soundRecord

- (void)startRecord {
    
    self.recorder = nil;
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance]; 
    NSError *err = nil; 
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:&err]; 
    if(err) { 
        NSLog(@"audioSession: %@ %d %@", [err domain], [err code], [[err userInfo] description]); 
        return; 
    }
    
    //Make the default sound route for the session be to use the speaker
    UInt32 doChangeDefaultRoute = 1;
    AudioSessionSetProperty (kAudioSessionProperty_OverrideCategoryDefaultToSpeaker, sizeof (doChangeDefaultRoute), &doChangeDefaultRoute);

    [audioSession setActive:YES error:&err]; 
    err = nil; 
    if(err) { 
        NSLog(@"audioSession: %@ %d %@", [err domain], [err code], [[err userInfo] description]); 
        return; 
    } 
    
    NSString *path = [NSTemporaryDirectory() stringByAppendingString:@"RecordedFile"];
    path = [path stringByAppendingFormat:@"%@.caf",[[self class] stringWithUUID]];
    self.recordedFile = [NSURL URLWithString:[path stringByAddingURLEncoding]];
    
    NSDictionary *dic = [self recordingSettings];
    self.recorder = [[[AVAudioRecorder alloc] initWithURL:self.recordedFile settings:dic error:nil] autorelease];
    [recorder prepareToRecord];
    
    self.recorder.meteringEnabled = YES;
    [self.recorder record];
    [recorder recordForDuration:0];
    
    self.levelTimer = [NSTimer scheduledTimerWithTimeInterval: 0.0001 target: self selector: @selector(levelTimerCallback:) userInfo: nil repeats: YES];
}

- (void)deleteRecord {
    
    if ([self.player isPlaying]) {
        
        [self.player stop];
    }
    
    [self.recorder stop];
    [self.recorder deleteRecording];
    
    [self.HUD hide:NO];
}

- (void)postButtonClick {
    
    [self.HUD removeFromSuperview];
    
    if ([delegate respondsToSelector:@selector(postAudioComment:)]) {
        
        [delegate postAudioComment:YES];
    }
}

- (NSString *)convertFormat:(id)sender {
    
    NSString *recordPath = [[self.recordedFile absoluteString] stringByReplacingURLEncoding];
    
    self.convertPath = [NSTemporaryDirectory() stringByAppendingString:@"RecordedFileConvert"];
    self.convertPath = [self.convertPath stringByAppendingFormat:@"%@.mp3",[[self class] stringWithUUID]];
    
    FILE *pcm = fopen([recordPath cStringUsingEncoding:1], "rb");//被转换的文件
    FILE *mp3 = fopen([self.convertPath cStringUsingEncoding:1], "wb");//转换后文件的存放位置
    
    int read, write;
    
    const int PCM_SIZE = 8192;
    
    const int MP3_SIZE = 8192;
    
    short int pcm_buffer[PCM_SIZE*2];
    
    unsigned char mp3_buffer[MP3_SIZE];
    
    lame_t lame = lame_init();
    
    lame_set_in_samplerate(lame, 44100);
    
    lame_set_VBR(lame, vbr_default);
    
    lame_init_params(lame);
    
    do {
        
        read = fread(pcm_buffer, 2*sizeof(short int), PCM_SIZE, pcm);
        
        if (read == 0)
            
            write = lame_encode_flush(lame, mp3_buffer, MP3_SIZE);
        
        else
            
            write = lame_encode_buffer_interleaved(lame, pcm_buffer, read, mp3_buffer, MP3_SIZE);
        
        fwrite(mp3_buffer, write, 1, mp3);
        
    } while (read != 0);
    
    lame_close(lame);
    
    fclose(mp3);
    
    return self.convertPath;
}

#pragma mark action
- (void)isAudioPlaying {
    
    if (![self.player isPlaying]) {
        
        [self.playAudioTimer invalidate];
        [playAudioAnimation stopAnimating];
        
        [playButton setImage:[UIImage imageNamed:@"play_soundRecord@2x"] forState:UIControlStateNormal];
    }
}

- (void)playSound {
    
    if ([player isPlaying]) {
        [player  pause];
        [self.playAudioTimer invalidate];
        [playButton setImage:[UIImage imageNamed:@"play_soundRecord@2x"] forState:UIControlStateNormal];
        [playAudioAnimation stopAnimating];
    }
    else {
        
        [player play];
        [playButton setImage:[UIImage imageNamed:@"pause_soundRecord@2x"] forState:UIControlStateNormal];
        [playAudioAnimation startAnimating];
        
        self.playAudioTimer = [NSTimer scheduledTimerWithTimeInterval: 0.0001 target: self selector: @selector(isAudioPlaying) userInfo: nil repeats: YES];
    }   
}

- (void)levelTimerCallback:(NSTimer *)timer {
    
    [recorder updateMeters];
    
    double ff = [recorder averagePowerForChannel:0];
    
    ff = ff+60;
        
    if (ff>10 && ff<20) {
        [imageViewAnimation setImage:[UIImage imageNamed:@"sound_record1@2x"]];
    }
    else if (ff >=20 &&ff<30) {
        [imageViewAnimation setImage:[UIImage imageNamed:@"sound_record2@2x"]];
    }
    else if (ff >=30 &&ff<40) {
        [imageViewAnimation setImage:[UIImage imageNamed:@"sound_record3@2x"]];
    }
    else if (ff >=40 &&ff<50) {
        [imageViewAnimation setImage:[UIImage imageNamed:@"sound_record4@2x"]];
    } else {
        [imageViewAnimation setImage:[UIImage imageNamed:@"sound_record5@2x"]];
    }
}

@end
