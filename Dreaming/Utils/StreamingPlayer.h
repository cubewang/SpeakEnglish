//
//  StreamingPlayer.h
//  Dreaming
//
//  Created by Cube Wang on 12-8-23.
//  Copyright (c) 2012年 Dreaming Team. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VisualDownloader.h"


@protocol StreamingPlayerStateChangedDelegate <NSObject>

/** 
 * Tell the streaming player is playing or not. 
 */
- (void)streamingPlayerStateDidChange:(BOOL)isPlaying;

@end


@interface StreamingPlayer : UIView <VisualDownloaderDelegate> {

}

@property (nonatomic, assign) id<StreamingPlayerStateChangedDelegate> stateChangedDelegate;

- (void)stopPlaying;
- (void)pausePlaying;
- (void)startOrPauseAudioPlaying;
- (BOOL)isAudioPlaying;
- (void)setAudioUrl:(NSString *)url;

- (IBAction)buttonPressed:(id)sender;

@end
