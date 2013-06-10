//
//  DreamingAPI.m
//  Dreaming
//
//  Created by Cube on 12-8-15.
//  Copyright 2012 Dreaming Team. All rights reserved.
//

#import "DreamingAPI.h"
#import "ZUser.h"
#import "ZStatus.h"
#import "ZDirectMessage.h"
#import "ZStatusTag.h"
#import "ZConversation.h"
#import "ZOAuthUser.h"
#import "UserAccount.h"
#import "ZWord.h"
#import "ZFriendship.h"


@interface DreamingAPI ()


@end


@implementation DreamingAPI

static RKObjectManager* dictObjectManager = nil;

+ (RKObjectManager*)getDictObjectManager
{
    return dictObjectManager;
}

+ (void)initObjectMapping 
{
    // Initialize RestKit
    RKObjectManager* objectManager = [RKObjectManager managerWithBaseURLString:MAIN_PATH];
    
    objectManager.client.username = [UserAccount getUserName];
    objectManager.client.password = [UserAccount getUserPassword];
    objectManager.client.authenticationType = RKRequestAuthenticationTypeHTTPBasic;
    
    // Enable automatic network activity indicator management
    objectManager.client.requestQueue.showsNetworkActivityIndicatorWhenBusy = YES;
    
    objectManager.client.cachePolicy = RKRequestCachePolicyLoadIfOffline|RKRequestCachePolicyTimeout;
    objectManager.client.requestCache.storagePolicy = RKRequestCacheStoragePolicyPermanently;
    objectManager.client.timeoutInterval = 25;
    
    // Update date format so that we can parse dates properly
    // Wed Sep 29 15:31:08 +0000 2010
    [RKObjectMapping addDefaultDateFormatterForString:@"E MMM d HH:mm:ss Z y" inTimeZone:nil];
    
    // Uncomment these lines to use XML, comment it to use JSON
    //    objectManager.acceptMIMEType = RKMIMETypeXML;
    //    statusMapping.rootKeyPath = @"statuses.status";
    
    // Register our mappings with the provider using a resource path pattern
    [objectManager.mappingProvider setObjectMapping:[ZStatus getObjectMapping] forResourcePathPattern:PUBLIC_TIMELINE];
    [objectManager.mappingProvider setObjectMapping:[ZStatus getObjectMapping] forResourcePathPattern:HOME_TIMELINE];
    [objectManager.mappingProvider setObjectMapping:[ZStatus getObjectMapping] forResourcePathPattern:USER_TIMELINE];
    [objectManager.mappingProvider setObjectMapping:[ZStatus getObjectMapping] forResourcePathPattern:REPLY_LIST];
    [objectManager.mappingProvider setObjectMapping:[ZStatus getObjectMapping] forResourcePathPattern:TAG_TIMELINE];
    
    [objectManager.mappingProvider setObjectMapping:[ZStatus getObjectMapping] forResourcePathPattern:STATUS_SHOW];
    [objectManager.mappingProvider setObjectMapping:[ZStatus getObjectMapping] forResourcePathPattern:STATUS_UPDATE];
    
    [objectManager.mappingProvider setObjectMapping:[ZStatus getObjectMapping] forResourcePathPattern:FAVORITE_LIST];
    
    [objectManager.mappingProvider setObjectMapping:[ZStatusTag getObjectMapping] forResourcePathPattern:SUGGESTED_TAGS];
    
    [objectManager.mappingProvider setObjectMapping:[ZUser getObjectMapping] forResourcePathPattern:SUGGESTED_USERS];
    [objectManager.mappingProvider setObjectMapping:[ZUser getObjectMapping] forResourcePathPattern:USER_INFO];
    [objectManager.mappingProvider setObjectMapping:[ZUser getObjectMapping] forResourcePathPattern:USER_LOGIN];
    [objectManager.mappingProvider setObjectMapping:[ZUser getObjectMapping] forResourcePathPattern:USER_RETISTER];
    [objectManager.mappingProvider setObjectMapping:[ZUser getObjectMapping] forResourcePathPattern:FRIEND_LIST];
    [objectManager.mappingProvider setObjectMapping:[ZUser getObjectMapping] forResourcePathPattern:FOLLOWER_LIST];
    [objectManager.mappingProvider setObjectMapping:[ZUser getObjectMapping] forResourcePathPattern:PROFILE_IMAGE_UPDATE];
    
    [objectManager.mappingProvider setObjectMapping:[ZConversation getObjectMapping] forResourcePathPattern:CONVERSATION_LIST];
    [objectManager.mappingProvider setObjectMapping:[ZOAuthUser getObjectMapping] forResourcePathPattern:USER_BIND];
    
    [objectManager.mappingProvider setObjectMapping:[ZDirectMessage getObjectMapping] forResourcePathPattern:MESSAGE_RECTIPTS];
    [objectManager.mappingProvider setObjectMapping:[ZDirectMessage getObjectMapping] forResourcePathPattern:MESSAGE_CONVERSATION];
    [objectManager.mappingProvider setObjectMapping:[ZFriendship getObjectMapping] forResourcePathPattern:FRIENDSHIP_SHOW];

    
    if (dictObjectManager == nil) {
        dictObjectManager = [[RKObjectManager objectManagerWithBaseURLString:DICT_PATH] retain];
        dictObjectManager.client.timeoutInterval = 30;
        dictObjectManager.acceptMIMEType = RKMIMETypeXML;
    }
    
    [dictObjectManager.mappingProvider setObjectMapping:[ZWord getObjectMapping] forResourcePathPattern:DICTIONARY];
    
    //RKLogConfigureByName("RestKit", RKLogLevelWarning); 
    //RKLogConfigureByName("RestKit/ObjectMapping", RKLogLevelTrace);
    //RKLogConfigureByName("RestKit/Network", RKLogLevelTrace);
}

