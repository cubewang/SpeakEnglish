//
//  WebViewController.m
//  Dreaming
//
//  Created by Cube on 11-5-1.
//  Copyright 2011 Dreaming Team. All rights reserved.
//

#import <MessageUI/MessageUI.h>
#import <MapKit/MapKit.h>

#import "WebViewController.h"
#import "UserLoginViewController.h"
#import "UserLoginViewController_iPad.h"
#import "EGOPhotoViewController.h"
#import "SearchWebViewController.h"
#import "MovieViewController.h"

#import "AudioCommentCell.h"
#import "TextCommentCell.h"
#import "GlobalDef.h"
#import "ZConversation.h"

#import "ZAppDelegate.h"
#import "UserAccount.h"
#import "StringUtils.h"
#import "SoundRecorder.h"

#import "ZPhoto.h"
#import "ZPhotoSource.h"
#import "ZStatus.h"


static const int ddLogLevel = LOG_FLAG_ERROR;


@implementation NoAutoScrollUIScrollView

- (void)scrollRectToVisible:(CGRect)rect animated:(BOOL)animated
{
	// Don'd do anything here to prevent autoscrolling. 
	// Unless you plan on using this method in another fashion.
}

@end


@implementation NoMenuUITextView

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    if (action == @selector(cut:)){  
        return NO;  
    }   
    else if(action == @selector(copy:)){  
        return YES;  
    }   
    else if(action == @selector(paste:)){  
        return NO;  
    }   
    else if(action == @selector(select:)){  
        return NO;  
    }   
    else if(action == @selector(selectAll:)){  
        return NO;  
    }  
    else   
    {  
        return [super canPerformAction:action withSender:sender];  
    }
}

@end

@interface WebViewController() {
    
    int commentCountBeforeLoading; //分段请求前的评论数，用于记录是否请求完所有评论
    
    BOOL _performingCoordinateGeocode;
}

@property (nonatomic, retain) NSMutableArray *darenList;

@property (nonatomic, retain) ZStatus *operatingComment;

@property (nonatomic, retain) ZStatus *replyToComment;
@property (nonatomic, retain) UITableViewCell *replyToCommentCell;

@property (nonatomic, retain) NSMutableArray *commentListCached;

@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, retain) NSString *placename;

@end


@implementation WebViewController

static WebViewController *_audioPlayingInstance;

@synthesize article;
@synthesize conversation;
@synthesize darenList;

@synthesize shouldAutoPlayAudio;

@synthesize operatingComment;
@synthesize replyToComment;
@synthesize replyToCommentCell;
@synthesize commentListCached;

@synthesize selectedWord, word;
@synthesize wordPanelView, wordLabel, accetationLabel;

@synthesize contentScrollView;
@synthesize articleView;

@synthesize player;
@synthesize coverImageView;
@synthesize coverButton;

@synthesize commentTableView;
@synthesize textCommentString;
@synthesize commentView;

@synthesize baseTableViewControllerDelegate;

@synthesize swipeRightRecognizer;
@synthesize longPressGestureRecognizer;

@synthesize locationManager;
@synthesize placename;


+ (WebViewController *)getAudioPlayingWebViewController
{
    return _audioPlayingInstance;
}

+ (WebViewController*)createWebViewController:(ZStatus*)article 
              baseTableViewControllerDelegate:(id)delegate
{
    if (article == nil)
        return nil;
    
    if (_audioPlayingInstance != nil && _audioPlayingInstance.article.statusID == article.statusID)
    {
        return [_audioPlayingInstance retain];
    }
    
    WebViewController *webViewController = [[UIDevice currentDevice] userInterfaceIdiom ] == UIUserInterfaceIdiomPhone ?
        [[WebViewController alloc] init] :
        [[WebViewController alloc] initWithNibName:@"WebView_iPad" bundle:nil];
    
    webViewController.article = article;
    webViewController.baseTableViewControllerDelegate = delegate;
    
    return webViewController;
}

- (void)retainAudioPlayingWebViewControllerInstance {
    
    if (self == _audioPlayingInstance)
        return;
    
    if (_audioPlayingInstance != nil) {
        RELEASE_SAFELY(_audioPlayingInstance);
    }
    
    _audioPlayingInstance = [self retain];
}


