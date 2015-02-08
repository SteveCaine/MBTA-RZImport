//
//  ApiRoutesRequests.h
//  MBTA-RZImport
//
//  Created by Steve Caine on 01/11/15.
//
//	This code is distributed under the terms of the MIT license.
//
//	Copyright (c) 2015 Steve Caine.
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
