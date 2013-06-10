//
//  ZPhotoSource.m
//
//
//  Created by Devin Doty on 7/3/10July3.
//  Copyright 2012 Dreaming Team. All rights reserved.
//

#import "ZPhotoSource.h"


@implementation ZPhotoSource

@synthesize photos=_photos;
@synthesize numberOfPhotos=_numberOfPhotos;


- (id)initWithPhotos:(NSArray*)photos{
	
	if (self = [super init]) {
		
		_photos = [photos retain];
		_numberOfPhotos = [_photos count];
		
	}
	
	return self;

}

- (id <EGOPhoto>)photoAtIndex:(NSInteger)index{
	
	return [_photos objectAtIndex:index];
	
}

- (void)dealloc{
	
	[_photos release], _photos=nil;
	[super dealloc];
}

@end