- (void)dealloc {
    
    [[RKClient sharedClient].requestQueue cancelRequestsWithDelegate:self];
    
    self.article = nil;
    
    self.conversation = nil;
    self.commentListCached = nil;
    self.darenList = nil;
    
    self.operatingComment = nil;
    self.replyToComment = nil;
    self.replyToCommentCell = nil;
    
    self.selectedWord = nil;
    self.word = nil;
    
    self.contentScrollView = nil;
    self.articleView = nil;
    
    [self.player stopPlaying];
    self.player.stateChangedDelegate = nil;
    self.player = nil;
    self.coverImageView = nil;
    self.coverButton = nil;
    
    self.commentTableView = nil;
    self.commentView.delegate = nil;
    self.commentView = nil;
    self.textCommentString = nil;
    
    self.swipeRightRecognizer = nil;
    self.longPressGestureRecognizer = nil;
    
    self.locationManager = nil;
    self.placename = nil;
    
    [SoundRecorder shareInstance].delegate = nil;
    
    [super dealloc];
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    if (self == _audioPlayingInstance) {
        return;
    }
    
    self.contentScrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    UIButton *buttonLeft = [[[UIButton alloc] initWithFrame:CGRectMake(5, 0, 44, 44)] autorelease];
    [buttonLeft setImage:[UIImage imageNamed:@"back@2x"] forState:UIControlStateNormal];
    [buttonLeft addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *itemLeft = [[[UIBarButtonItem alloc] initWithCustomView:buttonLeft] autorelease]; 
    
    self.navigationItem.leftBarButtonItem = itemLeft;
    
    UIButton *buttonRight = [[[UIButton alloc] initWithFrame:CGRectMake(5, 0, 44, 44)] autorelease];
    [buttonRight setImage:[UIImage imageNamed:@"share_article@2x"] forState:UIControlStateNormal];
    [buttonRight addTarget:self action:@selector(shareByActivity) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *itemRight = [[[UIBarButtonItem alloc] initWithCustomView:buttonRight] autorelease];
    
    self.navigationItem.rightBarButtonItem = itemRight;
    
    [self setupLongPressGesture];

    [self initCommentView];
    [self loadArticle:self.article];
    [self getLocation];
}

- (void)addTitleView {
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if ([self.navigationController.navigationBar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)]){
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"NavBar_ios5.png"] forBarMetrics:UIBarMetricsDefault];
    }
    
    self.viewDeckController.panningGestureDelegate = self;
    self.viewDeckController.enabled = NO;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    self.viewDeckController.panningGestureDelegate = nil;
    self.viewDeckController.enabled = YES;
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)initControls:(ZStatus*)status
{
    CGFloat top = 0;
    
    if ([[ZStatus getCoverImageUrl:status] length] > 0) {
        
        CGFloat coverHeight = ([[UIDevice currentDevice] userInterfaceIdiom ] == UIUserInterfaceIdiomPhone ? COVER_IMAGE_HEIGHT : COVER_IMAGE_HEIGHT * 4 / 3);
        
        self.coverImageView = [[[UIImageView alloc] init] autorelease];
        
        self.coverImageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.coverImageView setClipsToBounds:YES];
        self.coverImageView.frame = CGRectMake(0,
                                               top,
                                               SCREEN_WIDTH,
                                               coverHeight);
        
        [self.contentScrollView addSubview:self.coverImageView];
        
        [self.coverImageView setImageWithURL:[NSURL URLWithString:[ZStatus getCoverImageUrl:status]] 
                               placeholderImage:[RTTableViewCell getDefaultCoverImage]];
        
        self.coverButton = [[[UIButton alloc] init] autorelease];
        [self.coverButton addTarget:self action:@selector(coverButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        if ([[ZStatus getVideoUrl:status] length] > 0) {
            
            if ([[UIDevice currentDevice] userInterfaceIdiom ] == UIUserInterfaceIdiomPhone) {
                [self.coverButton setImage:[UIImage imageNamed:@"video_button@2x.png"] forState:UIControlStateNormal];
            }
            else {
                [self.coverButton setImage:[UIImage imageNamed:@"video_button_iPad.png"] forState:UIControlStateNormal];
            }
        }
        
        self.coverButton.frame = CGRectMake((SCREEN_WIDTH - COVER_IMAGE_WIDTH)/2,
                                            top,
                                            COVER_IMAGE_WIDTH,
                                            COVER_IMAGE_HEIGHT);
        
        [self.contentScrollView addSubview:self.coverButton];
        
        UIButton *favoriteButton = [[[UIButton alloc] initWithFrame:
                                     CGRectMake(SCREEN_WIDTH - 44, coverHeight - 44, 44, 44)] autorelease];
        [favoriteButton addTarget:self action:@selector(favoriteButtonClicked:) forControlEvents:UIControlEventTouchDown];
        
        NSString *imageName = status.isFavorited ? @"favorite_on@2x" : @"favorite_off@2x";
        [favoriteButton setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
        
        [self.contentScrollView addSubview:favoriteButton];
        
        top += coverHeight + kTableCellMargin;
    }
    
    if ([[ZStatus getAudioUrl:status] length] > 0) {
        
        self.player = [[[StreamingPlayer alloc] initWithFrame:CGRectMake(0, 0, PLAYER_HEIGHT, PLAYER_WIDTH)] autorelease];
        self.player.stateChangedDelegate = self;
        
        [self.contentScrollView addSubview:self.player];
        
        self.player.frame = CGRectMake((SCREEN_WIDTH - PLAYER_WIDTH)/2,
                                       top,
                                       PLAYER_WIDTH,
                                       PLAYER_HEIGHT);
        
        top += PLAYER_HEIGHT + kTableCellMargin;
        
        [self.player setAudioUrl:[ZStatus getAudioUrl:status]];
        
        if (self.shouldAutoPlayAudio) {
            RELEASE_SAFELY(_audioPlayingInstance);
            [self.player buttonPressed:nil];
        }
    }
    
    NSString *contentString = status.text;
    
    //计算articleView高度
    self.articleView.frame = CGRectMake(kTableCellSmallMargin,
                                        top,
                                        SCREEN_WIDTH - 2*kTableCellSmallMargin,
                                        SCREEN_HEIGHT);
    
    self.articleView.text = contentString;
    
    //设置高度
    self.articleView.frame = CGRectMake(kTableCellSmallMargin,
                                        top,
                                        SCREEN_WIDTH - 2*kTableCellSmallMargin,
                                        self.articleView.contentSize.height);
    
    self.contentScrollView.contentSize = CGSizeMake(SCREEN_WIDTH,
                                                    top + self.articleView.frame.size.height + kTableCellSmallMargin);
}


- (void)initCommentTableView:(ZConversation*)theConversation
{
    if ([theConversation.statusList count] == 0)
        return;
    
    CGFloat tableHeight = [self tableHeightForObject:theConversation];
    
    CGSize size = self.contentScrollView.contentSize;
    
    if (self.commentTableView != nil) {
        
        size.height -= self.commentTableView.frame.size.height;
        [self.commentTableView removeFromSuperview];
    }
    
    CGRect rc = CGRectMake(0, kTableCellSmallMargin + size.height, SCREEN_WIDTH, tableHeight);
    
    self.commentTableView = [[[UITableView alloc] initWithFrame:rc 
                                                          style:UITableViewStylePlain] autorelease];
    self.commentTableView.dataSource = self;
    self.commentTableView.delegate = self;
    self.commentTableView.scrollEnabled = NO;
    self.commentTableView.backgroundColor = [UIColor clearColor];
    
    [self.contentScrollView addSubview:self.commentTableView];
    
    size.height += (tableHeight + kTableCellMargin);
    
    self.contentScrollView.contentSize = size;
}

- (void)resizeCommentTableView:(ZConversation*)theConversation
{
    CGFloat tableHeight = [self tableHeightForObject:theConversation];
    
    CGSize size = self.contentScrollView.contentSize;
    size.height -= (self.commentTableView.frame.size.height + kTableCellMargin);
    
    CGRect rc = CGRectMake(0, kTableCellSmallMargin + size.height, SCREEN_WIDTH, tableHeight);
    
    self.commentTableView.frame = rc;
    
    size.height += tableHeight + kTableCellMargin;
    
    self.contentScrollView.contentSize = size;
    
    [self.commentTableView reloadData];
}

- (void)initCommentView {
    
    audioComment = NO;
    
    if (self.commentView == nil) {
        
        self.commentView = [[[ZTextField alloc] init] autorelease];
        self.commentView.delegate = self;
        [self.commentView setView:self.view];
        
        [self.view addSubview:self.commentView];
    }
    
    [self.view bringSubviewToFront:wordPanelView];
}

- (void)postCommentToServer {
    
    [[ZAppDelegate sharedAppDelegate] showProgress:self.view info:NSLocalizedString(@"发送中", @"")];
    [[ZAppDelegate sharedAppDelegate] setProgress:self.view progress:0.2 info:NSLocalizedString(@"发送中", @"")];
    
    NSInteger statusId = self.replyToComment == nil ? self.article.statusID : self.replyToComment.statusID;
    
    NSString *latitude = nil;
    NSString *longitude = nil;
    
    CLLocationCoordinate2D locationCoordinate = [ZAppDelegate sharedAppDelegate].userLocation.coordinate;
    
    if (locationCoordinate.latitude != 0.0 || locationCoordinate.longitude != 0.0) {
        latitude = [NSString stringWithFormat:@"%f", locationCoordinate.latitude];
        longitude = [NSString stringWithFormat:@"%f", locationCoordinate.longitude];
    }
    
    if (audioComment) {
        
        audioComment = NO;
        
        NSString *filePath = [[SoundRecorder shareInstance] convertFormat:nil];
        
        if (filePath == nil) {
            
            return;
        }
        
        [DreamingAPI postStatus:@"音频评论"
                    filePath:filePath
                  websiteUrl:nil 
           inReplyToStatusId:[NSString stringWithFormat:@"%d", statusId] 
                    latitude:latitude
                   longitude:longitude
                    delegate:self]; 
    }
    else {
        
        [DreamingAPI postStatus:self.textCommentString
                    filePath:nil
                  websiteUrl:nil 
           inReplyToStatusId:[NSString stringWithFormat:@"%d", statusId]
                    latitude:latitude
                   longitude:longitude
                    delegate:self]; 
    }
    
    [self unsetInReplying];
}

- (void)postAudioComment:(BOOL)isAudioComment {
    
    audioComment = isAudioComment;
    
    if ([self needUserLogin:self])
        return;
    
    [self postCommentToServer];
}

- (void)showSoundRecordFailed {
    
    [[SoundRecorder shareInstance] soundRecordFailed:self.view];
}


- (void)userLoginViewControllerReturnResult {
    
    [self postCommentToServer];
}


#pragma mark -
#pragma mark Gesture

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    
    if (self.swipeRightRecognizer == gestureRecognizer || self.longPressGestureRecognizer == gestureRecognizer) {
        return YES;
    }
    
    return NO;
}

- (IBAction)handleSwipeFrom:(UISwipeGestureRecognizer *)recognizer {
    
    if (recognizer.direction == UISwipeGestureRecognizerDirectionRight) {
        [self back];
    }
}


- (void)setupLongPressGesture
{
    //取词长按手势
    self.longPressGestureRecognizer = 
    [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    
    [self.articleView addGestureRecognizer:self.longPressGestureRecognizer];
    [self.longPressGestureRecognizer setDelegate:self];
    [self.longPressGestureRecognizer release];
}

- (void)delayDidWordPanelShow:(id) sender
{
    //隐藏取词Bar
    self.wordPanelView.alpha = 1.0;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [UIView setAnimationDuration:0.3];
    
    self.wordPanelView.alpha = 0.0;
    
    [UIView commitAnimations];
}

- (IBAction) worldPanelViewDidClicked:(id)sender
{
    [self showDictPage];
}

- (void)handleLongPress:(UIGestureRecognizer *)gestureRecognizer {
    
    if (self.articleView.selectedRange.location == NSNotFound || self.articleView.selectedRange.length == 0) {
        
        return;
    }
    
    UIMenuController *menuController = [UIMenuController sharedMenuController];
    UIMenuItem *resetMenuItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"翻译verb", @"") action:@selector(showDictPage)];
    [menuController setMenuItems:[NSArray arrayWithObjects:resetMenuItem, nil]];
    [menuController setMenuVisible:YES animated:YES];
    [resetMenuItem release];
    
    NSString* selection = [self.articleView.text substringWithRange:self.articleView.selectedRange];
    
    //去掉左右空格
    selection = [selection stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    NSArray *wordArray = [selection componentsSeparatedByString:@" "];
    if ([wordArray count] > 1) {
        
        //翻译句子
        return;
    }
    
    //选择的内容为空
    if (selection.length == 0)
    {
        return;
    }
    
    //显示取词Bar
    if (self.wordPanelView.hidden || self.wordPanelView.alpha < 0.1)
    {
        self.wordPanelView.hidden = NO;
        self.wordPanelView.alpha = 0.0;
        
        [UIView beginAnimations:nil 
                        context:nil];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        [UIView setAnimationDuration:.3];
        
        self.wordPanelView.alpha = 1.0;
        
        [UIView commitAnimations];
    }
    
    //防止重发查询
    if (self.word != nil && [selection isEqualToString:self.word.Key])
    {
        if ([self.word.AcceptationList count] > 0)
        {
            self.accetationLabel.text = [self.word.AcceptationList objectAtIndex:0];
        }
        else {
            self.accetationLabel.text = NSLocalizedString(@"点击查看释义", @"");
        }
        
        [self performSelector:@selector(delayDidWordPanelShow:) 
                   withObject:nil 
                   afterDelay:3];
        
        return;
    }
    
    if ([DreamingAPI getWord:selection delegate:self]) {

        self.selectedWord = selection;
        self.wordLabel.text = self.selectedWord;
        self.accetationLabel.text = NSLocalizedString(@"查找中...", @"");
    }
}

- (void)showDictPage
{
    if ([self.selectedWord length] > 0)
    {
        NSString *dictUrl = [NSString stringWithFormat:@"%@%@", DICTIONARY_PAGE, self.selectedWord];
        SearchWebViewController *searchViewController = [[SearchWebViewController alloc] init];
        searchViewController.contentUrl = dictUrl;
        [self presentModalViewController:searchViewController animated:YES];
        
        [searchViewController release];
    }
}


#pragma mark -
#pragma mark Comment Cell Action

- (IBAction)commentCellButtonAction:(UIButton *)sender {
    
    if ([self needUserLogin:nil])
        return;
    
    UIButton *clickedButton = (UIButton*)sender;
    
    if (clickedButton.tag >= 10000)
    {
        self.operatingComment = [self.darenList count] > clickedButton.tag - 10000 ? [self.darenList objectAtIndex:clickedButton.tag - 10000] : nil;
    }
    else
    {
        self.operatingComment = [self.conversation.statusList count] > clickedButton.tag ? [self.conversation.statusList objectAtIndex:clickedButton.tag] : nil;
    }
    
    if (self.operatingComment == nil)
        return;
    
    if ([[UserAccount getUserId] isEqualToString:[NSString stringWithFormat:@"%d",self.operatingComment.user.userID]]) {
        
        if (self.operatingComment.favoritesCount >= 4)
        {
            [self shareToSNS:
             [NSString stringWithFormat:@"我说的口语得到了%d个同学的喜爱，我获得了“口语达人”的称号！你也来试试看！", self.operatingComment.favoritesCount]];
        }
        else
        {
            [self deleteComment];
        }
    }
    else {

        UILabel *label = nil;
        UIImageView *imageView = nil;
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:
                                  (clickedButton.tag >= 10000 ? clickedButton.tag - 10000 : clickedButton.tag)
                                                    inSection:
                                  (clickedButton.tag >= 10000 ? 0 : 1)
                                  ];
        id cell = [self.commentTableView cellForRowAtIndexPath:indexPath];
        
        if ([cell isKindOfClass:[AudioCommentCell class]])
        {
            AudioCommentCell *audioCommentCell = (AudioCommentCell *)cell;
            label = audioCommentCell.favoriteCountLabel;
            imageView = audioCommentCell.smileImageView;
        }
        else if ([cell isKindOfClass:[TextCommentCell class]]) {
            TextCommentCell *textCommentCell = (TextCommentCell *)cell;
            label = textCommentCell.favoriteCountLabel;
            //imageView = textCommentCell.smileImageView;
        }
        
        [self commentCellFavoriteButtonClicked:clickedButton label:label imageView:imageView];
    }
}

