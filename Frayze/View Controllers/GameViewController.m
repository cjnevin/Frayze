//
//  FirstViewController.m
//  WordPlay
//
//  Created by CJNevin on 30/10/2013.
//  Copyright (c) 2013 CJNevin. All rights reserved.
//

#import "GameViewController.h"
#import "UIScrollView+Directions.h"
#import "NSArray+NumberComparison.h"

@interface GameViewController ()
{
    UIScrollView *boardScroller;
    UIView *boardContainer;
    UIView *tileRack;
    UILabel *scoreLabel;
    UIButton *play;
    
    CNScrabble *scrabble;
    CNScrabbleTile *draggedTile;    // Tile being dragged
    NSMutableArray *drawnTiles;     // Tiles in rack
    NSMutableSet *droppedTiles;     // Tiles on board
}
@end

@implementation GameViewController

- (NSInteger)calculateScore
{
    NSInteger score = 0, multiplier = 1;
    NSArray *board = [scrabble board];
    NSMutableArray *xs = [NSMutableArray array], *ys = [NSMutableArray array];
    for (CNScrabbleTile *tile in droppedTiles) {
        NSInteger x = tile.coord.x, y = tile.coord.y;
        SquareType type = [board[y][x] integerValue];
        NSInteger val = [tile letterValue];
        if (type == SQ_DOUBLE_LETTER) {
            val *= 2;
        } else if (type == SQ_TRIPLE_LETTER) {
            val *= 3;
        } else if (type == SQ_TRIPLE_WORD) {
            multiplier *= 3;
        } else if (type == SQ_DOUBLE_WORD || type == SQ_CENTER) {
            multiplier *= 2;
        }
        score += val;
        [xs addObject:[NSNumber numberWithInteger:tile.coord.x]];
        [ys addObject:[NSNumber numberWithInteger:tile.coord.y]];
    }
    BOOL valid = [xs isNumberArrayConsecutive] && [ys isNumberArraySame];
    if (!valid) valid = [ys isNumberArrayConsecutive] && [xs isNumberArraySame];
    if (valid) {
        score *= multiplier;
        if (droppedTiles.count == scrabble.tilesInRack) {
            score += 50;
        }
        return score;
    } else {
        return -1;
    }
}

- (void)createBoardWithSize:(CGSize)size inView:(UIView*)view
{
    boardContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    NSArray *board = [scrabble board];
    NSUInteger dimensions = [scrabble boardSize];
    NSInteger width = round(size.width / dimensions);
    NSInteger height = round(size.height / dimensions);
    for (NSInteger y = 0; y < dimensions; y++) {
        for (NSInteger x = 0; x < dimensions; x++) {
            CGRect frame = CGRectMake(x * width, y * height, width, height);
            SquareType type = [board[y][x] integerValue];
            CNScrabbleSquare *square = [[CNScrabbleSquare alloc] initWithFrame:frame type:type coord:CGPointMake(x, y)];
            [boardContainer addSubview:square];
        }
    }
    [view addSubview:boardContainer];
}

- (void)layoutTileRack
{
    NSInteger count = drawnTiles.count;
    if (count == 0) return;
    CGFloat tileWidth = 40;
    CGFloat tilePadding = (320 / count);
    NSLog(@"Padding = %f", tilePadding);
    for (NSInteger i = 0; i < count; i++) {
        CNScrabbleTile *tile = drawnTiles[i];
        CGFloat x = (i * (tilePadding - tileWidth) + i * tileWidth);// - (tileWidth * .5);
        NSLog(@"X = %f, value = %d", x, [tile letterValue]);
        tile.frame = CGRectMake(x, 10, tileWidth, tileWidth);
        [tileRack addSubview:tile];
    }
}

