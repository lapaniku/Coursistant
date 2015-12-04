//
//  CoursistantIAPHelper.m
//  Coursistant
//
//  Created by Andrei Lapanik on 01.04.14.
//  Copyright (c) 2014 Altasapiens. All rights reserved.
//

#import "CoursistantIAPHelper.h"

@implementation CoursistantIAPHelper

+ (CoursistantIAPHelper *)sharedInstance {
    static dispatch_once_t once;
    static CoursistantIAPHelper * sharedInstance;
    dispatch_once(&once, ^{
        NSSet * productIdentifiers = [NSSet setWithObjects:
                                      [CoursistantIAPHelper allLanguagesProductKey],
                                      nil];
        sharedInstance = [[self alloc] initWithProductIdentifiers:productIdentifiers];
    });
    return sharedInstance;
}

+(NSString *) allLanguagesProductKey {
    return @"com.altasapiens.Coursistant.intsubtitles";
}

-(BOOL) isAllLanguagesAvailable {
    return [self productPurchased:[CoursistantIAPHelper allLanguagesProductKey]];
}

@end