- (void)commentCellFavoriteButtonClicked:(UIButton *)sender label:(UILabel *)label imageView:(UIImageView *)imageView {
    
    UIButton *button = sender;
    
    NSString *statusId = [NSString stringWithFormat:@"%d",self.operatingComment.statusID];
    
    if (statusId == nil) {
        return ;
    }
    
    button.enabled = NO;
    
    if (self.operatingComment.isFavorited)
    {
        [DreamingAPI deleteFavorite:statusId onDidLoadResponse:^(RKResponse *response) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [button setImage:[UIImage imageNamed:@"thumbs_up_off"] forState:UIControlStateNormal];
                self.operatingComment.isFavorited = NO;
                if (self.operatingComment.favoritesCount != 0)
                {
                    self.operatingComment.favoritesCount -= 1;
                    label.text = [NSString stringWithFormat:@"%d", self.operatingComment.favoritesCount];
                    
                    [self processChangingAnimation:imageView
                                fromFavoritesCount:self.operatingComment.favoritesCount + 1
                                  toFavoritesCount:self.operatingComment.favoritesCount];
                }
                
                button.enabled = YES;
            });
        }
          onDidFailLoadWithError:^(NSError *error) {
              dispatch_async(dispatch_get_main_queue(), ^{
                  [[ZAppDelegate sharedAppDelegate] showInformation:self.view info:NSLocalizedString(@"取消赞失败了", @"")];
                  
                  button.enabled = YES;
              });
          }];
    }
    else 
    {
        [DreamingAPI createFavorite:statusId onDidLoadResponse:^(RKResponse *response) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [button setImage:[UIImage imageNamed:@"thumbs_up_on"] forState:UIControlStateNormal];
                self.operatingComment.isFavorited = YES;
                self.operatingComment.favoritesCount += 1;
                label.text = [NSString stringWithFormat:@"%d", self.operatingComment.favoritesCount];
                
                [self processChangingAnimation:imageView
                            fromFavoritesCount:self.operatingComment.favoritesCount - 1
                              toFavoritesCount:self.operatingComment.favoritesCount];
                
                button.enabled = YES;
            });
        }
          onDidFailLoadWithError:^(NSError *error) {
              dispatch_async(dispatch_get_main_queue(), ^{
                  [[ZAppDelegate sharedAppDelegate] showInformation:self.view info:NSLocalizedString(@"添加赞失败了", @"")];
                  
                  button.enabled = YES;
              });
          }];
    }
}

