//
//  ZTextField.m
//  TestForInput
//
//  Created by curer on 11-10-16.
//  Copyright 2011 Dreaming Team. All rights reserved.
//

#import "ZTextField.h"
#import "GlobalDef.h"


@implementation ZTextField

@synthesize textView;
@synthesize backgroundImage;
@synthesize parentView;
@synthesize delegate;
@synthesize keyboardRect;
@synthesize brotherView;

@synthesize textImage;
@synthesize buttonImage;
@synthesize buttonImagePress;
@synthesize changTextButton;
@synthesize soundRecordButton;
@synthesize doneBtn;
@synthesize entryImageView;

- (id)init
{
    return [self initWithFrame:CGRectZero];
}

- (id)initWithFrame:(CGRect)frame
{
    return [super initWithFrame:frame];
}

- (void)changeButtonText:(NSString *)text
{
    if ([text length] == 0) {
        [self.soundRecordButton setTitle:NSLocalizedString(@"按住，用英语说观点", @"") forState:UIControlStateNormal];
    }
    else {
        [self.soundRecordButton setTitle:text forState:UIControlStateNormal];
    }
}

- (void)setView:(UIView *)aParentView
{
    if (self) {
        
        CGFloat viewHeight = [[UIDevice currentDevice] userInterfaceIdiom ] == UIUserInterfaceIdiomPhone ? 416 : 960;
        
        self.frame = CGRectMake(0, viewHeight - 48, SCREEN_WIDTH, 48);
        
        didAudioCommentShow = YES;
        
        self.parentView = aParentView;
        self.backgroundImage = [UIImage imageNamed:@"messageTextBg.png"];
        self.buttonImage = [UIImage imageNamed:@"messageTextSend.png"];
        self.textImage = [UIImage imageNamed:@"messageText.png"];
        UIView *containerView = self;
        
        self.changTextButton = [[[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/64, 4, 44, 44)]autorelease];
        [self.changTextButton setImage:[UIImage imageNamed:@"text_comment@2x"] forState:UIControlStateNormal];
        [self.changTextButton addTarget:self action:@selector(changTextButtonClick) forControlEvents:UIControlEventTouchUpInside];
        
        self.soundRecordButton = [[[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/6.4, 4, SCREEN_WIDTH/1.3, 44)] autorelease];
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            
            [self.soundRecordButton setBackgroundImage:[UIImage imageNamed:@"audio_comment@2x"] forState:UIControlStateNormal];
            [self.soundRecordButton setBackgroundImage:[UIImage imageNamed:@"audio_comment_s@2x"] forState:UIControlStateHighlighted];
        }
        else {
            [self.soundRecordButton setBackgroundImage:[UIImage imageNamed:@"audio_comment_iPad"] forState:UIControlStateNormal];
            [self.soundRecordButton setBackgroundImage:[UIImage imageNamed:@"audio_comment_iPad_s"] forState:UIControlStateHighlighted];
        }
        
        [self.soundRecordButton setTitle:NSLocalizedString(@"按住，用英语说观点", @"") forState:UIControlStateNormal];
        self.soundRecordButton.titleLabel.font = [UIFont systemFontOfSize:14.f];
        [self.soundRecordButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        
        [self.soundRecordButton addTarget:self action:@selector(soundRecordButtonClick) forControlEvents:UIControlEventTouchDown];
        [self.soundRecordButton addTarget:self action:@selector(soundRecordButtonTouchUp) forControlEvents:UIControlEventTouchUpInside| UIControlEventTouchUpOutside];
        
        textView = [[HPGrowingTextView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/6.4, 10, SCREEN_WIDTH/1.45, 40)];
        textView.contentInset = UIEdgeInsetsMake(0, 5, 0, 5);
        
        textView.minNumberOfLines = 1;
        textView.maxNumberOfLines = 4;
        textView.returnKeyType = UIReturnKeyDefault; 
        textView.font = [UIFont systemFontOfSize:15.0f];
        textView.delegate = self;
        textView.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(5, 0, 5, 0);
        textView.backgroundColor = [UIColor whiteColor];
        
        self.entryImageView = [[[UIImageView alloc] init] autorelease];
        self.entryImageView.frame = CGRectMake(SCREEN_WIDTH/6.4, 8, SCREEN_WIDTH/1.45, 38);
        self.entryImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        
        if (textImage) {
            self.entryImageView.image = [textImage stretchableImageWithLeftCapWidth:13
                                                                       topCapHeight:22];
        }
        else {
            self.entryImageView.image = [[UIImage imageNamed:@"MessageEntryInputField.png"] 
                                    stretchableImageWithLeftCapWidth:13 
                                    topCapHeight:22];
        }
        
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.frame = CGRectMake(0, 0, containerView.frame.size.width, containerView.frame.size.height);
        imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        
        imageView.image = [UIImage imageNamed:@"comment_bg@2x.png"];

        textView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        // view hierachy
        [containerView addSubview:imageView];
        [containerView addSubview:textView];
        [containerView addSubview:entryImageView];
        
        [containerView addSubview:changTextButton];
        [containerView addSubview:self.soundRecordButton];
        
        [entryImageView release];
        [imageView release];
        
        self.doneBtn = [[[UIButton alloc] init]autorelease];
        
        self.doneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.doneBtn.frame = CGRectMake(containerView.frame.size.width - 50, 2, 48, 48);
        [self.doneBtn setTitle:NSLocalizedString(@"发送",@"" )  forState:UIControlStateNormal];
        
        self.doneBtn.titleLabel.font = [UIFont boldSystemFontOfSize:14.0f];
        
        [self.doneBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.doneBtn addTarget:self action:@selector(resignTextView) forControlEvents:UIControlEventTouchUpInside];
        [self.doneBtn setBackgroundImage:[UIImage imageNamed:@"MessageEntrySendButton@2x"] forState:UIControlStateNormal];
        [containerView addSubview:self.doneBtn];
        containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(keyboardWillShow:) 
                                                     name:UIKeyboardWillShowNotification 
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(keyboardWillHide:) 
                                                     name:UIKeyboardWillHideNotification 
                                                   object:nil];        
    }
    
    textView.hidden = YES;
    self.doneBtn.hidden = YES;
    self.entryImageView.hidden = YES;
    
    [self sendSubviewToBack:textView];
    [self sendSubviewToBack:self.doneBtn];
}

