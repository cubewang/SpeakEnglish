//
//  ZOAuthUser.h
//  Dreaming
//
//  Created by yg curer on 12-9-5.
//  Copyright (c) 2012年 Dreaming Team. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ZUser;
@interface ZOAuthUser : NSObject

@property (nonatomic, retain) ZUser *user;
@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) NSString *password;
@property (nonatomic, assign) BOOL hasRegistered;

+ (RKObjectMapping*)getObjectMapping;

@end
