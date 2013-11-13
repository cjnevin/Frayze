//
//  NSMutableArray+CNResultSorting.h
//  Frayze
//
//  Created by CJNevin on 14/11/2013.
//  Copyright (c) 2013 CJNevin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableArray (CNResultSorting)

- (void)sortByLengthOfKey:(NSString*)key;
- (void)sortByKey:(NSString*)key;

@end
