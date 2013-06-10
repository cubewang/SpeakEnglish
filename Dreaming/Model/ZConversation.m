//
//  ZConversation.m
//  Dreaming
//
//  Created by Cube Wang on 12-8-25.
//  Copyright (c) 2012年 Dreaming Team. All rights reserved.
//

#import "ZConversation.h"

@implementation ZConversation

@synthesize originalStatus;
@synthesize statusList;

+ (RKObjectMapping*)getObjectMapping
{
    RKObjectMapping* conversationMapping = [RKObjectMapping mappingForClass:[ZConversation class]];
    
    [conversationMapping mapKeyPath:@"original" toRelationship:@"originalStatus" withMapping:[ZStatus getObjectMapping]];
    [conversationMapping mapKeyPath:@"conversation" toRelationship:@"statusList" withMapping:[ZStatus getObjectMapping]];
    
    return conversationMapping;
}

- (void)dealloc {
    [super dealloc];
    
    //self.originalStatus = nil;
    //self.statusList = nil;
}

@end