+ (void)setCachePolicy:(BOOL)useCacheFirst
{
    RKObjectManager* objectManager = [RKObjectManager sharedManager];
    
    if (useCacheFirst) {
        objectManager.client.cachePolicy = RKRequestCachePolicyEnabled;
    }
    else 
    {
        objectManager.client.cachePolicy = RKRequestCachePolicyLoadIfOffline|RKRequestCachePolicyTimeout;
    }
}

+ (BOOL)getPublicTimeline:(NSInteger)maxId 
                   length:(NSInteger)length 
                 delegate:(id<RKObjectLoaderDelegate>)delegate
            useCacheFirst:(BOOL)useCacheFirst
{
    if (delegate == nil)
        return NO;
    
    [DreamingAPI setCachePolicy:useCacheFirst];
    
    // Load the object model via RestKit
    RKObjectManager* objectManager = [RKObjectManager sharedManager];
    
    objectManager.client.password = [UserAccount getUserPassword];
    objectManager.client.username = [UserAccount getUserName];
    objectManager.client.authenticationType = RKRequestAuthenticationTypeHTTPBasic;
    
    if (maxId < 0) {
        
        [objectManager loadObjectsAtResourcePath:PUBLIC_TIMELINE delegate:delegate];
        
        return YES;
    }
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            [NSString stringWithFormat:@"%d", maxId], @"max_id",
                            [NSString stringWithFormat:@"%d", length], @"count", nil];
    
    NSString *resourcePath = [PUBLIC_TIMELINE stringByAppendingQueryParameters:params];
    
    [objectManager loadObjectsAtResourcePath:resourcePath delegate:delegate];
    
    return YES;
}

+ (BOOL)getHomeTimeline:(NSInteger)maxId 
                 length:(NSInteger)length
               delegate:(id<RKObjectLoaderDelegate>)delegate
          useCacheFirst:(BOOL)useCacheFirst
{
    if (delegate == nil)
        return NO;
    
    [DreamingAPI setCachePolicy:useCacheFirst];
    
    // Load the object model via RestKit
    RKObjectManager* objectManager = [RKObjectManager sharedManager];
    
    objectManager.client.username = @"voaspecial";
    objectManager.client.password = @"123456";
    
    if (maxId < 0) {
        
        [objectManager loadObjectsAtResourcePath:HOME_TIMELINE delegate:delegate];
        
        return YES;
    }
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            [NSString stringWithFormat:@"%d", maxId], @"max_id",
                            [NSString stringWithFormat:@"%d", length], @"count", nil];
    
    NSString *resourcePath = [HOME_TIMELINE stringByAppendingQueryParameters:params];
    
    [objectManager loadObjectsAtResourcePath:resourcePath delegate:delegate];
    
    return YES;
}

