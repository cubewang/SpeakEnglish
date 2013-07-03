//
//  DreamingAPI.h
//  Dreaming
//
//  封装Dreaming Restful Web Service接口
//  Created by Cube on 12-8-15.
//  Copyright 2012 Dreaming Team. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <RestKit/RestKit.h>

#define MAIN_PATH    @"http://42.121.117.183/english/index.php/api" //192.168.1.105:8889

#define DICT_PATH    @"http://dict-co.iciba.com/api"
#define DICTIONARY       @"/dictionary.php"
#define DICTIONARY_PAGE  @"http://3g.dict.cn/s.php?q="


//timeline
#define PUBLIC_TIMELINE                 @"/statuses/public_timeline.json"
#define HOME_TIMELINE                   @"/statuses/home_timeline.json"
#define USER_TIMELINE                   @"/statuses/user_timeline/:username"
#define REPLY_LIST                      @"/statuses/replies.json"
#define RETWEETS_OF_ME                  @"/statuses/retweets_of_me.json"


#define TAG_TIMELINE                   @"/statusnet/tags/timeline.json"

//favorites
#define FAVORITES_CREATE                @"/favorites/create"     //api/favorites/create/:id.:format
#define FAVORITES_DESTORY               @"/favorites/destroy"    //api/favorites/destroy/:id.:format
#define FAVORITE_LIST                   @"/favorites.json"            //api/favorites/:id.:format

//direct message
#define MESSAGE_LIST                    @"/messagebox/list.json"
#define MESSAGE_RECTIPTS                @"/direct_messages.json"
#define MESSAGE_SENDLIST                @"/direct_messages/sent.json"
#define MESSAGE_CREATE                  @"/direct_messages/new.json" 
#define MESSAGE_CONVERSATION            @"/messagebox/conversation.json"

//friendship
#define FRIEND_LIST                     @"/statuses/friends/:id"       //用户完整信息关注列表
#define FOLLOWER_LIST                   @"/statuses/followers/:id"     //用户完整信息粉丝列表
#define FRIENDSHIP_SHOW                 @"/friendships/show.json"

#define FRIENDSHIP_CREATE               @"/friendships/create.json"     
#define FRIENDSHIP_DESTORY              @"/friendships/destroy.json"

//status
#define STATUS_UPDATE                   @"/statuses/update.json"    //发布内容
#define STATUS_DELETE                   @"/statuses/destroy.json"   //删除内容
#define STATUS_RETWEET                  @"/statuses/retweet"        //转发内容
#define STATUS_SHOW                     @"/statuses/show/:status_id"


//users
#define USER_INFO                       @"/users/show.json"           //api/users/show/:id.:format

#define USER_RETISTER                   @"/account/register.json"
#define USER_LOGIN                      @"/account/verify_credentials.json"
#define USER_BIND                       @"/account/register/:platform.json"

#define SUGGESTED_USERS                 @"/suggestions/users/hot.json"


//account
#define PROFILE_UPDATE                  @"/account/update_profile.json"
#define PROFILE_IMAGE_UPDATE            @"/account/update_profile_image.json"


//tags
#define SUGGESTED_TAGS                  @"/suggestions/tags/hot.json"


//coversation
#define CONVERSATION_LIST               @"/statusnet/conversation/:conversation_id"


//apps
#define APPS_LIST                       @"/statuses/user_timeline/goodapps.json"



@interface DreamingAPI : NSObject {

}

+ (RKObjectManager*)getDictObjectManager;
+ (void)initObjectMapping;


//Timeline

+ (BOOL)getPublicTimeline:(NSInteger)maxId 
                 length:(NSInteger)length 
               delegate:(id<RKObjectLoaderDelegate>)delegate
          useCacheFirst:(BOOL)useCacheFirst;

+ (BOOL)getHomeTimeline:(NSInteger)maxId 
                length:(NSInteger)length 
              delegate:(id<RKObjectLoaderDelegate>)delegate
         useCacheFirst:(BOOL)useCacheFirst;

+ (BOOL)getUserTimeline:(NSString *)userId
                  maxId:(NSInteger)maxId 
                 length:(NSInteger)length 
               delegate:(id<RKObjectLoaderDelegate>)delegate
          useCacheFirst:(BOOL)useCacheFirst;

+ (BOOL)getGoodApps:(id<RKObjectLoaderDelegate>)delegate
      useCacheFirst:(BOOL)useCacheFirst;

+ (BOOL)getReplyList:(NSInteger)maxId
                 length:(NSInteger)length 
               delegate:(id<RKObjectLoaderDelegate>)delegate
          useCacheFirst:(BOOL)useCacheFirst;


//Status

+ (BOOL)getStatus:(NSString *)statusId
         delegate:(id<RKObjectLoaderDelegate>)delegate
    useCacheFirst:(BOOL)useCacheFirst;

+ (BOOL)postStatus:(NSString *)status
          filePath:(NSString *)filePath
        websiteUrl:(NSString *)websiteUrl
 inReplyToStatusId:(NSString *)statusId
          latitude:(NSString *)latitude
         longitude:(NSString *)longitude
          delegate:(id<RKRequestDelegate>)delegate;

