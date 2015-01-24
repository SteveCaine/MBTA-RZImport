//
//	MasterViewController.m
//	MBTA-RZImport
//
//	Created by Steve Caine on 01/10/15.
//	Copyright (c) 2015 Steve Caine. All rights reserved.
//

#define CONFIG_get_not_request 0

#if CONFIG_get_not_request
#else
#endif


#import "MasterViewController.h"
#import "DetailViewController.h"

#import "ServiceMBTA.h"
#import "ServiceMBTA_strings.h"

#import "ApiRoutes.h"
#import "ApiTime.h"

#import "ApiRoutesRequest.h"
#import "ApiTimeRequest.h"

#import "EXTScope.h"

// ----------------------------------------------------------------------

static NSString *str_sequeID_DetailViewController = @"showDetail";
//static NSString *str_sequeID_DetailViewController = @"showResponse";

static NSString * const				test_routeID   = @"71";
static NSString * const				test_stopID    = @"2021";
//static CLLocationCoordinate2D const test_location  = { +42.373600, -71.118962 };

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
	ApiTimeRequest *request = [[ApiTimeRequest alloc] init];
	[request refresh_success:^(ApiRequest *request) {
		NSLog(@"\n\n%s servertime = %@\n\n", __FUNCTION__, [request response]);
		@strongify(self)
		[self show_success:[request response] verb:verb_servertime];
	} failure:^(NSError *error) {
		NSLog(@"\n\n%s API call failed: %@", __FUNCTION__, [error localizedDescription]);
		;
		@strongify(self)
		[self show_failure_verb:verb_servertime];
	}];
}

//	http://realtime.mbta.com/developer/api/v2/routes?api_key=<myKey>&format=[json/xml]
- (void)get_routes {
	@weakify(self)
	ApiRoutesRequest *request = [[ApiRoutesRequest alloc] init];
	[request refresh_success:^(ApiRequest *request) {
		NSLog(@"\n\n%s routes = %@\n\n", __FUNCTION__, [request response]);
		@strongify(self)
		[self show_success:[request response] verb:verb_routes];
	} failure:^(NSError *error) {
		NSLog(@"\n\n%s API call failed: %@", __FUNCTION__, [error localizedDescription]);
		@strongify(self)
		[self show_failure_verb:verb_routes];
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
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [ServiceMBTA verbCount];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

	NSString *text = [ServiceMBTA verbForIndex:indexPath.row];
/** /
	switch (indexPath.row) {
		case e_verb_servertime:
			break;
		case e_verb_routes:
			break;
		default:
			break;
	}
/ **/
	cell.textLabel.text = text;
	cell.detailTextLabel.text = @"idle";

	if (indexPath.row > e_verb_routes) {
		cell.userInteractionEnabled = NO;
		cell.textLabel.textColor = [UIColor lightGrayColor];
		cell.detailTextLabel.textColor = [UIColor lightGrayColor];
	}

	UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	spinner.hidesWhenStopped = YES;
	[cell setAccessoryView:spinner];

	cell.selectionStyle = UITableViewCellSelectionStyleNone;

	return cell;
}

// ----------------------------------------------------------------------
#pragma mark - UITableViewDelegate
// ----------------------------------------------------------------------

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	// servertime
#if 1
	switch (indexPath.row) {
		case e_verb_servertime:
			[self get_servertime];
			break;
		case e_verb_routes:
			[self get_routes];
			break;
		default:
			break;
	}
#elif 0
	@weakify(self)
	[ApiTime get_success:^(ApiTime *servertime) {
		NSLog(@"\n\n%s servertime = %@\n\n", __FUNCTION__, servertime);
		@strongify(self)
		[self show_success:servertime verb:verb_servertime];
	} failure:^(NSError *error) {
		NSLog(@"\n\n%s API call failed: %@", __FUNCTION__, [error localizedDescription]);
		@strongify(self)
		[self show_failure_verb:verb_servertime];
	}];
#else
	ApiRequest *request = [[ApiTimeRequest alloc] init];
	@weakify(self)
	[request refresh_success:^(ApiRequest *request) {
		@strongify(self)
		[self show_success:[request response] verb:verb_servertime];
	} failure:^(NSError *error) {
		NSLog(@"\n\n%s API call failed: %@", __FUNCTION__, [error localizedDescription]);
		@strongify(self)
		[self show_failure_verb:verb_servertime];
	}];
#endif
	// clear selection on table cell with animation delay
//	UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
//	[cell setSelected:NO animated:YES];
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
		default:
			break;
	}
	
	if (text)
		[self setResponse:text forVerb:verb];
}

- (void)show_failure_verb:(NSString *)verb {
	NSString *text = [NSString stringWithFormat:@"%@ request failed", verb];
	[self setResponse:text forVerb:verb];
}

// ----------------------------------------------------------------------

// returns string "<num> routes in <num> modes"
- (NSString *)routes_in_modes:(NSArray *)modes {
	NSUInteger num_routes = 0;
	for (ApiRouteMode *mode in modes) {
		num_routes += [mode.routes count];
	}
	NSString *result = [NSString stringWithFormat:@"%lu routes in %lu modes", (unsigned long)num_routes, (unsigned long)[modes count]];
	return result;
}

// returns string "<num> routes in <num> modes"
- (NSString *)stops_in_directions:(NSArray *)directions {
	NSUInteger num_stops = 0;
	for (ApiRouteDirection *direction in directions) {
		num_stops += [direction.stops count];
	}
	NSString *result = [NSString stringWithFormat:@"%lu stops in %lu directions", (unsigned long)num_stops, (unsigned long)[directions count]];
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
				
				UIView *accessoryView = cell.accessoryView;
				if ([accessoryView isKindOfClass:[UIActivityIndicatorView class]]) {
					UIActivityIndicatorView *spinner = (UIActivityIndicatorView *)accessoryView;
					[spinner stopAnimating];
				}
				// wait awhile, then go back to original state
				[self performSelector:@selector(resetForVerb:) withObject:verb afterDelay:3.0];
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
