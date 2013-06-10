    //
//  MainViewController.m
//  EnglishFun
//
//  Created by Cube on 12-08-16.
//  Copyright 2012 Dreaming Team. All rights reserved.
//

#import "MainViewController.h"
#import "WebViewController.h"
#import "NowplayEmptyViewController.h"

#import "GlobalDef.h"
#import "DreamingAPI.h"
#import "ZAppDelegate.h"


@interface MainViewController() {
    
    //广告条
    BOOL adPageControlIsChangingPage;
}

//广告条
@property (nonatomic, retain) UIScrollView *adScrollView;
@property (nonatomic, retain) UIPageControl* adPageControl;

@property (nonatomic, retain) NSMutableArray *appList;

@end


@implementation MainViewController

@synthesize settedTag, usedTag;
@synthesize audioPlayingButton;
@synthesize audioPlayingAnimation;
@synthesize adScrollView, adPageControl;
@synthesize appList;


- (void)dealloc {
    
    self.settedTag = nil;
    self.usedTag = nil;
    
    self.audioPlayingButton = nil;
    self.audioPlayingAnimation = nil;
    
    self.adScrollView = nil;
    self.adPageControl = nil;
    
    self.appList = nil;
    
    [super dealloc];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    
    if (self.settedTag == nil) {
        self.usedTag = @"";
    }
    else {
        self.usedTag = self.settedTag;
    }
    
    [super viewDidLoad];
    
    [self setNavigationBar];
    
    [self requestApps];
}


- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    if ([self.navigationController.navigationBar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)]) {
        
        NSString *imageName = [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone ? @"NavBar_ios5" :@"NavBar_iPad";
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:imageName] forBarMetrics:UIBarMetricsDefault];
    }
    
    [super viewWillAppear:animated];
}

