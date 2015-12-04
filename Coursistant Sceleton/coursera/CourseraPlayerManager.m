//
//  CourseraPlayerManager.m
//  Coursistant
//
//  Created by Andrei Lapanik on 22.11.13.
//  Copyright (c) 2013 Altasapiens. All rights reserved.
//

#import "CourseraPlayerManager.h"
#import "AFHTTPRequestOperation.h"

@implementation CourseraPlayerManager

@synthesize parser, delegate;

-(id) init:(id <IContentDelegate>)aDelegate parser:(id<IContentParser>)aParser {
    self = [super init];
    delegate = aDelegate;
    parser = aParser;
    return self;
}


- (void) readContent:(NSURL *)requestURL title:(NSString *)title{

    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:requestURL];
    AFHTTPRequestOperation *requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSMutableArray *contentData = [[NSMutableArray alloc] initWithObjects:[requestURL description], nil];
        [contentData addObjectsFromArray:[parser parseContent:operation.responseString]];
        [delegate contentExtracted:contentData];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [delegate contentError:error];
    }];
    
    [requestOperation start];
}

@end
