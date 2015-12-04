//
//  CSTJSONRequestOperation.m
//  Coursistant Sceleton
//
//  Created by Andrew on 07.05.13.
//  Copyright (c) 2013 Andrew. All rights reserved.
//

#import "CSTJSONRequestOperation.h"

@implementation CSTJSONRequestOperation

+ (CSTJSONRequestOperation *)JSONRequestOperationWithRequest:(NSURLRequest *)urlRequest
                                                    success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                                                    failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure
                                             responseFilter:(NSData *(^)(NSData *response))responseFilter
{
    CSTJSONRequestOperation *requestOperation = [[self alloc] initWithRequest:urlRequest];
    requestOperation.responseFilter = responseFilter;
    [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (success) {
            success(operation.request, operation.response, responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
            failure(operation.request, operation.response, error, [(AFJSONRequestOperation *)operation responseJSON]);
        }
    }];
    
    return requestOperation;
}


- (id)responseData {
    if(self.responseFilter != nil) {
        return self.responseFilter(super.responseData);
    } else {
        return super.responseData;
    }
}

+ (NSSet *)acceptableContentTypes {
    return [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", nil];
}

@end