- (void)processChangingAnimation:(UIImageView *)imageView
              fromFavoritesCount:(NSInteger)fromFavoritesCount
                toFavoritesCount:(NSInteger)toFavoritesCount
{
    UIImage *toImage = nil;
    
    if (fromFavoritesCount == 2 && toFavoritesCount == 1) {
    }
    else if ((fromFavoritesCount == 1 && toFavoritesCount == 2) ||
        (fromFavoritesCount == 4 && toFavoritesCount == 3))
    {
        toImage = [UIImage imageNamed:@"smile_1.png"];
    }
    else if ((fromFavoritesCount == 3 && toFavoritesCount == 4) ||
             (fromFavoritesCount == 8 && toFavoritesCount == 7))
    {
        toImage = [UIImage imageNamed:@"smile_2.png"];
    }
    else if ((fromFavoritesCount == 7 && toFavoritesCount == 8) ||
             (fromFavoritesCount == 16 && toFavoritesCount == 15))
    {
        toImage = [UIImage imageNamed:@"smile_3.png"];
    }
    else if ((fromFavoritesCount == 15 && toFavoritesCount == 16) ||
             (fromFavoritesCount == 32 && toFavoritesCount == 31))
    {
        toImage = [UIImage imageNamed:@"smile_4.png"];
    }
    else if (fromFavoritesCount == 31 && toFavoritesCount == 32)
    {
        toImage = [UIImage imageNamed:@"smile_5.png"];
    }
    else {
        return;
    }
    
    [self doSmileAnimation:imageView toImage:toImage];
}

- (void)doSmileAnimation:(UIImageView *)imageView toImage:(UIImage*)toImage {
    
    CABasicAnimation* rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = @((2 * M_PI) * 3); // 3 is the number of 360 degree rotations
    rotationAnimation.duration = 1.5f;
    rotationAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation.fromValue = @4.0f;
    scaleAnimation.toValue = @1.0f;
    scaleAnimation.duration = 1.5f;
    scaleAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    
    CABasicAnimation *crossFadeAnimation = [CABasicAnimation animationWithKeyPath:@"contents"];
    crossFadeAnimation.duration = 1.5f;
    crossFadeAnimation.fromValue = (id)imageView.image.CGImage;
    crossFadeAnimation.toValue = (id)toImage.CGImage;
    
    CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
    animationGroup.duration = 1.5f;
    animationGroup.autoreverses = NO;
    animationGroup.repeatCount = 0;
    [animationGroup setAnimations:@[rotationAnimation, scaleAnimation, crossFadeAnimation]];
    
    [imageView.layer addAnimation:animationGroup forKey:@"animationGroup"];
    
    imageView.image = toImage;
}

- (void)deleteComment
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"你要删除评论吗？", @"")
                                                             delegate:self
                                                    cancelButtonTitle:NSLocalizedString(@"取消", @"") 
                                               destructiveButtonTitle:NSLocalizedString(@"确认删除", @"") 
                                                    otherButtonTitles:nil];
    [actionSheet showInView:self.view];
    [actionSheet release];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([[UserAccount getUserId] isEqualToString:[NSString stringWithFormat:@"%d",self.operatingComment.user.userID]]) {
        
        if (buttonIndex == 0) 
        {
            NSString *statusId = [NSString stringWithFormat:@"%d",self.operatingComment.statusID];
            [DreamingAPI deleteStatus:statusId delegate:self];
        }
    }
}

- (void)resetCommentList
{
    if (self.commentListCached)
    {
        [self.commentListCached removeAllObjects];
        commentCountBeforeLoading = 0;
    }
}

#pragma mark -
#pragma mark StreamingPlayerStateChangedDelegate

