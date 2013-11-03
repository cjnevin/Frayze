//
//  SettingsDataSource.h
//  Frayze
//
//  Created by CJNevin on 3/11/2013.
//  Copyright (c) 2013 CJNevin. All rights reserved.
//

#import <Foundation/Foundation.h>

#define THEME_CHANGED @"THEME_CHANGED"

@interface SettingsDataSource : NSObject <UITableViewDataSource, UITableViewDelegate>
{
    NSMutableArray *sections;
}

+ (SettingsDataSource*)sharedInstance;

@property (atomic) NSUInteger themeIndex;
@property (atomic) NSUInteger sizeIndex;

@end
