//
//  ApiRequest_private.h
//  MBTA-RZImport
//
//  Created by Steve Caine on 01/10/15.
//  Copyright (c) 2015 Steve Caine. All rights reserved.
//

#import "ApiRequest.h"

// ----------------------------------------------------------------------

// private
@interface ApiRequest ()

//@property (copy, nonatomic, readwrite) NSString *verb;
//@property (copy, nonatomic, readwrite) NSString *key;
@property (  copy, nonatomic) NSString *verb;
//@property (  copy, nonatomic) NSString *key;

@property (strong, nonatomic) NSMutableDictionary *params;
@property (strong, nonatomic) ApiData *data; // the request-appropriate subclass of ApiData

// bypass 'staleAge' logic, always make fresh request to service
- (void)get_success:(void(^)(ApiRequest *request))success
			failure:(void(^)(NSError *error))failure;

- (double)staleAge; // subclasses MUST override this

@end