+ (BOOL)getUserTimeline:(NSString *)userId
                  maxId:(NSInteger)maxId 
                 length:(NSInteger)length 
               delegate:(id<RKObjectLoaderDelegate>)delegate
          useCacheFirst:(BOOL)useCacheFirst
{
    if (delegate == nil || [userId length] == 0)
        return NO;
    
    [DreamingAPI setCachePolicy:useCacheFirst];
    
    RKObjectManager* objectManager = [RKObjectManager sharedManager];
    
    objectManager.client.password = [UserAccount getUserPassword];
    objectManager.client.username = [UserAccount getUserName];
    objectManager.client.authenticationType = RKRequestAuthenticationTypeHTTPBasic;
    
    NSString *path = [NSString stringWithFormat:@"/statuses/user_timeline/%@.json", userId];
    
    NSString *resourcePath = nil;
    NSDictionary *params = nil;
    
    if (maxId < 0) {
        
        params = [NSDictionary dictionaryWithObjectsAndKeys:
                  [NSString stringWithFormat:@"%d", length], @"count", nil];
        
        resourcePath = [path stringByAppendingQueryParameters:params];
        
        [objectManager loadObjectsAtResourcePath:resourcePath delegate:delegate];
        
        return YES;
    }
    
    params = [NSDictionary dictionaryWithObjectsAndKeys:
              [NSString stringWithFormat:@"%d", maxId], @"max_id",
              [NSString stringWithFormat:@"%d", length], @"count", nil];
    
    resourcePath = [path stringByAppendingQueryParameters:params];
    
    [objectManager loadObjectsAtResourcePath:resourcePath delegate:delegate];
    
    return YES;
}

+ (BOOL)getGoodApps:(id<RKObjectLoaderDelegate>)delegate
          useCacheFirst:(BOOL)useCacheFirst
{
    if (delegate == nil)
        return NO;
    
    [DreamingAPI setCachePolicy:useCacheFirst];
    
    RKObjectManager* objectManager = [RKObjectManager sharedManager];
    
    objectManager.client.password = [UserAccount getUserPassword];
    objectManager.client.username = [UserAccount getUserName];
    objectManager.client.authenticationType = RKRequestAuthenticationTypeHTTPBasic;
    
    [objectManager loadObjectsAtResourcePath:APPS_LIST delegate:delegate];
    
    return YES;
}

+ (BOOL)getReplyList:(NSInteger)maxId 
              length:(NSInteger)length
            delegate:(id<RKObjectLoaderDelegate>)delegate
       useCacheFirst:(BOOL)useCacheFirst
{
    if (delegate == nil)
        return NO;
    
    [DreamingAPI setCachePolicy:useCacheFirst];
    
    // Load the object model via RestKit
    RKObjectManager* objectManager = [RKObjectManager sharedManager];
    
    objectManager.client.password = [UserAccount getUserPassword];
    objectManager.client.username = [UserAccount getUserName];
    objectManager.client.authenticationType = RKRequestAuthenticationTypeHTTPBasic;
    
    if (maxId < 0) {
        
        [objectManager loadObjectsAtResourcePath:[NSString stringWithFormat:@"%@?include_in_reply_to_status=1", REPLY_LIST] delegate:delegate];
        
        return YES;
    }
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            [NSString stringWithFormat:@"%d", maxId], @"max_id",
                            [NSString stringWithFormat:@"%d", length], @"count", 
                            @"1", @"include_in_reply_to_status", nil];
    
    NSString *resourcePath = [REPLY_LIST stringByAppendingQueryParameters:params];
    
    [objectManager loadObjectsAtResourcePath:resourcePath delegate:delegate];
    
    return YES;
}

+ (BOOL)getStatus:(NSString *)statusId
         delegate:(id<RKObjectLoaderDelegate>)delegate
    useCacheFirst:(BOOL)useCacheFirst
{
    if (delegate == nil || statusId == nil)
        return NO;
    
    [DreamingAPI setCachePolicy:useCacheFirst];
    
    // Load the object model via RestKit
    RKObjectManager* objectManager = [RKObjectManager sharedManager];
    
    objectManager.client.password = [UserAccount getUserPassword];
    objectManager.client.username = [UserAccount getUserName];
    objectManager.client.authenticationType = RKRequestAuthenticationTypeHTTPBasic;
    
    NSString *resourcePath = [NSString stringWithFormat:@"/statuses/show/%@.json", statusId];
    
    [objectManager loadObjectsAtResourcePath:resourcePath delegate:delegate];
    
    return YES;
}

+ (BOOL)postStatus:(NSString *)status
          filePath:(NSString *)filePath
        websiteUrl:(NSString *)websiteUrl
 inReplyToStatusId:(NSString *)statusId
          latitude:(NSString *)latitude
         longitude:(NSString *)longitude
          delegate:(id<RKObjectLoaderDelegate>)delegate
{
    if ([status length] == 0)
        return NO;
    
    NSDictionary* dictionary = [NSDictionary dictionaryWithObjectsAndKeys:status, @"status", nil];
    
    RKParams* params = [[RKParams alloc] initWithDictionary:dictionary];
    
    if ([statusId length] > 0) {
        [params setValue:statusId forParam:@"in_reply_to_status_id"];
    }
    
    if ([longitude length] > 0) {
        [params setValue:longitude forParam:@"long"];
    }
    
    if ([latitude length] > 0) {
        [params setValue:latitude forParam:@"lat"];
    }
    
    if ([filePath length] > 0) {
        [params setFile:filePath forParam:@"media"];
    }
    
    if ([websiteUrl length] > 0) {
        [params setValue:websiteUrl forParam:@"url"];
    }
    
    RKObjectManager* objectManager = [RKObjectManager sharedManager];
    
    objectManager.client.password = [UserAccount getUserPassword];
    objectManager.client.username = [UserAccount getUserName];
    objectManager.client.authenticationType = RKRequestAuthenticationTypeHTTPBasic;
    
    [objectManager loadObjectsAtResourcePath:STATUS_UPDATE usingBlock:^(RKObjectLoader *loader) {
        
        loader.method = RKRequestMethodPOST;
        loader.params = params;
        loader.delegate = delegate;
    }];
    
    return YES;
}


