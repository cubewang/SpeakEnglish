//
//  ZUser.m
//  Dreaming
//
//  Created by Cube Wang on 12-8-14.
//  Copyright (c) 2012年 Dreaming Team. All rights reserved.
//

#import "ZUser.h"

@implementation ZUser

@synthesize userID;
@synthesize name;
@synthesize screenName;
@synthesize password;

@synthesize location;
@synthesize description;
@synthesize profileImageUrl;
@synthesize followersCount;
@synthesize friendsCount;
@synthesize createAt;
@synthesize statusesCount;
@synthesize following;
@synthesize blogUrl;
@synthesize gender;

+ (RKObjectMapping*)getObjectMapping {
    
    RKObjectMapping* userMapping = [RKObjectMapping mappingForClass:[ZUser class]];
    [userMapping mapKeyPath:@"id" toAttribute:@"userID"];
    [userMapping mapKeyPath:@"screen_name" toAttribute:@"screenName"];
    [userMapping mapKeyPath:@"name" toAttribute:@"name"];
    [userMapping mapKeyPath:@"password" toAttribute:@"password"];
    
    [userMapping mapKeyPath:@"location" toAttribute:@"location"];
    [userMapping mapKeyPath:@"description" toAttribute:@"description"];
    [userMapping mapKeyPath:@"profile_image_url" toAttribute:@"profileImageUrl"];
    [userMapping mapKeyPath:@"followers_count" toAttribute:@"followersCount"];
    [userMapping mapKeyPath:@"friends_count" toAttribute:@"friendsCount"];
    [userMapping mapKeyPath:@"create_at" toAttribute:@"createAt"];
    [userMapping mapKeyPath:@"statuses_count" toAttribute:@"statusesCount"];
    [userMapping mapKeyPath:@"following" toAttribute:@"following"];
    [userMapping mapKeyPath:@"url" toAttribute:@"blogUrl"];
    [userMapping mapKeyPath:@"gender" toAttribute:@"gender"];
    
    return userMapping;
}

- (void)dealloc {
    self.name = nil;
    self.screenName = nil;
    self.password = nil;
    
    self.location = nil;
    self.description = nil;
    self.profileImageUrl = nil;
    self.followersCount = nil;
    self.friendsCount = nil;
    self.createAt = nil;
    self.statusesCount = nil;
    self.blogUrl = nil;
    self.gender = nil;

    [super dealloc];
}

@end
