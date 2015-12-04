//
//  CollectionUtils.m
//  Coursistant Sceleton
//
//  Created by Andrew on 14.03.13.
//  Copyright (c) 2013 Andrew. All rights reserved.
//

#import "CollectionUtils.h"

@implementation CollectionUtils

+ (NSArray *) expandArray:(NSArray *)array nodeKey:(NSString *)nodeKey {
    
    NSMutableArray *result = [[NSMutableArray alloc] init];
    for (NSDictionary *item in array) {
        [result addObject:item];
        NSArray *nodes = [item valueForKey:nodeKey];
        for (NSDictionary *node in nodes) {
            [node setValue:[item valueForKey:@"title"] forKey:@"category"];
            [result addObject:node];
        }
    }
    return result;
}

+ (NSDate *) extractDate:(NSString *)dateStr {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *enUSPOSIXLocale = [[NSLocale alloc]
                                 initWithLocaleIdentifier:@"en_US_POSIX"];
    [dateFormatter setLocale:enUSPOSIXLocale];
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    [dateFormatter setTimeZone:timeZone];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    return dateStr == (id)[NSNull null] ? nil : [dateFormatter dateFromString:[dateStr substringToIndex:10]];
}


+ (NSString *) courseState:(NSDate *)startDate endDate:(NSDate *)endDate actual:(NSNumber *)actual archived:(BOOL)archived {
    
    if (startDate == nil) {
        startDate = [CollectionUtils extractDate:@"2999-12-30"];
    }
    
    if (endDate == nil) {
        endDate = [CollectionUtils extractDate:@"2999-12-31"];
    }

    NSDate *now = [NSDate date];
    if (actual.intValue == 1 && !([startDate compare:now] == NSOrderedDescending) && !archived && ([endDate compare:now] == NSOrderedDescending) ) {
        return @"Current";
    }
    else if ( ([startDate compare:now] == NSOrderedDescending)  && !archived){
        return @"Upcoming";
    } else {
        return @"Archived";
    }
}

@end
