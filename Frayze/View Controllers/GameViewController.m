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
#import <AudioToolbox/AudioServices.h>

@interface GameViewController ()
{
    NSUInteger currentScore;
    UIView *boardContainer;
    
    CNScrabble *scrabble;
}
@end

@implementation GameViewController

- (void)applyTheme
{
    tileRack.backgroundColor = [UIColor tileRackColor];
    cpuScoreLabel.textColor = [UIColor tileTextColor];
    cpuScoreHeadLabel.textColor = [UIColor tileTextColor];
    scoreLabel.textColor = [UIColor tileTextColor];
    scoreHeadLabel.textColor = [UIColor tileTextColor];
    [boardScroller.layer setBorderColor:[UIColor squareBorderColor].CGColor];
    [self.view setBackgroundColor:[UIColor gameBackgroundColor]];
    for (CNScrabbleSquare *square in boardContainer.subviews) {
        if ([square isKindOfClass:[CNScrabbleSquare class]]) {
            [square applyTheme];
        }
    }
    [tileRack.subviews makeObjectsPerformSelector:@selector(applyTheme)];
    [scrabble.playedTiles makeObjectsPerformSelector:@selector(applyTheme)];
    [scrabble.droppedTiles makeObjectsPerformSelector:@selector(applyTheme)];
    for (UIView *v in boardContainer.subviews) {
        if (v.tag == 101) {
            [v.layer setBorderColor:[UIColor tileHighlight].CGColor];
        }
    }
    if (latticeImage) {
        [latticeImage removeFromSuperview];
    }
    latticeImage = [[UIImageView alloc] initWithImage:[self createLattice]];
    [boardContainer addSubview:latticeImage];
}

- (UIImage*)createLattice
{
    CGRect bounds = CGRectMake(0, 0, 600, 600);
    UIGraphicsBeginImageContext(bounds.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 1);
    [[UIColor squareBorderColor] setStroke];
    for (NSInteger i = 0; i <= 600; i+= 40) {
        CGContextBeginPath(context);
        CGContextMoveToPoint(context, i, 0);
        CGContextAddLineToPoint(context, i, 600);
        CGContextStrokePath(context);
        CGContextBeginPath(context);
        CGContextMoveToPoint(context, 0, i);
        CGContextAddLineToPoint(context, 600, i);
        CGContextStrokePath(context);
    }
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(themeChanged:) name:THEME_CHANGED object:nil];
    
    boardContainer = [[UIView alloc] init];
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapBoard:)];
    [doubleTap setNumberOfTapsRequired:2];
    [boardScroller addGestureRecognizer:doubleTap];
    [boardScroller addSubview:boardContainer];
    [boardScroller setDelegate:self];
    [boardScroller setMaximumZoomScale:1.0f];
    [boardScroller setMinimumZoomScale:0.5f];
    [boardScroller setBouncesZoom:NO];
    [boardScroller setScrollIndicatorInsets:UIEdgeInsetsZero];
    [boardScroller setContentInset:UIEdgeInsetsZero];
    [boardScroller.layer setBorderWidth:1.0f];
    
    UIBarButtonItem *play = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self action:@selector(playPressed:)];
    UIBarButtonItem *shuffle = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(shufflePressed:)];
    UIBarButtonItem *settings = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemOrganize target:self action:@selector(settingsPressed:)];
    UIBarButtonItem *info = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks target:self action:@selector(infoPressed:)];
    
    [self.navigationItem setLeftBarButtonItems:@[settings, shuffle]];
    [self.navigationItem setRightBarButtonItems:@[play, info]];
    [self.navigationItem setTitle:@"Frayze"];
    
    [self.view bringSubviewToFront:tileRack];
    [self.view bringSubviewToFront:settingsView];
    
    settingsDataSource = [SettingsDataSource sharedInstance];
    settingsTable.dataSource = settingsDataSource;
    settingsTable.delegate = settingsDataSource;
    
    // Finally setup the scrabble board
    [self applyTheme];
    scrabble = [[CNScrabble alloc] initWithDelegate:self];
    [scrabble resetGame];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Scroll View

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    if (scrollView == boardScroller) {
        return boardContainer;
    }
    return nil;
}

#pragma mark - Delegate

