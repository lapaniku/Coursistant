//
//  SettingsHelper.m
//  Coursistant
//
//  Created by Andrei Lapanik on 28.03.14.
//  Copyright (c) 2014 Altasapiens. All rights reserved.
//

#import "SettingsHelper.h"

@implementation SettingsHelper

+(BOOL) isLanguageEqualToDefault:(NSString *)languageCode {
    
    if([SettingsHelper isDefaultLanguageDefined] && languageCode != nil && ![languageCode isEqualToString:@""]) {
        NSString *defaultLanguage = [SettingsHelper defaultLanguage];
        return [defaultLanguage isEqualToString:[languageCode lowercaseString]];
    } else {
        return NO;
    }
}


+(BOOL) isDefaultLanguageDefined {
    NSString *defaultLanguage = [SettingsHelper defaultLanguage];
    return defaultLanguage != nil && ![defaultLanguage isEqualToString:@""];
}

+(NSString *) defaultLanguage {
    return [[[NSUserDefaults standardUserDefaults] objectForKey:@"defaultLanguage"] lowercaseString];
}

@end
