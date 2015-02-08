//
//  ApiRequest.m
//  MBTA-RZImport
//
//  Created by Steve Caine on 01/10/15.
//  Copyright (c) 2015 Steve Caine. All rights reserved.
//

#import "ApiRequest.h"
#import "ApiRequest_private.h"

#import "ApiXMLParserDelegate.h"
#import "AppDelegate.h"
#import "ServiceMBTA.h"
#import "ServiceMBTA_strings.h"

//#import "Debug_iOS.h"

// ----------------------------------------------------------------------
// some unchanging parts of v2 API request URLs
// used to sanity-check URL strings
#define str_http  	@"http://"
#define str_api_v2	@"/developer/api/v2"
#define str_api_key	@"?api_key="
#define str_format	@"&format="

// ----------------------------------------------------------------------

@implementation ApiRequest

// parse request URL string into key for naming cached JSON/XML files
//	so for request = "http://realtime.mbta.com/developer/api/v2/<verb>?apiKey=<key>&<p1>=<v1>...&<pN>=<vN>&format=<format>"
//			   key = "<verb>&<p1>=<v1>...&<pN>=<vN>"

#warning TODO use custom NSDictionary subclass to build request strings so parameters match order they were added in
// else this logic will fail for some requests, as order of parameters will vary based on which parameters are included

+ (NSString *)keyForRequest:(NSString *)request {
	NSString *result = nil;
	if ([request length]) {
		// TODO: handle case where '&format=' param is missing?
		// sanity check - look for unvarying parts of every request
		if (
			NSNotFound == [request rangeOfString:	str_http  ].location  ||
			NSNotFound == [request rangeOfString:	str_api_v2].location  ||
			NSNotFound == [request rangeOfString:	str_api_key].location ||
			NSNotFound == [request rangeOfString:	str_format].location
			) {
			NSLog(@"%s FAILED to parse '%@'", __FUNCTION__, request);
			NSAssert(false, @"Invalid MBTA-v2 request URL.");
		}
		else {
			NSArray *parts1 = [request componentsSeparatedByString:@"&"];
			if ([parts1 count] > 1) {
				// parts1 = { "http://<ip>/developer/api/v2/<verb>?apiKey=<key>", "<p1>=<v1>" ... "<pN>=<vN>", "format=<format>" }
				
				// parts1[0] = "http://<ip>/developer/api/v2/<verb>?apiKey=<key>"
				NSArray *parts2 = [parts1[0] componentsSeparatedByString:@"?"];
				if ([parts2 count] > 1) {
					// parts2 = { "http://<ip>/developer/api/v2/<verb>", "apiKey=<key>" }
					NSArray *parts3 = [parts2[0] componentsSeparatedByString:@"/"];
					if ([parts3 count] == 7) {
						// verb is last part3 element
						NSString *verb = parts3[6];
						
						// some requests are never cached, ex. servertime, stopsbylocation
						if ([ServiceMBTA isResponseCachedForVerb:verb]) {
							// params (if any) are the *middle* elements in -parts1- array (excluding first and last)
							NSMutableString *str = [NSMutableString stringWithString:verb];
							for (int i = 1; i < [parts1 count] - 1; ++i) {
								[str appendFormat:@"&%@", parts1[i]];
							}
							result = [NSString stringWithString:str];
						}
					}
				}
			}
		}
	}
	return result;
}

// ----------------------------------------------------------------------

+ (id)cachedResponseForKey:(NSString *)key staleAge:(double)staleAge {
	id result = nil;
	
	if ([key length] && staleAge > 0.0) {
		
		// may be JSON or XML
		NSString *path = [AppDelegate responseFileForKey:key];
		if ([path length]) {
			NSString *name = [path lastPathComponent];
			NSError *error = nil;
			double age = [AppDelegate ageOfFile:path error:&error];
			if (error && [error code] != NSFileReadNoSuchFileError) {
				NSLog(@"Error checking age of cached response file '%@': %@", name, [error localizedDescription]);
			}
			// '-ageOfFile:' returns 0.0 if fileNotFound
			else if (age > 0.0 && age < staleAge) {
				NSData *data = [NSData dataWithContentsOfFile:path];
				if ([data length]) {
					NSString *ext = [path pathExtension];
					if ([ext compare:format_json options:NSCaseInsensitiveSearch] == NSOrderedSame) {
						NSError *error = nil;
						id jsonData = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
						if (error) {
							NSLog(@"Failed to read cached JSON file '%@': %@", name, [error localizedDescription]);
						}
						else
							result = jsonData;
					}
					else if ([ext compare:format_xml options:NSCaseInsensitiveSearch] == NSOrderedSame) {
						NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
						ApiXMLParserDelegate *delegate = [[ApiXMLParserDelegate alloc] init];
						parser.delegate = delegate;
						[parser parse];
						NSError *error = [delegate error];
						if (error) {
							NSLog(@"Failed to read cached XML file '%@': %@", name, [error localizedDescription]);
						}
						else {
							result = [delegate onlyChild];
						}
					}
				}
			}
		}
	}
	return result;
}

// ----------------------------------------------------------------------

- (void)refresh_success:(void(^)(ApiRequest *request))success
				failure:(void(^)(NSError *error))failure {
	NSAssert(false, @"Abstract class 'ApiRequest' should never be instantiated.");
}

// ----------------------------------------------------------------------

- (ApiData *)response {
	return self.data;
}

// ----------------------------------------------------------------------

- (NSString *)key {
	NSAssert(false, @"Abstract class 'ApiRequest' should never be instantiated.");
	return nil;
}

// ----------------------------------------------------------------------

- (double)staleAge {
	NSAssert(false, @"Abstract class 'ApiRequest' should never be instantiated.");
	return 0.0;
}

@end
