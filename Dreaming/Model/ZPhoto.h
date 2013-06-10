//
//  ZPhoto.h
//  
//
//  Created by Devin Doty on 7/3/10July3.
//  Copyright 2012 Dreaming Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EGOPhotoGlobal.h"


@interface ZPhoto : NSObject <EGOPhoto>{
	
	NSURL *_URL;
	NSString *_caption;
	CGSize _size;
	UIImage *_image;
	
	BOOL _failed;
	
}

- (id)initWithImageURL:(NSURL*)aURL name:(NSString*)aName image:(UIImage*)aImage;
- (id)initWithImageURL:(NSURL*)aURL name:(NSString*)aName;
- (id)initWithImageURL:(NSURL*)aURL;
- (id)initWithImage:(UIImage*)aImage;
@end
