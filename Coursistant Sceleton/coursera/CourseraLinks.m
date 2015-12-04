//
//  CourseraLinks.m
//  Coursistant Sceleton
//
//  Created by Andrew on 21.02.13.
//  Copyright (c) 2013 Andrew. All rights reserved.
//

#import "CourseraLinks.h"

@implementation CourseraLinks

+ (NSURL *) LoginURL {
    
//    return [[NSURL alloc] initWithScheme:@"https" host:@"www.coursera.org" path:@"/maestro/api/user/login"];
    return [[NSURL alloc] initWithScheme:@"https" host:@"accounts.coursera.org" path:@"/api/v1/login"];    
}

+ (NSURL *) AccountsURL {
    
    //    return [[NSURL alloc] initWithScheme:@"https" host:@"www.coursera.org" path:@"/maestro/api/user/login"];
    return [[NSURL alloc] initWithScheme:@"https" host:@"accounts.coursera.org" path:@"/"];
}

+ (NSURL *) BaseURL {
    
    return [[NSURL alloc] initWithScheme:@"https" host:@"www.coursera.org" path:@"/"];
}

+ (NSURL *) ClassURL:(NSString *)classPath {
    
    return [[NSURL alloc] initWithScheme:@"https" host:@"class.coursera.org" path:classPath];
}

+ (NSURL *) ProfileURL:(NSString *) userID {
    NSString *path = [[NSString alloc] initWithFormat:@"/maestro/api/topic/list_my?user_id=%@", userID];
//    NSString *path = [[NSString alloc] initWithFormat:@"/api/openCourseMemberships.v1/?q=findByUser&userId=%@", userID];
//    NSString *path = @"/maestro/api/topic/list2_combined";
    return [[NSURL alloc] initWithScheme:@"https" host:@"www.coursera.org" path:path];
}

+ (NSURL *) OpenURL:(NSString *) homeLink {
    
//    NSString *urlString = [[NSString alloc] initWithFormat:@"%@/auth/auth_redirector?type=login&subtype=normal", homeLink];
//    return [[NSURL alloc] initWithString: urlString];
    return [[NSURL alloc] initWithScheme:@"https" host:@"accounts.coursera.org" path:@"/api/v1/login"];
}

+ (NSString *) Referer {
    return @"https://www.coursera.org/account/signin";
}

@end
