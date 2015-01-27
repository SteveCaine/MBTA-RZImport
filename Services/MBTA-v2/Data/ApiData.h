//
//  ApiData.h
//  MBTA-APIs
//
//  Created by Steve Caine on 12/31/14.
//  Copyright (c) 2014 Steve Caine. All rights reserved.
//

#import <Foundation/Foundation.h>

#if CONFIG_USE_RZImport
	#import "NSObject+RZImport.h"
	#import "RZImportable.h"
#endif

#define ApiData_ErrorDomain		@"ApiData_ErrorDomain"

// ----------------------------------------------------------------------

@interface ApiData : NSObject	PROTOCOL_RZImportable

+ (NSError *)error_unknown;
+ (NSError *)error_JSON_import_failed;
+ (NSError *)error_missing_implementation;

@end

// ----------------------------------------------------------------------