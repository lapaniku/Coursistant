//
//  UdacityLoginManager.h
//  Coursistant Sceleton
//
//  Created by Andrew on 20.12.12.
//  Copyright (c) 2012 Andrew. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ILoginDelegate.h"
#import "ILoginManager.h"
#import "AFHTTPRequestOperation.h"
#import "GlobalConst.h"

@interface UdacityLoginManager : NSObject <ILoginManager> {
    
    NSString *postData;
    AFHTTPRequestOperation *openSessionOperation;

}

@property(nonatomic, assign) id <ILoginDelegate> delegate;

+ (NSString *) extractToken;

@end
