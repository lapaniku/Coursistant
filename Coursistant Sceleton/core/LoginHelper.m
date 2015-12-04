//
//  LoginHelper.m
//  Coursistant Sceleton
//
//  Created by Andrew on 20.12.12.
//  Copyright (c) 2012 Andrew. All rights reserved.
//

#import "LoginHelper.h"

@implementation LoginHelper

static char const possibleChars[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";

+ (NSURLRequest *) createLoginRequest:(NSURL *)loginURL contentType:(NSString *)contentType referer:(NSString *)referer tokenName:(NSString *)tokenName tokenValue:(NSString *)tokenValue postData:(NSString *)postData
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:loginURL];
    
    [request setValue:@"*/*" forHTTPHeaderField:@"Accept"];
    [request setHTTPMethod: @"POST"];
    if(contentType != nil) {
        [request setValue:contentType forHTTPHeaderField:@"Content-Type"];
    }
    if(referer != nil) {
        [request setValue:referer forHTTPHeaderField:@"Referer"];
    }
    [request setValue:@"XMLHttpRequest" forHTTPHeaderField:@"X-Requested-With"];
    if(tokenValue != nil) {
        [request setValue:tokenValue forHTTPHeaderField:tokenName];        
    }
    if(postData != nil) {
        [request setHTTPBody: [postData dataUsingEncoding:NSUTF8StringEncoding]];
    }
        
    
    return request;
}

+ (void) createLoginCookie:(NSString *)domain token:(NSString *)token tokenKey:(NSString *)tokenKey
{
    NSDictionary *loginCookieDict = [NSMutableDictionary
                                   dictionaryWithObjectsAndKeys:domain, NSHTTPCookieDomain,
                                   tokenKey, NSHTTPCookieName,
                                   @"/", NSHTTPCookiePath,
                                   token, NSHTTPCookieValue,
                                   nil];
    
    NSHTTPCookie *loginCookie = [NSHTTPCookie cookieWithProperties:loginCookieDict];
    
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:loginCookie];
}

+ (void) logCookies:(NSURL *)url {
    
//    NSArray *cookies;
//    
//    if(url == nil) {
//        cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
//    } else {
//        cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:url];
//    }
    
//    NSLog(@"Cookies for URL:\n %@", [url description]);
//    
//    for (NSHTTPCookie *cookie in cookies) {
//        NSLog(@"Cookie: %@\n", [cookie description]);
//    }
}

+ (void) deleteCookies:(NSURL *)url {
    
    NSArray *cookies;
    
    if(url == nil) {
        cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
    } else {
        cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:url];
    }
    
//    NSLog(@"Cookies for deletion:\n %d", [cookies count]);
    
    for (NSHTTPCookie *cookie in cookies) {
//       NSLog(@"Cookie: %@\n", [cookie description]);
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
    }
}

+(NSString *) token:(int)size {
    unichar characters[size];
    for(int index=0; index < size; ++index)
    {
        characters[index] = possibleChars[arc4random_uniform(sizeof(possibleChars)-1)];
    }
    
    return [NSString stringWithCharacters:characters length:size];
}

@end
