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

#import "EXTScope.h"

#import "Debug_iOS.h"

// ----------------------------------------------------------------------

static NSString *str_sequeID_DetailViewController = @"showDetail";
//static NSString *str_sequeID_DetailViewController = @"showResponse";

static NSString * const		  test_routeID   = @"71";
static NSString * const		  test_stopID    = @"2021";
static CLLocationCoordinate2D test_location  = { +42.373600, -71.118962 };

static ApiRoutes			*sRoutes;
static ApiRoute				*sRoute71;
static ApiRoutesByStop		*sRoutesByStop;
static ApiStopsByRoute		*sStopsByRoute;
static ApiStopsByLocation	*sStopsByLocation;

// ----------------------------------------------------------------------
#pragma mark -
// ----------------------------------------------------------------------

@interface MasterViewController ()
@end

// ----------------------------------------------------------------------
#pragma mark -
// ----------------------------------------------------------------------

@implementation MasterViewController


// ----------------------------------------------------------------------
#pragma mark -
// ----------------------------------------------------------------------

//	http://realtime.mbta.com/developer/api/v2/servertime?api_key=<myKey>&format=[json/xml]
- (void)get_servertime {
	@weakify(self)
	[ApiTime get_success:^(ApiTime *servertime) {
		MyLog(@"\n\n%s servertime = %@\n\n", __FUNCTION__, servertime);
		@strongify(self)
		[self show_success:servertime verb:verb_servertime];
	} failure:^(NSError *error) {
		NSLog(@"\n\n%s API call failed: %@", __FUNCTION__, [error localizedDescription]);
		@strongify(self)
		[self show_failure_verb:verb_servertime];
	}];
}

// ----------------------------------------------------------------------
//	http://realtime.mbta.com/developer/api/v2/routes?api_key=<myKey>&format=[json/xml]
- (void)get_routes {
	@weakify(self)
	[ApiRoutes get_success:^(ApiRoutes *routes) {
		MyLog(@"\n\n%s routes = %@\n\n", __FUNCTION__, routes);
		
		sRoutes = routes;
		
		// enable table row(s) that require 'sRoutes'
		NSIndexPath *indexPath = [NSIndexPath indexPathForRow:e_verb_stopsbyroute inSection:0];
		// either gets existing cell directly from cache
		// or creates new one via call to our '-tableView:cellForRowAtIndexPath:'
		UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
		if (cell) {
			cell.userInteractionEnabled = cell.textLabel.enabled = cell.detailTextLabel.enabled = YES;
		}
		
		@strongify(self)
		[self show_success:routes verb:verb_routes];
	} failure:^(NSError *error) {
		NSLog(@"\n\n%s API call failed: %@", __FUNCTION__, [error localizedDescription]);
		@strongify(self)
		[self show_failure_verb:verb_routes];
	}];
}
- (void)update_routes {
	if (sRoutes) {
		@weakify(self)
		[sRoutes update_success:^(ApiRoutes *routes) {
			NSAssert(routes == sRoutes, @"Update failed to return original item.");
			MyLog(@"\n\n%s routes = %@\n\n", __FUNCTION__, routes);
			@strongify(self)
			[self show_success:routes verb:verb_routes];
		} failure:^(NSError *error) {
			NSLog(@"\n\n%s API call failed: %@", __FUNCTION__, [error localizedDescription]);
			@strongify(self)
			[self show_failure_verb:verb_routes];
		}];
	}
	else
		[self show_failure_verb:verb_routes];
}

// ----------------------------------------------------------------------
- (void)get_routesbystop {
	@weakify(self)
	[ApiRoutesByStop get4stop:test_stopID success:^(ApiRoutesByStop *routes) {
		MyLog(@"\n\n%s routes = %@\n\n", __FUNCTION__, routes);
		
		sRoutesByStop = routes;
		
		@strongify(self)
		[self show_success:routes verb:verb_routesbystop];
	} failure:^(NSError *error) {
		NSLog(@"\n\n%s API call failed: %@", __FUNCTION__, [error localizedDescription]);
		@strongify(self)
		[self show_failure_verb:verb_routesbystop];
	}];
}
- (void)update_routesbystop {
	if (sRoutesByStop) {
		@weakify(self)
		[sRoutesByStop update_success:^(ApiRoutesByStop *routes) {
			NSAssert(routes == sRoutesByStop, @"Update failed to return original item.");
			MyLog(@"\n\n%s routesbystop = %@\n\n", __FUNCTION__, routes);
			@strongify(self)
			[self show_success:routes verb:verb_routesbystop];
		} failure:^(NSError *error) {
			NSLog(@"\n\n%s API call failed: %@", __FUNCTION__, [error localizedDescription]);
			@strongify(self)
			[self show_failure_verb:verb_routesbystop];
		}];
	}
	else
		[self show_failure_verb:verb_routesbystop];
}