+ (BOOL)deleteStatus:(NSString *)statusId
            delegate:(id<RKRequestDelegate>)delegate
{
    if ([statusId length] == 0)
        return NO;
    
    NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:statusId, @"id", nil];
    
    RKClient *client = [RKClient sharedClient];
    client.authenticationType = RKRequestAuthenticationTypeHTTPBasic;
    client.username = [UserAccount getUserName];
    client.password = [UserAccount getUserPassword];
    
    [client post:STATUS_DELETE params:params delegate:delegate];
    
    return YES;
}

+ (BOOL)getConversation:(NSString *)conversationId
                  page:(NSInteger)page
                 length:(NSInteger)length 
               delegate:(id<RKObjectLoaderDelegate>)delegate
          useCacheFirst:(BOOL)useCacheFirst
{
    if (delegate == nil || conversationId == nil)
        return NO;
    
    [DreamingAPI setCachePolicy:useCacheFirst];
    
    // Load the object model via RestKit
    RKObjectManager* objectManager = [RKObjectManager sharedManager];
    
    objectManager.client.password = [UserAccount getUserPassword];
    objectManager.client.username = [UserAccount getUserName];
    objectManager.client.authenticationType = RKRequestAuthenticationTypeHTTPBasic;
    
    NSString *resourcePath = [NSString stringWithFormat:@"/statusnet/conversation/%@.json", conversationId];
    
    if (page < 0) {
        
        [objectManager loadObjectsAtResourcePath:resourcePath delegate:delegate];
        
        return YES;
    }
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            [NSString stringWithFormat:@"%d", page], @"page",
                            [NSString stringWithFormat:@"%d", length], @"count", nil];
    
    resourcePath = [resourcePath stringByAppendingQueryParameters:params];
    
    [objectManager loadObjectsAtResourcePath:resourcePath delegate:delegate];
    
    return YES;
}

+ (BOOL)retweet:(NSString *)statusId
onDidLoadResponse:(void (^)(RKResponse *response))onDidLoadResponseBlock
onDidFailLoadWithError:(void (^)(NSError *error))onDidFailLoadWithErrorBlock
{
    if ([statusId length] == 0)
        return NO;
    
    NSString *path = [NSString stringWithFormat:@"%@/%@.json", STATUS_RETWEET, statusId];
    
    [[RKClient sharedClient] post:path usingBlock:^(RKRequest *request) {
        request.onDidLoadResponse = onDidLoadResponseBlock;
        request.onDidFailLoadWithError = onDidFailLoadWithErrorBlock;
    }]; 
    
    return YES;
}

+ (BOOL)getSuggestedTags:(id<RKObjectLoaderDelegate>)delegate
           useCacheFirst:(BOOL)useCacheFirst 
{
    if (delegate == nil)
        return NO;
    
    [DreamingAPI setCachePolicy:useCacheFirst];
    
    RKObjectManager* objectManager = [RKObjectManager sharedManager];
    
    objectManager.client.password = [UserAccount getUserPassword];
    objectManager.client.username = [UserAccount getUserName];
    objectManager.client.authenticationType = RKRequestAuthenticationTypeHTTPBasic;
    
    [objectManager loadObjectsAtResourcePath:SUGGESTED_TAGS delegate:delegate];
    
    return YES;
}

+ (BOOL)getTimeline:(NSString *)tagName
              maxId:(NSInteger)maxId 
             length:(NSInteger)length 
           delegate:(id<RKObjectLoaderDelegate>)delegate
      useCacheFirst:(BOOL)useCacheFirst
{
    if (delegate == nil || [tagName length] == 0)
        return NO;
    
    [DreamingAPI setCachePolicy:useCacheFirst];
    
    RKObjectManager* objectManager = [RKObjectManager sharedManager];
    
    objectManager.client.password = [UserAccount getUserPassword];
    objectManager.client.username = [UserAccount getUserName];
    objectManager.client.authenticationType = RKRequestAuthenticationTypeHTTPBasic;
    
    NSString *path = [NSString stringWithFormat:@"%@%@%@", TAG_TIMELINE, @"?tag=", tagName];
    
    if (maxId < 0) {
        
        [objectManager loadObjectsAtResourcePath:path delegate:delegate];
        
        return YES;
    }
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            [NSString stringWithFormat:@"%d", maxId], @"max_id",
                            [NSString stringWithFormat:@"%d", length], @"count", 
                            tagName, @"tag", nil];
    
    NSString *resourcePath = [path stringByAppendingQueryParameters:params];
    
    [objectManager loadObjectsAtResourcePath:resourcePath delegate:delegate];
    
    return YES;
}

