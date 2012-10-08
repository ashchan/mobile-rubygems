//
//  NavigationBar.m
//  RubyGems
//
//  Created by James Chen on 10/7/12.
//  Copyright (c) 2012 ashchan.com. All rights reserved.
//

#import "NavigationBar.h"

@implementation NavigationBar

- (UIColor *)topLineColor {
    return [UIColor colorWithHex:0xFF1000];
}

- (UIColor *)gradientStartColor {
    return [UIColor colorWithHex:0xDD0000];
}

- (UIColor *)gradientEndColor {
    return [UIColor colorWithHex:0xAA0000];    
}

- (UIColor *)bottomLineColor {
    return [UIColor colorWithHex:0x990000];   
}

- (UIColor *)tintColor {
    return kTintColor;
}

- (CGFloat)roundedCornerRadius {
    return 5;
}

@end
