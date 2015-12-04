//
//  BasicCoursewareManager.m
//  Coursistant Sceleton
//
//  Created by Andrew on 14.01.13.
//  Copyright (c) 2013 Andrew. All rights reserved.
//

#import "BasicContentManager.h"
#import "AFHTTPRequestOperation.h"
#import "IContentParser.h"
#import "OfflineDataManager.h"

@implementation BasicContentManager

@synthesize delegate, parser;
@synthesize onlineDataHandler, offlineDataHandler;

-(id) init:(id <IContentDelegate>)aDelegate parser:(id<IContentParser>)aParser
{
    self = [super init];
    self.delegate = aDelegate;
    self.parser = aParser;
    return self;
}

-(void) readContent:(NSURL *)requestURL title:(NSString *)title {
    
    if([OfflineDataManager sharedOfflineDataManager].online) {
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:requestURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:120];
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            NSArray *contentData = [parser parseContent:operation.responseString];
            if(onlineDataHandler != nil) {
                onlineDataHandler(title, contentData);
            }
            
            [delegate contentExtracted:contentData];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            if([OfflineDataManager isConnectionNotAvailableError:error]) {
                [self useOfflineData:title];
            } else {
                [delegate contentError:error];
            }
            
        }];
        
        [[OperationService sharedOperationService] manageOperation:operation owner:self];
    } else {
            
        [self useOfflineData:title];
    }
}

-(void) useOfflineData:(NSString *)title {
    if(offlineDataHandler != nil) {
        NSArray *contentData = offlineDataHandler(title);
        if(contentData != nil) {
            [delegate contentExtracted:contentData];
        } else {
            NSString *message = [NSString stringWithFormat:@"No data stored for course \"%@.\"", title];
            NSError *error = [[NSError alloc] initWithDomain:message code:-1 userInfo:nil];
            [delegate contentError:error];
        }
    }
}

@end
