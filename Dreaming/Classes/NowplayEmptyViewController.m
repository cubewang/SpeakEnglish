//
//  NowplayEmptyViewController.m
//  Dreaming
//
//  Created by Cube on 13-1-9.
//  Copyright (c) 2013年 Dreaming Team. All rights reserved.
//

#import "NowplayEmptyViewController.h"

@interface NowplayEmptyViewController ()

@property (nonatomic, retain) IBOutlet UIImageView *backgroundView;
@property (nonatomic, retain) IBOutlet UILabel *nowplayEmptyLabel;
@property (nonatomic, retain) IBOutlet UILabel *nowplayEmptyDescriptionLabel;

@end

@implementation NowplayEmptyViewController

@synthesize backgroundView;
@synthesize nowplayEmptyLabel;
@synthesize nowplayEmptyDescriptionLabel;


- (void)dealloc {

    [super dealloc];
    
    self.backgroundView = nil;
    self.nowplayEmptyLabel = nil;
    self.nowplayEmptyDescriptionLabel = nil;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    UIButton *buttonLeft = [[[UIButton alloc] initWithFrame:CGRectMake(5, 0, 44, 44)] autorelease];
    [buttonLeft setImage:[UIImage imageNamed:@"back@2x"] forState:UIControlStateNormal];
    [buttonLeft addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *itemLeft = [[[UIBarButtonItem alloc] initWithCustomView:buttonLeft] autorelease]; 
    
    self.navigationItem.leftBarButtonItem = itemLeft;
    
    self.nowplayEmptyLabel.text = NSLocalizedString(@"没有播放英语音频", @"");
    self.nowplayEmptyDescriptionLabel.text = NSLocalizedString(@"播放中的英语音频可以在这里查看", @"");
    
    if (IS_IPHONE_5) {
        self.backgroundView.image = [UIImage imageNamed:@"nowplayEmpty-568h@2x.jpg"];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.viewDeckController.enabled = NO;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    self.viewDeckController.enabled = YES;
}

#pragma mark * UI Actions

- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
