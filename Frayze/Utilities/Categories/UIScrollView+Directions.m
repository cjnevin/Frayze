//
//  UIScrollView+Directions.m
//  Stuff
//
//  Created by CJNevin on 31/10/2013.
//  Copyright (c) 2013 CJNevin. All rights reserved.
//

#import "UIScrollView+Directions.h"

@implementation UIScrollView (Directions)

- (CardinalDirections)getDirectionWithTop:(BOOL)top left:(BOOL)left right:(BOOL)right bottom:(BOOL)bottom
{
    CardinalDirections d = D_NONE;
    if (top) {
        if (left) {
            // Move NW
            d = D_NW;
        } else if (right) {
            // Move NE
            d = D_NE;
        } else {
            // Move N
            d = D_N;
        }
    } else if (bottom) {
        if (left) {
            // Move SW
            d = D_SW;
        } else if (right) {
            // Move SE
            d = D_SE;
        } else {
            // Move S
            d = D_S;
        }
    } else if (left) {
        // Move W
        d = D_W;
    } else if (right) {
        // Move E
        d = D_E;
    }
    return d;
}

- (CardinalDirections)getDirectionForEdgeWithPoint:(CGPoint)bpt
{
    // Move zoom if user is hovering over a edge and there is content in that direction
    CGPoint spt = [self contentOffset];
    // Edges for matching
    CGFloat zone = 30.0f;
    CGRect topEdge = CGRectMake(spt.x, spt.y, self.frame.size.width, zone);
    CGRect leftEdge = CGRectMake(spt.x, spt.y, zone, self.frame.size.height);
    CGRect rightEdge = CGRectMake(spt.x + self.frame.size.width - zone, spt.y, zone, self.frame.size.height);
    CGRect bottomEdge = CGRectMake(spt.x, spt.y + self.frame.size.height - zone, self.frame.size.width, zone);
    // Get Cardinal Direction
    CardinalDirections direction = [self getDirectionWithTop:CGRectContainsPoint(topEdge, bpt)
                                                        left:CGRectContainsPoint(leftEdge, bpt)
                                                       right:CGRectContainsPoint(rightEdge, bpt)
                                                      bottom:CGRectContainsPoint(bottomEdge, bpt)];
    return direction;
}

- (CGPoint)getOffsetForDirection:(CardinalDirections)direction
{
    CGFloat amount = 10.0f;
    switch (direction) {
        case D_E: return CGPointMake(amount, 0);
        case D_N: return CGPointMake(0, -amount);
        case D_S: return CGPointMake(0, amount);
        case D_W: return CGPointMake(-amount, 0);
        case D_NE: return CGPointMake(amount, -amount);
        case D_NW: return CGPointMake(-amount, -amount);
        case D_SE: return CGPointMake(amount, amount);
        case D_SW: return CGPointMake(-amount, amount);
        default: return CGPointZero;
    }
}
@end
