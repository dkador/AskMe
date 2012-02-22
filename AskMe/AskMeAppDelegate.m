//
//  AskMeAppDelegate.m
//  AskMe
//
//  Created by Daniel Kador on 7/2/11.
//  Copyright 2011 Dorkfort.com. All rights reserved.
//

#import "AskMeAppDelegate.h"
#import "QuestionController.h"
#import "WaitingController.h"
#import "Util.h"
#import "KeenClient.h"


@implementation AskMeAppDelegate


@synthesize window=_window;

@synthesize viewController=_viewController;

@synthesize delegate;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {   
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    id remoteNotification = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    NSLog(@"remote: %@", remoteNotification);
        
    // Override point for customization after application launch.
    QuestionController *theController = [[QuestionController alloc] init];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:theController];
    [theController release];
    [self setViewController:navController];
    [navController release];
    self.window.rootViewController = self.viewController;
    
    NSNumber *currentQuestionId = [Util currentQuestionId];
    if (currentQuestionId) {
        // go straight to it.
        WaitingController *waitingController = [[WaitingController alloc] initWithQuestion:nil AndChoices:nil];
        waitingController.questionAlreadyCreated = YES;
        waitingController.questionId = currentQuestionId;
        [self.viewController pushViewController:waitingController animated:NO];
        [waitingController setupTimer];
        [waitingController release];
    }
    
    [self.window makeKeyAndVisible];
    
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound];
    
    [KeenClient clientForProject:@"4f386613a8438d182f000001" andAuthToken:@"83984bbb1526452aa1a077f4d77b9d53"];
    
    NSDictionary *event = [NSDictionary dictionaryWithObjectsAndKeys:@"app launched", @"name", [Util UUIDForDevice], @"user", nil];
    [[KeenClient lastRequestedClient] addEvent:event toCollection:@"flows"];
    
    return YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    UIBackgroundTaskIdentifier taskId = [application beginBackgroundTaskWithExpirationHandler:^(void) {
        
    }];
    NSDictionary *event = [NSDictionary dictionaryWithObjectsAndKeys:@"app closed", @"name", [Util UUIDForDevice], @"user", nil];
    [[KeenClient lastRequestedClient] addEvent:event toCollection:@"flows"];
    [[KeenClient lastRequestedClient] uploadWithFinishedBlock:^(void){
        NSLog(@"Upload finished, ending background thread.");
        [application endBackgroundTask:taskId];
    }];
}

// Delegation methods
- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)devToken {
    NSString *token = [[devToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<> "]];
    NSLog(@"token 1: %@", token);
    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSLog(@"token 2: %@", token);
    [Util setDeviceToken:token];
}

- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err {
    NSLog(@"Error in registration. Error: %@", err);
    [Util removeDeviceToken];    
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    NSLog(@"got a remote notification %@", userInfo);
    NSNumber *questionId = [userInfo objectForKey:@"question_id"];
    if (questionId) {
        NSLog(@"remote notification had question %@", questionId);
        if ([self.viewController.visibleViewController isKindOfClass:[WaitingController class]]) {
            NSLog(@"user is already viewing waiting screen, force a reload");
            WaitingController *controller = (WaitingController *) self.viewController.visibleViewController;
            [controller refresh];
        }
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];  
    NetCheck *netCheck = [[NetCheck alloc] init];
    netCheck.delegate = self;
    [netCheck checkReachabilityForHost:ServerHost];
}

- (void)dealloc {
    [_window release];
    [_viewController release];
    self.delegate = nil;
    [super dealloc];
}

# pragma mark - NetCheckDelegate

- (void)reachabilityFinishedWithInternetReachable:(Boolean)internetReachable HostReachable:(Boolean)hostReachable {
    if (!(internetReachable && hostReachable)) {
        [Util showErrorWithText:@"It seems your device has no internet connection. This app likely will not work." AndTitle:@"Hold It!"];
    }
}

@end
