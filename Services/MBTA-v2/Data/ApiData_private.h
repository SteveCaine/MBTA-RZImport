//
//  ApiData_private.h
//  MBTA-RZImport
//
//  Created by Steve Caine on 01/10/15.
//  Copyright (c) 2015 Steve Caine. All rights reserved.
//

#import "ApiData.h"

#import "ApiRoutes.h"

// --------------------------------------------------

@interface ApiData ()

@property (  copy, nonatomic) NSString		*verb;
@property (  copy, nonatomic) NSDictionary	*params;

+ (void)get_item:(NSString *)verb
		  params:(NSDictionary *)params
		 success:(void(^)(ApiData *item))success
		 failure:(void(^)(NSError *error))failure;

- (void)internal_update_success:(void(^)(ApiData *item))success
						failure:(void(^)(NSError *error))failure;

+ (ApiData *)itemForResponse:(NSDictionary *)response
						verb:(NSString *)verb
					  params:(NSDictionary *)params;

- (instancetype)initWithResponse:(NSDictionary *)response;

- (void)updateFromResponse:(NSDictionary *)response;

@end

// --------------------------------------------------

@interface ApiRouteDirections : ApiData
@property (strong, nonatomic) NSArray *directions;
@end

// --------------------------------------------------

@interface ApiRouteDirection ()
+ (NSArray *)updateDirections:(NSArray *)cur_directions
			   withDirections:(NSArray *)a_directions;
@end

// --------------------------------------------------

@interface ApiStop ()
+ (NSArray *)updateStops:(NSArray *)cur_stops
			   withStops:(NSArray *)a_stops
				forClass:(id)class;
@end

// --------------------------------------------------
