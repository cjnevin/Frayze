//
//  CNScrabble.h
//  Frayze
//
//  Created by CJNevin on 30/10/2013.
//  Copyright (c) 2013 CJNevin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CNScrabbleSquare.h"
#import "CNScrabbleDictionary.h"

#define HISTORY_WORDS_KEY @"HWK"
#define HISTORY_SCORE_KEY @"HSK"

typedef enum {
    VO_VALID = 1,
    VO_INVALID,
    VO_NOT_INLINE,
    VO_NOT_INTERSECTING_CENTER,
    VO_NOT_INTERSECTING_CENTER_BY_PROXY,
    VO_NOT_DEFINED,
} ValidityOptions;

@class CNScrabbleTile;

@protocol CNScrabbleDelegate <NSObject>

- (void)highlightTiles:(NSArray*)tiles;

- (void)boardReset;
- (void)tilesReset;

- (void)drewTile:(CNScrabbleTile*)tile;
- (void)drewTiles;

@end

@interface CNScrabble : NSObject

@property (nonatomic, assign) id<CNScrabbleDelegate> delegate;
@property (nonatomic, strong) NSMutableArray *words;
@property (nonatomic, strong) NSMutableArray *drawnTiles;
@property (nonatomic, strong) NSMutableSet *droppedTiles;
@property (nonatomic, strong) NSMutableArray *board;
@property (nonatomic, strong) NSMutableArray *bagTiles;
@property (nonatomic, strong) NSMutableArray *playedTiles;
@property (nonatomic, strong) NSMutableArray *playedHistory;
@property (nonatomic, strong) CNScrabbleDictionary *dictionary;
@property (nonatomic, strong) CNScrabbleTile *draggedTile;    // Tile being dragged

+ (NSDictionary*)letterValues;

- (id)initWithDelegate:(id<CNScrabbleDelegate>)_delegate;

// Board / Tiles
- (CNScrabbleTile*)getTileAtX:(NSInteger)x y:(NSInteger)y;
- (CGRect)rectForTiles:(NSArray*)tiles;
- (BOOL)isEmptyAtPoint:(CGPoint)point;
- (void)drawTiles;
- (void)resetGame;
- (NSUInteger)boardSize;
- (NSUInteger)tilesInRack;

// Score
- (void)submitWords:(NSMutableArray*)wordValues score:(NSUInteger)score;
- (void)verifyValidityWithCompletion:(void(^)(NSInteger score, ValidityOptions status, NSString *message, NSArray *wordTilesArray))completion;

@end
