//
//  SettingsHelper.h
//  Coursistant
//
//  Created by Andrei Lapanik on 28.03.14.
//  Copyright (c) 2014 Altasapiens. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SettingsHelper : NSObject

+(BOOL) isLanguageEqualToDefault:(NSString *)languageCode;

+(BOOL) isDefaultLanguageDefined;

+(NSString *) defaultLanguage;

@end
