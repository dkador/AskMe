//
//  NetCheck.m
//  NetCheck
//
//  Created by Daniel Kador on 8/28/11.
//  Copyright 2011 Dorkfort.com. All rights reserved.
//

#import "NetCheck.h"
#import "Reachability.h"


@implementation NetCheck

@synthesize internetReachable, hostReachable;
@synthesize delegate;

# pragma mark - lifecycle

- (void)dealloc {
    self.internetReachable = nil;
    self.hostReachable = nil;
    self.delegate = nil;
    // make sure to remove self from notifications
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

# pragma mark - impl

- (void) checkReachabilityForHost: (NSString *) host {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkNetworkStatus:) name:kReachabilityChangedNotification object:nil];
    
    self.internetReachable = [Reachability reachabilityForInternetConnection];
    [self.internetReachable startNotifier];
    
    // check if a pathway to a random host exists
    self.hostReachable = [Reachability reachabilityWithHostName:host];
    [self.hostReachable startNotifier];
    
    // wait until we get notified
}

- (void) checkNetworkStatus:(NSNotification *)notice
{
    // called after network status changes
    
    NetworkStatus internetStatus = [internetReachable currentReachabilityStatus];
    switch (internetStatus)
    
    {
        case NotReachable:
        {
            NSLog(@"The internet is down.");
            [self.delegate reachabilityFinishedWithInternetReachable:NO HostReachable:NO];
            return;            
        }
        case ReachableViaWiFi:
        {
            NSLog(@"The internet is working via WIFI.");
            break;            
        }
        case ReachableViaWWAN:
        {
            NSLog(@"The internet is working via WWAN.");
            break;
        }
    }
    
    NetworkStatus hostStatus = [hostReachable currentReachabilityStatus];
    switch (hostStatus)
    
    {
        case NotReachable:
        {
            NSLog(@"A gateway to the host server is down.");
            [self.delegate reachabilityFinishedWithInternetReachable:YES HostReachable:NO];
            return;            
        }
        case ReachableViaWiFi:
        {
            NSLog(@"A gateway to the host server is working via WIFI.");
            break;            
        }
        case ReachableViaWWAN:
        {
            NSLog(@"A gateway to the host server is working via WWAN.");            
            break;            
        }
    }
    [self.delegate reachabilityFinishedWithInternetReachable:YES HostReachable:YES];
}

@end

