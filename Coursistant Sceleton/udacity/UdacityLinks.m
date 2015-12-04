//
//  UdacityLinks.m
//  Coursistant Sceleton
//
//  Created by Andrew on 26.12.12.
//  Copyright (c) 2012 Andrew. All rights reserved.
//

#import "UdacityLinks.h"

@implementation UdacityLinks

+ (NSString *) Domain {
    
    return @"www.udacity.com";
}

+ (NSURL *) LoginURL {
    
//    return [[NSURL alloc] initWithScheme:@"http" host:[UdacityLinks Domain] path:@"/ajax"];
    return [[NSURL alloc] initWithScheme:@"https" host:[UdacityLinks Domain] path:@"/api/session"];
}

+ (NSURL *) BaseURL {
    
    return [[NSURL alloc] initWithScheme:@"https" host:[UdacityLinks Domain] path:@"/"];
}

+ (NSURL *) ProfileURL {
    
    return [[NSURL alloc] initWithScheme:@"https" host:[UdacityLinks Domain] path:@"/api/users/me"];
}

+ (NSURL *) MyCoursesURL {
    
    return [[NSURL alloc] initWithScheme:@"https" host:[UdacityLinks Domain] path:@"/my_courses "];
}

@end
