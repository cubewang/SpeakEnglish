//
//  ZDirectMessage.m
//  Dreaming
//
//  Created by Cube Wang on 12-8-14.
//  Copyright (c) 2012年 Dreaming Team. All rights reserved.
//

#import "ZDirectMessage.h"

@implementation ZDirectMessage

@synthesize messageId;
@synthesize senderId;
@synthesize text;
@synthesize recipientId;
@synthesize createdAt;
@synthesize senderName;
@synthesize sender;
@synthesize recipientName;
@synthesize recipient;

- (void) dealloc {
    
    self.text = nil;
    self.createdAt = nil;
    self.senderName = nil;
    self.sender = nil;
    self.recipientName = nil;
    self.recipient = nil;
    
    [super dealloc];
}

+ (RKObjectMapping*)getObjectMapping {
    
    RKObjectMapping* messageMapping = [RKObjectMapping mappingForClass:[ZDirectMessage class]];
    [messageMapping mapKeyPathsToAttributes:@"id",@"messageId",
     @"sender_id",@"senderId",
     @"text",@"text",
     @"recipient_id", @"recipientId",
     @"created_at",@"createdAt",
     @"sender_screen_name",@"senderName",
     @"recipient_screen_name",@"recipientName",nil];
        
    [messageMapping mapRelationship:@"sender" withMapping:[ZUser getObjectMapping]];
    
    [messageMapping mapRelationship:@"recipient" withMapping:[ZUser getObjectMapping]];
    
    return messageMapping;
}

@end
