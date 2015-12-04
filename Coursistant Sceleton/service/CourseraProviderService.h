//
//  CourseraProviderService.h
//  Coursistant Sceleton
//
//  Created by Andrew on 21.02.13.
//  Copyright (c) 2013 Andrew. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IProviderService.h"
#import "CourseraLoginManager.h"
#import "CourseraProfileManager.h"
#import "BasicContentManager.h"
#import "CourseraCoursewareManager.h"
#import "CourseraPlayerManager.h"

@interface CourseraProviderService : NSObject <IProviderService> {
    
    CourseraLoginManager *loginManager;
    CourseraProfileManager *profileManager;
    CourseraCoursewareManager *coursewareManager;
    CourseraPlayerManager *lectureManager;
}

CWL_DECLARE_SINGLETON_FOR_CLASS(CourseraProviderService);

@end
