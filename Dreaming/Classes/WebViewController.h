//
//  WebViewController.h
//  Dreaming
//
//  Abstract: 内容页面视图控制器
//
//  Created by Cube on 11-5-1.
//  Copyright 2011 Dreaming Team. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <MessageUI/MessageUI.h>
#import <CoreLocation/CoreLocation.h>

#import "BaseTableViewController.h"
#import "ZTextField.h"

#import "ZWord.h"


@protocol WebViewControllerDelegate <NSObject>

/** 
 * Called when tell BaseTableViewController the table data was dirty. 
 */
- (void)setRefreshComment;

@end


@interface NoAutoScrollUIScrollView : UIScrollView

@end



@interface NoMenuUITextView : UITextView

@end



@class ZConversation;

@interface WebViewController : UIViewController
<RKObjectLoaderDelegate, UIActionSheetDelegate, UITableViewDataSource, UITableViewDelegate,MFMailComposeViewControllerDelegate, WebViewControllerDelegate, UIGestureRecognizerDelegate, StreamingPlayerStateChangedDelegate, CLLocationManagerDelegate>
{
    BOOL audioComment;
}

@property (nonatomic, retain) ZStatus *article;             //当前文章
@property (nonatomic, retain) ZConversation *conversation;

@property (nonatomic, assign) BOOL shouldAutoPlayAudio;

@property (nonatomic, retain) NSString *selectedWord;
@property (nonatomic, retain) ZWord *word;

@property (nonatomic, retain) IBOutlet UIView *wordPanelView;
@property (nonatomic, retain) IBOutlet UILabel *wordLabel;
@property (nonatomic, retain) IBOutlet UILabel *accetationLabel;


@property (nonatomic, retain) IBOutlet UIScrollView *contentScrollView;

@property (nonatomic, retain) IBOutlet NoMenuUITextView *articleView;

@property (nonatomic, retain) StreamingPlayer *player;
@property (nonatomic, retain) UIImageView *coverImageView;
@property (nonatomic, retain) UIButton *coverButton;

@property (nonatomic, retain) UITableView  *commentTableView;
@property (nonatomic, retain) NSString *textCommentString;
@property (nonatomic, retain) ZTextField *commentView;

@property (nonatomic, retain) id<BaseTableViewControllerDelegate> baseTableViewControllerDelegate;

@property (nonatomic, strong) IBOutlet UISwipeGestureRecognizer *swipeRightRecognizer;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGestureRecognizer;

+ (WebViewController *)getAudioPlayingWebViewController;
+ (WebViewController *)createWebViewController:(ZStatus *)article 
              baseTableViewControllerDelegate:(id)delegate;

- (void)delayDidWordPanelShow:(id)sender;
- (IBAction)worldPanelViewDidClicked:(id)sender;

- (IBAction)handleSwipeFrom:(UISwipeGestureRecognizer *)recognizer;

- (void)back;

@end
