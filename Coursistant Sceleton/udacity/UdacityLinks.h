//
//  UdacityLinks.h
//  Coursistant Sceleton
//
//  Created by Andrew on 26.12.12.
//  Copyright (c) 2012 Andrew. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UdacityLinks : NSObject

+ (NSString *) Domain;

+ (NSURL *) LoginURL;

+ (NSURL *) BaseURL;

+ (NSURL *) ProfileURL;

+ (NSURL *) MyCoursesURL;

@end
