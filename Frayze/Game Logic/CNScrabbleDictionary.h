//
//  CNScrabbleDictionary.h
//  Frayze
//
//  Created by CJNevin on 13/11/2013.
//  Copyright (c) 2013 CJNevin. All rights reserved.
//

#import <Foundation/Foundation.h>

#define DEF_KEY @"Def"
#define NAME_KEY @"Name"

@interface CNScrabbleDictionary : NSObject
{
    NSDictionary *dictionary;
}

@property (nonatomic, strong, readonly) NSString *path;

- (id)initWithPlist:(NSString*)name;
- (id)initWithRawTextFile:(NSString*)rawTextFile;

- (NSDictionary*)getDictionary;
- (NSMutableArray*)allWords;
- (NSString*)definitionForWord:(NSString*)word;
- (BOOL)isWordValid:(NSString*)word;
- (NSMutableArray*)wordsBegginningWith:(NSString*)word;
- (NSArray*)wordsComparableWith:(NSString*)word;
- (void)wordsWithLetters:(NSArray*)letters prefix:(NSString*)prefix letterDict:(NSDictionary*)letterDict results:(NSMutableArray*)results;

@end
