//
//  ZFriendship.m
//  Dreaming
//
//  Created by yg curer on 12-9-14.
//  Copyright (c) 2012年 Dreaming Team. All rights reserved.
//

#import "ZFriendship.h"

@implementation ZFriendship

@synthesize isFollowed;
@synthesize isFollowedBy;
@synthesize userId;

- (void)dealloc
{
    [super dealloc];
}

+ (RKObjectMapping*)getObjectMapping {
    
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[ZFriendship class]];
    
    [mapping mapKeyPathsToAttributes:@"relationship.source.id", @"userId"
                ,@"relationship.source.followed_by", @"isFollowedBy"
                ,@"relationship.source.following", @"isFollowed"
     ,nil];
    
    return mapping;
}

@end
