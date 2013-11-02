//
//  CNScrabble.h
//  WordPlay
//
//  Created by CJNevin on 30/10/2013.
//  Copyright (c) 2013 CJNevin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CNScrabbleSquare.h"

@interface CNScrabble : NSObject

+ (NSDictionary*)letterValues;

- (NSArray*)board;
- (NSUInteger)boardSize;

- (NSArray*)draw:(NSInteger)amount;
- (void)resetTiles;
- (NSUInteger)tilesInRack;

@end
