//
//  ApiRoute.m
//  RestKitTester
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

#if CONFIG_USE_RZImport
static ApiRoutes *sRoutes;
#endif

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
	NSUInteger index = 0;
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
#if CONFIG_USE_RZImport

@implementation ApiRouteDirections
@end

#endif
// --------------------------------------------------
#pragma mark -
// --------------------------------------------------

@implementation ApiRouteDirection

#if CONFIG_USE_RZImport
+ (NSDictionary *)rzi_customMappings {
	return @{
			 @"direction_id"   : @"ID",
			 @"direction_name" : @"name",
			 };
}
- (BOOL)rzi_shouldImportValue:(id)value forKey:(NSString *)key {
	if ([key isEqualToString:key_stop]) {
		self.stops = [ApiStop rzi_objectsFromArray:value];
		return NO;
	}
	return YES;
}
#endif

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

@implementation ApiRoute

#if CONFIG_USE_RZImport
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
#endif

- (void)addStops_success:(void(^)(ApiRoute *route))success
				 failure:(void(^)(NSError *error))failure {
	NSDictionary *params = @{ param_route : self.ID };
	
	[ApiData get_array:verb_stopsbyroute params:params success:^(NSArray *array) {
		if (success) {
			// TODO: validate that returned items ARE ApiRouteDirections
			self.directions = array;
			success(self);
		}
	} failure:^(NSError *error) {
		NSLog(@"%s API call failed: %@", __FUNCTION__, [error localizedDescription]);
	}];
}

#if 0 //CONFIG_USE_RZImport
- (NSArray *)directions {
	return nil;
}
- (void)setDirections:(NSArray *)directions {
}
#endif

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
//+ (ApiRouteMode *)mode_for_dict:(NSDictionary *)dict;
- (BOOL)isOurData:(NSDictionary *)dict;
@end

@implementation ApiRouteMode

#if CONFIG_USE_RZImport
#if !CONFIG_USE_RZImport_update
+ (id)rzi_existingObjectForDict:(NSDictionary *)dict {
//	ApiRoutes *sRoutes = [ApiRoutes routes];
	if (sRoutes) {
		NSString *str_route_type = [dict objectForKey:key_route_type];
		NSString *mode_name = [dict objectForKey:key_mode_name];
		
		if ([str_route_type length] && [mode_name length]) {
			NSNumber *route_type = [NSNumber numberWithInteger:[str_route_type integerValue]];
			for (ApiRouteMode *mode in sRoutes.modes) {
				if ([route_type compare:mode.type] == NSOrderedSame) {
					if ([mode_name compare:mode.name] == NSOrderedSame) {
						return mode;
					}
				}
			}
		}
	}
	return nil;
}
#endif
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
	NSLog(@"%s %p returns %s", __FUNCTION__, dict, (result ? "YES" : "NO"));
	return result;
}
#endif

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

#if DEBUG_static_routes // for testing only
+ (ApiRoutes *)routes {
	return sRoutes;
}
#endif

+ (void)initialize {
	NSLog(@"%s called.", __FUNCTION__);
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

- (void)update_success:(void(^)(ApiData *item))success
			   failure:(void(^)(NSError *error))failure {
	
}

//static ApiRoutes *sRoutes;
//#if CONFIG_USE_RZImport
//+ (id)rzi_existingObjectForDict:(NSDictionary *)dict {
//	return sRoutes;
//}
//#endif

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
#if !DEBUG_disableNewCode
		NSArray *a_modes = [json objectForKey:key_mode];
		_modes = [ApiRouteMode rzi_objectsFromArray:a_modes];

#if CONFIG_USE_RZImport_update
		[self post_init];
#else
		_all_routes = [NSMutableArray array];
		_routes_by_mode_name = [NSMutableDictionary dictionaryWithCapacity:num_strs_RouteMode-1];
		
		for (ApiRouteMode *mode in _modes) {
			// set the 'mode' enum on every route this mode contains
			RouteMode route_mode = mode_for_name(mode.name);
			for (ApiRoute *route in mode.routes)
				route.mode = route_mode;
			
			[_all_routes addObjectsFromArray:mode.routes];
			
			// in the case of Subway, this combines routes from both subway modes
			NSMutableArray *mode_routes = [_routes_by_mode_name objectForKey:mode.name];
			if (mode_routes == nil) {
				mode_routes = [NSMutableArray arrayWithArray:mode.routes];
				[_routes_by_mode_name setObject:mode_routes forKey:mode.name];
			}
			[mode_routes addObjectsFromArray:mode.routes];
			
		}
#endif
		
#endif
#if CONFIG_USE_RZImport
		sRoutes = self;
#endif
	}
	return self;
}

#if CONFIG_USE_RZImport_update
- (void)updateFromJSON:(NSDictionary *)json {
	NSArray *a_modes = [json objectForKey:key_mode];
	NSMutableArray *updated_modes = [NSMutableArray arrayWithCapacity:[self.modes count]];
	for (ApiRouteMode *mode in self.modes) {
		for (NSDictionary *d_mode in a_modes) {
			if ([mode isOurData:d_mode]) {
				[mode rzi_importValuesFromDict:d_mode];
				[updated_modes addObject:mode];
				break;
			}
		}
	}
	self.modes = updated_modes; // any modes *not* in json are discarded
	[self post_init];
}
#endif

- (void)post_init {
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

+ (void)get4stopID:(NSString *)stopID
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






