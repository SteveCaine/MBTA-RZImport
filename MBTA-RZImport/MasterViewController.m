//
//	MasterViewController.m
//	MBTA-RZImport
//
//	Created by Steve Caine on 01/10/15.
//	Copyright (c) 2015 Steve Caine. All rights reserved.
//

#import "MasterViewController.h"
#import "DetailViewController.h"

#import "ServiceMBTA.h"
#import "ServiceMBTA_strings.h"

#import "ApiRoutes.h"
#import "ApiStops.h"
#import "ApiTime.h"

#import "ApiRoutesRequests.h"
#import "ApiStopsRequests.h"
#import "ApiTimeRequest.h"

#import "EXTScope.h"

#import "Debug_iOS.h"

// ----------------------------------------------------------------------

static NSString *str_sequeID_DetailViewController = @"showDetail";
//static NSString *str_sequeID_DetailViewController = @"showResponse";

static NSString * const		  test_routeID   = @"71";
static NSString * const		  test_stopID    = @"2021";
static CLLocationCoordinate2D test_location  = { +42.373600, -71.118962 };

static NSUInteger	sSection_gets	  = 0;
static NSUInteger	sSection_requests = 1;

// ----------------------------------------------------------------------
#pragma mark -
// ----------------------------------------------------------------------

@interface MasterViewController ()
@property (strong, nonatomic) ApiRoutes					*routes;
@property (strong, nonatomic) ApiRoute					*route71;
@property (strong, nonatomic) ApiRoutesByStop			*routesByStop;
@property (strong, nonatomic) ApiStopsByRoute			*stopsByRoute;
@property (strong, nonatomic) ApiStopsByLocation		*stopsByLocation;

@property (strong, nonatomic) ApiTimeRequest			*timeRequest;
@property (strong, nonatomic) ApiRoutesRequest			*routesRequest;
@property (strong, nonatomic) ApiRoutesByStopRequest	*routesByStopRequest;
@property (strong, nonatomic) ApiStopsByRouteRequest	*stopsByRouteRequest;
@property (strong, nonatomic) ApiStopsByLocationRequest	*stopsByLocationRequest;
@end

// ----------------------------------------------------------------------
#pragma mark -
// ----------------------------------------------------------------------

@implementation MasterViewController

// ----------------------------------------------------------------------
//#pragma mark -
// ----------------------------------------------------------------------

//	http://realtime.mbta.com/developer/api/v2/servertime?api_key=<myKey>&format=[json/xml]
- (void)get_servertime {
	@weakify(self)
	[ApiTime get_success:^(ApiTime *servertime) {
		MyLog(@"\n\n%s servertime = %@\n\n", __FUNCTION__, servertime);
		@strongify(self)
		[self show_success:servertime verb:verb_servertime section:sSection_gets];
	} failure:^(NSError *error) {
		NSLog(@"\n\n%s API call failed: %@", __FUNCTION__, [error localizedDescription]);
		@strongify(self)
		[self show_failure_verb:verb_servertime section:sSection_gets];
	}];
}

- (void)request_servertime {
	if (self.timeRequest == nil)
		self.timeRequest = [[ApiTimeRequest alloc] init];
	@weakify(self)
	[self.timeRequest refresh_success:^(ApiRequest *request) {
		ApiData *time = [request response];
		NSAssert([time isKindOfClass:[ApiTime class]], @"Wrong ApiData subclass returned by request.");
		ApiTime *servertime = (ApiTime *)time;
		MyLog(@"\n\n%s servertime = %@\n\n", __FUNCTION__, servertime);
		@strongify(self)
		[self show_success:servertime verb:verb_servertime section:sSection_requests];
	} failure:^(NSError *error) {
		NSLog(@"\n\n%s API call failed: %@", __FUNCTION__, [error localizedDescription]);
		@strongify(self)
		[self show_failure_verb:verb_servertime section:sSection_requests];
	}];
}

