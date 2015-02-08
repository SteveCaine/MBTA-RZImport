//
//  AFJSONResponseSerializerWithData.m
//  MBTA-RZImport
//
//	save raw JSON data into text file in subfolder of app's Caches folder
//
//	Created by Greg Fiumara (@gfiumara) on 10/11/13 or later
//	first as comment in https://github.com/AFNetworking/AFNetworking/issues/1397#issuecomment-26139898
//	revised in his blog http://blog.gregfiumara.com/archives/239
//  Copyright (c) 2013 Greg Fiumara.
//
//	Modified by Steve Caine. (@SteveCaine on github.com)
//	Modifications copyright (c) 2014-2015 Steve Caine.
//

#import "AFJSONResponseSerializerWithData.h"

#import "AppDelegate.h"
#import "ApiRequest.h"
#import "ServiceMBTA_strings.h"

#import "Debug_iOS.h"

@implementation AFJSONResponseSerializerWithData

- (id)responseObjectForResponse:(NSURLResponse *)response
						   data:(NSData *)data
						  error:(NSError *__autoreleasing *)error
{
	id JSONObject = [super responseObjectForResponse:response data:data error:error];
	if (*error == nil) {
		// save raw response as file in our cached responses folder
		NSURL *url = [response URL];
		NSString *request = [url absoluteString];
		NSString *key = [ApiRequest keyForRequest:request];
		NSString *jsonName = nil;
		if ([key length])
			jsonName = [key stringByAppendingPathExtension:format_json];
#if DEBUG_saveKeylessResponses
		else {
			// bug? save file w/ cur date/time for debugging
			// (but will also save do-not-cache files)
			NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
			formatter.dateFormat = @"dd MMM HH.mm.ss"; // no colons allowed in file names
			NSString *dateString = [formatter stringFromDate:[NSDate date]];
			NSLog(@"Failed to get key for %i-byte response at '%@'", (int)[data length], dateString);
			jsonName = [dateString stringByAppendingString:[NSString stringWithFormat:@".%@",format_json]];
		}
#endif
		if ([jsonName length])
			(void) [AppDelegate cacheResponse:data asFile:jsonName];
	}
	
	return (JSONObject);
}

@end