+ (BOOL)getFavorites:(NSInteger)maxId
              length:(NSInteger)length
            delegate:(id<RKObjectLoaderDelegate>)delegate
       useCacheFirst:(BOOL)useCacheFirst
{
    [DreamingAPI setCachePolicy:useCacheFirst];
    
    RKObjectManager* objectManager = [RKObjectManager sharedManager];
    
    objectManager.client.password = [UserAccount getUserPassword];
    objectManager.client.username = [UserAccount getUserName];
    objectManager.client.authenticationType = RKRequestAuthenticationTypeHTTPBasic;
    
    if (maxId < 0) {
        
        [objectManager loadObjectsAtResourcePath:FAVORITE_LIST delegate:delegate];
        
        return YES;
    }
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            [NSString stringWithFormat:@"%d", maxId], @"max_id",
                            [NSString stringWithFormat:@"%d", length], @"count",
                            nil];
    
    NSString *resourcePath = [FAVORITE_LIST stringByAppendingQueryParameters:params];
    
    [objectManager loadObjectsAtResourcePath:resourcePath delegate:delegate];
    
    return YES;
}

+ (BOOL)createFavorite:(NSString *)statusId
     onDidLoadResponse:(void (^)(RKResponse *response))onDidLoadResponseBlock
onDidFailLoadWithError:(void (^)(NSError *error))onDidFailLoadWithErrorBlock;
{
    if ([statusId length] == 0)
        return NO;
    
    NSString *path = [NSString stringWithFormat:@"%@/%@.json", FAVORITES_CREATE, statusId];
    
    RKClient *client = [RKClient sharedClient];
    client.authenticationType = RKRequestAuthenticationTypeHTTPBasic;
    client.username = [UserAccount getUserName];
    client.password = [UserAccount getUserPassword];
    
    [client post:path usingBlock:^(RKRequest *request) {
        request.onDidLoadResponse = onDidLoadResponseBlock;
        request.onDidFailLoadWithError = onDidFailLoadWithErrorBlock;
    }]; 
    
    return YES;
}

+ (BOOL)deleteFavorite:(NSString *)statusId
     onDidLoadResponse:(void (^)(RKResponse *response))onDidLoadResponseBlock
onDidFailLoadWithError:(void (^)(NSError *error))onDidFailLoadWithErrorBlock;
{
    if ([statusId length] == 0)
        return NO;
    
    NSString *path = [NSString stringWithFormat:@"%@/%@.json", FAVORITES_DESTORY, statusId];
    
    RKClient *client = [RKClient sharedClient];
    client.authenticationType = RKRequestAuthenticationTypeHTTPBasic;
    client.username = [UserAccount getUserName];
    client.password = [UserAccount getUserPassword];
    
    [client post:path usingBlock:^(RKRequest *request) {
        request.onDidLoadResponse = onDidLoadResponseBlock;
        request.onDidFailLoadWithError = onDidFailLoadWithErrorBlock;
    }]; 
    
    return YES;
}


+ (BOOL)getUser:(NSString *)userId
     screenName:(NSString *)screenName
       delegate:(id<RKObjectLoaderDelegate>)delegate
  useCacheFirst:(BOOL)useCacheFirst
{
    if ([userId length] == 0 && [screenName length] == 0)
        return NO;
    
    [DreamingAPI setCachePolicy:useCacheFirst];
    
    RKObjectManager* objectManager = [RKObjectManager sharedManager];
    
    objectManager.client.password = [UserAccount getUserPassword];
    objectManager.client.username = [UserAccount getUserName];
    objectManager.client.authenticationType = RKRequestAuthenticationTypeHTTPBasic;
    
    NSString *path = nil;
    
    if ([userId length] > 0) 
    {
        path = [NSString stringWithFormat:@"/users/show.json?id=%@", userId];
    }
    else
    {
        path = [NSString stringWithFormat:@"/users/show.json?screen_name=%@", screenName];
    }
    
    [objectManager loadObjectsAtResourcePath:path delegate:delegate];
    
    return YES;
}

