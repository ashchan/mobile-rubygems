//
//  GemEntry.h
//  RubyGems
//
//  Created by James Chen on 10/7/12.
//  Copyright (c) 2012 ashchan.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GemEntry : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *version;
@property (nonatomic, copy) NSString *info;
@property (nonatomic, strong) NSArray *authors;
@property (nonatomic, copy) NSNumber *downloads;
@property (nonatomic, copy) NSNumber *versionDownloads;
@property (nonatomic, strong) NSArray *developmentDepencencies;
@property (nonatomic, strong) NSArray *runtimeDepencencies;
@property (nonatomic, strong) NSArray *links;

@property (nonatomic) BOOL fullyLoaded;

+ (GemEntry *)entryFromJSON:(id)json;

@end
