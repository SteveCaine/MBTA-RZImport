//
//  ApiXMLParserDelegate.h
//  MBTA-RZImport
//
//
//
//  Created by Steve Caine on 01/31/15.
//
//	This code is distributed under the terms of the MIT license.
//
//	Copyright (c) 2015 Steve Caine.
//

#import <Foundation/Foundation.h>

// text content of an XML element is stored
// as a single concatenated string with this key
#define key_XMLReader_text	@"text"

@interface ApiXMLParserDelegate : NSObject <NSXMLParserDelegate>

// if YES, child elements of the same type are *always* stored
// in an array on parent (keyed to the child's elementName)
// if NO, an array is only used when there are multiple children of same type,
// while a single child element is stored directly on parent with that key
@property (assign, nonatomic) BOOL putChildrenInArrays; // default is YES

- (NSDictionary *)data;

- (NSDictionary *)onlyChild;

- (NSError *)error;

- (void)reset; // clear current data, ready to parse fresh tree of XML

@end
