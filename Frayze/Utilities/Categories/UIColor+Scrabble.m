//
//  UIColor+Scrabble.m
//  WordPlay
//
//  Created by CJNevin on 31/10/2013.
//  Copyright (c) 2013 CJNevin. All rights reserved.
//

#import "UIColor+Scrabble.h"

//#define INVERSE true

// Adjust hues using same logic as INVERSE, allow user to define the amount to offset from the original

@implementation UIColor (Scrabble)

UIColor* rgb(NSUInteger r, NSUInteger g, NSUInteger b) {
#ifdef INVERSE
    NSInteger amount = 255;
    return [UIColor colorWithRed:abs(amount-r)/255.f green:abs(amount-g)/255.f blue:abs(amount-b)/255.f alpha:1.0f];
#endif
    return [UIColor colorWithRed:r/255.f green:g/255.f blue:b/255.f alpha:1.0f];
}

#pragma mark - Game

+ (UIColor *)gameBackgroundColor
{
    return rgb(255, 255, 255);
}

#pragma mark - Board

+ (UIColor*)doubleWordColor
{
    return rgb(255,182,193);
}

+ (UIColor*)doubleLetterColor
{
    return rgb(173,216,230);
}

+ (UIColor*)tripleLetterColor
{
    return rgb(65,105,225);
}

+ (UIColor*)tripleWordColor
{
    return rgb(205,92,92);
}

+ (UIColor*)centerColor
{
    return rgb(216,191,216);
}

+ (UIColor*)squareColor
{
    return rgb(245,245,220);
}

+ (UIColor *)squareBorderColor
{
    return rgb(0,0,0);
}

#pragma mark - Tile

+ (UIColor*)tileColor
{
    return rgb(238,221,130);
}

+ (UIColor*)tileTextColor
{
    return rgb(0, 0, 0);
}

+ (UIColor*)tileRackColor
{
    return rgb(210, 180, 140);
}

+ (UIColor *)tileBorderColor
{
    return rgb(0, 0, 0);
}

@end
