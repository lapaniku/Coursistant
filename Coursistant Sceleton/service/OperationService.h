//
//  NetworkService.h
//  Coursistant Sceleton
//
//  Created by Andrew on 01.03.13.
//  Copyright (c) 2013 Andrew. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CWLSynthesizeSingleton.h"

@interface OperationService : NSObject {
    NSOperationQueue *queue;
    NSObject *owner;
}

CWL_DECLARE_SINGLETON_FOR_CLASS(OperationService)

//+ (OperationService *)sharedOperationService;

-(void) manageOperation:(NSOperation *)operation owner:(NSObject *)someOwner;

-(void) cancelAllOperations;

@end
