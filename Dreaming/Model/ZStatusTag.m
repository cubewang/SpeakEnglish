//
//  ZStatusTag.m
//  Dreaming
//
//  Created by cg on 12-8-23.
//  Copyright (c) 2012年 Dreaming Team. All rights reserved.
//

#import "ZStatusTag.h"

@implementation ZStatusTag

@synthesize tagName;


+ (RKObjectMapping*)getObjectMapping {
    
    RKObjectMapping* tagMapping = [RKObjectMapping mappingForClass:[ZStatusTag class]];
    
    [tagMapping mapKeyPath:@"name" toAttribute:@"tagName"];
    
    return tagMapping;
}

- (void)dealloc {
    
    self.tagName = nil;
    
    [super dealloc];
}

@end
