//
//  ApiData.m
//  MBTA-RZImport
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
			data.params = params; // 'copy' property
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
		NSString *msg = [NSString stringWithFormat:
						 @"ApiData subclass '%@' should handle %s and just call '-init' on its superclass.",
						 NSStringFromClass([self class]), __FUNCTION__];
		NSAssert(false, msg);
	}
	return self;
}

- (void)updateFromJSON:(NSDictionary *)json {
	NSString *msg = [NSString stringWithFormat:
					 @"%s called on ApiData subclass (%@) that does not implement it.",
					 __FUNCTION__, NSStringFromClass([self class])];
	NSAssert(false, msg);
}

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
#if CONFIG_useXML
							 format:xmlFormat
#else
							 format:jsonFormat // default is JSON
#endif
							success:^(NSURLSessionDataTask *task, id responseObject) {
								[self log_task:task];
								MyLog(@" response = %@", responseObject);
#if CONFIG_useXML
#error NOT YET IMPLEMENTED
#warning TODO - add support for XML parsing (such as blakewatters' 'XMLReader' - https://github.com/blakewatters/XML-to-NSDictionary)
								NSXMLParser *parser = (NSXMLParser *)responseObject;
								parser.shouldProcessNamespaces = YES;
#endif
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
								if (failure)
									failure(error);
								else
									NSLog(@"%s API call failed: %@", __FUNCTION__, [error localizedDescription]);
							}];
	MyLog(@" request URL = '%@'", url);
}

+ (void)log_task:(NSURLSessionDataTask *)task {
	NSURLRequest *request = [task originalRequest];
	NSURL *url = request.URL;
	NSString *requestStr = [url absoluteString];
	MyLog(@" request = '%@'", requestStr);
	
#ifdef DEBUG
	// log HTTP headers in request and response
	MyLog(@"\n requestHeaders = %@\n", [request allHTTPHeaderFields]);
	
	NSURLResponse *response = [task response];
	if ([response respondsToSelector:@selector(allHeaderFields)]) {
		NSDictionary *headers = [(NSHTTPURLResponse *)response allHeaderFields];
		MyLog(@" responseHeaders = %@", headers);
	}
#endif
}

// --------------------------------------------------

@end
