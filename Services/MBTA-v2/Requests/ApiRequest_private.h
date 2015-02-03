//
//  ApiRequest_private.h
//  MBTA-RZImport
//
//  Created by Steve Caine on 01/10/15.
//  Copyright (c) 2015 Steve Caine. All rights reserved.
//

#import "ApiRequest.h"

#import "ApiRoutesRequests.h"
#import "ApiStopsRequests.h"

// ----------------------------------------------------------------------

@interface ApiRequest ()

@property (strong, nonatomic) ApiData  *data; // request-specific subclass of ApiData

// subclasses MUST override these
- (NSString *)key;
- (double)staleAge;

@end

// ----------------------------------------------------------------------

@interface ApiRoutesByStopRequest ()
@property (copy, nonatomic) NSString *stopID;
@end

// ----------------------------------------------------------------------

@interface ApiStopsByRouteRequest ()
@property (copy, nonatomic) NSString *routeID;
@end

// ----------------------------------------------------------------------

@interface ApiStopsByLocationRequest ()
@property (assign, nonatomic) CLLocationCoordinate2D location;
@end

// ----------------------------------------------------------------------
