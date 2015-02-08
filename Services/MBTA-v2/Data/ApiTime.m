//
//  ApiTime.m
//  MBTA-RZImport
//
//  Created by Steve Caine on 12/26/14.
//
//	This code is distributed under the terms of the MIT license.
//
//	Copyright (c) 2014-2015 Steve Caine.
//

#import "ApiTime.h"

#import "ApiData_private.h"
#import "ServiceMBTA_strings.h"

#import "Debug_iOS.h"

// ----------------------------------------------------------------------

@interface ApiTime ()
@property (  copy, nonatomic) NSNumber *server_dt;
@end

// ----------------------------------------------------------------------

@implementation ApiTime

+ (void)get_success:(void(^)(ApiTime *data))success
			failure:(void(^)(NSError *error))failure {
	[ApiData get_item:verb_servertime params:nil success:^(ApiData *item) {
		if (item && [item isKindOfClass:[ApiTime class]]) {
			if (success)
				success((ApiTime *)item);
		}
		else {
			NSError *error = (item ? [ApiData error_wrong_subclass_ApiData] : [ApiData error_unknown]);
			if (failure)
				failure(error);
			else
				MyLog(@"%@ 'get' failed: %@", NSStringFromClass([self class]), [error localizedDescription]);
		}
	} failure:^(NSError *error) {
		if (failure)
			failure(error);
		else
			NSLog(@"%@ 'get' failed: %@", NSStringFromClass([self class]), [error localizedDescription]);
	}];
}

// no '-updateFromResponse:' because we never *update* a servertime object; it's always time-sensitive

- (NSDate *)time {
	NSDate *result = nil;
	if (self.server_dt != nil)
		result = [NSDate dateWithTimeIntervalSince1970:[self.server_dt integerValue]];
	return result;
}

- (NSString *)description {
	NSMutableString *result = [NSMutableString stringWithFormat:@"<%@ %p>", NSStringFromClass([self class]), self];
	[result appendFormat:@" time = %@", [self time]];
	return result;
}

@end

// ----------------------------------------------------------------------
