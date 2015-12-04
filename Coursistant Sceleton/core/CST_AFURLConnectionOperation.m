    //
//  CST_AFURLConnectionOperation.m
//  Coursistant
//
//  Created by Администратор on 28.7.13.
//  Copyright (c) 2013 Andrew. All rights reserved.
//

#import "CST_AFURLConnectionOperation.h"
#import "AFURLConnectionOperation.h"

#if defined(__IPHONE_OS_VERSION_MIN_REQUIRED)
typedef UIBackgroundTaskIdentifier AFBackgroundTaskIdentifier;
#else
typedef id AFBackgroundTaskIdentifier;
#endif

@interface CST_AFURLConnectionOperation()
@property (readwrite, nonatomic, strong) NSRecursiveLock *lock;
@property (readwrite, nonatomic, assign) AFBackgroundTaskIdentifier backgroundTaskIdentifier;

@end



@implementation CST_AFURLConnectionOperation

@synthesize lock = _lock;
@synthesize backgroundTaskIdentifier = _backgroundTaskIdentifier;


- (void)setShouldExecuteAsBackgroundTaskWithExpirationHandlerCST:(void (^)(void))handler {
    [self.lock lock];
    if (!self.backgroundTaskIdentifier) {
        UIApplication *application = [UIApplication sharedApplication];
        __weak __typeof(&*self)weakSelf = self;
        self.backgroundTaskIdentifier = [application beginBackgroundTaskWithExpirationHandler:^{
            __strong __typeof(&*weakSelf)strongSelf = weakSelf;
            
            if (handler) {
                handler();
            }
            
            if (strongSelf) {
                
                if ([strongSelf isFinished]) {
                    [strongSelf cancel];
                } else {
                    [strongSelf pause];
                }
                
                
                [application endBackgroundTask:strongSelf.backgroundTaskIdentifier];
                strongSelf.backgroundTaskIdentifier = UIBackgroundTaskInvalid;
                
            }
        }];
    }
    [self.lock unlock];
}

@end
