//
//  RequestClient.h
//  MBTA-RZImport
//
//  Created by Steve Caine on 01/10/15.
//  Copyright (c) 2015 Steve Caine. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>

// ----------------------------------------------------------------------

typedef enum ResponseFormats {
	xmlFormat = -1,
	jsonFormat,
	jsonpFormat
} ResponseFormat;

// ----------------------------------------------------------------------

@interface RequestClient : AFHTTPSessionManager

+ (RequestClient *)sharedClient;

- (NSString *)request:(NSString *)verb
			   params:(NSDictionary *)params
			   format:(ResponseFormat)format
			  success:(void(^)(NSURLSessionDataTask *task, id responseObject))success
			  failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failure;

@end

// ----------------------------------------------------------------------
