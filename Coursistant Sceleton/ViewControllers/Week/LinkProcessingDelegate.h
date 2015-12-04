//
//  LinkProcessingDelegate.h
//  Coursistant
//
//  Created by Andrei Lapanik on 25.03.14.
//  Copyright (c) 2014 Altasapiens. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IContentDelegate.h"

@interface LinkProcessingDelegate : NSObject <IContentDelegate> {
    
    NSMutableDictionary *linkProcessingMap;
}

-(id) init;

-(void) registerBlock:(void (^)(NSArray*))processingBlock forLink:(NSString *)link;

-(void) contentExtracted:(NSArray *)items;

- (void) contentError:(NSError *)error;

- (void) notifyDelay;

@end
