//
//  CSTJSONRequestOperation.h
//  Coursistant Sceleton
//
//  Created by Andrew on 07.05.13.
//  Copyright (c) 2013 Andrew. All rights reserved.
//

#import "AFJSONRequestOperation.h"

@interface CSTJSONRequestOperation : AFJSONRequestOperation

@property (nonatomic, copy) NSData *(^responseFilter)(NSData *response);

+ (CSTJSONRequestOperation *)JSONRequestOperationWithRequest:(NSURLRequest *)urlRequest
                                                     success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                                                     failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure
                                              responseFilter:(NSData *(^)(NSData *response))responseFilter;

@end
