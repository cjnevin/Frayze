//
//  SettingsDataSource.h
//  Frayze
//
//  Created by CJNevin on 3/11/2013.
//  Copyright (c) 2013 CJNevin. All rights reserved.
//

#import <Foundation/Foundation.h>

#define THEME_CHANGED @"THEME_CHANGED"
#define SIZE_CHANGED @"SIZE_CHANGED"
#define COUNT_CHANGED @"COUNT_CHANGED"

@interface SettingsDataSource : NSObject <UITableViewDataSource, UITableViewDelegate>
{
    NSMutableArray *sections;
}

+ (SettingsDataSource*)sharedInstance;

@property (atomic) NSUInteger themeIndex;
@property (atomic) NSUInteger countIndex;
@property (atomic) NSUInteger gameTypeIndex;

@end
