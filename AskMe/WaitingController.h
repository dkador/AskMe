//
//  WaitingController.h
//  AskMe
//
//  Created by Daniel Kador on 8/13/11.
//  Copyright 2011 Dorkfort.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WaitingController : UITableViewController {
    
}

@property (nonatomic, retain) NSString *question;
@property (nonatomic, retain) NSString *answer;
@property (nonatomic, retain) NSArray *choices;
@property (nonatomic, retain) NSNumber *questionId;
@property (nonatomic) Boolean questionAlreadyCreated;
@property (nonatomic, retain) NSTimer *refreshTimer;

- (id) initWithQuestion: (NSString *) question AndChoices: (NSArray *) choices;
- (void) refresh;
- (void) setupTimer;
- (void) startOver;

@end
