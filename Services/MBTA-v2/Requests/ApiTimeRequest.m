//
//  ApiTimeRequest.m
//  MBTA-RZImport
//
//  Created by Steve Caine on 01/10/15.
//  Copyright (c) 2015 Steve Caine. All rights reserved.
//

#import "ApiTimeRequest.h"

#import "ApiRequest_private.h"

#import "ServiceMBTA_strings.h"

// ----------------------------------------------------------------------

@implementation ApiTimeRequest

- (double)staleAge {
	return 0.0; // always get fresh
}

- (instancetype)init {
	self = [super init];
	if (self) {
		super.verb = verb_servertime;
//		super.key = verb_servertime;
//		super.params remains nil
	}
	return self;
}

@end

// ----------------------------------------------------------------------
