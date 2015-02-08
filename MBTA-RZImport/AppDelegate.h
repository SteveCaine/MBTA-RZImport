//
//	AppDelegate.h
//	MBTA-RZImport
//
//	Created by Steve Caine on 01/10/15.
//
//	This code is distributed under the terms of the MIT license.
//
//	Copyright (c) 2015 Steve Caine.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

+ (NSString*) documentsDirectory;

+ (NSString*) cacheDirectory;

+ (NSString*) responsesDirectory;

+ (BOOL)cacheResponse:(NSData *)data asFile:(NSString *)name; // withExtension:(NSString *)ext;

// may be JSON or XML
+ (NSString *)responseFileForKey:(NSString *)key;

+ (NSString *)jsonFileForKey:(NSString *)key;
+ (NSString *)xmlFileForKey:(NSString *)key;

+ (double) ageOfFile: (NSString*) filePath error: (NSError**) error;

@end
