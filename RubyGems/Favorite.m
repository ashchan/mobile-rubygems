//
//  Favorite.m
//  RubyGems
//
//  Created by James Chen on 10/7/12.
//  Copyright (c) 2012 ashchan.com. All rights reserved.
//

#import "Favorite.h"

NSString *const kFavoriteModelName      = @"Favorite";
NSString *const kCloudKeyPrefix         = @"fav-";

@interface Favorite () {
}

- (NSMutableArray *)allFavorites;
- (NSDictionary *)raw;
- (NSString *)storeKey;

@end

@implementation Favorite

@synthesize gemName;

- (id)initWithGemName:(NSString *)aGemName {
    if (self = [super init]) {
        gemName = aGemName;
    }
    return self;
}

+ (NSArray *)favorites {
    NSMutableArray *results = [[NSMutableArray alloc] init];
    NSUbiquitousKeyValueStore *store = [NSUbiquitousKeyValueStore defaultStore];
    for (NSString *key in [store dictionaryRepresentation].allKeys) {
        if ([key hasPrefix:kCloudKeyPrefix]) {
            [results addObject:[store dictionaryForKey:key]];
        }
    }

    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"createdAt" ascending:NO];
    [results sortUsingDescriptors:[[NSArray alloc] initWithObjects:sortDescriptor, nil]];
    return results;
}

+ (void)sync {
    [[NSUbiquitousKeyValueStore defaultStore] synchronize];
}

+ (void)syncPush {
}

- (NSString *)storeKey {
    return [NSString stringWithFormat:@"%@%@", kCloudKeyPrefix, self.gemName];
}
                      
- (NSArray *)allFavorites {
    return [self.class favorites];
}

- (NSDictionary *)raw {
    NSUbiquitousKeyValueStore *store = [NSUbiquitousKeyValueStore defaultStore];
    NSString *key = [self storeKey];
    if ([[store dictionaryRepresentation].allKeys containsObject:key]) {
        return [store dictionaryForKey:key];
    }
    return nil;
}

- (BOOL)doesExist {
    return [self raw] != nil;
}

- (void)save {
    if (![self doesExist]) {
        NSDictionary *f = [[NSDictionary alloc] initWithObjectsAndKeys:self.gemName, @"name",
                           [NSDate date], @"createdAt", nil];
        [[NSUbiquitousKeyValueStore defaultStore] setDictionary:f forKey:[self storeKey]];
    }
}

- (void)delete {
    if ([self doesExist]) {
        [[NSUbiquitousKeyValueStore defaultStore] removeObjectForKey:[self storeKey]];
    }
}

@end
