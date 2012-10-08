//
//  RubyGemsAPIManager.h
//  RubyGems
//
//  Created by James Chen on 10/7/12.
//  Copyright (c) 2012 ashchan.com. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    GemsCategoryUpdated     = 0,
    GemsCategoryNew         = 1,
    GemsCategoryTop         = 2
} GemsCategory;


@interface RubyGemsAPIManager : NSObject

+ (RubyGemsAPIManager *)sharedManager;

- (void)loadCategory:(GemsCategory)category progress:(void (^)(CGFloat))progress completion:(void (^)(NSArray *))completion failure:(void (^)(NSError *))failure;
- (void)loadByGemName:(NSString *)name progress:(void (^)(CGFloat))progress completion:(void (^)(id))completion failure:(void (^)(NSError *))failure;
- (void)searchString:(NSString *)string progress:(void (^)(CGFloat))progress completion:(void (^)(NSArray *))completion failure:(void (^)(NSError *))failure;

@end
