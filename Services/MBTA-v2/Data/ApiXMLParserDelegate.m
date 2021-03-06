//
//  ApiXMLParserDelegate.m
//  MBTA-RZImport
//
//	Adapted from the open-source "XML-to-NSDictionary" library
//	by Blake Watters et al (https://github.com/blakewatters/XML-to-NSDictionary).
//
//  Created by Steve Caine on 01/31/15.
//
//	This code is distributed under the terms of the MIT license.
//
//	Copyright (c) 2015 Steve Caine.
//

#import "ApiXMLParserDelegate.h"

#import "Debug_iOS.h"

// ----------------------------------------------------------------------

@interface ApiXMLParserDelegate ()
// each level in this 'stack' contains *latest* element added to that level of our growing tree
@property (strong, nonatomic) NSMutableArray	*dictionaryStack;
@property (strong, nonatomic) NSMutableString	*textInProgress;
@property (strong, nonatomic) NSError			*internal_error;
@end

// ----------------------------------------------------------------------
#pragma mark -
// ----------------------------------------------------------------------

@implementation ApiXMLParserDelegate

// ----------------------------------------------------------------------
#pragma mark - public
// ----------------------------------------------------------------------

- (NSDictionary *)data {
	return [self.dictionaryStack firstObject]; // may be nil
}

- (NSDictionary *)onlyChild {
	NSDictionary *result = nil;
	// XML responses from MBTA v2 API appear to always have this structure:
	// the root is a dictionary with a single array item
	// and all child elements in the entire tree
	// are stored in a single array item on their parent
	NSDictionary *root = [self.dictionaryStack firstObject]; // may be nil
	NSArray *allKeys = [root allKeys];
	NSString *key = [allKeys firstObject];
	if ([key length]) {
		NSArray *array = [root objectForKey:key];
		NSAssert([array isKindOfClass:[NSArray class]], @"Child nodes should always be arrays.");
		result = [array firstObject];
	}
	return result;
}

- (NSError *)error {
	return self.internal_error;
}

// ----------------------------------------------------------------------
#pragma mark - private
// ----------------------------------------------------------------------

- (instancetype)init {
	self = [super init];
	if (self) {
		_putChildrenInArrays = YES;
		_dictionaryStack = [NSMutableArray arrayWithObject:[NSMutableDictionary dictionary]];
		_textInProgress = [[NSMutableString alloc] init];
	//	_internal_error remains nil
	}
	return self;
}

- (void)reset {
	self.dictionaryStack = [NSMutableArray arrayWithObject:[NSMutableDictionary dictionary]];
	self.textInProgress = [[NSMutableString alloc] init];
	self.internal_error = nil;
}

// ----------------------------------------------------------------------

- (void) parser:(NSXMLParser *)parser
didStartElement:(NSString *)elementName
   namespaceURI:(NSString *)namespaceURI
  qualifiedName:(NSString *)qName
	 attributes:(NSDictionary *)attributeDict {
	
	// dictionary for current level in stack
	NSMutableDictionary *parent = [self.dictionaryStack lastObject];
//	MyLog(@"\n\n => %@", parent);
	
	// create dictionary for this new element
	NSMutableDictionary *child = [NSMutableDictionary dictionary];
	[child addEntriesFromDictionary:attributeDict];
	
	id existingValue = [parent objectForKey:elementName];
	if (existingValue) {
		// see comment on this property in header file
		if (self.putChildrenInArrays) {
			NSAssert([existingValue isKindOfClass:[NSMutableArray class]], @"_putChildrenInArrays logic error.");
			// add this new child to the existing array of children of this type
			NSMutableArray *array = (NSMutableArray *)existingValue;
			[array addObject:child];
		}
		else {
			// already an array? again, just add child to it
			if ([existingValue isKindOfClass:[NSMutableArray class]]) {
				NSMutableArray *array = (NSMutableArray *)existingValue;
				[array addObject:child];
			}
			else {
				// not an array? then put it and this child in new array,
				// and set that array on parent keyed to elementName
				NSMutableArray *array = [NSMutableArray array];
				[array addObject:existingValue];
				[array addObject:child];
				[parent setObject:array forKey:elementName];
			}
		}
	}
	else {
		if (self.putChildrenInArrays) {
			// always store children in arrays
			NSMutableArray *array = [NSMutableArray array];
			[array addObject:child];
			[parent setObject:array forKey:elementName];
		}
		else {
			// store single child of this type directly on parent keyed to elementName
			[parent setObject:child forKey:elementName];
		}
	}
	// update stack (latest child added to this level of the growing tree)
	[self.dictionaryStack addObject:child];

//	MyLog(@"==> %@", parent);
}

// ----------------------------------------------------------------------

- (void) parser:(NSXMLParser *)parser
  didEndElement:(NSString *)elementName
   namespaceURI:(NSString *)namespaceURI
  qualifiedName:(NSString *)qName {
	
	// update parent with any text content from XML
	NSMutableDictionary *parent = [self.dictionaryStack lastObject];
//	MyLog(@" <= %@", parent);
	
	if ([self.textInProgress length]) {
		// trim ends of whitespace (including newlines)
		NSString *text = [self.textInProgress stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		// add text as child object with key 'text'
		[parent setObject:text forKey:key_XMLReader_text];
		// reset text buffer
		[self.textInProgress setString:@""];
	}
	
	// pop this level off the stack
	[self.dictionaryStack removeLastObject];
//	MyLog(@"<== %@\n\n", parent);
}

// ----------------------------------------------------------------------

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
	[self.textInProgress appendString:string];
}

// ----------------------------------------------------------------------

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
	self.internal_error = parseError;
}

// ----------------------------------------------------------------------

@end