// ----------------------------------------------------------------------
- (void)get_stopsbyroute {
#if CONFIG_stops_update_route
	if (sRoutes) {
		
		sRoute71 = [sRoutes routeByID:test_routeID];
		
		if (sRoute71) {
			@weakify(self)
			[sRoute71 addStops_success:^(ApiRoute *route) {
				MyLog(@"\n\n%s route 71 => %@\n\n", __FUNCTION__, sRoute71);
				@strongify(self)
				[self show_success:sRoute71 verb:verb_stopsbyroute];
			} failure:^(NSError *error) {
				NSLog(@"\n\n%s API call failed: %@", __FUNCTION__, [error localizedDescription]);
				@strongify(self)
				[self show_failure_verb:verb_stopsbyroute];
			}];
		}
		else
			[self show_failure_verb:verb_stopsbyroute];
	}
	else
		[self show_failure_verb:verb_stopsbyroute];
#else
	@weakify(self)
	[ApiStopsByRoute get4route:test_routeID success:^(ApiStopsByRoute *stops) {
		MyLog(@"\n\n%s stops = %@\n\n", __FUNCTION__, stops);
		
		sStopsByRoute = stops;
		
		@strongify(self)
		[self show_success:stops verb:verb_stopsbyroute];
	} failure:^(NSError *error) {
		NSLog(@"\n\n%s API call failed: %@", __FUNCTION__, [error localizedDescription]);
		@strongify(self)
		[self show_failure_verb:verb_stopsbyroute];
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
			[self show_success:route verb:verb_stopsbyroute];
		} failure:^(NSError *error) {
			NSLog(@"\n\n%s API call failed: %@", __FUNCTION__, [error localizedDescription]);
			@strongify(self)
			[self show_failure_verb:verb_stopsbyroute];
		}];
	}
	else
		[self show_failure_verb:verb_stopsbyroute];
#else
	if (sStopsByRoute) {
		@weakify(self)
		[sStopsByRoute update_success:^(ApiStopsByRoute *stops) {
			NSAssert(stops == sStopsByRoute, @"Update failed to return original item.");
			MyLog(@"\n\n%s stops = %@\n\n", __FUNCTION__, stops);
			@strongify(self)
			[self show_success:stops verb:verb_stopsbyroute];
		} failure:^(NSError *error) {
			NSLog(@"\n\n%s API call failed: %@", __FUNCTION__, [error localizedDescription]);
			@strongify(self)
			[self show_failure_verb:verb_stopsbyroute];
		}];
	}
	else
		[self show_failure_verb:verb_stopsbyroute];
#endif
}

// ----------------------------------------------------------------------
- (void)get_stopsbylocation {
	@weakify(self)
	[ApiStopsByLocation get4location:test_location success:^(ApiStopsByLocation *stops) {
		MyLog(@"\n\n%s stops = %@\n\n", __FUNCTION__, stops);
		
		sStopsByLocation = stops;
		
		@strongify(self)
		[self show_success:stops verb:verb_stopsbylocation];
	} failure:^(NSError *error) {
		NSLog(@"\n\n%s API call failed: %@", __FUNCTION__, [error localizedDescription]);
		@strongify(self)
		[self show_failure_verb:verb_stopsbylocation];
	}];
}
- (void)update_stopsbylocation {
	if (sStopsByLocation) {
		@weakify(self)
		[sStopsByLocation update_success:^(ApiStopsByLocation *stops) {
			MyLog(@"\n\n%s stops = %@\n\n", __FUNCTION__, stops);
			@strongify(self)
			[self show_success:stops verb:verb_stopsbylocation];
		} failure:^(NSError *error) {
			NSLog(@"\n\n%s API call failed: %@", __FUNCTION__, [error localizedDescription]);
			@strongify(self)
			[self show_failure_verb:verb_stopsbylocation];
		}];
	}
	else
		[self show_failure_verb:verb_stopsbylocation];
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
#warning TODO - make this 2-section table? top section does 'request', bottom section does 'get' and 'update'?
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
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
			enabled = (sRoutes != nil);
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
	
	switch (indexPath.row) {
		
		case e_verb_servertime:
			[self get_servertime];
			break;
		
		case e_verb_routes:
			if (sRoutes == nil)
				[self get_routes];
			else
				[self update_routes];
			break;
		
		case e_verb_routesbystop:
			if (sRoutesByStop == nil)
				[self get_routesbystop];
			else
				[self update_routesbystop];
			break;
		
		case e_verb_stopsbyroute:
			if (sRoutes) {
#if CONFIG_stops_update_route
				if (sRoute71 == nil)
					[self get_stopsbyroute];
				else
					[self update_stopsbyroute];
#else
				if (sStopsByRoute == nil)
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
			if (sStopsByLocation == nil) {
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

// ----------------------------------------------------------------------
#pragma mark - show success/failure
// ----------------------------------------------------------------------

- (void)show_success:(ApiData *)data verb:(NSString *)verb {
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
		[self setResponse:text forVerb:verb];
}

- (void)show_failure_verb:(NSString *)verb {
	NSString *text = [NSString stringWithFormat:@"%@ request failed", verb];
	[self setResponse:text forVerb:verb];
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

- (void)setResponse:(NSString *)text forVerb:(NSString *)verb {
	if ([verb length]) {
		NSUInteger row = [ServiceMBTA indexForVerb:verb];
		if (row < [ServiceMBTA verbCount]) { // get NSNotFound for unknown verb
			NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
			UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
			
			if ([text length]) {
				cell.detailTextLabel.text = text;
				
				// flash cell briefly to indicate response has arrived
				[cell setSelected:YES animated:YES];
				[cell setSelected: NO animated:YES];
				
				// wait awhile, then go back to original state
				[self performSelector:@selector(resetForVerb:) withObject:verb afterDelay:3.0];
			}
			UIView *accessoryView = cell.accessoryView;
			if ([accessoryView isKindOfClass:[UIActivityIndicatorView class]]) {
				UIActivityIndicatorView *spinner = (UIActivityIndicatorView *)accessoryView;
				[spinner stopAnimating];
			}
		}
	}
}

- (void)resetForVerb:(NSString *)verb {
	NSUInteger row = [ServiceMBTA indexForVerb:verb];
	if (row < [ServiceMBTA verbCount]) { // get NSNotFound for unknown verb
		NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
		UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
		cell.detailTextLabel.text = @"idle";
	}
}

@end
