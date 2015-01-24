//
//  ApiData.h
//  MBTA-APIs
//
//  Created by Steve Caine on 12/31/14.
//  Copyright (c) 2014 Steve Caine. All rights reserved.
//

#import <Foundation/Foundation.h>

#if CONFIG_USE_RZImport
	#import "NSObject+RZImport.h"
	#import "RZImportable.h"
#endif

#define ApiData_ErrorDomain		@"ApiData_ErrorDomain"

// ----------------------------------------------------------------------

@interface ApiData : NSObject			PROTOCOL_RZImportable

#if 0
+ (void)get_item:(NSString *)verb
		  params:(NSDictionary *)params
		  success:(void(^)(ApiData *item))success
		  failure:(void(^)(NSError *error))failure;

+ (void)get_array:(NSString *)verb
		   params:(NSDictionary *)params
		  success:(void(^)(NSArray *array))success
		  failure:(void(^)(NSError *error))failure;

- (void)update_success:(void(^)(ApiData *item))success
			   failure:(void(^)(NSError *error))failure;
#endif

+ (NSError *)error_unknown;
+ (NSError *)error_incomplete_implementation;

@end

// ----------------------------------------------------------------------
