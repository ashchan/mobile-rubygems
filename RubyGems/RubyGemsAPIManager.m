//
//  RubyGemsAPIManager.m
//  RubyGems
//
//  Created by James Chen on 10/7/12.
//  Copyright (c) 2012 ashchan.com. All rights reserved.
//

#import "RubyGemsAPIManager.h"
#import "JSONKit.h"

static NSString *const kRubyGemsAPIEndpoint = @"https://rubygems.org/api/v1";

@interface RubyGemsAPIManager ()

- (NSURL *)URLForPath:(NSString *)path;

@end

@implementation RubyGemsAPIManager

+ (RubyGemsAPIManager *)sharedManager {
    static RubyGemsAPIManager *_sharedManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self.class alloc] init];
    });
    return _sharedManager;
}

- (NSURL *)URLForPath:(NSString *)path {
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", kRubyGemsAPIEndpoint, path]];
}

- (void)loadCategory:(GemsCategory)category progress:(void (^)(CGFloat))progress completion:(void (^)(NSArray *))completion failure:(void (^)(NSError *))failure {
    NSString *path;
    switch (category) {
        case GemsCategoryUpdated:
            path = @"/activity/just_updated.json";
            break;
        case GemsCategoryNew:
            path = @"/activity/latest.json";
            break;
        case GemsCategoryTop:
            path = @"/downloads/all.json";
            break;
    }

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSData *responseData = [NSData dataWithContentsOfURL:[self URLForPath:path]];
        __block id result = [responseData objectFromJSONData];
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([result isKindOfClass:[NSArray class]]) {
                completion(result);
            } else {
                NSDictionary *dic = (NSDictionary *)result;
                completion([dic objectForKey:@"gems"]);
            }
        });
    });
}

- (void)loadByGemName:(NSString *)name progress:(void (^)(CGFloat))progress completion:(void (^)(id))completion failure:(void (^)(NSError *))failure {
    NSString *path = [NSString stringWithFormat:@"/gems/%@.json", name];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSData *responseData = [NSData dataWithContentsOfURL:[self URLForPath:path]];
        __block id result = [responseData objectFromJSONData];
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(result);
        });
    });
}

- (void)searchString:(NSString *)string progress:(void (^)(CGFloat))progress completion:(void (^)(NSArray *))completion failure:(void (^)(NSError *))failure {
    NSString *path = [NSString stringWithFormat:@"/search.json?query=%@", string];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSData *responseData = [NSData dataWithContentsOfURL:[self URLForPath:path]];
        __block id result = [responseData objectFromJSONData];
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([result isKindOfClass:[NSArray class]]) {
                completion(result);
            } else {
                NSDictionary *dic = (NSDictionary *)result;
                completion([dic objectForKey:@"gems"]);
            }
        });
    });
}

@end
