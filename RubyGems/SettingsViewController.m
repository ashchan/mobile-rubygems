//
//  SettingsViewController.m
//  RubyGems
//
//  Created by James Chen on 10/7/12.
//  Copyright (c) 2012 ashchan.com. All rights reserved.
//

#import "SettingsViewController.h"
#import "SVWebViewController.h"

@interface SettingsViewController ()

@property (strong, nonatomic) IBOutlet UILabel *appInfo;

@end

NSString *const kGithubAddress = @"https://github.com/ashchan/mobile-rubygems";

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    self.appInfo.text = [NSString stringWithFormat:@"%@ v%@", kAppName, version];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    SVWebViewController *browser = [[SVWebViewController alloc] initWithAddress:kGithubAddress];
    browser.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:browser animated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
}

- (void)viewDidUnload {
    [self setAppInfo:nil];
    [self setAppInfo:nil];
    [super viewDidUnload];
}
@end