+ (BOOL)getSuggestedUsers:(id<RKObjectLoaderDelegate>)delegate
            useCacheFirst:(BOOL)useCacheFirst
{
    if (delegate == nil)
        return NO;
    
    [DreamingAPI setCachePolicy:useCacheFirst];
    
    RKObjectManager* objectManager = [RKObjectManager sharedManager];
    
    objectManager.client.password = [UserAccount getUserPassword];
    objectManager.client.username = [UserAccount getUserName];
    objectManager.client.authenticationType = RKRequestAuthenticationTypeHTTPBasic;
    
    [objectManager loadObjectsAtResourcePath:SUGGESTED_USERS delegate:delegate];
    
    return YES;
}

+ (BOOL)registerUser:(NSString *)userName
         andPassword:(NSString *)password
            delegate:(id<RKObjectLoaderDelegate>)delegate
{
    if ([userName length] == 0 || [password length] == 0 || delegate == nil)
        return NO;
    
    RKParams* params = [RKParams params];
    
    [params setValue:userName forParam:@"username"];
    [params setValue:password forParam:@"password"];
    
    [[RKObjectManager sharedManager] loadObjectsAtResourcePath:USER_RETISTER usingBlock:^(RKObjectLoader *loader) {
        
        loader.method = RKRequestMethodPOST;
        loader.params = params;
        loader.delegate = delegate;
    }];
    
    return YES;
}

+ (BOOL)login:(NSString *)userName
  andPassword:(NSString *)password
     delegate:(id<RKObjectLoaderDelegate>)delegate
{
    if ([userName length] == 0 || [password length] == 0 || delegate == nil)
        return NO;
    
    RKObjectManager* objectManager = [RKObjectManager sharedManager];
    
    objectManager.client.username = userName;
    objectManager.client.password = password;
    
    [objectManager loadObjectsAtResourcePath:USER_LOGIN delegate:delegate];
    
    return YES;
}

+ (BOOL)bind:(NSString *)token
      openId:(NSString *)openId
platformType:(NSString *)type
    delegate:(id<RKObjectLoaderDelegate>)delegate
{
    if ([token length] == 0 || delegate == nil) {
        return NO;
    }
    
    NSString *path = nil;
    if ([type isEqualToString:@"sina"]) {
        path = [NSString stringWithFormat:@"/account/register/sina.json?token=%@", token];
    }
    else if ([type isEqualToString:@"qq"])
    {
        path = [NSString stringWithFormat:@"/account/register/qq.json?token=%@&openid=%@", token, openId];
    }
    else
    {
        return NO;
    }
    
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    
    objectManager.client.password = [UserAccount getUserPassword];
    objectManager.client.username = [UserAccount getUserName];
    objectManager.client.authenticationType = RKRequestAuthenticationTypeHTTPBasic;
    
    [objectManager loadObjectsAtResourcePath:path delegate:delegate];
    
    return YES;
}

+ (void)loginOut
{
    [[RKClient sharedClient].requestCache invalidateAll];
    
    [UserAccount clearUserInfo];
}

+ (BOOL)updateProfile:(NSString *)name
              blogUrl:(NSString *)url
             location:(NSString *)location
          description:(NSString *)description
             delegate:(id<RKRequestDelegate>)delegate
{
    if ([name length] == 0 && [url length] == 0 
        && [location length] == 0 && [description length] == 0)
        return NO;
    
    NSMutableDictionary* params = [[NSMutableDictionary alloc] init];
    
    if ([name length] > 0)
        [params setObject:name forKey:@"name"];
    
    if ([url length] > 0)
        [params setObject:url forKey:@"url"];
    
    if ([location length] > 0)
        [params setObject:location forKey:@"location"];
    
    if ([description length] > 0)
        [params setObject:description forKey:@"description"];
    
    RKClient *client = [RKClient sharedClient];
    client.authenticationType = RKRequestAuthenticationTypeHTTPBasic;
    client.username = [UserAccount getUserName];
    client.password = [UserAccount getUserPassword];
    
    [client post:PROFILE_UPDATE params:params delegate:delegate];
    
    return YES;
}

+ (BOOL)updateProfileImage:(NSString *)imageFilePath
                  delegate:(id<RKObjectLoaderDelegate>)delegate
{
    if ([imageFilePath length] == 0)
        return NO;
    
    RKParams* params = [[RKParams alloc] init];
    
    [params setFile:imageFilePath forParam:@"image"];
    
    RKObjectManager* objectManager = [RKObjectManager sharedManager];
    
    objectManager.client.password = [UserAccount getUserPassword];
    objectManager.client.username = [UserAccount getUserName];
    objectManager.client.authenticationType = RKRequestAuthenticationTypeHTTPBasic;
    
    [objectManager loadObjectsAtResourcePath:PROFILE_IMAGE_UPDATE usingBlock:^(RKObjectLoader *loader) {
        
        loader.method = RKRequestMethodPOST;
        loader.params = params;
        loader.delegate = delegate;
    }];
    
    return YES;
}