// ----------------------------------------------------------------------
//	http://realtime.mbta.com/developer/api/v2/routes?api_key=<myKey>&format=[json/xml]
- (void)get_routes {
	@weakify(self)
	[ApiRoutes get_success:^(ApiRoutes *routes) {
		MyLog(@"\n\n%s routes = %@\n\n", __FUNCTION__, routes);
		
		self.routes = routes;
		
		// enable table row(s) that require 'self.routes'
		NSIndexPath *indexPath = [NSIndexPath indexPathForRow:e_verb_stopsbyroute inSection:sSection_gets];
		// either gets existing cell directly from cache
		// or creates new one via call to our '-tableView:cellForRowAtIndexPath:'
		UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
		if (cell) {
			cell.userInteractionEnabled = cell.textLabel.enabled = cell.detailTextLabel.enabled = YES;
		}
		
		@strongify(self)
		[self show_success:routes verb:verb_routes section:sSection_gets];
	} failure:^(NSError *error) {
		NSLog(@"\n\n%s API call failed: %@", __FUNCTION__, [error localizedDescription]);
		@strongify(self)
		[self show_failure_verb:verb_routes section:sSection_gets];
	}];
}
- (void)update_routes {
	if (self.routes) {
		@weakify(self)
		[self.routes update_success:^(ApiRoutes *routes) {
			NSAssert(routes == self.routes, @"Update failed to return original item.");
			MyLog(@"\n\n%s routes = %@\n\n", __FUNCTION__, routes);
			@strongify(self)
			[self show_success:routes verb:verb_routes section:sSection_gets];
		} failure:^(NSError *error) {
			NSLog(@"\n\n%s API call failed: %@", __FUNCTION__, [error localizedDescription]);
			@strongify(self)
			[self show_failure_verb:verb_routes section:sSection_gets];
		}];
	}
	else
		[self show_failure_verb:verb_routes section:sSection_gets];
}

- (void)request_routes {
	if (self.routesRequest == nil)
		self.routesRequest = [[ApiRoutesRequest alloc] init];
	@weakify(self)
	[self.routesRequest refresh_success:^(ApiRequest *request) {
		ApiRoutes *routes = (ApiRoutes *)[request response];
		NSAssert([routes isKindOfClass:[ApiRoutes class]], @"Wrong ApiData subclass returned by request.");
		@strongify(self)
		[self show_success:routes verb:verb_routes section:sSection_requests];
	} failure:^(NSError *error) {
		NSLog(@"\n\n%s API call failed: %@", __FUNCTION__, [error localizedDescription]);
		@strongify(self)
		[self show_failure_verb:verb_routes section:sSection_requests];
	}];
}

// ----------------------------------------------------------------------
- (void)get_routesbystop {
	@weakify(self)
	[ApiRoutesByStop get4stop:test_stopID success:^(ApiRoutesByStop *routes) {
		MyLog(@"\n\n%s routes = %@\n\n", __FUNCTION__, routes);
		
		self.routesByStop = routes;
		
		@strongify(self)
		[self show_success:routes verb:verb_routesbystop section:sSection_gets];
	} failure:^(NSError *error) {
		NSLog(@"\n\n%s API call failed: %@", __FUNCTION__, [error localizedDescription]);
		@strongify(self)
		[self show_failure_verb:verb_routesbystop section:sSection_gets];
	}];
}
- (void)update_routesbystop {
	if (self.routesByStop) {
		@weakify(self)
		[self.routesByStop update_success:^(ApiRoutesByStop *routes) {
			NSAssert(routes == self.routesByStop, @"Update failed to return original item.");
			MyLog(@"\n\n%s routesbystop = %@\n\n", __FUNCTION__, routes);
			@strongify(self)
			[self show_success:routes verb:verb_routesbystop section:sSection_gets];
		} failure:^(NSError *error) {
			NSLog(@"\n\n%s API call failed: %@", __FUNCTION__, [error localizedDescription]);
			@strongify(self)
			[self show_failure_verb:verb_routesbystop section:sSection_gets];
		}];
	}
	else
		[self show_failure_verb:verb_routesbystop section:sSection_gets];
}

