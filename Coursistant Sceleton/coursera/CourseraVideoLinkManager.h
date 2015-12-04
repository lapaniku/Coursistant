//
//  CourseraVideoLinkManager.h
//  Coursera Downloader
//
//  Created by Andrew on 17.12.12.
//  Copyright (c) 2012 Andrew. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CourseraVideoLinkDelegate.h"

@interface CourseraVideoLinkManager : NSObject {
    
    NSOperationQueue *serialQueue;
}

@property(nonatomic, assign) id <CourseraVideoLinkDelegate> videoLinkDelegate;

-(id) initWithDelegate: (id <CourseraVideoLinkDelegate>) delegate;

-(void) requestSingleVideoLink:(NSString *)lectureLink;

-(void) requestSerialVideoLink:(NSString *)lectureLink;

@end
