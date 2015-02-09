//
//  AFXMLParserResponseSerializerWithData.m
//  MBTA-RZImport
//
//  Created by Steve Caine on 02/06/15.
//
//	This code is distributed under the terms of the MIT license.
//
//	Copyright (c) 2015 Steve Caine.
//

#import "AFXMLParserResponseSerializerWithData.h"

#import "AppDelegate.h"
#import "ApiRequest.h"
#import "ServiceMBTA.h"
#import "ServiceMBTA_strings.h"

@implementation AFXMLParserResponseSerializerWithData

- (id)responseObjectForResponse:(NSHTTPURLResponse *)response
						   data:(NSData *)data
						  error:(NSError *__autoreleasing *)error
{
	id XMLObject = [super responseObjectForResponse:response data:data error:error];
	if (*error == nil) {
		// save raw response as file in our cached responses folder
		NSURL *url = [response URL];
		NSString *request = [url absoluteString];
		NSString *key = [ApiRequest keyForRequest:request];
		NSString *xmlName = nil;
		if ([key length])
			xmlName = [key stringByAppendingPathExtension:format_xml];
#if DEBUG_saveKeylessResponses
		else {
			// bug? save file w/ cur date/time for debugging
			// (but will also save do-not-cache files)
			NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
			formatter.dateFormat = @"dd MMM HH.mm.ss"; // no colons allowed in file names
			NSString *dateString = [formatter stringFromDate:[NSDate date]];
			NSLog(@"Failed to get key for %i-byte response at '%@'", (int)[data length], dateString);
			xmlName = [dateString stringByAppendingString:[NSString stringWithFormat:@".%@",format_xml]];
		}
#endif
		if ([xmlName length])
			(void) [AppDelegate cacheResponse:data asFile:xmlName];
	}

	// SPC 2015-01-30 write raw response to Xcode debugger console
#if DEBUG_logRawResponse
	NSString *text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	NSLog(@"\n\nraw response = '%@'\n\n", text);
#endif

	return XMLObject;
}
@end
