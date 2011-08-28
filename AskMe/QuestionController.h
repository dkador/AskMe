//
//  QuestionController.h
//  AskMe
//
//  Created by Daniel Kador on 7/2/11.
//  Copyright 2011 Dorkfort.com. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface QuestionController : UIViewController <UITextViewDelegate> {
    UITextView *questionTextView;
}

@property (nonatomic, retain) UITextView *questionTextView;

@end
