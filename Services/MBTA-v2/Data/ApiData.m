//
//  ApiData.m
//  MBTA-APIs
//
//  Created by Steve Caine on 12/31/14.
//  Copyright (c) 2014 Steve Caine. All rights reserved.
//

#import "ApiData.h"
#import "ApiData_private.h"
#import "ApiData+RZImport.h"

#import "RequestClient.h"

#import "ServiceMBTA+RZImport.h"

#import "Debug_iOS.h"

#define str_unknown_error			@"ApiData: Unknown error."
#define str_JSON_import_failed		@"ApiData: JSON import failed."
#define str_missing_implementation	@"ApiData: Missing implementation." // not meant to be user-facing error msg

@implementation ApiData
// ----------------------------------------------------------------------

+ (void)get_item:(NSString *)verb
		  params:(NSDictionary *)params
		 success:(void(^)(ApiData *item))success
		 failure:(void(^)(NSError *error))failure {

	[ApiData request:verb params:params item:nil success:^(ApiData *data) {
		if ([data isKindOfClass:[ApiData class]]) {
			data.verb = verb;
			data.params = [params copy];
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

- (void)internal_update_success:(void(^)(ApiData *item))success
						failure:(void(^)(NSError *error))failure {
	[ApiData request:self.verb params:self.params item:self success:^(ApiData *data) {
		if (success)
			success(data);
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
#if CONFIG_USE_RestKit
/*
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

- (void)update_array:(NSString *)verb
			 success:(void(^)(NSArray *array))success
			 failure:(void(^)(NSError *error))failure {
	NSString *msg = [NSString stringWithFormat:@"Class '%@' fails to implement %s.", NSStringFromClass([self class]), __FUNCTION__];
	NSAssert(false, msg);
	if (failure)
		failure([ApiData error_missing_implementation]);
}
*/
#endif

// ----------------------------------------------------------------------
#pragma mark - errors
// ----------------------------------------------------------------------

+ (NSError *)error_unknown {
	return [[NSError alloc] initWithDomain:ApiData_ErrorDomain
									  code:-1
								  userInfo:@{ NSLocalizedDescriptionKey : str_unknown_error }];
}
+ (NSError *)error_JSON_import_failed {
	return [[NSError alloc] initWithDomain:ApiData_ErrorDomain
									  code:-2
								  userInfo:@{ NSLocalizedDescriptionKey : str_JSON_import_failed }];
}
+ (NSError *)error_missing_implementation {
	return [[NSError alloc] initWithDomain:ApiData_ErrorDomain
									  code:-3
								  userInfo:@{ NSLocalizedDescriptionKey : str_missing_implementation }];
}

// ----------------------------------------------------------------------
#pragma mark - locals
// ----------------------------------------------------------------------

+ (void)request:(NSString *)verb
		 params:(NSDictionary *)params
		   item:(ApiData *)item // nil for -get-, else this is -update-
		success:(void(^)(ApiData *data))success
		failure:(void(^)(NSError *error))failure {
	
	RequestClient *client = [RequestClient sharedClient];
	NSString *url = [client request:verb
							 params:params
							 format:jsonFormat
							success:^(NSURLSessionDataTask *task, id responseObject) {
								ApiData *data = item;
								if (data)
									[data updateFromJSON:responseObject];
								else
									data = [ApiData itemForJSON:responseObject verb:verb params:params];
								if (data) {
									if (success)
										success(data);
								}
								else {
									NSError *error = [self error_JSON_import_failed];
									if (failure)
										failure(error);
									else
										NSLog(@"%s %@", __FUNCTION__, [error localizedDescription]);
								}
							}
					 
							failure:^(NSURLSessionDataTask *task, NSError *error) {
//								[self failure:task error:error];
								if (failure)
									failure(error);
								else
									NSLog(@"%s API call failed: %@", __FUNCTION__, [error localizedDescription]);
							}];
	NSLog(@" request URL = '%@'", url);
}

// --------------------------------------------------
#pragma mark -
// --------------------------------------------------

- (void)success:(NSURLSessionDataTask *)task response:(id)responseObject {
	//	self.data = [ApiData itemForJSON:responseObject key:[self key]];
//	self.data = [ApiData itemForJSON:responseObject verb:self.verb params:self.params];
}

- (void)failure:(NSURLSessionDataTask *)task error:(NSError *)error {
	NSLog(@"ApiRequest error: %@", [error localizedDescription]);
}

// ----------------------------------------------------------------------
@end