- (void)request_routesbystop {
	if (self.routesByStopRequest == nil)
		self.routesByStopRequest = [[ApiRoutesByStopRequest alloc] init4stop:test_stopID];
	@weakify(self)
	[self.routesByStopRequest refresh_success:^(ApiRequest *request) {
		ApiRoutesByStop *routes = (ApiRoutesByStop *)[request response];
		NSAssert([routes isKindOfClass:[ApiRoutesByStop class]], @"Wrong ApiData subclass returned by request.");
		@strongify(self)
		[self show_success:routes verb:verb_routesbystop section:sSection_requests];
	} failure:^(NSError *error) {
		NSLog(@"\n\n%s API call failed: %@", __FUNCTION__, [error localizedDescription]);
		@strongify(self)
		[self show_failure_verb:verb_routesbystop section:sSection_requests];
	}];
}

// ----------------------------------------------------------------------
- (void)get_stopsbyroute {
#if CONFIG_stops_update_route
	if (self.routes) {
		
		sRoute71 = [self.routes routeByID:test_routeID];
		
		if (sRoute71) {
			@weakify(self)
			[sRoute71 addStops_success:^(ApiRoute *route) {
				MyLog(@"\n\n%s route 71 => %@\n\n", __FUNCTION__, sRoute71);
				@strongify(self)
				[self show_success:sRoute71 verb:verb_stopsbyroute section:sSection_gets];
			} failure:^(NSError *error) {
				NSLog(@"\n\n%s API call failed: %@", __FUNCTION__, [error localizedDescription]);
				@strongify(self)
				[self show_failure_verb:verb_stopsbyroute section:sSection_gets];
			}];
		}
		else
			[self show_failure_verb:verb_stopsbyroute section:sSection_gets];
	}
	else
		[self show_failure_verb:verb_stopsbyroute];
#else
	@weakify(self)
	[ApiStopsByRoute get4route:test_routeID success:^(ApiStopsByRoute *stops) {
		MyLog(@"\n\n%s stops = %@\n\n", __FUNCTION__, stops);
		
		self.stopsByRoute = stops;
		
		@strongify(self)
		[self show_success:stops verb:verb_stopsbyroute section:sSection_gets];
	} failure:^(NSError *error) {
		NSLog(@"\n\n%s API call failed: %@", __FUNCTION__, [error localizedDescription]);
		@strongify(self)
		[self show_failure_verb:verb_stopsbyroute section:sSection_gets];
	}];
#endif
}
- (void)update_stopsbyroute {
#if CONFIG_stops_update_route
	if (sRoute71) {
#warning TODO
		@weakify(self)
		[sRoute71 updateStops_success:^(ApiRoute *route) {
			NSAssert(route == sRoute71, @"Update failed to return original item.");
			@strongify(self)
			[self show_success:route verb:verb_stopsbyroute section:sSection_gets];
		} failure:^(NSError *error) {
			NSLog(@"\n\n%s API call failed: %@", __FUNCTION__, [error localizedDescription]);
			@strongify(self)
			[self show_failure_verb:verb_stopsbyroute section:sSection_gets];
		}];
	}
	else
		[self show_failure_verb:verb_stopsbyroute];
#else
	if (self.stopsByRoute) {
		@weakify(self)
		[self.stopsByRoute update_success:^(ApiStopsByRoute *stops) {
			NSAssert(stops == self.stopsByRoute, @"Update failed to return original item.");
			MyLog(@"\n\n%s stops = %@\n\n", __FUNCTION__, stops);
			@strongify(self)
			[self show_success:stops verb:verb_stopsbyroute section:sSection_gets];
		} failure:^(NSError *error) {
			NSLog(@"\n\n%s API call failed: %@", __FUNCTION__, [error localizedDescription]);
			@strongify(self)
			[self show_failure_verb:verb_stopsbyroute section:sSection_gets];
		}];
	}
	else
		[self show_failure_verb:verb_stopsbyroute section:sSection_gets];
#endif
}

