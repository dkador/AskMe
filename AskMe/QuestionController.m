//
//  QuestionController.m
//  AskMe
//
//  Created by Daniel Kador on 7/2/11.
//  Copyright 2011 Dorkfort.com. All rights reserved.
//

#import "QuestionController.h"
#import "ChoicesController.h"
#import "Util.h"

#import <QuartzCore/QuartzCore.h>


@interface QuestionController()

- (void) nextSelected;

@end


@implementation QuestionController

@synthesize questionTextView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc {
    self.questionTextView = nil;
    [super dealloc];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
        
    [[self view] setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
    
    UIBarButtonItem *nextButton = [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStyleDone target:self action:@selector(nextSelected)];
    [nextButton setEnabled:NO];
    [[self navigationItem] setRightBarButtonItem:nextButton];
    [nextButton release];
        
    UITextView *theTextView = [[UITextView alloc] init];
    [self setQuestionTextView:theTextView];
    [theTextView release];
    [[self questionTextView] setDelegate:self];
    [[self questionTextView] setFont:[UIFont systemFontOfSize:14]];
    [[self view] addSubview:[self questionTextView]];
    [[self questionTextView] becomeFirstResponder];
    self.questionTextView.clipsToBounds = YES;
    [self willRotateToInterfaceOrientation:[UIApplication sharedApplication].statusBarOrientation duration:NSTimeIntervalSince1970];
}

-(void)viewDidAppear:(BOOL)animated {
    self.navigationItem.title = @"New Question";
}

- (void)viewWillAppear:(BOOL)animated {
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    CGFloat height;
    CGFloat width;
    // status bar and navigation bar
    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
        height = [Util getCurrentDeviceWidth] - 20 - 32;
        height -= 162;
        width = [Util getCurrentDeviceHeight];
    } else {
        height = [Util getCurrentDeviceHeight] - 20 - 44;
        height -= 216;        
        width = [Util getCurrentDeviceWidth];
    }
    self.questionTextView.frame = CGRectMake(0, 0, width, height);
}

# pragma mark - private impl

- (void)nextSelected {
    NSLog(@"next selected");
    ChoicesController *choicesController = [[ChoicesController alloc] initWithStyle:UITableViewStyleGrouped];
    [choicesController setQuestion:[[self questionTextView] text]];
    self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil] autorelease];
    [[self navigationController] pushViewController:choicesController animated:YES];
    [choicesController release];
}

# pragma mark - UITextViewDelegate impl

- (void)textViewDidChange:(UITextView *)textView {
    Boolean hasContent = [[[self questionTextView] text] length] > 0;
    [[[self navigationItem] rightBarButtonItem] setEnabled:hasContent];
    
}

@end
