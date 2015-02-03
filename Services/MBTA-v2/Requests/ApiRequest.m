//
//  ApiRequest.m
//  MBTA-RZImport
//
//  Created by Steve Caine on 01/10/15.
//  Copyright (c) 2015 Steve Caine. All rights reserved.
//

#import "ApiRequest.h"
#import "ApiRequest_private.h"

//#import "Debug_iOS.h"

@implementation ApiRequest

- (void)refresh_success:(void(^)(ApiRequest *request))success
				failure:(void(^)(NSError *error))failure {
	NSAssert(false, @"Abstract class 'ApiRequest' should never be instantiated.");
}

// ----------------------------------------------------------------------

- (ApiData *)response {
	return self.data;
}

// ----------------------------------------------------------------------

- (NSString *)key {
	NSAssert(false, @"Abstract class 'ApiRequest' should never be instantiated.");
	return nil;
}

// ----------------------------------------------------------------------

- (double)staleAge {
	NSAssert(false, @"Abstract class 'ApiRequest' should never be instantiated.");
	return 0.0;
}

@end
