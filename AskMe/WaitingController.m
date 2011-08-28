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

#import <QuartzCore/QuartzCore.h>


@implementation WaitingController

//NSString * const ServerAddress = @"http://192.168.1.50:3000";
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
        NSURL *url = [NSURL URLWithString:[ServerAddress stringByAppendingString:@"/questions.json"]];
        ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];

        NSMutableDictionary *requestDict = [NSMutableDictionary dictionaryWithCapacity:1];
        NSMutableDictionary *questionDict = [NSMutableDictionary dictionaryWithCapacity:2];
        [questionDict setObject:self.question forKey:@"body"];
        if ([Util deviceToken]) {
            NSLog(@"sending device token %@", [Util deviceToken]);
            [questionDict setObject:[Util deviceToken] forKey:@"apns_device_token"];
        }
        NSMutableArray *choicesArray = [NSMutableArray arrayWithCapacity:self.choices.count];
        for (NSString *choice in self.choices) {
            NSDictionary *choiceDict = [NSDictionary dictionaryWithObject:choice forKey:@"body"];
            [choicesArray addObject:choiceDict];
        }
        [questionDict setObject:choicesArray forKey:@"choices"];
        [requestDict setObject:questionDict forKey:@"question"];
        NSError *error = nil;
        //TODO error
        NSData *jsonData = [[CJSONSerializer serializer] serializeDictionary:requestDict error:&error];
        [request appendPostData:jsonData];
        [request setRequestMethod:@"POST"];
        request.requestHeaders = [NSMutableDictionary dictionaryWithObject:@"application/json" forKey:@"Content-Type"];
        
        [request setCompletionBlock:^{  
            if (request.responseStatusCode == 201) {
                NSLog(@"THAT FUCKER GOT CREATED");
                NSData *jsonData = [request responseData];
                NSError *error = nil;
                //TODO errors
                NSDictionary *dict = [[CJSONDeserializer deserializer] deserializeAsDictionary:jsonData error:&error];
                NSLog(@"RESPONSE %@", dict);
                NSNumber *theId = [[dict objectForKey:@"question"] objectForKey:@"id"];
                NSLog(@"the id %@", theId);
                [Util setCurrentQuestionId:theId];
                self.questionId = theId;
                [self setupTimer];
            } else {
                NSLog(@"something bad happened");
            }
        }];
        [request setFailedBlock:^{
            //TODO
            NSError *error = [request error];
            NSLog(@"question create failed %@", [error localizedDescription]);
        }];
        
        [request startAsynchronous];
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
    CGSize max = CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX);
    retVal = [stringVal sizeWithFont:font constrainedToSize:max lineBreakMode:UILineBreakModeWordWrap].height;
    return MAX(44, retVal); // table view cell height is 44 - never want it to be smaller than that
}

# pragma mark - impl

- (void) refresh {
    if (self.questionId) {
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/questions/%@.json", ServerAddress, self.questionId]];
        ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];   
        [request setCompletionBlock:^{
            NSLog(@"refresh succeeded");
            NSData *jsonData = [request responseData];
            NSError *error = nil;
            //TODO errors
            NSDictionary *dict = [[CJSONDeserializer deserializer] deserializeAsDictionary:jsonData error:&error];
            NSLog(@"RESPONSE %@", dict);
            NSDictionary *question = [dict objectForKey:@"question"];
            self.question = [question objectForKey:@"body"];
            NSDictionary *answer = [question objectForKey:@"answer"];
            if (answer) {
                NSLog(@"has answer");
                [self.refreshTimer invalidate];
                self.navigationItem.title = @"Answered!";
                id otherText = [answer objectForKey:@"other_text"];
                if (otherText != [NSNull null] && ![otherText isEqualToString:@""]) {
                    self.answer = otherText;
                } else {
                    NSNumber *choiceId = [answer objectForKey:@"choice_id"];
                    NSArray *choices = [question objectForKey:@"choices"];
                    for (NSDictionary *choice in choices) {
                        if ([choiceId isEqualToNumber:[choice objectForKey:@"id"]]) {
                            NSLog(@"found our choice %@", choice);
                            self.answer = [choice objectForKey:@"body"];
                        }
                    }
                }
                [self.tableView reloadData];
            }
        }];
        [request setFailedBlock:^{
            NSLog(@"refresh failed");
        }];
        [request startAsynchronous];
    }
}

- (void) setupTimer {
    if (!self.refreshTimer || !self.refreshTimer.isValid) {        
        NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:15.0 target:self selector:@selector(refresh) userInfo:nil repeats:YES];
        self.refreshTimer = timer;        
    }
}

- (void) startOver {
    [self.refreshTimer invalidate];
    [Util removeCurrentQuestionId];
    QuestionController *controller = (QuestionController *) [self.navigationController.viewControllers objectAtIndex:0];
    controller.questionTextView.text = @"";    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
