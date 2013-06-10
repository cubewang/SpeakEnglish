    //
//  BaseTableViewController.m
//  Dreaming
//
//  Created by Cube on 11-5-4.
//  Copyright 2011 Dreaming Team. All rights reserved.
//

#import "MovieViewController.h"
#import "BaseTableViewController.h"
#import "WebViewController.h"
#import "GlobalDef.h"
#import "UserAccount.h"
#import "ZPhoto.h"
#import "ZPhotoSource.h"
#import "EGOPhotoViewController.h"
#import "ZAppDelegate.h"
#import "DDLog.h"
#import "SearchWebViewController.h"
#import "TagDetailsController.h"

static const int ddLogLevel = LOG_FLAG_ERROR;

@implementation BaseTableViewController

@synthesize statusItems;
@synthesize baseTableView = _baseTableView;

@synthesize lastUpdateDate;

@synthesize refreshHeaderView = _refreshHeaderView;

- (void)dealloc {
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [[RKClient sharedClient].requestQueue cancelRequestsWithDelegate:self];
    
    self.baseTableView = nil;
    self.statusItems = nil;
    self.statusItems = nil;
    
    [statusItemsCached release];
    
    [_refreshHeaderView release];
    self.lastUpdateDate = nil;
    
    [super dealloc];
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {

    [super viewDidLoad];
    
    _needRefreshed = NO;
    statusCountBeforeLoading = 0;
    
    CGRect rc = self.view.frame;
    rc.origin.y = 0;
    rc.size.height -= 44;
    
    self.baseTableView = [[[UITableView alloc] initWithFrame:rc 
                                                       style:UITableViewStylePlain] autorelease];
    self.baseTableView.delegate = self;
    self.baseTableView.dataSource = self;
    [self.view addSubview:self.baseTableView];
    
    self.baseTableView.scrollsToTop = YES;
    
    // Configure the table view.
    self.baseTableView.rowHeight = 70;
    self.baseTableView.backgroundColor = CELL_BACKGROUND;
    self.baseTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.baseTableView.showsVerticalScrollIndicator = YES;
    self.baseTableView.userInteractionEnabled = YES;
    
    if (_refreshHeaderView == nil) {
        EGORefreshTableHeaderView *view = [[[EGORefreshTableHeaderView alloc] 
                                           initWithFrame: CGRectMake(0.0f, -60, SCREEN_WIDTH, 60)] autorelease];
        view.delegate = self;
        
        self.refreshHeaderView = view;
    }
    
    [self.baseTableView insertSubview:self.refreshHeaderView atIndex:0];
    
    [_refreshHeaderView refreshLastUpdatedDate];

    
    if (statusItems == nil) {
        statusItems = [[NSMutableArray alloc] init];
    }
    
    if (statusItemsCached == nil) {
        statusItemsCached = [[NSMutableArray alloc] init];
    }
    
    [self getArticleList:-1 length:SECTION_LENGTH useCacheFirst:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    if (_needRefreshed)
    {
        [self refresh];
    }
}

- (void)enforceRefresh
{
    [_refreshHeaderView enforceRefresh:self.baseTableView];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    // Release any retained subviews of the main view.
}


#pragma mark RKObjectLoaderDelegate methods

- (void)request:(RKRequest*)request didLoadResponse:(RKResponse*)response {
}

- (void)objectLoader:(RKObjectLoader*)objectLoader didLoadObjects:(NSArray*)objects {
    
    if ([objects count] > 0 && ![[objects lastObject] isKindOfClass:[ZStatus class]]) {
        return;
    }
    
    for (ZStatus *status in objects)
    {
        //如果是activity，跳过
        if ([status.sourceFrom isEqualToString:@"activity"])
            continue;
        
        //如果Status已存在，跳过
        BOOL isStatusDuplicate = NO;
        for (ZStatus *s in statusItemsCached) {
            if (s.statusID == status.statusID) {
                isStatusDuplicate = YES;
                break;
            }
        }
        if (isStatusDuplicate)
            continue;
        
        //如果是评论的话
        if (status.inReplyToStatusId != nil)
            continue;
        
        status.text = [ZStatus formatStatusText:status.text];
        [ZStatus separateTags:status];
        
        if (status.attachments == nil && status.retweetedStatusAttachments != nil) {
            status.attachments = status.retweetedStatusAttachments;
            status.retweetedStatusAttachments = nil;
        }
        
        [statusItemsCached addObject:status];
    }
    
    if ([statusItemsCached count] == 0) //statusItems没有内容
    {
        self.statusItems = [statusItemsCached copy];
        [self.statusItems release];
        
        [statusItemsCached removeAllObjects];
        
        if (_needRefreshed)
        {
            _needRefreshed = NO;
        }
        
        [self.baseTableView reloadData];
        [self doneLoadingTableViewData];
        
        return;
    }
    
    //如果statusItems没有增长，说明已经请求完所有服务器的文章
    if (statusCountBeforeLoading == [statusItemsCached count] 
        && statusCountBeforeLoading == [statusItems count]) 
    {
        [[ZAppDelegate sharedAppDelegate] showInformation:self.view info:NSLocalizedString(@"沒有更多內容了", @"")];
    }
    
    self.statusItems = [[statusItemsCached copy] autorelease];
    
    [self.baseTableView reloadData];
    
    if (_needRefreshed)
    {
        _needRefreshed = NO;
    }
    
    [self doneLoadingTableViewData];
    
    if (!objectLoader.response.wasLoadedFromCache)
        self.lastUpdateDate = [NSDate date];
}

- (void)objectLoader:(RKObjectLoader*)objectLoader didFailWithError:(NSError*)error {

    [self processRequestError];
}

- (void)request:(RKRequest *)request didFailLoadWithError:(NSError *)error {
    
    [self processRequestError];
}

- (void)objectLoaderDidLoadUnexpectedResponse:(RKObjectLoader *)objectLoader {
    
    [self processRequestError];
}

- (void)requestDidTimeout:(RKRequest *)request {
    
    [self processRequestError];
}

- (void)processRequestError {
    
    [[ZAppDelegate sharedAppDelegate] showNetworkFailed:self.view];
    
    _needRefreshed = YES;
    
    [self doneLoadingTableViewData];
    [self.baseTableView reloadData];
}


#pragma mark -
#pragma mark UI Action

//用户头像按钮点击事件处理，根据tag取得被点击的CELL，进而获得用户的Id
- (IBAction)avatarButtonClicked:(id)sender {
}

- (IBAction)coverButtonClicked:(id)sender {
    UIButton *clickedButton = (UIButton*)sender;
    
    ZStatus *status = [statusItems count] > clickedButton.tag ? [statusItems objectAtIndex:clickedButton.tag] : nil;
    
    NSString* videoUrlString = [ZStatus getVideoUrl:status];
    if ([videoUrlString length] > 0) {
        [self videoUrlButtonClicked:sender];
        return;
    }
}

- (IBAction)favoriteButtonClicked:(id)sender {
    
    UIButton *button = sender;
    
    ZStatus *status = [self.statusItems count] > button.tag ? [self.statusItems objectAtIndex:button.tag] : nil;
    
    if (status == nil)
        return;
    
    NSString *statusId = [NSString stringWithFormat:@"%d",status.statusID];
    
    if (status.isFavorited) {
        
        [DreamingAPI deleteFavorite:statusId onDidLoadResponse:^(RKResponse *response) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [button setImage:[UIImage imageNamed:@"favorite_off_timeline"] forState:UIControlStateNormal];
                status.isFavorited = NO;
                if (status.favoritesCount != 0)
                    status.favoritesCount -= 1;
            });
        }
          onDidFailLoadWithError:^(NSError *error) {
              dispatch_async(dispatch_get_main_queue(), ^{
                  [[ZAppDelegate sharedAppDelegate] showInformation:self.view info:NSLocalizedString(@"取消赞失败", @"")];
              });
          }];
    }
    else {
        
        [DreamingAPI createFavorite:statusId onDidLoadResponse:^(RKResponse *response) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [button setImage:[UIImage imageNamed:@"favorite_on_timeline"] forState:UIControlStateNormal];
                status.isFavorited = YES;
                status.favoritesCount += 1;
            });
        }
          onDidFailLoadWithError:^(NSError *error) {
              dispatch_async(dispatch_get_main_queue(), ^{
                  [[ZAppDelegate sharedAppDelegate] showInformation:self.view info:NSLocalizedString(@"添加赞失败了", @"")];
              });
          }];
    }
}