- (void)drawTiles
{
    if (!drawnTiles) drawnTiles = [NSMutableArray array];
    NSUInteger amount = [scrabble tilesInRack] - [drawnTiles count];
    NSArray *tiles = [scrabble draw:amount];
    for (NSString *tile in tiles) {
        CNScrabbleTile *newTile = [[CNScrabbleTile alloc] initWithFrame:CGRectZero letter:tile];
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panTile:)];
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressTile:)];
        [pan setDelegate:self];
        [longPress setDelegate:self];
        [longPress setMinimumPressDuration:0.25f];
        [newTile setGestureRecognizers:@[pan, longPress]];
        [drawnTiles addObject:newTile];
    }
    [self layoutTileRack];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    scrabble = [[CNScrabble alloc] init];
    droppedTiles = [NSMutableSet set];
    
    CGFloat topOffset = 30, leftOffset = 10;
    boardScroller = [[UIScrollView alloc] initWithFrame:CGRectMake(leftOffset, topOffset, 300, 300)];
    [self createBoardWithSize:CGSizeMake(600, 600) inView:boardScroller];
    [boardScroller setDelegate:self];
    [boardScroller setContentSize:CGSizeMake(600, 600)];
    [boardScroller setMaximumZoomScale:1.0f];
    [boardScroller setMinimumZoomScale:0.5f];
    [boardScroller setZoomScale:0.5f];
    [boardScroller setBouncesZoom:NO];
    [boardScroller.layer setBorderWidth:1.0f];
    [boardScroller.layer setBorderColor:[UIColor squareBorderColor].CGColor];
    [self.view addSubview:boardScroller];
    [self.view setBackgroundColor:[UIColor gameBackgroundColor]];
    
    scoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(leftOffset, topOffset + 300 + 10, 300, 25)];
    [self.view addSubview:scoreLabel];
    
    play = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [play setFrame:CGRectMake(leftOffset, topOffset + 300 + 10 + 25, 100, 44)];
    [play setTitle:@"Play" forState:UIControlStateNormal];
    [play.layer setBorderWidth:1.0f];
    [play addTarget:self action:@selector(playPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:play];
    
    CGFloat rackHeight = 60.0f;
    tileRack = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - rackHeight, self.view.frame.size.width, rackHeight)];
    tileRack.backgroundColor = [UIColor tileRackColor];
    [self.view addSubview:tileRack];
    
    [self drawTiles];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Scroll View

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return boardContainer;
}

#pragma mark - Gestures

