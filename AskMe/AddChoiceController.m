//
//  AddChoiceController.m
//  AskMe
//
//  Created by Daniel Kador on 7/4/11.
//  Copyright 2011 Dorkfort.com. All rights reserved.
//

#import "AddChoiceController.h"


@implementation AddChoiceController

@synthesize delegate=delegate_;

#pragma mark - View lifecycle

- (void)loadView {
    UIView *theView = [[UIView alloc] init];
    self.view = theView;
    [theView release];
    
    [self.view setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
    
    self.navigationItem.title = @"Add a choice";
    
    CGRect bounds = [[UIScreen mainScreen] bounds];
        
    UITextField *theField = [[UITextField alloc] init];
    theField.borderStyle = UITextBorderStyleRoundedRect;
    theField.frame = CGRectMake(10, 65, bounds.size.width - 20, 44);
    theField.delegate = self;
    theField.placeholder = @"Enter a choice";
    theField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [self.view addSubview:theField];
    [theField becomeFirstResponder];
    [theField release];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

# pragma mark - UITextFieldDelegate impl

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    [self.delegate choiceAdded:textField.text];
    return YES;
}

@end
