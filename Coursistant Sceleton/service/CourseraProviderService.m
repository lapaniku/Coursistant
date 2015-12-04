//
//  CourseraProviderService.m
//  Coursistant Sceleton
//
//  Created by Andrew on 21.02.13.
//  Copyright (c) 2013 Andrew. All rights reserved.
//

#import "CourseraProviderService.h"
#import "JSParser.h"
#import "ParserManager.h"


@implementation CourseraProviderService

CWL_SYNTHESIZE_SINGLETON_FOR_CLASS(CourseraProviderService);

- (id<ILoginManager>) loginManager:(id<ILoginDelegate>)delegate {
    
    if(loginManager == nil) {
        loginManager = [[CourseraLoginManager alloc] init:delegate];
    } else {
        loginManager.delegate = delegate;
    }
    return loginManager;
}

- (id<IProfileManager>) profileManager:(id<IProfileDelegate>)delegate {
    
    if(profileManager == nil) {
        profileManager = [[CourseraProfileManager alloc] init:delegate];
    } else {
        profileManager.delegate = delegate;
    }
    return profileManager;
}

- (id<IContentManager>) coursewareManager:(id<IContentDelegate>)delegate {
    
    if(coursewareManager == nil) {
        coursewareManager = [[CourseraCoursewareManager alloc] init:delegate parser:[[JSParser alloc] init:[ParserManager script:@"CourseraCoursewareParser"]]];
        
    } else {
        coursewareManager.delegate = delegate;
    }
    return coursewareManager;
}

- (id<IContentManager>) lectureManager:(id<IContentDelegate>)delegate {
/*
    if(lectureManager == nil) {
        lectureManager = [[CourseraPlayerManager alloc] init:delegate parser:[[JSParser alloc] init:[ParserManager script:@"CourseraPlayerCodeParser"]]];
        
    } else {
        coursewareManager.delegate = delegate;
    }
    return lectureManager;
*/
    return [[CourseraPlayerManager alloc] init:delegate parser:[[JSParser alloc] init:[ParserManager script:@"CourseraPlayerCodeParser"]]];
}

@end
