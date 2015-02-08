//
//  ApiStopsRequests.h
//  MBTA-RZImport
//
//  Created by Steve Caine on 02/02/15.
//
//	This code is distributed under the terms of the MIT license.
//
//	Copyright (c) 2015 Steve Caine.
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
