//
//  AddChoiceController.h
//  AskMe
//
//  Created by Daniel Kador on 7/4/11.
//  Copyright 2011 Dorkfort.com. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol AddChoiceControllerDelegate;

@interface AddChoiceController : UIViewController <UITextFieldDelegate> {
}

@property (assign, nonatomic) id<AddChoiceControllerDelegate> delegate;

@end

@protocol AddChoiceControllerDelegate

- (void) choiceAdded: (NSString *) choice;

@end