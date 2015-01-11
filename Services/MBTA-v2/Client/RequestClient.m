//
//  RequestClient.m
//  MBTA-RZImport
//
//  Created by Steve Caine on 01/10/15.
//  Copyright (c) 2015 Steve Caine. All rights reserved.
//

#import "RequestClient.h"

//#import "AFJSONResponseSerializerWithData.h"
#import "ServiceMBTA.h"

//#import "Debug_iOS.h"

// ----------------------------------------------------------------------

@implementation RequestClient

#pragma mark - globals

// singleton must be thread-safe
+ (RequestClient *)sharedClient {
	static RequestClient *_sharedClient;
	
	static dispatch_once_t oncePredicate;
	dispatch_once(&oncePredicate, ^{
		_sharedClient = [[self alloc] initWithBaseURL:[NSURL URLWithString:[ServiceMBTA str_BaseURL]]];});
	
	return _sharedClient;
}

- (NSString *)request:(NSString *)verb
			   params:(NSDictionary *)params
			   format:(ResponseFormat)format
			  success:(void(^)(NSURLSessionDataTask *task, id responseObject))success
			  failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failure {
	//	MyLog(@"%s verb='%@' params=%@", __FUNCTION__, verb, params);
	
	NSString *result = nil;
	
	// base + verb + key + params + format
	
	NSMutableString *str_params = [NSMutableString string];
	NSArray *keys = [params allKeys];
	for (NSString *key in keys) {
		[str_params appendFormat:@"&%@=%@", key, params[key]];
	}
	
	NSString *str_format = nil;
	switch (format) {
		case xmlFormat:
			str_format = @"xml";
			break;
		case jsonFormat:
		default:
			str_format = @"json";
			break;
	}
	
	NSString *path = [NSString stringWithFormat:@"%@?api_key=%@%@&format=%@", verb, [ServiceMBTA str_key_API], str_params, str_format];
	
	result = [NSString stringWithFormat:@"%@%@", [ServiceMBTA str_BaseURL], path];
	
#if 0 //def DEBUG
	MyLog(@" key = '%@'", [NSString stringWithFormat:@"%@%@", verb, str_params]);
	MyLog(@" url = '%@'", result);
#endif
	
	//	MyLog(@"   path = '%@'", path);
	//	MyLog(@" result = '%@'", result);
	
	[self GET:path parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
		if (success) {
			success(task, responseObject);
		}
	} failure:^(NSURLSessionDataTask *task, NSError *error) {
		if (failure)
			failure(task, error);
		else
			NSLog(@"%s API call failed: %@", __FUNCTION__, [error localizedDescription]);
	}];
	return result;
}

#pragma mark - locals

- (instancetype)initWithBaseURL:(NSURL *)url {
	self = [super initWithBaseURL:url];
	if (self) {
		self.responseSerializer = [AFJSONResponseSerializer serializer];
		// SPC 07-22-14 from Greg Fiumara's blog
		// http://blog.gregfiumara.com/archives/239
//		self.responseSerializer = [AFJSONResponseSerializerWithData serializer];
		
		self.requestSerializer  = [AFJSONRequestSerializer  serializer];
	}
	return self;
}

@end

// ----------------------------------------------------------------------
