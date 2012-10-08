//
//  DetailViewController.m
//  RubyGems
//
//  Created by James Chen on 10/7/12.
//  Copyright (c) 2012 ashchan.com. All rights reserved.
//

#import "DetailViewController.h"
#import "GemEntry.h"
#import "MBProgressHUD.h"
#import "RubyGemsAPIManager.h"
#import "SVWebViewController.h"
#import "Favorite.h"

@interface DetailViewController () <UITableViewDataSource, UITableViewDelegate> {
    BOOL _loading;
    Favorite *_favorite;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;

- (void)configBookmarkButton;
- (void)bookmarkButtonTapped:(id)sender;
- (void)configureView;

@end

@implementation DetailViewController
@synthesize tableView = _tableView;

@synthesize detailItem = _detailItem;

- (void)bookmarkButtonTapped:(id)sender {
    UIButton *button = (UIButton *)sender;
    UIImage *image;
    if ([_favorite doesExist]) {
        [_favorite delete];
        image = [UIImage imageNamed:@"favorite"];
    } else {
        [_favorite save];
        image = [UIImage imageNamed:@"unfavorite"];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kFavoritesShouldReloadNotification object:nil];
    [button setImage:image forState:UIControlStateNormal];
    _favorite = [[Favorite alloc] initWithGemName:self.detailItem.name];
}

- (void)configBookmarkButton {
    _favorite = [[Favorite alloc] initWithGemName:self.detailItem.name];
    UIButton *favoriteButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 32, 29)];
    [favoriteButton addTarget:self action:@selector(bookmarkButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    UIImage *image = [UIImage imageNamed:([_favorite doesExist] ? @"unfavorite" : @"favorite")];
    [favoriteButton setImage:image forState:UIControlStateNormal];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:favoriteButton];
    self.navigationItem.rightBarButtonItem = item;
}

- (void)configureView {
    self.title = self.detailItem.name;

    _loading = !self.detailItem.fullyLoaded;
    if (_loading) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.labelText = @"Loading...";
        [[RubyGemsAPIManager sharedManager] loadByGemName:self.detailItem.name
                                                 progress:^(CGFloat p) {
                                                     hud.progress = p;
                                                 }
                                               completion:^(id json) {
                                                   self.detailItem = [GemEntry entryFromJSON:json];
                                                   _loading = NO;
                                                   [self.tableView reloadData];
                                                   [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                                               }
                                                  failure:^(NSError *error) {
                                                      // TODO
                                                      [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                                                  }];
    }

    [self performSelector:@selector(configBookmarkButton) withObject:nil afterDelay:0.01];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil] setTintColor:kTintColor];

    [self configureView];
}

- (void)viewDidUnload {
    [self setTableView:nil];
    [super viewDidUnload];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _loading ? 0 : 6;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return nil;
            break;
        case 1:
            return @"Authors";
            break;
        case 2:
            return @"Downloads";
            break;
        case 3:
            return @"Links";
            break;
        case 4:
            return @"Development Dependencies";
            break;
        case 5:
            return @"Runtime Dependencies";
            break;
        default:
            return nil;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 2;
            break;
        case 1:
            return self.detailItem.authors.count;
            break;
        case 2:
            return 2;
            break;
        case 3:
            return MAX(self.detailItem.links.count, 1);
            break;
        case 4:
            return MAX(self.detailItem.developmentDepencencies.count, 1);
            break;
        case 5:
            return MAX(self.detailItem.runtimeDepencencies.count, 1);
            break;
        default:
            return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row == 1) {
        NSString *info = self.detailItem.info;
        CGSize size = [info sizeWithFont:[UIFont systemFontOfSize:13]
                       constrainedToSize:CGSizeMake(300, 360)
                           lineBreakMode:UILineBreakModeTailTruncation];
        return MAX(68, size.height + 10);
    }
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;

    switch (indexPath.section) {
        case 0:
            if (indexPath.row == 0) {
                cell = [tableView dequeueReusableCellWithIdentifier:@"SubtitleCell"];
                cell.textLabel.text = self.detailItem.name;
                cell.detailTextLabel.text = self.detailItem.version;
            } else {
                cell = [tableView dequeueReusableCellWithIdentifier:@"GemInfoCell"];
                cell.textLabel.text = self.detailItem.info;
            }
            break;
        case 1:
            cell = [tableView dequeueReusableCellWithIdentifier:@"DetailCell"];
            cell.textLabel.text = [self.detailItem.authors objectAtIndex:indexPath.row];
            break;
        case 2:
            cell = [tableView dequeueReusableCellWithIdentifier:@"SubtitleCell"];
            if (indexPath.row == 0) {
                NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
                numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
                cell.textLabel.text = [numberFormatter stringFromNumber:self.detailItem.versionDownloads];
                cell.detailTextLabel.text = @"This Version";
            } else {
                NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
                numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
                cell.textLabel.text = [numberFormatter stringFromNumber:self.detailItem.downloads];
                cell.detailTextLabel.text = @"Total";
            }
            break;
        case 3:
            if (self.detailItem.links.count == 0) {
                cell = [tableView dequeueReusableCellWithIdentifier:@"EmptyCell"];
            } else {
                cell = [tableView dequeueReusableCellWithIdentifier:@"LinksCell"];
                NSArray *link = [self.detailItem.links objectAtIndex:indexPath.row];
                cell.textLabel.text = [link objectAtIndex:0];
            }
            break;
        case 4:
            if (self.detailItem.developmentDepencencies.count > 0) {
                cell = [tableView dequeueReusableCellWithIdentifier:@"DepencenciesCell"];
                NSDictionary *dep = [self.detailItem.developmentDepencencies objectAtIndex:indexPath.row];
                cell.textLabel.text = [dep objectForKey:@"name"];
                cell.detailTextLabel.text = [dep objectForKey:@"requirements"];
            } else {
                cell = [tableView dequeueReusableCellWithIdentifier:@"EmptyCell"];
            }
            break;
        case 5:
            if (self.detailItem.runtimeDepencencies.count > 0) {
                cell = [tableView dequeueReusableCellWithIdentifier:@"DepencenciesCell"];
                NSDictionary *dep = [self.detailItem.runtimeDepencencies objectAtIndex:indexPath.row];
                cell.textLabel.text = [dep objectForKey:@"name"];
                cell.detailTextLabel.text = [dep objectForKey:@"requirements"];
            } else {
                cell = [tableView dequeueReusableCellWithIdentifier:@"EmptyCell"];
            }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 3) {
        NSArray *link = [self.detailItem.links objectAtIndex:indexPath.row];
        SVWebViewController *browser = [[SVWebViewController alloc] initWithAddress:[link objectAtIndex:1]];
        browser.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:browser animated:YES];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showDependency"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSDictionary *dep = indexPath.section == 4 ?
            [self.detailItem.developmentDepencencies objectAtIndex:indexPath.row] :
            [self.detailItem.runtimeDepencencies objectAtIndex:indexPath.row];
        GemEntry *entry = [[GemEntry alloc] init];
        entry.name = [dep objectForKey:@"name"];
        entry.fullyLoaded = NO;
        [[segue destinationViewController] setDetailItem:entry];
    }
}

@end
