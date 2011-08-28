//
//  NetCheck.h
//  NetCheck
//
//  Created by Daniel Kador on 8/28/11.
//  Copyright 2011 Dorkfort.com. All rights reserved.
//

#import <Foundation/Foundation.h>


@class Reachability;

@protocol NetCheckDelegate;

@interface NetCheck : NSObject {
    Reachability *internetReachable;
    Reachability *hostReachable;
    
    id<NetCheckDelegate> delegate;
}

@property (nonatomic, retain) Reachability *internetReachable;
@property (nonatomic, retain) Reachability *hostReachable;

@property (nonatomic, retain) id<NetCheckDelegate> delegate;

- (void) checkReachabilityForHost: (NSString *) host;

@end

@protocol NetCheckDelegate

- (void) reachabilityFinishedWithInternetReachable: (Boolean) internetReachable HostReachable: (Boolean) hostReachable;

@end
