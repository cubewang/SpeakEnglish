//
//  UserAccount.m
//  Dreaming
//
//  Created by Cube Wang on 12-8-31.
//  Copyright (c) 2012年 Dreaming Team. All rights reserved.
//

#import "UserAccount.h"

NSString *const kUserId =   @"DreamingUserId";
NSString *const kName =     @"DreamingName";
NSString *const kPassword = @"DreamingPassword";
NSString *const kScreenName =  @"DreamingScreenName";
NSString *const kLocation =    @"DreamingLocation";
NSString *const kDescription = @"DreamingDescription";
NSString *const kProfileImageUrl = @"DreamingProfileImageUrl";
NSString *const kCreateAt =    @"DreamingCreateAt";
NSString *const kGender =    @"DreamingGender";

@implementation UserAccount


+ (NSString *)getUserId
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:kUserId];
}

+ (NSString *)getUserName
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:kScreenName];
}

+ (NSString *)getUserPassword
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:kPassword];
}

+ (NSString *)getProfileImageUrl
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:kProfileImageUrl];
}

+ (NSString *)getLocation
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:kLocation];
}

+ (NSString *)getDescription
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:kDescription];
}

+ (NSString *)getGender
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:kGender];
}

+ (NSString *)getDisplayName
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:kName];
}

+ (BOOL)setUserInfo:(ZUser *)user
{
    if (user == nil)
        return NO;
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%d", user.userID] forKey:kUserId];
    
    if (user.password)
        [[NSUserDefaults standardUserDefaults] setObject:user.password forKey:kPassword];
    
    if (user.screenName)
        [[NSUserDefaults standardUserDefaults] setObject:user.screenName forKey:kScreenName];
    
    if (user.profileImageUrl)
        [[NSUserDefaults standardUserDefaults] setObject:user.profileImageUrl forKey:kProfileImageUrl];
    
    if (user.location) 
        [[NSUserDefaults standardUserDefaults] setObject:user.location forKey:kLocation];
    
    if (user.description) 
        [[NSUserDefaults standardUserDefaults] setObject:user.description forKey:kDescription];
    
    if (user.gender)
        [[NSUserDefaults standardUserDefaults] setObject:user.gender forKey:kGender];
    
    if (user.name)
        [[NSUserDefaults standardUserDefaults] setObject:user.name forKey:kName];
   
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    return YES;
}

+ (void)clearUserInfo
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUserId];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kPassword];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kScreenName];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kProfileImageUrl];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kLocation];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kDescription];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kGender];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kName];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
