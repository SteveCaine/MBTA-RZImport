//
//  ApiTime.h
//  MBTA-RZImport
//
//  Created by Steve Caine on 12/26/14.
//
//	This code is distributed under the terms of the MIT license.
//
//	Copyright (c) 2014-2015 Steve Caine.
//

#import <Foundation/Foundation.h>

#import "ApiData.h"

// ----------------------------------------------------------------------

@interface ApiTime : ApiData

+ (void)get_success:(void(^)(ApiTime *data))success
			failure:(void(^)(NSError *error))failure;

- (NSDate *)time;

@end

// ----------------------------------------------------------------------
