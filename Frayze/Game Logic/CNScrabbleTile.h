//
//  CNScrabbleTile.h
//  WordPlay
//
//  Created by CJNevin on 31/10/2013.
//  Copyright (c) 2013 CJNevin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CNScrabbleTile : UIView

@property (nonatomic, strong) UILabel *letterLabel;
@property (nonatomic, strong) UILabel *pointLabel;
@property (nonatomic, assign) CGPoint coord;

- (void)applyTheme;
- (id)initWithFrame:(CGRect)frame letter:(NSString*)letter;
- (NSInteger)letterValue;
- (NSNumber*)getX;
- (NSNumber*)getY;

@end
