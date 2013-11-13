//
//  NSMutableArray+CNResultSorting.m
//  Frayze
//
//  Created by CJNevin on 14/11/2013.
//  Copyright (c) 2013 CJNevin. All rights reserved.
//

#import "NSMutableArray+CNResultSorting.h"

@implementation NSMutableArray (CNResultSorting)

- (void)sortByKey:(NSString *)key
{
    [self sortUsingComparator:^NSComparisonResult(NSDictionary* obj1, NSDictionary* obj2) {
        return [obj1[key] compare:obj2[key] options:NSBackwardsSearch];
    }];
}

- (void)sortByLengthOfKey:(NSString *)key
{
    [self sortUsingComparator:^NSComparisonResult(NSDictionary* obj1, NSDictionary* obj2) {
        NSNumber *num1 = [NSNumber numberWithUnsignedInteger:[obj1[key] length]];
        NSNumber *num2 = [NSNumber numberWithUnsignedInteger:[obj2[key] length]];
        return [num1 compare:num2];
    }];
}

@end
