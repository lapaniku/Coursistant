//
//  KeyValueParser.h
//  Coursistant Sceleton
//
//  Created by Andrew on 10.01.13.
//  Copyright (c) 2013 Andrew. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ContentParser : NSObject {
    NSDictionary * (^handler)(NSDictionary *matchMap);
}

@property (nonatomic) NSString *pattern;
@property (nonatomic) NSArray *keys;

-(id) init: (NSString *)aPattern keys:(NSArray *)aKeys handler:(NSDictionary *(^)(NSDictionary *matchMap))aHandler;

-(NSArray *) parse:(NSString *)string;

+(BOOL) isInside:(NSString *)sample instring:(NSString *)string;

@end
