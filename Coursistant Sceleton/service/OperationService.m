//
//  NetworkService.m
//  Coursistant Sceleton
//
//  Created by Andrew on 01.03.13.
//  Copyright (c) 2013 Andrew. All rights reserved.
//

#import "OperationService.h"
#import "CWLSynthesizeSingleton.h"

@interface OperationService ()
@end

@implementation OperationService

CWL_SYNTHESIZE_SINGLETON_FOR_CLASS(OperationService);

static void *queueOperationCountContext;

// must be singleton

-(id) init {
    
    self = [super init];
    queue = [[NSOperationQueue alloc] init];
    [queue addObserver: self forKeyPath: @"operationCount" options: NSKeyValueObservingOptionNew context: &queueOperationCountContext];
    return self;
}

-(void) manageOperation:(NSOperation *)operation owner:(NSObject *)someOwner {
    if(owner != nil) {
            
        if(owner != someOwner) {
            // some exception
        }
    } else {
        owner = someOwner;
    }
    if(queue.operationCount == 0) {
        // show spinner
        [self postOperationsStarted];
    }
    [queue addOperation:operation];
    
}

-(void) cancelAllOperations {
    [queue cancelAllOperations];
    // hide spinner
    [self postOperationsFinished];
}

- (void) observeValueForKeyPath:(NSString *) keyPath ofObject:(id) object change:(NSDictionary *) change context:(void *) context {
    if (context == &queueOperationCountContext && [@"operationCount" isEqual: keyPath]) {
        if(queue.operationCount == 0) {
            // hide spinner
            [self postOperationsFinished];
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

-(void) postOperationsStarted {
    NSNotification *notif = [NSNotification notificationWithName:@"operationsStarted"
                                                          object:self
                                                        userInfo:nil];
    [[NSNotificationCenter defaultCenter] postNotification:notif];
}

-(void) postOperationsFinished {
    NSNotification *notif = [NSNotification notificationWithName:@"operationsFinished"
                                                          object:self
                                                        userInfo:nil];
    [[NSNotificationCenter defaultCenter] postNotification:notif];    
}

@end
