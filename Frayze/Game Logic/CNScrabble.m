//
//  CNScrabble.m
//  WordPlay
//
//  Created by CJNevin on 30/10/2013.
//  Copyright (c) 2013 CJNevin. All rights reserved.
//

#import "CNScrabble.h"

#define DOUBLE_UP false

@interface CNScrabble()
{
    NSMutableArray *tiles;
    NSMutableArray *board;
}
@end

@implementation CNScrabble

+ (NSDictionary*)letterDistribution
{
    static NSDictionary *values = nil;
    if (!values) {
        values = @{@"a":@9, @"b":@2, @"c":@2, @"d":@4, @"e":@12,
                   @"f":@2, @"g":@3, @"h":@2, @"i":@9, @"j":@1,
                   @"k":@1, @"l":@4, @"m":@2, @"n":@6, @"o":@8,
                   @"p":@2, @"q":@1, @"r":@6, @"s":@4, @"t":@6,
                   @"u":@4, @"v":@2, @"w":@2, @"x":@1, @"y":@2,
                   @"z":@1, @"?":@2};
    }
    return values;
}

+ (NSDictionary*)letterValues
{
    static NSDictionary *values = nil;
    if (!values) {
        values = @{@"aeilnorstu": @1,
                   @"dgm": @2,
                   @"bcp": @3,
                   @"fhvwy": @4,
                   @"k": @5,
                   @"j": @8,
                   @"qxz": @10};
    }
    return values;
}

- (id)init
{
    self = [super init];
    if (self) {
        [self resetBoard];
        [self resetTiles];
    }
    return self;
}

- (BOOL)is:(NSUInteger)a inItems:(NSUInteger*)items
{
    for (NSInteger i = 0; i < sizeof(items); i++) {
        if (a == items[i]) {
            return YES;
        }
    }
    return NO;
}

- (NSArray*)board
{
    return board;
}

- (NSUInteger)tilesInRack
{
    return 7;
}

- (NSUInteger)boardSize
{
#if DOUBLE_UP
    return 25;
#endif
    return 15;
}

- (void)resetBoard
{
    // TODO: Make this dynamic, so we can support all different sizes
    board = [NSMutableArray array];
    NSUInteger dim = [self boardSize];
    NSInteger mid = dim / 2 + 1;
    NSInteger qtr = mid / 2;
    NSInteger two = mid / 4;
    NSInteger six = two * 3;
    NSInteger sev = six + ((mid - six) * .5);
    NSInteger eig = dim / 5;
    for (NSInteger y = 1; y <= dim; y++) {
        NSMutableArray *row = [NSMutableArray arrayWithCapacity:dim];
        for (NSInteger x = 1; x <= dim; x++) {
            SquareType sqType = SQ_NORMAL;
            NSInteger nx = x;
            NSInteger ny = y;
            if (x != y) {
                nx = dim - x + 1;
                ny = dim - y + 1;
            }
            if (nx == y) {
                if (nx < 2 || nx == dim) {
                    sqType = SQ_TRIPLE_WORD;
                } else if (nx == mid) {
                    sqType = SQ_CENTER;
                } else {
                    sqType = SQ_DOUBLE_WORD;
                }
            }
            if (sqType == SQ_NORMAL || sqType == SQ_DOUBLE_WORD) {
                nx = dim - x + 1;
                ny = dim - y + 1;
                if (((x == six || nx == six) && (y == six || ny == six)) ||
                    ((x == six || nx == six) && (y == two || ny == two)) ||
                    ((x == two || nx == two) && (y == six || ny == six))) {
                    sqType = SQ_TRIPLE_LETTER;
                }
                else if (((x == 1 || nx == 1) && (y == mid || ny == mid)) ||
                         ((y == 1 || ny == 1) && (x == mid || nx == mid))) {
                    // Corners
                    sqType = SQ_TRIPLE_WORD;
                }
                else if (((x == qtr || nx == qtr) && (y == 1 || y == mid || y == dim)) ||
                         ((y == qtr || ny == qtr) && (x == 1 || x == mid || x == dim)) ||
                         ((x == sev || nx == sev) && (y == eig || y == sev || ny == eig || ny == sev)) ||
                         ((y == sev || ny == sev) && (x == eig || x == sev || nx == eig || nx == sev))) {
                    sqType = SQ_DOUBLE_LETTER;
                }
            }
            [row addObject:[NSNumber numberWithInteger:sqType]];
        }
        [board addObject:row];
    }
    NSLog(@"Total Squares: %d", dim * dim);
}

- (void)resetTiles
{
    tiles = [NSMutableArray array];
    NSDictionary *distribution = [[self class] letterDistribution];
    for (NSString *letter in [distribution allKeys]) {
        for (NSInteger x = 0; x < [distribution[letter] integerValue]; x++) {
            [tiles addObject:letter];
        }
    }
    NSLog(@"Total Tiles: %d", tiles.count);
}

- (NSArray*)draw:(NSInteger)amount
{
    NSMutableArray *drawn = [NSMutableArray array];
    for (NSInteger x = 0; x < amount; x++) {
        if (tiles.count > 0) {
            NSInteger t = arc4random() % tiles.count;
            [drawn addObject:tiles[t]];
        }
    }
    return drawn;
}

@end