- (void)request_stopsbyroute {
#if CONFIG_stops_update_route
	// no request object; call is made directly on the ApiRoute object
#else
	if (self.stopsByRouteRequest == nil)
		self.stopsByRouteRequest = [[ApiStopsByRouteRequest alloc] init4route:test_routeID];
	@weakify(self)
	[self.stopsByRouteRequest refresh_success:^(ApiRequest *request) {
		ApiStopsByRoute *stops = (ApiStopsByRoute *)[request response];
		NSAssert([stops isKindOfClass:[ApiStopsByRoute class]], @"Wrong ApiData subclass returned by request.");
		@strongify(self)
		[self show_success:stops verb:verb_stopsbyroute section:sSection_requests];
	} failure:^(NSError *error) {
		NSLog(@"\n\n%s API call failed: %@", __FUNCTION__, [error localizedDescription]);
		@strongify(self)
		[self show_failure_verb:verb_routesbystop section:sSection_requests];
	}];
#endif
}

// ----------------------------------------------------------------------
- (void)get_stopsbylocation {
	@weakify(self)
	[ApiStopsByLocation get4location:test_location success:^(ApiStopsByLocation *stops) {
		MyLog(@"\n\n%s stops = %@\n\n", __FUNCTION__, stops);
		
		self.stopsByLocation = stops;
		
		@strongify(self)
		[self show_success:stops verb:verb_stopsbylocation section:sSection_gets];
	} failure:^(NSError *error) {
		NSLog(@"\n\n%s API call failed: %@", __FUNCTION__, [error localizedDescription]);
		@strongify(self)
		[self show_failure_verb:verb_stopsbylocation section:sSection_gets];
	}];
}
- (void)update_stopsbylocation {
	if (self.stopsByLocation) {
		@weakify(self)
		[self.stopsByLocation update_success:^(ApiStopsByLocation *stops) {
			MyLog(@"\n\n%s stops = %@\n\n", __FUNCTION__, stops);
			@strongify(self)
			[self show_success:stops verb:verb_stopsbylocation section:sSection_gets];
		} failure:^(NSError *error) {
			NSLog(@"\n\n%s API call failed: %@", __FUNCTION__, [error localizedDescription]);
			@strongify(self)
			[self show_failure_verb:verb_stopsbylocation section:sSection_gets];
		}];
	}
	else
		[self show_failure_verb:verb_stopsbylocation section:sSection_gets];
}

- (void)request_stopsbylocation {
	if (self.stopsByLocationRequest == nil)
		self.stopsByLocationRequest = [[ApiStopsByLocationRequest alloc] init4location:test_location];
	@weakify(self)
	[self.stopsByLocationRequest refresh_success:^(ApiRequest *request) {
		ApiStopsByLocation *stops = (ApiStopsByLocation *)[request response];
		NSAssert([stops isKindOfClass:[ApiStopsByLocation class]], @"Wrong ApiData subclass returned by request.");
		@strongify(self)
		[self show_success:stops verb:verb_stopsbylocation section:sSection_requests];
	} failure:^(NSError *error) {
		NSLog(@"\n\n%s API call failed: %@", __FUNCTION__, [error localizedDescription]);
		@strongify(self)
		[self show_failure_verb:verb_stopsbylocation section:sSection_requests];
	}];
}

// ----------------------------------------------------------------------
#pragma mark -
// ----------------------------------------------------------------------

- (void)awakeFromNib {
	[super awakeFromNib];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (void)dealloc {
	// in case someday this VC is not the only one in this app
	// cancel any '-performSelector:' calls before we go away
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
}

// ----------------------------------------------------------------------
#pragma mark - Segues
// ----------------------------------------------------------------------

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
	return NO;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([[segue identifier] isEqualToString:@"showDetail"]) {
//	    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
		NSDate *object = [NSDate date];
	    [[segue destinationViewController] setDetailItem:object];
	}
}

// ----------------------------------------------------------------------
#pragma mark - UITableViewDataSource
// ----------------------------------------------------------------------
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [ServiceMBTA verbCount];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

	NSString *text = [ServiceMBTA verbForIndex:indexPath.row];
	
	BOOL enabled = NO;
	switch (indexPath.row) {
		case e_verb_servertime:
		case e_verb_routes:
		case e_verb_routesbystop:
		case e_verb_stopsbylocation:
			enabled = YES;
			break;
		case e_verb_stopsbyroute:
#if CONFIG_stops_update_route
			enabled = (self.routes != nil && indexPath.section == 0); // only ever enabled for 'gets'
#endif
			break;
		default:
			break;
	}
	cell.userInteractionEnabled = cell.textLabel.enabled = cell.detailTextLabel.enabled = enabled;
	
	cell.textLabel.text = text;
	cell.detailTextLabel.text = @"idle";

	UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	spinner.hidesWhenStopped = YES;
	[cell setAccessoryView:spinner];

