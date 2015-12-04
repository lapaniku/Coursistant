//
//  JSParser.m
//  Coursistant Sceleton
//
//  Created by Andrew on 01.02.13.
//  Copyright (c) 2013 Andrew. All rights reserved.
//

#import "JSParser.h"
#import "JSEngine.h"

@implementation JSParser

- (id) init: (NSString *)aParserCode {
    
    self = [super init];
    engine = [[JSEngine alloc] init];
    parserCode = aParserCode;
    return self;
}

-(id) parseContent:(NSString *)content {
    
    NSString *encodedPage = [JSParser stringConvertedForJavasacript:content];
    
    NSString *executionCode = [parserCode stringByReplacingOccurrencesOfString:@"/*[PAGE]*/" withString:encodedPage];
    NSString *codeResult = [engine runJS:executionCode];
    if(codeResult) {
        return [NSJSONSerialization JSONObjectWithData:[codeResult dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
    } else {
        return nil;
    }
}

-(id) parseArray:(NSArray *)array {
    
    NSString* jsonArray = [JSParser filterUnsafeJSON:[[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:array options:0 error:nil] encoding:NSUTF8StringEncoding]];
    
    NSString *executionCode = [parserCode stringByReplacingOccurrencesOfString:@"/*[ARRAY]*/" withString:jsonArray];
    NSString *codeResult = [engine runJS:executionCode];
    if (codeResult) {
        return [NSJSONSerialization JSONObjectWithData:[codeResult dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
    } else {
        return nil;
    }
}


+ (NSString *)stringConvertedForJavasacript:(NSString *)str {
    // valid JSON object need to be an array or dictionary
    NSArray* arrayForEncoding = @[str];
    NSString* jsonString = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:arrayForEncoding options:0 error:nil] encoding:NSUTF8StringEncoding];
    
    NSString* escapedString = [JSParser filterUnsafeJSON:[jsonString substringWithRange:NSMakeRange(2, jsonString.length - 4)]];
    return [NSString stringWithFormat:@"\"%@\"", escapedString];
}

+ (NSString*) filterUnsafeJSON:(NSString*)jsonStr {
    if (jsonStr.length > 0) {
        NSMutableCharacterSet *unsafeSet = [NSMutableCharacterSet new];
        void (^addUnsafe)(NSInteger, NSInteger) = ^(NSInteger from, NSInteger to) {
            if (to > from) {
                [unsafeSet addCharactersInRange:NSMakeRange(from, (to - from) + 1)];
            } else {
                [unsafeSet addCharactersInRange:NSMakeRange(from, 1)];
            }
        };
        
        addUnsafe(0x0000, 0x001f);
        addUnsafe(0x007f, 0x009f);
        addUnsafe(0x00ad, 0);
        addUnsafe(0x0600, 0x0604);
        addUnsafe(0x070f, 0);
        addUnsafe(0x17b4, 0);
        addUnsafe(0x17b5, 0);
        addUnsafe(0x200c, 0x200f);
        addUnsafe(0x2028, 0x202f);
        addUnsafe(0x2060, 0x206f);
        addUnsafe(0xfeff, 0);
        addUnsafe(0xfff0, 0xffff);
        
        jsonStr = [[jsonStr componentsSeparatedByCharactersInSet:unsafeSet] componentsJoinedByString:@""];
    }
    return jsonStr;
}

@end