- (void)changTextButtonClick {
    
    if (didAudioCommentShow) {
        
        [self.changTextButton setImage:[UIImage imageNamed:@"audio_comment_mini@2x"] forState:UIControlStateNormal];
        
        [self sendSubviewToBack:self.soundRecordButton];
        self.soundRecordButton.hidden = YES;
        
        textView.hidden = NO;
        self.doneBtn.hidden = NO;
        self.entryImageView.hidden = NO;
        
        [self bringSubviewToFront:textView];
        [self bringSubviewToFront:self.doneBtn];
        [self bringSubviewToFront:self.entryImageView];
        
        didAudioCommentShow = NO;
        
        [textView becomeFirstResponder];
    }
    
    else {
        
        [self.changTextButton setImage:[UIImage imageNamed:@"text_comment@2x"] forState:UIControlStateNormal];
        
        textView.hidden = YES;
        self.doneBtn.hidden = YES;
        self.entryImageView.hidden = YES;
        
        [self sendSubviewToBack:textView];
        [self sendSubviewToBack:self.doneBtn];
        [self sendSubviewToBack:self.entryImageView];
        
        self.soundRecordButton.hidden = NO;
        [self bringSubviewToFront:self.soundRecordButton];
        
        didAudioCommentShow = YES;
        
        [textView resignFirstResponder];
    }
}

- (void)dealloc
{
    textView.delegate = nil;
    delegate = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:UIKeyboardWillShowNotification 
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:UIKeyboardWillHideNotification 
                                                  object:nil];
    
    [backgroundImage release];
    [textView release];

    [brotherView release];
    [textImage release];
    [buttonImage release];
    [buttonImagePress release];
    self.changTextButton = nil;
    self.soundRecordButton = nil; 
    self.doneBtn = nil;
    self.entryImageView = nil;
    self.parentView = nil;
    
    [super dealloc];
}

#pragma mark delegate

- (void)soundRecordButtonClick {
    if ([delegate respondsToSelector:@selector(ZTextFieldSoundRecordButtonClicked)]) {
       
        [delegate ZTextFieldSoundRecordButtonClicked];
    }
}

- (void)soundRecordButtonTouchUp {
    
    if ([delegate respondsToSelector:@selector(ZTextFieldSoundRecordButtonTouchup)]) {
        
        [delegate ZTextFieldSoundRecordButtonTouchup];
    }
}


- (void)resignTextView
{
    if ([delegate respondsToSelector:@selector(ZTextFieldButtonDidClicked:)]) {
        [delegate ZTextFieldButtonDidClicked:self];
    }
}

//Code from Brett Schumann
- (void)keyboardWillShow:(NSNotification *)note {
   
    // get keyboard size and loctaion
    CGRect keyboardBounds;
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // Need to translate the bounds to account for rotation.
    //keyboardBounds = [self.parentView convertRect:keyboardBounds toView:nil];
    keyboardBounds = [self.superview convertRect:keyboardBounds toView:nil];
    keyboardRect = keyboardBounds;
    
    // get a rect for the textView frame
    CGRect containerFrame = self.frame;
    containerFrame.origin.y = self.superview.bounds.size.height - (keyboardBounds.size.height + containerFrame.size.height);
    // animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
    // set views with new info
    self.frame = containerFrame;
    
    if (self.brotherView) 
    {
        CGRect viewFrame = self.brotherView.frame;
        viewFrame.size.height -= keyboardBounds.size.height;
        self.brotherView.frame = viewFrame;
    }
    
    // commit animations
    [UIView commitAnimations];
    
    didAudioCommentShow = YES;
    
    [self changTextButtonClick];
    
    if ([delegate respondsToSelector:@selector(ZTextFieldKeyboardPopup:)]) {
        [delegate ZTextFieldKeyboardPopup:self];
    }
}

- (void)keyboardWillHide:(NSNotification *)note {
    
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // get a rect for the textView frame
    CGRect containerFrame = self.frame;
    containerFrame.origin.y = self.superview.bounds.size.height - containerFrame.size.height;
    
    // animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
    // set views with new info
    self.frame = containerFrame;
    
    if (self.brotherView) 
    {
        CGRect viewFrame = self.brotherView.frame;
        viewFrame.size.height += keyboardRect.size.height;
        self.brotherView.frame = viewFrame;
    }
    
    // commit animations
    [UIView commitAnimations];
    
    didAudioCommentShow = NO;
    
    [self changTextButtonClick];
    
    if ([delegate respondsToSelector:@selector(ZTextFieldKeyboardDrop:)]) {
        [delegate ZTextFieldKeyboardDrop:self];
    }
}

- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height
{
    float diff = (growingTextView.frame.size.height - height);
    
    CGRect r = self.frame;
    r.size.height -= diff;
    r.origin.y += diff;
    self.frame = r;
}

- (BOOL)becomeFirstResponder
{
    [super becomeFirstResponder];
    return [self.textView becomeFirstResponder];
}

- (BOOL)resignFirstResponder
{
    [super resignFirstResponder];
    return [self.textView resignFirstResponder];
}


@end
