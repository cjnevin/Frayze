//
//  CNScrabbleDictionary.h
//  Frayze
//
//  Created by CJNevin on 13/11/2013.
//  Copyright (c) 2013 CJNevin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CNScrabbleDictionary : NSObject
{
    NSDictionary *dictionary;
}

@property (nonatomic, strong, readonly) NSString *path;

- (id)initWithPlist:(NSString*)name;
- (id)initWithRawTextFile:(NSString*)rawTextFile;

- (NSString*)definitionForWord:(NSString*)word;
- (BOOL)isWordValid:(NSString*)word;

@end