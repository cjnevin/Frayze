//
//  NSArray+NumberComparison.m
//  Stuff
//
//  Created by CJNevin on 31/10/2013.
//  Copyright (c) 2013 CJNevin. All rights reserved.
//

#import "NSArray+NumberComparison.h"

@implementation NSArray (NumberComparison)

- (BOOL)isNumberArraySame
{
    NSNumber *num = nil;
    for (NSNumber *n in self) {
        if (num) {
            if (![n isEqualToNumber:num]) {
                return NO;
            }
        } else {
            num = n;
        }
    }
    return YES;
}

- (BOOL)isNumberArrayConsecutive
{
    NSInteger lastn = 0;
    for (NSNumber *n in [self sortedArrayUsingSelector:@selector(compare:)]) {
        if (lastn == 0 || lastn == n.integerValue - 1) {
            lastn = n.integerValue;
        } else {
            return NO;
        }
    }
    return lastn > 0;
}
@end
