//
//  IProviderLoginManager.h
//  Coursistant Sceleton
//
//  Created by Andrew on 20.12.12.
//  Copyright (c) 2012 Andrew. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ILoginDelegate.h"
#import "OperationService.h"

typedef enum {SessionAlive=0, SessionExpired, NoSession} SessionStatus;

@protocol ILoginManager <NSObject>

@required

-(id) init: (id <ILoginDelegate>) aDelegate;

-(void) doLogin: (NSString *) aUsername password: (NSString *) aPassword;

-(BOOL) isSessionAlive;

@optional
-(void) deleteCookies;

@end
