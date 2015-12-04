//
//  UdacityProviderService.h
//  Coursistant Sceleton
//
//  Created by Andrew on 07.02.13.
//  Copyright (c) 2013 Andrew. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IProviderService.h"
#import "UdacityLoginManager.h"
#import "UdacityProfileManager.h"
#import "BasicContentManager.h"
#import "BasicJSONManager.h"

@interface UdacityProviderService : NSObject <IProviderService> {
    
    UdacityLoginManager *loginManager;
    UdacityProfileManager *profileManager;
    BasicJSONManager *coursewareManager;
    BasicContentManager *lectureManager;
}

CWL_DECLARE_SINGLETON_FOR_CLASS(UdacityProviderService);

@end
