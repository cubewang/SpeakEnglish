//
//  ZStatus.h
//  Dreaming
//
//  Created by Cube Wang on 12-8-14.
//  Copyright (c) 2012年 Dreaming Team. All rights reserved.
//

#import "ZUser.h"

@interface ZStatus : NSObject {
    
}

/**
 * The unique ID of this Status
 */
@property (nonatomic, assign) NSInteger statusID;

/**
 * The conversation ID of this Status
 */
@property (nonatomic, assign) NSInteger conversationID;

/**
 * Timestamp the Status was sent
 */
@property (nonatomic, retain) NSDate* createdAt;

/**
 * Text of the Status
 */
@property (nonatomic, retain) NSString* text;

/**
 * Html Text of the Status
 */
@property (nonatomic, retain) NSString* html;

/**
 * The Id of the Status this Status was in response to
 */
@property (nonatomic, retain) NSNumber* inReplyToStatusId;

/**
 * The Id of the User this Status was in response to
 */
@property (nonatomic, retain) NSNumber* inReplyToUserId;

/**
 * The screen name of the User this Status was in response to
 */
@property (nonatomic, retain) NSString* inReplyToScreenName;

/**
 * The Status which this Status was in response to
 */
@property (nonatomic, retain) NSString* inReplyToStatus;

/**
 * Is this status a favorite?
 */
@property (nonatomic, assign) BOOL isFavorited;

@property (nonatomic, assign) BOOL haveRead;

/**
 * The Status where be posted
 */
@property (nonatomic, retain) NSString* sourceFrom;

/**
 * The geo coordinates where the User post this Status
 */
@property (nonatomic, retain) NSArray* coordinates;

/**
 * attachments with this Status
 */
@property (nonatomic, retain) NSArray* attachments;


/**
 * The Id of the Status this Status was retweeted
 */
@property (nonatomic, retain) NSNumber* retweetedStatusId;

/**
 * attachments with the Status this Status reply to
 */
@property (nonatomic, retain) NSArray* retweetedStatusAttachments;

/**
 * tags with this Status
 */
@property (nonatomic, retain) NSMutableArray *statusTags;

/**
 * The User who posted this status
 */
@property (nonatomic, retain) ZUser* user;

/**
 * The conversation ID of this Status
 */
@property (nonatomic, assign) NSInteger repostsCount;

/**
 * The conversation ID of this Status
 */
@property (nonatomic, assign) NSInteger commentsCount;

/**
 * The conversation ID of this Status
 */
@property (nonatomic, assign) NSInteger favoritesCount;


+ (RKObjectMapping*)getObjectMapping;

+ (NSString*)getCoverImageUrl:(ZStatus*)article;
+ (NSString*)getAudioUrl:(ZStatus*)status;
+ (NSString*)getVideoUrl:(ZStatus*)status;
+ (NSString*)formatStatusText:(NSString*)text;
+ (NSString*)revertStatusText:(NSString*)text;
+ (void)separateTags:(ZStatus *)status;

+ (NSString*)getAppStoreUrl:(ZStatus*)status;

@end
