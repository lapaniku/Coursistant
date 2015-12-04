//
//  UdacityProfileManager.m
//  Coursistant Sceleton
//
//  Created by Andrew on 26.12.12.
//  Copyright (c) 2012 Andrew. All rights reserved.
//

#import "UdacityProfileManager.h"
#import "IProfileDelegate.h"
#import "AFHTTPRequestOperation.h"
#import "UdacityLinks.h"
#import "JSParser.h"
#import "ParserManager.h"
#import "LoginHelper.h"
#import "OfflineDataManager.h"
#import "UdacityLoginManager.h"

@implementation UdacityProfileManager

@synthesize delegate;

static void *myContextPointer;

- (id) init: (id <IProfileDelegate>) aDelegate
{
    self = [super init];
    self.delegate = aDelegate;
    return self;
}

- (void) readProfile:(NSString *)aUserID {
    
    if([OfflineDataManager sharedOfflineDataManager].online) {
        
        NSString *token = [UdacityLoginManager extractToken];
        
        if(token == nil) {
            NSURLRequest *openSessionRequest = [[NSURLRequest alloc] initWithURL:[UdacityLinks BaseURL]];
            openSessionOperation = [[AFHTTPRequestOperation alloc] initWithRequest:openSessionRequest];
            
            __unsafe_unretained UdacityProfileManager *upm = self;
            [openSessionOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                //NSLog(@"Success");
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                if([OfflineDataManager isConnectionNotAvailableError:error]) {
                    
                    [upm useOfflineData];
                } else {
                    [upm.delegate profileError:error code:nil];
                }
            }];
            [openSessionOperation addObserver:self forKeyPath:@"response" options:NSKeyValueObservingOptionNew  context:&myContextPointer];
            [[OperationService sharedOperationService] manageOperation:openSessionOperation owner:self];
            
        } else {
            [self requestProfile:token];
        }
    } else {
        [self useOfflineData];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if(context != &myContextPointer) {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    } else {
        if ([keyPath isEqualToString:@"response"]) {
            NSString *token = [UdacityLoginManager extractToken];
            [self requestProfile:token];
            [object removeObserver:self forKeyPath:@"response" context:&myContextPointer];
        }
    }
}

- (void) requestProfile:(NSString *)token {
    
    NSMutableURLRequest *profileRequest = [[NSMutableURLRequest alloc] initWithURL:[UdacityLinks ProfileURL]];
    
    [profileRequest setHTTPMethod: @"GET"];
    [profileRequest setValue:@"https://www.udacity.com/my_courses" forHTTPHeaderField:@"Referer"];
    [profileRequest setValue:@"XMLHttpRequest" forHTTPHeaderField:@"X-Requested-With"];
    [profileRequest setValue:token forHTTPHeaderField:@"X-XSRF-TOKEN"];
    
    
    queue = [[NSOperationQueue alloc] init];
    [queue setMaxConcurrentOperationCount:1];
    
    AFHTTPRequestOperation *getProfileOperation = [[AFHTTPRequestOperation alloc] initWithRequest:profileRequest];
    
    [getProfileOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        JSParser *jsparser = [[JSParser alloc] init:[ParserManager script:@"UdacityProfileDataParser"]];
        NSArray *parserResult = [jsparser parseContent:operation.responseString];
        if(([parserResult count] > 0) && ![[parserResult objectAtIndex:0] isKindOfClass:[NSDictionary class]]) {
            
            [self extractCourseInfo:parserResult];
        } else {
            
            NSArray *newCourses = [[OfflineDataManager sharedOfflineDataManager] updateProfileFor:@"Udacity" profile:parserResult];
            [delegate profileExtracted:parserResult newCources:newCourses];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if([OfflineDataManager isConnectionNotAvailableError:error]) {
            [self useOfflineData];
        } else {
            [delegate profileError:error code:[@"Udacity" stringByAppendingString:[@(operation.response.statusCode) description]]];
        }
    }];
    
    [[OperationService sharedOperationService] manageOperation:getProfileOperation owner:self];
}

- (void) extractCourseInfo:(NSArray *)courseData {
    
    if([OfflineDataManager sharedOfflineDataManager].online) {
        NSURL *dataURL = [NSURL URLWithString:[courseData objectAtIndex:0]];
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:dataURL];
        
        AFHTTPRequestOperation *courseInfoOperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        
        [courseInfoOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            NSMutableArray *parseData = [[NSMutableArray alloc] initWithArray:courseData];
            [parseData replaceObjectAtIndex:0 withObject:operation.responseString];
            
            JSParser *jsparser = [[JSParser alloc] init:[ParserManager script:@"UdacityCourseInfoParser"]];
            NSArray *parserResult = [jsparser parseArray:parseData];
            NSArray *newCourses = [[OfflineDataManager sharedOfflineDataManager] updateProfileFor:@"Udacity" profile:parserResult];
            [delegate profileExtracted:parserResult newCources:newCourses];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            if([OfflineDataManager isConnectionNotAvailableError:error]) {
                [self useOfflineData];
            } else {
                [delegate profileError:error code:nil];
            }
        }];
        
        [[OperationService sharedOperationService] manageOperation:courseInfoOperation owner:self];
    } else {
        
        [self useOfflineData];
    }
}

-(void) useOfflineData {
    NSArray *profile = [[OfflineDataManager sharedOfflineDataManager] profileFor:@"Udacity"];
    if(profile != nil) {
        [delegate profileExtracted:profile newCources:nil];
    } else {
        NSString *message = [NSString stringWithFormat:@"No data stored for Udacity provider"];
        NSError *error = [[NSError alloc] initWithDomain:message code:-1 userInfo:nil];
        
        [delegate profileError:error code:nil];
    }
}

@end
