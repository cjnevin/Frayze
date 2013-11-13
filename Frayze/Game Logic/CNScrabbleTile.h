//
//  CNScrabbleTile.h
//  Frayze
//
//  Created by CJNevin on 31/10/2013.
//  Copyright (c) 2013 CJNevin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CNScrabbleTile : UIView
{
    NSString *letterString;
}

@property (nonatomic, strong) UILabel *letterLabel;
@property (nonatomic, strong) UILabel *pointLabel;
@property (nonatomic, assign) CGPoint coord;

- (id)initWithFrame:(CGRect)frame letter:(NSString*)letter;

- (void)applyTheme;
- (NSInteger)letterValue;
- (NSNumber*)getX;
- (NSNumber*)getY;

@end
