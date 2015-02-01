//
//  ApiXMLParserDelegate.h
//  MBTA-RZImport
//
//  Created by Steve Caine on 01/31/15.
//  Copyright (c) 2015 Steve Caine. All rights reserved.
//

#import <Foundation/Foundation.h>

// text content of an XML element stored as a single concatenated string
#define key_XMLReader_text	@"text"

@interface ApiXMLParserDelegate : NSObject <NSXMLParserDelegate>

- (NSDictionary *)data;

- (NSError *)error;

- (void)reset; // clear current data, ready to parse fresh tree of XML

@end
