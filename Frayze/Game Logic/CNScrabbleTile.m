//
//  CNScrabbleTile.m
//  Frayze
//
//  Created by CJNevin on 31/10/2013.
//  Copyright (c) 2013 CJNevin. All rights reserved.
//

#import "CNScrabbleTile.h"
#import "CNScrabble.h"

@implementation CNScrabbleTile

@synthesize pointLabel;
@synthesize letterLabel;
@synthesize coord;
@synthesize letterString;

- (void)applyTheme
{
    [letterLabel setTextColor:[UIColor tileTextColor]];
    [letterLabel setBackgroundColor:[UIColor tileColor]];
    [letterLabel.layer setBorderColor:[UIColor tileBorderColor].CGColor];
    [pointLabel setTextColor:[UIColor tileTextColor]];
}

- (id)initWithFrame:(CGRect)frame letter:(NSString*)letter
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        letterString = letter;
        CGRect subFrame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        letterLabel = [[UILabel alloc] initWithFrame:subFrame];
        [letterLabel setText:letter];
        [letterLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:28.f]];
        [letterLabel setMinimumScaleFactor:0.5f];
        [letterLabel setAdjustsFontSizeToFitWidth:YES];
        [letterLabel setTextAlignment:NSTextAlignmentCenter];
        [letterLabel setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
        [letterLabel.layer setBorderWidth:1.0f];
        [letterLabel.layer setCornerRadius:5.f];
        [self addSubview:letterLabel];
        
        NSInteger value = [self letterValue];
        if (value > 0) {
            subFrame = CGRectMake(frame.size.width - 15, frame.size.height - 12, 10, 10);
            pointLabel = [[UILabel alloc] initWithFrame:subFrame];
            [pointLabel setText:[NSString stringWithFormat:@"%d", value]];
            [pointLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:10.f]];
            [pointLabel setMinimumScaleFactor:0.05f];
            [pointLabel setAdjustsFontSizeToFitWidth:YES];
            [pointLabel setTextAlignment:NSTextAlignmentRight];
            [pointLabel setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
            [self addSubview:pointLabel];
        }
        [self applyTheme];
    }
    return self;
}

- (NSInteger)letterValue
{
    NSDictionary *dict = [CNScrabble letterValues];
    NSString *letter = letterString;
    for (NSString *s in [dict allKeys]) {
        if ([s rangeOfString:letter].location != NSNotFound) {
            return [dict[s] integerValue];
        }
    }
    return 0;
}

- (NSNumber*)getX
{
    return [NSNumber numberWithInt:(NSInteger)coord.x];
}

- (NSNumber*)getY
{
    return [NSNumber numberWithInt:(NSInteger)coord.y];
}

@end
