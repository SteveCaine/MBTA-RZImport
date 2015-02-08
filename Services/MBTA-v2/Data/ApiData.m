//
//  ApiData.m
//  MBTA-RZImport
//
//  Created by Steve Caine on 12/31/14.
//
//	This code is distributed under the terms of the MIT license.
//
//	Copyright (c) 2014-2015 Steve Caine.
//

#import "ApiData.h"
#import "ApiData_private.h"
#import "ApiXMLParserDelegate.h"

#import "RequestClient.h"
#import "ServiceMBTA.h"
#import "ServiceMBTA_strings.h"

#import "ApiRoutes.h"
#import "ApiStops.h"
#import "ApiTime.h"

#import "Debug_iOS.h"

#define str_unknown_error			@"ApiData: Unknown error."
#define str_response_import_failed	@"ApiData: Response import failed."
#define str_wrong_subclass_ApiData	@"ApiData: Wrong subclass of ApiData returned."
#define str_missing_implementation	@"ApiData: Missing implementation." // not meant to be user-facing error msg

@implementation ApiData
// ----------------------------------------------------------------------

+ (void)get_item:(NSString *)verb
		  params:(NSDictionary *)params
		 success:(void(^)(ApiData *item))success
		 failure:(void(^)(NSError *error))failure {

	[ApiData request:verb params:params item:nil success:^(ApiData *data) {
		// callers must validate it's the correct *subclass* of ApiData
		if ([data isKindOfClass:[ApiData class]]) {
			data.verb = verb;
			data.params = params; // 'copy' property
			if (success)
				success(data);
		}
		else {
			NSError *error = [ServiceMBTA error_notApiData];
			if (failure)
				failure(error);
			else
				MyLog(@"%s %@", __FUNCTION__, [error localizedDescription]);
		}
	} failure:^(NSError *error) {
		if (failure)
			failure(error);
		else
			MyLog(@"%s %@", __FUNCTION__, [error localizedDescription]);
	}];
}

- (void)internal_update_success:(void(^)(ApiData *item))success
						failure:(void(^)(NSError *error))failure {
	[ApiData request:self.verb params:self.params item:self success:^(ApiData *data) {
		if (data && [data isKindOfClass:[self class]]) {
			if (success)
				success(data);
		}
		else {
			NSError *error = (data ? [ApiData error_wrong_subclass_ApiData] : [ApiData error_unknown]);
			if (failure)
				failure(error);
			else
				MyLog(@"%s %@", __FUNCTION__, [error localizedDescription]);
			
		}
	} failure:^(NSError *error) {
		if (failure)
			failure(error);
		else
			MyLog(@"%s %@", __FUNCTION__, [error localizedDescription]);
	}];
}

// ----------------------------------------------------------------------

// factory method to create different ApiData types based on request's verb+params
+ (ApiData *)itemForResponse:(NSDictionary *)response
						verb:(NSString *)verb
					  params:(NSDictionary *)params {
	ApiData *result = nil;
	
	if ([response isKindOfClass:[NSDictionary class]]) {
		
		// these responses return a single dictionary
		// so we call 'rzi_objectFromDictionary' directly;
		if ([verb isEqualToString:verb_servertime]) {
			result = [ApiTime rzi_objectFromDictionary:response];
		}
		else if ([verb isEqualToString:verb_routesbystop]) {
			result = [ApiRoutesByStop rzi_objectFromDictionary:response];
		}
		// schedulebystop
		// predictionsbyroute
		// predictionsbystop
		// predictionsbytrip
		// vehiclesbyroute
		// vehiclesbytrip
		// alertsbyid
		
		// these responses return an array of dictionaries under one key
		// so we alloc/init object here, and it calls the appropriate 'rzi_' methods internally
		else if ([verb isEqualToString:verb_routes]) {
			result = [[ApiRoutes alloc] initWithResponse:response];
		}
		else if ([verb isEqualToString:verb_stopsbyroute]) {
			result = [[ApiStopsByRoute alloc] initWithResponse:response];
		}
		else if ([verb isEqualToString:verb_stopsbylocation]) {
			result = [[ApiStopsByLocation alloc] initWithResponse:response];
		}
		// alerts
		// alertsbyroute
		// alertsbystop
		// alertheaders
		// alertheadersbyroute
		// alertheadersbystop
	}
	
	// unused: none of our requests return a raw array of objects
//	else if ([response isKindOfClass:[NSArray class]]) {
	else {
		MyLog(@"%s unexpected response type '%@' for %p", __FUNCTION__, [response class], response);
	}
	
	return result;
}

