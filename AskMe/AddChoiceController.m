//
//  AddChoiceController.m
//  AskMe
//
//  Created by Daniel Kador on 7/4/11.
//  Copyright 2011 Dorkfort.com. All rights reserved.
//

#import "AddChoiceController.h"
#import "Util.h"


@interface AddChoiceController()

- (void) done;

@end

@implementation AddChoiceController

@synthesize delegate=delegate_;
@synthesize textView=textView_;

- (void)dealloc {
    [textView_ release];
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)loadView {
    UIView *theView = [[UIView alloc] init];
    self.view = theView;
    [theView release];
    
    [self.view setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
    
    self.navigationItem.title = @"Add a choice";
                
    UITextView *theField = [[UITextView alloc] init];
    theField.delegate = self;
    theField.font = [UIFont systemFontOfSize:16];
    [self.view addSubview:theField];
    [theField becomeFirstResponder];
    self.textView = theField;
    [self willRotateToInterfaceOrientation:[UIApplication sharedApplication].statusBarOrientation duration:NSTimeIntervalSince1970];
    [theField release];
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(done)];
    [doneButton setEnabled:NO];
    [[self navigationItem] setRightBarButtonItem:doneButton];
    [doneButton release];
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
    self.textView.frame = CGRectMake(0, 0, width, height);
}

# pragma mark - UITextViewDelegate impl

- (void)textViewDidChange:(UITextView *)textView {
    // enable/disable done button
    self.navigationItem.rightBarButtonItem.enabled = ![self.textView.text isEqualToString:@""];
}

# pragma mark - impl

- (void)done {
    [self.delegate choiceAdded:self.textView.text];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
