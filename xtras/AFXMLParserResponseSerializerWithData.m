//
//  AFXMLParserResponseSerializerWithData.m
//  MBTA-RZImport
//
//  Created by Steve Caine on 02/06/15.
//  Copyright (c) 2015 Steve Caine. All rights reserved.
//

#import "AFXMLParserResponseSerializerWithData.h"

#import "AppDelegate.h"
#import "ApiRequest.h"
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
		NSString *xmlName = [key stringByAppendingPathExtension:format_xml];
#ifdef DEBUG
		if ([xmlName length] == 0) { // bug? save file w/ cur date/time for debugging
			NSLog(@"Failed to get key for %i-byte response '%@'", (int)[data length], response);
			NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
			formatter.dateFormat = @"dd MMM HH.mm.ss"; // no colons allowed in file names
			NSString *dateString = [formatter stringFromDate:[NSDate date]];
			xmlName = [dateString stringByAppendingPathComponent:format_xml];
		}
#endif
		(void) [AppDelegate cacheResponse:data asFile:xmlName];
	}
	return XMLObject;
}
@end