- (void)streamingPlayerStateDidChange:(BOOL)isPlaying
{
    MainViewController* mainController = [[ZAppDelegate sharedAppDelegate] mainViewController];
    [mainController setAudioNowPlayingStatus:isPlaying];
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    // Return the number of rows in the section.
    
    if (section == 0)
        return self.darenList.count == 0 ? 1 : self.darenList.count;
    
    if (section == 1)
        return self.conversation.statusList.count == 0 ? 0 : self.conversation.statusList.count + 1;
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {

    UIView *view = [[[UIView alloc] init] autorelease];
    
    UIImageView *imageView = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 30)] autorelease];
    imageView.image = [UIImage imageNamed:@"comment_title_bg@2x"];
    UILabel *lable = [[[UILabel alloc] initWithFrame:CGRectMake(8, 2, 200, 30)] autorelease];
    lable.textAlignment = UITextAlignmentLeft;
    lable.backgroundColor = [UIColor clearColor];
    lable.font = [UIFont boldSystemFontOfSize:13.0];
    lable.textColor = SECTION_TEXT_COLOR;
    lable.text = (section == 0 ? NSLocalizedString(@"口语达人",@"") : NSLocalizedString(@"全部评论",@""));
    [imageView addSubview:lable];
    
    [view addSubview:imageView];
    
    return view;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 1 && indexPath.row == [self.conversation.statusList count]) {
        
        UITableViewCell *cell = [[[UITableViewCell alloc] 
                                  initWithStyle:UITableViewCellStyleDefault 
                                  reuseIdentifier:nil] autorelease];
        
        cell.textLabel.text = NSLocalizedString(@"显示更多", @"");
        cell.textLabel.textAlignment = UITextAlignmentCenter;
        cell.textLabel.font = [UIFont boldSystemFontOfSize:16];
        cell.textLabel.highlightedTextColor = CELLTEXT_COLOR;
        
        UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        activityView.frame = CGRectMake(95.0f, 18.0f, 25.0f, 25.0f);
        activityView.hidesWhenStopped = YES;
        activityView.tag = 200;
        [cell addSubview:activityView];
        [activityView release];
        
        // set selection color 
        UIView *backgroundView = [[UIView alloc] initWithFrame:cell.frame]; 
        backgroundView.backgroundColor = SELECTED_BACKGROUND;
        cell.selectedBackgroundView = backgroundView; 
        [backgroundView release];
        
        return cell;
    }
    
    // Configure the cell.
    ZStatus *comment = nil;
    
    if (indexPath.section == 0) {
        comment = [self.darenList count] == 0 ? nil : [self.darenList objectAtIndex:indexPath.row];
        
        if (comment == nil) {
            
            UITableViewCell *cell = [[[UITableViewCell alloc] init] autorelease];
            
            UIView *view = [[[UIView alloc] init] autorelease];
            
            UIImageView *imageView = nil;
            
            if ([[UIDevice currentDevice] userInterfaceIdiom ] == UIUserInterfaceIdiomPhone)
            {
                imageView = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 60)] autorelease];
                imageView.image = [UIImage imageNamed:@"daren_empty_bg@2x"];
            }
            else
            {
                imageView = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 768, 60)] autorelease];
                imageView.image = [UIImage imageNamed:@"daren_empty_bg_iPad"];
            }
            
            [view addSubview:imageView];
            
            cell.backgroundView = view;
            [cell setSelectionStyle:UITableViewCellEditingStyleNone];
            
            return cell;
        }
    }
    else {
        comment = [self.conversation.statusList count] == 0 ? nil : [self.conversation.statusList objectAtIndex:indexPath.row];
    }
    
    if ([self isAudioComment:comment])
    {
        ZStatus *sourceComment = [self getReplyToComment:comment];
        
        NSString *nibName = @"AudioCommentCell";
        
        AudioCommentCell *commentCell = [tableView dequeueReusableCellWithIdentifier:nibName];
        
        if (commentCell == nil) {
            NSArray *nibs = [[NSBundle mainBundle] loadNibNamed:nibName owner:nil options:nil];
            
            for (id item in nibs) {
                if ([item isKindOfClass:[UITableViewCell class]]) {
                    commentCell = item;
                    break;
                }
            }
        }
        
        [commentCell setSelectionStyle:UITableViewCellEditingStyleNone];
        [commentCell setDataSource:comment replyToStatus:sourceComment];
        [commentCell setCommentDelegate:indexPath.section == 0 ? indexPath.row + 10000 : indexPath.row //区分精华评论和全部评论
                                  target:self 
                                  action:@selector(commentCellButtonAction:)];
        
        if ([[UserAccount getUserId] integerValue] == comment.user.userID) {
            commentCell.backgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"my_comment_bg"]] autorelease];
        }
        else {
            commentCell.backgroundView = nil;
        }
        
        return commentCell;
    }
    else
    {
        TextCommentCell *commentCell = [tableView dequeueReusableCellWithIdentifier:@"TextCommentCell"];
        
        if (commentCell == nil) {
            NSArray *nibs = [[NSBundle mainBundle] loadNibNamed:@"TextCommentCell" owner:nil options:nil];
            
            for (id item in nibs) {
                if ([item isKindOfClass:[UITableViewCell class]]) {
                    commentCell = item;
                    break;
                }
            }
        }
        
        [commentCell setSelectionStyle:UITableViewCellEditingStyleNone];
        [commentCell setDataSource:comment];
        [commentCell setCommentDelegate:indexPath.section == 0 ? indexPath.row + 10000 : indexPath.row //区分精华评论和全部评论 
                                 target:self 
                                 action:@selector(commentCellButtonAction:)];
        
        return commentCell;
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ZStatus *comment = nil;
    
    if (indexPath.section == 0) {
        
        if ([self.darenList count] == 0)
            return 60;
        
        comment = [self.darenList objectAtIndex:indexPath.row];
    }
    else {
        
        if ([self.conversation.statusList count] == 0) {
            return 0;
        }
        
        if (indexPath.row >= [self.conversation.statusList count])
            return 60;
        
        comment = [self.conversation.statusList count] == 0 ? nil : [self.conversation.statusList objectAtIndex:indexPath.row];
    }
    
    return [self isAudioComment:comment] ?
    [AudioCommentCell heightForCell:comment replyToStatus:[self getReplyToComment:comment]] :
    [TextCommentCell heightForCell:comment];
}


- (CGFloat)tableHeightForObject:(ZConversation*)theConversation {
    
    CGFloat tableHeight = 0.0;
    
    for (ZStatus *status in self.darenList)
    {
        tableHeight += ([self isAudioComment:status] ?
                        [AudioCommentCell heightForCell:status replyToStatus:[self getReplyToComment:status]] :
                        [TextCommentCell heightForCell:status]);
    }
    
    if (self.darenList.count == 0)
        tableHeight += 60;
    
    for (ZStatus *status in theConversation.statusList)
    {
        if (status.statusID == theConversation.originalStatus.statusID)
            continue;
        
        tableHeight += ([self isAudioComment:status] ?
                        [AudioCommentCell heightForCell:status replyToStatus:[self getReplyToComment:status]] :
                        [TextCommentCell heightForCell:status]);
    }
    
    return tableHeight > 0.0 ? tableHeight + 60 + 60: 0.0;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Deselect
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 1 && indexPath.row == [self.conversation.statusList count])
    {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        if (cell) {
            
            [(UIActivityIndicatorView *)[cell viewWithTag:200] startAnimating];
            cell.textLabel.text = NSLocalizedString(@"加载中...", @"");
        }
        
        NSInteger page = [self.conversation.statusList count] / 20 + 1;
        
        [DreamingAPI getConversation:[NSString stringWithFormat:@"%d", self.article.conversationID]
                             page:page
                           length:20
                         delegate:self
                    useCacheFirst:NO];
        
        commentCountBeforeLoading = [self.conversation.statusList count];
        
        return;
    }
    else
    {
        UITableViewCell *cellClicked = [tableView cellForRowAtIndexPath:indexPath];
        
        ZStatus *commentClicked = nil;
        
        if (indexPath.section == 0) {
            commentClicked = [self.darenList count] == 0 ? nil : [self.darenList objectAtIndex:indexPath.row];
        }
        else {
            commentClicked = [self.conversation.statusList count] == 0 ? nil : [self.conversation.statusList objectAtIndex:indexPath.row];
        }
        
        if (commentClicked == nil)
            return;
        
        //再次点击消除回复状态
        if (self.replyToComment.statusID == commentClicked.statusID)
        {
            [self unsetInReplying];
            
            return;
        }
        
        [self setInReplying:commentClicked.user.name commentClicked:commentClicked cellClicked:cellClicked];
    }
}

