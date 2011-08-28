//
//  QuestionController.m
//  AskMe
//
//  Created by Daniel Kador on 7/2/11.
//  Copyright 2011 Dorkfort.com. All rights reserved.
//

#import "QuestionController.h"
#import "ChoicesController.h"

#import <QuartzCore/QuartzCore.h>


@interface QuestionController()

- (void) nextSelected;

@end


@implementation QuestionController

@synthesize questionTextView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    self.questionTextView = nil;
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[self view] setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
    [[self navigationItem] setTitle:@"AskMe"];
    UIBarButtonItem *nextButton = [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStyleDone target:self action:@selector(nextSelected)];
    [nextButton setEnabled:NO];
    [[self navigationItem] setRightBarButtonItem:nextButton];
    [nextButton release];
    
    CGRect bounds = [[UIScreen mainScreen] bounds];
    
    UILabel *label = [[UILabel alloc] init];
    [label setFrame:CGRectMake(20, 7, bounds.size.width - 40, 44)];
    [label setText:@"Enter your question."];
    [label setBackgroundColor:[UIColor clearColor]];
    [[self view] addSubview:label];
    
    UITextView *theTextView = [[UITextView alloc] init];
    [self setQuestionTextView:theTextView];
    [theTextView release];
    [[self questionTextView] setFrame:CGRectMake(20, 50, bounds.size.width - 40, 140)];
    [[self questionTextView] setDelegate:self];
    [[self questionTextView] setFont:[UIFont systemFontOfSize:14]];
    [[self view] addSubview:[self questionTextView]];
    [[self questionTextView] becomeFirstResponder];
    self.questionTextView.layer.cornerRadius = 5;
    self.questionTextView.clipsToBounds = YES;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

# pragma mark - private impl

- (void)nextSelected {
    NSLog(@"next selected");
    ChoicesController *choicesController = [[ChoicesController alloc] initWithStyle:UITableViewStyleGrouped];
    [choicesController setQuestion:[[self questionTextView] text]];
    [[self navigationController] pushViewController:choicesController animated:YES];
    [choicesController release];
}

# pragma mark - UITextViewDelegate impl

- (void)textViewDidChange:(UITextView *)textView {
    Boolean hasContent = [[[self questionTextView] text] length] > 0;
    [[[self navigationItem] rightBarButtonItem] setEnabled:hasContent];
    
}

@end
