//
//  FirstViewController.h
//  WordPlay
//
//  Created by CJNevin on 30/10/2013.
//  Copyright (c) 2013 CJNevin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CNScrabble.h"
#import "CNScrabbleTile.h"

@interface GameViewController : UIViewController <UIScrollViewDelegate, UIGestureRecognizerDelegate, CNScrabbleDelegate, UITableViewDataSource, UITableViewDelegate>
{
    IBOutlet UIView *tileRack, *settingsView;
    IBOutlet UIScrollView *settingsTable;
}

@end
