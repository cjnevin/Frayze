//
//  CNScrabbleDictionary.m
//  Frayze
//
//  Created by CJNevin on 13/11/2013.
//  Copyright (c) 2013 CJNevin. All rights reserved.
//

#import "CNScrabbleDictionary.h"
#import <stdio.h>

@implementation CNScrabbleDictionary

@synthesize path = _path;

- (id)initWithRawTextFile:(NSString *)rawTextFile
{
    self = [super init];
    if (self) {
        _path = rawTextFile;
        [self createDictionary];
    }
    return self;
}

- (id)initWithPlist:(NSString *)name
{
    self = [super init];
    if (self) {
        _path = name;
        [self loadDictionary];
    }
    return self;
}

#pragma mark - Plist Import

- (NSDictionary*)getDictionary
{
    return dictionary;
}

- (void)populate:(NSString*)prefix letterDict:(NSDictionary*)letterDict array:(NSMutableArray*)array {
    for (NSString *key in [letterDict allKeys]) {
        if (![key isEqualToString:DEF_KEY]) {
            [self populate:[prefix stringByAppendingString:key] letterDict:letterDict[key] array:array];
        } else {
            [array addObject:@{NAME_KEY: prefix, DEF_KEY: letterDict[DEF_KEY]}];
        }
    }
}

- (NSMutableArray*)allWords
{
    // This method is slow, use at your own peril
    NSMutableArray *results = [NSMutableArray array];
    for (NSString *key in dictionary) {
        [self populate:key letterDict:dictionary[key] array:results];
    }
    [results sortByKey:NAME_KEY];
    return results;
}

- (void)wordsWithLetters:(NSArray*)letters prefix:(NSString*)prefix letterDict:(NSDictionary*)letterDict results:(NSMutableArray*)results
{
    if ([[letterDict allKeys] containsObject:DEF_KEY]) {
        [results addObject:@{NAME_KEY: prefix, DEF_KEY: letterDict[DEF_KEY]}];
    }
    for (NSString *key in [letterDict allKeys]) {
        if ([letters containsObject:@"?"]) {
            NSInteger index = [letters indexOfObject:@"?"];
            NSMutableArray *copy = [NSMutableArray arrayWithArray:letters];
            [copy removeObjectAtIndex:index];
            [self wordsWithLetters:copy
                            prefix:[NSString stringWithFormat:@"%@%@", prefix, key]
                        letterDict:letterDict[key]
                           results:results];
        } else if ([letters containsObject:key]) {
            NSInteger index = [letters indexOfObject:key];
            NSMutableArray *copy = [NSMutableArray arrayWithArray:letters];
            [copy removeObjectAtIndex:index];
            [self wordsWithLetters:copy
                            prefix:[NSString stringWithFormat:@"%@%@", prefix, key]
                        letterDict:letterDict[key]
                           results:results];
        }
    }
}

- (NSMutableArray*)lettersForWord:(NSString*)word
{
    NSMutableArray *letters = [NSMutableArray array];
    for (NSInteger i = 0; i < word.length; i++) {
        [letters addObject:[word substringWithRange:NSMakeRange(i, 1)]];
    }
    return letters;
}

- (NSArray*)wordsComparableWith:(NSString*)word
{
    if (word.length < 2) return nil;
    NSMutableArray *matching = [NSMutableArray array];
    [self wordsWithLetters:[self lettersForWord:word] prefix:@"" letterDict:dictionary results:matching];
    NSMutableArray *startingWith = [self wordsBegginningWith:word];
    [startingWith sortByKey:NAME_KEY];
    [matching removeObjectsInArray:startingWith];
    return [startingWith arrayByAddingObjectsFromArray:matching];
}

- (NSMutableArray*)wordsBegginningWith:(NSString*)word
{
    if (word.length < 2) return nil;
    NSMutableString *buffer = [NSMutableString string];
    NSMutableArray *results = [NSMutableArray array];
    NSDictionary *letterDict = dictionary;
    for (NSInteger i = 0; i < word.length; i++) {
        NSString *letter = [word substringWithRange:NSMakeRange(i, 1)];
        if (![[letterDict allKeys] containsObject:letter]) {
            return results;
        }
        [buffer appendString:letter];
        letterDict = letterDict[letter];
        if (i == word.length - 1) {
            [self populate:buffer letterDict:letterDict array:results];
            [results sortByKey:NAME_KEY];
            return results;
        }
    }
    return results;
}

- (NSString*)definitionForWord:(NSString*)word
{
    NSDictionary *letterDict = dictionary;
    for (NSInteger i = 0; i < word.length; i++) {
        NSString *letter = [word substringWithRange:NSMakeRange(i, 1)];
        if (![[letterDict allKeys] containsObject:letter]) {
            return nil;
        }
        letterDict = letterDict[letter];
        if (i == word.length - 1) {
            if ([[letterDict allKeys] containsObject:DEF_KEY]) {
                return letterDict[DEF_KEY];
            }
        }
    }
    return nil;
}

- (BOOL)isWordValid:(NSString*)word
{
    return [self definitionForWord:word] != nil;
}

- (void)loadDictionary
{
    NSString *path = [[NSBundle mainBundle] pathForResource:_path ofType:@"plist"];
    dictionary = [NSDictionary dictionaryWithContentsOfFile:path];
}

#pragma mark - Plist Creation

- (NSString*)readNextLineOfFile:(FILE*)file {
    NSUInteger bufferSize = 4096;
    char buffer[bufferSize];
    NSMutableString *result = [NSMutableString stringWithCapacity:bufferSize];
    NSUInteger charsRead = 0;
    do {
        // Look for end of line
        if (fscanf(file, "%4095[^\n]%n%*c", buffer, &charsRead) == 1) {
            [result appendFormat:@"%s", buffer];
        } else {
            break;
        }
    } while (charsRead == bufferSize - 1);
    return result;
}

- (void)createDictionary
{
    NSString *path = [[NSBundle mainBundle] pathForResource:_path ofType:@"txt"];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    FILE *file = fopen([path UTF8String], "r");
    while (!feof(file)) {
        NSString *line = [self readNextLineOfFile:file];
        NSString *word = [line componentsSeparatedByString:@" "][0];
        NSMutableDictionary *letterDict = dict;
        for (NSInteger i = 0; i < word.length; i++) {
            NSString *letter = [word substringWithRange:NSMakeRange(i, 1)];
            if (![[letterDict allKeys] containsObject:letter]) {
                letterDict[letter] = [[NSMutableDictionary alloc] init];
            }
            letterDict = letterDict[letter];
            if (i == word.length - 1) {
                [letterDict setObject:[[line substringFromIndex:word.length] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:DEF_KEY];
            }
        }
    }
    fclose(file);
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    [dict writeToFile:[[documentsDirectory stringByAppendingPathComponent:_path] stringByAppendingPathExtension:@"plist"] atomically:YES];
}

@end
