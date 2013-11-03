//
//  SettingsDataSource.m
//  Frayze
//
//  Created by CJNevin on 3/11/2013.
//  Copyright (c) 2013 CJNevin. All rights reserved.
//

#import "SettingsDataSource.h"

@implementation SettingsDataSource

static const NSString *kSectionTitle = @"SectionTitle";
static const NSString *kSectionItems = @"SectionItems";

static const NSString *kTheme = @"Theme";
static const NSString *kThemeDefault = @"Light (Default)";
static const NSString *kThemeDark = @"Dark (Inverted)";
static const NSString *kThemeShift1 = @"Shift 1";
static const NSString *kThemeShift2 = @"Shift 2";
static const NSString *kThemeShift3 = @"Shift 3";

static const NSString *kGameType = @"Game Type";
static const NSString *kGameTypeDefault = @"Default";
static const NSString *kGameTypeFrayze = @"Checkered";

static const NSString *kCount = @"Tile Count";
static const NSString *kCountDefault = @"Default (100)";
static const NSString *kCountDouble = @"Double (200)";

@synthesize themeIndex, gameTypeIndex, countIndex;

+ (SettingsDataSource *)sharedInstance
{
    static SettingsDataSource *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[SettingsDataSource alloc] init];
    });
    return instance;
}

- (id)init
{
    self = [super init];
    if (self) {
        themeIndex = [[[NSUserDefaults standardUserDefaults] objectForKey:(NSString*)kTheme] unsignedIntegerValue];
        gameTypeIndex = [[[NSUserDefaults standardUserDefaults] objectForKey:(NSString*)kGameType] unsignedIntegerValue];
        countIndex = [[[NSUserDefaults standardUserDefaults] objectForKey:(NSString*)kCount] unsignedIntegerValue];
        
        sections = [NSMutableArray array];
        [sections addObject:@{kSectionTitle: kTheme,
                              kSectionItems: @[kThemeDefault, kThemeDark, kThemeShift1, kThemeShift2, kThemeShift3]}];
        [sections addObject:@{kSectionTitle: kGameType,
                              kSectionItems: @[kGameTypeDefault, kGameTypeFrayze]}];
        [sections addObject:@{kSectionTitle: kCount,
                              kSectionItems: @[kCountDefault, kCountDouble]}];
    }
    return self;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [sections[section][kSectionItems] count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return sections.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return sections[section][kSectionTitle];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    cell.textLabel.text = sections[indexPath.section][kSectionItems][indexPath.row];
    NSString *section = sections[indexPath.section][kSectionTitle];
    if ([section isEqualToString:(NSString*)kTheme]) {
        cell.accessoryType = themeIndex == indexPath.row ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    } else if ([section isEqualToString:(NSString*)kGameType]) {
        cell.accessoryType = gameTypeIndex == indexPath.row ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    } else if ([section isEqualToString:(NSString*)kCount]) {
        cell.accessoryType = countIndex == indexPath.row ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    }
    return cell;
}

#pragma mark - Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *section = sections[indexPath.section][kSectionTitle];
    if ([section isEqualToString:(NSString*)kTheme]) {
        themeIndex = indexPath.row;
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithUnsignedInteger:themeIndex] forKey:(NSString*)kTheme];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [[NSNotificationCenter defaultCenter] postNotificationName:THEME_CHANGED object:nil];
        [tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationFade];
    } else if ([section isEqualToString:(NSString*)kGameType]) {
        gameTypeIndex = indexPath.row;
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithUnsignedInteger:gameTypeIndex] forKey:(NSString*)kGameType];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationFade];
    } else if ([section isEqualToString:(NSString*)kCount]) {
        countIndex = indexPath.row;
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithUnsignedInteger:countIndex] forKey:(NSString*)kCount];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationFade];
    }
}

@end
