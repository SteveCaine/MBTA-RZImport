//
//  ApiRoute.m
//  MBTA-RZImport
//
//  Created by Steve Caine on 12/26/14.
//  Copyright (c) 2014 Steve Caine. All rights reserved.
//

#import "ApiRoutes.h"

#import "ApiData_private.h"
#import "ApiStops.h"

#import "ServiceMBTA_strings.h"

//#import "NSObject+RZImport.h"
//#import "RZImportable.h"

#import "Debug_iOS.h"

static ApiRoutes *sRoutes;

// --------------------------------------------------
//#pragma mark -
// --------------------------------------------------
// map enum values to mode names
static NSString * const strs_RouteMode[] = {
	@"",	// unknown mode
	@"Subway",
	@"Rail",
	@"Bus",
	@"Boat"
};
NSUInteger num_strs_RouteMode = sizeof(strs_RouteMode)/sizeof(strs_RouteMode[0]);

RouteMode mode_for_name(NSString *mode_name) {
	RouteMode result = mode_unknown;
	NSUInteger index = 1;
	while (index < num_strs_RouteMode) {
		if ([mode_name isEqualToString:strs_RouteMode[index]]) {
			result = index;
			break;
		}
		++index;
	}
	return result;
}

NSString *name_for_mode(RouteMode mode) {
	if (mode < num_strs_RouteMode)
		return strs_RouteMode[mode];
	return nil;
}

// --------------------------------------------------
#pragma mark -
// --------------------------------------------------

@implementation ApiRouteDirections
@end

// --------------------------------------------------
#pragma mark -
// --------------------------------------------------

@implementation ApiRouteDirection

+ (NSDictionary *)rzi_customMappings {
	return @{
			 @"direction_id"   : @"ID",
			 @"direction_name" : @"name",
			 };
}
- (BOOL)rzi_shouldImportValue:(id)value forKey:(NSString *)key {
	if ([key isEqualToString:key_stop]) {
		self.stops = [ApiStop updateStops:self.stops withStops:value forClass:[ApiStop class]];
		return NO;
	}
	return YES;
}
// compares 'cur_directions' (objects) with 'a_directions' (deserialized JSONs),
// updating those that match and replacing those that don't
+ (NSArray *)updateDirections:(NSArray *)cur_directions withDirections:(NSArray *)a_directions {
	NSArray *result = nil;
	
	if ([cur_directions count] == 0) { // no existing directions (creating new parent object)
		result = [ApiRouteDirection rzi_objectsFromArray:a_directions];
	}
	else { // yes existing directions (updating existing parent object)
		NSMutableArray     *new_directions = [NSMutableArray array];
		NSMutableArray *updated_directions = [NSMutableArray array];
		
		for (NSDictionary *d_direction in a_directions) {
			BOOL updated = NO;
			for (ApiRouteDirection *cur_direction in cur_directions) {
				
				// equivalent to '-isOurData:' in class RouteMode
				NSString *direction_id = [d_direction objectForKey:key_direction_id];
				if (direction_id && ([direction_id integerValue] == [cur_direction.ID integerValue])) {
					
					[cur_direction rzi_importValuesFromDict:d_direction];
					[updated_directions addObject:cur_direction];
					updated = YES;
					break;
				}
			}
			if (!updated) {
				ApiRouteDirection *new_direction = [ApiRouteDirection rzi_objectFromDictionary:d_direction];
				[new_directions addObject:new_direction];
			}
		}
		// old directions *not* found in json are discarded (from existing ApiRoutes object)
		result = [NSArray arrayWithArray:updated_directions];
		// new directions found in json are added (*all* if this is new ApiRoutes object)
		result = [result arrayByAddingObjectsFromArray:new_directions];
	}
	return result;
}

- (NSString *)description {
	NSMutableString *result = [NSMutableString stringWithFormat:@"<%@ %p>", NSStringFromClass([self class]), self];
	[result appendFormat:@"\n\tid = '%@', name = '%@'", self.ID, self.name];
	if ([self.stops count]) {
		int index = 0;
		for (ApiStop *stop in self.stops) {
			NSString *stop_order = ([stop.order isKindOfClass:[NSNumber class]]	? [NSString stringWithFormat:@"%2li", (long)[stop.order integerValue]] : [stop.order description]);
			[result appendFormat:@"\n\t%2i: %@: stop %@ (%@) is at %f, %f (lat/lon)", index++, stop_order, stop.ID, stop.name, [stop location].latitude, [stop location].longitude];
		}
	}
	return result;
}

