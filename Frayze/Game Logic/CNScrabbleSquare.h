//
//  CNScrabbleSquare.h
//  WordPlay
//
//  Created by CJNevin on 31/10/2013.
//  Copyright (c) 2013 CJNevin. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    SQ_NORMAL,
    SQ_CENTER,
    SQ_DOUBLE_LETTER,
    SQ_DOUBLE_WORD,
    SQ_TRIPLE_LETTER,
    SQ_TRIPLE_WORD,
} SquareType;

@interface CNScrabbleSquare : UIView
{
    UILabel *typeLabel;
    SquareType type;
    CGPoint coord;
}

- (id)initWithFrame:(CGRect)frame type:(SquareType)type coord:(CGPoint)coord;

- (void)applyTheme;
- (CGPoint)coord;
- (SquareType)squareType;
- (NSString*)textForSquareType;

@end
