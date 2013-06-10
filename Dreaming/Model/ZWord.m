//
//  Word.m
//  Dreaming
//
//  Created by Cube on 11-5-16.
//  Copyright 2011 Dreaming Team. All rights reserved.
//

#import "ZWord.h"


@implementation ZWord

@synthesize Key;
@synthesize PhoneticSymbol;
@synthesize Pronunciation;
@synthesize AcceptationList;


+ (RKObjectMapping*)getObjectMapping {
    
    RKObjectMapping* wordMapping = [RKObjectMapping mappingForClass:[ZWord class]];
    [wordMapping mapKeyPath:@"dict.key" toAttribute:@"Key"];
    [wordMapping mapKeyPath:@"dict.ps" toAttribute:@"PhoneticSymbol"];
    [wordMapping mapKeyPath:@"dict.pron" toAttribute:@"Pronunciation"];
    [wordMapping mapKeyPath:@"dict.acceptation" toAttribute:@"AcceptationList"];
    
    return wordMapping;
}

- (void)dealloc {
    self.Key = nil;
    self.PhoneticSymbol = nil;
    self.Pronunciation = nil;
    self.AcceptationList = nil;
    
    [super dealloc];
}

@end

