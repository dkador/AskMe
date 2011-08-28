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
@synthesize choices=choices_;
@synthesize questionId=questionId_;
@synthesize questionAlreadyCreated=questionAlreadyCreated_;
@synthesize refreshTimer=refreshTimer_;

@synthesize questionLabel=questionLabel_;
@synthesize answerTextView=answerTextView_;

- (id) initWithQuestion: (NSString *) question AndChoices: (NSArray *) choices {
    if (self = [super init]) {
        self.question = question;
        self.choices = choices;
    }
    return self;
}

- (void)dealloc {
    [question_ release];
    [choices_ release];
    [questionId_ release];
    [refreshTimer_ release];
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)loadView {
    UIView *theView = [[UIView alloc] init];
    self.view = theView;
    [theView release];    
    
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    self.navigationItem.title = @"Waiting...";
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refresh)];
    self.navigationItem.rightBarButtonItem = item;
    [item release];
    
    UILabel *questionLabel = [[UILabel alloc] init];
    questionLabel.frame = CGRectMake(10, 10, 300, 44);
    questionLabel.backgroundColor = [UIColor clearColor];
    questionLabel.textAlignment = UITextAlignmentCenter;
    questionLabel.text = self.question;
    [self.view addSubview:questionLabel];
    self.questionLabel = questionLabel;
    [questionLabel release];
    
    UITextView *textView = [[UITextView alloc] init];
    textView.frame = CGRectMake(10, 60, 300, 200);
    textView.layer.cornerRadius = 8;
    textView.editable = NO;
    textView.text = @"Waiting for answer...";
    textView.font = [UIFont systemFontOfSize:20];
    [self.view addSubview:textView];
    self.answerTextView = textView;
    [textView release];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.frame = CGRectMake(10, 300, 150, 44);
    [button setTitle:@"Ask a new question" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(startOver) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

- (void)viewDidLoad { 
    [super viewDidLoad];
    
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

- (void)viewDidUnload {
    [super viewDidUnload];
    self.answerTextView = nil;
    self.questionLabel = nil;
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.refreshTimer invalidate];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

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
            self.questionLabel.text = [question objectForKey:@"body"];
            NSDictionary *answer = [question objectForKey:@"answer"];
            if (answer) {
                NSLog(@"has answer");
                [self.refreshTimer invalidate];
                self.navigationItem.title = @"Answered!";
                id otherText = [answer objectForKey:@"other_text"];
                if (otherText != [NSNull null] && ![otherText isEqualToString:@""]) {
                    self.answerTextView.text = otherText;
                } else {
                    NSNumber *choiceId = [answer objectForKey:@"choice_id"];
                    NSArray *choices = [question objectForKey:@"choices"];
                    for (NSDictionary *choice in choices) {
                        if ([choiceId isEqualToNumber:[choice objectForKey:@"id"]]) {
                            NSLog(@"found our choice %@", choice);
                            self.answerTextView.text = [choice objectForKey:@"body"];                            
                        }
                    }
                }
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
        NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(refresh) userInfo:nil repeats:YES];
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
