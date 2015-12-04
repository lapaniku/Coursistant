//
//  IProviderLoginDelegate.h
//  Coursistant Sceleton
//
//  Created by Andrew on 20.12.12.
//  Copyright (c) 2012 Andrew. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ILoginDelegate <NSObject>

@required

- (void) loggedInSuccessfully:(NSString *)aUserID provider:(NSString *)provider;

- (void) loginErrorWithMessage:(NSString *)errorMessage provider:(NSString *)provider;

- (void) loginProtocolError:(NSError *)error provider:(NSString *)provider;

- (void) loginRedirected:(NSURLRequest *)request provider:(NSString *)provider;

@end