- (IBAction)videoUrlButtonClicked:(id)sender
{
    UIButton *button = sender;
    
    ZStatus *status = [self.statusItems count] > button.tag ? [self.statusItems objectAtIndex:button.tag] : nil;
    
    if (status == nil)
        return;
    
    NSString* videoUrlString = [ZStatus getVideoUrl:status];
    if ([videoUrlString length] == 0) {
        return ;
    }
    
    MovieViewController *videoPlayer = [[MovieViewController alloc] initWithContentURL:
                                        [NSURL URLWithString:videoUrlString]];
    
    [videoPlayer shouldAutorotateToInterfaceOrientation:YES];
    
    [self presentMoviePlayerViewControllerAnimated:videoPlayer];
}

- (IBAction)audioUrlButtonClicked:(id)sender
{
    UIButton *button = sender;
    
    ZStatus *status = [self.statusItems count] > button.tag ? [self.statusItems objectAtIndex:button.tag] : nil;
    
    WebViewController *webViewController = [WebViewController createWebViewController:status baseTableViewControllerDelegate:self];
    webViewController.shouldAutoPlayAudio = YES;
    
    [self.navigationController pushViewController:webViewController animated:YES];
    
    [webViewController release];
}


//文章标签按钮事件处理
- (IBAction)tagButtonClicked:(id)sender {
    
    UIButton *clickedButton = (UIButton*)sender;
    
    NSString *tag = [clickedButton titleForState:UIControlStateNormal];
    tag = [tag stringByReplacingOccurrencesOfString:@"#" withString:@""];
    
    TagDetailsController *tagDetailsController = [[[TagDetailsController alloc] init] autorelease];
    tagDetailsController.articleTag = tag;
    
    [self.navigationController pushViewController:tagDetailsController animated:YES];
}