+ (BOOL)getFollowers:(NSString *)userId
        orScreenName:(NSString *)screenName
                page:(NSInteger)page
              length:(NSInteger)length 
            delegate:(id<RKObjectLoaderDelegate>)delegate
       useCacheFirst:(BOOL)useCacheFirst
{
    if ([userId length] == 0 && [screenName length] == 0)
        return NO;
    
    if (delegate == nil)
        return NO;
    
    RKObjectManager* objectManager = [RKObjectManager sharedManager];
    
    objectManager.client.password = [UserAccount getUserPassword];
    objectManager.client.username = [UserAccount getUserName];
    objectManager.client.authenticationType = RKRequestAuthenticationTypeHTTPBasic;
    
    NSString *resourcePath = nil;
    
    if ([userId length] > 0) {
        resourcePath = [NSString stringWithFormat:@"/statuses/followers/%@.json", userId];
    }
    else {
        resourcePath = [NSString stringWithFormat:@"/statuses/followers/%@.json", screenName];
    }
    
    if (page < 0) {
        
        [objectManager loadObjectsAtResourcePath:resourcePath delegate:delegate];
        
        return YES;
    }
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            [NSString stringWithFormat:@"%d", page], @"page",
                            [NSString stringWithFormat:@"%d", length], @"count", nil]; 
    
    resourcePath = [resourcePath stringByAppendingQueryParameters:params];
    
    [objectManager loadObjectsAtResourcePath:resourcePath delegate:delegate];
    
    return YES;
}

+ (BOOL)getFriends:(NSString *)userId
      orScreenName:(NSString *)screenName
              page:(NSInteger)page
            length:(NSInteger)length 
          delegate:(id<RKObjectLoaderDelegate>)delegate
     useCacheFirst:(BOOL)useCacheFirst
{
    if ([userId length] == 0 && [screenName length] == 0)
        return NO;
    
    if (delegate == nil)
        return NO;
    
    RKObjectManager* objectManager = [RKObjectManager sharedManager];
    
    objectManager.client.password = [UserAccount getUserPassword];
    objectManager.client.username = [UserAccount getUserName];
    objectManager.client.authenticationType = RKRequestAuthenticationTypeHTTPBasic;
    
    NSString *resourcePath = nil;
    
    if ([userId length] > 0) {
        resourcePath = [NSString stringWithFormat:@"/statuses/friends/%@.json", userId];
    }
    else {
        resourcePath = [NSString stringWithFormat:@"/statuses/friends/%@.json", screenName];
    }
    
    if (page < 0) {
        
        [objectManager loadObjectsAtResourcePath:resourcePath delegate:delegate];
        
        return YES;
    }
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            [NSString stringWithFormat:@"%d", page], @"page",
                            [NSString stringWithFormat:@"%d", length], @"count", nil]; 
    
    resourcePath = [resourcePath stringByAppendingQueryParameters:params];
    
    [objectManager loadObjectsAtResourcePath:resourcePath delegate:delegate];
    
    return YES;
}

+ (BOOL)followUser:(NSString *)userId
      orScreenName:(NSString *)screenName
          delegate:(id<RKRequestDelegate>)delegate
{
    if ([userId length] == 0 && [screenName length] == 0)
        return NO;
    
    NSDictionary *params = nil;
    
    if ([userId length] > 0) 
    {
        params = [NSDictionary dictionaryWithObjectsAndKeys:userId, @"id", nil];
    }
    else
    {
        params = [NSDictionary dictionaryWithObjectsAndKeys:screenName, @"screen_name", nil];
    }
    
    RKClient *client = [RKClient sharedClient];
    client.authenticationType = RKRequestAuthenticationTypeHTTPBasic;
    client.username = [UserAccount getUserName];
    client.password = [UserAccount getUserPassword];
    
    [client post:FRIENDSHIP_CREATE params:params delegate:delegate];
    
    return YES;
}

+ (BOOL)unfollowUser:(NSString *)userId
        orScreenName:(NSString *)screenName
            delegate:(id<RKRequestDelegate>)delegate
{
    if ([userId length] == 0 && [screenName length] == 0)
        return NO;
    
    NSDictionary *params = nil;
    
    if ([userId length] > 0) 
    {
        params = [NSDictionary dictionaryWithObjectsAndKeys:userId, @"id", nil];
    }
    else
    {
        params = [NSDictionary dictionaryWithObjectsAndKeys:screenName, @"screen_name", nil];
    }
    
    RKClient *client = [RKClient sharedClient];
    client.authenticationType = RKRequestAuthenticationTypeHTTPBasic;
    client.username = [UserAccount getUserName];
    client.password = [UserAccount getUserPassword];
    
    [client post:FRIENDSHIP_DESTORY params:params delegate:delegate];
    
    return YES;
}

