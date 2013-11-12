//
//  CNScrabbleDictionary.m
//  Frayze
//
//  Created by CJNevin on 13/11/2013.
//  Copyright (c) 2013 CJNevin. All rights reserved.
//

#import "CNScrabbleDictionary.h"
#import <stdio.h>

#define DEF_KEY @"Def"

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
