//
//  CNScrabbleTile.m
//  WordPlay
//
//  Created by CJNevin on 31/10/2013.
//  Copyright (c) 2013 CJNevin. All rights reserved.
//

#import "CNScrabbleTile.h"
#import "CNScrabble.h"

@implementation CNScrabbleTile

@synthesize coord;

- (id)initWithFrame:(CGRect)frame letter:(NSString*)letter
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        letterLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [letterLabel setText:[letter uppercaseString]];
        [letterLabel setTextColor:[UIColor tileTextColor]];
        [letterLabel setFont:[UIFont boldSystemFontOfSize:20]];
        [letterLabel setMinimumScaleFactor:0.5f];
        [letterLabel setAdjustsFontSizeToFitWidth:YES];
        [letterLabel setTextAlignment:NSTextAlignmentCenter];
        [letterLabel setBackgroundColor:[UIColor tileColor]];
        [letterLabel setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
        [self.layer setBorderWidth:1.0f];
        [self.layer setBorderColor:[UIColor tileBorderColor].CGColor];
        [self addSubview:letterLabel];
    }
    return self;
}

- (NSInteger)letterValue
{
    NSDictionary *dict = [CNScrabble letterValues];
    NSString *letter = [letterLabel.text lowercaseString];
    for (NSString *s in [dict allKeys]) {
        if ([s rangeOfString:letter].location != NSNotFound) {
            return [dict[s] integerValue];
        }
    }
    return 0;
}

@end
