//
//  ZPhotoSource.h
//
//
//  Created by Devin Doty on 7/3/10July3.
//  Copyright 2012 Dreaming Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EGOPhotoGlobal.h"

@interface ZPhotoSource : NSObject <EGOPhotoSource> {
	
	NSArray *_photos;
	NSInteger _numberOfPhotos;

}

- (id)initWithPhotos:(NSArray*)photos;

@end
