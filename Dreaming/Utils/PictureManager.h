//
//  PictureManager.h
//  Dreaming
//
//  Created by curer on 11-9-11.
//  Copyright 2011 Dreaming Team. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PictureManager : NSObject {

}

+ (BOOL)CreateThumbByImagePath:(NSString *)path;

+ (UIImage *)GetThumbImageByImagePath:(NSString*)path;

+ (UIImage *)scaleAndRotateImage:(UIImage *)image andMaxLen:(int)kMaxResolution;

@end
