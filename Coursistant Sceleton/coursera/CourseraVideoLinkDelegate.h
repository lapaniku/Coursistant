//
//  CourseraVideoLinkDelegate.h
//  Coursera Downloader
//
//  Created by Andrew on 17.12.12.
//  Copyright (c) 2012 Andrew. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CourseraVideoLinkDelegate <NSObject>

@required
- (void) lectureVideoURLReady:(NSURL *)url initialURL:(NSURL *)initialURL;

@end