- (void)playPressed:(id)sender
{
    if (droppedTiles.count == 0 || [self calculateScore] == -1) {
        [[[UIAlertView alloc] initWithTitle:@"Invalid Placement" message:@"Please place tiles horizontally/vertically." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        return;
    }
    [droppedTiles removeAllObjects];
    [self drawTiles];
}

- (void)moveBoard
{
    
    CGPoint pt = [self.view convertPoint:draggedTile.center fromView:draggedTile.superview];
    if (CGRectContainsPoint(boardScroller.frame, pt)) {
        CGPoint bpt = [boardContainer convertPoint:draggedTile.center fromView:draggedTile.superview];
        if (boardScroller.zoomScale == 1.0f) {
            CardinalDirections direction = [boardScroller getDirectionForEdgeWithPoint:bpt];
            if (direction != D_NONE) {
                // Wait in hover zone for 1s before scrolling
                // Should queue a selector and cancel if user moves outside of this zone
                /*static NSTimeInterval hover = 0;
                 static CGFloat delay = 0.5f;
                 NSTimeInterval currTime = [[NSDate date] timeIntervalSince1970];
                 if (hover == 0.0f) {
                 hover = currTime;
                 return;
                 }
                 if (currTime - hover > delay) {
                 hover = currTime;
                 } else {
                 return;
                 }*/
                // Amount to add to current point
                CGPoint toAdd = [boardScroller getOffsetForDirection:direction];
                CGPoint newPoint = CGPointMake(toAdd.x + bpt.x, toAdd.y + bpt.y);
                // Scroll to new point
                CGRect brect = CGRectMake(newPoint.x - boardScroller.frame.size.width*.5,
                                          newPoint.y - boardScroller.frame.size.height*.5,
                                          boardScroller.frame.size.width, boardScroller.frame.size.height);
                [boardScroller zoomToRect:brect animated:YES];
            }
        }
    }
}

- (void)panTile:(UIPanGestureRecognizer*)gesture
{
    if (draggedTile == gesture.view) {
        [self adjustAnchorPointForGestureRecognizer:gesture];
        // Adjust icon location
        CGPoint translation = [gesture translationInView:[draggedTile superview]];
        [draggedTile setCenter:CGPointMake([draggedTile center].x + translation.x, [draggedTile center].y + translation.y)];
        [gesture setTranslation:CGPointZero inView:[draggedTile superview]];
    }
}

- (void)longPressTile:(UILongPressGestureRecognizer*)gesture
{
    if (draggedTile && draggedTile != gesture.view) return;
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan: {
            NSLog(@"Long Press Tile");
            draggedTile = (CNScrabbleTile*)gesture.view;
            [boardScroller setUserInteractionEnabled:NO];
            [draggedTile.superview bringSubviewToFront:draggedTile];
            break;
        }
        case UIGestureRecognizerStateCancelled: {
            [boardScroller setUserInteractionEnabled:YES];
            [self layoutTileRack];
            draggedTile = nil;
            break;
        }
        case UIGestureRecognizerStateEnded: {
            
            [boardScroller setUserInteractionEnabled:YES];
            CGPoint pt = [self.view convertPoint:draggedTile.center fromView:draggedTile.superview];
            if (CGRectContainsPoint(boardScroller.frame, pt)) {
                CGPoint bpt = [boardContainer convertPoint:draggedTile.center fromView:draggedTile.superview];
                if (boardScroller.zoomScale < 1.0f) {
                    // Zoom in on area user is hovering over
                    CGRect brect = CGRectMake(bpt.x - boardScroller.frame.size.width*.5,
                                              bpt.y - boardScroller.frame.size.height*.5,
                                              boardScroller.frame.size.width, boardScroller.frame.size.height);
                    [boardScroller zoomToRect:brect animated:YES];
                }
            }

            if (CGRectContainsPoint(boardScroller.frame, pt)) {
                CGPoint bpt = [boardContainer convertPoint:draggedTile.center fromView:draggedTile.superview];
                for (CNScrabbleSquare *square in boardContainer.subviews) {
                    if (CGRectContainsPoint(square.frame, bpt)) {
                        BOOL filled = NO;
                        for (CNScrabbleTile *tile in square.subviews) {
                            if ([tile isKindOfClass:[CNScrabbleTile class]]) {
                                filled = YES;
                                break;
                            }
                        }
                        if (!filled) {
                            [draggedTile setFrame:square.frame];
                            [boardContainer addSubview:draggedTile];
                            [drawnTiles removeObject:draggedTile];
                            [droppedTiles addObject:draggedTile];
                            [draggedTile setCoord:square.coord];
                        }
                        break;
                    }
                }
            }
            
            scoreLabel.text = [NSString stringWithFormat:@"%d", [self calculateScore]];
            [self layoutTileRack];
            draggedTile = nil;
            break;
        }
        default:
            break;
    }
}

- (void)adjustAnchorPointForGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        UIView *piece = gestureRecognizer.view;
        CGPoint locationInView = [gestureRecognizer locationInView:piece];
        CGPoint locationInSuperview = [gestureRecognizer locationInView:piece.superview];
        piece.layer.anchorPoint = CGPointMake(locationInView.x / piece.bounds.size.width, locationInView.y / piece.bounds.size.height);
        piece.center = locationInSuperview;
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if (([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]] &&
         [otherGestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]]) ||
        ([gestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]] &&
         [otherGestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]))
    {
        return YES;
    }
    return NO;
}


@end
