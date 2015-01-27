//
//  ApiRequest.h
//  MBTA-RZImport
//
//  Created by Steve Caine on 01/10/15.
//  Copyright (c) 2015 Steve Caine. All rights reserved.
//

#import <Foundation/Foundation.h>

#warning TODO - do away with Request class hierarchy in this branch!
// ----------------------------------------------------------------------
@class ApiData;

@interface ApiRequest : NSObject

// or just make these private?
//@property (copy, nonatomic, readonly) NSString *verb;
//@property (copy, nonatomic, readonly) NSString *key;

- (void)refresh_success:(void(^)(ApiRequest *request))success
				failure:(void(^)(NSError *error))failure;

- (ApiData *)response; // an ApiData subclass specific to the request

- (NSString *)result;	// short string describing response

@end

// ----------------------------------------------------------------------
