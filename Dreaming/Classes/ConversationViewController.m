//
//  ConversationViewController.m
//  Dreaming
//
//  Created by Cube on 13-1-31.
//  Copyright 2013 Dreaming Team. All rights reserved.
//

#import <MessageUI/MessageUI.h>
#import <MapKit/MapKit.h>

#import "WebViewController.h"
#import "ConversationViewController.h"
#import "UserLoginViewController.h"
#import "UserLoginViewController_iPad.h"
#import "EGOPhotoViewController.h"
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


@interface ConversationViewController() {
    
    BOOL _performingCoordinateGeocode;
}

@property (nonatomic, retain) ZStatus *operatingComment;

@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, retain) NSString *placename;

@end


@implementation ConversationViewController


@synthesize originalStatus;
@synthesize replyToMeStatus;
@synthesize myStatus;
@synthesize myReplyingStatuses;

@synthesize operatingComment;

@synthesize contentScrollView;
@synthesize articleView;
@synthesize articleSignature;

@synthesize player;
@synthesize coverImageView;
@synthesize coverButton;

@synthesize commentTableView;
@synthesize textCommentString;
@synthesize commentView;

@synthesize swipeRightRecognizer;

@synthesize locationManager;
@synthesize placename;


- (void)dealloc {
    
    [[RKClient sharedClient].requestQueue cancelRequestsWithDelegate:self];
    
    self.originalStatus = nil;
    self.replyToMeStatus = nil;
    self.myStatus = nil;
    self.myReplyingStatuses = nil;
    
    self.operatingComment = nil;
    
    self.contentScrollView = nil;
    self.articleView = nil;
    self.articleSignature = nil;
    
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
    
    self.locationManager = nil;
    self.placename = nil;
    
    [SoundRecorder shareInstance].delegate = nil;
    
    [super dealloc];
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.contentScrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    UIButton *buttonLeft = [[[UIButton alloc] initWithFrame:CGRectMake(5, 0, 44, 44)] autorelease];
    [buttonLeft setImage:[UIImage imageNamed:@"back@2x"] forState:UIControlStateNormal];
    [buttonLeft addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *itemLeft = [[[UIBarButtonItem alloc] initWithCustomView:buttonLeft] autorelease]; 
    
    self.navigationItem.leftBarButtonItem = itemLeft;

    [self initCommentView];
    [self loadArticle:self.originalStatus];
    [self getLocation];
    
    [SoundRecorder shareInstance].delegate = self;
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
    
    self.contentScrollView.contentSize = CGSizeMake(SCREEN_WIDTH, top + self.articleView.frame.size.height + kTableCellSmallMargin);
    
    CGRect signatureRect = self.articleSignature.frame;
    signatureRect.origin.y = self.contentScrollView.contentSize.height;
    self.articleSignature.frame = signatureRect;
    
    self.contentScrollView.contentSize = 
    CGSizeMake(SCREEN_WIDTH, self.contentScrollView.contentSize.height + signatureRect.size.height);
}


- (void)initCommentTableView
{
    if (self.replyToMeStatus == nil)
        return;
    
    CGFloat tableHeight = [self tableHeightForObject];
    
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

- (void)resizeCommentTableView
{
    CGFloat tableHeight = [self tableHeightForObject];
    
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
        
        [self.commentView changeButtonText:[NSString stringWithFormat:NSLocalizedString(@"按住，回复%@", @""), self.replyToMeStatus.user.name]];
        
        [self.view addSubview:self.commentView];
    }
}

- (void)postCommentToServer {
    
    [[ZAppDelegate sharedAppDelegate] showProgress:self.view info:NSLocalizedString(@"发送中", @"")];
    [[ZAppDelegate sharedAppDelegate] setProgress:self.view progress:0.2 info:NSLocalizedString(@"发送中", @"")];
    
    NSInteger statusId = self.replyToMeStatus.statusID;
    
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
}

- (void)postAudioComment:(BOOL)isAudioComment {
    
    audioComment = isAudioComment;
    
    if (![self needUserLogin:self]) {

        [self postCommentToServer];
    }
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
    
    if (self.swipeRightRecognizer == gestureRecognizer) {
        return YES;
    }
    
    return NO;
}

- (IBAction)handleSwipeFrom:(UISwipeGestureRecognizer *)recognizer {
    
    if (recognizer.direction == UISwipeGestureRecognizerDirectionRight) {
        [self back];
    }
}


#pragma mark -
#pragma mark Comment Cell Action

- (IBAction)commentCellButtonAction:(UIButton *)sender {
    
    if ([self needUserLogin:nil])
        return;
    
    UIButton *clickedButton = (UIButton*)sender;
    
    self.operatingComment = nil;
    
    if (self.myStatus != nil) {
        if (clickedButton.tag == 0) {
            self.operatingComment = self.myStatus;
        }
        else if (clickedButton.tag == 1) {
            self.operatingComment = self.replyToMeStatus;
        }
        else {
            self.operatingComment = [self.myReplyingStatuses objectAtIndex:clickedButton.tag - 2];
        }
    }
    else {
        if (clickedButton.tag == 0) {
            self.operatingComment = self.replyToMeStatus;
        }
        else if (clickedButton.tag == 1) {
            self.operatingComment = [self.myReplyingStatuses objectAtIndex:0];
        }
        else {
            self.operatingComment = [self.myReplyingStatuses objectAtIndex:clickedButton.tag - 1];
        }
    }
    
    if (self.operatingComment == nil)
        return;
    
    if ([[UserAccount getUserId] isEqualToString:[NSString stringWithFormat:@"%d",self.operatingComment.user.userID]]) {
        
        [self deleteComment];
    }
    else {

        UILabel *label = nil;
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:clickedButton.tag inSection:0];
        id cell = [self.commentTableView cellForRowAtIndexPath:indexPath];
        
        if ([cell isKindOfClass:[AudioCommentCell class]])
        {
            AudioCommentCell *audioCommentCell = (AudioCommentCell *)cell;
            label = audioCommentCell.favoriteCountLabel;
        }
        else if ([cell isKindOfClass:[TextCommentCell class]]) {
            TextCommentCell *textCommentCell = (TextCommentCell *)cell;
            label = textCommentCell.favoriteCountLabel;
        }
        
        [self commentCellFavoriteButtonClicked:clickedButton label:label];
    }
}

