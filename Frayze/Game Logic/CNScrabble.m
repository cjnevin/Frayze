//
//  CNScrabble.m
//  WordPlay
//
//  Created by CJNevin on 30/10/2013.
//  Copyright (c) 2013 CJNevin. All rights reserved.
//

#import "CNScrabble.h"
#import "CNScrabbleTile.h"
#import "NSArray+NumberComparison.h"
#import <objc/message.h>

#define DOUBLE_UP false

@interface CNScrabble()

@end

@implementation CNScrabble

@synthesize words;
@synthesize board;
@synthesize delegate;
@synthesize drawnTiles;
@synthesize droppedTiles;
@synthesize bagTiles;
@synthesize playedTiles;
@synthesize draggedTile;

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
                   @"dg": @2,
                   @"bcmp": @3,
                   @"fhvwy": @4,
                   @"k": @5,
                   @"j": @8,
                   @"qxz": @10};
    }
    return values;
}

- (id)initWithDelegate:(id<CNScrabbleDelegate>)_delegate
{
    self = [super init];
    if (self) {
        delegate = _delegate;
    }
    return self;
}

- (void)resetGame
{
    [self resetBoard];
    [self resetTiles];
    [self drawTiles];
}

#pragma mark - Board

- (NSUInteger)boardSize
{
#if DOUBLE_UP
    return 25;
#endif
    return 15;
}

- (void)resetBoard
{
    droppedTiles = [NSMutableSet set];
    board = [NSMutableArray array];
    NSUInteger dim = [self boardSize];
    NSInteger mid = (dim + 1) / 2;
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
    [delegate boardReset];
}

#pragma mark - Tiles

- (NSArray*)draw:(NSInteger)amount
{
    NSMutableArray *drawn = [NSMutableArray array];
    for (NSInteger x = 0; x < amount; x++) {
        if (bagTiles.count > 0) {
            NSInteger t = arc4random() % bagTiles.count;
            [drawn addObject:bagTiles[t]];
        }
    }
    return drawn;
}

- (void)drawTiles
{
    if (!drawnTiles) drawnTiles = [NSMutableArray array];
    NSUInteger amount = [self tilesInRack] - [drawnTiles count];
    NSArray *newTiles = [self draw:amount];
    for (NSString *tile in newTiles) {
        CNScrabbleTile *newTile = [[CNScrabbleTile alloc] initWithFrame:CGRectMake(0, 0, 40, 40) letter:tile];
        [drawnTiles addObject:newTile];
        [delegate drewTile:newTile];
    }
    [delegate drewTiles];
}

- (BOOL)isEmptyAtPoint:(CGPoint)point
{
    BOOL filled = NO;
    // Check if tile is already in this square
    for (CNScrabbleTile *tile in droppedTiles) {
        if (tile != draggedTile) {
            if (CGPointEqualToPoint(tile.center, point)) {
                filled = YES;
                break;
            }
        }
    }
    // Check if word is already in this square
    if (!filled) {
        for (NSDictionary *word in words) {
            CGRect rect = CGRectFromString(word[@"rect"]);
            if (CGRectContainsPoint(rect, point)) {
                filled = YES;
                break;
            }
        }
    }
    return !filled;
}

- (CGRect)rectForTiles:(NSArray*)tiles
{
    CGFloat miny = CGFLOAT_MAX, minx = CGFLOAT_MAX;
    CGFloat maxx = 0, maxy = 0;
    for (CNScrabbleTile *tile in tiles) {
        maxx = MAX(maxx, CGRectGetMaxX(tile.frame));
        maxy = MAX(maxy, CGRectGetMaxY(tile.frame));
        minx = MIN(minx, CGRectGetMinX(tile.frame));
        miny = MIN(miny, CGRectGetMinY(tile.frame));
    }
    return CGRectMake(minx, miny, maxx - minx, maxy - miny);
}