- (void)setInReplying:(NSString *)name commentClicked:(ZStatus *)commentClicked cellClicked:(UITableViewCell *)cellClicked
{
    [self.replyToCommentCell changeReplyingState:nil hidden:YES];
    [cellClicked changeReplyingState:[NSString stringWithFormat:NSLocalizedString(@"回复%@中", @""), name] hidden:NO];
    [self.commentView changeButtonText:[NSString stringWithFormat:NSLocalizedString(@"按住，回复%@", @""), name]];
    self.replyToComment = commentClicked;
    self.replyToCommentCell = cellClicked;
    
    self.contentScrollView.scrollEnabled = NO;
    self.contentScrollView.backgroundColor = SELECTED_BACKGROUND;
}

- (void)unsetInReplying
{
    [self.replyToCommentCell changeReplyingState:nil hidden:YES];
    [self.commentView changeButtonText:nil];
    
    self.replyToComment = nil;
    self.replyToCommentCell = nil;
    
    self.contentScrollView.scrollEnabled = YES;
    self.contentScrollView.backgroundColor = [UIColor clearColor];
}

- (BOOL)isAudioComment:(ZStatus *)status {
    return [[ZStatus getAudioUrl:status] length] > 0;
}

- (ZStatus *)getReplyToComment:(ZStatus *)status {
    if (status.inReplyToStatusId == nil || [status.inReplyToStatusId integerValue] == self.article.statusID)
        return nil;
    
    NSInteger replyToId = [status.inReplyToStatusId integerValue];
    
    for (ZStatus *comment in self.conversation.statusList)
    {
        if (comment.statusID == replyToId) {
            return comment;
        }
    }
    
    //如果本地没有找到，构造一个
    ZStatus *sourceStatus = [[[ZStatus alloc] init] autorelease];
    sourceStatus.user = [[[ZUser alloc] init] autorelease];
    sourceStatus.user.screenName = status.inReplyToScreenName;
    sourceStatus.user.userID = [status.inReplyToUserId integerValue];
    sourceStatus.statusID = [status.inReplyToStatusId integerValue];
    
    return sourceStatus;
}


- (void)loadArticle:(ZStatus *)status
{
    if (status == nil || status.text == nil)
        return;
    
    [self initControls:status];
    
    [self addTitleView];
    
    [DreamingAPI getConversation:[NSString stringWithFormat:@"%d", status.conversationID]
                         page:0
                       length:20
                     delegate:self
                useCacheFirst:NO];
}


- (void)showWordOnLabel {

    if (self.word == nil)
    {
        self.accetationLabel.text = NSLocalizedString(@"点击查看释义", @"");
        
        [self performSelector:@selector(delayDidWordPanelShow:) 
                   withObject:nil 
                   afterDelay:3];
        return;
    }

    self.wordLabel.text = self.word.Key;

    if ([self.word.AcceptationList count] > 0)
    {
        self.accetationLabel.text = [self.word.AcceptationList objectAtIndex:0];
    }
    else {
        self.accetationLabel.text = NSLocalizedString(@"点击查看释义", @"");
    }

    [self performSelector:@selector(delayDidWordPanelShow:) 
               withObject:nil 
               afterDelay:3];
}

- (void)scrollToComment {
    
    [self resetCommentList];
    
    [DreamingAPI getConversation:[NSString stringWithFormat:@"%d", self.article.conversationID]
                         page:0
                       length:20
                     delegate:self
                useCacheFirst:NO];
    
    CGPoint point = CGPointMake(0, self.articleView.contentSize.height);
    
    [self.contentScrollView setContentOffset:point animated:YES];
}

#pragma mark RKObjectLoaderDelegate methods

- (void)request:(RKRequest*)request didLoadResponse:(RKResponse*)response {

    NSString *string = [response.URL absoluteString];
    
    if ([string hasPrefix:[NSString stringWithFormat:@"%@%@", MAIN_PATH, STATUS_DELETE]]) {
        
        NSString* bodyString = [[[NSString alloc] initWithData:response.body encoding:NSUTF8StringEncoding] autorelease];
        
        NSString *resultString = NSLocalizedString(@"评论删除成功", @"");
        
        if ([bodyString rangeOfString:@"error"].length > 0) {
            
            resultString = NSLocalizedString(@"评论删除失败", @"");
        }
        else {
            [self scrollToComment];
        }
        
        [[ZAppDelegate sharedAppDelegate] showInformation:self.view info:resultString];
    }
    else if ([string hasPrefix:[NSString stringWithFormat:@"%@%@", MAIN_PATH, STATUS_UPDATE]]) {
        
        if (response.statusCode == 200) {
            
            [[ZAppDelegate sharedAppDelegate] setProgress:self.view progress:1.0 info:NSLocalizedString(@"评论发送成功", @"")];
            
            [self scrollToComment];
        }
        else {
            [[ZAppDelegate sharedAppDelegate] setProgress:self.view progress:1.0 info:NSLocalizedString(@"评论发送失败",@"")];
        }
    }
}


