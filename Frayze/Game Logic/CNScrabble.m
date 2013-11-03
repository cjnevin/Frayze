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

/*
 4 blank tiles (scoring 0 points)
 1 point: E ×24, A ×16, O ×15, T ×15, I ×13, N ×13, R ×13, S ×10, L ×7, U ×7
 2 points: D ×8, G ×5
 3 points: C ×6, M ×6, B ×4, P ×4
 4 points: H ×5, F ×4, W ×4, Y ×4, V ×3
 5 points: K ×2
 8 points: J ×2, X ×2
 10 points: Q ×2, Z ×2
 */

+ (NSDictionary*)letterDistribution
{
    static NSInteger oldDistribution = -1;
    NSInteger newDistribution = [[SettingsDataSource sharedInstance] countIndex];
    if (oldDistribution == -1) oldDistribution = newDistribution;
    static NSDictionary *values = nil;
    if (!values || oldDistribution != newDistribution) {
        if (newDistribution == 1) {
            // Super, 200 tiles
            values = @{@"A":@16, @"B":@4, @"C":@6, @"D":@8, @"E":@24,
                       @"F":@4, @"G":@5, @"H":@5, @"I":@13, @"J":@2,
                       @"K":@2, @"L":@7, @"M":@6, @"N":@13, @"O":@15,
                       @"P":@4, @"Q":@2, @"R":@13, @"S":@10, @"T":@15,
                       @"U":@7, @"V":@3, @"W":@4, @"X":@2, @"Y":@4,
                       @"Z":@2, @"?":@4};
        } else {
            // Classic, 100 tiles
            values = @{@"A":@9, @"B":@2, @"C":@2, @"D":@4, @"E":@12,
                       @"F":@2, @"G":@3, @"H":@2, @"I":@9, @"J":@1,
                       @"K":@1, @"L":@4, @"M":@2, @"N":@6, @"O":@8,
                       @"P":@2, @"Q":@1, @"R":@6, @"S":@4, @"T":@6,
                       @"U":@4, @"V":@2, @"W":@2, @"X":@1, @"Y":@2,
                       @"Z":@1, @"?":@2};
        }
        oldDistribution = newDistribution;
    }
    return values;
}

+ (NSDictionary*)letterValues
{
    static NSDictionary *values = nil;
    if (!values) {
        values = @{@"AEILNORSTU": @1,
                   @"DG": @2,
                   @"BCMP": @3,
                   @"FHVWY": @4,
                   @"K": @5,
                   @"J": @8,
                   @"QXZ": @10};
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
    NSInteger size = [[SettingsDataSource sharedInstance] gameTypeIndex];
    if (size == 1) {
        return 15;
    } else {
        return 15;
    }
}

- (void)applyTheme
{
    NSUInteger dim = [self boardSize];
    for (NSInteger y = 1; y <= dim; y++) {
        for (NSInteger x = 1; x <= dim; x++) {
            
        }
    }
}

- (void)resetCheckeredBoard
{
    droppedTiles = [NSMutableSet set];
    board = [NSMutableArray array];
    NSUInteger dim = [self boardSize];
    for (NSInteger y = 1; y <= dim; y++) {
        NSMutableArray *row = [NSMutableArray arrayWithCapacity:dim];
        for (NSInteger x = 1; x <= dim; x++) {
            SquareType sqType = SQ_NORMAL;
            if ((y == 2 && x == 2) || (y == 14 && x == 2) || (x == 14 && y == 2) || (x == 14 && y == 14)) {
                sqType = SQ_TRIPLE_WORD;
            }
            else if (y % 2 == 0 && x % 2 == 0) {
                sqType = SQ_DOUBLE_LETTER;
                if (y == 8 && x == 8) {
                    sqType = SQ_CENTER;
                } else if ((y == 6 && x == 6) || (y == 10 && x == 6) || (x == 10 && y == 6) || (x == 10 && y == 10)) {
                    sqType = SQ_TRIPLE_LETTER;
                } else if (y % 4 == 0 && x % 4 == 0) {
                    sqType = SQ_DOUBLE_WORD;
                }
            }
            [row addObject:[NSNumber numberWithInteger:sqType]];
        }
        [board addObject:row];
    }
    NSLog(@"Total Squares: %d", dim * dim);
    [delegate boardReset];
}

- (void)resetBoard
{
    if ([[SettingsDataSource sharedInstance] gameTypeIndex] == 1) {
        [self resetCheckeredBoard];
        return;
    }
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
    [drawnTiles makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [playedTiles makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [droppedTiles makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [drawnTiles removeAllObjects];
    [playedTiles removeAllObjects];
    [droppedTiles removeAllObjects];
    [words removeAllObjects];
    [delegate tilesReset];
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
            wordMultiplier *= [self wordMultiplierForSquare:tile.coord];
        }
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
    SquareType type = [board[y-1][x-1] integerValue];
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
    SquareType type = [board[y-1][x-1] integerValue];
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
            NSArray *wordTiles = [self getTilesAtX:tile.coord.x inArray:adjArray];
            NSUInteger wordScore = 0;
            if (wordTiles.count > 1) {
                wordScore = [self wordValueForTiles:wordTiles dropped:tiles];
                if (!auditing) {
                    NSLog(@"WordX = %@, %d", [self getWord:wordTiles], wordScore);
                    [self.delegate highlightTiles:wordTiles];
                }
                score += wordScore;
            }
            // Calculate horizontal words for each letter
            for (CNScrabbleTile *dTile in droppedTiles) {
                wordTiles = [self getTilesAtY:dTile.coord.y inArray:adjArray];
                if (wordTiles.count > 1) {
                    wordScore = [self wordValueForTiles:wordTiles dropped:tiles];
                    if (!auditing) {
                        NSLog(@"WordY = %@, %d", [self getWord:wordTiles], wordScore);
                        [self.delegate highlightTiles:wordTiles];
                    }
                    score += wordScore;
                }
            }
        } else {
            NSArray *wordTiles = [self getTilesAtY:tile.coord.y inArray:adjArray];
            NSUInteger wordScore = 0;
            if (wordTiles.count > 1) {
                wordScore = [self wordValueForTiles:wordTiles dropped:tiles];
                if (!auditing) {
                    NSLog(@"WordY = %@, %d", [self getWord:wordTiles], wordScore);
                    [self.delegate highlightTiles:wordTiles];
                }
                score += wordScore;
            }
            // Calculate vertical words for each letter
            for (CNScrabbleTile *dTile in droppedTiles) {
                wordTiles = [self getTilesAtX:dTile.coord.x inArray:adjArray];
                if (wordTiles.count > 1) {
                    wordScore = [self wordValueForTiles:wordTiles dropped:tiles];
                    if (!auditing) {
                        NSLog(@"WordX = %@, %d", [self getWord:wordTiles], wordScore);
                        [self.delegate highlightTiles:wordTiles];
                    }
                    score += wordScore;
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
