//
//  AskMeAppDelegate.h
//  AskMe
//
//  Created by Daniel Kador on 7/2/11.
//  Copyright 2011 Dorkfort.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NetCheck.h"


@interface AskMeAppDelegate : NSObject <UIApplicationDelegate, NetCheckDelegate> {

}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet UINavigationController *viewController;

@property (nonatomic, assign) id<NetCheckDelegate> delegate;

@end