- (void)resetTiles
{
    bagTiles = [NSMutableArray array];
    NSDictionary *distribution = [[self class] letterDistribution];
    for (NSString *letter in [distribution allKeys]) {
        for (NSInteger x = 0; x < [distribution[letter] integerValue]; x++) {
            [bagTiles addObject:letter];
        }
    }
    NSLog(@"Total Tiles: %d", bagTiles.count);
}

- (NSUInteger)tilesInRack
{
    return 7;
}

- (BOOL)tilesAreHorizontallyArranged:(NSArray*)tiles
{
    CGPoint lastPoint = CGPointZero;
    for (CNScrabbleTile *tile in tiles) {
        if (!CGPointEqualToPoint(CGPointZero, lastPoint)) {
            if (tile.coord.y != lastPoint.y) {
                return NO;
            }
        }
        lastPoint = tile.coord;
    }
    return YES;
}

- (BOOL)tilesAreVerticallyArranged:(NSArray*)tiles
{
    CGPoint lastPoint = CGPointZero;
    for (CNScrabbleTile *tile in tiles) {
        if (!CGPointEqualToPoint(CGPointZero, lastPoint)) {
            if (tile.coord.x != lastPoint.x) {
                return NO;
            }
        }
        lastPoint = tile.coord;
    }
    return YES;
}

- (NSInteger)wordValueForTiles:(NSArray*)tiles dropped:(NSArray*)dropped
{
    NSInteger wordValue = 0;
    NSInteger wordMultiplier = 1;
    for (CNScrabbleTile *tile in tiles) {
        NSInteger letterMultiplier = 1;
        if ([dropped containsObject:tile]) {
            letterMultiplier = [self letterMultiplierForSquare:tile.coord];
        }
        wordMultiplier *= [self wordMultiplierForSquare:tile.coord];
        wordValue += (letterMultiplier * tile.letterValue);
    }
    wordValue *= wordMultiplier;
    return wordValue;
}

- (NSUInteger)matchingObjectsInArray:(NSArray*)a withArray:(NSArray*)b
{
    NSUInteger match = 0;
    for (NSObject *_a in a) {
        if ([b containsObject:_a]) match++;
    }
    return match;
}

- (CNScrabbleTile*)getTileAtX:(NSInteger)x y:(NSInteger)y
{
    NSUInteger s = [self boardSize];
    if (x > 0 && x <= s && y > 0 && y <= s) {
        for (CNScrabbleTile *tile in playedTiles) {
            if (CGPointEqualToPoint(CGPointMake(x, y), tile.coord)) {
                return tile;
            }
        }
        for (CNScrabbleTile *tile in droppedTiles) {
            if (CGPointEqualToPoint(CGPointMake(x, y), tile.coord)) {
                return tile;
            }
        }
    }
    return nil;
}

- (CNScrabbleTile*)getTileAtX:(NSInteger)x y:(NSInteger)y inArray:(NSArray*)array
{
    NSUInteger s = [self boardSize];
    if (x > 0 && x <= s && y > 0 && y <= s) {
        for (CNScrabbleTile *tile in array) {
            if (CGPointEqualToPoint(CGPointMake(x, y), tile.coord)) {
                return tile;
            }
        }
    }
    return nil;
}

- (NSArray*)getTilesAtY:(NSInteger)y inArray:(NSArray*)arr
{
    NSMutableArray *array = [NSMutableArray array];
    for (CNScrabbleTile *tile in arr) {
        if (tile.coord.y == y) [array addObject:tile];
    }
    return [array sortedArrayUsingComparator:^NSComparisonResult(CNScrabbleTile* obj1, CNScrabbleTile* obj2) {
        return [obj1.getX compare:obj2.getX];
    }];
}

- (NSArray*)getTilesAtX:(NSInteger)x inArray:(NSArray*)arr
{
    NSMutableArray *array = [NSMutableArray array];
    for (CNScrabbleTile *tile in arr) {
        if (tile.coord.x == x) [array addObject:tile];
    }
    return [array sortedArrayUsingComparator:^NSComparisonResult(CNScrabbleTile* obj1, CNScrabbleTile* obj2) {
        return [obj1.getY compare:obj2.getY];
    }];
}

