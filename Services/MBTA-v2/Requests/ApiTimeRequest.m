//
//  ApiTimeRequest.m
//  MBTA-RZImport
//
//  Created by Steve Caine on 01/10/15.
//  Copyright (c) 2015 Steve Caine. All rights reserved.
//

#import "ApiTimeRequest.h"

#import "ApiRequest_private.h"

#import "ApiTime.h"

// ----------------------------------------------------------------------

@implementation ApiTimeRequest

//#pragma mark - public

- (void)refresh_success:(void(^)(ApiRequest *request))success
				failure:(void(^)(NSError *error))failure {
	// always get fresh, no need to check for existing JSON/XML file
	[ApiTime get_success:^(ApiTime *data) {
		self.data = data;
		if (success)
			success(self);
	} failure:^(NSError *error) {
		if (failure)
			failure(error);
		else
			NSLog(@"ApiTimeRequest error: %@", [error localizedDescription]);
	}];
}

// ----------------------------------------------------------------------
//#pragma mark - private
// ----------------------------------------------------------------------

- (NSString *)key {
	return nil; // always get fresh
}

- (double)staleAge {
	return 0.0; // ditto
}

@end

// ----------------------------------------------------------------------
