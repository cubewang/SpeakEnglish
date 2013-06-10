//
//  ZConversation.h
//  Dreaming
//
//  Created by Cube Wang on 12-8-25.
//  Copyright (c) 2012年 Dreaming Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZStatus.h"

@interface ZConversation : NSObject

/**
 * The first status in conversation 
 */
@property (nonatomic, retain) ZStatus* originalStatus;

/**
 * All status list in conversation 
 */
@property (nonatomic, retain) NSMutableArray* statusList;


+ (RKObjectMapping*)getObjectMapping;

@end
