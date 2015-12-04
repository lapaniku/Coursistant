//
//  CollectionUtils.h
//  Coursistant Sceleton
//
//  Created by Andrew on 14.03.13.
//  Copyright (c) 2013 Andrew. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CollectionUtils : NSObject

+ (NSArray *) expandArray:(NSArray *)array nodeKey:(NSString *)nodeKey;

+ (NSDate *) extractDate:(NSString *)dateStr;

+ (NSString *) courseState:(NSDate *)startDate endDate:(NSDate *)endDate actual:(NSNumber *)actual archived:(BOOL)archived;

@end
