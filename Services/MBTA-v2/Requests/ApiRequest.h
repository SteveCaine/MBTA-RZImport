//
//  ApiRequest.h
//  MBTA-RZImport
//
//  Created by Steve Caine on 01/10/15.
//
//	This code is distributed under the terms of the MIT license.
//
//	Copyright (c) 2015 Steve Caine.
//

#import <Foundation/Foundation.h>

// ----------------------------------------------------------------------
@class ApiData;

@interface ApiRequest : NSObject

+ (NSString *)keyForRequest:(NSString *)request;

+ (id)cachedResponseForKey:(NSString *)key staleAge:(double)staleAge;

// subclasses MUST override this
- (void)refresh_success:(void(^)(ApiRequest *request))success
				failure:(void(^)(NSError *error))failure;

- (ApiData *)response; // an ApiData subclass specific to the request

@end

// ----------------------------------------------------------------------
