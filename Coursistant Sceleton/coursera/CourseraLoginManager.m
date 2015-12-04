//
//  CourseraLoginManager.m
//  Coursistant Sceleton
//
//  Created by Andrew on 21.02.13.
//  Copyright (c) 2013 Andrew. All rights reserved.
//

#import "CourseraLoginManager.h"
#import "CSTJSONRequestOperation.h"
#import "CourseraLinks.h"
#import "LoginHelper.h"
#import "OfflineDataManager.h"
#import "ContentParser.h"

@implementation CourseraLoginManager

@synthesize delegate;

- (id) init: (id <ILoginDelegate>) aDelegate {
    
    self = [super init];
    [self setDelegate:aDelegate];
    return self;
}

- (void) doLogin: (NSString *) username password: (NSString *) password {
    
    if([OfflineDataManager sharedOfflineDataManager].online) {
//        if(![self isSessionAlive]) {
            NSString *postData = [self createPostData:username passowrd:password];
            NSString *token = [LoginHelper token:24];
            
            [self createCourseraCookie: token];
            
            NSURLRequest *loginRequest = [LoginHelper createLoginRequest:[CourseraLinks LoginURL] contentType:@"application/x-www-form-urlencoded; charset=UTF-8" referer:@"https://accounts.coursera.org/signin?post_redirect=https%3A%2F%2Fwww.coursera.org%2F" tokenName:@"X-CSRFToken" tokenValue:token postData:postData];
            
            AFHTTPRequestOperation *loginOperation = [[AFHTTPRequestOperation alloc] initWithRequest:loginRequest];
            [loginOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                

                NSURLRequest *dataRequest = [[NSURLRequest alloc] initWithURL:[CourseraLinks BaseURL]];
                AFHTTPRequestOperation *dataOperation = [[AFHTTPRequestOperation alloc] initWithRequest:dataRequest];
                __block AFHTTPRequestOperation *blockOperation = dataOperation;
                [dataOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                    
                    ContentParser *idParser = [[ContentParser alloc] init:@"\\\\\"id\\\\\"\\:([\\d]+)," keys:@[@"id"] handler:nil];
                    NSArray *parseResult = [idParser parse:blockOperation.responseString];
                    if(parseResult.count == 0) {
                        NSURL *url = [NSURL URLWithString:@"http://coursistant.com/id.txt"];
                        NSError* error;
                        NSString *content = [NSString stringWithContentsOfURL:url encoding:NSASCIIStringEncoding error:&error];
                        if(!error) {
                            ContentParser *idParser = [[ContentParser alloc] init:content keys:@[@"id"] handler:nil];
                            parseResult = [idParser parse:blockOperation.responseString];
                        }
                    }
                    
                    NSString *userID = [[parseResult objectAtIndex:0] objectForKey:@"id"];
                    if(userID) {
                        [[OfflineDataManager sharedOfflineDataManager] updateUserIDFor:@"Coursera" userID:userID];
                        [delegate loggedInSuccessfully:userID provider:@"Coursera"];
                    } else {
                        userID = [[OfflineDataManager sharedOfflineDataManager] userIDFor:@"Coursera"];

                        if(userID) {
                            [delegate loggedInSuccessfully:userID provider:@"Coursera"];
                        } else {                            
                            [delegate loginErrorWithMessage:nil provider:@"Coursera"];
                        }
                    }
                    
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    if([OfflineDataManager isConnectionNotAvailableError:error]) {
                        [self useOfflineData];
                    } else {
                        [delegate loginProtocolError:error provider:@"Coursera"];
                    }
                }];
                [[OperationService sharedOperationService] manageOperation:dataOperation owner:self];
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                if([OfflineDataManager isConnectionNotAvailableError:error]) {
                    [self useOfflineData];
                } else {
                    [delegate loginProtocolError:error provider:@"Coursera"];
                }
            }];
                        
            [[OperationService sharedOperationService] manageOperation:loginOperation owner:self];
//        } else {
//            [self useOfflineData];
//        }
    } else {
        [self useOfflineData];
    }
}

-(BOOL) isSessionAlive {
    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[CourseraLinks AccountsURL]];
    
    for (NSHTTPCookie *cookie in cookies) {
        if ([[cookie name] isEqualToString:@"CAUTH"]) {
            return [cookie.expiresDate compare:[NSDate date]] == NSOrderedDescending;
        }
    }
    
    return NO;
}

-(void) deleteCookies {
   NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[CourseraLinks BaseURL]];
   for (NSHTTPCookie *cookie in cookies) {
       
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
            
        
    }
}

-(NSString *) createPostData:(NSString *)username passowrd:(NSString *)password {
    return [[NSString stringWithFormat:@"email=%@&password=%@&webrequest=true", username, [[[password stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] stringByReplacingOccurrencesOfString:@"=" withString:@"%3D"] stringByReplacingOccurrencesOfString:@"&" withString:@"%26"]] stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"] ;
}

- (void) createCourseraCookie: (NSString *) token {
    NSDictionary *courseraCookieDict = [NSMutableDictionary
                                        dictionaryWithObjectsAndKeys:@"accounts.coursera.org", NSHTTPCookieDomain,
                                        @"csrftoken", NSHTTPCookieName,
                                        @"/", NSHTTPCookiePath,
                                        token, NSHTTPCookieValue,
                                        nil, NSHTTPCookieExpires, nil];
    
    NSHTTPCookie *courseraCookie = [NSHTTPCookie cookieWithProperties:courseraCookieDict];
    
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:courseraCookie];
}

-(void) useOfflineData {
    NSString *userID = [[OfflineDataManager sharedOfflineDataManager] userIDFor:@"Coursera"];
    if(userID != nil) {
        [delegate loggedInSuccessfully:userID provider:@"Coursera"];
    } else {
        [delegate loginErrorWithMessage:@"No session stored for Coursera provider." provider:@"Coursera"];
    }
}

@end