//	cell.selectionStyle = UITableViewCellSelectionStyleNone;

	return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	NSString *result = @"???";
	switch (section) {
		case 0:
			result = @"get data";
			break;
		case 1:
			result = @"request data";
			break;
		default:
			break;
	}
	return result;
}

// ----------------------------------------------------------------------
#pragma mark - UITableViewDelegate
// ----------------------------------------------------------------------

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

	UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
	// clear selection on table cell with animation delay
	// (if we don't call 'cell.selectionStyle = UITableViewCellSelectionStyleNone' above)
	[cell setSelected:NO animated:YES];
	
	UIActivityIndicatorView *spinner = nil;
	UIView *accessoryView = cell.accessoryView;
	if ([accessoryView isKindOfClass:[UIActivityIndicatorView class]]) {
		spinner = (UIActivityIndicatorView *)accessoryView;
		[spinner startAnimating];
	}
	cell.detailTextLabel.text = @"requesting ...";
	
	if (indexPath.section == 0) {
		switch (indexPath.row) {
				
			case e_verb_servertime:
				[self get_servertime];
				break;
				
			case e_verb_routes:
				if (self.routes == nil)
					[self get_routes];
				else
					[self update_routes];
				break;
				
			case e_verb_routesbystop:
				if (self.routesByStop == nil)
					[self get_routesbystop];
				else
					[self update_routesbystop];
				break;
				
			case e_verb_stopsbyroute:
				if (self.routes) {
#if CONFIG_stops_update_route
					if (sRoute71 == nil)
						[self get_stopsbyroute];
					else
						[self update_stopsbyroute];
#else
					if (self.stopsByRoute == nil)
						[self get_stopsbyroute];
					else
						[self update_stopsbyroute];
#endif
				}
				else { // stop spinner, reset cell to pre-request state
					[spinner stopAnimating];
					cell.detailTextLabel.text = @"idle";
				}
				break;
			case e_verb_stopsbylocation:
				if (self.stopsByLocation == nil) {
					[self get_stopsbylocation];
				}
				else
					[self update_stopsbylocation];
				break;
				
			default:
				[spinner stopAnimating];
				cell.detailTextLabel.text = @"idle";
				break;
		}
	}
	else if (indexPath.section == 1) {
		switch (indexPath.row) {
			case e_verb_servertime:
				[self request_servertime];
				break;
			case e_verb_routes:
				[self request_routes];
				break;
			case e_verb_routesbystop:
				[self request_routesbystop];
				break;
			case e_verb_stopsbyroute:
				[self request_stopsbyroute];
				break;
			case e_verb_stopsbylocation:
				[self request_stopsbylocation];
				break;
			default:
				[spinner stopAnimating];
				cell.detailTextLabel.text = @"idle";
				break;
		}
	}
}

// ----------------------------------------------------------------------
#pragma mark - show success/failure
// ----------------------------------------------------------------------

