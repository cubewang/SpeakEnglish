//
//  ZDirectMessage.h
//  Dreaming
//
//  Created by Cube Wang on 12-8-14.
//  Copyright (c) 2012年 Dreaming Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZUser.h"

@interface ZDirectMessage : NSObject {
    
}

@property (nonatomic, assign) NSInteger messageId; //私信id
@property (nonatomic, assign) NSInteger senderId; //发送方id
@property (nonatomic, retain) NSString *text; //私信内容
@property (nonatomic, assign) NSInteger recipientId; //接受方id
@property (nonatomic, retain) NSString *senderName; //发送方name
@property (nonatomic, retain) NSString *recipientName; //接受方name
@property (nonatomic, retain) ZUser *sender; //发送方个人信息
@property (nonatomic, retain) ZUser *recipient; //接受方个人信息
@property (nonatomic, retain) NSDate* createdAt; // 发送时间

+ (RKObjectMapping*)getObjectMapping;

@end
