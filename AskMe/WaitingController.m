//
//  WaitingController.m
//  AskMe
//
//  Created by Daniel Kador on 8/13/11.
//  Copyright 2011 Dorkfort.com. All rights reserved.
//

#import "WaitingController.h"
#import "QuestionController.h"
#import "ASIHTTPRequest.h"
#import "CJSONSerializer.h"
#import "CJSONDeserializer.h"
#import "Util.h"
#import "KeenClient.h"

#import <QuartzCore/QuartzCore.h>
#import <Parse/Parse.h>


@implementation WaitingController

//NSString * const ServerHost = @"192.168.1.50";
//NSString * const ServerAddress = @"http://192.168.1.50:3000";

NSString * const ServerHost = @"askme.herokuapp.com";
NSString * const ServerAddress = @"http://askme.herokuapp.com";

@synthesize question=question_;
@synthesize answer=answer_;
@synthesize choices=choices_;
@synthesize questionId=questionId_;
@synthesize questionAlreadyCreated=questionAlreadyCreated_;
@synthesize refreshTimer=refreshTimer_;

- (id) initWithQuestion: (NSString *) question AndChoices: (NSArray *) choices {
    if (self = [super initWithStyle:UITableViewStyleGrouped]) {
        self.question = question;
        self.answer = @"Waiting for answer";
        self.choices = choices;
    }
    return self;
}

- (void)dealloc {
    [question_ release];
    [answer_ release];
    [choices_ release];
    [questionId_ release];
    [refreshTimer_ release];
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad { 
    [super viewDidLoad];
    
    self.navigationItem.title = @"Waiting...";
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refresh)];
    self.navigationItem.rightBarButtonItem = item;
    [item release];
    
    if (!self.questionAlreadyCreated) {
        PFObject *parseQuestion = [PFObject objectWithClassName:@"Question"];
        [parseQuestion setObject:self.question forKey:@"body"];
        if ([Util deviceToken]) {
            [parseQuestion setObject:[Util deviceToken] forKey:@"apns_device_token"];
        }
        NSMutableArray *parseChoicesArray = [NSMutableArray arrayWithCapacity:self.choices.count];
        for (NSString *choice in self.choices) {
            PFObject *parseChoice = [PFObject objectWithClassName:@"Choice"];
            [parseChoice setObject:choice forKey:@"body"];
            [parseChoicesArray addObject:parseChoice];
        }
        [parseQuestion setObject:parseChoicesArray forKey:@"choices"];
        [parseQuestion saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (!error) {
                NSString *theId = [parseQuestion objectId];
                [Util setCurrentQuestionId:theId];
                self.questionId = theId;
                [self setupTimer];
            } else {
                NSLog(@"Error: %@", [error localizedDescription]);
                [Util showErrorWithText:@"Error sending question to server!" AndTitle:@"C'mon!"];
            }
        }];
    } else {
        [self refresh];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.refreshTimer invalidate];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3; // 1 for orig question, 1 for answer, 1 for starting over
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"Your Question";
    } else if (section == 1) {
        return @"The Answer";
    } else {
        return @"Start Over";
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.textLabel.lineBreakMode = UILineBreakModeWordWrap;
        cell.textLabel.numberOfLines = 0;
    }
    
    // Configure the cell...
    if (indexPath.section == 0) {
        cell.textLabel.text = self.question;
    } else if (indexPath.section == 1) {
        cell.textLabel.text = self.answer;
    } else {
        cell.textLabel.text = @"Ask a new question";
        cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    }     
    
    return cell;
}

#pragma mark - Table view delegate

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // only allow start over cell to be selected
    if (indexPath.section == 2) {
        return indexPath;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 2) {
        [self startOver];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat retVal = 0;
    NSString *stringVal = nil;
    UIFont *font = [UIFont systemFontOfSize:17];
    if (indexPath.section == 0) {
        stringVal = self.question;
    } else if (indexPath.section == 1) {
        stringVal = self.answer;
    } else {
        stringVal = @"Ask a new question";
    }
    CGSize max = CGSizeMake([Util getCurrentDeviceWidth] - 20, CGFLOAT_MAX);
    retVal = [stringVal sizeWithFont:font constrainedToSize:max lineBreakMode:UILineBreakModeWordWrap].height;
    return MAX(44, retVal); // table view cell height is 44 - never want it to be smaller than that
}

# pragma mark - impl

- (void) refresh {
    if (self.questionId) {
        PFQuery *query = [PFQuery queryWithClassName:@"Question"];
        [query includeKey:@"answer"];
        [query includeKey:@"answer.choice"];
        [query getObjectInBackgroundWithId:self.questionId block:^(PFObject *parseQuestion, NSError *error) {
            if (!error) {
                self.question = [parseQuestion objectForKey:@"body"];
                PFObject *parseAnswer = [parseQuestion objectForKey:@"answer"];
                if (parseAnswer) {
                    [self.refreshTimer invalidate];
                    self.navigationItem.title = @"Answered!";
                    
                    PFObject *choice = [parseAnswer objectForKey:@"choice"];
                    if (choice) {
                        self.answer = [choice objectForKey:@"body"];
                    } else {
                        id otherText = [parseAnswer objectForKey:@"other_text"];
                        if (otherText == [NSNull null]) {
                            otherText = @"";
                        }
                        self.answer = otherText;
                    }
                    [self.tableView reloadData];
                    
                    NSMutableDictionary *event2 = [NSMutableDictionary dictionaryWithObjectsAndKeys:[Util UUIDForDevice], @"user",
                                                   self.question, @"question_asked",
                                                   [NSNumber numberWithUnsignedInteger:self.choices.count], @"number_of_answers_provided",
                                                   self.answer, @"answer_chosen",
                                                   choice != nil ? @"Robot" : @"Human", @"chosen_by",
                                                   nil];
                    NSUInteger index = 1;
                    for (NSString *choice in self.choices) {
                        [event2 setValue:choice forKey:[NSString stringWithFormat:@"answer_choice_%i", index]];
                        index++;
                    }
                    [[KeenClient sharedClient] addEvent:event2 toEventCollection:@"answer_received" error:nil];
                }
            } else {
                NSLog(@"Error: %@", [error localizedDescription]);
                [Util showErrorWithText:@"Error getting answer from server!" AndTitle:@"Weak"];
            }
        }];
    }
}

- (void) setupTimer {
    if (!self.refreshTimer || !self.refreshTimer.isValid) {        
        NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(refresh) userInfo:nil repeats:YES];
        self.refreshTimer = timer;        
    }
}

- (void) startOver {
    NSDictionary *event = nil;
    if (self.refreshTimer.isValid) {
        event = [NSDictionary dictionaryWithObjectsAndKeys:[Util UUIDForDevice], @"user", 
                 @"asked new question before old one was answered", @"name", nil];
    } else {
        event = [NSDictionary dictionaryWithObjectsAndKeys:[Util UUIDForDevice], @"user", 
                 @"asked new question after old one was answered", @"name", nil];
    }
    [[KeenClient sharedClient] addEvent:event toEventCollection:@"flows" error:nil];
    
    [self.refreshTimer invalidate];
    [Util removeCurrentQuestionId];
    QuestionController *controller = (QuestionController *) [self.navigationController.viewControllers objectAtIndex:0];
    controller.questionTextView.text = @"";    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
