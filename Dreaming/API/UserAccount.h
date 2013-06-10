//
//  DreamingClient.h
//  Dreaming
//
//  Created by Cube Wang on 12-8-31.
//  Copyright (c) 2012年 Dreaming Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZUser.h"

@interface UserAccount : NSObject {
    
}


+ (NSString *)getUserId;
+ (NSString *)getDisplayName;
+ (NSString *)getUserPassword;
+ (NSString *)getLocation;
+ (NSString *)getDescription;
+ (NSString *)getGender;
+ (NSString *)getProfileImageUrl;
+ (NSString *)getUserName;

+ (BOOL)setUserInfo:(ZUser *)user;

+ (void)clearUserInfo;


@end
