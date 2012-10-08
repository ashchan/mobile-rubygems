//
//  MasterViewController.m
//  RubyGems
//
//  Created by James Chen on 10/7/12.
//  Copyright (c) 2012 ashchan.com. All rights reserved.
//

#import "MasterViewController.h"
#import "DetailViewController.h"
#import "MBProgressHUD.h"
#import "GemEntry.h"
#import "EGORefreshTableHeaderView.h"

@interface MasterViewController () <UITableViewDelegate, UITableViewDataSource, EGORefreshTableHeaderDelegate> {
    NSMutableArray *_objects;
    EGORefreshTableHeaderView *_refreshHeader;
    BOOL _reloading;
}

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

- (void)loadGems;
- (IBAction)segmentedControlValueChanged:(id)sender;

@end

@implementation MasterViewController
@synthesize segmentedControl = _segmentedControl;
@synthesize tableView = _tableView;
@synthesize gemsCategory;

@synthesize detailViewController = _detailViewController;

- (void)viewDidLoad {
    [super viewDidLoad];
    _objects = [[NSMutableArray alloc] init];
    self.gemsCategory = GemsCategoryUpdated;
    _reloading = NO;

    _refreshHeader = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.view.frame.size.width, self.tableView.bounds.size.height)];
    _refreshHeader.delegate = self;
    [self.tableView addSubview:_refreshHeader];

    [self loadGems];
}

- (void)viewDidUnload
{
    [self setTableView:nil];
    [self setSegmentedControl:nil];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:animated];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _objects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];

    GemEntry *object = [_objects objectAtIndex:indexPath.row];
    cell.textLabel.text = object.name;
    cell.detailTextLabel.text = object.version;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        GemEntry *object = [_objects objectAtIndex:indexPath.row];
        [[segue destinationViewController] setDetailItem:object];
    }
}

- (IBAction)segmentedControlValueChanged:(id)sender {
    self.gemsCategory = (GemsCategory)[sender selectedSegmentIndex];
    [self loadGems];
}

#pragma mark - Data Source Loading / Reloading Methods

- (void)reloadTableViewDataSource{
	_reloading = YES;
    [self loadGems];
}

- (void)doneLoadingTableViewData{
	_reloading = NO;
	[_refreshHeader egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
}

#pragma mark - EGORefreshTableHeaderDelegate

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view {
    [self reloadTableViewDataSource];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view {
    return _reloading;
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view {
    return [NSDate date];
}

#pragma mark - UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {	
	[_refreshHeader egoRefreshScrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
	[_refreshHeader egoRefreshScrollViewDidEndDragging:scrollView];
}

# pragma mark - load from api

- (void)loadGems {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    //hud.mode = MBProgressHUDModeDeterminate;
    hud.labelText = @"Loading...";
    [[RubyGemsAPIManager sharedManager] loadCategory:self.gemsCategory
                                            progress:^(CGFloat p) {
                                                hud.progress = p;
                                            }
                                          completion:^(NSArray *objects) {
                                              [_objects removeAllObjects];
                                              for (id obj in objects) {
                                                  [_objects addObject:[GemEntry entryFromJSON:obj]];
                                              }
                                              [self.tableView reloadData];
                                              [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                                              [_refreshHeader refreshLastUpdatedDate];
                                              if (_reloading) {
                                                  [self doneLoadingTableViewData];
                                              }
                                          }
                                             failure:^(NSError *error) {
                                                 [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                                                 if (_reloading) {
                                                     [self doneLoadingTableViewData];
                                                 }
                                             }];
}

@end
