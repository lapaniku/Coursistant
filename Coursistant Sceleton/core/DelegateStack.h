//
//  DelagateStack.h
//  Coursistant
//
//  Created by Andrew on 11.09.13.
//  Copyright (c) 2013 Altasapiens. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DelegateStack : NSObject {
    
    NSMutableSet *delegateKeys;
}

-(void) useDelegate:(NSString *)delegateKey;

-(void) freeDelegate:(NSString *)delegateKey;

-(BOOL) allDelegatesFree;

@end
