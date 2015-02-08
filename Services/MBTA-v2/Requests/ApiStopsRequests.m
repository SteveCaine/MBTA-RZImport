//
//  ApiStopsRequests.m
//  MBTA-RZImport
//
//  Created by Steve Caine on 02/02/15.
//
//	This code is distributed under the terms of the MIT license.
//
//	Copyright (c) 2015 Steve Caine.
//

#import "ApiStopsRequests.h"
#import "ApiRequest_private.h"

#import "ApiData_private.h"
#import "ApiStops.h"
#import "ServiceMBTA_strings.h"

// ----------------------------------------------------------------------

@implementation ApiStopsByRouteRequest

- (void)refresh_success:(void(^)(ApiRequest *request))success
				failure:(void(^)(NSError *error))failure {
	// check for existing JSON/XML response file in our cache
	NSString *key = [self key];
	id cachedResponse = [ApiRequest cachedResponseForKey:key staleAge:[self staleAge]];
	
	if (cachedResponse) {
		if (self.data && [self.data isKindOfClass:[ApiStopsByRoute class]]) {
			[self.data updateFromResponse:cachedResponse];
		}
		else {
			self.data = [[ApiStopsByRoute alloc] initWithResponse:cachedResponse];
		}
		if (success)
			success(self);
	}
	// only make fresh request if there's no file
	// or the file is older than our -staleAge
	else {
		[ApiStopsByRoute get4route:self.routeID
						  success:^(ApiStopsByRoute *data) {
							  self.data = data;
							  if (success)
								  success(self);
						  } failure:^(NSError *error) {
							  if (failure)
								  failure(error);
							  else
								  NSLog(@"ApiStopsByRouteRequest error: %@", [error localizedDescription]);
						  }];
	}
}

// ----------------------------------------------------------------------

- (NSString *)key {
	// "stopsbyroute&route=x"
	return [NSString stringWithFormat:@"%@&%@=%@", verb_stopsbyroute, param_route, self.routeID];
}

- (double)staleAge {
	// one month
	return 30.0 * 24.0 * 3600.0;
}

// ----------------------------------------------------------------------

- (instancetype)init4route:(NSString *)routeID {
	self = [super init];
	if (self) {
		_routeID = routeID;
	}
	return self;
}

@end

// ----------------------------------------------------------------------
#pragma mark -
// ----------------------------------------------------------------------

@implementation ApiStopsByLocationRequest

- (void)refresh_success:(void(^)(ApiRequest *request))success
				failure:(void(^)(NSError *error))failure {
	
	// never cached, always make fresh request
	// since location is infinitely variable in two dimensions
	[ApiStopsByLocation get4location:self.location
							 success:^(ApiStopsByLocation *data) {
								 self.data = data;
								 if (success)
									 success(self);
							 } failure:^(NSError *error) {
								 if (failure)
									 failure(error);
								 else
									 NSLog(@"ApiStopsByLocationRequest error: %@", [error localizedDescription]);
							 }];
}

// ----------------------------------------------------------------------

- (NSString *)key {
	return nil; // never cached
}

- (double)staleAge {
	return 0.0; // never cached
}

// ----------------------------------------------------------------------

- (instancetype)init4location:(CLLocationCoordinate2D)location {
	self = [super init];
	if (self) {
		_location = location;
	}
	return self;
}

@end

// ----------------------------------------------------------------------
