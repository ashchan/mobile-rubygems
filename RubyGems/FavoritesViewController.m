//
//  FavoritesViewController.m
//  RubyGems
//
//  Created by James Chen on 10/7/12.
//  Copyright (c) 2012 ashchan.com. All rights reserved.
//

#import "FavoritesViewController.h"
#import "DetailViewController.h"
#import "GemEntry.h"
#import "Favorite.h"
#import "MBProgressHUD.h"
#import "EGORefreshTableHeaderView.h"

@interface FavoritesViewController () <EGORefreshTableHeaderDelegate> {
    NSMutableArray *_objects;
    EGORefreshTableHeaderView *_refreshHeader;
    BOOL _reloading;
}

- (void)reload;

@end

@implementation FavoritesViewController

- (void)reload {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Loading...";

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [_objects removeAllObjects];
        [_objects addObjectsFromArray:[Favorite favorites]];

        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            [self.tableView reloadData];
            [_refreshHeader refreshLastUpdatedDate];
            if (_reloading) {
                [self doneLoadingTableViewData];
            }
        });
    });

}

- (void)favoritesUpdated:(NSNotification *)notification {
    [self reload];
}

- (void)favoritesUpdatedFromCloud:(NSNotification *)notification {
    [Favorite sync];
    [self reload];
    [Favorite syncPush];
}

- (void)favoritesPushSync:(NSNotification *)notification {
    [Favorite syncPush];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil] setTintColor:kTintColor];
    self.navigationItem.hidesBackButton = YES;

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(favoritesUpdatedFromCloud:)
                                                 name:NSUbiquitousKeyValueStoreDidChangeExternallyNotification
                                               object:[NSUbiquitousKeyValueStore defaultStore]];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(favoritesUpdated:)
                                                 name:kFavoritesShouldReloadNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(favoritesPushSync:)
                                                 name:kSyncFavoritesPushNotifiction object:nil];

    _objects = [[NSMutableArray alloc] init];

    _refreshHeader = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.view.frame.size.width, self.tableView.bounds.size.height)];
    _refreshHeader.delegate = self;
    [self.tableView addSubview:_refreshHeader];

    [self reload];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:animated];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _objects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"FavoriteCell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    NSDictionary *object = [_objects objectAtIndex:indexPath.row];
    cell.textLabel.text = [object objectForKey:@"name"];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"MMM dd, yyyy hh:mm";
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    cell.detailTextLabel.text = [dateFormatter stringFromDate:[object objectForKey:@"createdAt"]];

    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSDictionary *obj = [_objects objectAtIndex:indexPath.row];
        [[[Favorite alloc] initWithGemName:[obj objectForKey:@"name"]] delete];
        [_objects removeObject:obj];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (UITableViewCellEditingStyle) tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        GemEntry *entry = [[GemEntry alloc] init];
        entry.name = [[_objects objectAtIndex:indexPath.row] objectForKey:@"name"];
        entry.fullyLoaded = NO;
        [[segue destinationViewController] setDetailItem:entry];
    }
}

- (void)reloadTableViewDataSource{
	_reloading = YES;
    [self reload];
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

@end