- (void)show_success:(ApiData *)data verb:(NSString *)verb section:(NSUInteger)section {
	NSString *text = nil;
	
	NSUInteger index = [ServiceMBTA indexForVerb:verb];
	switch (index) {
		case e_verb_servertime: {
			ApiTime *servertime = (ApiTime *)data;
			text = [NSString stringWithFormat:@"%@ => %@", verb, [servertime time]];
		}	break;
		case e_verb_routes: {
			ApiRoutes *routes = (ApiRoutes *)data;
			text = [NSString stringWithFormat:@"%@ => %@", verb, [self routes_in_modes:routes.modes]];
		}	break;
		case e_verb_routesbystop: {
			ApiRoutesByStop *routes = (ApiRoutesByStop *)data;
			text = [NSString stringWithFormat:@"%@ => %@", verb, [self routes_in_modes:routes.modes]];
		}	break;
		case e_verb_stopsbyroute: {
#if CONFIG_stops_update_route
			ApiRoute *route71 = (ApiRoute *)data;
			text = [NSString stringWithFormat:@"%@ => %@", verb, [self stops_in_directions:route71.directions]];
#else
			ApiStopsByRoute *stops = (ApiStopsByRoute *)data;
			text = [NSString stringWithFormat:@"%@ => %@", verb, [self stops_in_directions:stops.directions]];
#endif
		}	break;
		case e_verb_stopsbylocation: {
			ApiStopsByLocation *stopsbylocation = (ApiStopsByLocation *)data;
			text = [NSString stringWithFormat:@"%@ => %@", verb, [self stops:stopsbylocation.stops near_location:stopsbylocation.location]];
		}	break;
		default:
			MyLog(@"%s NO CODE FOR VERB '%@'", __FUNCTION__, verb);
			text = @"NO CODE";
			break;
	}
	MyLog(@"%s shows '%@'", __FUNCTION__, text);
	
	if (text)
		[self setResponse:text forVerb:verb section:section];
}

- (void)show_failure_verb:(NSString *)verb section:(NSUInteger)section {
	NSString *text = [NSString stringWithFormat:@"%@ request failed", verb];
	[self setResponse:text forVerb:verb section:section];
}

// ----------------------------------------------------------------------
// return short string summarizing (sub)response to request
// ----------------------------------------------------------------------

// returns string "<num> routes in <num> modes"
- (NSString *)routes_in_modes:(NSArray *)modes {
	NSUInteger num_routes = 0;
	for (ApiRouteMode *mode in modes) {
		num_routes += [mode.routes count];
	}
	NSString *result = [NSString stringWithFormat:@"%i routes in %i modes", (int)num_routes, (int)[modes count]];
	return result;
}

// returns string "<num> stops in <num> directions"
- (NSString *)stops_in_directions:(NSArray *)directions {
	NSUInteger num_stops = 0;
	for (ApiRouteDirection *direction in directions) {
		num_stops += [direction.stops count];
	}
	NSString *result = [NSString stringWithFormat:@"%i stops in %i directions", (int)num_stops, (int)[directions count]];
	return result;
}

// returns string "<num> stops near <lat>, <lon> (lat,lon)"
- (NSString *)stops:(NSArray *)stops near_location:(CLLocationCoordinate2D)location {
	NSString *result = [NSString stringWithFormat:@"%i stops near %.3f, %.3f (lat,lon)", (int)[stops count], location.latitude, location.longitude];
	return result;
}

// ----------------------------------------------------------------------

- (void)setResponse:(NSString *)text forVerb:(NSString *)verb section:(NSUInteger)section {
	if ([verb length]) {
		NSUInteger row = [ServiceMBTA indexForVerb:verb];
		if (row < [ServiceMBTA verbCount]) { // get NSNotFound for unknown verb
			NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
			UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
			
			if ([text length]) {
				cell.detailTextLabel.text = text;
				
				// flash cell briefly to indicate response has arrived
				[cell setSelected:YES animated:YES];
				[cell setSelected: NO animated:YES];
				
				// cancel any previously posted 'reset' calls
				[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(resetForIndexPath:) object:indexPath];
				
				// now wait awhile, then reset table row to its original state
				[self performSelector:@selector(resetForIndexPath:) withObject:indexPath afterDelay:3.0];
			}
			UIView *accessoryView = cell.accessoryView;
			if ([accessoryView isKindOfClass:[UIActivityIndicatorView class]]) {
				UIActivityIndicatorView *spinner = (UIActivityIndicatorView *)accessoryView;
				[spinner stopAnimating];
			}
		}
	}
}

- (void)resetForIndexPath:(NSIndexPath *)indexPath {
	NSUInteger row = indexPath.row;
	if (row < [ServiceMBTA verbCount]) { // get NSNotFound for unknown verb
		UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
		cell.detailTextLabel.text = @"idle";
	}
}

@end
