//
//  CourseraLinks.h
//  Coursistant Sceleton
//
//  Created by Andrew on 21.02.13.
//  Copyright (c) 2013 Andrew. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CourseraLinks : NSObject

+ (NSURL *) LoginURL;

+ (NSURL *) BaseURL;

+ (NSURL *) ProfileURL:(NSString *)userID;

+ (NSURL *) OpenURL:(NSString *)homeLink;

+ (NSURL *) ClassURL:(NSString *)classPath;

+ (NSString *) Referer;

+ (NSURL *) AccountsURL;

@end
