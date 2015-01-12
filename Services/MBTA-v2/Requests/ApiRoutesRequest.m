//
//  ApiRoutesRequest.m
//  MBTA-RZImport
//
//  Created by Steve Caine on 01/11/15.
//  Copyright (c) 2015 Steve Caine. All rights reserved.
//

#import "ApiRoutesRequest.h"

#import "ApiRequest_private.h"

#import "ServiceMBTA_strings.h"

// ----------------------------------------------------------------------

@implementation ApiRoutesRequest

- (double)staleAge {
	// one month
	return 30.0 * 24.0 * 3600.0;
}

- (instancetype)init {
	self = [super init];
	if (self) {
		super.verb = verb_routes;
//		super.params remains nil
	}
	return self;
}

@end
