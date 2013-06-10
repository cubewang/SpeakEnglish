//
//  ZStatus.m
//  Dreaming
//
//  Created by Cube Wang on 12-8-14.
//  Copyright (c) 2012年 Dreaming Team. All rights reserved.
//

#import "ZStatus.h"

@implementation ZStatus

@synthesize statusID;
@synthesize conversationID;
@synthesize createdAt;
@synthesize text;
@synthesize html;
@synthesize inReplyToStatusId;
@synthesize inReplyToUserId;
@synthesize inReplyToScreenName;
@synthesize inReplyToStatus;
@synthesize isFavorited;
@synthesize haveRead;
@synthesize sourceFrom;
@synthesize coordinates;
@synthesize attachments;
@synthesize retweetedStatusId;
@synthesize retweetedStatusAttachments;
@synthesize statusTags;
@synthesize user;
@synthesize repostsCount;
@synthesize commentsCount;
@synthesize favoritesCount;


+ (RKObjectMapping*)getObjectMapping {
    
    RKObjectMapping* statusMapping = [RKObjectMapping mappingForClass:[ZStatus class]];
    [statusMapping mapKeyPathsToAttributes:@"id", @"statusID",
     @"statusnet_conversation_id", @"conversationID",
     @"created_at", @"createdAt",
     @"text", @"text",
     @"statusnet_html", @"html",
     @"in_reply_to_status_id", @"inReplyToStatusId",
     @"in_reply_to_user_id", @"inReplyToUserId",
     @"in_reply_to_screen_name", @"inReplyToScreenName",
     @"favorited", @"isFavorited",
     @"source", @"sourceFrom",
     @"reposts_count", @"repostsCount",
     @"comments_count", @"commentsCount",
     @"favorites_count", @"favoritesCount",
     nil];
    
    [statusMapping mapKeyPath:@"attachments" toAttribute:@"attachments"];
    [statusMapping mapKeyPath:@"geo.coordinates" toAttribute:@"coordinates"];
    
    [statusMapping mapKeyPath:@"in_reply_to_status.text" toAttribute:@"inReplyToStatus"];
    
    [statusMapping mapKeyPath:@"retweeted_status.attachments" toAttribute:@"retweetedStatusAttachments"];
    [statusMapping mapKeyPath:@"retweeted_status.id" toAttribute:@"retweetedStatusId"];
    
    [statusMapping mapRelationship:@"user" withMapping:[ZUser getObjectMapping]];
    
    return statusMapping;
}

+ (NSString*)getCoverImageUrl:(ZStatus*)article {
    
    if ([article.attachments count] > 0) {
        
        for (NSDictionary *dictionary in article.attachments)
        {
            NSString *mimetype = [dictionary objectForKey:@"mimetype"];
            NSString *url = [dictionary objectForKey:@"url"];
            
            if ([mimetype hasPrefix:@"image"]) {
                return url;
            }
        }
    }
    
    return nil;
}

+ (NSString*)getAudioUrl:(ZStatus*)status {
    
    if ([status.attachments count] > 0) {
        
        for (NSDictionary *dictionary in status.attachments)
        {
            NSString *mimetype = [dictionary objectForKey:@"mimetype"];
            mimetype = [mimetype lowercaseString];
            
            NSString *url = [dictionary objectForKey:@"url"];
            NSString *lowerUrl = [url lowercaseString];
            
            if ([mimetype hasPrefix:@"audio"]) {
                return url;
            }
            
            if ([mimetype hasPrefix:@"text/url"] && [lowerUrl hasSuffix:@"mp3"]) {
                return url;
            }
        }
    }
    
    return nil;
}

+ (NSString*)getVideoUrl:(ZStatus*)status {
    
    if ([status.attachments count] > 0) {
        
        for (NSDictionary *dictionary in status.attachments)
        {
            NSString *mimetype = [dictionary objectForKey:@"mimetype"];
            mimetype = [mimetype lowercaseString];
            
            NSString *url = [dictionary objectForKey:@"url"];
            NSString *lowerUrl = [url lowercaseString];
            
            if ([mimetype hasPrefix:@"text/url"] && ![lowerUrl hasSuffix:@"mp3"]) {
                return url;
            }
        }
    }
    
    return nil;
}

+ (NSString*)formatStatusText:(NSString*)text {
    
    if (text == nil)
        return nil;
    
    if ([text length] == 0)
        return @"";
    
    return [text stringByReplacingOccurrencesOfString:@"\n" withString:@"\n\n"];
}

+ (NSString*)revertStatusText:(NSString*)text {
    
    if (text == nil)
        return nil;
    
    if ([text length] == 0)
        return @"";
    
    return [text stringByReplacingOccurrencesOfString:@"\n\n" withString:@"\n"];
}

+ (void)separateTags:(ZStatus *)status {
    
    if ([status.text length] == 0)
        return;
    
    NSError *error = nil;
    //取得标签，如：#每日一文#
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"(#.{2,60}?#)"
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    
    __block NSUInteger count = 0;
    [regex enumerateMatchesInString:status.text options:0 range:NSMakeRange(0, [status.text length]) usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop) {
        
        NSRange matchRange = [match range];
        
        NSString *substringMatch = [status.text substringWithRange:matchRange];
        
        if ([substringMatch length] > 0) {
            if (status.statusTags == nil)
                status.statusTags = [[[NSMutableArray alloc] init] autorelease];
            
            [status.statusTags addObject:substringMatch];
        }
        
        if (++count >= 3) *stop = YES;
    }];
    
    status.text = [regex stringByReplacingMatchesInString:status.text
                                                  options:0
                                                    range:NSMakeRange(0, [status.text length])
                                             withTemplate:@""];
}


+ (NSString*)getAppStoreUrl:(ZStatus*)status {
    
    if ([status.attachments count] > 0) {
        
        for (NSDictionary *dictionary in status.attachments)
        {
            NSString *mimetype = [dictionary objectForKey:@"mimetype"];
            mimetype = [mimetype lowercaseString];
            
            NSString *url = [dictionary objectForKey:@"url"];
            NSString *lowerUrl = [url lowercaseString];
            
            NSRange range = [lowerUrl rangeOfString:@"itunes.apple.com"];
            
            if ([mimetype hasPrefix:@"text/url"] && range.location != NSNotFound) {
                return url;
            }
        }
    }
    
    return nil;
}

- (void)dealloc {
    
    self.createdAt = nil;
    self.text = nil;
    self.html = nil;
    self.inReplyToUserId = nil;
    self.inReplyToStatusId = nil;
    self.inReplyToScreenName = nil;
    self.inReplyToStatus = nil;
    self.sourceFrom = nil;
    self.coordinates = nil;
    self.attachments = nil;
    self.retweetedStatusId = nil;
    self.retweetedStatusAttachments = nil;
    self.statusTags = nil;
    self.user = nil;
    
    [super dealloc];
}

@end
