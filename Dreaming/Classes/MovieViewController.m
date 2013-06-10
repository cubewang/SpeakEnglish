//
//  MovieViewController.m
//  Dreaming
//
//  Created by Cube on 13-3-18.
//  Copyright (c) 2013年 Dreaming Team. All rights reserved.
//

#import "MovieViewController.h"

@implementation MovieViewController

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

//支持iOS6
-(BOOL)shouldAutorotate
{
    return YES;
}

//支持iOS6
-(NSUInteger)supportedInterfaceOrientations
{
    return 0;
}

- (id)initWithContentURL:(NSURL *)contentURL {
    self = [super initWithContentURL:contentURL];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(detectOrientation) name:@"UIDeviceOrientationDidChangeNotification" object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

- (void)detectOrientation {
    UIDeviceOrientation toInterfaceOrientation = [[UIDevice currentDevice] orientation];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.4];
    [UIView setAnimationCurve:2];
    
    if(toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft) 
    {
        self.view.transform = CGAffineTransformMakeRotation(-M_PI_2);
        [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeLeft];
        self.view.bounds = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.width);
    }
    else if (toInterfaceOrientation == UIInterfaceOrientationLandscapeRight) 
    {
        self.view.transform = CGAffineTransformMakeRotation(M_PI_2);
        [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeRight];
        self.view.bounds = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.width);
    }
    else if (toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) 
    {
        self.view.transform = CGAffineTransformMakeRotation(M_PI);
        [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortraitUpsideDown];
        self.view.bounds = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height);
    }
    else if (toInterfaceOrientation == UIInterfaceOrientationPortrait) 
    {
        self.view.transform = CGAffineTransformMakeRotation(0);
        [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait];
        self.view.bounds = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height);
    }
    
    [UIView commitAnimations];
    
    [[UIApplication sharedApplication] setStatusBarOrientation:[self interfaceOrientation] animated:NO];
}

@end
