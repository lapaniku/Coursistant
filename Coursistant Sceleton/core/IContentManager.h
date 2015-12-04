//
//  IContentManager.h
//  Coursistant Sceleton
//
//  Created by Andrew on 07.02.13.
//  Copyright (c) 2013 Andrew. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IContentDelegate.h"
#import "IContentParser.h"
#import "OperationService.h"

@protocol IContentManager <NSObject>

@required

-(id) init:(id <IContentDelegate>)aDelegate parser:(id<IContentParser>)aParser;

-(void) readContent:(NSURL *)requestURL title:(NSString *)title;

-(id <IContentDelegate>) delegate;

@end