+ (BOOL)deleteStatus:(NSString *)statusId 
            delegate:(id<RKRequestDelegate>)delegate;

+ (BOOL)getConversation:(NSString *)conversationId
             page:(NSInteger)page
            length:(NSInteger)length 
          delegate:(id<RKObjectLoaderDelegate>)delegate
     useCacheFirst:(BOOL)useCacheFirst;

+ (BOOL)retweet:(NSString *)statusId
onDidLoadResponse:(void (^)(RKResponse *response))onDidLoadResponseBlock
onDidFailLoadWithError:(void (^)(NSError *error))onDidFailLoadWithErrorBlock;


//Tag

//+ (BOOL)getHottestTags;

+ (BOOL)getSuggestedTags:(id<RKObjectLoaderDelegate>)delegate
           useCacheFirst:(BOOL)useCacheFirst;

+ (BOOL)getTimeline:(NSString *)tagName
              maxId:(NSInteger)maxId 
             length:(NSInteger)length 
           delegate:(id<RKObjectLoaderDelegate>)delegate
      useCacheFirst:(BOOL)useCacheFirst;


//Favorite

+ (BOOL)getFavorites:(NSInteger)maxId
              length:(NSInteger)length 
            delegate:(id<RKObjectLoaderDelegate>)delegate
       useCacheFirst:(BOOL)useCacheFirst;

+ (BOOL)createFavorite:(NSString *)statusId
     onDidLoadResponse:(void (^)(RKResponse *response))onDidLoadResponseBlock
onDidFailLoadWithError:(void (^)(NSError *error))onDidFailLoadWithErrorBlock;


+ (BOOL)deleteFavorite:(NSString *)statusId
     onDidLoadResponse:(void (^)(RKResponse *response))onDidLoadResponseBlock
onDidFailLoadWithError:(void (^)(NSError *error))onDidFailLoadWithErrorBlock;


//User

+ (BOOL)getUser:(NSString *)userId
     screenName:(NSString *)screenName
       delegate:(id<RKObjectLoaderDelegate>)delegate
  useCacheFirst:(BOOL)useCacheFirst;

+ (BOOL)getSuggestedUsers:(id<RKObjectLoaderDelegate>)delegate
            useCacheFirst:(BOOL)useCacheFirst;

+ (BOOL)registerUser:(NSString *)userName
         andPassword:(NSString *)password
            delegate:(id<RKObjectLoaderDelegate>)delegate;

+ (BOOL)login:(NSString *)userName
  andPassword:(NSString *)password
     delegate:(id<RKObjectLoaderDelegate>)delegate;

+ (void)loginOut;

+ (BOOL)bind:(NSString *)token
      openId:(NSString *)openId
platformType:(NSString *)type
    delegate:(id<RKObjectLoaderDelegate>)delegate;


+ (BOOL)changeUserName:(NSString *)userName
            orPassword:(NSString *)password
			delegate:(id<RKRequestDelegate>)delegate;

+ (BOOL)updateProfile:(NSString *)name
              blogUrl:(NSString *)url
             location:(NSString *)location
          description:(NSString *)description
             delegate:(id<RKRequestDelegate>)delegate;

+ (BOOL)updateProfileImage:(NSString *)imageFilePath
                  delegate:(id<RKObjectLoaderDelegate>)delegate;


//Friendship

+ (BOOL)getFollowers:(NSString *)userId
        orScreenName:(NSString *)screenName
                page:(NSInteger)page
              length:(NSInteger)length 
            delegate:(id<RKObjectLoaderDelegate>)delegate
       useCacheFirst:(BOOL)useCacheFirst;

+ (BOOL)getFriends:(NSString *)userId
      orScreenName:(NSString *)screenName
              page:(NSInteger)page
            length:(NSInteger)length 
          delegate:(id<RKObjectLoaderDelegate>)delegate
     useCacheFirst:(BOOL)useCacheFirst;

+ (BOOL)followUser:(NSString *)userId
      orScreenName:(NSString *)screenName
          delegate:(id<RKRequestDelegate>)delegate;

+ (BOOL)unfollowUser:(NSString *)userId
      orScreenName:(NSString *)screenName
            delegate:(id<RKRequestDelegate>)delegate;

+ (BOOL)getFriendship:(NSInteger)targetId
             delegate:(id<RKObjectLoaderDelegate>)delegate;

//Direct Message

+ (BOOL)getDirectMessages:(NSString *)userId
                 delegate:(id<RKObjectLoaderDelegate>)delegate 
            useCacheFirst:(BOOL)useCacheFirst;

+ (BOOL)createDirectMessage:(NSString *)userId
                    message:(NSString *)text 
                   delegate:(id<RKRequestDelegate>)delegate;

+ (BOOL)getMessageConversation:(NSString *)userId
                      delegate:(id<RKObjectLoaderDelegate>)delegate 
                 useCacheFirst:(BOOL)useCacheFirst;

//+ (BOOL)deleteDirectMessage;

+ (BOOL)getWord:(NSString *)word
       delegate:(id<RKObjectLoaderDelegate>)delegate;

@end
