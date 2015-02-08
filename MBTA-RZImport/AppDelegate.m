//
//	AppDelegate.m
//	MBTA-RZImport
//
//	Created by Steve Caine on 01/10/15.
//
//	This code is distributed under the terms of the MIT license.
//
//	Copyright (c) 2015 Steve Caine.
//

#import "AppDelegate.h"

#import "ServiceMBTA_strings.h"

#import "Debug_iOS.h"

// ----------------------------------------------------------------------

@interface AppDelegate ()

@end

// ----------------------------------------------------------------------
#pragma mark -
// ----------------------------------------------------------------------

@implementation AppDelegate

// ----------------------------------------------------------------------
#pragma mark - public
// ----------------------------------------------------------------------

+ (NSString *)documentsDirectory {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	return [paths firstObject];
}

// ----------------------------------------------------------------------

+ (NSString *)cacheDirectory {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	return [paths firstObject];
}

// ----------------------------------------------------------------------

+ (NSString *)responsesDirectory {
	NSString *result = nil;
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	NSString *dir = [paths firstObject];
	if ([dir length])
		result = [dir stringByAppendingPathComponent:cached_responses_directory];
	return result;
}

// ----------------------------------------------------------------------
// will replace existing files
+ (BOOL)cacheResponse:(NSData *)data asFile:(NSString *)name {
	BOOL result = NO;
	if ([name length]) {
		NSString *responsesDir = [self responsesDirectory];
		if ([responsesDir length]) {
			NSString *responsePath = [responsesDir stringByAppendingPathComponent:name];
			BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:responsePath];
			NSError *error = nil;
			if (exists) {
				BOOL cleared = [[NSFileManager defaultManager] removeItemAtPath:responsePath error:&error];
				if (!cleared)
					NSLog(@" error clearing older response file '%@' - %@", name, [error localizedDescription]);
			}
			if (error == nil) {
				result = [[NSFileManager defaultManager] createFileAtPath:responsePath contents:data attributes:nil];
				if (!result)
					NSLog(@" error saving response as file '%@'", name);
			}
		}
	}
	return result;
}

// ----------------------------------------------------------------------
// may be JSON or XML
+ (NSString *)responseFileForKey:(NSString *)key {
	NSString *result = nil;

	NSString *jsonFile = [self jsonFileForKey:key];
	NSString  *xmlFile = [self  xmlFileForKey:key];
	
	if ([jsonFile length] == 0)
		result = xmlFile;
	else if ([xmlFile length] == 0)
		result = jsonFile;
	else {
		// which is the earliest file? (missing file/error returns 0.0)
		double jsonAge = [self ageOfFile:jsonFile error:nil];
		double  xmlAge = [self ageOfFile:xmlFile  error:nil];
		
		if (jsonAge > 0.0 && xmlAge > 0.0) { // else both are bogus
			if (jsonAge < xmlAge)
				result = jsonFile;
			else
				result = xmlFile;
		}
	}
	return result;
}

// ----------------------------------------------------------------------
+ (NSString *)jsonFileForKey:(NSString *)key {
	NSString *result = nil;
	
	NSString *dataDirectory = [[self cacheDirectory] stringByAppendingPathComponent:cached_responses_directory];
	NSString *name = [key stringByAppendingPathExtension:format_json];
	NSString *path = [dataDirectory stringByAppendingPathComponent:name];
	if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
		result = path;
	}
	return result;
}
// ----------------------------------------------------------------------
+ (NSString *)xmlFileForKey:(NSString *)key {
	NSString *result = nil;
	
	NSString *dataDirectory = [[self cacheDirectory] stringByAppendingPathComponent:cached_responses_directory];
	NSString *name = [key stringByAppendingPathExtension:format_xml];
	NSString *path = [dataDirectory stringByAppendingPathComponent:name];
	if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
		result = path;
	}
	return result;
}

// ----------------------------------------------------------------------
// return 0 if fileNotFound or error, caller should check if error is NSFileReadNoSuchFileError
+ (double)ageOfFile:(NSString *)filePath error:(NSError **)error {
	double result = 0.0;
	NSDictionary *attribs = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:error];
	if (attribs && !*error) {
		NSDate *date = [attribs objectForKey:NSFileModificationDate];
		result = -[date timeIntervalSinceNow];
	}
	return result;
}

// ----------------------------------------------------------------------
#pragma mark - overrides
// ----------------------------------------------------------------------

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
#ifdef DEBUG
	MyLog(@"*** %@ ***", str_AppName());
	NSDate *now = [NSDate date];
	MyLog(@"launched at %@ on %@", str_logTime(now), str_logDate(now));
	MyLog(@"%@", str_device_OS_UDID());
	MyLog(@"\napp path = '%@'", str_AppPath());
	//	MyLog(@" doc path = '%@'", str_DocumentsPath());
	MyLog(@"\ncached responses path = '%@'", [AppDelegate responsesDirectory]);
	MyLog(@"\n%s", __FUNCTION__);
	
	if(getenv( "NSDebugEnabled"))
		MyLog(@"NSDebugEnabled == YES");
	if(getenv( "NSZombieEnabled"))
		MyLog(@"NSZombieEnabled == YES");
	if(getenv( "NSAutoreleaseFreedObjectCheckEnabled"))
		MyLog(@"NSAutoreleaseFreedObjectCheckEnabled == YES");
#endif
	// Override point for customization after application launch.
	
	// if cached responses folder doesn't already exist, create it
	NSString *responsesDir = [AppDelegate responsesDirectory];
	if ([responsesDir length]) {
		if (![[NSFileManager defaultManager] fileExistsAtPath:responsesDir]) {
			NSError *error = nil;
			if ([[NSFileManager defaultManager] createDirectoryAtPath:responsesDir
										  withIntermediateDirectories:NO
														   attributes:nil
																error:&error]) {
			}
			else
				NSLog(@"Error creating cached responses directory: %@", [error localizedDescription]);
		}
	}
	else
		NSLog(@"No path for response files cache.");
	
	return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application {
	// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
	// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
	// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
	// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
	// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
