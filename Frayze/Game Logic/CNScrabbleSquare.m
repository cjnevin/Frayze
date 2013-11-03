//
//  CNScrabbleSquare.m
//  WordPlay
//
//  Created by CJNevin on 31/10/2013.
//  Copyright (c) 2013 CJNevin. All rights reserved.
//

#import "CNScrabbleSquare.h"

@implementation CNScrabbleSquare

- (void)applyTheme
{
    [typeLabel setText:[self textForSquareType]];
    [typeLabel setBackgroundColor:[self colorForSquareType]];
    //[self.layer setBorderColor:[UIColor squareBorderColor].CGColor];
}

- (id)initWithFrame:(CGRect)frame type:(SquareType)_type coord:(CGPoint)_coord
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        type = _type;
        coord = _coord;
        typeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [typeLabel setText:[self textForSquareType]];
        [typeLabel setAdjustsFontSizeToFitWidth:YES];
        [typeLabel setFont:[UIFont systemFontOfSize:14]];
        [typeLabel setMinimumScaleFactor:0.25f];
        [typeLabel setTextAlignment:NSTextAlignmentCenter];
        //[self.layer setBorderWidth:1.0f];
        [self addSubview:typeLabel];
        [self applyTheme];
    }
    return self;
}

#pragma mark -

+ (UIColor*)colorForSquareType:(SquareType)square
{
    switch (square) {
        case SQ_CENTER:
            return [UIColor centerColor];
        case SQ_DOUBLE_WORD:
            return [UIColor doubleWordColor];
        case SQ_DOUBLE_LETTER:
            return [UIColor doubleLetterColor];
        case SQ_TRIPLE_LETTER:
            return [UIColor tripleLetterColor];
        case SQ_TRIPLE_WORD:
            return [UIColor tripleWordColor];
        default:
            return [UIColor squareColor];
    }
}

+ (NSString*)textForSquareType:(SquareType)square
{
    return nil;
    switch (square) {
        case SQ_CENTER:
            return @"CE";
        case SQ_DOUBLE_WORD:
            return @"DW";
        case SQ_DOUBLE_LETTER:
            return @"DL";
        case SQ_TRIPLE_LETTER:
            return @"TL";
        case SQ_TRIPLE_WORD:
            return @"TW";
        default:
            return @"  ";
    }
}

- (UIColor*)colorForSquareType
{
    return [[self class] colorForSquareType:type];
}

- (NSString*)textForSquareType
{
    return [[self class] textForSquareType:type];
}

- (CGPoint)coord
{
    return coord;
}

- (SquareType)squareType
{
    return type;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
