//
//  ZOAuthUser.m
//  Dreaming
//
//  Created by yg curer on 12-9-5.
//  Copyright (c) 2012年 Dreaming Team. All rights reserved.
//

#import "ZOAuthUser.h"
#import "ZUser.h"

@implementation ZOAuthUser

@synthesize user;
@synthesize username;
@synthesize password;
@synthesize hasRegistered;

- (void)dealloc
{
    self.user = nil;
    self.username = nil;
    self.password = nil;
    
    [super dealloc];
}

+ (RKObjectMapping*)getObjectMapping {
    
    RKObjectMapping* statusMapping = [RKObjectMapping mappingForClass:[ZOAuthUser class]];
    [statusMapping mapKeyPathsToAttributes:@"registered", @"hasRegistered",
     @"auth.username", @"username",
     @"auth.password", @"password",
     nil];
    
    //[statusMapping mapKeyPath:@"attachments" toAttribute:@"attachments"];
    //[statusMapping mapKeyPath:@"geo.coordinates" toAttribute:@"coordinates"];
    
    [statusMapping mapRelationship:@"user" withMapping:[ZUser getObjectMapping]];
    
    return statusMapping;
}

@end
