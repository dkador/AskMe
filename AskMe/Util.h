//
//  Util.h
//  AskMe
//
//  Created by Daniel Kador on 8/14/11.
//  Copyright 2011 Dorkfort.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Util : NSObject {
    
}

+ (void) showErrorWithText: (NSString *) errorText AndTitle: (NSString *) title;

+ (NSString *) deviceToken;
+ (void) setDeviceToken: (NSString *) deviceToken;
+ (void) removeDeviceToken;

+ (NSNumber *) currentQuestionId;
+ (void) setCurrentQuestionId: (NSNumber *) questionId;
+ (void) removeCurrentQuestionId;

+ (uint) getCurrentDeviceWidth;
+ (uint) getCurrentDeviceHeight;

@end
