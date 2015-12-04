//
//  IProfileManager.h
//  Coursistant Sceleton
//
//  Created by Andrew on 21.12.12.
//  Copyright (c) 2012 Andrew. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IProfileDelegate.h"
#import "OperationService.h"

@protocol IProfileManager <NSObject>

@required

- (id) init: (id <IProfileDelegate>) aDelegate;

- (void) readProfile:(NSString *)aUserID;

@end
