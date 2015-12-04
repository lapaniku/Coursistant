//
//  JSParser.h
//  Coursistant Sceleton
//
//  Created by Andrew on 01.02.13.
//  Copyright (c) 2013 Andrew. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IContentParser.h"
#import "JSEngine.h"

@interface JSParser : NSObject <IContentParser> {

    JSEngine *engine;
    NSString *parserCode;
}

-(id) init: (NSString *)jsFileName;

-(id) parseContent:(NSString *)page;

-(id) parseArray:(NSArray *)array;

+(NSString*) filterUnsafeJSON:(NSString*)jsonStr;

@end
