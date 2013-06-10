//
//  ZFriendship.h
//  Dreaming
//
//  Created by yg curer on 12-9-14.
//  Copyright (c) 2012年 Dreaming Team. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZFriendship : NSObject

@property (nonatomic, assign) BOOL isFollowed;
@property (nonatomic, assign) BOOL isFollowedBy;
@property (nonatomic, assign) NSInteger userId;

+ (RKObjectMapping*)getObjectMapping;

@end
