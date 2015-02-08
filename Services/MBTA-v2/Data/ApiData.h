//
//  ApiData.h
//  MBTA-RZImport
//
//  Created by Steve Caine on 12/31/14.
//  Copyright (c) 2014 Steve Caine. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NSObject+RZImport.h"
#import "RZImportable.h"

#define ApiData_ErrorDomain		@"ApiData_ErrorDomain"

// ----------------------------------------------------------------------

@interface ApiData : NSObject <RZImportable>

+ (NSError *)error_unknown;
+ (NSError *)error_response_import_failed;
+ (NSError *)error_wrong_subclass_ApiData;
+ (NSError *)error_missing_implementation;

@end

// ----------------------------------------------------------------------
