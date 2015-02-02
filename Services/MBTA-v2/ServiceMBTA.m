//
//  ServiceMBTA.m
//  MBTA-RZImport
//
//  Created by Steve Caine on 12/30/14.
//  Copyright (c) 2014 Steve Caine. All rights reserved.
//

#import "ServiceMBTA.h"

#import "ServiceMBTA_strings.h"

#define str_error_unknown		@"Service MBTA: Request failed, unknown error."
#define str_error_notApiData	@"Service MBTA: Request returned invalid data type(s)."
#define str_error_tooManyItems	@"Service MBTA: Request for single item returned multiple items."

NSString * const str_BaseURL = @"http://realtime.mbta.com/developer/api/v2/";

#warning TEST KEY FOR DEVELOPERS, DO NOT USE IN PRODUCTION CODE!
NSString * const str_key_API = @"wX9NwuHnZU2ToO7GmGR9uw";

// --------------------------------------------------
// see "ServiceMBTA_strings.h" for list of #define's for each verb
enum {
	e_servertime,
	e_routes,
	e_routesbystop,
	e_stopsbyroute,
	e_stopsbylocation,
	e_schedulebystop,
	e_schedulebyroute,
	e_schedulebytrip,
	e_predictionsbyroute,
	e_predictionsbystop,
	e_predictionsbytrip,
	e_vehiclesbyroute,
	e_vehiclesbytrip,
	e_alerts,
	e_alertsbyroute,
	e_alertsbystop,
	e_alertbyid,
	e_alertheaders,
	e_alertheadersbyroute,
	e_alertheadersbystop
};

static NSString *verbs[] = {
	@"servertime",			// 0
	@"routes",
	@"routesbystop",
	@"stopsbyroute",
	@"stopsbylocation"
	// rest disabled until we have code to exercise them
/** /
	,
	@"schedulebystop",		// 5
	@"schedulebyroute",
	@"schedulebytrip",
	@"predictionsbyroute",
	@"predictionsbystop",
	@"predictionsbytrip",	// 10
	@"vehiclesbyroute",
	@"vehiclesbytrip",
	@"alerts",
	@"alertsbyroute",
	@"alertsbystop",		// 15
	@"alertbyid",
	@"alertheaders",
	@"alertheadersbyroute",
	@"alertheadersbystop"
/ **/
};
static NSUInteger num_verbs = sizeof(verbs)/sizeof(verbs[0]);

static NSString *json_replys[] = {
	@"",
	@"",
	@"",
#if CONFIG_stops_update_route
	@"direction",
#else
	@"",
#endif
	@""
};
static NSUInteger num_json_replys = sizeof(json_replys)/sizeof(json_replys[0]);

static NSString *xml_replys[] = {
	@"server_time",
	@"route_list",
	@"route_list",
#if CONFIG_stops_update_route
	@"stop_list.direction",
#else
	@"stop_list",
#endif
	@"stop_list"
};
static NSUInteger num_xml_replys = sizeof(xml_replys)/sizeof(xml_replys[0]);
// --------------------------------------------------

@implementation ServiceMBTA

+ (NSString *)str_BaseURL {
	return str_BaseURL;
}

+ (NSString *)str_key_API {
	return str_key_API;
}

+ (NSUInteger)verbCount {
	// must be a 1-to-1-to-1 mapping of these three lists
	// as each verb must have both a json_reply and an xml_reply
	NSAssert((num_verbs == num_json_replys) && (num_json_replys == num_xml_replys), @"verb-reply count mismatch");
	return num_verbs;
}

+ (NSString *)verbForIndex:(NSUInteger)index {
	if (index < num_verbs)
		return verbs[index];
	return nil;
}

+ (NSUInteger)indexForVerb:(NSString *)verb {
	static NSArray *a_verbs;
	if (a_verbs == nil)
		a_verbs = [NSArray arrayWithObjects:verbs count:num_verbs];
	
	return [a_verbs indexOfObject:verb];
}

// ----------------------------------------------------------------------

+ (NSError *)error_unknown {
	return [[NSError alloc] initWithDomain:MBTA_APIs_ErrorDomain
									  code:-1
								  userInfo:@{ NSLocalizedDescriptionKey : str_error_unknown }];
}

+ (NSError *)error_notApiData {
	return [[NSError alloc] initWithDomain:MBTA_APIs_ErrorDomain
									  code:-2
								  userInfo:@{ NSLocalizedDescriptionKey : str_error_notApiData }];
}

+ (NSError *)error_tooManyItems {
	return [[NSError alloc] initWithDomain:MBTA_APIs_ErrorDomain
									  code:-3
								  userInfo:@{ NSLocalizedDescriptionKey : str_error_tooManyItems }];
}

// --------------------------------------------------

@end
