//
//  VoteView.h
//  
//
//  Created by cg on 12-3-28.
//  Copyright 2012 Dreaming Team. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>


@protocol VoteViewDelegate

- (void)voteViewButtonDidClick:(id)customAlertView atIndex:(NSInteger)index;

@end

@interface VoteView : UIView {
	UIImageView *backgroundView;
	id<VoteViewDelegate>delegate;
	UIView *superView;
	UIView *alertShowView;
}

@property(assign,nonatomic)UIImageView *backgroundView;

- (id)initWithCancelbutton:(NSString*)cancelName OtherButton:(NSString*)otherButton Delegate:(id)delegate SuperView:(UIView*)superView;
-(void)setAlertBackgroundImage:(NSString *)imagename;

-(void)alertShow;

@end