- (void)commentCellFavoriteButtonClicked:(UIButton *)sender label:(UILabel *)label {
    
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


#pragma mark -
#pragma mark StreamingPlayerStateChangedDelegate

- (void)streamingPlayerStateDidChange:(BOOL)isPlaying
{
    MainViewController* mainController = [[ZAppDelegate sharedAppDelegate] mainViewController];
    [mainController setAudioNowPlayingStatus:isPlaying];
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (self.myStatus == nil)
        return [self.myReplyingStatuses count] + 1;
    
    return [self.myReplyingStatuses count] + 2;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.myStatus == nil && indexPath.row > 0 && [self.myReplyingStatuses count] == 0)
        return nil;
    
    ZStatus *comment = nil;
    
    if (self.myStatus != nil) {
        if (indexPath.row == 0) {
            comment = self.myStatus;
        }
        else if (indexPath.row == 1) {
            comment = self.replyToMeStatus;
        }
        else {
            comment = [self.myReplyingStatuses objectAtIndex:indexPath.row - 2];
        }
    }
    else {
        if (indexPath.row == 0) {
            comment = self.replyToMeStatus;
        }
        else if (indexPath.row == 1) {
            comment = [self.myReplyingStatuses objectAtIndex:0];
        }
        else {
            comment = [self.myReplyingStatuses objectAtIndex:indexPath.row - 1];
        }
    }
    
    if ([self isAudioComment:comment])
    {
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
        [commentCell setDataSource:comment replyToStatus:nil];
        [commentCell setCommentDelegate:indexPath.row 
                                  target:self 
                                  action:@selector(commentCellButtonAction:)];
        
        if ([[UserAccount getUserId] integerValue] == comment.user.userID) {
            commentCell.backgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"my_comment_bg"]] autorelease];
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
        [commentCell setCommentDelegate:indexPath.row 
                                 target:self 
                                 action:@selector(commentCellButtonAction:)];
        
        return commentCell;
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.myStatus == nil && indexPath.row > 0 && [self.myReplyingStatuses count] == 0)
        return 0;
    
    ZStatus *comment = nil;
    
    if (self.myStatus != nil) {
        if (indexPath.row == 0) {
            comment = self.myStatus;
        }
        else if (indexPath.row == 1) {
            comment = self.replyToMeStatus;
        }
        else {
            comment = [self.myReplyingStatuses objectAtIndex:indexPath.row - 2];
        }
    }
    else {
        if (indexPath.row == 0) {
            comment = self.replyToMeStatus;
        }
        else if (indexPath.row == 1) {
            comment = [self.myReplyingStatuses objectAtIndex:0];
        }
        else {
            comment = [self.myReplyingStatuses objectAtIndex:indexPath.row - 1];
        }
    }
    
    return [self isAudioComment:comment] ?
    [AudioCommentCell heightForCell:comment replyToStatus:nil] :
    [TextCommentCell heightForCell:comment];
}


