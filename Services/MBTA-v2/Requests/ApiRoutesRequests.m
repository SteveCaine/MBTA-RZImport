//
//  ApiRoutesRequests.m
//  MBTA-RZImport
//
//  Created by Steve Caine on 01/11/15.
//  Copyright (c) 2015 Steve Caine. All rights reserved.
//

#import "ApiRoutesRequests.h"
#import "ApiRequest_private.h"

#import "ApiData_private.h"
#import "ApiRoutes.h"
#import "ServiceMBTA_strings.h"

// ----------------------------------------------------------------------

@implementation ApiRoutesRequest

- (void)refresh_success:(void(^)(ApiRequest *request))success
				failure:(void(^)(NSError *error))failure {
	
	// check for existing JSON/XML response file in our cache
	NSString *key = [self key];
	id cachedResponse = [ApiRequest cachedResponseForKey:key staleAge:[self staleAge]];
	
	if (cachedResponse) {
		if (self.data && [self.data isKindOfClass:[ApiRoutes class]]) {
			[self.data updateFromResponse:cachedResponse];
		}
		else {
			self.data = [[ApiRoutes alloc] initWithResponse:cachedResponse];
		}
		if (success)
			success(self);
	}
	// only make fresh request if there's no file
	// or the file is older than our -staleAge
	else {
		[ApiRoutes get_success:^(ApiRoutes *data) {
			self.data = data;
			if (success)
				success(self);
		} failure:^(NSError *error) {
			if (failure)
				failure(error);
			else
				NSLog(@"ApiRoutesRequest error: %@", [error localizedDescription]);
		}];
	}
}

// ----------------------------------------------------------------------

- (NSString *)key {
	return verb_routes;
}

- (double)staleAge {
	// one month
	return 30.0 * 24.0 * 3600.0;
}

@end

// ----------------------------------------------------------------------
#pragma mark -
// ----------------------------------------------------------------------

@implementation ApiRoutesByStopRequest

- (void)refresh_success:(void(^)(ApiRequest *request))success
				failure:(void(^)(NSError *error))failure {
	
	// check for existing JSON/XML response file in our cache
	NSString *key = [self key];
	id cachedResponse = [ApiRequest cachedResponseForKey:key staleAge:[self staleAge]];
	
	if (cachedResponse) {
		if (self.data && [self.data isKindOfClass:[ApiRoutesByStop class]]) {
			[self.data updateFromResponse:cachedResponse];
		}
		else {
			self.data = [ApiData itemForResponse:cachedResponse verb:verb_routesbystop params:nil];
		}
		if (success)
			success(self);
	}
	// only make fresh request if there's no file
	// or the file is older than our -staleAge
	else {
		[ApiRoutesByStop get4stop:self.stopID
						  success:^(ApiRoutesByStop *data) {
							  self.data = data;
							  if (success)
								  success(self);
						  } failure:^(NSError *error) {
							  if (failure)
								  failure(error);
							  else
								  NSLog(@"ApiRoutesByStopRequest error: %@", [error localizedDescription]);
						  }];
	}
}

// ----------------------------------------------------------------------

- (NSString *)key {
	// "routesbystop&stop=x"
	return [NSString stringWithFormat:@"%@&%@=%@", verb_routesbystop, param_stop, self.stopID];
}

- (double)staleAge {
	// one month
	return 30.0 * 24.0 * 3600.0;
}

// ----------------------------------------------------------------------

- (instancetype)init4stop:(NSString *)stopID {
	self = [super init];
	if (self) {
		_stopID = stopID;
	}
	return self;
}

@end

// ----------------------------------------------------------------------
