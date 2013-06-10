//
//  ZTextField.h
//  TestForInput
//
//  Created by curer on 11-10-16.
//  Copyright 2011 Dreaming Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HPGrowingTextView.h"

@interface ZTextField : UIView <HPGrowingTextViewDelegate>{
    HPGrowingTextView *textView;
    UIImage *backgroundImage;
    UIImage *textImage;
    
    UIImage *buttonImage;
    UIImage *buttonImagePress;
    
    UIView *parentView;
    UIView *brotherView;
    
    CGRect keyboardRect;
    
    id      delegate;
    
    BOOL   didAudioCommentShow;
}

- (void)setView:(UIView *)aParentView;
- (void)changeButtonText:(NSString *)text;

@property (nonatomic, retain) HPGrowingTextView *textView;
@property (nonatomic, retain) UIView *parentView;
@property (nonatomic, retain) UIView *brotherView;
@property (nonatomic, retain) UIButton *changTextButton;
@property (nonatomic, retain) UIButton *soundRecordButton;
@property (nonatomic, retain) UIButton *doneBtn;

@property (nonatomic, retain) UIImage *backgroundImage;
@property (nonatomic, retain) UIImage *textImage;
@property (nonatomic, retain) UIImage *buttonImage;
@property (nonatomic, retain) UIImage *buttonImagePress;
@property (nonatomic, retain) UIImageView *entryImageView;

@property (nonatomic, assign) id delegate;

@property (nonatomic, assign) CGRect keyboardRect;

@end

@protocol ZTextFieldDelegate <NSObject>

- (void)ZTextFieldButtonDidClicked:(ZTextField *)sender;
- (void)ZTextFieldKeyboardPopup:(ZTextField *)sender;
- (void)ZTextFieldKeyboardDrop:(ZTextField *)sender;
- (void)ZTextFieldSoundRecordButtonClicked;
- (void)ZTextFieldSoundRecordButtonTouchup;

@end