#pragma mark -
#pragma mark Table view data source

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (statusItems.count == 0) 
        return 0;
    
    return statusItems.count + 1;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    if (indexPath.row == [statusItems count]) {
        
        UITableViewCell *cell = [[[UITableViewCell alloc] 
                 initWithStyle:UITableViewCellStyleDefault 
                 reuseIdentifier:nil] autorelease];
        
        cell.textLabel.text = NSLocalizedString(@"显示下20条", @"");
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
    
    static NSString *cellIdentifier = @"RTTableViewCell";
    
    RTTableViewCell *tableViewCell = (RTTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (tableViewCell == nil)
    {
        tableViewCell = [[RTTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
	
        // set selection color 
        UIView *backgroundView = [[UIView alloc] initWithFrame:tableViewCell.frame]; 
        backgroundView.backgroundColor = SELECTED_BACKGROUND;
        tableViewCell.selectedBackgroundView = backgroundView; 
        [backgroundView release];
    }
    
    // Configure the cell.
    ZStatus *status = [statusItems count] == 0 ? nil : [statusItems objectAtIndex:indexPath.row];
    if (status) {
        [tableViewCell setDataSource:status];
        [tableViewCell setAvatarImageUrl:status.user.profileImageUrl 
                                   tagId:indexPath.row 
                                  target:self 
                                  action:@selector(avatarButtonClicked:)];
        [tableViewCell setCoverImageUrl:[ZStatus getCoverImageUrl:status]
                                  tagId:indexPath.row
                                 target:self
                                 action:@selector(coverButtonClicked:)];
        [tableViewCell setVideoUrl:[ZStatus getVideoUrl:status]
                                  tagId:indexPath.row
                                 target:self
                                 action:@selector(videoUrlButtonClicked:)];
        [tableViewCell setAudioUrl:[ZStatus getAudioUrl:status]
                             tagId:indexPath.row
                            target:self
                            action:@selector(audioUrlButtonClicked:)];
        [tableViewCell setArticleTags:status.statusTags 
                               target:self 
                               action:@selector(tagButtonClicked:)];
    }
    
    return tableViewCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row >= [statusItems count])
        return 60;
    
    ZStatus *status = [statusItems count] == 0 ? nil : [statusItems objectAtIndex:indexPath.row];
    if (status) {
        return [RTTableViewCell rowHeightForObject:status];
    }
    else {
        return 0.0;
    }
}


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Deselect
    [self.baseTableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == [statusItems count]) {
        
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        if (cell) {
            
            [(UIActivityIndicatorView *)[cell viewWithTag:200] startAnimating];
            cell.textLabel.text = NSLocalizedString(@"加载中...", @"");
        }

        ZStatus *lastStatus = (ZStatus*)[statusItems lastObject];
        
        //请求statusItems后面SECTION_LENGTH长度的文章列表
        [self getArticleList:lastStatus.statusID length:SECTION_LENGTH useCacheFirst:NO];
        
        statusCountBeforeLoading = [statusItems count];
        
        return;
    }
    
    // Show detail
    WebViewController *webViewController = [WebViewController createWebViewController:[statusItems objectAtIndex:indexPath.row] baseTableViewControllerDelegate:self];
    [self.navigationController pushViewController:webViewController animated:YES]; 
    [webViewController release];
}


#pragma mark -
#pragma mark BaseTableViewControllerDelegat

- (void)setTableNeedRefreshed:(BOOL)needRefreshed
{
    _needRefreshed = needRefreshed;
}


// Reset and reparse
- (void)refresh {
    
    if (statusItemsCached)
    {
        [statusItemsCached removeAllObjects];
        statusCountBeforeLoading = 0;
    }
    
    [self getArticleList:-1 length:SECTION_LENGTH useCacheFirst:NO];
}

- (BOOL)getArticleList:(NSInteger)maxId length:(NSInteger)length useCacheFirst:(BOOL)useCacheFirst
{
    return NO;
}

#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {	
	
    [_refreshHeaderView egoRefreshScrollViewDidScroll:(UITableView *)scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
	
    [_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
	
}

#pragma mark -
#pragma mark Data Source Loading / Reloading Methods

- (void)reloadTableViewDataSource {
	
    //  should be calling your tableviews data source model to reload
    //  put here just for demo
    [self refresh];
}

- (void)delayDidFinishedLoading
{
    //  model should call this when its done loading
	_reloading = NO;
    
    [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.baseTableView];
}

- (void)doneLoadingTableViewData {
	
    [self performSelector:@selector(delayDidFinishedLoading) 
               withObject:nil 
               afterDelay:.5];
}

#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view {
	
	[self reloadTableViewDataSource];
	
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view {
	
	return _reloading; // should return if data source model is reloading
	
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view {
    //this maybe overwrite by subclass
    if (self.lastUpdateDate == nil) {
        self.lastUpdateDate = [[NSUserDefaults standardUserDefaults] objectForKey:kLastUpdateDate];
    }
    
	return self.lastUpdateDate;
}

@end
