//
//  ApiRequest.m
//  MBTA-RZImport
//
//  Created by Steve Caine on 01/10/15.
//  Copyright (c) 2015 Steve Caine. All rights reserved.
//

#import "ApiRequest.h"
#import "ApiRequest_private.h"

#import "ApiData.h"
#import "ApiData+RZImport.h"

#import "RequestClient.h"

#import "Debug_iOS.h"

// ----------------------------------------------------------------------

//@interface ApiRequest ()
//@end

// ----------------------------------------------------------------------

@implementation ApiRequest

// ----------------------------------------------------------------------
#pragma mark - globals
// ----------------------------------------------------------------------

- (void)refresh_success:(void(^)(ApiRequest *request))success
				failure:(void(^)(NSError *error))failure {
	[self get_success:^(ApiRequest *request) {
		if (success)
			success(self);
	} failure:^(NSError *error) {
		if (failure)
			failure(error);
		else
			NSLog(@"%s API call failed: %@", __FUNCTION__, [error localizedDescription]);
	}];
}

- (ApiData *)response {
	return self.data;
}

- (NSString *)result {
	return [self.data description];
}
// ----------------------------------------------------------------------
#pragma mark - locals
// ----------------------------------------------------------------------

- (double)staleAge {
	NSAssert(false, @"Abstract class 'ApiRequest' should never be instantiated.");
	return 0.0;
}

- (void)get_success:(void(^)(ApiRequest *request))success
			failure:(void(^)(NSError *error))failure {
#if CONFIG_USE_RZImport
	RequestClient *client = [RequestClient sharedClient];
	NSString *url = [client request:self.verb
							 params:self.params
							 format:jsonFormat
							success:^(NSURLSessionDataTask *task, id responseObject) {
								[self success:task response:responseObject];
								if (success)
									success(self);
							}
					 
							failure:^(NSURLSessionDataTask *task, NSError *error) {
								[self failure:task error:error];
								if (failure)
									failure(error);
								else
									NSLog(@"%s API call failed: %@", __FUNCTION__, [error localizedDescription]);
							}];
	MyLog(@" request URL = '%@'", url);
#else
	NSError *error = [ApiData error_missing_implementation];
	if (failure)
		failure(error);
	else
		NSLog(@"Error: %@", [error localizedDescription]);
#endif
}

// --------------------------------------------------
#pragma mark -
// --------------------------------------------------

- (void)success:(NSURLSessionDataTask *)task response:(id)responseObject {
//	self.data = [ApiData itemForJSON:responseObject key:[self key]];
	self.data = [ApiData itemForJSON:responseObject verb:self.verb params:self.params];
}

- (void)failure:(NSURLSessionDataTask *)task error:(NSError *)error {
	NSLog(@"ApiRequest error: %@", [error localizedDescription]);
}

@end