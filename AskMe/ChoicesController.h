//
//  ChoicesController.h
//  AskMe
//
//  Created by Daniel Kador on 7/2/11.
//  Copyright 2011 Dorkfort.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddChoiceController.h"


@interface ChoicesController : UITableViewController <AddChoiceControllerDelegate> {

}

@property (nonatomic, retain) NSString *question;
@property (nonatomic, retain) NSMutableArray *choices;

@end
