//
//  Word.h
//  Dreaming
//
//  Created by Cube on 11-5-16.
//  Copyright 2011 Dreaming Team. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ZWord : NSObject {
}

@property (nonatomic, retain) NSString *Key;
@property (nonatomic, retain) NSMutableArray *PhoneticSymbol; //音标
@property (nonatomic, retain) NSMutableArray *Pronunciation;  //发音的链接
@property (nonatomic, retain) NSMutableArray *AcceptationList; //词义

+ (RKObjectMapping*)getObjectMapping;

@end