@end

// --------------------------------------------------
#pragma mark -
// --------------------------------------------------

@interface ApiRoute ()
@property (strong, nonatomic) ApiStopsByRoute *stopsbyroute;
@end

@implementation ApiRoute

+ (NSDictionary *)rzi_customMappings {
	return @{
			 @"route_id"   : @"ID",
			 @"route_name" : @"name",
			 @"route_hide" : @"noUI"
			 };
}
- (BOOL)rzi_shouldImportValue:(id)value forKey:(NSString *)key {
	if ([key isEqualToString:key_direction]) {
		self.directions = [ApiRouteDirection rzi_objectsFromArray:value];
		return NO;
	}
	return YES;
}

- (void)addStops_success:(void(^)(ApiRoute *route))success
				 failure:(void(^)(NSError *error))failure {
	NSDictionary *params = @{ param_route : self.ID };
	
	[ApiData get_item:verb_stopsbyroute params:params success:^(ApiData *data) {
		self.stopsbyroute = (ApiStopsByRoute *)data;
		self.directions = self.stopsbyroute.directions;
		if (success) {
			success(self);
		}
	} failure:^(NSError *error) {
		NSLog(@"%s API call failed: %@", __FUNCTION__, [error localizedDescription]);
	}];
}

- (void)updateStops_success:(void(^)(ApiRoute *route))success
					failure:(void(^)(NSError *error))failure {
	[self.stopsbyroute update_success:^(ApiStopsByRoute *stops) {
		NSAssert(stops == self.stopsbyroute, @"Update failed to return original item.");
		self.directions = self.stopsbyroute.directions;
		if (success) {
			success(self);
		}
	} failure:^(NSError *error) {
		NSLog(@"%s API call failed: %@", __FUNCTION__, [error localizedDescription]);
	}];
}

- (NSString *)description {
	NSMutableString *result = [NSMutableString stringWithFormat:@"<%@ %p>", NSStringFromClass([self class]), self];
	
	BOOL numericID = ([self.ID integerValue] != 0);
	NSString *strID = (numericID ? [NSString stringWithFormat:@"#%@", self.ID] : [NSString stringWithFormat:@"'%@'",self.ID]);
	
	[result appendFormat:@"\n\t\t id = '%@', name = '%@'", strID, self.name];
	if ([self.directions count]) {
		int index = 0;
		for (ApiRouteDirection *direction in self.directions) {
			[result appendFormat:@"\n\t%2i: direction '%@' has %lu stops", index++, direction.name, (unsigned long)[direction.stops count]];
		}
	}
	return result;
}

@end

// --------------------------------------------------
#pragma mark -
// --------------------------------------------------
@interface ApiRouteMode ()
- (BOOL)isOurData:(NSDictionary *)dict;
@end

@implementation ApiRouteMode

+ (NSDictionary *)rzi_customMappings {
	return @{
			 @"route_type" : @"type",
			 @"mode_name"  : @"name",
			 };
}
+ (NSArray *)rzi_nestedObjectKeys {
	return @[ key_route ];
}
- (BOOL)rzi_shouldImportValue:(id)value forKey:(NSString *)key {
	if ([key isEqualToString:key_route]) {
		self.routes = [ApiRoute rzi_objectsFromArray:value];
		return NO;
	}
	return YES;
}
// compares 'cur_modes' (objects) with 'a_modes' (deserialized JSONs),
// updating those that match (-isOurData:) and replacing those that don't
+ (NSArray *)updateModes:(NSArray *)cur_modes withModes:(NSArray *)a_modes {
	NSArray *result = nil;
	if ([cur_modes count] == 0) { // no existing modes (creating new routes object)
		result = [ApiRouteMode rzi_objectsFromArray:a_modes];
	}
	else { // yes existing modes (updating existing routes object)
		NSMutableArray     *new_modes = [NSMutableArray array];
		NSMutableArray *updated_modes = [NSMutableArray array];
		
		for (NSDictionary *d_mode in a_modes) {
			BOOL updated = NO;
			for (ApiRouteMode *cur_mode in cur_modes) {
				if ([cur_mode isOurData:d_mode]) {
					[cur_mode rzi_importValuesFromDict:d_mode];
					[updated_modes addObject:cur_mode];
					updated = YES;
					break;
				}
			}
			if (!updated) {
				ApiRouteMode *new_mode = [ApiRouteMode rzi_objectFromDictionary:d_mode];
				[new_modes addObject:new_mode];
			}
		}
		// modes *not* in json are discarded (from existing ApiRoutes object)
		result = [NSArray arrayWithArray:updated_modes];
		// new modes in json are added (*all* if this is new ApiRoutes object)
		result = [result arrayByAddingObjectsFromArray:new_modes];
	}
	return result;
}

