//
//  RightViewController.m
//
//
//  Created by Cube on 04.12.11.
//  Copyright (c) 2011 Dreaming Team. All rights reserved.
//

#import "RightViewController.h"
#import "MainViewController.h"
#import "ConversationViewController.h"
#import <RestKit/RestKit.h>
#import "UserAccount.h"
#import "ZDirectMessage.h"

@interface RightViewController () <IIViewDeckControllerDelegate>

@property (nonatomic, retain) ZStatus *replyToMeStatus;

@end

@implementation RightViewController

@synthesize statusItems = _statusItems, statusItemsCached = _statusItemsCached;
@synthesize tableViewCell, tableViewCellNib, tableView;
@synthesize replyToMeStatus;


- (void)dealloc {
    
    [[RKClient sharedClient].requestQueue cancelRequestsWithDelegate:self];
    
    self.statusItems = nil;
    self.statusItemsCached = nil;
    
    RELEASE_SAFELY(tableViewCell);
    RELEASE_SAFELY(tableViewCellNib);
    
    self.tableView = nil;
    
    self.replyToMeStatus = nil;
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.layer.cornerRadius = 5;
    self.view.layer.masksToBounds = YES;
    
    self.statusItems = [[[NSMutableArray alloc] init] autorelease];
    self.statusItemsCached = [[[NSMutableArray alloc] init] autorelease];
    
    self.tableViewCellNib = [UINib nibWithNibName:@"ActivityTableViewCell" bundle:nil];
    self.tableView.scrollsToTop = NO;
    
    [self setGuideline:YES];
    
    [DreamingAPI getReplyList:-1 length:20 delegate:self useCacheFirst:NO];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)setGuideline:(BOOL)useGuideline {
    if (useGuideline) {
        
        UIImageView *imageView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"notification_empty@2x"]] autorelease];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        self.tableView.tableHeaderView = imageView;
    }
    else {
        self.tableView.tableHeaderView = nil;
    }
}

- (void)viewDeckControllerDidOpenRightView:(IIViewDeckController*)viewDeckController animated:(BOOL)animated {
    
    [self refresh];
}

- (void)viewDeckControllerDidCloseRightView:(IIViewDeckController*)viewDeckController animated:(BOOL)animated {
    
    MainViewController* mainController = [[ZAppDelegate sharedAppDelegate] mainViewController];
    [mainController setNotification:NO];
}

static NSDate *lastUpdateDate = nil;

- (void)refresh
{
    if ([UserAccount getUserId] == nil)
        return;
    
    NSTimeInterval sec = [[NSDate date] timeIntervalSinceDate:lastUpdateDate];
    
    //刷新频率
    if (lastUpdateDate == nil || sec > 10) {
        [DreamingAPI getReplyList:-1 length:20 delegate:self useCacheFirst:NO];
        
        RELEASE_SAFELY(lastUpdateDate);
        lastUpdateDate = [[NSDate date] retain];
    }
}


#pragma mark RKObjectLoaderDelegate methods
- (void)request:(RKRequest*)request didLoadResponse:(RKResponse*)response {
}

- (void)objectLoader:(RKObjectLoader *)objectLoader didLoadObject:(id)object {
    
    NSString *string = [objectLoader.URL absoluteString];
    
    if ([string hasPrefix:[NSString stringWithFormat:@"%@/statusnet/conversation", MAIN_PATH]])
    {
        ZConversation *conversation = (ZConversation *)object;
        
        if (conversation.originalStatus != nil && self.replyToMeStatus != nil) {
            
            conversation.originalStatus.text = [ZStatus formatStatusText:conversation.originalStatus.text];
            
            [ZStatus separateTags:conversation.originalStatus];
            
            [self pushConversationViewController:conversation.originalStatus replyToMeStatus:self.replyToMeStatus];
        }
    }
}