- (void)boardReset
{
    currentScore = 0;
    [scoreLabel setText:@"0"];
    [cpuScoreLabel setText:@"0"];
    [boardContainer.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    CGSize size = CGSizeMake(600, 600);
    [boardContainer setFrame:CGRectMake(0, 0, size.width, size.height)];
    [boardScroller setContentSize:size];
    NSArray *board = [scrabble board];
    NSUInteger dimensions = [scrabble boardSize];
    NSInteger width = round(size.width / dimensions);
    NSInteger height = round(size.height / dimensions);
    for (NSInteger y = 0; y < dimensions; y++) {
        for (NSInteger x = 0; x < dimensions; x++) {
            CGRect frame = CGRectMake(x * width, y * height, width, height);
            SquareType type = [board[y][x] integerValue];
            CNScrabbleSquare *square = [[CNScrabbleSquare alloc] initWithFrame:frame type:type coord:CGPointMake(x + 1, y + 1)];
            [boardContainer addSubview:square];
        }
    }
    [boardContainer addSubview:latticeImage];
    [boardScroller setZoomScale:0.5f];
}

- (void)drewTile:(CNScrabbleTile *)tile
{
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panTile:)];
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressTile:)];
    [pan setDelegate:self];
    [longPress setDelegate:self];
    [longPress setMinimumPressDuration:0.1f];
    [tile setGestureRecognizers:@[pan, longPress]];
}

- (void)drewTiles
{
    NSInteger count = [[scrabble drawnTiles] count];
    if (count == 0) return;
    CGFloat xpadding = 3;
    CGFloat tileWidth = 40;
    CGFloat totalWidth = tileWidth * count;
    CGFloat padding = xpadding * count;
    CGFloat xoffset = (320 - totalWidth - padding) / 2;
    for (NSInteger i = 0; i < count; i++) {
        CNScrabbleTile *tile = [scrabble drawnTiles][i];
        CGFloat x = round(xoffset + i * (tileWidth + xpadding));
        tile.frame = CGRectMake(x, 5, tileWidth, tileWidth);
        [tileRack addSubview:tile];
    }
}

- (void)tilesReset
{
    [self removeHighlights];
}

- (void)highlightTiles:(NSArray *)tiles
{
    CGRect rect = [scrabble rectForTiles:tiles];
    UIView *view = [[UIView alloc] initWithFrame:rect];
    [view setBackgroundColor:[UIColor clearColor]];
    [view setTag:101];
    [view.layer setCornerRadius:3.f];
    [view.layer setBorderColor:[UIColor tileHighlight].CGColor];
    [view.layer setBorderWidth:3.f];
    [boardContainer addSubview:view];
}

- (void)removeHighlights
{
    for (UIView *v in boardContainer.subviews) {
        if (v.tag == 101) {
            [v removeFromSuperview];
        }
    }
}

#pragma mark - Gestures

- (void)themeChanged:(NSNotification*)notification
{
    [self applyTheme];
}

- (void)infoPressed:(id)sender
{
    
}

- (void)shufflePressed:(id)sender
{
    
}