// ----------------------------------------------------------------------

- (instancetype)initWithResponse:(NSDictionary *)response {
	self = [super init];
	if (self) {
		NSString *msg = [NSString stringWithFormat:
						 @"ApiData subclass '%@' should handle %s and just call '-init' on its superclass.",
						 NSStringFromClass([self class]), __FUNCTION__];
		NSAssert(false, msg);
	}
	return self;
}

- (void)updateFromResponse:(NSDictionary *)response {
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
+ (NSError *)error_response_import_failed {
	return [[NSError alloc] initWithDomain:ApiData_ErrorDomain
									  code:-2
								  userInfo:@{ NSLocalizedDescriptionKey : str_response_import_failed }];
}
+ (NSError *)error_wrong_subclass_ApiData {
	return [[NSError alloc] initWithDomain:ApiData_ErrorDomain
									  code:-3
								  userInfo:@{ NSLocalizedDescriptionKey : str_wrong_subclass_ApiData }];
}
+ (NSError *)error_missing_implementation {
	return [[NSError alloc] initWithDomain:ApiData_ErrorDomain
									  code:-4
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
							 format:jsonFormat
#endif
							success:^(NSURLSessionDataTask *task, id responseObject) {
								[self log_task:task];
								MyLog(@" response = %@", responseObject);
#if CONFIG_useXML
								// AFNetworking returns an NSXMLParser object loaded with response data,
								// it's our job to parse that data
								NSXMLParser *parser = (NSXMLParser *)responseObject;
								parser.shouldProcessNamespaces = YES;
								ApiXMLParserDelegate *delegate = [[ApiXMLParserDelegate alloc] init];
								parser.delegate = delegate;
								[parser parse];
								responseObject = nil; // finished with parser
								
								if ([delegate error] == nil) {
									// our parser delegate returns data from the MBTA's XML responses
									// in a structure compatible with the its JSON responses:
									// the root is a dictionary with a single array item
									// and all child elements in the entire tree
									// are stored in array items on their parent keyed by their element name
									responseObject = [delegate onlyChild];
								}
								delegate = nil;
#else
//								MyLog(@" responseObject = %@", responseObject);
#endif
								
								ApiData *data = item;
								if (data)
									[data updateFromResponse:responseObject];
								else
									data = [ApiData itemForResponse:responseObject verb:verb params:params];
								if (data) {
									if (success)
										success(data);
								}
								else {
									NSError *error = [self error_response_import_failed];
									if (failure)
										failure(error);
									else
										MyLog(@"%s %@", __FUNCTION__, [error localizedDescription]);
								}
							}
					 
							failure:^(NSURLSessionDataTask *task, NSError *error) {
								if (failure)
									failure(error);
								else
									MyLog(@"%s %@", __FUNCTION__, [error localizedDescription]);
							}];
	MyLog(@" request URL = '%@'", url);
}

+ (void)log_task:(NSURLSessionDataTask *)task {
#ifdef DEBUG
	NSURLRequest *request = [task originalRequest];
	NSURL *url = request.URL;
	NSString *requestStr = [url absoluteString];
	MyLog(@" request = '%@'", requestStr);
	
#if DEBUG_logHeadersHTTP
	// log HTTP headers in request and response
	MyLog(@"\n requestHeaders = %@\n", [request allHTTPHeaderFields]);
	
	NSURLResponse *response = [task response];
	if ([response respondsToSelector:@selector(allHeaderFields)]) {
		NSDictionary *headers = [(NSHTTPURLResponse *)response allHeaderFields];
		MyLog(@" responseHeaders = %@", headers);
	}
#endif
#endif
}

// --------------------------------------------------

@end
