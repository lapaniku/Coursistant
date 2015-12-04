	//
//  UdacityLoginManager.m
//  Coursistant Sceleton
//
//  Created by Andrew on 20.12.12.
//  Copyright (c) 2012 Andrew. All rights reserved.
//

#import "UdacityLoginManager.h"
#import "ILoginDelegate.h"
#import "CSTJSONRequestOperation.h"
#import "LoginHelper.h"
#import "UdacityLinks.h"
#import "AFHTTPRequestOperation.h"
#import "OfflineDataManager.h"

@implementation UdacityLoginManager

@synthesize delegate;

static void *myContextPointer;

- (id) init: (id <ILoginDelegate>) aDelegate {
    
    self = [super init];
    [self setDelegate:aDelegate];
    return self;
}

- (void) doLogin: (NSString *) username password: (NSString *) password {
    
    postData = [self createPostData:username password:password];
        
    if([OfflineDataManager sharedOfflineDataManager].online) {
//        if(![self isSessionAlive]) {
            NSURLRequest *openSessionRequest = [[NSURLRequest alloc] initWithURL:[UdacityLinks BaseURL]];
            openSessionOperation = [[AFHTTPRequestOperation alloc] initWithRequest:openSessionRequest];
            
            __unsafe_unretained UdacityLoginManager *ulm = self;
            [openSessionOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                if([OfflineDataManager isConnectionNotAvailableError:error]) {
                    
                    [ulm useOfflineData];
                } else {
                    [ulm.delegate loginProtocolError:error provider:@"Udacity"];
                }
            }];
            [openSessionOperation addObserver:self forKeyPath:@"response" options:NSKeyValueObservingOptionNew  context:&myContextPointer];
            
            [[OperationService sharedOperationService] manageOperation:openSessionOperation owner:self];
//        } else {
//            [self useOfflineData];
//        }
    } else {
            
        [self useOfflineData];
    }

}

- (void) useOfflineData {
    NSString *userID = [[OfflineDataManager sharedOfflineDataManager] userIDFor:@"Udacity"];
    if(userID != nil) {
        [delegate loggedInSuccessfully:userID provider:@"Udacity"];
    } else {
        [delegate loginErrorWithMessage:@"No session stored for Udacity provider." provider:@"Udacity"];
    }
}

- (BOOL) isSessionAlive {
    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[UdacityLinks BaseURL]];
    
    for (NSHTTPCookie *cookie in cookies) {
        if ([[cookie name] isEqualToString:@"DgU00"]) {
            return [cookie.expiresDate compare:[NSDate date]] == NSOrderedDescending;
        }
    }
    
    return NO;
}

- (void) deleteCookies {
    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[UdacityLinks BaseURL]];
    
//    for (NSHTTPCookie *cookie in cookies) {
//        if ([[cookie name] isEqualToString:@"sessionid"]) {
//            [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
//            
//        }
//    }

     for (NSHTTPCookie *cookie in cookies) {
        
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
    }
}

- (NSString *) createPostData:(NSString *)username password:(NSString *)password
{
    return /*[*/[[NSString alloc] initWithFormat:@"{\"udacity\":{\"username\":\"%@\",\"password\":\"%@\"}}", username, password]  /*stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"]*/;

}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if(context != &myContextPointer) {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    } else {
        if ([keyPath isEqualToString:@"response"]) {
            [self authorize];
            [object removeObserver:self forKeyPath:@"response" context:&myContextPointer];
        }
    }
}

+ (NSString *) extractToken {
    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[UdacityLinks BaseURL]];
    
    for (NSHTTPCookie *cookie in cookies) {
        //NSLog(@">>> %@", [cookie description]);
        if([@"XSRF-TOKEN" isEqualToString:cookie.name]) {
        
            return cookie.value;
        }
    }
    return nil;
}

- (void) authorize {

    if([OfflineDataManager sharedOfflineDataManager].online) {
        
        NSString *token = [UdacityLoginManager extractToken];
        
        NSURLRequest *loginRequest = [LoginHelper createLoginRequest:[UdacityLinks LoginURL] contentType:@"application/json;charset=utf-8" referer:[[UdacityLinks BaseURL] absoluteString] tokenName:@"X-XSRF-TOKEN" tokenValue:token postData:postData];
        

        
        CSTJSONRequestOperation *loginOperation = [CSTJSONRequestOperation JSONRequestOperationWithRequest:loginRequest success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
            
            NSDictionary *account = [JSON valueForKey:@"account"];
            NSDictionary *session = [JSON valueForKey:@"session"];
            
            NSString *userID;
            if((account != nil) && (session != nil)) {
                userID = [account valueForKey:@"key"];
            }
            if(userID) {
                [[OfflineDataManager sharedOfflineDataManager] updateUserIDFor:@"Udacity" userID:userID];
                [delegate loggedInSuccessfully:userID provider:@"Udacity"];
                [UdacityLoginManager extractToken];
            } else {
                userID = [[OfflineDataManager sharedOfflineDataManager] userIDFor:@"Udacity"];
                
                if(userID) {
                    [delegate loggedInSuccessfully:userID provider:@"Udacity"];
                } else {
                    [delegate loginErrorWithMessage:nil provider:@"Udacity"];
                }
            }
            
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
            
            if([OfflineDataManager isConnectionNotAvailableError:error]) {
                
                [self useOfflineData];
            } else {
                [delegate loginProtocolError:error provider:@"Udacity"];
            }
        } responseFilter:^NSData *(NSData *response) {
            NSString *responseString = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
            NSArray *lines = [responseString componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
            if([lines count] > 0) {
                
                return [[lines objectAtIndex:[lines count]-1] dataUsingEncoding:NSUTF8StringEncoding];
            } else {
                return response;
            }
        }];
        
        [[OperationService sharedOperationService] manageOperation:loginOperation owner:self];
    } else {
        
        [self useOfflineData];
    }
}

@end
