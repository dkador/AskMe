//
//  Util.m
//  AskMe
//
//  Created by Daniel Kador on 8/14/11.
//  Copyright 2011 Dorkfort.com. All rights reserved.
//

#import "Util.h"

@implementation Util

NSString * const DeviceTokenKey = @"DeviceToken";
NSString * const CurrentQuestionId = @"CurrentQuestionIdKey";

+ (void) showErrorWithText: (NSString *) errorText AndTitle: (NSString *) title {
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:errorText delegate:nil cancelButtonTitle:@"Oops" otherButtonTitles:nil];
	[alert show];
	[alert release];
}

+ (NSString *) deviceToken {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults stringForKey:DeviceTokenKey];
}

+ (void) setDeviceToken: (NSString *) deviceToken {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:deviceToken forKey:DeviceTokenKey];
    [defaults synchronize];
}

+ (void) removeDeviceToken {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:DeviceTokenKey];
    [defaults synchronize];
}

+ (NSNumber *) currentQuestionId {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:CurrentQuestionId];
}

+ (void) setCurrentQuestionId: (NSNumber *) questionId {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:questionId forKey:CurrentQuestionId];
    [defaults synchronize];
}

+ (void) removeCurrentQuestionId {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:CurrentQuestionId];
    [defaults synchronize];
}

+ (uint) getCurrentDeviceWidth {
    BOOL isPortrait = UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation]);
    switch ([[UIDevice currentDevice] userInterfaceIdiom]) {
        case UIUserInterfaceIdiomPad:
            if (isPortrait) {
                return 768;
            } else {
                return 1024;
            }
        default:
            if (isPortrait) {
                return 320;
            } else {
                return 480;
            }
    }
}

+ (uint) getCurrentDeviceHeight {
    BOOL isPortrait = UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation]);
    switch ([[UIDevice currentDevice] userInterfaceIdiom]) {
        case UIUserInterfaceIdiomPad:
            if (isPortrait) {
                return 1024;
            } else {
                return 768;
            }
        default:
            if (isPortrait) {
                return 480;
            } else {
                return 320;
            }
    }
}

@end
