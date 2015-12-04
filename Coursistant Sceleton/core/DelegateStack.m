//
//  DelagateStack.m
//  Coursistant
//
//  Created by Andrew on 11.09.13.
//  Copyright (c) 2013 Altasapiens. All rights reserved.
//

#import "DelegateStack.h"

@implementation DelegateStack


-(id) init {
    self = [super init];
    delegateKeys = [[NSMutableSet alloc] init];
    return self;
}

-(void) useDelegate:(NSString *)delegateKey {
    [delegateKeys addObject:delegateKey];
}

-(void) freeDelegate:(NSString *)delegateKey {
    [delegateKeys removeObject:delegateKey];
}

-(BOOL) allDelegatesFree {
    return [delegateKeys count] == 0;
}


@end