- (void)playPressed:(id)sender
{
    if (![scrabble canSubmit]) {
        [[[UIAlertView alloc] initWithTitle:@"Invalid Placement" message:@"Please place tiles horizontally/vertically." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    } else {
        [self removeHighlights];
        currentScore += [scrabble calculateScore:NO];
        scoreLabel.text = [NSString stringWithFormat:@"%d", currentScore];
        [scrabble submit];
    }
}

- (void)settingsPressed:(id)sender
{
    // TODO: Prompt if user wants to commit these changes and lose their current game
    static NSInteger oldGameType = -1;
    static NSInteger oldTileCount = -1;
    NSInteger newGameType = [[SettingsDataSource sharedInstance] gameTypeIndex];
    NSInteger newTileCount = [[SettingsDataSource sharedInstance] countIndex];
    CGFloat alpha = 1.0f;
    [UIView animateWithDuration:0.5f animations:^{
        if (settingsView.alpha == alpha) {
            if (oldGameType != newGameType || oldTileCount != newTileCount) {
                oldTileCount = newTileCount;
                oldGameType = newGameType;
                [scrabble resetGame];
            }
            settingsView.alpha = 0.0f;
        } else {
            oldGameType = newGameType;
            oldTileCount = newTileCount;
            settingsView.alpha = alpha;
        }
    }];
}

- (void)zoomBoardAtPoint:(CGPoint)pt
{
    if (CGRectContainsPoint(boardScroller.frame, pt)) {
        CGPoint bpt = [boardContainer convertPoint:pt fromView:self.view];
        if (boardScroller.zoomScale < 1.0f) {
            // Zoom in on area user is hovering over
            CGRect brect = CGRectMake(bpt.x - boardScroller.frame.size.width*.5,
                                      bpt.y - boardScroller.frame.size.height*.5,
                                      boardScroller.frame.size.width, boardScroller.frame.size.height);
            [boardScroller zoomToRect:brect animated:YES];
        }
    }
    
}

- (void)moveBoard
{
    return;
    /*
     CGPoint pt = [self.view convertPoint:draggedTile.center fromView:draggedTile.superview];
     if (CGRectContainsPoint(boardScroller.frame, pt)) {
     CGPoint bpt = [boardContainer convertPoint:draggedTile.center fromView:draggedTile.superview];
     if (boardScroller.zoomScale == 1.0f) {
     CardinalDirections direction = [boardScroller getDirectionForEdgeWithPoint:bpt];
     if (direction != D_NONE) {*/
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
    /*             CGPoint toAdd = [boardScroller getOffsetForDirection:direction];
     CGPoint newPoint = CGPointMake(toAdd.x + bpt.x, toAdd.y + bpt.y);
     // Scroll to new point
     CGRect brect = CGRectMake(newPoint.x - boardScroller.frame.size.width*.5,
     newPoint.y - boardScroller.frame.size.height*.5,
     boardScroller.frame.size.width, boardScroller.frame.size.height);
     [boardScroller zoomToRect:brect animated:YES];
     }
     }
     }*/
}

- (void)doubleTapBoard:(UITapGestureRecognizer*)gesture
{
    if (boardScroller.zoomScale == 1.0f) {
        [boardScroller setZoomScale:0.5f animated:YES];
    } else {
        CGPoint pt = [gesture locationInView:boardContainer];
        CGRect brect = CGRectMake(pt.x - boardScroller.frame.size.width*.5,
                                  pt.y - boardScroller.frame.size.height*.5,
                                  boardScroller.frame.size.width, boardScroller.frame.size.height);
        [boardScroller zoomToRect:brect animated:YES];
    }
}

- (void)panTile:(UIPanGestureRecognizer*)gesture
{
    CNScrabbleTile *t = scrabble.draggedTile;
    if (t == gesture.view) {
        [self adjustAnchorPointForGestureRecognizer:gesture];
        // Adjust icon location
        CGPoint translation = [gesture translationInView:[t superview]];
        [t setCenter:CGPointMake([t center].x + translation.x, [t center].y + translation.y)];
        [gesture setTranslation:CGPointZero inView:[t superview]];
    }
}

- (void)longPressTile:(UILongPressGestureRecognizer*)gesture
{
    CNScrabbleTile *t = scrabble.draggedTile;
    if (t && t != gesture.view) return;
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan: {
            NSLog(@"Long Press Tile");
            t = (CNScrabbleTile*)gesture.view;
            scrabble.draggedTile = t;
            [boardScroller setUserInteractionEnabled:NO];
            [t.superview bringSubviewToFront:t];
            break;
        }
        case UIGestureRecognizerStateCancelled: {
            [boardScroller setUserInteractionEnabled:YES];
            [self drewTiles];
            scrabble.draggedTile = nil;
            break;
        }
        case UIGestureRecognizerStateEnded: {
            // TODO: Vibrate on drop on board/rack - setting
            // TODO: Restore to tile rack if user drags out of confines of board
            // TODO: Check that location is within visible area if zoomed in
            [boardScroller setUserInteractionEnabled:YES];
            
            CGPoint pt = [self.view convertPoint:t.center fromView:t.superview];
            CGPoint bpt = [gesture locationInView:boardContainer];  //[boardContainer convertPoint:t.center fromView:t.superview];
            CGRect visibleRect = [boardScroller convertRect:boardScroller.bounds toView:boardContainer];
            BOOL filled = NO;
            BOOL inbounds = CGRectContainsPoint(visibleRect, bpt);
            if (CGRectContainsPoint(boardScroller.frame, pt) && inbounds) {
                filled = ![scrabble isEmptyAtPoint:bpt];
            }
            if (!filled) {
                // Square is empty, add dragged tile
                filled = YES;
                if (inbounds) {
                    for (CNScrabbleSquare *square in boardContainer.subviews) {
                        if ([square isKindOfClass:[CNScrabbleSquare class]]) {
                            if (CGRectContainsPoint(square.frame, bpt)) {
                                if ([scrabble getTileAtX:square.coord.x y:square.coord.y]) {
                                    break;
                                }
                                [t setFrame:square.frame];
                                [t setCoord:square.coord];
                                [boardContainer addSubview:t];
                                [[scrabble drawnTiles] removeObject:t];
                                [[scrabble droppedTiles] addObject:t];
                                // Vibrate on drop?
                                //AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
                                filled = NO;
                                break;
                            }
                        }
                    }
                }
            }
            if (filled) {
                // Square is filled, remove dragged tile
                if (![[scrabble drawnTiles] containsObject:t]) {
                    [[scrabble drawnTiles] addObject:t];
                }
                [[scrabble droppedTiles] removeObject:t];
            }
            // Show running score?
            //scoreLabel.text = [NSString stringWithFormat:@"%d", [scrabble calculateScore]];
            scrabble.draggedTile = nil;
            [self drewTiles];
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