// match route_type and mode_name values in dict against our own
- (BOOL)isOurData:(NSDictionary *)dict {
	BOOL result = NO;
	if (dict) {
		NSString *mode_name = [dict objectForKey:key_mode_name];
		if ([mode_name length] && [mode_name isEqualToString:self.name]) {
			NSString *str_route_type = [dict objectForKey:key_route_type];
			if ([str_route_type length]) {
				NSNumber *route_type = [NSNumber numberWithInteger:[str_route_type integerValue]];
				if ([route_type compare:self.type] == NSOrderedSame) {
					result = YES;
				}
			}
		}
	}
	MyLog(@"%s %p returns %s", __FUNCTION__, dict, (result ? "YES" : "NO"));
	return result;
}

- (NSString *)description {
	NSMutableString *result = [NSMutableString stringWithFormat:@"<%@ %p>", NSStringFromClass([self class]), self];
	[result appendFormat:@"\n\ttype = '%@', name = '%@'", self.type, self.name];
	if ([self.routes count]) {
		int index = 0;
		for (ApiRoute *route in self.routes) {
			
			BOOL numericID = ([route.ID integerValue] != 0);
			NSString *strID = (numericID ? [NSString stringWithFormat:@"#%@", route.ID] : [NSString stringWithFormat:@"'%@'",route.ID]);
			
			[result appendFormat:@"\n\t%2i: route %@ (%@)", index++, strID, route.name];
		}
	}
	return result;
}

@end

// --------------------------------------------------
#pragma mark -
// --------------------------------------------------

@interface ApiRoutes ()
// RZ
// CALC
@property (strong, nonatomic) NSMutableArray *all_routes;
@property (strong, nonatomic) NSMutableDictionary *routes_by_mode_name;
@end

// --------------------------------------------------
#pragma mark -
// --------------------------------------------------

@implementation ApiRoutes

static ApiRoutes *sRoutes;

+ (void)initialize {
	MyLog(@"%s called.", __FUNCTION__);
}

+ (void)get_success:(void(^)(ApiRoutes *data))success
			failure:(void(^)(NSError *error))failure {
	[ApiData get_item:verb_routes params:nil success:^(ApiData *item) {
		// TODO: validate that returned item IS ApiRoutes
		if (success)
			success((ApiRoutes *)item);
	} failure:^(NSError *error) {
		if (failure)
			failure(error);
		else
			NSLog(@"%s API call failed: %@", __FUNCTION__, [error localizedDescription]);
	}];
}

- (void)update_success:(void(^)(ApiRoutes *routes))success
			   failure:(void(^)(NSError *error))failure {
	[super internal_update_success:^(ApiData *item) {
		// -super- should catch this and call our 'failure' block
		NSAssert(item == self, @"Update failed to return original item.");
		if (success)
			success((ApiRoutes *)item);
	} failure:^(NSError *error) {
		if (failure)
			failure(error);
		else
			NSLog(@"%s failed: %@", __FUNCTION__, [error localizedDescription]);
	}];
}

- (ApiRoute *)routeByID:(NSString *)routeID {
	ApiRoute *result = nil;
	for (ApiRouteMode * mode in self.modes) {
		for (ApiRoute *route in mode.routes) {
			if ([route.ID isEqualToString:routeID]) {
				result = route;
				break;
			}
			if (result)
				break;
		}
	}
	return result;
}

