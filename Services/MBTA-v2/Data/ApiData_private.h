//
//  ApiData_private.h
//  MBTA-RZImport
//
//  Created by Steve Caine on 01/10/15.
//  Copyright (c) 2015 Steve Caine. All rights reserved.
//

#import "ApiData.h"

#import "ApiRoutes.h"

// --------------------------------------------------

@interface ApiData ()

- (instancetype)initWithJSON:(NSDictionary *)json;

@end

// --------------------------------------------------
#if CONFIG_USE_RZImport
// --------------------------------------------------

@interface ApiRouteDirections : ApiData
@property (strong, nonatomic) NSArray *directions;
@end

// --------------------------------------------------
#if 0
@interface ApiRoute ()
@property (strong, nonatomic) ApiRouteDirections *route_directions;
- (void)setDirections:(NSArray *)directions;
@end
#endif
// --------------------------------------------------
#endif
// --------------------------------------------------

// --------------------------------------------------
//#pragma mark -
// --------------------------------------------------
