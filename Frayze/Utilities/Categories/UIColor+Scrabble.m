//
//  UIColor+Scrabble.m
//  Frayze
//
//  Created by CJNevin on 31/10/2013.
//  Copyright (c) 2013 CJNevin. All rights reserved.
//

#import "UIColor+Scrabble.h"

// Adjust hues using same logic as INVERSE, allow user to define the amount to offset from the original

@implementation UIColor (Scrabble)

NSUInteger theme() {
    NSUInteger index = [[SettingsDataSource sharedInstance] themeIndex];
    return index;
}

UIColor* rgb(NSUInteger r, NSUInteger g, NSUInteger b) {
    if (theme() == 1) {
        CGFloat amount = 400.f;
        return [UIColor colorWithRed:abs(amount-r)/amount green:abs(amount-g)/amount blue:abs(amount-b)/amount alpha:1.0f];
    } else if (theme() == 2) {
        return [UIColor colorWithRed:b/255.f green:g/255.f blue:r/255.f alpha:1.0f];    // BGR
    } else if (theme() == 3) {
        return [UIColor colorWithRed:g/255.f green:r/255.f blue:b/255.f alpha:1.0f];    // GRB
    } else if (theme() == 4) {
        return [UIColor colorWithRed:g/255.f green:b/255.f blue:r/255.f alpha:1.0f];    // GBR
    } else {
        return [UIColor colorWithRed:r/255.f green:g/255.f blue:b/255.f alpha:1.0f];    // RGB
    }
}

UIColor* white(NSUInteger w) {
    return rgb(w, w, w);
}

#pragma mark - Game

+ (UIColor *)gameBackgroundColor
{
    //return [self tileRackColor];
    return white(255);
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
    return white(0);
}

#pragma mark - Tile

+ (UIColor*)tileHighlight
{
    return rgb(147,112,219);
    return rgb(50,205,50);
}

+ (UIColor*)tileColor
{
    return rgb(238,221,130);
}

+ (UIColor*)tileTextColor
{
    return white(0);
}

+ (UIColor*)tileCountColor
{
    return white(255);
}

+ (UIColor*)tileCountBackgroundColor
{
    return white(0);
}

+ (UIColor*)tileRackColor
{
    return rgb(210, 180, 140);
}

+ (UIColor *)tileBorderColor
{
    return white(0);
}

@end