- (void)getAdjacentTiles:(NSMutableSet**)target
                       x:(NSUInteger)x
                       y:(NSUInteger)y
                       v:(BOOL)v
                       h:(BOOL)h
                original:(CNScrabbleTile*)original
{
    CNScrabbleTile *tile = [self getTileAtX:x y:y];
    if (tile != nil && (tile == original || ![*target containsObject:tile])) {
        [*target addObject:tile];
        if (h) {
            [self getAdjacentTiles:target x:x + 1 y:y v:v h:h original:original];
            [self getAdjacentTiles:target x:x - 1 y:y v:v h:h original:original];
        }
        if (v) {
            [self getAdjacentTiles:target x:x y:y + 1 v:v h:h original:original];
            [self getAdjacentTiles:target x:x y:y - 1 v:v h:h original:original];
        }
    }
}

- (void)printTilesInArray:(NSArray*)tiles
{
    // Print results
    NSUInteger dim = [self boardSize];
    for (NSInteger y = 1; y <= dim; y++) {
        NSMutableString *line = [NSMutableString string];
        for (NSInteger x = 1; x <= dim; x++) {
            CGPoint pt = CGPointMake(x, y);
            BOOL found = NO;
            for (CNScrabbleTile *tile in tiles) {
                if (CGPointEqualToPoint(pt, tile.coord)) {
                    found = YES;
                    [line appendString:tile.letterLabel.text];
                    break;
                }
            }
            if (!found) {
                [line appendString:@" "];
            }
        }
        NSLog(@"%@", line);
    }
}

- (NSString*)getWord:(NSArray*)tiles
{
    NSMutableString *buffer = [NSMutableString string];
    for (CNScrabbleTile* tile in tiles) {
        [buffer appendString:tile.letterLabel.text];
    }
    return buffer;
}

#pragma mark - Score

- (NSInteger)letterMultiplierForSquare:(CGPoint)coord
{
    NSInteger multiplier = 1;
    NSInteger x = coord.x, y = coord.y;
    SquareType type = [board[y][x] integerValue];
    if (type == SQ_TRIPLE_LETTER) {
        multiplier = 3;
    } else if (type == SQ_DOUBLE_LETTER) {
        multiplier = 2;
    }
    return multiplier;
}

- (NSInteger)wordMultiplierForSquare:(CGPoint)coord
{
    NSInteger multiplier = 1;
    NSInteger x = coord.x, y = coord.y;
    SquareType type = [board[y][x] integerValue];
    if (type == SQ_TRIPLE_WORD) {
        multiplier = 3;
    } else if (type == SQ_DOUBLE_WORD || type == SQ_CENTER) {
        multiplier = 2;
    }
    return multiplier;
}