- (void)objectLoader:(RKObjectLoader*)objectLoader didLoadObjects:(NSArray*)objects {
    
    NSString *string = [objectLoader.URL absoluteString];
    
    if ([string hasPrefix:[NSString stringWithFormat:@"%@%@",MAIN_PATH,REPLY_LIST]])
    {
        NSString *userId = [UserAccount getUserId];
        
        if ([userId length] == 0)
            return;
        
        NSInteger unread = 0;
        
        for (ZStatus *status in objects)
        {
            if ([userId intValue] == status.user.userID)
                continue;

            status.text = [ZStatus formatStatusText:status.text];
            
            [ZStatus separateTags:status];
            
            [self.statusItemsCached addObject:status];
            
            NSInteger lastUpdateStatusId = [[NSUserDefaults standardUserDefaults] integerForKey:@"lastUpdateStatusId"];
            
            if (status.statusID > lastUpdateStatusId) {
                
                status.haveRead = NO;
                
                unread++;
            }
            else {
                status.haveRead = YES;
            }
        }
        
        if (unread > 0) {
            MainViewController* mainController = [[ZAppDelegate sharedAppDelegate] mainViewController];
            [mainController setNotification:YES];
        }
        
        self.statusItems = [[self.statusItemsCached copy] autorelease];
        
        ZStatus *st = [self.statusItemsCached count] == 0 ? nil : [self.statusItemsCached objectAtIndex:0];
        
        [[NSUserDefaults standardUserDefaults] setInteger:st.statusID forKey:@"lastUpdateStatusId"];
        
        
        [self.statusItemsCached removeAllObjects];
        
        [self reloadNotifications];
    }
}

- (void)reloadNotifications {
    
    if ([self.statusItems count] > 0) {
        [self setGuideline:NO];
    }
    else {
        [self setGuideline:YES];
    }
    
    [self.tableView reloadData];
}

- (void)objectLoader:(RKObjectLoader*)objectLoader didFailWithError:(NSError*)error {
}


#pragma mark -
#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return [_statusItems count];
    }
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if ([self.statusItems count] == 0)
        return 0;
    
    return 30;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return 60;
    }
    
    return  60;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if ([self.statusItems count] == 0)
        return nil;
    
    if (section == 0) {
        
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tableViewSection_bg"]];
        UILabel *lable = [[[UILabel alloc] initWithFrame:CGRectMake(60, 0, 200, 30)] autorelease];
        lable.textAlignment = UITextAlignmentLeft;
        lable.backgroundColor = [UIColor clearColor];
        lable.font = [UIFont systemFontOfSize:14.0];
        lable.textColor = SECTION_TEXT_COLOR;
        lable.text = NSLocalizedString(@"你收到的最新回复",@"");
        [imageView addSubview:lable];
        
        return [imageView autorelease];
    }
    
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ActivityTableViewCell";
    
    ActivityTableViewCell *cell = (ActivityTableViewCell *)[aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
    {
        NSArray *nibs = [[NSBundle mainBundle] loadNibNamed:CellIdentifier
                                                      owner:nil options:nil];
        
        for (id item in nibs) {
            if ([item isKindOfClass:[UITableViewCell class]]) {
                cell = item;
                break;
            }
        }
    }

    [cell setBackgroundImage:[UIImage imageNamed:@"TagCellBackground"]];
    
    // set selection color 
    cell.selectedBackgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"TagCellBackground_s"]] autorelease];
    
    if (indexPath.section == 0) {
        
        ZStatus *status = [self.statusItems count] == 0 ? nil : [self.statusItems objectAtIndex:indexPath.row];
        [cell setActivity:status];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
   
    // Deselect
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    ZStatus *status = [self.statusItems count] == 0 ? nil : [self.statusItems objectAtIndex:indexPath.row];
    
    if (status.sourceFrom && [status.sourceFrom isEqualToString:@"activity"])
    {
    }
    else
    {
        self.replyToMeStatus = [self.statusItems objectAtIndex:indexPath.row];
        
        [DreamingAPI getConversation:[NSString stringWithFormat:@"%d", self.replyToMeStatus.conversationID]
                             page:0
                           length:1
                         delegate:self
                    useCacheFirst:YES];
    }
}

- (void)pushConversationViewController:(ZStatus *)original replyToMeStatus:(ZStatus *)reply
{
    if (original == nil || reply == nil)
        return;
    
    ConversationViewController *controller = [[[ConversationViewController alloc] init] autorelease];
    controller.originalStatus = original;
    controller.replyToMeStatus = reply;
    
    [self.viewDeckController rightViewPushViewControllerOverCenterController:controller];
}


- (BOOL)viewDeckControllerWillCloseRightView:(IIViewDeckController*)viewDeckController animated:(BOOL)animated {
    
    return YES;
}


@end