+ (BOOL)getFriendship:(NSInteger)targetId
             delegate:(id<RKObjectLoaderDelegate>)delegate
{
    [DreamingAPI setCachePolicy:NO];
    
    NSDictionary *params = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%d", targetId]
                                                       forKey:@"target_id"];
    
    NSString *resourcePath = [FRIENDSHIP_SHOW stringByAppendingQueryParameters:params];
    RKObjectManager *objectManager = [RKObjectManager sharedManager];

    objectManager.client.password = [UserAccount getUserPassword];
    objectManager.client.username = [UserAccount getUserName];
    objectManager.client.authenticationType = RKRequestAuthenticationTypeHTTPBasic;
    
    [objectManager loadObjectsAtResourcePath:resourcePath delegate:delegate];
    
    return YES;
}

+ (BOOL)changeUserName:(NSString *)userName
            orPassword:(NSString *)password
	    delegate:(id<RKRequestDelegate>)delegate {
    
    return YES;
}

+ (BOOL)createDirectMessage:(NSString *)userId
                    message:(NSString *)text 
                   delegate:(id<RKRequestDelegate>)delegate {
    
    if ([userId length] == 0 || [text length] == 0) {
        return NO;
    }
    
    NSDictionary *params = nil;
    
    if ([userId length] > 0 && [text length] > 0) {
        
        params = [NSDictionary dictionaryWithObjectsAndKeys:
                           [NSString stringWithFormat:@"%@", userId], @"user_id",
                           [NSString stringWithFormat:@"%@", text], @"text", nil];
    }
    
    RKClient *client = [RKClient sharedClient];
    client.authenticationType = RKRequestAuthenticationTypeHTTPBasic;
    client.username = [UserAccount getUserName];
    client.password = [UserAccount getUserPassword];
    
    [client post:MESSAGE_CREATE params:params delegate:delegate];
    
    return YES;
}

+ (BOOL)getDirectMessages:(NSString *)userId
                 delegate:(id<RKObjectLoaderDelegate>)delegate  
            useCacheFirst:(BOOL)useCacheFirst {
    
    if (delegate == nil)
        return NO;
    
    if ([userId length] == 0) {
        return NO;
    }
    
    [DreamingAPI setCachePolicy:useCacheFirst];
    
    NSDictionary *params = nil;
    
    if ([userId length] > 0) {
        
        params = [NSDictionary dictionaryWithObjectsAndKeys:
                  [NSString stringWithFormat:@"%@", userId], @"user_id",nil];
    }
    
    RKObjectManager* objectManager = [RKObjectManager sharedManager];
    
    objectManager.client.username = [UserAccount getUserName];
    objectManager.client.password = [UserAccount getUserPassword];
    
    NSString *resourcePath = [MESSAGE_RECTIPTS stringByAppendingQueryParameters:params];
    
    [objectManager loadObjectsAtResourcePath:resourcePath delegate:delegate];
        
    return YES;
}

+ (BOOL)getMessageConversation:(NSString *)userId
                      delegate:(id<RKObjectLoaderDelegate>)delegate 
                 useCacheFirst:(BOOL)useCacheFirst
{
    if (delegate == nil)
        return NO;
    
    if ([userId length ] == 0) {
        return NO;
    }
        
    [DreamingAPI setCachePolicy:useCacheFirst];
    
    NSString *resourcePath;
    
    if ([userId length] > 0) {
        
        resourcePath = [NSString stringWithFormat:@"%@?id=%@",MESSAGE_CONVERSATION,userId];
    }
    
    RKObjectManager* objectManager = [RKObjectManager sharedManager];
    
    objectManager.client.username = [UserAccount getUserName];
    objectManager.client.password = [UserAccount getUserPassword];
    
    [objectManager loadObjectsAtResourcePath:resourcePath delegate:delegate];
    
    return YES;
}

+ (BOOL)getWord:(NSString *)word
       delegate:(id<RKObjectLoaderDelegate>)delegate
{
    if (delegate == nil || [word length] == 0)
        return NO;
    
    [DreamingAPI setCachePolicy:YES];
    
    NSString *resourcePath = [NSString stringWithFormat:@"%@?w=%@", DICTIONARY, word];
    
    RKObjectManager* objectManager = [DreamingAPI getDictObjectManager];
    [objectManager loadObjectsAtResourcePath:resourcePath delegate:delegate];
    
    return YES;
}

@end
