//
//  ZUser.h
//  Dreaming
//
//  Created by Cube Wang on 12-8-14.
//  Copyright (c) 2012年 Dreaming Team. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZUser : NSObject {
    
}

@property (nonatomic, assign) NSInteger userID;
@property (nonatomic, retain) NSString* name;
@property (nonatomic, retain) NSString* screenName;
@property (nonatomic, retain) NSString* password;

@property (nonatomic, retain) NSString* location;        //地点名称
@property (nonatomic, retain) NSString* description;     //自我描述
@property (nonatomic, retain) NSString* profileImageUrl; //头像Url
@property (nonatomic, retain) NSString* followersCount;  //粉丝数
@property (nonatomic, retain) NSString* friendsCount;    //关注数
@property (nonatomic, retain) NSString* createAt;        //加入时间
@property (nonatomic, retain) NSString* statusesCount;   //微博数
@property (nonatomic, retain) NSString* blogUrl; 
@property (nonatomic, retain) NSString* gender; 
@property (nonatomic) BOOL following;                    //是否关注

+ (RKObjectMapping*)getObjectMapping;

@end
