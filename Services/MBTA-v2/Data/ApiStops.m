//
//  ApiStops.m
//  MBTA-RZImport
//
//  Created by Steve Caine on 12/26/14.
//
//	This code is distributed under the terms of the MIT license.
//
//	Copyright (c) 2014-2015 Steve Caine.
//

#import "ApiStops.h"

#import "ApiData_private.h"

#import "ApiRoutes.h"
#import "ServiceMBTA_strings.h"

#import "Debug_iOS.h"

// ----------------------------------------------------------------------

@interface ApiStop ()
@property (  copy, nonatomic) NSString *latitude;
@property (  copy, nonatomic) NSString *longitude;
@end

@implementation ApiStop

+ (NSDictionary *)rzi_customMappings {
	return @{
			 @"stop_id"				: @"ID",
			 @"stop_name"			: @"name",
			 @"parent_station"		: @"station",
			 @"parent_station_name"	: @"station_name",
			 @"stop_lat"			: @"latitude",
			 @"stop_lon"			: @"longitude",
			 @"stop_order"			: @"order"
			 };
}

// compares 'cur_stops' (objects) with 'a_stops' (deserialized JSON/XML),
// updating those that match and replacing those that don't
#warning TODO update this for each new sub-class of ApiStop as they're created
+ (NSArray *)updateStops:(NSArray *)cur_stops withStops:(NSArray *)a_stops forClass:(id)class_of_ApiStop {
	NSArray *result = nil;
	if ([cur_stops count] == 0) { // no existing stops (creating new stopsbylocation object)
		result = [class_of_ApiStop rzi_objectsFromArray:a_stops];
	}
	else { // yes existing stops (updating existing stopsbylocation object)
		NSMutableArray *new_stops = [NSMutableArray array];
		NSMutableArray *updated_stops = [NSMutableArray array];
		
		for (NSDictionary *d_stop in a_stops) {
			BOOL updated = NO;
			for (ApiStop *cur_stop in cur_stops) {
				NSString *stop_id = [d_stop objectForKey:key_stop_id];
				if ([stop_id isEqualToString:cur_stop.ID]) {
					[cur_stop rzi_importValuesFromDict:d_stop];
					[updated_stops addObject:cur_stop];
					updated = YES;
					break;
				}
			}
			if (!updated) {
				ApiStop *new_stop = [class_of_ApiStop rzi_objectFromDictionary:d_stop];
				[new_stops addObject:new_stop];
			}
		}
		// stops *not* in response are discarded (from existing ApiStopsByLocation object)
		result = [NSArray arrayWithArray:updated_stops];
		// new stops in response are added (*all* if this is new ApiStopsByLocation object)
		result = [result arrayByAddingObjectsFromArray:new_stops];
	}
	return result;
}

- (CLLocationCoordinate2D) location {
	CLLocationCoordinate2D result = {0,0};
	if ([self.latitude length] && [self.longitude length]) {
		result.latitude  = [self.latitude  doubleValue];
		result.longitude = [self.longitude doubleValue];
	}
	return result;
}

- (NSString *)description {
	NSMutableString *result = [NSMutableString stringWithFormat:@"<%@ %p>", NSStringFromClass([self class]), self];
	
	BOOL numericID = ([self.ID integerValue] != 0);
	NSString *strID = (numericID ? [NSString stringWithFormat:@"#%@", self.ID] : [NSString stringWithFormat:@"'%@'",self.ID]);
	
	if (self.order)
		[result appendFormat:@"%2i: ", (int)[self.order integerValue]];
	
	[result appendFormat:@"Stop %@ ('%@')", strID, self.name];
	
	if ([self.distance floatValue] > 0.0)
		[result appendFormat:@" is %f miles away", [self.distance floatValue]];
	
	[result appendFormat:@" at %f, %f (lat,lon)", self.location.latitude, self.location.longitude];
	
	return result;
}
@end

// ----------------------------------------------------------------------

@implementation ApiStopsByRoute


