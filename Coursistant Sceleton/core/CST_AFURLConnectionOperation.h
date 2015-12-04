//
//  CST_AFURLConnectionOperation.h
//  Coursistant
//
//  Created by Администратор on 28.7.13.
//  Copyright (c) 2013 Andrew. All rights reserved.
//

#import "AFURLConnectionOperation.h"

@interface CST_AFURLConnectionOperation : AFURLConnectionOperation
- (void)setShouldExecuteAsBackgroundTaskWithExpirationHandlerCST:(void (^)(void))handler;
@end
