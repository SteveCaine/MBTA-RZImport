//
//  ApiXMLParserDelegate.m
//  MBTA-RZImport
//
//	Adapted from the open-source "XML-to-NSDictionary" library
//	by Blake Watters et al (https://github.com/blakewatters/XML-to-NSDictionary).
//
//  Created by Steve Caine on 01/31/15.
//  Copyright (c) 2015 Steve Caine. All rights reserved.
//

#import "ApiXMLParserDelegate.h"

#import "Debug_iOS.h"

// ----------------------------------------------------------------------

@interface ApiXMLParserDelegate ()
// each level in this 'stack' contains *last* element added to that level of our growing tree
@property (strong, nonatomic) NSMutableArray *dictionaryStack;
@property (strong, nonatomic) NSMutableString *textInProgress;
@property (strong, nonatomic) NSError *error;

@property (strong, nonatomic) NSString *prefix;
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

- (NSError *)error {
	return self.error;
}

// ----------------------------------------------------------------------
#pragma mark - private
// ----------------------------------------------------------------------

- (instancetype)init {
	self = [super init];
	if (self) {
		_dictionaryStack = [NSMutableArray arrayWithObject:[NSMutableDictionary dictionary]];
		_textInProgress = [[NSMutableString alloc] init];
	//	_error remains nil
	}
	return self;
}

- (void)reset {
	self.dictionaryStack = [NSMutableArray arrayWithObject:[NSMutableDictionary dictionary]];
	self.textInProgress = [[NSMutableString alloc] init];
	self.error = nil;
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
	
	// we strip 1st element from keypaths to create JSON-like response trees
	if ([self.prefix length] == 0)
		self.prefix = [NSString stringWithFormat:@"%@.", elementName];
	
	// create dictionary for this new element
	NSMutableDictionary *child = [NSMutableDictionary dictionary];
	[child addEntriesFromDictionary:attributeDict];
	
	// if parent already has child(ren) with this 'elementName'
	// we'll need an array to hold them all
	id existingValue = [parent objectForKey:elementName];
	if (existingValue) {
		
		NSMutableArray *array = nil;
		
		if ([existingValue isKindOfClass:[NSMutableArray class]]) {
			// array already exists, use it
			array = (NSMutableArray *)existingValue;
		}
		else {
			// no array yet, so create one
			array = [NSMutableArray array];
			// add the (first) child to this new array
			[array addObject:existingValue];
			// and replace it in the parent with the array that now contains it
			[parent setObject:array forKey:elementName];
			// so what was a single object is now an array *containing* objects
		}
		// now the new(est) child is added to the array
		[array addObject:child];
	}
	else {
		// no existing value for this key, so add new element directly to parent
		[parent setObject:child forKey:elementName];
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
	self.error = parseError;
}

// ----------------------------------------------------------------------

@end
