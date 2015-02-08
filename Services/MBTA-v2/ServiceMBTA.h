//
//  ServiceMBTA.h
//  MBTA-RZImport
//
//	Partial implementation of MBTA v2 API to demonstrate
//	the use of RZImport from RaizLabs (https://github.com/Raizlabs/RZImport)
//
//	Supports these five calls:
//	http://realtime.mbta.com/developer/api/v2/servertime?api_key=<myKey>&format=[json/xml]
//	http://realtime.mbta.com/developer/api/v2/routes?api_key=<myKey>&format=[json/xml]
//	http://realtime.mbta.com/developer/api/v2/routesbystop?stop=<stop_id>&api_key=<myKey>&format=[json/xml]
//	http://realtime.mbta.com/developer/api/v2/stopsbyroute?route=<route_id>&api_key=<myKey>&format=[json/xml]
//	http://realtime.mbta.com/developer/api/v2/stopsbylocation?lat=<latitude>&lon=<longitude>&api_key=<myKey>&format=[json/xml]
//
//  Created by Steve Caine on 12/30/14.
//
//	This code is distributed under the terms of the MIT license.
//
//	Copyright (c) 2014-2015 Steve Caine.
//

#import <Foundation/Foundation.h>

#define MBTA_RZImport_ErrorDomain	@"ServiceMBTA-RZImport ErrorDomain"

// ----------------------------------------------------------------------
@interface ServiceMBTA : NSObject
// ----------------------------------------------------------------------

+ (NSString *)str_BaseURL;
+ (NSString *)str_key_API;

+ (NSUInteger)verbCount;
+ (NSString *)verbForIndex:(NSUInteger)index;
+ (NSUInteger)indexForVerb:(NSString *)verb;

+ (BOOL)isResponseCachedForVerb:(NSString *)verb;

// ----------------------------------------------------------------------

+ (NSError *)error_unknown;
+ (NSError *)error_notApiData;

// ----------------------------------------------------------------------
@end
// ----------------------------------------------------------------------
