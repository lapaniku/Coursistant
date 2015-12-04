//
//  LoginHelper.h
//  Coursistant Sceleton
//
//  Created by Andrew on 20.12.12.
//  Copyright (c) 2012 Andrew. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LoginHelper : NSObject

+ (NSURLRequest *) createLoginRequest:(NSURL *)loginURL contentType:(NSString *)contentType referer:(NSString *)referer tokenName:(NSString *)tokenName tokenValue:(NSString *)tokenValue postData:(NSString *)postData;

+ (void) createLoginCookie:(NSString *)domain token:(NSString *)token tokenKey:(NSString *)tokenKey;

+ (void) logCookies:(NSURL *)url;

+ (void) deleteCookies:(NSURL *)url;

+(NSString *) token:(int)size;

@end
