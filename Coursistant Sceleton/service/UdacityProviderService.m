//
//  UdacityProviderService.m
//  Coursistant Sceleton
//
//  Created by Andrew on 07.02.13.
//  Copyright (c) 2013 Andrew. All rights reserved.
//

#import "UdacityProviderService.h"
#import "BasicContentManager.h"
#import "JSParser.h"
#import "ParserManager.h"
#import "OfflineDataManager.h"

@implementation UdacityProviderService

CWL_SYNTHESIZE_SINGLETON_FOR_CLASS(UdacityProviderService);

- (id<ILoginManager>) loginManager:(id<ILoginDelegate>)delegate {
    
    if(loginManager == nil) {
        loginManager = [[UdacityLoginManager alloc] init:delegate];
    } else {
        loginManager.delegate = delegate;
    }
    return loginManager;
}

- (id<IProfileManager>) profileManager:(id<IProfileDelegate>)delegate{
    
    if(profileManager == nil) {
        profileManager = [[UdacityProfileManager alloc] init:delegate];
    } else {
        profileManager.delegate = delegate;
    }
    return profileManager;
    
}

- (id<IContentManager>) coursewareManager:(id<IContentDelegate>)delegate {
    
    if(coursewareManager == nil) {
        coursewareManager = [[BasicJSONManager alloc] init:delegate parser:[[JSParser alloc] init:[ParserManager script:@"UdacityCoursewareParser"]]];
        coursewareManager.onlineDataHandler = ^(NSString *title, NSArray *contentData) {
            
            [[OfflineDataManager sharedOfflineDataManager] updateCoursewareFor:@"Udacity" courseName:title courseware:contentData];
        };
        coursewareManager.offlineDataHandler = ^(NSString *title) {
            
            return [[OfflineDataManager sharedOfflineDataManager] coursewareFor:@"Udacity" courseName:title];
        };

    } else {
        coursewareManager.delegate = delegate;
    }
    return coursewareManager;
}

- (id<IContentManager>) lectureManager:(id<IContentDelegate>)delegate {
    
    return nil;
}

@end
