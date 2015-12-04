//
//  UdacityProfileManager.h
//  Coursistant Sceleton
//
//  Created by Andrew on 26.12.12.
//  Copyright (c) 2012 Andrew. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IProfileManager.h"
#import "AFHTTPRequestOperation.h"

@interface UdacityProfileManager : NSObject <IProfileManager> {
    
    NSOperationQueue *queue;
    AFHTTPRequestOperation *openSessionOperation;

}

@property(nonatomic, assign) id <IProfileDelegate> delegate;


@end
