//
//  SoundRecorder.h
//  DreamingNews
//
//  Created by cg on 12-10-19.
//  Copyright (c) 2012年 Dreaming Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MBProgressHUD.h"
#import <AVFoundation/AVFoundation.h>

@protocol SoundRecorderDelegate <NSObject>

- (void)postAudioComment:(BOOL)isAudioComment;
- (void)showSoundRecordFailed;

@end

@interface SoundRecorder : NSObject<AVAudioRecorderDelegate,AVAudioSessionDelegate> {
    
}

@property (nonatomic, assign) id delegate;

+ (SoundRecorder *)shareInstance;
+ (NSString *)stringWithUUID;

- (void)startSoundRecord:(UIView *)view;
- (void)soundRecordFailed:(UIView *)view;
- (void)stopSoundRecordView:(UIView *)view;
- (NSString *)convertFormat:(id)sender;

@end
