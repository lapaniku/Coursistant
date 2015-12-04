//
//  CourseraCoursewareManager.m
//  Coursistant Sceleton
//
//  Created by Andrew on 22.02.13.
//  Copyright (c) 2013 Andrew. All rights reserved.
//

#import "CourseraCoursewareManager.h"
#import "IContentDelegate.h"
#import "IContentParser.h"
#import "CourseraCourseLoginManager.h"
#import "AFHTTPRequestOperation.h"
#import "OfflineDataManager.h"

@implementation CourseraCoursewareManager

@synthesize delegate;
@synthesize courseURL;
@synthesize username, password;
@synthesize parser;

- (id) init:(id <IContentDelegate>)aDelegate parser:(id<IContentParser>)aParser
{
    self = [super init];
    self.delegate = aDelegate;
    self.parser = aParser;
    return self;
}

- (void) readContent:(NSURL *)requestURL title:(NSString *)title{
    
    courseTitle = title;
    if([OfflineDataManager sharedOfflineDataManager].online) {
//        courseLoginManager = [[CourseraCourseLoginManager alloc] init:self];
//        courseLoginManager.homeLink = requestURL.absoluteString;
//        [courseLoginManager doLogin:username password:password];
        
        
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:courseURL];
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            NSArray *contentData = [parser parseContent:operation.responseString];
            [[OfflineDataManager sharedOfflineDataManager] updateCoursewareFor:@"Coursera" courseName:courseTitle courseware:contentData];
            [delegate contentExtracted:contentData];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            if([OfflineDataManager isConnectionNotAvailableError:error]) {
                [self useOfflineData:courseTitle];
            } else {
                [delegate contentError:error];
            }
        }];
        
        [[OperationService sharedOperationService]manageOperation:operation owner:self];

    } else {
        
        [self useOfflineData:title];
    }
}

- (void) loggedInSuccessfully:(NSString *)aUserID provider:(NSString *)provider {
    if([OfflineDataManager sharedOfflineDataManager].online) {
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:courseURL];
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            NSArray *contentData = [parser parseContent:operation.responseString];
            [[OfflineDataManager sharedOfflineDataManager] updateCoursewareFor:@"Coursera" courseName:courseTitle courseware:contentData];
            [delegate contentExtracted:contentData];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            if([OfflineDataManager isConnectionNotAvailableError:error]) {
                [self useOfflineData:courseTitle];
            } else {
                [delegate contentError:error];
            }
        }];
                
        [[OperationService sharedOperationService]manageOperation:operation owner:self];
    } else {
        
        [self useOfflineData:courseTitle];
    }
}

- (void) loginErrorWithMessage:(NSString *)errorMessage provider:(NSString *)provider {
        
    //todo: implement
    [delegate contentExtracted:[[NSArray alloc] init]];
}

- (void) loginProtocolError:(NSError *)error provider:(NSString *)provider {
    
    //todo: implement
    [delegate contentExtracted:[[NSArray alloc] init]];
}

- (void) loginRedirected:(NSURLRequest *)request provider:(NSString *)provider {
    [delegate contentExtracted:[[NSArray alloc] init]];
}

-(void) useOfflineData:(NSString *)title {
    NSArray *contentData = [[OfflineDataManager sharedOfflineDataManager] coursewareFor:@"Coursera" courseName:title];
    if(contentData != nil) {
        [delegate contentExtracted:contentData];
    } else {
        NSString *message = [NSString stringWithFormat:@"No data stored for course \"%@.\"", title];
        NSError *error = [[NSError alloc] initWithDomain:message code:-1 userInfo:nil];
        [delegate contentError:error];
    }
}


@end
