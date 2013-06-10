//
//  ConversationViewController.h
//  Dreaming
//
//  Abstract: 视图控制器
//
//  Created by Cube on 13-1-31.
//  Copyright 2013 Dreaming Team. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <MessageUI/MessageUI.h>
#import <CoreLocation/CoreLocation.h>

#import "ZTextField.h"
#import "ZConversation.h"



@class NoMenuUITextView;


@interface ConversationViewController : UIViewController
<RKObjectLoaderDelegate, UIActionSheetDelegate, UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate, StreamingPlayerStateChangedDelegate, CLLocationManagerDelegate>
{
    BOOL audioComment;
}

@property (nonatomic, retain) ZStatus *originalStatus;  //Conversation中的第一篇Status
@property (nonatomic, retain) ZStatus *replyToMeStatus; //回复我的Status
@property (nonatomic, retain) ZStatus *myStatus; //我发表的Status
@property (nonatomic, retain) NSMutableArray *myReplyingStatuses; //我正在发布中的Status


@property (nonatomic, retain) IBOutlet UIScrollView *contentScrollView;

@property (nonatomic, retain) IBOutlet NoMenuUITextView *articleView;
@property (nonatomic, retain) IBOutlet UIImageView *articleSignature;
@property (nonatomic, retain) StreamingPlayer *player;
@property (nonatomic, retain) UIImageView *coverImageView;
@property (nonatomic, retain) UIButton *coverButton;

@property (nonatomic, retain) UITableView  *commentTableView;
@property (nonatomic, retain) NSString *textCommentString;
@property (nonatomic, retain) ZTextField *commentView;


@property (nonatomic, strong) IBOutlet UISwipeGestureRecognizer *swipeRightRecognizer;

- (IBAction)handleSwipeFrom:(UISwipeGestureRecognizer *)recognizer;

- (void)back;

@end