- (NSInteger)calculateScore:(BOOL)auditing
{
    NSInteger score = 0;
    // Ensure that tiles are in same row or column
    NSArray *tiles = [droppedTiles allObjects];
    BOOL horizontal = [self tilesAreHorizontallyArranged:tiles];
    BOOL vertical = [self tilesAreVerticallyArranged:tiles];
    if (!horizontal && !vertical) {
        return 0;
    }
    // Determine tiles adjacent to dropped tiles
    NSMutableSet *adjacent = [NSMutableSet set];
    CNScrabbleTile *tile = [droppedTiles anyObject];
    [self getAdjacentTiles:&adjacent x:tile.coord.x y:tile.coord.y v:YES h:NO original:tile];
    [self getAdjacentTiles:&adjacent x:tile.coord.x y:tile.coord.y v:NO h:YES original:tile];
    
    // This set must include all dropped tiles, otherwise they aren't connected
    if ([self matchingObjectsInArray:[adjacent allObjects] withArray:[droppedTiles allObjects]] == [droppedTiles count]) {
        [adjacent removeAllObjects];
        // Ensure that there is a center tile
        NSInteger mid = ([self boardSize] + 1) / 2;
        CNScrabbleTile *midTile = [self getTileAtX:mid y:mid];
        if (!midTile) {
            // Tiles must intersect center of board
            NSLog(@"Tile must intersect center of the board.");
            return 0;
        }
        
        // Ensure that tiles intersect the center of the board
        for (CNScrabbleTile *dTile in droppedTiles) {
            [self getAdjacentTiles:&adjacent x:dTile.coord.x y:dTile.coord.y v:YES h:YES original:dTile];
        }
        midTile = [self getTileAtX:mid y:mid inArray:[adjacent allObjects]];
        if (!midTile) {
            // Tiles must intersect center of board
            NSLog(@"Tile must intersect with tiles that intersect with the center tile.");
            return 0;
        }
        
        // Remove all objects, so we can find the connected tiles
        [adjacent removeAllObjects];
        // Now collect all dropped tiles in both directions
        for (CNScrabbleTile *dTile in droppedTiles) {
            [self getAdjacentTiles:&adjacent x:dTile.coord.x y:dTile.coord.y v:YES h:NO original:dTile];
            [self getAdjacentTiles:&adjacent x:dTile.coord.x y:dTile.coord.y v:NO h:YES original:dTile];
        }
        // Calculate score for word
        NSArray *adjArray = [adjacent allObjects];
        if (vertical) {
            NSArray *word = [self getTilesAtX:tile.coord.x inArray:adjArray];
            if (!auditing) {
                NSLog(@"WordX = %@", [self getWord:word]);
                [self.delegate highlightTiles:word];
            }
            score += [self wordValueForTiles:word dropped:tiles];
            // Calculate horizontal words for each letter
            for (CNScrabbleTile *dTile in droppedTiles) {
                word = [self getTilesAtY:dTile.coord.y inArray:adjArray];
                if (word.count > 1) {
                    if (!auditing) {
                        NSLog(@"WordY = %@", [self getWord:word]);
                        [self.delegate highlightTiles:word];
                    }
                    score += [self wordValueForTiles:word dropped:tiles];
                }
            }
        } else {
            NSArray *word = [self getTilesAtY:tile.coord.y inArray:adjArray];
            if (!auditing) {
                NSLog(@"WordY = %@", [self getWord:word]);
                [self.delegate highlightTiles:word];
            }
            score += [self wordValueForTiles:word dropped:tiles];
            // Calculate vertical words for each letter
            for (CNScrabbleTile *dTile in droppedTiles) {
                word = [self getTilesAtX:dTile.coord.x inArray:adjArray];
                if (word.count > 1) {
                    if (!auditing) {
                        NSLog(@"WordX = %@", [self getWord:word]);
                        [self.delegate highlightTiles:word];
                    }
                    score += [self wordValueForTiles:word dropped:tiles];
                }
            }
        }
    }
    return score;
}

- (BOOL)canSubmit
{
    // Validate
    if (droppedTiles.count == 0 || [self calculateScore:YES] < 1) {
        return NO;
    }
    return YES;
}

- (void)submit
{
    // Store word
    CGRect rect = [self rectForTiles:[droppedTiles allObjects]];
    NSDictionary *word = @{@"rect": NSStringFromCGRect(rect), @"tiles": droppedTiles};
    if (!words) words = [NSMutableArray array];
    if (!playedTiles) playedTiles = [NSMutableArray array];
    [words addObject:word];
    [playedTiles addObjectsFromArray:[droppedTiles allObjects]];
    
    // Strip gestures
    for (CNScrabbleTile *tile in droppedTiles) {
        tile.gestureRecognizers = nil;
    }
    [droppedTiles removeAllObjects];
    
    // Replace tiles in rack
    [self drawTiles];
}

@end
