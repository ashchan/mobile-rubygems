//
//  MasterViewController.h
//  RubyGems
//
//  Created by James Chen on 10/7/12.
//  Copyright (c) 2012 ashchan.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RubyGemsAPIManager.h"

@class DetailViewController;

@interface MasterViewController : UIViewController

@property (strong, nonatomic) DetailViewController *detailViewController;
@property (nonatomic) GemsCategory gemsCategory;

@end
