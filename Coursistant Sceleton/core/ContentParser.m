//
//  KeyValueParser.m
//  Coursistant Sceleton
//
//  Created by Andrew on 10.01.13.
//  Copyright (c) 2013 Andrew. All rights reserved.
//

#import "ContentParser.h"

@implementation ContentParser

@synthesize pattern;
@synthesize keys;

- (id) init: (NSString *)aPattern keys:(NSArray *)aKeys handler:(NSDictionary *(^)(NSDictionary *matchMap))aHandler
{
    self = [super init];
    self.pattern = aPattern;
    self.keys = aKeys;
    handler = [aHandler copy];
    return self;
}

- (NSArray *) parse:(NSString *)string {
    
    NSMutableArray *result = [[NSMutableArray alloc] init];
    NSArray *matches = [ContentParser runRegex:self.pattern string:string];
    for (NSTextCheckingResult* match in matches) {
        NSMutableDictionary *matchMap = [[NSMutableDictionary alloc] initWithCapacity:[self.keys count]];
        for(int i = 0; i < [self.keys count]; i++) {
            NSString *key = [self.keys objectAtIndex:i];
            NSString *value = [[string substringWithRange:[match rangeAtIndex:i+1]] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            [matchMap setValue:value forKey:key];
        }
        if(handler != nil) {
            
            NSDictionary *handleResult = handler(matchMap);
            if(handleResult != nil) {
                
                [result addObject:handleResult];
            }
        } else {
                
            [result addObject:matchMap];
        }
        
    }
    return result;
}

+(NSArray *) runRegex:(NSString *)pattern string:(NSString *)string {
    
    NSError  *error  = NULL;
    NSRegularExpression *regex = [NSRegularExpression
                                  regularExpressionWithPattern:pattern
                                  options:NSRegularExpressionDotMatchesLineSeparators
                                  error:&error];
    
    // todo: check error
    NSArray *items = [regex matchesInString:string options:0 range:NSMakeRange(0, [string length])];
    
    return items;
}

+(BOOL) isInside:(NSString *)sample instring:(NSString *)string {
    
    NSArray *result = [ContentParser runRegex:sample string:string];
    return [result count] > 0;
}


@end
