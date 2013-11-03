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

static const NSString *kSize = @"Board Size";
static const NSString *kSizeDefault = @"Default 15x15";
static const NSString *kSizeLarge = @"Large 25x25";

@synthesize themeIndex, sizeIndex;

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
        sizeIndex = [[[NSUserDefaults standardUserDefaults] objectForKey:(NSString*)kSize] unsignedIntegerValue];
        
        sections = [NSMutableArray array];
        [sections addObject:@{kSectionTitle: kTheme,
                              kSectionItems: @[kThemeDefault, kThemeDark, kThemeShift1, kThemeShift2, kThemeShift3]}];
        [sections addObject:@{kSectionTitle: kSize,
                              kSectionItems: @[kSizeDefault, kSizeLarge]}];
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
    } else if ([section isEqualToString:(NSString*)kSize]) {
        cell.accessoryType = sizeIndex == indexPath.row ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
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
    } else if ([section isEqualToString:(NSString*)kSize]) {
        sizeIndex = indexPath.row;
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithUnsignedInteger:sizeIndex] forKey:(NSString*)kSize];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationFade];
    }
}

@end
