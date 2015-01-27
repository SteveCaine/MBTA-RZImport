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
@property (strong, nonatomic) NSDictionary	*params;

+ (void)get_item:(NSString *)verb
		  params:(NSDictionary *)params
		 success:(void(^)(ApiData *item))success
		 failure:(void(^)(NSError *error))failure;

- (void)internal_update_success:(void(^)(ApiData *item))success
						failure:(void(^)(NSError *error))failure;

#if CONFIG_USE_RestKit
+ (void)get_array:(NSString *)verb
		   params:(NSDictionary *)params
		  success:(void(^)(NSArray *array))success
		  failure:(void(^)(NSError *error))failure;

- (void)update_array:(NSString *)verb
			 success:(void(^)(NSArray *array))success
			 failure:(void(^)(NSError *error))failure;
#endif

- (instancetype)initWithJSON:(NSDictionary *)json;

- (void)updateFromJSON:(NSDictionary *)json;

@end

// --------------------------------------------------
#if CONFIG_USE_RZImport
// --------------------------------------------------

@interface ApiRouteDirections : ApiData
@property (strong, nonatomic) NSArray *directions;
@end

// --------------------------------------------------

@interface ApiRouteDirection ()
+ (NSArray *)updateDirections:(NSArray *)cur_directions withDirections:(NSArray *)a_directions;
@end

// --------------------------------------------------
#if 0
@interface ApiRoute ()
@property (strong, nonatomic) ApiRouteDirections *route_directions;
- (void)setDirections:(NSArray *)directions;
@end
#endif
// --------------------------------------------------
#endif
// --------------------------------------------------

// --------------------------------------------------
//#pragma mark -
// --------------------------------------------------
