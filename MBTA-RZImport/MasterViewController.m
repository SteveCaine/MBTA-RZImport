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

#import "ApiTime.h"
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

//	http://realtime.mbta.com/developer/api/v2/servertime?api_key=<myKey>&format=[json/xml]
- (void)get_servertime {
	@weakify(self)
	ApiTimeRequest *request = [[ApiTimeRequest alloc] init];
	[request refresh_success:^(ApiRequest *request) {
		@strongify(self)
		[self show_success:[request response] verb:verb_servertime];
	} failure:^(NSError *error) {
		NSLog(@"\n\n%s API call failed: %@", __FUNCTION__, [error localizedDescription]);
		;
		@strongify(self)
		[self show_failure_verb:verb_servertime];
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
	return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

	cell.textLabel.text = @"servertime";
	cell.detailTextLabel.text = @"idle";

//	if (should-be-disabled]) {
//		cell.userInteractionEnabled = NO;
//		cell.textLabel.textColor = [UIColor lightGrayColor];
//	}

	UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	spinner.hidesWhenStopped = YES;
	[cell setAccessoryView:spinner];

	cell.selectionStyle = UITableViewCellSelectionStyleNone;

	return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	// Return NO if you do not want the specified item to be editable.
	return NO;
}

// ----------------------------------------------------------------------
#pragma mark - UITableViewDelegate
// ----------------------------------------------------------------------

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	// servertime
#if 0
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
	
	ApiTime *servertime = (ApiTime *)data;
	text = [NSString stringWithFormat:@"%@ => %@", verb, [servertime time]];
	
	if (text)
		[self setResponse:text forVerb:verb];
}

- (void)show_failure_verb:(NSString *)verb {
	NSString *text = [NSString stringWithFormat:@"%@ request failed", verb];
	[self setResponse:text forVerb:verb];
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
