//
//  SearchViewController.m
//  RubyGems
//
//  Created by James Chen on 10/7/12.
//  Copyright (c) 2012 ashchan.com. All rights reserved.
//

#import "SearchViewController.h"
#import "DetailViewController.h"
#import "MBProgressHUD.h"
#import "GemEntry.h"
#import "RubyGemsAPIManager.h"

@interface SearchViewController () <UISearchBarDelegate> {
    NSMutableArray *_objects;
}

@property (strong, nonatomic) IBOutlet UISearchDisplayController *searchDisplayController;

@end

@implementation SearchViewController
@synthesize searchDisplayController;

- (void)viewDidLoad
{
    [super viewDidLoad];
    _objects = [[NSMutableArray alloc] init];
    self.clearsSelectionOnViewWillAppear = NO;
}

- (void)viewDidUnload
{
    [self setSearchDisplayController:nil];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _objects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    GemEntry *object = [_objects objectAtIndex:indexPath.row];
    cell.textLabel.text = object.name;
    cell.detailTextLabel.text = object.version;
    
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        UITableView *tableView = searchDisplayController.active ? searchDisplayController.searchResultsTableView : self.tableView;

        NSIndexPath *indexPath = [tableView indexPathForSelectedRow];
        GemEntry *object = [_objects objectAtIndex:indexPath.row];
        [[segue destinationViewController] setDetailItem:object];
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Searching...";
    [[RubyGemsAPIManager sharedManager] searchString:self.searchDisplayController.searchBar.text
                                            progress:^(CGFloat p) {
                                                hud.progress = p;
                                            }
                                          completion:^(NSArray *objects) {
                                              [_objects removeAllObjects];
                                              for (id obj in objects) {
                                                  [_objects addObject:[GemEntry entryFromJSON:obj]];
                                              }
                                              [self.searchDisplayController.searchResultsTableView reloadData];
                                              [self.tableView reloadData];
                                              [MBProgressHUD hideHUDForView:self.view animated:YES];
                                          }
                                             failure:^(NSError *error) {
                                                 [MBProgressHUD hideHUDForView:self.view animated:YES];
                                                 // TODO
                                          }];
}

@end