- (CGFloat)tableHeightForObject {
    
    CGFloat tableHeight = 0.0;
    
    if (self.myStatus != nil) {
        tableHeight += ([self isAudioComment:self.myStatus] ?
                        [AudioCommentCell heightForCell:self.myStatus replyToStatus:nil] :
                        [TextCommentCell heightForCell:self.myStatus]);
    }
    
    tableHeight += ([self isAudioComment:self.replyToMeStatus] ?
                    [AudioCommentCell heightForCell:self.replyToMeStatus replyToStatus:nil] :
                    [TextCommentCell heightForCell:self.replyToMeStatus]);
    
    for (ZStatus *status in self.myReplyingStatuses)
    {
        tableHeight += ([self isAudioComment:status] ?
                        [AudioCommentCell heightForCell:status replyToStatus:nil] :
                        [TextCommentCell heightForCell:status]);
    }
    
    return tableHeight;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Deselect
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


- (BOOL)isAudioComment:(ZStatus *)status {
    return [[ZStatus getAudioUrl:status] length] > 0;
}


- (void)loadArticle:(ZStatus *)status
{
    if (status == nil || status.text == nil)
        return;
    
    [self initControls:status];
    
    [self addTitleView];
    
    if ([self.replyToMeStatus.inReplyToStatusId integerValue] != self.originalStatus.statusID)
        [DreamingAPI getStatus:[self.replyToMeStatus.inReplyToStatusId stringValue]
                   delegate:self
              useCacheFirst:YES];
    
    [self initCommentTableView];
}


- (void)scrollToComment {
    
    [self resizeCommentTableView];
    
    CGPoint point = CGPointMake(0, self.articleView.contentSize.height);
    
    [self.contentScrollView setContentOffset:point animated:YES];
}

#pragma mark RKObjectLoaderDelegate methods

- (void)request:(RKRequest*)request didLoadResponse:(RKResponse*)response {

    NSString *string = [response.URL absoluteString];
    
    if ([string hasPrefix:[NSString stringWithFormat:@"%@%@", MAIN_PATH, STATUS_DELETE]]) {
        
        NSString* bodyString = [[[NSString alloc] initWithData:response.body encoding:NSUTF8StringEncoding] autorelease];
        
        if ([bodyString rangeOfString:@"error"].length > 0) {
            
            [[ZAppDelegate sharedAppDelegate] showInformation:self.view info:NSLocalizedString(@"评论删除失败", @"")];
        }
        else {
            [[ZAppDelegate sharedAppDelegate] showInformation:self.view info: NSLocalizedString(@"评论删除成功", @"")];
            
            [self back];
        }
    }
    else if ([string hasPrefix:[NSString stringWithFormat:@"%@%@", MAIN_PATH, STATUS_UPDATE]]) {
        
        if (response.statusCode == 200) {
            
            [[ZAppDelegate sharedAppDelegate] setProgress:self.view progress:1.0 info:NSLocalizedString(@"评论发送成功", @"")];
        }
        else {
            [[ZAppDelegate sharedAppDelegate] setProgress:self.view progress:1.0 info:NSLocalizedString(@"评论发送失败",@"")];
        }
    }
}


- (void)objectLoader:(RKObjectLoader *)objectLoader didLoadObject:(id)object {
    
    NSString *string = [objectLoader.URL absoluteString];
    
    if ([string hasPrefix:[NSString stringWithFormat:@"%@/statuses/show", MAIN_PATH]])
    {
        ZStatus *status = (ZStatus *)object;
        
        if (status != nil) {
            self.myStatus = status;
            
            [self resizeCommentTableView];
        }
    }
    else if ([string hasPrefix:[NSString stringWithFormat:@"%@%@", MAIN_PATH, STATUS_UPDATE]])
    {
        ZStatus *status = (ZStatus *)object;
        
        if (self.myReplyingStatuses == nil) {
            self.myReplyingStatuses = [[[NSMutableArray alloc] init] autorelease];
        }
        
        [self.myReplyingStatuses addObject:status];
        
        [self scrollToComment];
    }
}

- (void)objectLoader:(RKObjectLoader*)objectLoader didFailWithError:(NSError*)error {
    
    NSString *string = [objectLoader.URL absoluteString];
    
    if ([string hasPrefix:[NSString stringWithFormat:@"%@%@", MAIN_PATH, STATUS_UPDATE]]) {
        
        [[ZAppDelegate sharedAppDelegate] setProgress:self.view progress:1.0 info:NSLocalizedString(@"评论发送失败",@"")];
    }
}

- (void)request:(RKRequest *)request didFailLoadWithError:(NSError *)error {
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [[ZAppDelegate sharedAppDelegate] showNetworkFailed:self.view];
}


#pragma mark * UI Actions

- (void)back {
    
    [self.player stopPlaying];
    
    [AudioCommentCell stopAudioPlaying];
    
    [self.navigationController popViewControllerAnimated:YES];
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


- (IBAction)coverButtonClicked:(id)sender {

    NSString* videoUrlString = [ZStatus getVideoUrl:self.originalStatus];
    if ([videoUrlString length] > 0) {
        
        [self playVideoNow];
        
        return ;
    }
    
    NSString* coverUrlString = [ZStatus getCoverImageUrl:self.originalStatus];
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
    NSString* videoUrlString = [ZStatus getVideoUrl:self.originalStatus];
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


#pragma mark touch

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    [self.commentView resignFirstResponder];
}

#pragma mark ZTextFieldDelegate

- (void)ZTextFieldButtonDidClicked:(ZTextField *)sender {
    
    ZTextField *text = sender;
    
    if ([text.textView.text length] == 0) {
        
        [[ZAppDelegate sharedAppDelegate] showInformation:self.view info:NSLocalizedString(@"评论不能为空",@"" )];
        
        return;
    }
    
    self.textCommentString = text.textView.text;
    
    [self.commentView resignFirstResponder];
    
    if (![self needUserLogin:self]) {
        
        [self postCommentToServer];
    }
}

- (void)ZTextFieldSoundRecordButtonClicked {
    
    [[WebViewController getAudioPlayingWebViewController].player pausePlaying];
    [self.player pausePlaying];
    [AudioCommentCell stopAudioPlaying];
    
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
        return;
    }
    
    self.locationManager = [[[CLLocationManager alloc] init] autorelease];
    [locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    [locationManager setDelegate:self];
    [locationManager startUpdatingLocation];
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
