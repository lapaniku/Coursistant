//
//  LinkProcessingDelegate.m
//  Coursistant
//
//  Created by Andrei Lapanik on 25.03.14.
//  Copyright (c) 2014 Altasapiens. All rights reserved.
//

#import "LinkProcessingDelegate.h"
#import "Flurry.h"

@implementation LinkProcessingDelegate

-(id) init {
    self = [super init];
    linkProcessingMap = [[NSMutableDictionary alloc] init];
    return self;
}

-(void) registerBlock:(void (^)(NSArray*))processingBlock forLink:(NSString *)link {
    [linkProcessingMap setValue:processingBlock forKey:link];
}

-(void) contentExtracted:(NSArray *)items {
    
    NSString *key = [items objectAtIndex:0];
    void (^linkProcessingBlock) (NSArray*) = [linkProcessingMap valueForKey:key];
    if(linkProcessingBlock != nil) {
        linkProcessingBlock(items);
    }
}

- (void) contentError:(NSError *)error {
    NSDictionary *eventParam = [NSDictionary dictionaryWithObjectsAndKeys: [error localizedDescription], @"error", nil];
    [Flurry logEvent:@"video_contentError" withParameters:eventParam];
    
}

- (void) notifyDelay {
    
}

@end