- (void)objectLoader:(RKObjectLoader *)objectLoader didLoadObject:(id)object {
    
    NSString *string = [objectLoader.URL absoluteString];
    
    if ([string hasPrefix:[NSString stringWithFormat:@"%@/statusnet/conversation", MAIN_PATH]])
    {
        ZConversation *lastConversation = (ZConversation *)object;
        
        if (self.commentListCached == nil) {
            self.commentListCached = [[[NSMutableArray alloc] init] autorelease];
        }
        
        for (ZStatus *status in lastConversation.statusList) {
            
            BOOL alreadyExist = NO;
            for (ZStatus *statusInCache in self.commentListCached)
            {
                if (statusInCache.statusID == status.statusID)
                    alreadyExist = YES;
            }
            
            //如果self.article是评论的话
            if (self.article.inReplyToStatusId != nil)
            {
                if (status.statusID == [self.article.inReplyToStatus integerValue])
                {
                    [lastConversation.statusList removeObject:status];
                    
                    continue;
                }
            }
            else if (status.statusID == self.article.statusID) {
                
                [lastConversation.statusList removeObject:status];
                
                continue;
            }
                    
            if (!alreadyExist)
                [self.commentListCached addObject:status];
        }
        
        if ([self.conversation.statusList count] == 0) {
            self.conversation = lastConversation;
            
            [self getDarenList];
            
            [self initCommentTableView:self.conversation];
        }
        else {

            self.conversation.statusList = [[self.commentListCached copy] autorelease];
            
            [self getDarenList];
            
            [self resizeCommentTableView:self.conversation];
            
            //如果评论列表没有增长，说明已经请求完所有服务器的文章
            if (commentCountBeforeLoading == [self.commentListCached count] 
                && commentCountBeforeLoading == [self.conversation.statusList count]) 
            {
                [[ZAppDelegate sharedAppDelegate] showInformation:self.view info:NSLocalizedString(@"沒有更多评论了", @"")];
            }
        }
    }
    
    else if ([string hasPrefix:[NSString stringWithFormat:@"%@%@",DICT_PATH,DICTIONARY]])
    {
        self.word = (ZWord *)object;
        
        if (self.word.Key == nil)
            self.word.Key = (self.selectedWord ? self.selectedWord : @"");
        
        [self showWordOnLabel];
    }
}

- (void)objectLoader:(RKObjectLoader*)objectLoader didFailWithError:(NSError*)error {
    
    NSString *string = [objectLoader.URL absoluteString];
    
    if ([string hasPrefix:[NSString stringWithFormat:@"%@%@",DICT_PATH,DICTIONARY]])
    {
        if ([self.selectedWord length]) {
            wordLabel.text = self.selectedWord;
            accetationLabel.text = NSLocalizedString(@"单词查找失败",@"");
            self.word = nil;
        }
        
        [self delayDidWordPanelShow:nil];
    }
    else if ([string hasPrefix:[NSString stringWithFormat:@"%@%@",MAIN_PATH,STATUS_UPDATE]]) {
        
        [[ZAppDelegate sharedAppDelegate] setProgress:self.view progress:1.0 info:NSLocalizedString(@"评论发送失败",@"")];
    }
    else if ([string hasPrefix:[NSString stringWithFormat:@"%@/statusnet/conversation", MAIN_PATH]])
    {
        [[ZAppDelegate sharedAppDelegate] showNetworkFailed:self.view];
        [self.commentTableView reloadData];
    }
}

- (void)request:(RKRequest *)request didFailLoadWithError:(NSError *)error {
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [[ZAppDelegate sharedAppDelegate] showNetworkFailed:self.view];
}


- (void)getDarenList {
    
    self.darenList = [[[NSMutableArray alloc] init] autorelease];
    
    ZStatus *firstDaren = nil;
    ZStatus *secondDaren = nil;
    ZStatus *thirdDaren = nil;
    
    for (ZStatus *status in self.conversation.statusList)
    {
        //大于等于4个赞的才有资格
        if (status.favoritesCount < 4)
            continue;
        
        if (status.favoritesCount > firstDaren.favoritesCount) {
            thirdDaren = secondDaren;
            secondDaren = firstDaren;
            firstDaren = status;
        }
        else if (status.favoritesCount > secondDaren.favoritesCount) {
            thirdDaren = secondDaren;
            secondDaren = status;
        }
        else if (status.favoritesCount > thirdDaren.favoritesCount) {
            thirdDaren = status;
        }
    }
    
    if (firstDaren != nil)
        [self.darenList addObject:firstDaren];
    
    if (secondDaren != nil)
        [self.darenList addObject:secondDaren];
    
    if (thirdDaren != nil)
        [self.darenList addObject:thirdDaren];
}

#pragma mark * UI Actions

- (void)back {
    
    if ([self.player isAudioPlaying]) 
    {
        [self retainAudioPlayingWebViewControllerInstance];
    }
    
    [AudioCommentCell stopAudioPlaying];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)shareByActivity {
    
    NSString *text = [ZStatus revertStatusText:self.article.text];
    
    if ([text length] == 0)
        return;
    
    [self shareToSNS:text];
}

- (void)shareToSNS:(NSString *)text
{
    if ([text length] == 0)
        return;
    
    NSArray *activityItems;
    NSURL *url = [NSURL URLWithString:NSLocalizedString(@"rate url", @"")];
    
    if (self.coverImageView.image != nil) {
        activityItems = @[text, self.coverImageView.image, url];
    } else {
        activityItems = @[text, url];
    }
    
    UIActivityViewController *activityController =
    [[UIActivityViewController alloc] initWithActivityItems:activityItems
                                      applicationActivities:nil];
    
    [self presentViewController:activityController
                       animated:YES completion:nil];
}

- (BOOL)needUserLogin:(id)callbackDelegate
{
    if ([UserAccount getUserName] == nil) {
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            
            UserLoginViewController *userLoginVC = [[[UserLoginViewController alloc] init]autorelease];
            userLoginVC.delegate = callbackDelegate;
            [self presentModalViewController:userLoginVC animated:YES];
        }
        else {
            UserLoginViewController_iPad *userLoginVC = [[[UserLoginViewController_iPad alloc] init]autorelease];
            userLoginVC.delegate = callbackDelegate;
            [self presentModalViewController:userLoginVC animated:YES];
        }
        
        return YES;
    }
    
    return NO;
}

- (IBAction)favoriteButtonClicked:(UIButton *)sender {
    
    if ([self needUserLogin:nil])
        return;
    
    UIButton *button = sender;
    
    NSString *statusId = [NSString stringWithFormat:@"%d",self.article.statusID];
    
    if (statusId == nil) {
        return ;
    }
    
    if (self.article.isFavorited)
    {
        [DreamingAPI deleteFavorite:statusId onDidLoadResponse:^(RKResponse *response) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [button setImage:[UIImage imageNamed:@"favorite_off"] forState:UIControlStateNormal];
                article.isFavorited = NO;
            });
        }
          onDidFailLoadWithError:^(NSError *error) {
              dispatch_async(dispatch_get_main_queue(), ^{
                  [[ZAppDelegate sharedAppDelegate] showInformation:self.view info:NSLocalizedString(@"取消喜爱失败", @"")];
              });
          }];
    }
    else
    {
        [DreamingAPI createFavorite:statusId onDidLoadResponse:^(RKResponse *response) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [button setImage:[UIImage imageNamed:@"favorite_on"] forState:UIControlStateNormal];
                article.isFavorited = YES;
            });
        }
          onDidFailLoadWithError:^(NSError *error) {
              dispatch_async(dispatch_get_main_queue(), ^{
                  [[ZAppDelegate sharedAppDelegate] showInformation:self.view info:NSLocalizedString(@"添加喜爱失败", @"")];
              });
          }];
    }
}


