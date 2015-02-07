//
//	AppDelegate.h
//	MBTA-RZImport
//
//	Created by Steve Caine on 01/10/15.
//	Copyright (c) 2015 Steve Caine. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

+ (NSString*) documentsDirectory;

+ (NSString*) cacheDirectory;

+ (NSString*) responsesDirectory;

+ (BOOL)cacheResponse:(NSData *)data asFile:(NSString *)name; // withExtension:(NSString *)ext;

// may be JSON or XML
+ (NSString *)fileForKey:(NSString *)key;

+ (NSString *)jsonFileForKey:(NSString *)key;
+ (NSString *)xmlFileForKey:(NSString *)key;

+ (double) ageOfFile: (NSString*) filePath error: (NSError**) error;

@end