- (instancetype)initWithJSON:(NSDictionary *)json {
	self = [super init];
	if (self) {
		// nothing else to do here, so just call update
		[self updateFromJSON:json];
	}
	return self;
}

- (void)updateFromJSON:(NSDictionary *)json {
	NSArray *a_modes = [json objectForKey:key_mode];
	self.modes = [ApiRouteMode updateModes:self.modes withModes:a_modes];
	
	if (_all_routes)
		[_all_routes removeAllObjects];
	else
		_all_routes = [NSMutableArray array];
	
	if (_routes_by_mode_name)
		[_routes_by_mode_name removeAllObjects];
	else
		_routes_by_mode_name = [NSMutableDictionary dictionary];
	
	for (ApiRouteMode *mode in _modes) {
		// set the 'mode' enum on every route this mode contains
		RouteMode route_mode = mode_for_name(mode.name);
		for (ApiRoute *route in mode.routes)
			route.mode = route_mode;
		
		[_all_routes addObjectsFromArray:mode.routes];
		
		// in the case of Subway, this combines routes from both subway modes (Green Line and everything else)
		NSMutableArray *mode_routes = [_routes_by_mode_name objectForKey:mode.name];
		if (mode_routes == nil) {
			mode_routes = [NSMutableArray arrayWithArray:mode.routes];
			[_routes_by_mode_name setObject:mode_routes forKey:mode.name];
		}
		[mode_routes addObjectsFromArray:mode.routes];
	}
}

- (NSString *)description {
	NSMutableString *result = [NSMutableString stringWithFormat:@"<%@ %p>", NSStringFromClass([self class]), self];
	if ([self.modes count]) {
		int index = 0;
		for (ApiRouteMode *mode in self.modes) {
			[result appendFormat:@"\n%2i: %@", index++, mode];
		}
	}
	return result;
}

@end

// --------------------------------------------------
#pragma mark -
// --------------------------------------------------

@implementation ApiRoutesByStop

+ (void)get4stop:(NSString *)stopID
		   success:(void(^)(ApiRoutesByStop *data))success
		   failure:(void(^)(NSError *error))failure {
	NSDictionary *params = @{ param_stop : stopID };
	
	[ApiData get_item:verb_routesbystop params:params success:^(ApiData *item) {
		// TODO: validate that returned item IS ApiRoutesByStop
		if (success)
			success((ApiRoutesByStop *)item);
	} failure:^(NSError *error) {
		if (failure)
			failure(error);
		else
			NSLog(@"%s API call failed: %@", __FUNCTION__, [error localizedDescription]);
	}];
}
- (void)update_success:(void(^)(ApiRoutesByStop *item))success
			   failure:(void(^)(NSError *error))failure {
	[super internal_update_success:^(ApiData *item) {
		NSAssert(item == self, @"Update failed to return original item.");
		if (success)
			success(self);
	} failure:^(NSError *error) {
		if (failure)
			failure(error);
		else
			NSLog(@"%s API call failed: %@", __FUNCTION__, [error localizedDescription]);
	}];
}

- (BOOL)rzi_shouldImportValue:(id)value forKey:(NSString *)key {
	if ([key isEqualToString:key_mode]) {
		self.modes = [ApiRouteMode rzi_objectsFromArray:value];
		return NO;
	}
	return YES;
}

// NO '-initWithJSON:' as we call '+rzi_objectFromDictionary' directly

- (void)updateFromJSON:(NSDictionary *)json {
	self.stopID = [json objectForKey:key_stop_id];
	self.stopName = [json objectForKey:key_stop_name];
	
	NSArray *a_modes = [json objectForKey:key_mode];
	self.modes = [ApiRouteMode updateModes:self.modes withModes:a_modes];
}

- (NSString *)description {
	NSMutableString *result = [NSMutableString stringWithFormat:@"<%@ %p>", NSStringFromClass([self class]), self];
	[result appendFormat:@"\n\tstop = '%@', name = '%@'", self.stopID, self.stopName];
	if ([self.modes count]) {
		int index = 0;
		for (ApiRouteMode *mode in self.modes) {
			[result appendFormat:@"\n%2i: %@", index++, mode];
		}
	}
	return result;
}

@end


// ----------------------------------------------------------------------






