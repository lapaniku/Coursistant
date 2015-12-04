//
//  CourseraVideoLinkManager.m
//  Coursera Downloader
//
//  Created by Andrew on 17.12.12.
//  Copyright (c) 2012 Andrew. All rights reserved.
//

#import "CourseraVideoLinkManager.h"
#import "AFHTTPRequestOperation.h"
#import "CourseraVideoLinkDelegate.h"
#import "OperationService.h"

@implementation CourseraVideoLinkManager

@synthesize videoLinkDelegate;

- (id) initWithDelegate: (id <CourseraVideoLinkDelegate>) delegate {
    
    self = [super init];
    self.videoLinkDelegate = delegate;
    serialQueue = [[NSOperationQueue alloc] init];
    [serialQueue setMaxConcurrentOperationCount:1];
    return self;
}

-(NSOperation *) createLinkOperation:(NSString *)lectureLink {
    NSURL *lectureURL = [NSURL URLWithString:lectureLink];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:lectureURL];
    AFHTTPRequestOperation *requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    __block AFHTTPRequestOperation *_requestOperation = requestOperation;
    
    [requestOperation setRedirectResponseBlock:^NSURLRequest *(NSURLConnection *connection, NSURLRequest *request, NSURLResponse *redirectResponse) {
        
        if(redirectResponse) {
            //NSLog(@"Request: \n%@", [[request URL] description]);
            
            [_requestOperation cancel];
            
            
            // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! RECODE !!!!!!!!!!!!!!!!!!!!!!!!!!!
            [videoLinkDelegate lectureVideoURLReady:[request URL] initialURL:lectureURL];
            return request;
        } else {
            return request;
        }
    }];
    return requestOperation;
}

-(void) requestSingleVideoLink:(NSString *)lectureLink {
    
    NSOperation *requestOperation = [[NSOperation alloc] init];
    requestOperation = [self createLinkOperation:lectureLink];
    [requestOperation start];
}

-(void) requestSerialVideoLink:(NSString *)lectureLink {
    
    NSOperation *requestOperation = [[NSOperation alloc] init];
    requestOperation =[self createLinkOperation:lectureLink];
    NSOperation *lastAddedOperation;
    if(serialQueue.operations.count > 0) {
        lastAddedOperation = [serialQueue.operations objectAtIndex:serialQueue.operations.count-1];
    }
    if(lastAddedOperation != nil) {
        [requestOperation addDependency:lastAddedOperation];
    }

    [serialQueue addOperation:requestOperation];
}


@end
