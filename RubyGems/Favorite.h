//
//  Favorite.h
//  RubyGems
//
//  Created by James Chen on 10/7/12.
//  Copyright (c) 2012 ashchan.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Favorite : NSObject

@property (nonatomic, copy) NSString *gemName;

- (id)initWithGemName:(NSString *)gemName;
- (BOOL)doesExist;
- (void)delete;
- (void)save;
+ (NSArray *)favorites;
+ (void)syncPush;
+ (void)sync;

@end
