//
//  ApiRoutes.h
//  MBTA-RZImport
//
//  Created by Steve Caine on 12/26/14.
//  Copyright (c) 2014 Steve Caine. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ApiData.h"
#import "ApiStops.h"

// ----------------------------------------------------------------------

typedef enum : NSUInteger {
	mode_unknown,
	mode_Subway, // there are two Subway modes: Green Line and everything else
	mode_Rail,	 // so this enum is part of our logic to combine them
	mode_Bus,
	mode_Boat
} RouteMode;

// ----------------------------------------------------------------------
//@class ApiRouteMode;
// ----------------------------------------------------------------------

@interface ApiRouteDirection : ApiData

@property (  copy, nonatomic) NSNumber *ID;
@property (  copy, nonatomic) NSString *name;
@property (strong, nonatomic) NSArray  *stops;

@end

// ----------------------------------------------------------------------

@interface ApiRoute : ApiData

@property (  copy, nonatomic) NSString	*ID;
@property (  copy, nonatomic) NSString	*name;
@property (  copy, nonatomic) NSString	*noUI; // BOOL
@property (assign, nonatomic) RouteMode	mode;
@property (strong, nonatomic) NSArray  *directions;

- (void)addStops_success:(void(^)(ApiRoute *route))success
				 failure:(void(^)(NSError *error))failure;
- (void)updateStops_success:(void(^)(ApiRoute *route))success
					failure:(void(^)(NSError *error))failure;
@end

// ----------------------------------------------------------------------

@interface ApiRouteMode : ApiData
@property (  copy, nonatomic) NSNumber *type;
@property (  copy, nonatomic) NSString *name;
@property (strong, nonatomic) NSArray  *routes;
@end

// ----------------------------------------------------------------------

@interface ApiRoutes : ApiData
// RZ
@property (strong, nonatomic) NSArray *modes;

+ (void)get_success:(void(^)(ApiRoutes *data))success
			failure:(void(^)(NSError *error))failure;

- (void)update_success:(void(^)(ApiRoutes *routes))success
			   failure:(void(^)(NSError *error))failure;
// CALC
- (ApiRoute *)routeByID:(NSString *)routeID;
@end

// ----------------------------------------------------------------------

@interface ApiRoutesByStop: ApiData
@property (  copy, nonatomic) NSString *stopID;
@property (  copy, nonatomic) NSString *stopName;
@property (strong, nonatomic) NSArray  *modes;
+ (void)get4stop:(NSString *)stopID
		  success:(void(^)(ApiRoutesByStop *data))success
		  failure:(void(^)(NSError *error))failure;
- (void)update_success:(void(^)(ApiRoutesByStop *item))success
			   failure:(void(^)(NSError *error))failure;
@end

// ----------------------------------------------------------------------
