//
//  CNScrabbleTile.h
//  WordPlay
//
//  Created by CJNevin on 31/10/2013.
//  Copyright (c) 2013 CJNevin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CNScrabbleTile : UIView
{
    UILabel *letterLabel;
}

@property (nonatomic, assign) CGPoint coord;

- (id)initWithFrame:(CGRect)frame letter:(NSString*)letter;
- (NSInteger)letterValue;

@end