+ (void)get4route:(NSString *)routeID
		  success:(void(^)(ApiStopsByRoute *data))success
		  failure:(void(^)(NSError *error))failure {
	NSDictionary *params = @{ param_route : routeID };
	
	[ApiData get_item:verb_stopsbyroute params:params success:^(ApiData *item) {
		if (item && [item isKindOfClass:[ApiStopsByRoute class]]) {
			ApiStopsByRoute *stopsbyroute = (ApiStopsByRoute *)item;
			stopsbyroute.routeID = routeID;
			if (success)
				success(stopsbyroute);
		}
		else {
			NSError *error = (item ? [ApiData error_wrong_subclass_ApiData] : [ApiData error_unknown]);
			if (failure)
				failure(error);
			else
				MyLog(@"%@ 'get' failed: %@", NSStringFromClass([self class]), [error localizedDescription]);
		}
	} failure:^(NSError *error) {
		if (failure)
			failure(error);
		else
			NSLog(@"%@ 'get' failed: %@", NSStringFromClass([self class]), [error localizedDescription]);
	}];
}
- (void)update_success:(void(^)(ApiStopsByRoute *stops))success
			   failure:(void(^)(NSError *error))failure {
	[super internal_update_success:^(ApiData *item) {
		if (success)
			success(self);
	} failure:^(NSError *error) {
		if (failure)
			failure(error);
		else
			NSLog(@"%@ 'update' failed: %@", NSStringFromClass([self class]), [error localizedDescription]);
	}];
}

- (instancetype)initWithResponse:(NSDictionary *)response {
	self = [super init];
	if (self) {
		[self updateFromResponse:response];
	}
	return self;
}

- (void)updateFromResponse:(NSDictionary *)response {
	NSArray *a_directions = [response objectForKey:key_direction];
	self.directions = [ApiRouteDirection updateDirections:self.directions withDirections:a_directions];
}

- (NSString *)description {
	NSMutableString *result = [NSMutableString stringWithFormat:@"<%@ %p>", NSStringFromClass([self class]), self];
	if ([self.directions count]) {
		int index = 0;
		for (ApiRouteDirection *direction in self.directions) {
			[result appendFormat:@"\n%2i: %@", index++, direction];
		}
	}
	return result;
}

@end

// ----------------------------------------------------------------------

@implementation ApiStopsByLocation

+ (void)get4location:(CLLocationCoordinate2D)location
			 success:(void(^)(ApiStopsByLocation *data))success
			 failure:(void(^)(NSError *error))failure {
	NSDictionary *params = @{
							 param_lat : [NSNumber numberWithFloat:location.latitude],
							 param_lon : [NSNumber numberWithFloat:location.longitude]
							};
	
	[ApiData get_item:verb_stopsbylocation params:params success:^(ApiData *item) {
		if (item && [item isKindOfClass:[ApiStopsByLocation class]]) {
			if (success) {
				ApiStopsByLocation *stopsbylocation = (ApiStopsByLocation *)item;
				stopsbylocation.location = location;
				success(stopsbylocation);
			}
		}
		else {
			NSError *error = (item ? [ApiData error_wrong_subclass_ApiData] : [ApiData error_unknown]);
			if (failure)
				failure(error);
			else
				MyLog(@"%@ 'get' failed: %@", NSStringFromClass([self class]), [error localizedDescription]);
		}
	} failure:^(NSError *error) {
		if (failure)
			failure(error);
		else
			NSLog(@"%@ 'get' failed: %@", NSStringFromClass([self class]), [error localizedDescription]);
	}];
}
// a real app would never 'update' an existing stops-by-location object
// as a user's location is infinitely variable in two dimensions
- (void)update_success:(void(^)(ApiStopsByLocation *stops))success
			   failure:(void(^)(NSError *error))failure {
	[super internal_update_success:^(ApiData *item) {
		if (success)
			success(self);
	} failure:^(NSError *error) {
		if (failure)
			failure(error);
		else
			NSLog(@"%@ 'update' failed: %@", NSStringFromClass([self class]), [error localizedDescription]);
	}];
}

- (instancetype)initWithResponse:(NSDictionary *)response {
	self = [super init];
	if (self) {
		[self updateFromResponse:response];
	}
	return self;
}

- (void)updateFromResponse:(NSDictionary *)response {
	NSArray *a_stops = [response objectForKey:key_stop];
	self.stops = [ApiStop updateStops:self.stops withStops:a_stops forClass:[ApiStop class]];
}

- (NSString *)description {
	NSMutableString *result = [NSMutableString stringWithFormat:@"<%@ %p>", NSStringFromClass([self class]), self];
	[result appendFormat:@" at %f, %f (lat,lon)", self.location.latitude, self.location.longitude];
	if ([self.stops count]) {
		int index = 0;
		for (ApiStop *stop in self.stops) {
			[result appendFormat:@"\n%2i: %@", index++, stop];
		}
	}
	return result;
}

// ----------------------------------------------------------------------

@end
