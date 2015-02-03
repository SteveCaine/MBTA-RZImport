//
//  ApiStopsRequests.h
//  MBTA-RZImport
//
//  Created by Steve Caine on 02/02/15.
//  Copyright (c) 2015 Steve Caine. All rights reserved.
//

#import "ApiRequest.h"

// ----------------------------------------------------------------------

@interface ApiStopsByRouteRequest : ApiRequest
- (instancetype)init4route:(NSString *)routeID;
@end

// ----------------------------------------------------------------------

@interface ApiStopsByLocationRequest : ApiRequest
- (instancetype)init4location:(CLLocationCoordinate2D)location;
@end

// ----------------------------------------------------------------------
