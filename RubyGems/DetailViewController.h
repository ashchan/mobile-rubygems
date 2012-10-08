//
//  DetailViewController.h
//  RubyGems
//
//  Created by James Chen on 10/7/12.
//  Copyright (c) 2012 ashchan.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GemEntry;

@interface DetailViewController : UIViewController

@property (strong, nonatomic) GemEntry *detailItem;

@end
