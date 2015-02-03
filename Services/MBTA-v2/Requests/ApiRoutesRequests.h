//
//  ApiRoutesRequests.h
//  MBTA-RZImport
//
//  Created by Steve Caine on 01/11/15.
//  Copyright (c) 2015 Steve Caine. All rights reserved.
//

#import "ApiRequest.h"

// ----------------------------------------------------------------------

@interface ApiRoutesRequest : ApiRequest

@end

// ----------------------------------------------------------------------

@interface ApiRoutesByStopRequest : ApiRequest
- (instancetype)init4stop:(NSString *)stopID;
@end

// ----------------------------------------------------------------------
