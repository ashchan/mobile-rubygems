//
//  GemEntry.m
//  RubyGems
//
//  Created by James Chen on 10/7/12.
//  Copyright (c) 2012 ashchan.com. All rights reserved.
//

#import "GemEntry.h"

@interface GemEntry ()

+ (NSDictionary *)linksMap;

@end

@implementation GemEntry

+ (NSDictionary *)linksMap {
    static NSDictionary *map;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        map = [[NSDictionary alloc] initWithObjectsAndKeys:
               @"Homepage",     @"homepage_uri",
               @"Project",      @"project_uri",
               @"Source Code",  @"source_code_uri",
               @"Wiki",         @"wiki_uri",
               @"Documentation",@"documentation_uri",
               @"Mailing List", @"mailing_list_uri",
               @"Bug Tracker",  @"bug_tracker_uri",
               nil];
    });
    return map;
}

+ (GemEntry *)entryFromJSON:(id)json {
    GemEntry *entry = [[self.class alloc] init];
    NSDictionary *data = [json isKindOfClass:[NSArray class]] ? [(NSArray *)json objectAtIndex:0] : json;
    entry.name = [data objectForKey:@"name"];
    if (entry.name) {
        entry.fullyLoaded = YES;
        entry.version = [data objectForKey:@"version"];
    } else {
        entry.fullyLoaded = NO;
        entry.version = [data objectForKey:@"number"];
        entry.name = [(NSString *)[data objectForKey:@"full_name"] stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"-%@", entry.version]
                                                                                             withString:@""];
    }

    entry.info = [data objectForKey:@"info"];
    entry.authors = [[data objectForKey:@"authors"] componentsSeparatedByString:@", "];
    entry.downloads = [data objectForKey:@"downloads"];
    entry.versionDownloads = [data objectForKey:@"version_downloads"];
    entry.developmentDepencencies = [[data objectForKey:@"dependencies"] objectForKey:@"development"];
    entry.runtimeDepencencies = [[data objectForKey:@"dependencies"] objectForKey:@"runtime"];

    NSMutableArray *links = [[NSMutableArray alloc] init];
    for (NSString *key in [self.class linksMap].allKeys) {
        if ([data objectForKey:key] != [NSNull null]) {
            [links addObject:[[NSArray alloc] initWithObjects:[[self.class linksMap] objectForKey:key], [data objectForKey:key], nil]];
        }
    }
    entry.links = links;

    return entry;
}

@end
