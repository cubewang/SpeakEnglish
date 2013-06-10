//
//  MainViewController.h
//  EnglishFun
//
//  Created by Cube on 12-08-16.
//  Copyright 2012 Dreaming Team. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "BaseTableViewController.h"

#define kLastNewAppCheckDate  @"lastNewAppCheckDate"
#define kAdBarClosed          @"adBarClosed"


@protocol AutoRefreshingDelegate <NSObject>

- (void)loadArticlesNow:(BOOL)useCache;

@end


@interface MainViewController : BaseTableViewController
<AutoRefreshingDelegate>  {
}

@property (nonatomic, copy) NSString *settedTag;
@property (nonatomic, copy) NSString *usedTag;

@property (nonatomic, retain) UIButton *audioPlayingButton;
@property (nonatomic, retain) UIImageView *audioPlayingAnimation;


- (void)setArticleTag:(NSString *)tag;

- (void)setAudioNowPlayingStatus:(BOOL)isPlayingAudio;
- (void)setNotification:(BOOL)hasNewNotification;

@end
