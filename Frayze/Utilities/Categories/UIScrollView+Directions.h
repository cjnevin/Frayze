//
//  UIScrollView+Directions.h
//  Stuff
//
//  Created by CJNevin on 31/10/2013.
//  Copyright (c) 2013 CJNevin. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    D_NONE = 0,
    D_NW,
    D_NE,
    D_SW,
    D_SE,
    D_N,
    D_S,
    D_W,
    D_E,
} CardinalDirections;

@interface UIScrollView (Directions)

- (CardinalDirections)getDirectionWithTop:(BOOL)top left:(BOOL)left right:(BOOL)right bottom:(BOOL)bottom;
- (CardinalDirections)getDirectionForEdgeWithPoint:(CGPoint)bpt;
- (CGPoint)getOffsetForDirection:(CardinalDirections)direction;

@end
