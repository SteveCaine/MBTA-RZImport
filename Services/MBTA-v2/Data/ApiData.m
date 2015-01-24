//
//  ApiData.m
//  MBTA-APIs
//
//  Created by Steve Caine on 12/31/14.
//  Copyright (c) 2014 Steve Caine. All rights reserved.
//

#import "ApiData.h"

//#import "ServiceMBTA+RZImport.h"
#import "ServiceMBTA+RZImport.h"

#define str_error_unknown						@"ApiData: Unknown error."
#define str_error_incomplete_implementation		@"ApiData: Incomplete implementation." // not meant to be user-facing error msg

@implementation ApiData
// ----------------------------------------------------------------------

+ (void)get_item:(NSString *)verb
		  params:(NSDictionary *)params
		 success:(void(^)(ApiData *item))success
		 failure:(void(^)(NSError *error))failure {
	
	[ApiData request:verb params:params success:^(NSArray *data) {
		// validate return count == 1 and that item is ApiData
		if ([data count] && [data[0] isKindOfClass:[ApiData class]]) {
			if (success)
				success(data[0]);
		}
		else {
			NSError *error = [ServiceMBTA error_RZImport_unknown];
			if (failure)
				failure(error);
			else
				NSLog(@"%s ERROR: %@", __FUNCTION__, [error localizedDescription]);
		}
	} failure:^(NSError *error) {
		if (failure)
			failure(error);
		else
			NSLog(@"%s API call failed: %@", __FUNCTION__, [error localizedDescription]);
	}];
}

// ----------------------------------------------------------------------

- (instancetype)initWithJSON:(NSDictionary *)json {
	self = [super init];
	if (self) {
		NSString *msg = [NSString stringWithFormat:@"ApiData subclass '%@' should handle %s and just call '-init' on its superclass.", NSStringFromClass([self class]), __FUNCTION__];
		NSAssert(false, msg);
	}
	return self;
}

- (void)updateFromJSON:(NSDictionary *)json {
	NSString *msg = [NSString stringWithFormat:@"%s called on ApiData subclass (%@) that does not implement it.", __FUNCTION__, NSStringFromClass([self class])];
	NSAssert(false, msg);
}

// ----------------------------------------------------------------------

+ (void)get_array:(NSString *)verb
		   params:(NSDictionary *)params
		  success:(void(^)(NSArray *array))success
		  failure:(void(^)(NSError *error))failure {
	
	[ApiData request:verb params:params success:^(NSArray *data) {
		// TODO: validate that returned item(s) are all ApiData
		if ([data count]) {
			if (success)
				success(data);
		}
		else {
			NSError *error = [ServiceMBTA error_RZImport_unknown];
			if (failure)
				failure(error);
			else
				NSLog(@"%s ERROR: %@", __FUNCTION__, [error localizedDescription]);
		}
	} failure:^(NSError *error) {
		if (failure)
			failure(error);
		else
			NSLog(@"%s API call failed: %@", __FUNCTION__, [error localizedDescription]);
	}];
}

- (void)update_success:(void(^)(ApiData *item))success
			   failure:(void(^)(NSError *error))failure {
	NSString *msg = [NSString stringWithFormat:@"ApiData subclass '%@' fails to implement %s.", NSStringFromClass([self class]), __FUNCTION__];
	NSAssert(false, msg);
	if (failure)
		failure([ApiData error_incomplete_implementation]);
}

// ----------------------------------------------------------------------
#pragma mark - errors
// ----------------------------------------------------------------------

+ (NSError *)error_unknown {
	return [[NSError alloc] initWithDomain:ApiData_ErrorDomain
									  code:-1
								  userInfo:@{ NSLocalizedDescriptionKey : str_error_unknown }];
}
+ (NSError *)error_incomplete_implementation {
	return [[NSError alloc] initWithDomain:ApiData_ErrorDomain
									  code:-1
								  userInfo:@{ NSLocalizedDescriptionKey : str_error_incomplete_implementation }];
}

// ----------------------------------------------------------------------
#pragma mark - locals
// ----------------------------------------------------------------------

+ (void)request:(NSString *)verb
		 params:(NSDictionary *)params
		success:(void(^)(NSArray *data))success
		failure:(void(^)(NSError *error))failure {
	
	// add apiKey and format=[json/xml]
	NSMutableDictionary *params_internal = [[ServiceMBTA default_params] mutableCopy];
	if ([params count])
		[params_internal addEntriesFromDictionary:params];
#if CONFIG_USE_RestKit
	[ServiceMBTA request:verb
				  params:params_internal
				 success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
					 if (success) {
						 success(mappingResult.array);
					 }
				 }
				 failure:^(RKObjectRequestOperation *operation, NSError *error) {
					 if (failure)
						 failure(error);
					 else
						 NSLog(@"%s API call failed: %@", __FUNCTION__, [error localizedDescription]);
				 }];
#else
	NSError *error = [ApiData error_incomplete_implementation];
	if (failure)
		failure(error);
	else
		NSLog(@"Error: %@", [error localizedDescription]);
#endif
}

// ----------------------------------------------------------------------
@end