- (IBAction)coverButtonClicked:(id)sender {

    NSString* videoUrlString = [ZStatus getVideoUrl:self.article];
    if ([videoUrlString length] > 0) {
        
        [self playVideoNow];
        
        return ;
    }
    
    NSString* coverUrlString = [ZStatus getCoverImageUrl:self.article];
    if ([coverUrlString length] == 0) {
        return ;
    }
    
    ZPhoto *photo = [[ZPhoto alloc] initWithImageURL:[NSURL URLWithString:coverUrlString]];
    ZPhotoSource *source = [[ZPhotoSource alloc] initWithPhotos:[NSArray arrayWithObjects:photo, nil]];
    
    EGOPhotoViewController *photoController = [[EGOPhotoViewController alloc] initWithPhotoSource:source];
    [self.navigationController pushViewController:photoController animated:YES];
    
    [photoController release];
    [photo release];
    [source release];
}

- (void)playVideoNow
{
    NSString* videoUrlString = [ZStatus getVideoUrl:self.article];
    if ([videoUrlString length] == 0) {
        return ;
    }
    
    MovieViewController *videoPlayer = [[MovieViewController alloc] initWithContentURL:
                                        [NSURL URLWithString:videoUrlString]];
    
    [videoPlayer shouldAutorotateToInterfaceOrientation:YES];
    
    [self presentMoviePlayerViewControllerAnimated:videoPlayer];
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    //[super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)setRefreshComment
{
    [DreamingAPI getConversation:[NSString stringWithFormat:@"%d", self.article.conversationID]
                         page:0
                       length:20
                     delegate:self
                useCacheFirst:NO];
}

#pragma mark touch

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    [self.commentView resignFirstResponder];
}

#pragma mark ZTextFieldDelegate

- (void)ZTextFieldButtonDidClicked:(ZTextField *)sender {
    
    ZTextField *text= sender;
    
    if ([text.textView.text length] == 0) {
        
        [[ZAppDelegate sharedAppDelegate] showInformation:self.view info:NSLocalizedString(@"评论不能为空",@"" ) ];
        
        return;
    }
    
    self.textCommentString = text.textView.text;
    
    [self.commentView resignFirstResponder];
    
    if (![self needUserLogin:self]) {
        
        [self postCommentToServer];
    }
}

- (void)ZTextFieldSoundRecordButtonClicked {
    
    [_audioPlayingInstance.player pausePlaying];
    [self.player pausePlaying];
    [AudioCommentCell stopAudioPlaying];
    
    [SoundRecorder shareInstance].delegate = self;
    
    [[SoundRecorder shareInstance] startSoundRecord:self.view];
}

- (void)ZTextFieldSoundRecordButtonTouchup {
    
    [[SoundRecorder shareInstance] stopSoundRecordView:self.view];
}

- (void)ZTextFieldKeyboardPopup:(ZTextField *)sender {
    
    self.contentScrollView.userInteractionEnabled = NO;
}

- (void)ZTextFieldKeyboardDrop:(ZTextField *)sender {
    
    self.contentScrollView.userInteractionEnabled = YES;
}


#pragma mark audio player

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (void)remoteControlReceivedWithEvent:(UIEvent *)event
{
    if (event.type != UIEventTypeRemoteControl) {
        return;
    }
    
    switch (event.subtype) {
        case UIEventSubtypeRemoteControlPause:
            break;
        case UIEventSubtypeRemoteControlPlay:    
            break;
        case UIEventSubtypeRemoteControlStop:
            break;
        case UIEventSubtypeRemoteControlTogglePlayPause:
        {
            if (_audioPlayingInstance.player != nil) {
                [_audioPlayingInstance.player startOrPauseAudioPlaying];
            }
            else {
                [self.player startOrPauseAudioPlaying];
            }
            
            break;
        }
            
        default:
            break;
    }
}


#pragma mark -
#pragma mark Location Manager

- (void)getLocation
{
    if ([ZAppDelegate sharedAppDelegate].userLocation != nil)
        return;
    
    // if location services are restricted do nothing
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied ||
        [CLLocationManager authorizationStatus] == kCLAuthorizationStatusRestricted )
    {
        [self performSelector:@selector(showLocationError) withObject:nil afterDelay:0.8];
        
        return;
    }
    
    self.locationManager = [[[CLLocationManager alloc] init] autorelease];
    [locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    [locationManager setDelegate:self];
    [locationManager startUpdatingLocation];
}

- (void)showLocationError
{
    NSInteger showLocationErrorCount = [[NSUserDefaults standardUserDefaults] integerForKey:@"showLocationErrorCount"];
    
    //为防止每次都提示打扰用户，这里以showLocationErrorCount为判断
    if (showLocationErrorCount > 1)
        return;

    [[NSUserDefaults standardUserDefaults] setInteger:showLocationErrorCount + 1 forKey:@"showLocationErrorCount"];
    
    [[ZAppDelegate sharedAppDelegate] showInformation:self.view info:@"获取位置失败，打开定位后可以找到身边的童鞋哦～"];
}


//a new location value is available
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {
    
    [ZAppDelegate sharedAppDelegate].userLocation = newLocation;
    
    if (self.placename == nil && !_performingCoordinateGeocode) {
        [self performCoordinateGeocode];
        
        _performingCoordinateGeocode = YES;
    }
    
    [self.locationManager stopUpdatingLocation];
}

//the location manager was unable to retrieve a location value
- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error {
    
}

- (void)performCoordinateGeocode
{
    CLLocationCoordinate2D locationCoordinate = [ZAppDelegate sharedAppDelegate].userLocation.coordinate;
    
    if (locationCoordinate.latitude == 0.0 && locationCoordinate.longitude == 0.0)
        return;
    
    CLGeocoder *geocoder = [[[CLGeocoder alloc] init] autorelease];
    
    CLLocation *location = [[[CLLocation alloc] initWithLatitude:locationCoordinate.latitude longitude:locationCoordinate.longitude] autorelease];
    
    //标志位防止提交多次
    __block BOOL isUpdatingLocation = NO;
    
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error || [placemarks count] == 0) {
            return;
        }
        
        CLPlacemark *placemark = [placemarks objectAtIndex:0];
        
        NSString *locality = [placemark performSelector:NSSelectorFromString(@"locality")];
        NSString *subLocality = [placemark performSelector:NSSelectorFromString(@"subLocality")];
        NSString *name = [placemark performSelector:NSSelectorFromString(@"name")];
        
        //优先使用locality＋subLocality作为位置名称，其次使用name
        if (locality == nil) {
            self.placename = name;
        }
        else
        {
            self.placename = locality;
            
            if (subLocality != nil)
            {
                self.placename = self.placename == nil ? subLocality : [self.placename stringByAppendingString:subLocality];
            }
        }
        
        if (!isUpdatingLocation) {
            [DreamingAPI updateProfile:nil
                            blogUrl:nil
                           location:self.placename
                        description:nil
                           delegate:nil];
            
            isUpdatingLocation = YES;
        } 
    }];
}


@end
