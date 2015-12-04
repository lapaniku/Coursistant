//
//  CourseraLoginManager.m
//  Coursera Downloader
//
//  Created by Andrew on 21.11.12.
//  Copyright (c) 2012 Andrew. All rights reserved.
//

#import "CourseraCourseLoginManager.h"
#import "AFHTTPRequestOperation.h"
#import "CourseraLinks.h"
#import "OperationService.h"
#import "LoginHelper.h"

@implementation CourseraCourseLoginManager

@synthesize delegate;
@synthesize homeLink;

static void *myContextPointer;


- (id) init:(id<ILoginDelegate>)aDelegate {
    
    self = [super init];
    self.delegate = aDelegate;
    return self;
}

- (void) doLogin: (NSString *) aUsername password: (NSString *) aPassword {
    
    if(![CourseraCourseLoginManager isSessionAvailable:homeLink]) {
        username = aUsername;
        password = aPassword;
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[CourseraLinks OpenURL:homeLink]];
        
        openOperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        [openOperation addObserver:self forKeyPath:@"response" options:NSKeyValueObservingOptionNew  context:&myContextPointer];
        
        [[OperationService sharedOperationService] manageOperation:openOperation owner:self];
    } else {
        [delegate loggedInSuccessfully:homeLink provider:@"Coursera"];
    }
}

-(BOOL) isSessionAlive {
    // for ILoginManager
    return NO;
}


+(BOOL) isSessionAvailable:(NSString *)homeLink {
    
    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[NSURL URLWithString:homeLink]];
        
    for (NSHTTPCookie *cookie in cookies) {
        if ([[cookie name] isEqualToString:@"session"]) {
            return [cookie.expiresDate compare:[NSDate date]] == NSOrderedDescending;
        }
    }
    
    return NO;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if(context != &myContextPointer) {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    } else {
        if ([keyPath isEqualToString:@"response"]) {
            [self authorize:object];
            [object removeObserver:self forKeyPath:@"response" context:&myContextPointer];
        }
    }
}

- (void) authorize:(id)responseObject {
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[[responseObject response] URL]];
    
    NSString *postData = [[NSString alloc] initWithFormat:@"email=%@&password=%@&login=Login", username, password];
    [request setHTTPMethod: @"POST"];
    [request setHTTPBody: [postData dataUsingEncoding:NSUTF8StringEncoding]];

    AFHTTPRequestOperation *loginOperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [loginOperation setRedirectResponseBlock:^NSURLRequest *(NSURLConnection *connection, NSURLRequest *request, NSURLResponse *redirectResponse) {

        if([CourseraCourseLoginManager isSessionAvailable:homeLink]) {
            return request;
        } else {
            [connection cancel];
            [delegate loginRedirected:request provider:@"Coursera"];
            return nil;
        }
    }];
    [loginOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [delegate loggedInSuccessfully:homeLink provider:@"Coursera"];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [delegate loginProtocolError:error provider:@"Coursera"];
    }];
    [[OperationService sharedOperationService] manageOperation:loginOperation owner:self];
}

@end