- (void)addAdScrollView {
    
    int posterCount = [self.appList count];
    
    if (posterCount == 0)
        return;
    
    CGRect posterRect = CGRectMake(0, 0, CELL_CONTENT_WIDTH, AD_BAR_HEIGHT * CELL_CONTENT_WIDTH / 320);
    CGRect pageControlRect = CGRectMake(CELL_CONTENT_WIDTH - 126, AD_BAR_HEIGHT * CELL_CONTENT_WIDTH / 320 - 24, 126, 26);
    
    UIView *adView = [[[UIView alloc] initWithFrame:posterRect] autorelease];
    self.adScrollView = [[[UIScrollView alloc] initWithFrame:posterRect] autorelease];
    self.adPageControl = [[[UIPageControl alloc] initWithFrame:pageControlRect] autorelease];
    
    self.adScrollView.delegate = self;
    self.adScrollView.backgroundColor = CELL_BACKGROUND;
    self.adScrollView.canCancelContentTouches = NO;
    self.adScrollView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    self.adScrollView.clipsToBounds = YES;
    self.adScrollView.scrollEnabled = YES;
    self.adScrollView.pagingEnabled = YES;
    
    self.adScrollView.scrollsToTop = NO;
    
    self.adPageControl.backgroundColor = [UIColor clearColor];
    
    if ([UIPageControl instancesRespondToSelector:@selector(setPageIndicatorTintColor:)])
    {
        self.adPageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
        self.adPageControl.currentPageIndicatorTintColor = [UIColor darkGrayColor];
    }
    
    [adView addSubview:self.adScrollView];
    [adView addSubview:self.adPageControl];
    
    CGFloat cx = 0;
    for (int i = 1; i <= posterCount; i++)
    {
        ZStatus *app = [self.appList objectAtIndex:i - 1];
        
        UIImageView *imageView = [[[UIImageView alloc] initWithFrame:
                                   CGRectMake(cx, 0, CELL_CONTENT_WIDTH, AD_BAR_HEIGHT * CELL_CONTENT_WIDTH / 320)] autorelease];
        
        NSString *imageUrl = [ZStatus getCoverImageUrl:app];
        
        [imageView setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:nil];
        
        UIButton *imageButton = [[[UIButton alloc] initWithFrame:
                                  CGRectMake(cx, 0, CELL_CONTENT_WIDTH, AD_BAR_HEIGHT * CELL_CONTENT_WIDTH / 320)] autorelease];
        [imageButton addTarget:self action:@selector(imageButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
        [imageButton setTag:300 + i]; //Tag: 300+
        
        [self.adScrollView addSubview:imageView];
        [self.adScrollView addSubview:imageButton];
        
        cx += self.adScrollView.frame.size.width;
    }
    
    UIButton *closeButton = [[[UIButton alloc] initWithFrame:
                              CGRectMake(CELL_CONTENT_WIDTH - 28,
                                         (AD_BAR_HEIGHT * CELL_CONTENT_WIDTH / 320 - 20) / 2,
                                         20,
                                         20)] autorelease];
    [closeButton setBackgroundImage:[UIImage imageNamed:@"ad_close@2x"] forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(adCloseButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [adView addSubview:closeButton];
    
    self.baseTableView.tableHeaderView = adView;
    
    self.adPageControl.numberOfPages = posterCount;
    [self.adScrollView setContentSize:CGSizeMake(cx, self.adScrollView.bounds.size.height)];
}

- (void)setNavigationBar
{
    self.navigationController.view.layer.cornerRadius = 5;
    self.navigationController.view.layer.masksToBounds = YES;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {

        UIButton *buttonLeft = [[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 51, 30)] autorelease];
        [buttonLeft setImage:[UIImage imageNamed:@"ButtonMenu"] forState:UIControlStateNormal];
        [buttonLeft addTarget:self action:@selector(showLeft) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *itemLeft = [[[UIBarButtonItem alloc] initWithCustomView:buttonLeft] autorelease]; 
        
        self.navigationItem.leftBarButtonItem = itemLeft;
        
        UIButton *buttonRight = [[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 51, 30)] autorelease];
        [buttonRight setImage:[UIImage imageNamed:@"notification@2x"] forState:UIControlStateNormal];
        [buttonRight addTarget:self action:@selector(showRight) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *itemRight = [[[UIBarButtonItem alloc] initWithCustomView:buttonRight] autorelease];
        
        self.navigationItem.rightBarButtonItem = itemRight;
    }
    
    //设置导航条文字
    UILabel* label = [[ZAppDelegate createNavTitleView:NSLocalizedString(@"VOA慢速英语", @"")] autorelease];
    self.navigationItem.titleView = label;
    
    [self initNowPlayingView];
}

- (void)setNotification:(BOOL)hasNewNotification
{
    UIButton *buttonRight = (UIButton *)self.navigationItem.rightBarButtonItem.customView;
    
    [buttonRight setImage:hasNewNotification ? [UIImage imageNamed:@"notification_new@2x"] : [UIImage imageNamed:@"notification@2x"]
                 forState:UIControlStateNormal];
    
    if (hasNewNotification) {
        AudioServicesPlaySystemSound (kSystemSoundID_Vibrate);
    }
}

- (void)initNowPlayingView
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        CGRect buttonRect = self.view.frame;
        buttonRect.origin.x = 0;
        buttonRect.origin.y = buttonRect.size.height - 44 - 44;
        buttonRect.size.height = 44;
        buttonRect.size.width = 44;
        
        self.audioPlayingButton = [[[UIButton alloc] initWithFrame:buttonRect] autorelease];
        [self.audioPlayingButton setImage:[UIImage imageNamed:@"nowplaying@2x"] forState:UIControlStateNormal];
        //[self.audioPlayingButton setImage:[UIImage imageNamed:@"nowplaying_s@2x"] forState:UIControlStateSelected];
        [self.audioPlayingButton addTarget:self action:@selector(nowplayingButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        
        [self.view addSubview:self.audioPlayingButton];
    }
    else {
        self.audioPlayingButton = [[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 51, 30)] autorelease];
        [self.audioPlayingButton setImage:[UIImage imageNamed:@"nowplaying_iPad@2x"] forState:UIControlStateNormal];
        [self.audioPlayingButton addTarget:self action:@selector(nowplayingButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *itemRight = [[[UIBarButtonItem alloc] initWithCustomView:self.audioPlayingButton] autorelease];
        
        self.navigationItem.rightBarButtonItem = itemRight;
    }
    
    [self setAudioNowPlayingStatus:NO];
}

- (void)setAudioNowPlayingStatus:(BOOL)isPlayingAudio
{
    if (self.audioPlayingAnimation == nil) {
        
        self.audioPlayingAnimation = [[[UIImageView alloc] initWithFrame:self.audioPlayingButton.frame] autorelease];
        self.audioPlayingAnimation.backgroundColor = [UIColor clearColor];
        
        self.audioPlayingAnimation.animationImages = ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) ?
        [NSArray arrayWithObjects:
         [UIImage imageNamed:@"nowplaying@2x"],
         [UIImage imageNamed:@"nowplaying2@2x"],
         [UIImage imageNamed:@"nowplaying3@2x"],
         [UIImage imageNamed:@"nowplaying4@2x"], nil]
        :
        [NSArray arrayWithObjects:
         [UIImage imageNamed:@"nowplaying_iPad@2x"],
         [UIImage imageNamed:@"nowplaying_iPad2@2x"],
         [UIImage imageNamed:@"nowplaying_iPad3@2x"],
         [UIImage imageNamed:@"nowplaying_iPad4@2x"], nil];
        
        self.audioPlayingAnimation.animationDuration = 1.5;
        self.audioPlayingAnimation.animationRepeatCount = 0;
        
        [self.view addSubview:audioPlayingAnimation];
    }
    
    if (isPlayingAudio) {
        [self.audioPlayingAnimation startAnimating];
        [self.audioPlayingButton setImage:nil forState:UIControlStateNormal];
    }
    else {
        [self.audioPlayingAnimation stopAnimating];
        [self.audioPlayingButton setImage:([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) ?
         [UIImage imageNamed:@"nowplaying@2x"] : [UIImage imageNamed:@"nowplaying_iPad@2x"]
                                 forState:UIControlStateNormal];
    }
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)objectLoader:(RKObjectLoader*)objectLoader didLoadObjects:(NSArray*)objects {
    
    NSString *string = [objectLoader.URL absoluteString];
    
    if ([string hasPrefix:[NSString stringWithFormat:@"%@%@",MAIN_PATH,APPS_LIST]])
    {
        if ([objects count] == 0)
            return;
        
        self.appList = [[[NSMutableArray alloc] init] autorelease];
        
        for (ZStatus *app in objects)
        {
            if (![app.text isEqualToString:@"VOA慢速英语"])
                [self.appList addObject:app];
        }
        
        if (!objectLoader.response.wasLoadedFromCache) {

            [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:kLastNewAppCheckDate];
        }
        
        [self addAdScrollView];
        
        return;
    }
    
    [super objectLoader:objectLoader didLoadObjects:objects];
   
    if (!objectLoader.response.wasLoadedFromCache) {

        [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:kLastUpdateDate];
    }
}

- (void)objectLoader:(RKObjectLoader*)objectLoader didFailWithError:(NSError*)error {
    
    NSString *string = [objectLoader.URL absoluteString];
    
    if ([string hasPrefix:[NSString stringWithFormat:@"%@%@",MAIN_PATH,APPS_LIST]])
        return;
    
    [super objectLoader:objectLoader didFailWithError:error];
}

- (void)request:(RKRequest *)request didFailLoadWithError:(NSError *)error {
    
    NSString *string = [request.URL absoluteString];
    
    if ([string hasPrefix:[NSString stringWithFormat:@"%@%@",MAIN_PATH,APPS_LIST]])
        return;
    
    [super request:request didFailLoadWithError:error];
}

- (void)objectLoaderDidLoadUnexpectedResponse:(RKObjectLoader *)objectLoader {
    
    NSString *string = [objectLoader.URL absoluteString];
    
    if ([string hasPrefix:[NSString stringWithFormat:@"%@%@",MAIN_PATH,APPS_LIST]])
        return;
    
    [super objectLoaderDidLoadUnexpectedResponse:objectLoader];
}

- (void)requestDidTimeout:(RKRequest *)request {
    
    NSString *string = [request.URL absoluteString];
    
    if ([string hasPrefix:[NSString stringWithFormat:@"%@%@",MAIN_PATH,APPS_LIST]])
        return;
    
    [super requestDidTimeout:request];
}

- (void)setArticleTag:(NSString *)tag
{
    if (tag != nil)
    {
        self.settedTag = tag;
    
        //设置导航条文字
        UILabel* label = [ZAppDelegate createNavTitleView:tag];
        self.navigationItem.titleView = label;
        [label release];
    } 
    else 
    {
        //设置导航条文字
        UILabel* label = [ZAppDelegate createNavTitleView:NSLocalizedString(@"VOA慢速英语", @"")];
        self.navigationItem.titleView = label;
        [label release];
        
        self.settedTag = nil;
    }
    
    [self enforceRefresh];
}

#pragma mark timeline

- (BOOL)getArticleList:(NSInteger)maxId length:(NSInteger)length useCacheFirst:(BOOL)useCacheFirst
{
    if (self.settedTag != nil)
    {
        self.usedTag = self.settedTag;
        
        BOOL result = [DreamingAPI getTimeline:self.usedTag maxId:maxId length:length delegate:self useCacheFirst:useCacheFirst];
        
        return result;
    }
    
    BOOL res = [DreamingAPI getHomeTimeline:maxId length:length delegate:self useCacheFirst:useCacheFirst];
    
    return res;
}

- (void)requestApps
{
    NSDate *lastNewAppCheckDate = [[NSUserDefaults standardUserDefaults] objectForKey:kLastNewAppCheckDate];
    NSTimeInterval sec = [[NSDate date] timeIntervalSinceDate:lastNewAppCheckDate];
    
    //5天后向服务器请求最新App数据
    if (sec > 5*24*60*60)
    {
        [DreamingAPI getGoodApps:self useCacheFirst:NO];
    }
    else
    {
        if (![[NSUserDefaults standardUserDefaults] boolForKey:kAdBarClosed])
            [DreamingAPI getGoodApps:self useCacheFirst:YES];
    }
}

- (void)showLeft
{
    [self.viewDeckController toggleLeftView];
}

- (void)showRight
{
    [self.viewDeckController toggleRightView];
}

- (void)nowplayingButtonClicked 
{
    WebViewController *webViewController = [WebViewController getAudioPlayingWebViewController];
    
    if (webViewController == nil) {
        NowplayEmptyViewController *nowplayEmptyViewController = 
        [[UIDevice currentDevice] userInterfaceIdiom ] == UIUserInterfaceIdiomPhone ?
        [[[NowplayEmptyViewController alloc] init] autorelease] :
        [[[NowplayEmptyViewController alloc] initWithNibName:@"NowplayEmptyView_iPad" bundle:nil] autorelease];
        
        [self.navigationController pushViewController:nowplayEmptyViewController animated:YES];
    }
    else {
        [self.navigationController pushViewController:webViewController animated:YES];
    }
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
            WebViewController *webViewController = [WebViewController getAudioPlayingWebViewController];
            
            [webViewController.player startOrPauseAudioPlaying];
            
            break;
        }
            
        default:
            break;
    }
}

#pragma mark AutoRefreshingDelegate

- (void)loadArticlesNow:(BOOL)useCache
{
    if (useCache)
    {
        [self getArticleList:-1 length:SECTION_LENGTH useCacheFirst:YES];
    }
    else
    {
        [self enforceRefresh];
    }
}

#pragma mark -
#pragma mark UIButton stuff
- (void)imageButtonDidClick:(id)sender
{
    UIButton *clickedButton = sender;
    int tagNumber = [clickedButton tag];
    
    int index = tagNumber - 300;
    
    ZStatus *app = [self.appList objectAtIndex:index - 1];
    
    NSURL *url = [NSURL URLWithString:[ZStatus getAppStoreUrl:app]];
    [[UIApplication sharedApplication] openURL:url];
}

- (void)adCloseButtonDidClick:(id)sender
{
    [self.baseTableView.tableHeaderView removeFromSuperview];
    self.baseTableView.tableHeaderView = nil;
    self.adScrollView = nil;
    self.adPageControl = nil;
    self.appList = nil;
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kAdBarClosed];
}


#pragma mark -
#pragma mark UIScrollViewDelegate stuff
- (void)scrollViewDidScroll:(UIScrollView *)_scrollView
{
    if (self.adScrollView == _scrollView)
    {
        if (adPageControlIsChangingPage) {
            return;
        }
        
        /*
         *    We switch page at 50% across
         */
        CGFloat pageWidth = _scrollView.frame.size.width;
        int page = floor((_scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
        self.adPageControl.currentPage = page;
    }
    
    [super scrollViewDidScroll:_scrollView];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)_scrollView
{
    if (self.adScrollView == _scrollView)
    {
        adPageControlIsChangingPage = NO;
    }
}

#pragma mark -
#pragma mark PageControl stuff
- (IBAction)changePage:(id)sender
{
    /*
     *    Change the scroll view
     */
    CGRect frame = self.adScrollView.frame;
    frame.origin.x = frame.size.width * self.adPageControl.currentPage;
    frame.origin.y = 0;
    
    [self.adScrollView scrollRectToVisible:frame animated:YES];
    
    /*
     *    When the animated scrolling finishings, scrollViewDidEndDecelerating will turn this off
     */
    adPageControlIsChangingPage = YES;
}

@end
